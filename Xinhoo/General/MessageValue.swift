//
//  MessageValue.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/22.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import XMPPFramework


enum MessageValue {
    
    
    case value(sender: String = UserManager.sharedInstance.jid, receiver: String, chatType: ChatType)
    
    enum ChatType {
        case privateChat(action: MessageAction, jid: String)
        case groupChat(action: MessageAction, roomId: Int)
        case channel(action: MessageAction, roomId: Int)

        func createMessageModel() -> CODMessageModel {
            

            switch self {
            case .channel(action: let action, roomId: let roomId):
                let messageModel = action.createMessageModel()
                messageModel.roomId = roomId
                if let channelModel = CODChannelModel.getChannel(by: roomId) {
                    if channelModel.signmsg {
                        messageModel.n = UserManager.sharedInstance.nickname ?? ""
                    }
                }else{
                    messageModel.n = ""
                }
                
                messageModel.burn = CODChannelModel.getChannel(by: roomId)?.burn.int ?? 0
                
                return messageModel
                
            case .groupChat(action: let action, roomId: let roomId):
                let messageModel = action.createMessageModel()
                messageModel.roomId = roomId
                messageModel.burn = CODGroupChatRealmTool.getGroupChat(id: roomId)?.burn.int ?? 0
                
                return messageModel
                
            case .privateChat(action: let action, jid: let jid):
                let messageModel = action.createMessageModel()
                messageModel.burn = CODContactRealmTool.getContactByJID(by: jid)?.burn ?? 0
                return messageModel
                
            }
            

        }
                    
        var value: Int {
            
            switch self {
            case .privateChat(action: _):
                return CODMessageChatType.privateChat.intValue
            case .groupChat(action: _):
                return CODMessageChatType.groupChat.intValue
            case .channel(action: _):
                return CODMessageChatType.channel.intValue
            }
            
        }
        
        var chatTypeStr: String {
            
            switch self {
            case .privateChat(action: _):
                return CODMessageChatType.privateChat.chatTypeStr
            case .groupChat(action: _):
                return CODMessageChatType.groupChat.chatTypeStr
            case .channel(action: _):
                return CODMessageChatType.channel.chatTypeStr
            }
            
        }
        
        var chatTypeValue: CODMessageChatType {
            switch self {
            case .privateChat(action: _):
                return CODMessageChatType.privateChat
            case .groupChat(action: _):
                return CODMessageChatType.groupChat
            case .channel(action: _):
                return CODMessageChatType.channel
            }
        }
        
    }
    
    enum MessageAction {
        case send(messageType: MessageType)
        case rp(messageId: String, messageType: MessageType)
        case fw(message: CODMessageModel)
        
        func createMessageModel() -> CODMessageModel {
            
            let messageModel = CODMessageModel()
            
            switch self {
            case .fw(message: let message):
                let messageModel = CODMessageModel(value: messageModel)
                messageModel.fwf = message.chatTypeEnum.fwf
                
                switch message.chatTypeEnum {
                case .channel:
                    let channelModel = CODChannelModel.getChannel(by: message.roomId)
                    messageModel.fwn = channelModel?.getGroupName() ?? ""
                    messageModel.fw = channelModel?.jid ?? ""
                    
                case .groupChat:
                    let groupChat = CODGroupChatRealmTool.getGroupChat(id: message.roomId)
                    messageModel.fwn = groupChat?.getGroupName() ?? ""
                    messageModel.fw = groupChat?.jid ?? ""
                    
                case .privateChat:
                    let contact = CODContactRealmTool.getContactByJID(by: message.fromJID)
                    messageModel.fwn = contact?.nick ?? ""
                    messageModel.fw = contact?.jid ?? ""
                }
                
                return messageModel
            case .rp(messageId: let messageId, messageType: let messageType):
                let messageModel = messageType.createMessageModel()
                messageModel.rp = messageId
            case .send(messageType: let messageType):
                return messageType.createMessageModel()
            }
            
            return messageModel
            
        }
        
    }
    
    
    
    enum MessageType {
        case multipleImage(images: [UploadTool.ImageInfo])
        
        func createMessageModel() -> CODMessageModel {
            
            let messageModel = CODMessageModel()
            
            switch self {
            case .multipleImage(images: let images):
                messageModel.type = .multipleImage
                for imageInfo in images {
                    messageModel.imageList.append(PhotoModelInfo.createModel(imageInfo: imageInfo))
                }

            }
            
            return messageModel
            
        }
        
    }
    
    
    func createMessageModel() -> CODMessageModel {
        
        
        switch self {
        case .value(sender: let sender, receiver: let receiver, chatType: let chatType):
            
            let messageModel = chatType.createMessageModel()
            
            messageModel.chatTypeEnum = chatType.chatTypeValue
            messageModel.fromJID = sender
            messageModel.fromWho = sender
            messageModel.toJID = receiver
            messageModel.toWho = receiver
            messageModel.datetimeInt = Date.milliseconds.int + UserManager.sharedInstance.timeStamp
            messageModel.datetime = messageModel.datetimeInt.string
            messageModel.statusType = CODMessageStatus.Pending
            messageModel.msgID = UserManager.sharedInstance.getMessageId()
            
            return messageModel
        }
        
        
        
        
    }
}
