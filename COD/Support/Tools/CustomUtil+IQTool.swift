//
//  CustomUtil+IQTool.swift
//  COD
//
//  Created by 1 on 2020/4/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import LGAlertView
import SafariServices

extension CustomUtil{
    
    typealias AFSNetSuccessBlock = (NSDictionary,SwiftyJSON.JSON) -> Void
    typealias AFSNetFaliedBlock  = (AFSErrorInfo) -> Void
    typealias DeleteCompletionBlock  = (NSInteger) -> Void
    static var pushTime = "0"
    /// 解析一个IQ
    ///
    /// - Parameters:
    ///   - iq: 传入一个IQ
    ///   - result: 解析结果回调
    class func analyticxXML(iq : XMPPIQ,result : @escaping (_ action : NSDictionary,_ info : NSDictionary? ) -> ()) {
        if iq.isErrorIQ {
//           CODProgressHUD.showErrorWithStatus("响应异常")
        return
        }
            
        if let member:DDXMLElement = iq.childElement {
            let actionNode = member.children?.first
                
            guard let actionString = actionNode?.stringValue else {
                return
            }
                
            let actionJson = JSON(parseJSON: actionString)
                
            guard let actionDic = actionJson.dictionaryObject as NSDictionary? else {
                return
            }

            let infoNode = member.children?.last
            let infoString = infoNode?.stringValue
            if infoString == nil {
                result(actionDic, nil)
            }
            if let infoData = infoString?.data(using: String.Encoding.utf8) {
                
                let infoDic:NSDictionary = try! JSONSerialization.jsonObject(with: infoData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                result(actionDic,infoDic)
                    
            }
        }

    }

        
    /// 生成一个固定格式IQ
    ///
    /// - Parameters:
    ///   - type: iqtype
    ///   - xmlns: xmlns
    ///   - actionDic: 对应的action字典
    /// - Returns: 返回一个iq
    class func xmppIQWithType(type : XMPPIQ.IQType, xmlns : String , actionDic : NSDictionary) -> XMPPIQ {
        
        let query : DDXMLElement = DDXMLElement.init(name: "query", xmlns: xmlns as String)
        let action : DDXMLElement = DDXMLElement.init(name: "action", stringValue: CustomUtil.stringWithDictionary(dict: actionDic) as String)
        let iq = XMPPIQ.init(iqType: type)
        query.addChild(action)
        iq.addChild(query)
        return iq
    }
        
    class func xmppIQ(type : XMPPIQ.IQType, xmlns : String , action: Dictionary<String, Any>) -> XMPPIQ {
        let query : DDXMLElement = DDXMLElement.init(name: "query", xmlns: xmlns as String)
        let action : DDXMLElement = DDXMLElement.init(name: "action", stringValue: action.jsonString() ?? "")
        let iq = XMPPIQ(iqType: type)
        query.addChild(action)
        iq.addChild(query)
        return iq
    }
        
    @objc class func objcXmppIQWithSet(xmlns : String , actionDic : NSDictionary) -> XMPPIQ {
        
        let query : DDXMLElement = DDXMLElement.init(name: "query", xmlns: xmlns as String)
        let action : DDXMLElement = DDXMLElement.init(name: "action", stringValue: CustomUtil.stringWithDictionary(dict: actionDic) as String)
        let iq = XMPPIQ.init(iqType: .set)
        query.addChild(action)
        iq.addChild(query)
        return iq
    }
        
    @objc class func objcXmppIQWithSetRTC(xmlns : String , actionDic : NSDictionary) -> XMPPIQ {
        
        let query : DDXMLElement = DDXMLElement.init(name: "query", xmlns: xmlns as String)
        let action : DDXMLElement = DDXMLElement.init(name: "action", stringValue: CustomUtil.stringWithDictionaryRTC(dict: actionDic) as String)
        let iq = XMPPIQ.init(iqType: .set)
        query.addChild(action)
        iq.addChild(query)
        return iq
    }

        
    class func sendPresence() {
        
        CustomUtil.checkVersion()
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kEndGetHistory), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil)
//        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPointForCircle), object: nil)
        
        
        let presence = XMPPPresence.init()
        XMPPManager.shareXMPPManager.xmppStream.send(presence)
        
