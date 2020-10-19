//
//  XMPPManager+ReceiveMessage.swift
//  COD
//
//  Created by 1 on 2019/4/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import SwiftyJSON

extension XMPPManager{
    //收到入群通知
    func isNotNeedInvitJoinFor(messageDic :Dictionary<String, Any>) -> (result: Bool, memberStr: String){
        let groupChatModel = CODGroupChatModel()
        let dataDic = messageDic
        guard let messageBodyModel = CODMessageHJsonModel.deserialize(from: dataDic) else {
            print("解析Message错误")
            return (false, "")
        }
        
        var messageText: String = ""
        if let dic = dataDic["setting"] as?  Dictionary<String, Any>{
            groupChatModel.jsonModel = CODGroupChatHJsonModel.deserialize(from: dic)
            groupChatModel.isValid = true
            if let memberArr = dic["member"] as? [Dictionary<String,Any>] {
                for member in memberArr {
                    let memberTemp = CODGroupMemberModel()
                    memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                    memberTemp.memberId = String(format: "%d%@", groupChatModel.roomID, memberTemp.username)
                    groupChatModel.member.append(memberTemp)
                }
                groupChatModel.customName = CODGroupChatModel.getCustomGroupName(memberList: groupChatModel.member)
            }
            
            if messageBodyModel.sender.compareNoCaseForString(UserManager.sharedInstance.jid) {
                messageText = String(format: "%@ \(NSLocalizedString("创建了群聊", comment: "")) “%@”", UserManager.sharedInstance.nickname!, groupChatModel.descriptions)
                
                var refuseMembersStr: String = ""
                if let refusememberArr = dic["refusemember"] as? [Dictionary<String,Any>], refusememberArr.count > 0 {
                    messageText.append("。\n")
                    for member in refusememberArr {
                        let memberTemp = CODGroupMemberModel()
                        memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                        if let contact = CODContactRealmTool.getContactByJID(by: memberTemp.jid) {
                            refuseMembersStr.append("\(contact.getContactNick())、")
                        }
                    }
                    refuseMembersStr = String.init(format: NSLocalizedString("你无法邀请“%@”进入群聊，根据对方的隐私设置，不能将对方加入群聊", comment: ""), refuseMembersStr)
                    messageText.append(refuseMembersStr)
                }
                
            }else{
                if let inviterModel = CODContactRealmTool.getContactByJID(by: messageBodyModel.sender) {
                    let inviterName = inviterModel.getContactNick()
                    messageText = String(format: "%@ \(NSLocalizedString("创建了群聊", comment: "")) “%@”", inviterName, groupChatModel.descriptions)
                }else{
                    messageText = NSLocalizedString("加入群聊", comment: "")
                }
            }
            
            
            if let groupmodel = CODGroupChatRealmTool.getGroupChat(id: groupChatModel.roomID) {  //判断我是否在群里，如果在的话，直接返回，不需要再次加入聊天室
                let groupmemberId = CODGroupMemberModel.getMemberId(roomId: groupmodel.roomID, userName: UserManager.sharedInstance.loginName!)
                if CODGroupMemberRealmTool.getMemberById(groupmemberId) != nil {
                    return (false, "\(messageText)")
                }
            }
            
            //创建成功加入聊天室
            XMPPManager.shareXMPPManager.joinGroupChatWith(groupJid: groupChatModel.jid)
        }
        
        groupChatModel.createDate = String(format: "%.0f", Date.milliseconds)
        if let groupPic = messageDic["grouppic"] as? String {
            groupChatModel.grouppic = groupPic
        }
        
        CODGroupChatRealmTool.insertGroupChat(by: groupChatModel)
        print("收到群聊通知，创建GroupChatModel")
        return (true, "\(messageText)")
    }
    
    
    //消息被拒收处理
    func messageDidSentBack(message: XMPPMessage, messageModel: CODMessageHJsonModel) {
        if let messageIDStr = message.elementID {
            guard let model = CODMessageRealmTool.getMessageByMsgId(messageIDStr) else{
                print("未查询到被拒收的消息")
                return
            }
            try! Realm.init().write {
                model.status = CODMessageStatus.Failed.rawValue
            }
            
            CODMessageRealmTool.updateMessageStyleByMsgId(model.msgID, status: CODMessageStatus.Failed.rawValue, sendTime: messageModel.sendTime)
            CODChatListRealmTool.updateLastDatetimeWithMessageModel(messageModel: model)
            
            NotificationCenter.default.post(name: NSNotification.Name.init(kUpdateTheMessageNoti), object: nil, userInfo: ["id":model.msgID])
            
            guard let contact = CODContactRealmTool.getContactByJID(by: model.toJID) else {
                return
            }
            var msgModel: CODMessageModel?
            if let error = message.errorMessage {
                print("error: \(error.localizedDescription)")
                let message = try! XMPPMessage.init(xmlString: error.localizedDescription)

                
                guard let errorJson = message.getChildrenJSON(name: "result") else {
                    return
                }
                
                
                switch(errorJson["code"].intValue) {
                    case 30005 : //黑名单被拒
                      msgModel = CODMessageModelTool.default.createTextModel(msgID: UserManager.sharedInstance.getMessageId(), toJID: model.toJID, textString: NSLocalizedString("对方拒收您的消息", comment: ""), chatType: .privateChat, roomId: nil, chatId: contact.rosterID, burn:  contact.burn, sendTime: messageModel.sendTime.string)
                      msgModel?.fromWho = message.fromStr ?? ""

                      break
                  case 30020 : //对方已开启拒收消息功能
                      
                      //                        if let contact = CODContactRealmTool.getContactByJID(by: model.toJID) {
                      
                      let alert = UIAlertController.init(title: NSLocalizedString("抱歉，根据对方的隐私设置，您不能给对方发送消息", comment: ""), message: nil, preferredStyle: .alert)
                      let confirmAction = UIAlertAction.init(title: "好", style: .default, handler: nil)
                      alert.addAction(confirmAction)
                      UIViewController.current()!.present(alert, animated: true, completion: nil)
                      //                        }
                      
                      break
                  default:
                      break
                }
            }
            
            if let msg = msgModel {
                msg.type = .notification
                
                if let history = CODChatHistoryRealmTool.getChatHistory(from: contact.rosterID) { ///避免出现多条
                    if let messageModel = history.messages.last {
                        if messageModel.text == msgModel?.text {
                            return
                        }
                    }
                }
                

                CODChatListRealmTool.addChatListMessage(id: contact.rosterID, message: msg)
                
                var fromJID: String = message.fromStr!
                if messageModel.chatType == .groupChat {//是群聊的话，设置fromJID为群JID
                    if !fromJID.contains("@conference") {
                        fromJID = messageModel.receiver
                    }
                }else{
                    fromJID = messageModel.sender
                }
                
            }
        }
    }

