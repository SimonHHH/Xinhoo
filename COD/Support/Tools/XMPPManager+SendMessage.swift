//
//  XMPPManager+SendMessage.swift
//  COD
//
//  Created by 1 on 2019/3/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework
import SwiftyJSON

extension CODMessageChatType {
    var chatTypeStr: String {
        get {
            switch self {
            case .channel,.groupChat:
                //                return "groupchat"
                return "chat"
            case .privateChat:
                return "chat"
            }
        }
    }
}

extension CODMessageChatType {
    
    var uploadType: String {
        
        switch self {
        //TODO: 频道对应处理
        case .groupChat:
            return "Group"
        case .channel:
            return "Channel"
        case .privateChat:
            return "Single"
        }
        
    }
    
}

extension XMPPManager {
    
    //发送文字消息
    func sendEmojiMessageTo(toJID :String, sender: String = UserManager.sharedInstance.jid, msgType: String, messageID: String,rp: String?,fw: String?,fwn: String?,messageStr :String, chatType : CODMessageChatType, roomId :String?,referTo:List<String>,burn: Int,fwf: String,n: String, itemID: String?, smsgID: String?) {
        ///创建目的用户的jid
        let jid = XMPPJID(string: toJID, resource: nil)
        
        ///创建消息
        
        let message = XMPPMessage(type: chatType.chatTypeStr, to: jid, elementID: messageID)
        let sendTime = String(format: "%.0f", Date.milliseconds)
        
        
        var referToArr = Array<String>()
        for memberJid in referTo {
            referToArr.append(memberJid)
        }
        
        let encript = messageStr
        ///添加消息内容
        var messageBody = ["msgType": Int(msgType) ?? 1,
                           "burn":burn,
                           "sendTime":sendTime,
                           "body":encript,
                           "sender":sender,
                           "fwf":fwf,
                           "n":n,
                           "l":messageStr.isContainsURL(),
                           "chatType":chatType.rawValue.int ?? 1,
                           "referTo":referToArr] as [String : Any]
        if chatType == .groupChat || chatType == .channel {
            messageBody["roomID"] = roomId?.int ?? 0
        }
        if rp != nil {
            messageBody["rp"] = rp
        }
        if fw?.removeAllSapce.count ?? 0 > 0 {
            messageBody["fw"] = fw
        }
        if fwn?.removeAllSapce.count ?? 0 > 0  {
            messageBody["fwn"] = fwn
        }
        
        if let itemID = itemID {
            messageBody["itemID"] = itemID
        }
        if let smsgID = smsgID {
            messageBody["smsgID"] = smsgID
        }
        
        messageBody["receiver"] = toJID
        message.addBody(messageBody.jsonString()!)
        
        ///发送消息
        xmppStream.send(message)
    }
    