        if XMPPManager.shareXMPPManager.xmppAutoPing != nil{
            XMPPManager.shareXMPPManager.xmppAutoPing.deactivate()
        }
        let xmppAutoPing = XMPPAutoPing()
        xmppAutoPing.addDelegate(XMPPManager.shareXMPPManager, delegateQueue: DispatchQueue.main)
        XMPPManager.shareXMPPManager.xmppAutoPing = xmppAutoPing
        XMPPManager.shareXMPPManager.xmppAutoPing.activate(XMPPManager.shareXMPPManager.xmppStream)
        XMPPManager.shareXMPPManager.xmppAutoPing.pingTimeout = 15
        XMPPManager.shareXMPPManager.xmppAutoPing.pingInterval = 30 //不设置默认60s
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.xmppConnectedSemaphore.signal()
        }
    }
    
    class func getPresencePriority(presence: XMPPPresence) -> OnlineState? {
        
        guard let children = presence.children else {
            return nil
        }
        
        for child in children {
            
            if child.name == "priority" {
                return child.stringValue.map { (OnlineState(rawValue: $0) ?? .online) }
            }
            
        }
        
        return nil
        
    }
    
    class func sendPresenceWithUnavailable() {
        
        let presence = XMPPPresence(type: "unavailable")
        XMPPManager.shareXMPPManager.xmppStream.send(presence)
    }
    
    class func parsingSessionItemList(dic:NSDictionary,isUpdate:Bool, topRankList: [String]){
            
        DispatchQueue.realmWriteQueue.async {
            let realm = try! Realm()
            if let array = dic["sessionItemVoList"] as? Array<NSDictionary> {
                
                var sessionList:Array<CODChatListModel> = Array<CODChatListModel>()
                    
                XinhooTool.addLog(log:"服务器返回会话列表")
                    
                var chatModelID: [Int] = Array()
                    
                for itemVo in array {
                        
                    if let sessionItem = SessionItemModel.deserialize(from: itemVo) {
                            
                        //2.0遗留功能完善，【mango客户反馈】IOS2.0版本里，小助手删掉以后，上线又跑出来了
                        //服务器没有提供删除会话的接口，经需求评审讨论，客户端自己本地逻辑删除，接收到会话列表的时候，判断小助手的badge是否为0，如果是0则不做任何操作
                        if sessionItem.itemID.contains("cod_60000000"),let chatModel = CODChatListRealmTool.getChatList(jid: sessionItem.itemID) ,chatModel.isInValid == true{
                            if sessionItem.badge == 0 {
                                continue
                            }
                        }
                            
                        if let chatModel = CODChatListRealmTool.getChatList(jid: sessionItem.itemID) {
                                
                            chatModelID.append(chatModel.id)
                                
                            do {
                                try realm.write {
                                    
                                    if let contact = CODContactRealmTool.getContactByJID(by: sessionItem.itemID) {
                                        chatModel.contact = contact
                                    }
                                    
                                    if let group = CODGroupChatRealmTool.getGroupChatByJID(by: sessionItem.itemID) {
                                        chatModel.groupChat = group
                                    }
                                    
                                    if let channel = CODChannelModel.getChannel(jid: sessionItem.itemID) {
                                        chatModel.channelChat = channel
                                    }
                                    
                                    chatModel.count = sessionItem.badge
                                    chatModel.lastMessage = sessionItem.lastMessage
                                    chatModel.title = sessionItem.itemName
                                    chatModel.groupRtc = sessionItem.groupRtc
                                    chatModel.groupRtcRoomId = sessionItem.groupRtcRoomId
                                    chatModel.groupRtcRequester = sessionItem.groupRtcRequester
                                    
                                    if let videoCallJid = CustomUtil.getRoomJid() {
                                        
                                        if videoCallJid == chatModel.jid && chatModel.groupRtc == 0{
                                            DispatchQueue.main.async {
                                                NotificationCenter.default.post(name: NSNotification.Name.init(kLoginoutNoti), object: nil, userInfo: nil)
                                            }
                                        }
                                        
                                    }
                                    
                                    if sessionItem.itemID.contains("cod_60000000") {
                                        chatModel.title = "\(kApp_Name)小助手"
                                    }
                                    for referto in sessionItem.referToResultVoList {
                                            
                                        let dict = ["msgId":referto["msgId"],"sendTime":referto["sendTime"]]
                                        
                                        if let jsonString = dict.jsonString(),chatModel.count > 0 {
                                            let strArr = jsonString.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").components(separatedBy: ",")
                                            if strArr.count == 2 {
                                                if !chatModel.referToMessageID.contains("{" + strArr[0] + "," + strArr[1] + "}") && !chatModel.referToMessageID.contains("{" + strArr[1] + "," + strArr[0] + "}") {
                                                    chatModel.referToMessageID.append(jsonString)
                                                }
                                            }
                                        }
                                    }
                                    
                                    if chatModel.count == 0 {
                                        chatModel.referToMessageID.removeAll()
                                    }
                                        
                                    chatModel.lastReadTime = sessionItem.lastReadTime
                                    chatModel.lastReadTimeOfMe = sessionItem.lastReadTimeOfMe
                                    
                                    
                                    if chatModel.finalPushTime != (sessionItem.clearTime.int ?? 0) && (sessionItem.clearTime.int ?? 0) > 0 {
                                        chatModel.finalPushTime = (sessionItem.clearTime.int ?? 0)
                                        CODChatListRealmTool.deleteMessageWithTime(time: sessionItem.clearTime, id: chatModel.id)
                                    }

                                    switch sessionItem.deleteTypeEnum {
                                    case .delete:
                                        chatModel.isInValid = true
                                        break

                                    case .active:
                                        chatModel.isInValid = false
                                        break

                                    }
                                    
                                    if sessionItem.lastMessage.count > 0 {
                                        do{
                                            let message = try XMPPMessage.init(xmlString: sessionItem.lastMessage)
                                            if let messageModel = XMPPManager.shareXMPPManager.xmppMessageToRealmMessage(message: message),messageModel.text.count > 0 {
                                                
                                                if (messageModel.type == .notification && messageModel.text == "") || messageModel.type == .haveRead  {
                                                    return
                                                }
                                                
                                                CODChatListRealmTool.addChatListMessage(id: chatModel.id, message: messageModel)
                                                //                                           self.updateLastPushTime(message: messageModel)
                                                if (self.pushTime.int ?? 0) < messageModel.datetimeInt {
                                                    self.pushTime = messageModel.datetime
                                                }
                                                
                                            }
                                        }catch{
                                            
                                        }
                                        
                                    }
                                }
                                    
                                    
                            }catch{}
                        }else{
                                
                            if let chatModel = CODChatListRealmTool.buildChatModel(sessionItem: sessionItem) {
                                chatModelID.append(chatModel.id)
                                sessionList.append(chatModel)
                            }
                                
                        }
                            
                            
                            
                    }
                }
                try! realm.write {
                    realm.add(sessionList, update: .modified)
                }
                    
                if isUpdate {
                    HistoryMessageManger.default.getRemoteHistoryList(chatIds: chatModelID, complete: nil)
                }
                    
            }
                
            if let dictionary = dic["rosterItemVo"] as? NSDictionary {
                    
                DispatchQueue.main.async {
                    UserManager.sharedInstance.haveNewFriend = (dictionary["badge"] as? Int) ?? 0
                }
                    
                let newfirendModel = CODContactModel()
                newfirendModel.rosterID = NewFriendRosterID
                newfirendModel.jid = (dictionary["itemID"] as? String) ?? NewFriendJid
                newfirendModel.username = NewFriendFlagBack
                newfirendModel.nick = NewFriendFlagBack
                newfirendModel.name = (dictionary["itemName"] as? String) ?? ""
                newfirendModel.isValid = true
                newfirendModel.stickytop = dictionary["stickytop"] as? Bool ?? false
                
                CODContactRealmTool.insertContact(by: newfirendModel)
                    
                let chatModel = CODChatListModel()
                chatModel.id = NewFriendRosterID
                chatModel.jid = newfirendModel.jid
                chatModel.title = (dictionary["nickName"] as? String) ?? ""
                chatModel.subTitle = (dictionary["desc"] as? String) ?? ""
                chatModel.count = (dictionary["badge"] as? Int) ?? 0
                chatModel.lastDateTime = (dictionary ["lastRequestTime"] as? String) ?? ""
                chatModel.stickyTop = newfirendModel.stickytop
                chatModel.contact = newfirendModel
                
                try! realm.write {
                    realm.create(CODChatListModel.self,value:["id":NewFriendRosterID,"jid":chatModel.jid,"title":chatModel.title,"subTitle":chatModel.subTitle,"count":chatModel.count,"lastDateTime":chatModel.lastDateTime,"stickyTop":chatModel.stickyTop,"contact":newfirendModel] , update: .all)
                }
            }
            
            CustomUtil.topRankListHander(chatJIDList: topRankList)
                
                
            DispatchQueue.main.async {
                
                XinhooTool.addLog(log:"服务器返回会话列表--并且后台加群成功--移动端发送出席")
                UserDefaults.standard.set(true, forKey: kIsFirst + UserManager.sharedInstance.loginName!)
                
                if XMPPManager.shareXMPPManager.isRepairData {
                    NotificationCenter.default.post(name: NSNotification.Name.init(kRepairSuccess), object: nil)
                }
                
                
                self.updatePushTime(time: self.pushTime)
                
                sendPresence()
                
            }
                
        }

    }
        
    class func updatePushTime(time:String) {
        
        if let loginName = UserManager.sharedInstance.loginName {
                
            if let lastPushTime = (CODUserDefaults.object(forKey: kLastMessageTime + loginName) as? String)?.int {
                if lastPushTime < (time.int ?? 0) {
                    CODUserDefaults.set(time, forKey: kLastMessageTime + loginName)
                    CODUserDefaults.synchronize()
                }
            } else {
                CODUserDefaults.set(time, forKey: kLastMessageTime + loginName)
                CODUserDefaults.synchronize()
            }
        }
        self.pushTime = "0"
        
    }
        
    class func updateLastPushTime(message:CODMessageModel) {
            
        if let loginName = UserManager.sharedInstance.loginName {
        
            if let lastPushTime = (CODUserDefaults.object(forKey: kLastMessageTime + loginName) as? String)?.int {
                if lastPushTime < message.datetimeInt {
                    CODUserDefaults.set(message.datetime, forKey: kLastMessageTime + loginName)
                    CODUserDefaults.synchronize()
                }
            } else {
                CODUserDefaults.set(message.datetime, forKey: kLastMessageTime + loginName)
                CODUserDefaults.synchronize()
            }
        }
    }
        
    class func getSessionItemList(lastPushTime:String,isFull:Bool) {
        
        XinhooTool.addLog(log:"开始获取会话列表 --- lastPushTime:\(lastPushTime)")
        var dict:NSDictionary? = [:]
        
        dict = ["name":COD_getsessionitemlist,
                "requester":UserManager.sharedInstance.jid,
                "isFull":isFull,
                "lastPushTime":lastPushTime]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_groupChat_v2, actionDic: dict!)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    /// 获取历史消息
    class func getHistoryMessage(lastMessageTime: String, roomID: String){
        
        
//        var dict:NSDictionary? = [:]
        
//        dict = ["name":COD_getRoomMsgHistory,
//                "requester":UserManager.sharedInstance.jid,
//                "lastPushTime":lastMessageTime,
//                "roomID":roomID]
//
//        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_groupChat, actionDic: dict!)
        
        var cloudDict:NSDictionary? = [:]
        
        cloudDict = ["name":COD_getCloudMsgHistory,
                     "requester":UserManager.sharedInstance.jid,
                     "lastPushTime":lastMessageTime]
        
        let cloudIQ = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_groupChat, actionDic: cloudDict!)
        
