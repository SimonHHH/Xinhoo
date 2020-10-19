//
//  NotifcationDeserialize.swift
//  COD
//
//  Created by Sim Tsai on 2020/3/2.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


class NotificationDeserialize {
    
    typealias NotiToString = ((CODMessageHJsonModel) -> String?)
    typealias ConfigMessageModel = ((CODMessageHJsonModel, CODMessageModel) -> Void)
    
    var deserializeSels: [String: NotiToString] = [:]
    var configMessageModelSels: [String: ConfigMessageModel] = [:]
    
    static var `default` = NotificationDeserialize()
    
    init() {
        self.addDeserialize(body: COD_SetCreateJoin, handle: SetCreateJoin)
        self.addConfigMessageModel(body: COD_SetCreateJoin, handle: SetCreateJoinConfigModel)
        self.addDeserialize(body: COD_QrInvitJoin, handle: QrInvitJoin)
        self.addConfigMessageModel(body: COD_QrInvitJoin, handle: QrInvitJoinConfigModel)
        self.addDeserialize(body: COD_urlinvitjoin, handle: setUrlInvitJoin)
        self.addConfigMessageModel(body: COD_urlinvitjoin, handle: setUrlInvitJoinConfigModel)
        self.addDeserialize(body: COD_InvitJoin, handle: InvitJoin)
        self.addConfigMessageModel(body: COD_InvitJoin, handle: InvitJoinConfigModel)
        self.addDeserialize(body: COD_refusejoin, handle: refuseJoin)
        self.addConfigMessageModel(body: COD_refusejoin, handle: refuseJoinConfigModel)
        self.addDeserialize(body: COD_CanSpeak, handle: canSpeak)
        self.addDeserialize(body: COD_KickOut, handle: kickOut)
        self.addDeserialize(body: COD_SetMucname, handle: setMucname)
        self.addDeserialize(body: COD_SetKickOut, handle: setKickOut)
        self.addDeserialize(body: COD_TransferOwner, handle: transferOwner)
        self.addConfigMessageModel(body: COD_TransferOwner, handle: transferOwnerConfigModel)
        self.addDeserialize(body: COD_SetNotice, handle: setNotice)
        self.addConfigMessageModel(body: COD_SetNotice, handle: setNoticeConfigModel)
        self.addDeserialize(body: COD_Notinvite, handle: notinvite)
        self.addDeserialize(body: COD_ChangeGroupAvatar, handle: changeGroupAvatar)
        self.addConfigMessageModel(body: COD_ChangeGroupAvatar, handle: changeGroupAvatarConfigModel)
        self.addDeserialize(body: COD_setBurn, handle: setBurn)
        self.addConfigMessageModel(body: COD_setBurn, handle: setBurnConfigModel)
        self.addDeserialize(body: COD_screenShot, handle: screenShot)
        self.addDeserialize(body: COD_userdetail, handle: Userdetail)
        self.addDeserialize(body: COD_createchannel, handle: CreateChannel)
        self.addDeserialize(body: COD_Addinvitjoinchannel, handle: Addinvitjoinchannel)
        self.addDeserialize(body: COD_Topmsg, handle: Topmsg)
        self.addConfigMessageModel(body: COD_Topmsg, handle: topMsgConfigModel)
        self.addDeserialize(body: COD_Bothroster, handle: Bothroster)
        self.addDeserialize(body: COD_XHReferall, handle: XHReferall)
        self.addDeserialize(body: COD_SignOut, handle: SignOut)
        self.addDeserialize(body: COD_xhshowallhistory, handle: xhshowallhistory)
        self.addDeserialize(body: COD_Invitjoinchannel, handle: invitjoinchannel)
        self.addConfigMessageModel(body: COD_Invitjoinchannel, handle: invitjoinchannelConfigModel)
        
        self.addDeserialize(body: COD_creatertcroom, handle: creatertcroom)
        self.addConfigMessageModel(body: COD_creatertcroom, handle: invitjoinCreatertcroom)
        self.addDeserialize(body: COD_endroom, handle: endRoom)
    }
    
    
    func notifcationToPrompt(message: XMPPMessage) -> String? {
        
        guard let jsonModel = XMPPManager.shareXMPPManager.xmppMessageToJsonMessageModel(message: message) else {
            return nil
        }
        
        if let sel = deserializeSels[jsonModel.body] {
            return sel(jsonModel)
        }
        
        return nil
        
    }
    