    //发送文字消息
    func sendTextMessageTo(toJID :String, sender: String = UserManager.sharedInstance.jid, msgType: String, messageID: String,rp: String?,fw: String?,fwn: String?,messageStr :String, chatType : CODMessageChatType, roomId :String?,referTo:List<String>,burn: Int,fwf: String,n: String, itemID: String?, smsgID: String?, entities:List<CODAttributeTextModel>? = nil) {
        ///创建目的用户的jid
        let jid = XMPPJID(string: toJID, resource: nil)
        
        ///创建消息
        let message = XMPPMessage(type: chatType.chatTypeStr, to: jid, elementID: messageID)
        let sendTime = String(format: "%.0f", Date.milliseconds)
        
        
        var referToArr = Array<String>()
        for memberJid in referTo {
            referToArr.append(memberJid)
        }
        
        let encript = AES128.aes128EncryptECB(messageStr)
        ///添加消息内容
        
        /// 是否是链接
        var l = messageStr.isContainsURL()
        
        let entitiesArr = entities?.toArrayJSON() ?? []
        
        if entities?.hasLink() ?? false {
            l = 1
        }
                
        var messageBody = ["msgType": Int(msgType) ?? 1,
                           "burn":burn,
                           "sendTime":sendTime,
                           "body":encript,
                           "sender":sender,
                           "fwf":fwf,
                           "n":n,
                           "l":l,
                           "chatType":chatType.rawValue.int ?? 1,
                           "referTo":referToArr,
                           "entities":entitiesArr] as [String : Any]
        
        if let itemID = itemID {
            messageBody["itemID"] = itemID
        }
        if let smsgID = smsgID {
            messageBody["smsgID"] = smsgID
        }
        
        if messageStr.firstCharacterAsString == "/" {
            messageBody["robot"] = 1
            if let roomIdInt = roomId?.int {
                
                let member = CODGroupMemberRealmTool.getMember(roomId: roomIdInt, jid: UserManager.sharedInstance.loginName ?? "")
                
                messageBody["allname"] = member?.getTheGroupNickName() ?? UserManager.sharedInstance.nickname ?? ""
                
            } else {
                messageBody["allname"] = UserManager.sharedInstance.nickname ?? ""
            }
            
            
        }
        
        if chatType == .groupChat || chatType == .channel {
            messageBody["roomID"] = roomId?.int ?? 0
        }
        
        if rp != nil {
            messageBody["rp"] = rp
        }
        if fw?.removeAllSapce.count ?? 0 > 0 {
            messageBody["fw"] = fw
        }
        if fwn?.removeAllSapce.count ?? 0 > 0  {
            messageBody["fwn"] = fwn
        }
        messageBody["receiver"] = toJID
        message.addBody(messageBody.jsonString()!)
        
        ///发送消息
        xmppStream.send(message)
    }
    
    //图片
    func sendPhotoMessageTo(toJID :String, sender: String = "\(UserManager.sharedInstance.jid)", msgType: String,messageID: String,rp: String?,fw: String?,fwn: String?, pictrueString :String,filename :String, chatType : CODMessageChatType, ishdimg:Bool, w:Int, h:Int, size:Int,description:String = "", roomId :String?,referTo:List<String>,burn: Int,fwf: String,n: String, itemID: String?, smsgID: String?, entities:List<CODAttributeTextModel>? = nil) {
        ///创建目的用户的jid
        let jid = XMPPJID(string: toJID, resource: nil)
        
        ///创建消息
        let message = XMPPMessage(type: chatType.chatTypeStr, to: jid, elementID: messageID)
        let sendTime = String(format: "%.0f", Date.milliseconds)
        //        setting"":{"ishdimg":true,"description":"描述内容","w":100,"h":230}
        let setting = ["ishdimg":(ishdimg ? true : false),"description":AES128.aes128EncryptECB(description),"w":w,"h":h,"filename":filename,"size":size] as [String : Any]
        var referToArr = Array<String>()
        for memberJid in referTo {
            referToArr.append(memberJid)
        }
        
        /// 是否是链接
        var l = pictrueString.isContainsURL()
        
        
        let entitiesArr = entities?.toArrayJSON() ?? []
        
        if entities?.hasLink() ?? false {
            l = 1
        }
        ///添加消息内容
        var messageBody = ["msgType": Int(msgType) ?? 2,
                           "burn":burn,
                           "sendTime":sendTime,
                           "body":pictrueString,
                           "setting":setting,
                           "sender":sender,
                           "fwf":fwf,
                           "n":n,
                           "chatType":chatType.rawValue.int ?? 1,
                           "l":l,
                           "entities":entitiesArr,
                           "referTo":referToArr] as [String : Any]
        
        if let itemID = itemID {
            messageBody["itemID"] = itemID
        }
        if let smsgID = smsgID {
            messageBody["smsgID"] = smsgID
        }
        
        if chatType == .groupChat || chatType == .channel {
            messageBody["roomID"] = roomId?.int ?? 0
            messageBody["receiver"] = toJID
        }else{
            messageBody["receiver"] = toJID
        }
        if rp != nil {
            messageBody["rp"] = rp
        }
        if fw?.removeAllSapce.count ?? 0 > 0 {
            messageBody["fw"] = fw
        }
        if fwn?.removeAllSapce.count ?? 0 > 0  {
            messageBody["fwn"] = fwn
        }
        message.addBody(messageBody.jsonString()!)
        
        ///发送消息O
        xmppStream.send(message)
    }
    
