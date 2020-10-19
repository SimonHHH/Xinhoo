//
//  XMPPManager+IQRequest.swift
//  COD
//
//  Created by XinHoo on 2019/3/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation
import XMPPFramework
import SwiftyJSON

var nameSpace = "com:xinhoo:"



extension XMPPManager{
    
    /// 获取个人信息及设置
    func requestUserInfo(response: @escaping XMPPIQResponse) {
//        self.successBlock = success
//        self.failBlock = fail
        
        let param = [
            "name": COD_personSetting,
            "requester": self.xmppStream.myJID?.bare ?? ""
        ]
        
        self.getRequest(param: param, xmlns: COD_com_xinhoo_setting_V2, response: response)
        
    }
    
    /// 设置个人信息及设置
    func SettingUserInfo(desc : Dictionary<String, Any>,
                         success  :  @escaping (_ result : CODResponseModel,_ nameStr: String) -> (),
                         fail     :  @escaping (_ result : CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        let paramDic = ["name":"changePerson","requester":"\(UserManager.sharedInstance.jid)","setting":desc] as [String : Any]
        let jsonStr = paramDic.jsonString()
        self.setRequest(paramStr: jsonStr!,actionStr: "setting")
    }
    
    /// 请求联系人列表
    func requestContacts() {
        
        self.getRequest(paramStr: "{\"name\":\"\(COD_GetContacts)\",\"requester\":\"\(UserManager.sharedInstance.jid)\"}",actionStr: "contacts_v2")
    }
    
    /// 搜索联系人列表
    func requestSearchContact(tel: String, picCode: String?, success  :  @escaping (_ result : CODResponseModel,_ nameStr: String) -> (),
                              fail     :  @escaping (_ result : CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        let paramDic = ["name":"searchUserBTN","requester":"\(UserManager.sharedInstance.jid )","search":[["content":"\(tel)"]], "picCode":picCode ?? ""] as [String : Any]
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "contacts")
    }
    
    
    //添加好友
    func requestAddRoster(tojid : String,desc : String,success  :  @escaping (_ result : CODResponseModel,_ nameStr: String) -> (),
                              fail     :  @escaping (_ result : CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        let paramDic = ["name":"addRoster","requester":"\(UserManager.sharedInstance.jid )","receiver": tojid + XMPPSuffix,"request":["desc":desc]] as [String : Any]
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "roster")
    }
    
    //接受好友
    func requestAcceptRoster(tojid :String,status : String = "1", response: @escaping XMPPIQResponse) {
        let paramDic = [
            "name":COD_Acceptroster,
            "requester":"\(UserManager.sharedInstance.jid )",
            "receiver":tojid,
            "status":status]

        self.getRequest(param: paramDic, xmlns: COD_com_xinhoo_roster, response: response)
        
    }
    
    //根据JID查找用户信息
    func requestUserInfo(userJids : [String],success  :  @escaping (_ result : CODResponseModel) -> (),
                         fail     :  @escaping () -> ()) {
        
    }
    
    //根据JID查找用户信息
    func requestUserInfo(userJid : String,success  :  @escaping (_ result : CODResponseModel) -> (),
                             fail     :  @escaping () -> ()) {
        
        let paramDic = ["name":COD_SearchUserBID,
                        "requester":"\(UserManager.sharedInstance.jid )",
            "search":[["content":userJid]]] as [String : Any]

        self.getRequest(param: paramDic, xmlns: COD_com_xinhoo_contacts) { result in
            
            switch result {
                
            case .success(let model):
                
                let newModel = model
                var dataJson = model.dataJson
                dataJson?["users"]["name"] = JSON(model.dataJson?["users"]["name"].string?.aes128DecryptECB(key: .nickName))
//                dataJson?["users"]["name"] = JSON(AES128.aes128EncryptECB(model.dataJson?["users"]["name"].string?.aes128DecryptECB(key: .nickName) ?? ""))
                newModel.dataJson = dataJson
                success(newModel)
                break
                
            case .failure(_):
                fail()
                break
                
            }
            
            
        }
        
    }
    
    /// get方法
    func getRequest(paramStr: String, actionStr: String) {
        
        let element = DDXMLElement(name: "query")
        element.addNamespace(DDXMLNode.namespace(withName: "", stringValue: self.getAllNameSpace(actionString: actionStr)) as! DDXMLNode)
        let action = DDXMLNode.element(withName: "action", stringValue: paramStr)
        element.addChild(action as! DDXMLNode)
        let iq = XMPPIQ(type: "get", elementID: UserManager.sharedInstance.getMessageId(), child: element)
        xmppStream.send(iq)
    }
    
    func getRequest(param: Dictionary<String, Any>, xmlns: String, response: XMPPIQResponse? = nil) {
        
        let iq = CustomUtil.xmppIQ(type: .get, xmlns: xmlns, action: param)
        
        self.messageQueue.async {
            
            if let elementID = iq.elementID, let response = response {
                self.iqRequsetQ[elementID] = XMPPIQResponseBlock(time: Date().timeIntervalSince1970, response: response)
            }
            
        }
        
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        
        
        
    }
    
    func setRequest(param: Dictionary<String, Any>, xmlns: String, response: XMPPIQResponse? = nil) {
        
        let iq = CustomUtil.xmppIQ(type: .set, xmlns: xmlns, action: param)
        
        self.messageQueue.async {
            if let elementID = iq.elementID, let response = response {
                self.iqRequsetQ[elementID] = XMPPIQResponseBlock(time: Date().timeIntervalSince1970, response: response)
            }
        }
        
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    /// set方法
    func setRequest(paramStr: String, actionStr: String) {
        
        let element = DDXMLElement(name: "query")
        element.addNamespace(DDXMLNode.namespace(withName: "", stringValue: self.getAllNameSpace(actionString: actionStr)) as! DDXMLNode)
        let action = DDXMLNode.element(withName: "action", stringValue: paramStr)
        element.addChild(action as! DDXMLNode)
        let iq = XMPPIQ(type: "set", elementID: UserManager.sharedInstance.getMessageId(), child: element)
        xmppStream.send(iq)
    }
    
    func getAllNameSpace(actionString: String) -> String{
        
        return String(format: "%@%@", nameSpace,actionString)
    }
    
}

// MARK: - 单聊相关
extension XMPPManager {
    
    ///加入黑名单
    func addBlacklist(rosterId: Int, isBlacklist: Bool,
                      success  :  @escaping (_ result : CODResponseModel,_ nameStr: String) -> (),
                      fail     :  @escaping (_ result : CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        let paramDic = ["name":"changeChat",
                        "requester": "\(UserManager.sharedInstance.jid)",
                        "setting": [COD_Blacklist: isBlacklist],
                        "rosterId": rosterId] as [String : Any]
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "setting")
    }
    
}


// MARK: - 群组相关
extension XMPPManager {
    //创建群组
    func createGroupChat(members: Array<CODContactModel>,
                         searchUsers: Array<CODSearchResultContact>?,
                         picID: String?,
                         roomName: String?,
                         isInvite: Bool?,
                         success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                         fail: @escaping (_ result: CODResponseModel ) -> ()) {
        
        self.successBlock = success
        self.failBlock = fail
        
        var membersTemp = Array<String>()
        for member in members {
            membersTemp.append(member.jid)
        }
        if let arr = searchUsers {
            for model in arr {
                membersTemp.append("\(model.username)\(XMPPSuffix)")
            }
        }
        var paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name":"createRoom",
            "isInvite":true,
            "notinvite":isInvite ?? true,
            "members":membersTemp] as [String : Any]
        if let picId = picID {
            paramDic["attID"] = picId
        }
        if let roomName = roomName {
            paramDic["roomName"] = roomName
        }
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "groupChat")
    }
    