    func configNotifcationModel(message: XMPPMessage, model: CODMessageModel) {
        
        guard let jsonModel = XMPPManager.shareXMPPManager.xmppMessageToJsonMessageModel(message: message) else {
            return
        }
        
        if let sel = configMessageModelSels[jsonModel.body] {
            sel(jsonModel, model)
        }
        
    }
    
    func addDeserialize(body: String, handle: @escaping NotiToString) {
        deserializeSels[body] = handle
    }
    
    func addConfigMessageModel(body: String, handle: @escaping ConfigMessageModel) {
        configMessageModelSels[body] = handle
    }
    
}

extension NotificationDeserialize {
    
    func SignOut(message: CODMessageHJsonModel) -> String? {
        var messageText = ""
        if message.sender != UserManager.sharedInstance.jid {
            if let members = message.settingJson["member"].arrayObject as? Array<Dictionary<String, Any>> {
                
                if let member = members.first {
                    let memberTemp = CODGroupMemberModel()
                    memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                    if message.chatType == .channel {
                        return nil
                    }else{
                        messageText = "“\(memberTemp.getMemberNickName())”\(NSLocalizedString("已退出群聊", comment: ""))"
                    }
                    return messageText
                }
            }
        }
        return nil
    }
    
    func xhshowallhistory(message: CODMessageHJsonModel) -> String? {
        var messageText = ""
        let json = message.settingJson
        if let xhreferall =  json["xhshowallhistory"].bool {
            if xhreferall {
                messageText = NSLocalizedString("管理员已开启群成员可查看入群前消息", comment: "")
            } else {
                messageText = NSLocalizedString("管理员已关闭群成员查看入群前消息", comment: "")
            }
        }
        return messageText
    }
    
    
    
    func Userdetail(message: CODMessageHJsonModel) -> String? {
        
        var messageText = ""
        
        let json = message.settingJson
        
        let userdetail = json["userdetail"].boolValue
        
        if userdetail == true {
            messageText = NSLocalizedString("管理员已允许群成员查看非好友个人信息", comment: "")
        } else {
            messageText = NSLocalizedString("管理员已禁止群成员查看非好友信息，同时转发、收藏、成员列表、@群成员功能将被关闭", comment: "")
        }
        
        return messageText
    }
    
    func CreateChannel(message: CODMessageHJsonModel) -> String? {
        
        return NSLocalizedString("频道已创建", comment: "")
    }
    
    func Addinvitjoinchannel(message: CODMessageHJsonModel) -> String? {
        
        return NSLocalizedString("您加入了此频道", comment: "")
    }
    
    func Topmsg(messageBodyModel: CODMessageHJsonModel) -> String? {
        
        var startStr = ""
        if let _ = CODGroupChatRealmTool.getGroupChat(id: messageBodyModel.roomID){
            let senderJid = messageBodyModel.sender
            let memberId = CODGroupMemberModel.getMemberId(roomId: messageBodyModel.roomID, userName: senderJid)
            if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                var preString = "\(memberModel.getMemberNickName())"
                if senderJid.compareNoCaseForString(UserManager.sharedInstance.jid) {
                    preString = NSLocalizedString("你", comment: "")
                }
                startStr = preString
            }
        }else if let channel = CODChannelModel.getChannel(by: messageBodyModel.roomID) {
            startStr = channel.getGroupName()
        }
        
        let topmsg = messageBodyModel.settingJson["topmsg"].string ?? ""
        
        let midStr = NSLocalizedString("已置顶", comment: "")
        var text = "1 条消息"
        if let message = CODMessageRealmTool.getMessageByMsgId(topmsg) {
            let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: message.msgType ) ?? .text
            switch modelType {
            case .text:
                text = "“\(message.text.replaceLineSpaceToSpace)”"
                break
            case .image:
                text = "1 张图片"
                break
            case .video:
                text = "1 个视频"
                break
            case .location:
                text = "1 个位置"
                break
            case .file:
                text = "1 个文件"
                break
            case .audio:
                text = "1 条语音消息"
                break
            case .businessCard:
                text = "1 个联系人信息"
                break
            case .multipleImage:
                text = "1 组图片"
            default:
                text = "1 条消息"
                break
            }
            switch modelType {
            case .text:
                break
            default:
                text = NSLocalizedString(text, comment: "")
            }
            