//        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        XMPPManager.shareXMPPManager.xmppStream.send(cloudIQ)
    }
    
    class func connectedNoti() {
        //通知后台自动加群
        let  dict:NSDictionary = ["name":COD_AutoJoinRoom,
                                  "requester":UserManager.sharedInstance.jid as Any,
                                  "resources":UserManager.sharedInstance.resource as Any]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_groupChat, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    class func getSessionList() {
        if let loginName = UserManager.sharedInstance.loginName {

            if let lastPushTime = CODUserDefaults.object(forKey: kLastMessageTime + loginName) as? String{
                CustomUtil.getSessionItemList(lastPushTime: lastPushTime, isFull: false)
            }else{
                CustomUtil.getSessionItemList(lastPushTime: "0", isFull: true)
            }
        }
        
    }
    
    /// 获取通讯录增量更新
    class func contactUpdate() {
        
        XinhooTool.addLog(log:"开始获取增量通讯录")
        var lastUpdateTime = ""
        if let lastTime = CODUserDefaults.object(forKey: kLastUpdateContactTime + UserManager.sharedInstance.loginName!) {
            lastUpdateTime = lastTime as! String
        }
        
        let  dict:NSDictionary = ["name":COD_GetContactsUpdate,
                                  "requester":UserManager.sharedInstance.jid as Any,
                                  "ver":lastUpdateTime]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_contacts_v2, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    class func topRankListHander(chatJIDList: [String], needReload: Bool = true) {
        
        for (index, value) in chatJIDList.enumerated() {
            
            var chatListModel: CODChatListModel?
            
            if value == kCloudJid {
                chatListModel = CODChatListRealmTool.getChatList(id: CloudDiskRosterID)
            } else if value == NewFriendFlagBack {
                chatListModel = CODChatListRealmTool.getChatList(id: NewFriendRosterID)
            } else {
                chatListModel = CODChatListRealmTool.getChatList(jid: value)
            }
            
            chatListModel?.setValue(\.stickyTopIndex, value: index)
            
            
            if needReload {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                }
            }
            
            

        }
        
    }
    
    class func pinChatToTop(chatId: Int) -> [CODChatListModel] {
        
        var list = CODChatListRealmTool.getStickyTopList(filterNewFriend: true)
        
        let indexOpt = list.firstIndex { $0.id == chatId }
        if let index = indexOpt {
            list = list.rearrange(fromIndex: index, toIndex: 0)
        }
        
        return list
        
    }
    
    class func pinChatToTop(jid: String) -> [CODChatListModel] {
        
        var list = CODChatListRealmTool.getStickyTopList(filterNewFriend: true)
        
        let indexOpt = list.firstIndex { $0.jid == jid }
        if let index = indexOpt {
            list = list.rearrange(fromIndex: index, toIndex: 0)
        }
        
        return list
        
    }

    class func removeMessage(messageModel: CODMessageModel, chatType: CODMessageChatType, chatId: Int, superView: UIView? ,deleteCompletionBlock: DeleteCompletionBlock?){
        
        let memberId = CODGroupMemberModel.getMemberId(roomId: chatId, userName: UserManager.sharedInstance.jid)
        let member = CODGroupMemberRealmTool.getMemberById(memberId)
        
        var isAdmin = false
        if member?.userpower ?? 30 < 30 {
            isAdmin = true
        }else {
            isAdmin = false
        }
        
        var btnArr: Array<String> = Array()
        let fromMe: Bool = messageModel.fromWho.contains(UserManager.sharedInstance.loginName!)
        let isGroup: Bool = messageModel.isGroupChat
        if fromMe {
            if isGroup {
                btnArr = ["为所有人删除","从本地删除"]
            }else{
                if chatId < 0 {
                    btnArr = ["删除"]
                }else{
                    btnArr = ["消息双向删除","从本地删除"]
                }
                
            }
        }else{
            if isGroup {
                if isAdmin {
                    btnArr = ["为所有人删除","从本地删除"]
                }else{
                    btnArr = ["从本地删除"]
                }
            }else{
                btnArr = ["从本地删除"]
            }
        }
        
        var removeTime = 10
        let todayTemp = Int64(Date.milliseconds)
        
//        if chatType != .privateChat {
            #if MANGO
            removeTime = 2880

            #elseif PRO
            removeTime = 1440

            #else
            removeTime = 10
            
            #endif
//        }

        if todayTemp - Int64(messageModel.datetimeInt ) >= 60 * removeTime * 1000{
              btnArr = ["从本地删除"]
        }
        
        if chatId == CloudDiskRosterID {
            if btnArr.contains("从本地删除") {
                btnArr.removeAll("从本地删除")
                btnArr.append("删除")
            }
        }
        
        if chatId == 0 || messageModel.statusType == .Failed {
            btnArr = ["删除"]
        }
        
        if chatType == .channel {
            btnArr = ["为所有人删除"]
        }
        
        var titleString: String?
        let imageCount: Int = self.getMessageImageCount(msgID: messageModel.msgID)
        if imageCount > 0 {
            titleString = String.init(format: NSLocalizedString("将删除%ld张图片", comment: ""), imageCount)
        }
        
        CODActionSheet.show(withTitle: titleString, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: btnArr, cancelButtonColor: UIColor.init(hexString: "#367CDE"), destructiveButtonColor: UIColor.init(hexString: "#367CDE"), otherButtonColors: [UIColor.red,UIColor.red], superView: superView) { (actionSheet, index) in

            if index != 0 {
                if btnArr.count == 2 {
                    if index == 1{
                        self.sendRemoveMessageIQ(isGroup: isGroup, fromMe: fromMe, isLocal: false, msgID: messageModel.msgID, chatType: chatType, chatId: chatId)
                    }else{
                        self.sendRemoveMessageIQ(isGroup: isGroup, fromMe: fromMe, isLocal: true, msgID: messageModel.msgID, chatType: chatType, chatId: chatId)
                    }
                }else if btnArr.count == 1 {
                    if chatType == .channel {
                        self.sendRemoveMessageIQ(isGroup: isGroup, fromMe: fromMe, isLocal: false, msgID: messageModel.msgID, chatType: chatType, chatId: chatId)
                    }else{
                        self.sendRemoveMessageIQ(isGroup: isGroup, fromMe: fromMe, isLocal: true, msgID: messageModel.msgID, chatType: chatType, chatId: chatId)
                    }
                }
            }
            
            if deleteCompletionBlock != nil {
                
                deleteCompletionBlock!(index)
            }
        }
    }
    
    class func sendRemoveMessageIQ(isGroup: Bool, fromMe: Bool,isLocal: Bool, msgID: String, chatType: CODMessageChatType, chatId: Int) {
         if !CODWebRTCManager.whetherConnectedNetwork() {
             CODProgressHUD.showErrorWithStatus(NSLocalizedString("网络请求失败，请稍后再试", comment: ""))
             return
         }
         if isLocal {
             //删除本地的消息
             self.sendRemoveLocalMSGIQ(isGroup: isGroup, fromMe: fromMe, msgID: msgID, chatType: chatType, chatId: chatId)
         }else{
             //双向删除 单聊  为所有人删除 群聊
             self.sendRemoveMSGIQ(isGroup: isGroup, fromMe: fromMe, msgID: msgID, chatType: chatType, chatId: chatId)
         }
     }
    
    class func  sendRemoveLocalMSGIQ(isGroup: Bool, fromMe: Bool, msgID: String, chatType: CODMessageChatType, chatId: Int){
        var dict = ["requester":UserManager.sharedInstance.jid,
                    "msgID":[msgID]] as [String : Any]
        if isGroup {
            dict["name"] = COD_removeLocalGroupMsg
        }else{
            if chatId == CloudDiskRosterID {
                dict["name"] = COD_removeclouddiskmsg
            }else{
                dict["name"] = COD_removeLocalChatMsg
            }
        }
        if XMPPManager.shareXMPPManager.currentChatFriend.removeAllSapce.count == 0 {
            dict["receiver"] = CODMessageRealmTool.getMessageByMsgId(msgID)?.toJID
        }else{
            dict["receiver"] = XMPPManager.shareXMPPManager.currentChatFriend
        }
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_message, actionDic: dict as NSDictionary)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    class func sendRemoveMSGIQ(isGroup: Bool, fromMe: Bool, msgID: String, chatType: CODMessageChatType, chatId: Int ) {
        var dict = ["requester":UserManager.sharedInstance.jid,
                    "msgID":[msgID]] as [String : Any]
        
        if chatType == .groupChat {
            dict["name"] = COD_removeGroupMsg
        } else if chatType == .channel{
            dict["name"] = COD_removeChannelMsg
        } else {
            dict["name"] = COD_removeChatMsg
        }
        if XMPPManager.shareXMPPManager.currentChatFriend.removeAllSapce.count == 0 {
            dict["receiver"] = CODMessageRealmTool.getMessageByMsgId(msgID)?.toJID
        }else{
            dict["receiver"] = XMPPManager.shareXMPPManager.currentChatFriend
        }
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_message, actionDic: dict as NSDictionary)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    
    /// 多端同步 清除会话聊天记录
    /// - Parameter model: 会话model
    class func clearChatRecord(chatId: Int, success: (() -> ())? = nil) {
        
        //chatType 会话类型：1(小助手,云盘)为单聊，2为群，3为频道
        var chatType = 1
        
        guard let model = CODChatListRealmTool.getChatList(id: chatId) else {
            return
        }
        
        switch model.chatTypeEnum {
        case .privateChat:
            chatType = 1
        case .groupChat:
            chatType = 2
        case .channel:
            chatType = 3
        }
        
        if model.id == RobotRosterID {
            chatType = 1
        }else if model.id == CloudDiskRosterID {
            chatType = 1
        }
        
        let dict: [String : Any] = ["name": COD_clearmsg,
                                    "requester": UserManager.sharedInstance.jid,
                                    "target": model.jid,
                                    "chatType": chatType]
        
        XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_groupChat) { (result) in
            
            switch result {
            case .failure(_):
                CODProgressHUD.showErrorWithStatus("同步清除聊天记录失败")
            case .success(_):
                success?()
                break
            }
        }
    }
    
    /// 多端同步 删除会话
    /// - Parameter model: 会话model
    class func deleteChat(model:CODChatListModel, success: (() -> ())? = nil) {
        
        //chatType 会话类型：1(小助手,云盘)为单聊，2为群，3为频道
        var chatType = 1
        
        switch model.chatTypeEnum {
        case .privateChat:
            chatType = 1
        case .groupChat:
            chatType = 2
        case .channel:
            chatType = 3
        }
        
        if model.id == RobotRosterID {
            chatType = 1
        }else if model.id == CloudDiskRosterID {
            chatType = 1
        }
        
        let dict: [String : Any] = ["name": COD_deletesessionitem, 
                                    "requester": UserManager.sharedInstance.jid,
                                    "target": model.jid,
                                    "chatType": chatType]
        
        XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_groupChat) { (result) in
            
            switch result {
            case .failure(_):
                CODProgressHUD.showErrorWithStatus("同步删除聊天失败")
            case .success(_):
                break
            }
        }
    }
    
    
    class func joinGroupHandle(model: CODResponseModel, linkString: String,isNeedPub: Bool = false,isPub: Bool = false,currentVC: UIViewController? = nil) {
            
            
            if let jsonModel = CODGroupChatHJsonModel.deserialize(from: model.dataJson?.dictionaryObject) {
                
                if let groupModel = CODGroupChatRealmTool.getGroupChat(id: jsonModel.roomID), groupModel.isValid ,groupModel.isMember(by: UserManager.sharedInstance.jid) {
                    
                    if let listModel = CODChatListRealmTool.getChatList(id: jsonModel.roomID) {
                        
                        let msgCtl = MessageViewController()
    //                    msgCtl.newMessageCount = listModel.count
                        msgCtl.title = listModel.groupChat?.getGroupName()
                        msgCtl.chatId = jsonModel.roomID
                        msgCtl.roomId = jsonModel.roomID.string
                        msgCtl.chatType = .groupChat
                        msgCtl.toJID = listModel.groupChat?.jid ?? ""
                        
                        var vc: UIViewController?
                        
                        if currentVC != nil {
                            vc = currentVC
                        }else{
                            vc = UIViewController.current()
                        }
                        
                        
                        if let viewControllers = vc?.navigationController?.viewControllers {
                        
                            
                            var vcs: [UIViewController]  = Array()
                            
                            for i in 1...viewControllers.count {
                                let vc = viewControllers[i-1]
                                if vc.isKind(of: MessageViewController.self) {
                                    break
                                }else{
                                    vcs.append(vc)
                                }
                            }
                            vcs.append(msgCtl)
                            vc?.navigationController?.setViewControllers(vcs, animated: true)
                        
                        }
                    }
                    
                    
                } else {
                    
                    let channelView = DeleteChatListModelView.initWitXib(imgID: jsonModel.grouppic, desc: jsonModel.description, subDesc: String(format: NSLocalizedString("%d 位成员", comment: ""), model.dataJson?["member"].arrayValue.count ?? 0))
                    
                    let alertView = LGAlertView(viewAndTitle: nil, message: nil, style: .actionSheet, view: channelView,
                                buttonTitles: [NSLocalizedString("加入", comment: "")], cancelButtonTitle: NSLocalizedString("取消", comment: ""), destructiveButtonTitle: nil,
                                actionHandler: { (alertView, index, buttonTitle) in
                                    
                                    if index == 0 {
                                        
                                        XMPPManager.shareXMPPManager.joinGroupAndChannel(linkString: linkString, inviter: UserManager.sharedInstance.jid, add: true,isNeedPub: isNeedPub,isPub: isPub) { (result) in
                                            
                                            switch result {
                                                
                                            case .success(let model):
                                                
                                                if let dataJson = model.dataJson {
                                                    CODGroupChatRealmTool.createGroupChat(roomID: dataJson["roomID"].intValue, json: dataJson)
                                                    if isNeedPub {
                                                        self.pushVC(roomID: dataJson["roomID"].intValue, type: .groupChat)
                                                    }else{
                                                        MessageViewController.pushVC(roomID: dataJson["roomID"].intValue, type: .groupChat)
                                                    }
                                                }
                                                
                                                break
                                            case .failure(.iqReturnError(let code, let msg)):
                                                switch code {
                                                case 30039, 30049:
                                                    LGAlertView(title: nil, message: NSLocalizedString("此邀请链接无效或已过期", comment: ""), style: .alert, buttonTitles: nil, cancelButtonTitle: "知道了", destructiveButtonTitle: nil, actionHandler: nil, cancelHandler: nil, destructiveHandler: nil).show()
                                                case 30051:
                                                    LGAlertView(title: nil, message: NSLocalizedString("根据群设置，您暂时无法加入该群聊", comment: ""), style: .alert, buttonTitles: nil, cancelButtonTitle: "好", destructiveButtonTitle: nil, actionHandler: nil, cancelHandler: nil, destructiveHandler: nil).show()
                                                default:
                                                    CODProgressHUD.showErrorWithStatus(msg)
                                                    break
                                                }
                                                break
                                                
                                            default:
                                                CODProgressHUD.showErrorWithStatus("请求失败，请重新请求")
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                    }, cancelHandler: nil, destructiveHandler: nil)
                        
                    alertView.showAnimated()
                    
                    
                }
                
                
                
            }
            
            
            
        }
        
        class func joinChannlHandle(model: CODResponseModel) {
            
            
            if let jsonModel = CODChannelHJsonModel.deserialize(from: model.dataJson?.dictionaryObject) {
                
                let channelModel = CODChannelModel.init(jsonModel: jsonModel)
                
                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: channelModel.grouppic, complete: nil)
                
                if let memberArr = model.dataJson?["channelMemberVoList"].array {
                    for member in memberArr {
                        let memberTemp = CODGroupMemberModel()
                        memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
                        memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                        channelModel.member.append(memberTemp)
                    }
                }
                
                channelModel.notice = model.dataJson?["noticecontent"]["notice"].stringValue ?? ""
                
                channelModel.customName = CODGroupChatModel.getCustomGroupName(memberList: channelModel.member)
                
                channelModel.createDate = String(format: "%.0f", Date.milliseconds)
                
                channelModel.addChannelChat()
                
                let msgCtl = MessageViewController()
                
                if let listModel = CODChatListRealmTool.getChatList(id: channelModel.roomID) {
                    msgCtl.newMessageCount = listModel.count
                    
                    if (listModel.channelChat?.descriptions) != nil {
                        let groupName = listModel.channelChat?.descriptions
                        if let groupName = groupName, groupName.count > 0 {
                            msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
                        }else{
                            msgCtl.title = NSLocalizedString("频道", comment: "")
                        }
                    }else{
                        msgCtl.title = NSLocalizedString("频道", comment: "")
                    }
                    
                    if let groupChatTemp = listModel.channelChat {
                        msgCtl.toJID = String(groupChatTemp.jid)
                    }
                    msgCtl.chatId = listModel.id
                    
                }else{
                    if channelModel.descriptions.count > 0 {
                        msgCtl.title = channelModel.descriptions.subStringToIndexAppendEllipsis(10)
                    }else{
                        msgCtl.title = NSLocalizedString("频道", comment: "")
                    }
                    
                    msgCtl.toJID =  channelModel.jid
                    msgCtl.chatId = channelModel.roomID
                }
                msgCtl.chatType = .channel
                msgCtl.channelModel = channelModel
                msgCtl.roomId = String(format: "%d", channelModel.roomID)
                msgCtl.isMute = channelModel.mute
                UIViewController.current()?.navigationController?.popToRootViewController(animated: false)
                UIViewController.current()?.navigationController?.pushViewController(msgCtl, animated: true)
            }
        }
    
    class func pushVC(roomID: Int, type: CODMessageChatType) {
        
        
        if type == .groupChat {
            
            if let group = CODGroupChatRealmTool.getGroupChat(id: roomID) {
                
                let msgCtl = MessageViewController()
                msgCtl.title = group.getGroupName()
                msgCtl.chatId = group.roomID
                msgCtl.roomId = group.roomID.string
                msgCtl.chatType = .groupChat
                msgCtl.toJID = group.jid
                
                
                if let viewControllers = UIViewController.current()?.navigationController?.viewControllers {
                    
                    
                    var vcs: [UIViewController]  = Array()
                    
                    for i in 1...viewControllers.count {
                        let vc = viewControllers[i-1]
                        if vc.isKind(of: MessageViewController.self) {
                            break
                        }else{
                            vcs.append(vc)
                        }
                    }
                    vcs.append(msgCtl)
                    UIViewController.current()?.navigationController?.setViewControllers(vcs, animated: true)
                    
                }else{
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    let tab = appdelegate.window?.rootViewController as! CODCustomTabbarViewController
                    //获取当导航控制器
                    let navCtrl = tab.selectedViewController as? UINavigationController
                    navCtrl?.pushViewController(msgCtl, animated: true)
                }
            }
            
        }
    }

    
    /// 点击URL事件
    /// - Parameter url: url
    class func openURL(url:String){
        var strUrl = url
        
        if strUrl.lowercased().hasPrefix("http://") == false && strUrl.lowercased().hasPrefix("https://") == false{
            strUrl = "http://" + strUrl
        }
        guard let url = URL.init(string: strUrl) else {
            return
        }
        
        ///判断当前连接是否已频道协议连接开头
        if strUrl.hasPrefix(CODAppInfo.channelSharePublicLink) {

            let dict:[String:Any] = ["name": COD_MemberJoin,
                                     "requester": UserManager.sharedInstance.jid,
                                     "inviter": UserManager.sharedInstance.jid,
                                     "userid": url.lastPathComponent.removeHeadAndTailSpace,
                                     "add": false]

            CODProgressHUD.showWithStatus(nil)

            XMPPManager.shareXMPPManager.getRequest(param: dict, xmlns: COD_com_xinhoo_groupchannel) { (response) in


                CODProgressHUD.dismiss()
                switch response {
                case .success(let model):

                        if model.dataJson?["type"].stringValue != CODGroupType.MPRI.rawValue {
                            CustomUtil.joinChannlHandle(model: model)
                        } else {
                            CustomUtil.joinGroupHandle(model: model, linkString: strUrl)
                        }

                    break
                default:
                    LGAlertView(title: nil, message: NSLocalizedString("此邀请链接无效或已过期", comment: ""), style: .alert, buttonTitles: nil, cancelButtonTitle: "知道了", destructiveButtonTitle: nil, actionHandler: nil, cancelHandler: nil, destructiveHandler: nil).show()


                    break
                }
            }

        }else{
            let safariVC = SFSafariViewController.init(url: URL.init(string: strUrl)!)
            UIViewController.current()!.present(safariVC, animated: true, completion: nil)
        }
        
    }
    
    /// 举报消息
    /// - Parameters:
    ///   - message: 消息模型
    ///   - reportType: 举报类型
    class func reportMessage(message: CODMessageModel?, reportType: BalloonActionViewController.ReportType, otherDesc: String = "") {
        
        guard let message = message else {
            return
        }
        
        let params = [
            "msgId": message.msgID,
            "msgOwnerId": message.fromJID.components(separatedBy: "@").first ?? "",
            "msgType": message.chatTypeEnum.rawValue,
            "othersDesc": otherDesc,
            "tipOffType": reportType.rawValue,
            "tipOffUserId": UserManager.sharedInstance.loginName ?? "",
            ] as [String : Any]
        
        HttpManager.share.post(url: HttpConfig.COD_Report, param: params, successBlock: { (dic, json) in
            
            if json["data"]["flag"].int == 1 {
                CODProgressHUD.showSuccessWithStatus(NSLocalizedString("非常感谢！\n我们会尽快核查您的举报。", comment: ""))
            }
            
        }) { (eoor) in
            
            CODProgressHUD.showSuccessWithStatus(NSLocalizedString("网络请求失败，请稍后再试", comment: ""))
        }
    }
    
}