    func setMucname(messageDic: Dictionary<String, Any>) -> String {
        guard let messageBodyModel = CODMessageHJsonModel.deserialize(from: messageDic) else {
            print("解析Message错误")
            return ""
        }
        var textStr = ""
        if let setting = messageDic["setting"] as? Dictionary<String, Any> {
            if let descriptions = setting["description"] as? String {
                switch messageBodyModel.chatType {
                case .groupChat:
                    textStr = "\(NSLocalizedString("群名称更改为：", comment: ""))\(descriptions)"
                case .channel:
                    textStr = "\(NSLocalizedString("频道名称已更改为", comment: ""))“\(descriptions)”"
                    break
                case .privateChat:
                    break
                }
                
                CODGroupChatRealmTool.modifyGroupChatNameByRoomID(by: messageBodyModel.roomID, newRoomName: descriptions)
            }
        }
        return textStr
    }
            
    
    func canSpeak(messageDic: Dictionary<String, Any>) -> String {
        
        guard let messageBodyModel = CODMessageHJsonModel.deserialize(from: messageDic) else {
            print("解析Message错误")
            return ""
        }
        
        if messageBodyModel.chatType == .groupChat {
            if let setting = messageDic["setting"] as? Dictionary<String, Any>,let canspeak = setting["canspeak"] as? Bool {
                try! Realm.init().write {
                    if let group = CODGroupChatRealmTool.getGroupChat(id: messageBodyModel.roomID){
                        group.canspeak = canspeak
                        //                    if let chatList = CODChatListRealmTool.getChatList(id: messageBodyModel.roomID){
                        //                        chatList.canspeak = canspeak
                        //                    }
                    }
                }
                return NSLocalizedString(canspeak ? "管理员已允许群成员发言,大家畅所欲言吧" : "管理员已禁止群成员发言", comment: "")
            }
        }else{
            return ""
        }
        return ""
    }
    
    
    /// 收到频道邀请
    /// - Parameter messageDic: 频道信息
    func channel_create(messageDic :Dictionary<String, Any>) {
        
        guard let dic = messageDic["setting"] as?  Dictionary<String, Any> else {
            return
        }
        
        guard let jsonModel = CODChannelHJsonModel.deserialize(from: dic) else {
            return
        }
        
        if jsonModel.roomID == 0 {
            return
        }
        
        if let channelModel = CODChannelModel.getChannel(by: jsonModel.roomID) {
            
            channelModel.updateChannel(isValid: true)
            CODChatListModel.insertOrUpdateChannelListModel(by: channelModel, message: nil)
            
        } else {
            
            let channelModel = CODChannelModel.init(jsonModel: CODChannelHJsonModel.deserialize(from: dic)!)
            channelModel.isValid = true
            
            if let memberArr = dic["channelMemberVoList"] as? [Dictionary<String,Any>] {
                
                let members = memberArr.map { member -> CODGroupMemberModel in
                    let memberTemp = CODGroupMemberModel()
                    memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                    memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                    return memberTemp
                }
                channelModel.member.append(objectsIn: members)
            }
            channelModel.customName = CODGroupChatModel.getCustomGroupName(memberList: channelModel.member)
            
            channelModel.createDate = String(format: "%.0f", Date.milliseconds)
            
            CODChatListModel.insertOrUpdateChannelListModel(by: channelModel, message: nil)
            
        }
        
        
    }
    