            text = midStr + " " + text
        }else{
            if topmsg == "0" || topmsg == ""{
                var preString = ""
                
                preString = "\(startStr) 已取消置顶 "
                if messageBodyModel.sender.compareNoCaseForString(UserManager.sharedInstance.jid) {
                    preString = "你 已取消置顶 "
                }
                return preString
                
            }else{
                return midStr + " " + text
            }
        }
        return startStr + " " + text
    }
    
    func topMsgConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        
        let topmsg = message.settingJson["topmsg"].string ?? ""
        let topMessageModel = CODMessageRealmTool.getMessageByMsgId(topmsg)
        if topMessageModel == nil {
            messageModel.setValue(\.needUpdateMsg, value: true)
            XMPPManager.shareXMPPManager.getTopMsg(roomId: messageModel.roomId)
        }
        
        if !message.isMeSend, message.chatType == .groupChat {
            let invitJoinList = List<String>()
            let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: message.sender)
            if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                let dic = [message.sender: memberModel.getMemberNickName()].jsonString()
                invitJoinList.append(dic ?? "")
            }
            messageModel.invitjoinList = invitJoinList
        }

    }
    
    func Bothroster(message: CODMessageHJsonModel) -> String? {
        
        var messageText = ""
        let settingJson = message.settingJson
        
        let contactModel = CODContactModel()
        contactModel.jsonModel = CODContactHJsonModel.deserialize(from: settingJson.dictionaryObject)
        
        messageText = "\(contactModel.getContactNick())与你已成为好友,你们可以开始聊天了"
        
//        if let loginName = UserManager.sharedInstance.loginName {
//            if message.sender.contains(loginName) {
//                return nil
//            }
//        }
        
        return messageText
    }
    
    
    func screenShot(messageBodyModel: CODMessageHJsonModel) -> String? {
        
        if let setting = messageBodyModel.setting {
            
            //设置截屏开关
            let screenShot = setting.screenshot
            
            if messageBodyModel.chatType == .privateChat {
                if CODContactRealmTool.getContactByJID(by: messageBodyModel.sender) != nil {
                    if messageBodyModel.sender.compareNoCaseForString(UserManager.sharedInstance.jid) {
                        return screenShot ? "你开启了截屏通知" : "你关闭了截屏通知"
                    } else {
                        return screenShot ? "对方开启了截屏通知" : "对方关闭了截屏通知"
                    }
                }
                if CODContactRealmTool.getContactByJID(by: messageBodyModel.receiver) != nil {
                    if messageBodyModel.sender.compareNoCaseForString(UserManager.sharedInstance.jid) {
                        return screenShot ? "你开启了截屏通知" : "你关闭了截屏通知"
                    } else {
                        return screenShot ? "对方开启了截屏通知" : "对方关闭了截屏通知"
                    }
                }
                
            } else {
                if CODGroupChatRealmTool.getGroupChat(id: messageBodyModel.roomID) != nil  {
                    if messageBodyModel.sender.compareNoCaseForString(UserManager.sharedInstance.jid) {
                        return screenShot ? "你开启了截屏通知" : "你关闭了截屏通知"
                    } else {
                        return screenShot ? "管理员开启了截屏通知" : "对方关闭了截屏通知"
                    }
                }
            }
        }
        
        return nil
        
    }
    
    func setBurn(message: CODMessageHJsonModel) -> String? {
        
        if let setting = message.setting {
            let burn = setting.burn
            let discription = CustomUtil.convertBurnStr(burn: burn).0
            if message.chatType == .privateChat {
                if let contactModel = CODContactRealmTool.getContactByJID(by: message.sender) {
                    if message.isMeSend {
                        return self.getBurnString(who: NSLocalizedString("您", comment: ""), burn: burn, discription: discription)
                    } else {
                        return self.getBurnString(who: "“\(contactModel.getContactNick())”", burn: burn, discription: discription)
                    }
                } else {
                    if let contactModel = CODContactRealmTool.getContactByJID(by: message.receiver) {
                        if message.isMeSend {
                            return self.getBurnString(who: NSLocalizedString("您", comment: ""), burn: burn, discription: discription)
                        } else {
                            return self.getBurnString(who: "“\(contactModel.getContactNick())”", burn: burn, discription: discription)
                        }
                    }
                }
            } else {
                if message.isMeSend {
                    return self.getBurnString(who: NSLocalizedString("您", comment: ""), burn: burn, discription: discription)
                } else {
                    let memberID = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: message.sender)
                    let member = CODGroupMemberRealmTool.getMemberById(memberID)
                    return self.getBurnString(who: "“\(member?.getMemberNickName() ?? NSLocalizedString("管理员", comment: ""))”", burn: burn, discription: discription)
                }
            }
            
        }
        
        return nil
        
    }
    
    func setBurnConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        if !message.isMeSend {
            let invitJoinList = List<String>()
            if message.chatType == .privateChat {
                if let contactModel = CODContactRealmTool.getContactByJID(by: message.sender) {
                    let dic = [message.sender: contactModel.getContactNick()].jsonString()
                    invitJoinList.append(dic ?? "")
                }
                messageModel.invitjoinList = invitJoinList
                
            } else if message.chatType == .groupChat {
                let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: message.sender)
                if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                    let dic = [message.sender: memberModel.getMemberNickName()].jsonString()
                    invitJoinList.append(dic ?? "")
                }
                messageModel.invitjoinList = invitJoinList
                
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
    
    func changeGroupAvatar(message: CODMessageHJsonModel) -> String? {
        
        if let setting = message.setting {
            
            let senderJid = message.sender
            var who: String = ""
            if senderJid.compareNoCaseForString(UserManager.sharedInstance.jid) {
                who = NSLocalizedString("您", comment: "")
            } else {
                let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: message.sender)
                if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                    who = memberModel.getMemberNickName()
                } else {
                    who = NSLocalizedString("管理员", comment: "")
                }
            }
            
            if let grouppic =  setting.grouppic {
                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: grouppic, complete: nil)
                if message.chatType == .groupChat {
                    return "“\(who)”\(NSLocalizedString("修改了群头像", comment: ""))"
                }else{
//                    return "“\(who)”\(NSLocalizedString("修改了频道头像", comment: ""))"
                    return NSLocalizedString("频道头像已更新", comment: "")
                }
                
            }
            
        }
        
        return nil
        
    }
    
    func changeGroupAvatarConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        
        if let _ = message.setting?.grouppic, !message.isMeSend {
            let invitJoinList = List<String>()
            let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: message.sender)
            if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                let dic = [message.sender: memberModel.getMemberNickName()].jsonString()
                invitJoinList.append(dic ?? "")
            }
            messageModel.invitjoinList = invitJoinList
        }
    }
    
    func notinvite(message: CODMessageHJsonModel) -> String? {
        
        if message.settingJson["notinvite"].boolValue {
            return NSLocalizedString("管理员已禁止群成员邀请好友入群", comment: "")
        } else {
            return NSLocalizedString("管理员已开启群成员邀请好友入群功能，同时群二维码也将生效", comment: "")
        }
        
    }
    
    func setNotice(message: CODMessageHJsonModel) -> String? {
        
        if message.chatType == .groupChat {
            
            let senderJid = message.sender
            let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: senderJid)
            
            if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                
                ///群公告修改
                if let notice = message.settingJson["notice"].string {
                    if notice.count > 0 {
                        if senderJid.compareNoCaseForString(UserManager.sharedInstance.jid) {
                            return "\(NSLocalizedString("你修改群公告为：", comment: ""))\(notice)"
                        } else {
                            return "“\(memberModel.getMemberNickName())”\(NSLocalizedString("修改群公告为：", comment: ""))\(notice)"
                        }
                        
                    } else {
                        if senderJid.compareNoCaseForString(UserManager.sharedInstance.jid) {
                            return NSLocalizedString("你已清空群公告", comment: "")
                        } else {
                            return "“\(memberModel.getMemberNickName())”\(NSLocalizedString("清空群公告", comment: ""))"
                        }
                        
                    }
                }
            }
        }
        
        return nil
        
    }
    
    func setNoticeConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        
        if let _ = message.settingJson["notice"].string, !message.isMeSend {
            let invitJoinList = List<String>()
            let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: message.sender)
            if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                let dic = [message.sender: memberModel.getMemberNickName()].jsonString()
                invitJoinList.append(dic ?? "")
            }
            messageModel.invitjoinList = invitJoinList
        }
        
    }
    
    func transferOwner(message: CODMessageHJsonModel) -> String? {
        
        if let newGroupOwnerJid = message.setting?.newGroupOwner {
            
            if newGroupOwnerJid.compareNoCaseForString(UserManager.sharedInstance.jid) {
                return NSLocalizedString("你已成为群主", comment: "")
            } else {
                let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: newGroupOwnerJid.subStringTo(string: "@"))
                if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                    return String(format: NSLocalizedString("“%@”已成为群主", comment: ""), memberModel.getMemberNickName())
                }
            }
            
        }
        
        return nil
        
    }
    
    func transferOwnerConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        
        if let newGroupOwnerJid = message.setting?.newGroupOwner, !newGroupOwnerJid.compareNoCaseForString(UserManager.sharedInstance.jid) {
            let invitJoinList = List<String>()
            let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: newGroupOwnerJid)
            if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                let dic = [newGroupOwnerJid: memberModel.getMemberNickName()].jsonString()
                invitJoinList.append(dic ?? "")
            }
            messageModel.invitjoinList = invitJoinList
        }
        
    }
    
    func setKickOut(message: CODMessageHJsonModel) -> String? {
        
        if message.chatType == .channel {
            return nil //NSLocalizedString("您被移出频道", comment: "")
        } else if message.chatType == .groupChat {
            return NSLocalizedString("您被移出群聊", comment: "")
        }
        
        return nil
        
    }
    
    func setMucname(message: CODMessageHJsonModel) -> String? {
        
        if let descriptions = message.settingJson["description"].string {
            switch message.chatType {
            case .groupChat:
                return "\(NSLocalizedString("群名称更改为：", comment: ""))\(descriptions)"
            case .channel:
                return "\(NSLocalizedString("频道名称已更改为", comment: ""))“\(descriptions)”"
            case .privateChat:
                break
            }
            
        }
        
        return nil
        
    }
    
    func kickOut(message: CODMessageHJsonModel) -> String? {
        if message.chatType == .groupChat {
            
            var tempStr = ""
            if let members = message.settingJson["member"].arrayObject as? Array<Dictionary<String, Any>> {
                
                
                for memberDic in members {
                    
                    if let memberJid = memberDic["jid"] as? String {
                        let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: memberJid)
                        if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                            tempStr.append(contentsOf: "\(memberModel.getMemberNickName())、")
                        } else if let contactModel = CODContactRealmTool.getContactByJID(by: memberJid) {
                            tempStr.append(contentsOf: "\(contactModel.getContactNick())、")
                        }else{
                            if let personInfo = CODPersonInfoModel.getPersonInfoModel(jid: memberJid) {
                                tempStr.append(contentsOf: "\(personInfo.name)、")
                            }
                        }
                    }
                }
                tempStr = "\(tempStr)\(NSLocalizedString("被移出群聊", comment: ""))"
            }
            return tempStr
            
        } else if message.chatType == .channel {
            return nil
        }
        
        return nil
    }
    
    func canSpeak(message: CODMessageHJsonModel) -> String? {
        
        if message.chatType == .groupChat {
            
            if let canspeak = message.settingJson["canspeak"].bool {
                return NSLocalizedString(canspeak ? "管理员已允许群成员发言,大家畅所欲言吧" : "管理员已禁止群成员发言", comment: "")
            }
        }
        
        return nil
        
    }
    
    func InvitJoinConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        
        if let member = message.settingJson["member"].arrayObject as? Array<Dictionary<String, Any>> {
            let invitJoinList = List<String>()
            for i in 0 ..< member.count {
                let memberTemp = member[i]
                let memberModel = CODGroupMemberModel()
                memberModel.jsonModel = CODGroupMemberHJsonModel.deserialize(from: memberTemp)
                
                let dic = [memberModel.jid:memberModel.getMemberNickName()].jsonString()
                invitJoinList.append(dic ?? "")
            }
            if !message.isMeSend {
                let memberID = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: message.sender)
                if let member = CODGroupMemberRealmTool.getMemberById(memberID) {
                    let dic = [message.sender: member.getMemberNickName()].jsonString()
                    invitJoinList.append(dic ?? "")
                }
            }