    //创建频道
    func createChannel(members: Array<CODContactModel>,
                         searchUsers: Array<CODSearchResultContact>?,
                         picID: String?,
                         channelType: CODChannelType = .CPUB,
                         channelPubLink: String?,
                         roomName: String?,
                         destription: String?,
                         success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                         fail: @escaping (_ result: CODResponseModel ) -> ()) {
        
        self.successBlock = success
        self.failBlock = fail
        
        var membersTemp = Array<String>()
        for member in members {
            membersTemp.append(member.jid)
        }
        if let arr = searchUsers {
            for model in arr {
                membersTemp.append("\(model.username)\(XMPPSuffix)")
            }
        }
        
        var paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name":COD_createchannel,
            "type":channelType.rawValue,
            "isInvite":true,
            "members":membersTemp] as [String : Any]
        if let picId = picID {
            paramDic["attID"] = picId
        }
        if let roomName = roomName {
            paramDic["roomName"] = roomName
        }
        if let destription = destription {
            paramDic["notice"] = destription
        }
        if let channelPubLink = channelPubLink {
            paramDic["userid"] = channelPubLink
        }
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "channel")
    }
    
    func channelSetting(roomID: Int,
                        type: CODChannelType? = nil,
                        linkUrl: String? = nil,
                        savecontacts: Bool? = nil,
                        stickytop: Bool? = nil,
                        mute: Bool? = nil,
                        userpic: String? = nil,
                        topmsg: String? = nil,
                        signmsg: Bool? = nil,
                        response: XMPPIQResponse? = nil) {
        

        var paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
        "name":COD_Setchannelsetting,
        "itemID":roomID] as [String : Any]
        
        var setting: [String: Any] = [:]
        
        if let type = type {
            setting["type"] = type.rawValue
        }
        
        if let linkUrl = linkUrl {
            setting["userid"] = linkUrl
        }
        
        if let savecontacts = savecontacts {
            setting["savecontacts"] = savecontacts
        }
        
        if let stickytop = stickytop {
            setting["stickytop"] = stickytop
        }
        
        if let mute = mute {
            setting["mute"] = mute
        }
        
        if let userpic = userpic {
            setting["userpic"] = userpic
        }
        
        if let topmsg = topmsg {
            setting["topmsg"] = topmsg
        }
        
        if let signmsg = signmsg {
            setting["signmsg"] = signmsg
        }
        
        paramDic["setting"] = setting

        let jsonStr = paramDic.jsonString()
        
        self.setRequest(param: paramDic, xmlns: COD_com_xinhoo_channelsetting, response: response)

    }
    
    func getChannelSetting(roomID: Int,
                           success:  ((_ result: CODResponseModel,_ nameStr: String) -> ())?,
                           fail: ((_ result: CODResponseModel ) -> ())?) {
        
        if let success = success {
            self.successBlock = success
        }
        
        if let fail = fail {
            self.failBlock = fail
        }
        
        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name":COD_Getchannelsetting,
            "itemID":roomID] as [String : Any]
        
        
        let jsonStr = paramDic.jsonString()
        self.setRequest(paramStr: jsonStr!, actionStr: "channelsetting")
        
    }
    
    //增加群成员
    func addGroupMember(members: Array<CODContactModel>, searchUsers: Array<CODSearchResultContact>?, roomId: Int, chatType: CODMessageChatType = .groupChat,
                        success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                        fail: @escaping (_ result: CODResponseModel ) -> ()) {
        
        self.successBlock = success
        self.failBlock = fail
        
        var membersTemp = Array<String>()
        for member in members {
            membersTemp.append(member.jid)
        }
        if let arr = searchUsers {
            for model in arr {
                membersTemp.append("\(model.username)\(XMPPSuffix)")
            }
        }
        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": "inviteMember",
            "roomID": roomId,
            "memberList": membersTemp] as [String: Any]
        
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: chatType.stringValue)
        
    }
    
    func destroyChannel(roomId: Int,
                        success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                        fail: @escaping (_ result: CODResponseModel ) -> ()) {
        
        self.successBlock = success
        self.failBlock = fail

        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": COD_destroyRoom,
            "roomID": roomId] as [String: Any]
        
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: CODMessageChatType.channel.stringValue)
        
    }
    
    func quitChannel(roomId: Int,
                        success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                        fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": COD_quitGroupChat,
            "roomID": roomId] as [String: Any]
        
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: CODMessageChatType.channel.stringValue)
    }
    
    func joinGroupAndChannel(linkString: String, inviter: String, add: Bool,isNeedPub: Bool = false,isPub: Bool = false, response: XMPPIQResponse? = nil) {
        var linkStr = linkString
        
        if linkString.hasPrefix("http") {
            let stringArray = linkString.components(separatedBy: "/")
            if stringArray.count > 0 {
                linkStr = stringArray.last ?? linkString
            }
        }
        if isNeedPub {
            
            let dict:[String:Any] = ["name": COD_MemberJoin,
                                       "requester": UserManager.sharedInstance.jid,
                                       "inviter": inviter,
                                       "userid": linkStr,
                                       "typeUserID": isPub,
                                       "add": add]
            XMPPManager.shareXMPPManager.getRequest(param: dict, xmlns: COD_com_xinhoo_groupchannel, response: response)
        }else{
            
            let dict: Dictionary<String, Any> = ["name": COD_MemberJoin,
                                                 "requester": UserManager.sharedInstance.jid,
                                                 "inviter": inviter,
                                                 "userid": linkStr,
                                                 "add": add]
            
            XMPPManager.shareXMPPManager.getRequest(param: dict, xmlns: COD_com_xinhoo_groupchannel, response: response)
            
        }
        
    }
    
    func searchChannel(search: String,
                        success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                        fail: @escaping (_ result: CODResponseModel ) -> ()) {
        
        self.successBlock = success
        self.failBlock = fail

        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": COD_searchChannel,
            "search": search] as [String: Any]
        
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: CODMessageChatType.channel.stringValue)
        
    }
    
    func getSearchResultInfo(userid: String,
                             type: String,
                        success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                        fail: @escaping (_ result: CODResponseModel ) -> ()) {
        
        self.successBlock = success
        self.failBlock = fail

        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": COD_viewsearchdata,
            "type": type,
            "search": userid] as [String: Any]
        
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: CODMessageChatType.channel.stringValue)
        
    }
    
    func globalSearch(search: String,
                      picCode: String? = nil,
                        success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                        fail: @escaping (_ result: CODResponseModel ) -> ()) {
        
        self.successBlock = success
        self.failBlock = fail

        var paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": COD_globalSearch,
            "search": search] as [String: Any]
        if let picCode = picCode {
            paramDic["picCode"] = picCode
        }
        
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: CODMessageChatType.channel.stringValue)
        
    }
    
    func setAdmins(roomId: Int, jid: String, isOn: Bool,
                   success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                   fail: @escaping (_ result: CODResponseModel ) -> ()) {
        
        self.successBlock = success
        self.failBlock = fail
        
        let paramDic = ["name": COD_SetAdmins,
                        "requester": UserManager.sharedInstance.jid,
                        "roomID": roomId,
                        "adminTarget": jid,
                        "isAdd": isOn] as [String: Any]
        
        
        let jsonStr = paramDic.jsonString()
        self.setRequest(paramStr: jsonStr!,actionStr: CODMessageChatType.channel.stringValue)

        
    }
    
    //删除群成员
    func subtractGroupMember(members: Array<CODGroupMemberModel>, roomId: Int,
                             chatType: CODMessageChatType = .groupChat,
                           success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                           fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        var membersTemp = Array<String>()
        for member in members {
            membersTemp.append(member.jid)
        }
        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": "kickOutMember",
            "roomID": roomId,
            "memberList": membersTemp] as [String: Any]
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: chatType.stringValue)
    }
    
    
    //群成员自主退群