    func sendFile(toJID :String, sender: String = "\(UserManager.sharedInstance.jid)", msgType: String,messageID: String,rp: String?,fw: String?,fwn: String?, fileID :String,filename :String,size :Int,description :String,thumb: String, chatType : CODMessageChatType, roomId: String?,referTo:List<String>,burn: Int,fwf: String,n: String, itemID: String?, smsgID: String?) {
        ///创建目的用户的jid
        let jid = XMPPJID(string: toJID, resource: nil)
        
        ///创建消息
        let message = XMPPMessage(type: chatType.chatTypeStr, to: jid, elementID: messageID)
        let sendTime = String(format: "%.0f", Date.milliseconds)
        
        let setting = ["filename":filename,
                       "size":size,
                       "description":AES128.aes128EncryptECB(description),
                       "thumb":thumb
            ] as [String : Any]
        var referToArr = Array<String>()
        for memberJid in referTo {
            referToArr.append(memberJid)
        }
        ///添加消息内容
        var messageBody = ["msgType": Int(msgType) ?? 11,
                           "burn":burn,
                           "body":fileID,
                           "sendTime":sendTime,
                           "setting":setting,
                           "sender":sender,
                           "fwf":fwf,
                           "n":n,
                           "chatType":chatType.rawValue.int ?? 1,
                           "referTo":referToArr] as [String : Any]
        
        if let itemID = itemID {
            messageBody["itemID"] = itemID
        }
        if let smsgID = smsgID {
            messageBody["smsgID"] = smsgID
        }

        if chatType == .groupChat || chatType == .channel {
            messageBody["roomID"] = roomId?.int ?? 0
            messageBody["receiver"] = toJID
        }else{
            messageBody["receiver"] = toJID
        }
        if rp != nil {
            messageBody["rp"] = rp
        }
        if fw?.removeAllSapce.count ?? 0 > 0 {
            messageBody["fw"] = fw
        }
        if fwn?.removeAllSapce.count ?? 0 > 0  {
            messageBody["fwn"] = fwn
        }
        message.addBody(messageBody.jsonString()!)
        
        ///发送消息
        xmppStream.send(message)
    }
    //位置名片
    func sendCards(toJID :String, sender: String = "\(UserManager.sharedInstance.jid)", msgType: String,messageID: String,rp: String?,fw: String?,fwn: String?, username :String,name :String,userdesc :String,userpic :String,jidString : String,gender: String, chatType : CODMessageChatType, roomId: String?,referTo:List<String>,burn: Int,fwf: String,n: String,description:String = "", itemID: String?, smsgID: String?) {
        ///创建目的用户的jid
        let jid = XMPPJID(string: toJID, resource: nil)
        
        ///创建消息
        let message = XMPPMessage(type: chatType.chatTypeStr, to: jid, elementID: messageID)
        let sendTime = String(format: "%.0f", Date.milliseconds)
        
        let setting = ["username":username,
                       "name":name,
                       "userdesc":userdesc,
                       "jid":jidString,
                       "gender":gender,
                       "description":AES128.aes128EncryptECB(description),
                       "userpic":userpic] as [String : Any]
        
        var referToArr = Array<String>()
        for memberJid in referTo {
            referToArr.append(memberJid)
        }
        ///添加消息内容
        var messageBody = ["msgType": Int(msgType) ?? 11,
                           "burn":burn,
                           "body":username,
                           "sendTime":sendTime,
                           "setting":setting,
                           "sender":sender,
                           "fwf":fwf,
                           "n":n,
                           "chatType":chatType.rawValue.int ?? 1,
                           "referTo":referToArr] as [String : Any]
        
        if let itemID = itemID {
            messageBody["itemID"] = itemID
        }
        if let smsgID = smsgID {
            messageBody["smsgID"] = smsgID
        }
        
        if chatType == .groupChat || chatType == .channel {
            messageBody["roomID"] = roomId?.int ?? 0
            messageBody["receiver"] = toJID
        }else{
            messageBody["receiver"] = toJID
        }
        if rp != nil {
            messageBody["rp"] = rp
        }
        if fw?.removeAllSapce.count ?? 0 > 0 {
            messageBody["fw"] = fw
        }
        if fwn?.removeAllSapce.count ?? 0 > 0  {
            messageBody["fwn"] = fwn
        }
        message.addBody(messageBody.jsonString()!)
        
        ///发送消息
        xmppStream.send(message)
    }
    
