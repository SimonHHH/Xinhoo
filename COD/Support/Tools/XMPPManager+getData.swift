//
//  XMPPManager+getData.swift
//  COD
//
//  Created by XinHoo on 2019/3/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation
import XMPPFramework
import SwiftyJSON

extension XMPPManager{
    // 获取用户设置及详细
    func getUserInfo(node : DDXMLNode?, nameStr: String){
        if (node != nil) {
            let json = JSON(parseJSON: node!.stringValue!)
            let result = json.dictionaryObject
            if let model = CODResponseModel.deserialize(from: result) {
                model.data = result
                if model.success {
                    if let userinfo = result!["setting"] as! Dictionary<String,Any>? {
                        if let userInfo = CODUserInfoAndSetting.deserialize(from: userinfo) {
                            UserManager.sharedInstance.userInfoSetting = userInfo
                        }
                    }
                    
                }else{
                    
                }
            }else{
                let model = CODResponseModel()
                print("getUserInfo error \(model)")
            }
        }
    }
    
    //更新用户设置及详细
    func updateUserInfo(node : DDXMLNode?, nameStr: String){
        let model = CODResponseModel()
        if (node != nil) {
            
            let json = JSON(parseJSON: node!.stringValue!)
            if let result = json.dictionaryObject {
                
                model.success = true
                model.data = result
                if let userinfo = result["setting"] as! Dictionary<String,Any>? {
                    UserManager.sharedInstance.userInfoSetting = CODUserInfoAndSetting.deserialize(from: userinfo)!
                }
                print("updateUserInfo success")
                if self.successBlock != nil {
                    
                    self.successBlock(model, nameStr)
                    self.failBlock = nil
                    self.successBlock = nil
                }
            }else{
                model.success = false
                model.msg = "JSON转换失败"
                if self.failBlock != nil {
                    self.failBlock(model)
                    self.failBlock = nil
                    self.successBlock = nil
                }
            }
        }else{
            model.success = false
            model.msg = "获取信息失败"
            if self.failBlock != nil {
                self.failBlock(model)
                self.failBlock = nil
                self.successBlock = nil
            }
        }
    }
    
    
    //获取联系人列表
    func getContactList(node : DDXMLNode?, nameStr: String){
        NSLog("开始写入好友信息++++++++++++++")
        if (node != nil) {
            
            var contactDic: Dictionary<String, CODContactModel> = Dictionary()
            
            //插入\(kApp_Name)小助手
            let contactModel = CODContactModel()
            contactModel.rosterID = 0
            contactModel.jid = "cod_60000000\(XMPPSuffix)"
            contactModel.username = "cod_60000000"
            contactModel.userpic = UIImage.getHelpIconName()
            contactModel.pinYin = ChineseString.getPinyinBy(CustomUtil.formatterStringWithAppName(str: "%@小助手"))
            contactModel.name = "\(kApp_Name)小助手"
            contactModel.isValid = true
            
            CODContactRealmTool.insertContact(by: contactModel)
            
            //插入我的云盘
            let cloudModel = CODContactModel()
            cloudModel.rosterID = CloudDiskRosterID
            cloudModel.jid = kCloudJid + XMPPSuffix
            cloudModel.username = "cod_60000000"
            cloudModel.userpic = "cloud_disk_icon"
            cloudModel.pinYin = ChineseString.getPinyinBy("我的云盘")
            cloudModel.name = "我的云盘"
            cloudModel.stickytop = UserManager.sharedInstance.xhassstickytop
            cloudModel.isValid = true
            
            CODContactRealmTool.insertContact(by: cloudModel)
            
            
            //插入网络数据
            let json = JSON(parseJSON: node!.stringValue!)
            guard let result = json.dictionaryObject else{
                return
            }
            
            let ver = (NSString.init(format: "%@", result["ver"] as? NSNumber ?? NSNumber.init(value: 0))) as String
            if let lastUpdateTime = CODUserDefaults.object(forKey: kLastUpdateContactTime + UserManager.sharedInstance.loginName!) {
                
                if ((lastUpdateTime as! String) < ver) {
                    CODUserDefaults.set(ver, forKey: kLastUpdateContactTime + UserManager.sharedInstance.loginName!)
                    CODUserDefaults.synchronize()
                }
                
            } else {
                
                CODUserDefaults.set(ver, forKey: kLastUpdateContactTime + UserManager.sharedInstance.loginName!)
                CODUserDefaults.synchronize()
            }
            
            if let topRankList = result["topRankList"] as? [String] {
                self.topRankList = topRankList
            }
            
            
            if let list :Array = result["roster"] as? [Dictionary<String,Any>] {
                print("%%%%%%%%%%%%% 联系人数量：\(list.count)")
                
                let localContacts = try! Realm.init().objects(CODContactModel.self)
                for contactModel in localContacts{
                    if contactModel.rosterID == RobotRosterID || contactModel.rosterID == CloudDiskRosterID {
                        continue
                    }
                    let model = CODContactModel()
                    model.setInvalidContactModel(contactModel)
                    contactDic["\(model.jid)"] = model
                }
                
                for item in list {
                    let contactModel = CODContactModel()
                    contactModel.jsonModel = CODContactHJsonModel.deserialize(from: item)
                    //判断是否是临时好友，（临时好友属于，被删除的好友，或者以前聊过天的陌生人）
                    contactModel.isValid = (item["status"] as? String ?? "REMOVE") != "REMOVE"
                    if let model = CODContactRealmTool.getContactById(by: contactModel.rosterID) {
                        if model.timestamp > 0 {
                            contactModel.timestamp = model.timestamp
                        }
                    }
                    
                    if let tels:Array = item["tels"] as? Array<String> {
                        for tel in tels{
                            if contactModel.tels.first == tel {
                                continue
                            }
                            contactModel.tels.append(tel)
                        }
                    }
                    
                    contactDic["\(contactModel.jid)"] = contactModel
                    
                    
                }
                
                let contactArr = contactDic.values
                for model in contactArr {
                    CODContactRealmTool.insertContact(by: model)
                    
                    if let listModel = CODChatListRealmTool.getChatList(id: model.rosterID) {
                        try! Realm.init().write {
                            listModel.title = model.getContactNick()
                            listModel.stickyTop = model.stickytop
                            listModel.jid = model.jid
                        }
                    }
                }
            }
            
            
            var groupDic: Dictionary<String, CODGroupChatModel> = Dictionary()
            if let grouplist :Array = result["group"] as? [Dictionary<String,Any>] {
                
                let localGroups = try! Realm.init().objects(CODGroupChatModel.self).filter("isDelete != \(true)")
                for localGroupModel in localGroups{
                    let groupModel = CODGroupChatModel()
                    groupModel.setInvalidGroupModel(localGroupModel)
                    groupDic["\(groupModel.jid)"] = groupModel
                }
                
                for group in grouplist{
                    
                    let groupChatModel = CODGroupChatModel()
                    groupChatModel.jsonModel = CODGroupChatHJsonModel.deserialize(from: group)
                    groupChatModel.isValid = true
                    CODDownLoadManager.sharedInstance.updateAvatar(userPicID: groupChatModel.grouppic, complete: nil)
                    if let memberArr = group["member"] as! [Dictionary<String,Any>]? {
                        for member in memberArr {
                            let memberTemp = CODGroupMemberModel()
                            memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                            memberTemp.memberId = String(format: "%d%@", groupChatModel.roomID, memberTemp.username)
                            groupChatModel.member.append(memberTemp)
                        }
                    }
                    if let noticeContent = group["noticecontent"] as? Dictionary<String, Any> {
                        if let notice = noticeContent["notice"] as? String {
                            groupChatModel.notice = notice
                        }
                    }
                    
                    groupChatModel.customName = CODGroupChatModel.getCustomGroupName(memberList: groupChatModel.member)
                    
                    groupDic["\(groupChatModel.jid)"] = groupChatModel
                    
                    
                }
                
                let groupArr = groupDic.values
                for model in groupArr {
                    
                    CODGroupChatRealmTool.insertGroupChat(by: model)
                    if let listModel = CODChatListRealmTool.getChatList(id: model.roomID) {
                        try! Realm.init().write {
                            listModel.stickyTop = model.stickytop
                            listModel.jid = model.jid
                        }
                    }
                }
                
            }
            
            
            //================
            
            
            var channelDic: Dictionary<String, CODChannelModel> = Dictionary()
            if let channellist :Array = result["channel"] as? [Dictionary<String,Any>] {
                
                let localGroups = try! Realm().objects(CODChannelModel.self)
                for localGroupModel in localGroups {
                    channelDic["\(localGroupModel.jid)"] = localGroupModel
                }
                
                for channel in channellist{
                    
                    guard let jsonModle = CODChannelHJsonModel.deserialize(from: channel) else {
                        continue
                    }
                    
                    
                    let channelModel = CODChannelModel(jsonModel: jsonModle)
                    channelModel.isValid = true
                    CODDownLoadManager.sharedInstance.updateAvatar(userPicID: channelModel.grouppic, complete: nil)
                    if let memberArr = channel["channelMemberVoList"] as! [Dictionary<String,Any>]? {
                        
                        var members: [CODGroupMemberModel] = []
                        for member in memberArr {
                            let memberTemp = CODGroupMemberModel()
                            memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                            memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                            members.append(memberTemp)
                        }
                        
                        channelModel.updateMembersWithContactsList(members, roomId: channelModel.roomID)
//                        channelModel.updateMembers(members)
                    }
                    if let noticeContent = channel["noticecontent"] as? Dictionary<String, Any> {
                        if let notice = noticeContent["notice"] as? String {
                            channelModel.notice = notice
                        }
                    }
                    
                    channelModel.customName = CODGroupChatModel.getCustomGroupName(memberList: channelModel.member)
                    
                    channelDic["\(channelModel.jid)"] = channelModel
                    
                }
                
                for (_, value) in channelDic {
                    
                    value.addChannelChat()
                    if let listModel = CODChatListRealmTool.getChatList(id: value.roomID) {
                        try! Realm.init().write {
                            listModel.stickyTop = value.stickytop
                            listModel.jid = value.jid
                        }
                    }
                    
                }
            }
            
            
        }
        
    }
    