//    func leaveGroupChat(roomId: Int,
//                        success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
//                        fail: @escaping (_ result: CODResponseModel ) -> ()) {
//        self.successBlock = success
//        self.failBlock = fail
//        
//        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
//            "name": "quitGroupChat",
//            "roomID": roomId] as [String: Any]
//        let jsonStr = paramDic.jsonString()
//        self.getRequest(paramStr: jsonStr!,actionStr: "groupChat")
//    }
    
    //修改群名称
    func changeGroupChatName(roomId: Int, roomName: String,
                             chatType: CODMessageChatType = .groupChat,
                             success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                             fail: @escaping (_ result: CODResponseModel ) -> ()) {
        
        self.successBlock = success
        self.failBlock = fail
        
        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": "editRoomName",
            "newRoomName": roomName,
            "roomID": roomId] as [String: Any]
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: chatType.stringValue)
    }
    
    //修改群里我的昵称    ***** 没找到接口
    func changeGroupMyNickName(roomId: Int, nickName: String,
                             success:  @escaping (_ result: CODResponseModel) -> (),
                             fail: @escaping (_ result: String ) -> ()) {

        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": "changeGroupNickName",
            "newNickName": nickName,
            "roomID": roomId] as [String: Any]
        
        self.getRequest(param: paramDic, xmlns: COD_com_xinhoo_groupChat) { (result) in
            
            switch result {
                
            case .success(let model):
                success(model)
                
            case .failure(.iqReturnError(_, let errorString)):
                fail(NSLocalizedString(errorString, comment: ""))
                
            default:
                fail(NSLocalizedString("网络异常", comment: ""))
                
            }
            
        }
        
    }

    //读取群组设定
    func getGroupInfo(roomId: Int,
                      success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                      fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": COD_groupSetting,
            "itemID": roomId] as [String: Any]
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "setting")
    }
    
    //修改阅后即焚设定
    func getGroupBurn(roomJid: String,
                      success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                      fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": COD_groupSetting,
            "tojid": roomJid] as [String: Any]
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "setting")
    }
    
    //转让群主操作
    func transferGroupAdmin(roomId: Int, newAdminName: String,
                      success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                      fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        let paramDic = ["requester": "\(UserManager.sharedInstance.jid)",
            "ownerTarget": newAdminName,
            "name": "transferOwner",
            "roomId": roomId] as [String: Any]
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "groupChat")
    }
    
    
    //设置群公告
    func settingGroupAnnounce(roomId: Int, notice: String,
                              chatType: CODMessageChatType = .groupChat,
                              success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                              fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        let paramDic = ["requester": "\(UserManager.sharedInstance.jid)",
            "notice": notice,
            "name": "setNotice",
            "roomID": roomId] as [String: Any]
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: chatType.stringValue)
    }
    
    ///群组保存到通讯录
    func settingGroupSavecontacts(roomId: Int, isSaveContacts: Bool,
                                  success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                                  fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        let paramDic = ["requester": "\(UserManager.sharedInstance.jid)",
            "name" : "changeGroup",
            "roomID" : roomId,
            "setting": ["savecontacts": isSaveContacts]] as [String: Any]
        
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "groupChat")
    }
    
    func getRoomUnReadList(roomID: Int, sendTime: String,
                           success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                           fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        let paramDic = ["requester": "\(UserManager.sharedInstance.jid)",
            "name" : "getRoomUnReadList",
            "roomID" : roomID,
            "sendTime" : sendTime] as [String: Any]
        
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "groupChat")
    }
    
}