    //位置信息
    func sendLocationMessageTo(toJID :String, sender: String = "\(UserManager.sharedInstance.jid)", msgType: String, messageID: String,rp: String?,fw: String?,fwn: String?, lngString :String,latString :String,titleString :String,subtitleString :String,pictrueString :String, chatType : CODMessageChatType, roomId: String?,referTo:List<String>,burn: Int,fwf: String,n: String,description:String = "", itemID: String?, smsgID: String?) {
        ///创建目的用户的jid
        let jid = XMPPJID(string: toJID, resource: nil)
        
        ///创建消息
        let message = XMPPMessage(type: chatType.chatTypeStr, to: jid, elementID: messageID)
        let setting = ["lng":lngString,"lat":latString,"title":titleString,"subtitle":subtitleString]
        let sendTime = String(format: "%.0f", Date.milliseconds)
        var referToArr = Array<String>()
        for memberJid in referTo {
            referToArr.append(memberJid)
        }
        ///添加消息内容
        var messageBody = ["msgType": Int(msgType) ?? 6,
                           "burn":burn,
                           "setting": setting,
                           "sendTime":sendTime,
                           "body":pictrueString,
                           "sender":sender,
                           "fwf":fwf,
                           "n":n,
                           "chatType":chatType.rawValue.int ?? 1,
                           "description":AES128.aes128EncryptECB(description),
                           "referTo":referToArr] as [String : Any]
        
        if let itemID = itemID {
            messageBody["itemID"] = itemID
        }
        if let smsgID = smsgID {
            messageBody["smsgID"] = smsgID
        }
        
        if chatType == .groupChat || chatType == .channel {
            messageBody["roomID"] = roomId?.int ?? 0
            messageBody["receiver"] = toJID
        }else{
            messageBody["receiver"] = toJID
        }
        if rp != nil {
            messageBody["rp"] = rp
        }
        if fw?.removeAllSapce.count ?? 0 > 0 {
            messageBody["fw"] = fw
        }
        if fwn?.removeAllSapce.count ?? 0 > 0  {
            messageBody["fwn"] = fwn
        }
        message.addBody(messageBody.jsonString()!)
        
        ///发送消息
        xmppStream.send(message)
    }
    
