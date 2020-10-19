//
//  CODChatMessageDisplayPageVM+Receive.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import XMPPFramework

extension CODChatMessageDisplayPageVM: XMPPStreamDelegate {
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        
        
        
        DispatchQueue.main.async {
            
            if let type = message.type, type.compareNoCaseForString("error") {   //消息来自系统 且 message.type == error，就是被拒收
                self.errorHandle(message: message)
                return
            }
            
            
            guard let messageModel = XMPPManager.shareXMPPManager.xmppMessageToRealmMessage(message: message) else {
                return
            }
            
            if (messageModel.type == .notification && messageModel.text.count == 0) {
                self.actionNotification(message: message)
                return
            }
            
            if self.checkMessage(message: message) == false {
                return
            }
            
            
            if messageModel.type == .voiceCall || messageModel.type == .videoCall {
                
                if (messageModel.videoCallModel?.videoCalltype != .close &&
                    messageModel.videoCallModel?.videoCalltype != .reject &&
                    messageModel.videoCallModel?.videoCalltype != .cancle &&
                    messageModel.videoCallModel?.videoCalltype != .timeout &&
                    messageModel.videoCallModel?.videoCalltype != .busy &&
                    messageModel.videoCallModel?.videoCalltype != .connectfailed) || messageModel.isGroupChat {
                    return
                }
                
            }
            
            if messageModel.type == .haveRead {
                return
            }
            
            if messageModel.isMeSend == false {
                CODMessageSendTool.default.sendHaveReadMessage(messageModel: messageModel)
                self.updateReadMessage(lastTime: messageModel.datetime)
            }
            

            CODChatListRealmTool.addChatListMessage(id: self.chatObj.chatId, message: messageModel)
            
            if let messageModel = CODMessageRealmTool.getExistMessage(messageModel.msgID) {
                self.receiveMessage(message: messageModel)
            }
            
        }
        
    }
    
    func errorHandle(message: XMPPMessage) {
        
        guard let messageID = message.elementID else {
            return
        }
        
        guard let model = CODMessageRealmTool.getMessageByMsgId(messageID) else{
            return
        }
        
        let messageJson = JSON(parseJSON: message.body ?? "")
        
        CODMessageRealmTool.updateMessageStyleByMsgId(messageID, status: CODMessageStatus.Failed.rawValue, sendTime: messageJson["sendTime"].int)
        CODChatListRealmTool.updateLastDatetimeWithMessageModel(messageModel: model)
        
        guard let contact = chatListModel.contact else {
            return
        }
        
        if let error = message.errorMessage {
            print("error: \(error.localizedDescription)")
            let errorMessage = try! XMPPMessage.init(xmlString: error.localizedDescription)
//            guard message.childCount > 1, let node = message.child(at: 1), node.name == "result"  else {
//                return
//            }
            
            guard let errorJson = errorMessage.getChildrenJSON(name: "result") else {
                return
            }
            

            
            
            switch(errorJson["code"].intValue) {
            case 30005 : //黑名单被拒
                let msgModel = CODMessageModelTool.default.createTextModel(msgID: UserManager.sharedInstance.getMessageId(), toJID: model.toJID, textString: NSLocalizedString("对方拒收您的消息", comment: ""), chatType: .privateChat, roomId: nil, chatId: contact.rosterID, burn:  contact.burn, sendTime: messageJson["sendTime"].int?.string)
                msgModel.type = .notification
                msgModel.fromWho = message.fromStr ?? ""
                CODChatListRealmTool.asyncAddChatListMessage(id: chatObj.chatId, message: msgModel)
                self.receiveMessage(message: msgModel)
                break
            default:
                break
            }
        }
        
        
    }
    
    func updateReadMessage(lastTime: String?) {
        
        var lastMessageTime = lastTime?.int ?? 0
        
        if self.isCloudDisk {
            lastMessageTime = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
        }
        
        DispatchQueue.main.async {
            
            if let unReadMessages = CODChatHistoryRealmTool.getChatHistoryMessage(from: self.chatObj.chatId, lastMessageTime: lastMessageTime, isRead: false), unReadMessages.count > 0 {
                for model in unReadMessages {
                    CODMessageRealmTool.updateMessageHaveReadedByMsgId(model.msgID, isReaded: true)
                    
                }
                // 因为这个if判断有可能是进不来的，所以 self.updateReadMessageBR.accept(Void()) 在if外层必须调用一次，用来刷新UI。
                // 但是在聊天页面收到已读回执的时候，UI已经先刷新，消息体的已读标记后标记，导致单双勾不准，所以在if里面再调用一次 self.updateReadMessageBR.accept(Void())
                self.updateReadMessageBR.accept(Void())
            }
            
        }
        
    }
    
    func actionNotification(message: XMPPMessage) {
        
        guard let messageBodyModel = XMPPManager.shareXMPPManager.xmppMessageToJsonMessageModel(message: message) else {
            return
        }
        
        if messageBodyModel.msgTypeEnum == .notification {
                        
            switch messageBodyModel.body {
            case COD_removeLocalChatMsg, COD_removeLocalGroupMsg,
                 COD_removeclouddiskmsg, COD_removeChatMsg,
                 COD_removeGroupMsg, COD_removeChannelMsg:
                if let msgIDs = messageBodyModel.settingJson["msgID"].arrayObject as? [String]  {
                    self.cellDeleteMessage(msgIDs: msgIDs)
                }
                
            case COD_SetAdmins.lowercased(), COD_TransferOwner:
                self.updateReadMessageBR.accept(Void())
            default:
                break
            }
            
        }
        
    }
    
    
    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        
        DispatchQueue.main.async {
            
            if self.checkMessage(message: message) == false {
                return
            }
            
            guard let jsonMessageModel = XMPPManager.shareXMPPManager.xmppMessageToJsonMessageModel(message: message) else {
                return
            }
            
            let messageModel = XMPPManager.shareXMPPManager.createMessageModel(message.elementID ?? "", jsonMessageModel, "", message)
            
            if messageModel.type == .haveRead {
                return
            }
            
            if messageModel.type == .text {
                messageModel.text = AES128.aes128DecryptECB(jsonMessageModel.body)
            }
            
            messageModel.statusType = .Failed
            
            CODChatListRealmTool.addChatListMessage(id: self.chatObj.chatId, message: messageModel)
            
            
        }
        
    }
    
    
    func checkAtMessage(message: XMPPMessage) {
        
        if self.checkMessage(message: message) == false {
            return
        }
        
        guard let messageModel = XMPPManager.shareXMPPManager.xmppMessageToRealmMessage(message: message) else {
            return
        }
        
        if (messageModel.referTo.contains(UserManager.sharedInstance.jid) || messageModel.referTo.contains(kAtAll)) {
            if let _ = CustomUtil.getRefertoString(message: messageModel) {
                let messageInfo = (sendTime: messageModel.datetime, msgId: messageModel.msgID)
                self.referToMessageID.insert(messageInfo, at: 0)
                self.referToMessageIDAdd.accept(messageInfo)
            }
        }
        
        
    }
    
    
    func checkMessage(message: XMPPMessage) -> Bool {
        
        guard let loginName = UserManager.sharedInstance.loginName else {
            return false
        }
        
        guard let jsonMessageModel = XMPPManager.shareXMPPManager.xmppMessageToJsonMessageModel(message: message) else {
            return false
        }
        
        if chatListModel.isInvalidated {
            return false
        }
        
        if jsonMessageModel.chatType != self.chatListModel.chatTypeEnum {
            return false
        }
        
        switch jsonMessageModel.chatType {
        case .privateChat:
            if jsonMessageModel.isMeSend {
                
                if jsonMessageModel.receiver != self.chatListModel.jid {
                    return false
                }
                
            } else {
                
                if jsonMessageModel.sender != self.chatListModel.jid && jsonMessageModel.receiver.contains(loginName) {
                    return false
                }
            }
            
        case .groupChat:
            guard let roomID = self.chatListModel.groupChat?.roomID, roomID == jsonMessageModel.roomID else {
                return false
            }
            
        case .channel:
            guard let roomID = self.chatListModel.channelChat?.roomID, roomID == jsonMessageModel.roomID else {
                return false
            }
        }
        
        
        
        return true
        
    }
    
    
    func getLastReceiveMessage() -> CODMessageModel? {
        
        return self.dataSources.first?.items.first(where: { (vm) -> Bool in
            if (vm.messageModel.type == .newMessage) {
                return false
            }
            
            return vm.messageModel.statusType == .Succeed
        }).map{ $0.messageModel }
        
    }
    
    
    func loadMessageFormShowedMessage() {
        if let lastReceiveMsg = self.getLastReceiveMessage() {
            
            self.getHistoryList(beginTime: "\(lastReceiveMsg.datetimeInt)", endTime: "0", updateRemoteLastMessage: false) { [weak self] (VMs) in
                
                guard let `self` = self else { return }
                
                var VMs = VMs
                
                if VMs.count > 0 {
                    VMs.removeLast()
                }
                
                self.insertChatCellVmsToBottom(cellVms: VMs)
                
                if let lastMessage = VMs.first?.messageModel,!lastMessage.isMeSend {
                    DDLogInfo("发送已读回执 getHistoryList (\(self.chatObj.jid))")
                    CODMessageSendTool.default.sendHaveReadMessage(messageModel: lastMessage)
                }
                
            }
            
        } else {
            
            
            
            self.getHistoryList(lastMessageId: "0", count: 20, checkBurn: false, insertShowNewMessageCell: false) { [weak self] (vms) in
                guard let `self` = self else { return }
                self.setChatCellVMs(cellVms: vms)
                if let lastMessage = vms.first?.messageModel {
                    DDLogInfo("发送已读回执 getHistoryList (\(self.chatObj.jid))")
                    CODMessageSendTool.default.sendHaveReadMessage(messageModel: lastMessage)
                }
            }
            
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didSend presence: XMPPPresence) {
        
        dispatch_async_safely_to_main_queue {
            
            XMPPManager.shareXMPPManager.getTopMsg(roomId: self.chatObj.chatId) { [weak self] topMessage in
                guard let `self` = self else { return }
                self.updateTopMsgBR.accept(topMessage)
            }
            
            self.loadMessageFormShowedMessage()
            
        }
        
    }
    
    func beforeSetRead(message: XMPPMessage) {
        
        guard let messageModel = XMPPManager.shareXMPPManager.xmppMessageToRealmMessage(message: message) else {
            return
        }
        
        if self.checkMessage(message: message) == false {
            return
        }
        
        if messageModel.type == .haveRead {
            self.updateReadMessage(lastTime: messageModel.text)
            return
        }
        
    }
    

    
    
}