//            else{
//                for member in message.settingJson["refusemember"].arrayValue {
//                    let memberTemp = CODGroupMemberModel()
//                    memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
//                    if let contact = CODContactRealmTool.getContactByJID(by: memberTemp.jid) {
//                        let dic = [contact.jid: contact.getContactNick()].jsonString()
//                        invitJoinList.append(dic ?? "")
//                    }
//                }
//            }
            
            messageModel.invitjoinList = invitJoinList
            
        }
        
    }
    
    func refuseJoin(message: CODMessageHJsonModel) -> String? {
        
        var refuseMembersStr: String = ""
        if let refusememberArr = message.settingJson["refusemember"].arrayObject as? [Dictionary<String,Any>], refusememberArr.count > 0 {
            
            for i in 0..<refusememberArr.count {
                let member = refusememberArr[i]
                let memberTemp = CODGroupMemberModel()
                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                if let contact = CODContactRealmTool.getContactByJID(by: memberTemp.jid) {
                    if i == refusememberArr.count-1 {
                        refuseMembersStr.append("\(contact.getContactNick())")
                    }else{
                        refuseMembersStr.append("\(contact.getContactNick())、")
                    }
                }
            }
            refuseMembersStr = String.init(format: NSLocalizedString("你无法邀请“%@”进入群聊，根据对方的隐私设置，不能将对方加入群聊", comment: ""), refuseMembersStr)
        }
        return refuseMembersStr
    }
    
    func refuseJoinConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        
        let invitJoinList = List<String>()
        for member in message.settingJson["refusemember"].arrayValue {
            let memberTemp = CODGroupMemberModel()
            memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
            if let contact = CODContactRealmTool.getContactByJID(by: memberTemp.jid) {
                let dic = [contact.jid: contact.getContactNick()].jsonString()
                invitJoinList.append(dic ?? "")
            }
        }
        
        messageModel.invitjoinList = invitJoinList
        
    }
    
    func InvitJoin(message: CODMessageHJsonModel) -> String? {
        
        var textStr = ""
        if let member = message.settingJson["member"].arrayObject as? Array<Dictionary<String, Any>> {
            var memberTempStr = ""
            for i in 0 ..< member.count {
                let memberDic = member[i]
                let memberTemp = CODGroupMemberModel()
                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: memberDic)
                memberTemp.memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: memberTemp.jid)
                if i == member.count-1 {
                    memberTempStr.append("\(memberTemp.getMemberNickName())")
                }else{
                    memberTempStr.append("\(memberTemp.getMemberNickName())、")
                }
            }
            
            if message.sender.compareNoCaseForString(UserManager.sharedInstance.jid) {
                textStr = String.init(format: NSLocalizedString("你邀请“%@”加入了群聊", comment: ""), memberTempStr)
                
//                var refuseMembersStr: String = ""
//                if let refusememberArr = message.settingJson["refusemember"].arrayObject as? [Dictionary<String,Any>], refusememberArr.count > 0 {
//                    if memberTempStr.count > 0 {
//                        textStr.append("。\n")
//                    }else{
//                        textStr = ""
//                    }
//
//                    for i in 0..<refusememberArr.count {
//                        let member = refusememberArr[i]
//                        let memberTemp = CODGroupMemberModel()
//                        memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
//                        if let contact = CODContactRealmTool.getContactByJID(by: memberTemp.jid) {
//                            if i == refusememberArr.count-1 {
//                                refuseMembersStr.append("\(contact.getContactNick())")
//                            }else{
//                                refuseMembersStr.append("\(contact.getContactNick())、")
//                            }
//                        }
//                    }
//                    refuseMembersStr = String.init(format: NSLocalizedString("你无法邀请“%@”进入群聊，根据对方的隐私设置，不能将对方加入群聊", comment: ""), refuseMembersStr)
//                    textStr.append(refuseMembersStr)
//                }
                
            }else{
                
                if memberTempStr.count <= 0 {
                    textStr = ""
                }else{
                    let invitorMemberID = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: message.sender)
                    if let invitor = CODGroupMemberRealmTool.getMemberById(invitorMemberID) {
                        textStr = String.init(format: NSLocalizedString("“%@”邀请“%@”加入了群聊", comment: ""), invitor.getMemberNickName(),memberTempStr)
                    }
                }
            }
        }
        
        return textStr
    }
    
    func SetCreateJoin(message: CODMessageHJsonModel) -> String? {
        
        var messageText = ""
        
        guard let groupChatJsonModel = CODGroupChatHJsonModel.deserialize(from: message.settingJson.dictionaryObject) else {
            return nil
        }
        
        if message.isMeSend {
            
            messageText = String(format: "%@ \(NSLocalizedString("创建了群聊", comment: "")) “%@”", UserManager.sharedInstance.nickname!, groupChatJsonModel.description)
            
            var refuseMembersStr: String = ""
            
            let refusememberArr = message.settingJson["refusemember"].arrayValue
            if refusememberArr.count > 0 {
                messageText.append("。\n")
                for member in refusememberArr {
                    let memberTemp = CODGroupMemberModel()
                    memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
                    if let contact = CODContactRealmTool.getContactByJID(by: memberTemp.jid) {
                        refuseMembersStr.append("\(contact.getContactNick())、")
                    }
                }
                refuseMembersStr = String.init(format: NSLocalizedString("你无法邀请“%@”进入群聊，根据对方的隐私设置，不能将对方加入群聊", comment: ""), refuseMembersStr)
                messageText.append(refuseMembersStr)
            }
            
            
        } else {
            
            if let inviterModel = CODContactRealmTool.getContactByJID(by: message.sender) {
                let inviterName = inviterModel.getContactNick()
                messageText = String(format: "%@ \(NSLocalizedString("创建了群聊", comment: "")) “%@”", inviterName, groupChatJsonModel.description)
            }else{
                messageText = NSLocalizedString("加入群聊", comment: "")
            }
            
        }
        
        return messageText
        
    }
    
    func SetCreateJoinConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        
        let invitJoinList = List<String>()
        if !message.isMeSend {
            if let inviterModel = CODContactRealmTool.getContactByJID(by: message.sender) {
                let inviterName = inviterModel.getContactNick()
                let dic = [message.sender: inviterName].jsonString()
                invitJoinList.append(dic ?? "")
            }
            
        }else{
            for member in message.settingJson["refusemember"].arrayValue {
                let memberTemp = CODGroupMemberModel()
                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
                if let contact = CODContactRealmTool.getContactByJID(by: memberTemp.jid) {
                    let dic = [contact.jid: contact.getContactNick()].jsonString()
                    invitJoinList.append(dic ?? "")
                }
            }
        }
        messageModel.invitjoinList = invitJoinList
    }
    
    func setUrlInvitJoin(message: CODMessageHJsonModel) -> String? {
        
        var textStr = ""
        
        if message.chatType == .groupChat {
            
            
            var nameString = ""
            
            if message.sender == UserManager.sharedInstance.jid {
                textStr = NSLocalizedString("您加入了群聊", comment: "")
            } else {
                if let member = message.settingJson["member"].arrayObject as? Array<Dictionary<String, Any>> {
                    for memberTemp in member {
                        let memberModel = CODGroupMemberModel()
                        memberModel.jsonModel = CODGroupMemberHJsonModel.deserialize(from: memberTemp)
                        memberModel.memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: memberModel.username)

                        if memberModel.jid == message.sender {
                            nameString = "“\(memberModel.getMemberNickName())”"
                        }
                    }
                    textStr = "\(nameString)\(NSLocalizedString("加入群聊", comment: ""))"
                }
            }
                
            return textStr
        } else if message.chatType == .channel {
            
            if message.settingJson["inviter"].string == UserManager.sharedInstance.jid {
                return NSLocalizedString("您加入了此频道", comment: "")
            } else {
                return nil
            }
            
            
        }
        
        return nil
    }
    
    func setUrlInvitJoinConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        let invitJoinList = List<String>()
        if message.chatType == .groupChat, message.sender != UserManager.sharedInstance.jid {
            guard let member = message.settingJson["member"].arrayObject as? Array<Dictionary<String, Any>> else {
                return
            }
            for memberTemp in member {
                let memberModel = CODGroupMemberModel()
                memberModel.jsonModel = CODGroupMemberHJsonModel.deserialize(from: memberTemp)
                memberModel.memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: memberModel.username)
                
                if memberModel.jid == message.sender {
                    let nameString = "“\(memberModel.getMemberNickName())”"
                    let dic = [memberModel.jid:nameString].jsonString()
                    invitJoinList.append(dic ?? "")
                }
            }
        }
        messageModel.invitjoinList = invitJoinList
    }
    
    func QrInvitJoin(message: CODMessageHJsonModel) -> String? {
        
        var textStr = ""
        
        if message.chatType == .groupChat {
            
            if let member = message.settingJson["member"].arrayObject as? Array<Dictionary<String, Any>> {
                var memberTempStr = ""
                var nameString = ""
                
                for memberTemp in member {
                    let memberModel = CODGroupMemberModel()
                    memberModel.jsonModel = CODGroupMemberHJsonModel.deserialize(from: memberTemp)
                    memberModel.memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: memberModel.username)
                    
                    if memberModel.jid == UserManager.sharedInstance.jid {
                        memberTempStr.append(contentsOf: NSLocalizedString("您", comment: ""))
                    }else{
                        memberTempStr.append(contentsOf: "\(memberModel.getMemberNickName())")
                    }
                    
                }
                
                if let groupModel = CODGroupChatRealmTool.getGroupChatByJID(by: message.receiver) {
                    
                    for memberModel in groupModel.member {
                        if message.setting?.inviter == memberModel.jid {
                            if memberModel.jid == UserManager.sharedInstance.jid {
                                nameString = "您"
                            }else{
                                nameString = "\(memberModel.getMemberNickName())"
                            }
                        }
                    }
                }
                if nameString.count == 0 {
                    textStr = "“\(memberTempStr)”\(NSLocalizedString("扫描", comment: ""))\(NSLocalizedString("二维码加入群聊", comment: ""))"
                    
                }else{
                    textStr = "“\(memberTempStr)”\(NSLocalizedString("扫描", comment: ""))“\(nameString)”\(NSLocalizedString("的二维码加入群聊", comment: ""))"
                }
                
            }
            
            
        } else {
            
            if message.settingJson["inviter"].string == UserManager.sharedInstance.jid {
                textStr = NSLocalizedString("您加入了此频道", comment: "")
            } else {
                return nil
            }
            
            
        }
        
        return textStr
        
    }
    
    func QrInvitJoinConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        if let member = message.settingJson["member"].arrayObject as? Array<Dictionary<String, Any>> {
            let invitJoinList = List<String>()
            for i in 0 ..< member.count {
                let memberTemp = member[i]
                let memberModel = CODGroupMemberModel()
                memberModel.jsonModel = CODGroupMemberHJsonModel.deserialize(from: memberTemp)
                
                let dic = [memberModel.jid: memberModel.getMemberNickName()]
                invitJoinList.append(dic.jsonString() ?? "")
            }
            if let inviter = message.setting?.inviter, inviter != UserManager.sharedInstance.jid {
                let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: inviter)
                if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                    let dic = [inviter: memberModel.getMemberNickName()]
                    invitJoinList.append(dic.jsonString() ?? "")
                }
            }
            
            messageModel.invitjoinList = invitJoinList
        }
    }
    
    func XHReferall(message: CODMessageHJsonModel) -> String? {
        ///群成员@所有人
        var messageText = ""
        let json = message.settingJson
        if let xhreferall =  json["xhreferall"].bool {
            if xhreferall {
                messageText = NSLocalizedString("管理员已开启群成员@所有人的功能", comment: "")
            } else {
                messageText = NSLocalizedString("管理员已关闭群成员@所有人的功能", comment: "")
            }
        }
        return messageText
        
    }
    
    func invitjoinchannel(message: CODMessageHJsonModel) -> String? {
        
        if message.isMeSend != true {
            return nil
        }
        
        guard let refusemembers = message.settingJson["refusemember"].array else {
            return nil
        }
        
        var refuseMembersStr: String = ""
        for refusemember in refusemembers {
            
            if let contact = CODContactRealmTool.getContactByJID(by: refusemember["jid"].stringValue) {
                
                refuseMembersStr += "\(contact.getContactNick())、"

            }
            
        }
        if refuseMembersStr.removeAllSapce.count > 0 {
            
            refuseMembersStr.removeLast(1)
            
            refuseMembersStr = String(format: NSLocalizedString("你无法邀请“%@”进入频道，根据对方的隐私设置，不能将对方加入频道", comment: ""), refuseMembersStr)
            
            return refuseMembersStr
            
        }else{
            
            return refuseMembersStr
        }
    }
    
    func invitjoinchannelConfigModel(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        if message.isMeSend {
            let invitJoinList = List<String>()
            for member in message.settingJson["refusemember"].arrayValue {
                let memberTemp = CODGroupMemberModel()
                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
                if let contact = CODContactRealmTool.getContactByJID(by: memberTemp.jid) {
                    let dic = [contact.jid: contact.getContactNick()].jsonString()
                    invitJoinList.append(dic ?? "")
                }
            }
            messageModel.invitjoinList = invitJoinList
        }
    }
    
    /// 群语音通话创建通知
    /// - Parameter message: 通知消息jsonModel
    func creatertcroom(message: CODMessageHJsonModel) -> String? {
        
        let senderJid = message.sender
        var who: String = ""
        if senderJid.compareNoCaseForString(UserManager.sharedInstance.jid) {
            who = NSLocalizedString("您", comment: "")
        } else {
            let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: message.sender)
            if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                who = memberModel.getMemberNickName()
            }
        }
        
        return "\(who) \(NSLocalizedString("发起了语音通话", comment: ""))"
    }
    
     func invitjoinCreatertcroom(message: CODMessageHJsonModel, messageModel: CODMessageModel) {
        
        let invitJoinList = List<String>()
        
        let senderJid = message.sender
        var who: String = ""
        if senderJid.compareNoCaseForString(UserManager.sharedInstance.jid) {
            who = NSLocalizedString("您", comment: "")
            let dic = [UserManager.sharedInstance.jid: who].jsonString()
            invitJoinList.append(dic ?? "")
            
        } else {
            let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomID, userName: message.sender)
            if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                who = memberModel.getMemberNickName()
                let dic = [memberModel.jid: who].jsonString()
                invitJoinList.append(dic ?? "")
            }
        }
        
        messageModel.invitjoinList = invitJoinList
        
        
    }
    
    /// 群语音通话创建通知
    /// - Parameter message: 通知消息jsonModel
    func endRoom(message: CODMessageHJsonModel) -> String? {
        
        return NSLocalizedString("语音通话已结束", comment: "")
    }
    
}