    func getTopMsg(roomId: Int, response: ((CODMessageModel?) -> Void)? = nil) {
        
        guard let chatList = CODChatListRealmTool.getChatList(id: roomId) else {
            return
        }
        
        var params: [String: Any] = [
            "roomID": roomId,
            "name": "getmucmsghistorybytopmsg",
            "requester": UserManager.sharedInstance.jid
        ]
        
        switch chatList.chatTypeEnum {
        case .groupChat:
            params["type"] = "G"
        case .channel:
            params["type"] = "C"
        default:
            return
        }
        
        self.getRequest(param: params, xmlns: COD_com_xinhoo_groupChat) { (result) in
            
            switch result {
                
            case .success(let model):
                
                guard let chatList = CODChatListRealmTool.getChatList(id: roomId) else {
                    return
                }
                
                let message = try! XMPPMessage(xmlString: model.dataJson?.stringValue ?? "")
                guard let messageModel = XMPPManager.shareXMPPManager.xmppMessageToRealmMessage(message: message) else {
                    chatList.groupChat?.updateModel(topmsg: "")
                    chatList.channelChat?.updateChannel(topmsg: "")
                    response?(nil)
                    return
                }
                CODChatListRealmTool.addChatListMessage(id: roomId, message: messageModel)
                
                let _ = try! Realm().refresh()
                
                CODMessageRealmTool.setReadedDestroy(by: [messageModel])
                response?(messageModel)
                
                switch chatList.chatTypeEnum {
                case .groupChat:
                    chatList.groupChat?.updateModel(topmsg: messageModel.msgID)
                    
                case .channel:
                    chatList.channelChat?.updateChannel(topmsg: messageModel.msgID)
                    
                case .privateChat:
                    break
                }
                
            case .failure(_):
                response?(nil)
                break
                
            }
            
        }
        
    }
    