    func channel_updateMember(messageDic :Dictionary<String, Any>) {
        
        let json = JSON(messageDic)
        
        if let channelModel = CODChannelModel.getChannel(by: json["roomID"].intValue) {
            
            if let memberArr = json["setting"]["member"].arrayObject as? [Dictionary<String,Any>] {
                
                let members = memberArr.map { member -> CODGroupMemberModel in
                    let memberTemp = CODGroupMemberModel()
                    memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                    memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                    return memberTemp
                }
                
                channelModel.addMembers(members)
            }
            
        }
        
        
    }
    
}

extension XMPPManager{
    
    func editMsg(message: XMPPMessage) {
        
        if let messageModel = self.xmppMessageToRealmMessage(message: message) {
            
            if let model = CODMessageRealmTool.getMessageByMsgId(messageModel.msgID) {
                model.editMessage(model: messageModel, status: .Succeed)
            }
            
            switch messageModel.chatTypeEnum {
            case .groupChat, .channel:
                CODChatListRealmTool.addChatListMessage(id: messageModel.roomId, message: messageModel)
            case .privateChat:
                
                var jid = ""
                if messageModel.isMeSend {
                    jid = messageModel.toJID
                } else {
                    jid = messageModel.fromJID
                }
                
                if let contact = CODContactRealmTool.getContactByJID(by: jid) {
                    CODChatListRealmTool.addChatListMessage(id: contact.rosterID, message: messageModel)
                }
            }
        }
    }
    
}