// MARK: - 单聊及群组通用相关
extension XMPPManager {
    //修改截屏通知设定
    func settingScreenShotNotification(isGroupChat: Bool, rosterOrRoomId: Int, isScreenShot: Bool,
                              success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                              fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        var paramDic = ["requester": "\(UserManager.sharedInstance.jid)",
            "setting": ["screenshot": isScreenShot]] as [String: Any]
        if isGroupChat {
            paramDic["roomID"] = rosterOrRoomId
            paramDic["name"] = "changeGroup"
        }else{
            paramDic["rosterID"] = rosterOrRoomId
            paramDic["name"] = "changeChat"
        }
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "setting")
    }
    
    func topranking(_ chatListModel: CODChatListModel, _ destinationJID: String) {
        
        let sourceJID = chatListModel.jid
        
        
        
        XMPPManager.shareXMPPManager.getRequest(param: [
            "requester": UserManager.sharedInstance.jid,
            "name": COD_Topranking,
            "footTarget": destinationJID,
            "target": sourceJID
        ], xmlns: COD_com_xinhoo_groupChat)
    }

    //修改聊天置顶
    func settingStickyTop(isGroupChat: Bool, rosterOrRoomId: Int, isStickyTop: Bool,
                                       success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                                       fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        var paramDic = ["requester": "\(UserManager.sharedInstance.jid)",
            "setting": [COD_Stickytop: isStickyTop]] as [String: Any]
        if isGroupChat {
            paramDic["roomID"] = rosterOrRoomId
            paramDic["name"] = "changeGroup"
        }else{
            paramDic["rosterID"] = rosterOrRoomId
            paramDic["name"] = "changeChat"
        }
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "setting")
    }
    
    ///修改消息免打扰设定
    func settingMute(isGroupChat: Bool, rosterOrRoomId: Int, isMute: Bool,
                     success:  @escaping (_ result: CODResponseModel,_ nameStr: String) -> (),
                     fail: @escaping (_ result: CODResponseModel ) -> ()) {
        self.successBlock = success
        self.failBlock = fail
        
        var paramDic = ["requester": "\(UserManager.sharedInstance.jid)",
            "setting": [COD_Mute: isMute]] as [String: Any]
        if isGroupChat {
            paramDic["roomID"] = rosterOrRoomId
            paramDic["name"] = "changeGroup"
        }else{
            paramDic["rosterID"] = rosterOrRoomId
            paramDic["name"] = "changeChat"
        }
        let jsonStr = paramDic.jsonString()
        self.getRequest(paramStr: jsonStr!,actionStr: "setting")
    }
    


}