    //视频信息
    func sendVideoMessageTo(toJID :String, sender: String = "\(UserManager.sharedInstance.jid)", msgType: String,messageID: String,rp: String?,fw: String?,fwn: String?, duration:Int,videoString :String,firstpicString :String, chatType : CODMessageChatType, roomId: String?,referTo:List<String>,burn: Int,fwf: String,n: String, w:Int, h:Int,description:String = "",size:Int,entities:List<CODAttributeTextModel>? = nil, itemID: String?, smsgID: String?) {
        
        ///创建目的用户的jid
        let jid = XMPPJID(string: toJID, resource: nil)
        
        ///创建消息
        let message = XMPPMessage(type: chatType.chatTypeStr, to: jid, elementID: messageID)
        
        let setting = ["firstpic":firstpicString,
                       "duration":duration,"description":AES128.aes128EncryptECB(description),"w":w,"h":h,"size":size] as [String : Any]
        let sendTime = String(format: "%.0f", Date.milliseconds)
        var referToArr = Array<String>()
        for memberJid in referTo {
            referToArr.append(memberJid)
        }
        ///添加消息内容
        var messageBody = ["msgType": Int(msgType) ?? 4,
                           "burn":burn,
                           "body":videoString,
                           "setting":setting,
                           "sendTime":sendTime,
                           "sender":sender,
                           "fwf":fwf,
                           "n":n,
                           "chatType":chatType.rawValue.int ?? 1,
                           "description":AES128.aes128EncryptECB(description),
                           "referTo":referToArr] as [String : Any]
        
        if let itemID = itemID {
            messageBody["itemID"] = itemID
        }
        if let smsgID = smsgID {
            messageBody["smsgID"] = smsgID
        }
        
        if chatType == .groupChat || chatType == .channel {
            messageBody["roomID"] = roomId?.int ?? 0
            messageBody["receiver"] = toJID
        }else{
            messageBody["receiver"] = toJID
        }
        if rp != nil {
            messageBody["rp"] = rp
        }
        if fw?.removeAllSapce.count ?? 0 > 0 {
            messageBody["fw"] = fw
        }
        if fwn?.removeAllSapce.count ?? 0 > 0  {
            messageBody["fwn"] = fwn
        }
        message.addBody(messageBody.jsonString()!)
        
        ///发送消息
        xmppStream.send(message)
    }
    
    //语音电话信息
    func sendVideoCallMessageTo(toJID :String, sender: String = "\(UserManager.sharedInstance.jid)", msgType: String,messageID: String,rp: String?,fw: String?,fwn: String?, duration:Int,videoType:String,room:String, chatType : CODMessageChatType, roomId: String?,referTo:List<String>,burn: Int,fwf: String,n: String) {
        ///创建目的用户的jid
        let jid = XMPPJID(string: toJID, resource: nil)
        
        ///创建消息
        let message = XMPPMessage(type: chatType.chatTypeStr, to: jid, elementID: messageID)
        var setting = ["room":room] as [String : Any]
        if duration > 0{
            setting["duration"] = duration
        }
        let sendTime = String(format: "%.0f", Date.milliseconds)
        var referToArr = Array<String>()
        for memberJid in referTo {
            referToArr.append(memberJid)
        }
        ///添加消息内容
        var messageBody = ["msgType": Int(msgType) ?? 5,
                           "burn":burn,
                           "body":videoType,
                           "setting":setting,
                           "sender":sender,
                           "fwf":fwf,
                           "n":n,
                           "sendTime":sendTime,
                           "chatType":chatType.rawValue.int ?? 1,
                           "referTo":referToArr] as [String : Any]
        if chatType == .groupChat || chatType == .channel {
            messageBody["roomID"] = roomId?.int ?? 0
            messageBody["receiver"] = toJID
        }else{
            messageBody["receiver"] = toJID
        }
        if rp != nil {
            messageBody["rp"] = rp
        }
        if fw?.removeAllSapce.count ?? 0 > 0 {
            messageBody["fw"] = fw
        }
        if fwn?.removeAllSapce.count ?? 0 > 0  {
            messageBody["fwn"] = fwn
        }
        message.addBody(messageBody.jsonString()!)
        
        ///发送消息
        xmppStream.send(message)
    }
    //语音信息
    func sendVoiceMessageTo(toJID :String, sender: String = "\(UserManager.sharedInstance.jid)", msgType: String,messageID: String,rp: String?,fw: String?,fwn: String?, duration:Int,voiceString :String, chatType : CODMessageChatType, roomId: String?,referTo:List<String>,burn: Int,fwf: String,n: String,description:String = "",size:Int, itemID: String?, smsgID: String?) {
        ///创建目的用户的jid
        let jid = XMPPJID(string: toJID, resource: nil)
        
        ///创建消息
        let message = XMPPMessage(type: chatType.chatTypeStr, to: jid, elementID: messageID)
        let setting = ["duration":duration,"description":AES128.aes128EncryptECB(description),"size":size] as [String : Any]
        
        let sendTime = String(format: "%.0f", Date.milliseconds)
        var referToArr = Array<String>()
        for memberJid in referTo {
            referToArr.append(memberJid)
        }
        ///添加消息内容
        var messageBody = ["msgType": Int(msgType) ?? 3,
                           "burn":burn,
                           "body":voiceString,
                           "setting":setting,
                           "sendTime":sendTime,
                           "sender":sender,
                           "fwf":fwf,
                           "n":n,
                           "chatType":chatType.rawValue.int ?? 1,
                           "referTo":referToArr] as [String : Any]
        
        if let itemID = itemID {
            messageBody["itemID"] = itemID
        }
        if let smsgID = smsgID {
            messageBody["smsgID"] = smsgID
        }
        
        if chatType == .groupChat || chatType == .channel {
            messageBody["roomID"] = roomId?.int ?? 0
            messageBody["receiver"] = toJID
            messageBody["setting"] = ["duration":duration,"description":AES128.aes128EncryptECB(description),"size":size] as [String : Any]
        }else{
            messageBody["receiver"] = toJID
        }
        if rp != nil {
            messageBody["rp"] = rp
        }
        if fw?.removeAllSapce.count ?? 0 > 0 {
            messageBody["fw"] = fw
        }
        if fwn?.removeAllSapce.count ?? 0 > 0  {
            messageBody["fwn"] = fwn
        }
        message.addBody(messageBody.jsonString()!)
        
        ///发送消息
        xmppStream.send(message)
    }
    