    func joinLocationGroup() {
        let groups = CODGroupChatRealmTool.getAllValidGroupChatList()
        guard groups.count > 0 else {
            return
        }
        //        for group in groups {
        //            XMPPManager.shareXMPPManager.joinGroupChatWith(groupJid: group.jid)
        //        }
    }
    
    //搜索好友
    func getSearchData(node : DDXMLNode?, nameStr: String) {
        
        if (node != nil) {
            if self.successBlock != nil && self.failBlock != nil {
                let json = JSON(parseJSON: node!.stringValue!)
                let result = json.dictionaryObject
                if let model = CODResponseModel.deserialize(from: result) {
                    model.data = result
                    if model.success {
                        self.successBlock(model, nameStr)
                        self.failBlock = nil
                        self.successBlock = nil
                    }else{
                        self.failBlock(model)
                        self.failBlock = nil
                        self.successBlock = nil
                    }
                }
            }else{
                let model = CODResponseModel()
                
                if self.failBlock != nil {
                    self.failBlock(model)
                }
                
                
                self.failBlock = nil
                self.successBlock = nil
            }
        }
    }
    
    //添加好友
    func getAddRoster(node : DDXMLNode?, nameStr: String) {
        
        if (node != nil) {
            if self.successBlock != nil && self.failBlock != nil {
                let json = JSON(parseJSON: node!.stringValue!)
                let result = json.dictionaryObject
                if let model = CODResponseModel.deserialize(from: result) {
                    model.data = result
                    if model.success {
                        self.successBlock(model, nameStr)
                        self.failBlock = nil
                        self.successBlock = nil
                    }else{
                        self.failBlock(model)
                        self.failBlock = nil
                        self.successBlock = nil
                    }
                }
            }else{
                let model = CODResponseModel()
                self.failBlock(model)
                self.failBlock = nil
                self.successBlock = nil
            }
        }
    }
    
