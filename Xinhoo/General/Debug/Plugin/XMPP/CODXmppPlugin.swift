//
//  CODXmppPlugin.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/8.
//  Copyright © 2020 XinHoo. All rights reserved.
//
#if XINHOO
import UIKit
import EchoSDK
import XMPPFramework
import SwiftDate
import SwiftyJSON
import SwifterSwift

extension EMMessageBodyType {
    
    var string: String {
        
        switch self {
        case .audio:
            return "Audio"
        case .text:
            return "Text"
        case .image:
            return "Image"
        case .video:
            return "Video"
        case .voiceCall:
            return "Voice Call"
        case .location:
            return "Location"
        case .file:
            return "File"
        case .notification:
            return "Notification"
        case .haveRead:
            return "Have Read"
        case .businessCard:
            return "Business Card"
        case .videoCall:
            return "Video Call"
        case .gifMessage:
            return "Emoji Package"
        case .multipleImage:
            return "Multiple Image"
        default:
            return "Unknown"
        }
        
    }
    
}

class CODXmppPlugin: ECOBasePlugin, XMPPStreamDelegate {
    
    enum XmppType {
        case IQ(iq: XMPPIQ)
        case Message(message: XMPPMessage)
        
        var string: String {
            switch self {
            case .IQ(_):
                return "IQ"
            case .Message(_):
                return "Message"
            }
        }
        
    }
    
    enum Recode {
        case Send(value: XmppType)
        case Receive(value: XmppType)
        
        var string: String {
            switch self {
            case .Send(_):
                return "Send"
            case .Receive(_):
                return "Receive"
            }
        }
        
        var logData: [String: Any]? {
            
            var sendData: [String: Any] = [:]
            
            switch self {
            case .Send(value: let value), .Receive(value: let value):
                
                guard var listData = self.toListData(type: value) else {
                    return nil
                }
                
                
                
                
                let detail = toDetail(type: value)
                sendData["detail"] = detail
                
                listData["content"] = detail.trimmingCharacters(in: .newlines)
                
                sendData["list"] = listData
                
                
            }
            
            return sendData
        }
        
        var logDataToString: String {
                        
            switch self {
            case .Send(value: let value):
                return """
                
                ===============================================================
                Send \((value.string))
                \(toDetail(type: value))
                ===============================================================
                """
            
            case .Receive(value: let value):
                return """
                
                ===============================================================
                Receive \((value.string))
                \(toDetail(type: value))
                ===============================================================
                """
            }
        }
        
        func toListData(type: XmppType) -> [String: Any]? {
            
            switch type {
            case .IQ(iq: let iq):
                return self.toListData(iq: iq)
            case .Message(message: let message):
                return self.toListData(message: message)
            }
            
        }
        
        func toListData(message: XMPPMessage) -> [String: Any]? {
            
            guard let messageModel = XMPPManager.shareXMPPManager.xmppMessageToRealmMessage(message: message) else {
                return nil
            }
            
            let msgTime = Date(milliseconds: messageModel.datetimeInt).toFormat("yyyy-MM-dd HH:mm:ss.SSS")
            
            let listData = [
                "MssageID": message.elementID ?? "",
                "Time": msgTime,
                "Disection": self.string,
                "MessageType": messageModel.type.string
                ] as [String : Any]
            
            return listData
            
        }
        
        func toListData(iq: XMPPIQ) -> [String: Any]? {
            let msgTime = Date().toFormat("yyyy-MM-dd HH:mm:ss.SSS")
            
            let listData = [
                "MssageID": iq.elementID ?? "",
                "Time": msgTime,
                "Disection": self.string,
                "MessageType": "IQ"
                ] as [String : Any]
            
            return listData
        }
        
        func toDetail(type: XmppType) -> String {
            
            switch type {
            case .Message(message: let message):
                return toDetail(message: message)
            case .IQ(iq: let iq):
                return toDetail(iq: iq)
            }
            
        }
        
        func toDetail(message: XMPPMessage) -> String {
            
            guard let messageModel = XMPPManager.shareXMPPManager.xmppMessageToRealmMessage(message: message) else {
                return ""
            }
            
            let info = """
            XMPP Message:
            \(message)
            
            Body:
            \(message.body ?? "")
            
            Body JSON:
            \(JSON(parseJSON: message.body ?? "").dictionaryObject?.jsonString(prettify: true) ?? "")
            
            Message Model:
            \(messageModel)
            """
            
            return info
            
        }
        
        func toDetail(iq: XMPPIQ) -> String {
            
            let model = XMPPManager.shareXMPPManager.deserializeToResponseModel(iq: iq)
            
            let info = """
            
            IQ Name: \(model?.name ?? "")
            XMLNS: \(iq.xmlns() ?? "")
            
            XMPP IQ:
            \(iq)
            
            Action:
            \(model?.actionJson?.dictionaryObject?.jsonString(prettify: true) ?? "")
            
            Data:
            \(model?.dataJson?.dictionaryObject?.jsonString(prettify: true) ?? "")
            
            """
            
            return info
            
        }
        
        
        
    }
    
    
    override init() {
        super.init()
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: .messageQueue)
        
        self.name = "XMPP"
        
        self.registerTemplate(ECOUITemplateType_ListDetail, data: [
            ["name": "MssageID","weight": 0.3],
            ["name": "Disection","weight": 0.2],
            ["name": "MessageType","weight": 0.2],
            ["name": "Time","weight": 0.2],
            ["name": "content","weight": 0.1],
        ])
        
    }
    
    func recodeMsg(recode: CODXmppPlugin.Recode) {
        
        guard let sendData = recode.logData else {
            return
        }
        
        self.sendBlock(sendData)
        
        DDLogInfo(recode.logDataToString)
        
        
        
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        recodeMsg(recode: .Receive(value: .Message(message: message)))
    }
    
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        recodeMsg(recode: .Send(value: .Message(message: message)))
    }
    
    func xmppStream(_ sender: XMPPStream, didSend iq: XMPPIQ) {
        recodeMsg(recode: .Send(value: .IQ(iq: iq)))
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        recodeMsg(recode: .Receive(value: .IQ(iq: iq)))
        return true
    }
    
    
    
    
}
#endif