    //已读的回执消息发送
    func sendHaveReadMessageTo(toJID :String, sender: String = "\(UserManager.sharedInstance.jid)",msgType: String,messageID: String,lastMessageTime :String, chatType : CODMessageChatType, roomId: String?) {
        ///创建目的用户的jid
        let jid = XMPPJID(string: toJID, resource: nil)
        
        ///创建消息
        let message = XMPPMessage(type: chatType.chatTypeStr, to: jid, elementID: messageID)
        
        let sendTime = String(format: "%.0f", Date.milliseconds)
        
        ///添加消息内容
        var messageBody = ["msgType": Int(msgType) ?? 10,
                           "burn":0,
                           "body":lastMessageTime,
                           "sendTime":sendTime,
                           "sender":sender,
                           "chatType":chatType.rawValue.int ?? 1] as [String : Any]
        if chatType == .groupChat || chatType == .channel {
            messageBody["roomID"] = roomId?.int ?? 0
            messageBody["receiver"] = toJID
        }else{
            messageBody["receiver"] = toJID
        }
        message.addBody(messageBody.jsonString()!)
        
        ///发送消息
        xmppStream.send(message)
    }
    
    /// 发送多媒体消息
    ///
    /// - Parameters:
    ///   - userName: 对方UserName
    ///   - fileId: 上传文件后返回的文件ID
    ///   - type: 发送的消息类型
    func sendMultiMessageTo(userName :String ,fileId :String ,type :MultiMessageType) {
        ///创建目的用户的jid
        let jid = XMPPJID(string: userName, resource: nil)
        
        ///创建消息
        let message = XMPPMessage(type: "chat", to: jid)
        
        ///添加消息内容
        message.addBody(fileId)
        message.addBody(type.description, withLanguage: "msgtype")
        
        ///发送消息
        xmppStream.send(message)
    }
    
    
    /// 发送输入的状态
    ///
    /// - Parameter userName: 对方UserName
    func sendChatStateTo(userName :String, chatState: XMPPMessage.ChatState) {
        let message = XMPPMessage(type: "chat", to: XMPPJID(string: userName, resource: nil))
        message.addChatState(chatState)
        xmppStream.send(message)
    }
    
    
}