    //监听是不是有新的好友添加你
    func getIsNewFriend(node : DDXMLNode?, nameStr: String) -> Bool {
        
        let json = JSON(parseJSON: node!.stringValue!)
        let result = json.dictionaryObject
        
        if let tojid = result?["tojid"] as? String {
            if tojid == _username {
                //监听新的好友添加的消息如果要是有的话，发送通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: HAVE_NEWFRIEND_NOTICATION), object: nil, userInfo: result)
                UserManager.sharedInstance.haveNewFriend = UserManager.sharedInstance.haveNewFriend + 1
                
                if let rootVC = UIApplication.shared.keyWindow?.rootViewController as? CODCustomTabbarViewController {
                    rootVC.tabBar.items?[1].badgeValue = ""
                }
                return true
            }else{
                return false
            }
        }
        return false
    }
    
    // MARK: ---------------- 群组相关 --------------------
    
    func resultModelWithMessageNode(node: DDXMLNode?, nameStr: String) {
        if (node != nil) {
            if self.successBlock != nil && self.failBlock != nil {
                let json = JSON(parseJSON: node!.stringValue!)
                let result = json.dictionaryObject
                if let model = CODResponseModel.deserialize(from: result) {
                    model.data = result
                    if model.success {
                        self.successBlock(model, nameStr)
                        self.failBlock = nil
                        self.successBlock = nil
                    }else{
                        self.failBlock(model)
                        self.failBlock = nil
                        self.successBlock = nil
                    }
                }else{
                    let model = CODResponseModel()
                    self.failBlock(model)
                    self.failBlock = nil
                    self.successBlock = nil
                }
            }else{
                
                if (self.failBlock != nil) {
                    let model = CODResponseModel()
                    self.failBlock(model)
                    self.failBlock = nil
                    self.successBlock = nil
                }
                
            }
        }
    }
    
    func getBurnString(who: String, burn: Int, discription: String) -> String {
        if burn > 0 {
            if burn == 1 {
                
                return String.init(format: NSLocalizedString("%@开启了“阅后即焚”", comment: ""), "\(who)")
            }else{
                return String.init(format: NSLocalizedString("%@开启了%@“阅后即焚”", comment: ""), "\(who)","\(discription)")
            }
        }else{
            return String.init(format: NSLocalizedString("%@关闭了“阅后即焚”", comment: ""), "\(who)")
        }
    }
    
    func updateMessageSendStatus(message: XMPPMessage) {
        if let messageModel = XMPPManager.shareXMPPManager.getMessageWithXMPPMsg(message: message) {
            guard CODMessageRealmTool.getMessageByMsgId(messageModel.msgID) != nil else {
                return
            }
            dispatch_async_safely_to_main_queue({
//                messageModel.status = CODMessageStatus.Succeed.rawValue
                CODMessageRealmTool.updateMessageStyleByMsgId(messageModel.msgID, status: CODMessageStatus.Succeed.rawValue, sendTime: messageModel.datetimeInt)
                
                CODChatListRealmTool.updateLastDatetimeWithMessageModel(messageModel: messageModel)

                
            })
            
            
        }
    }
    
}
