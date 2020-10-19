//
//  CODAutoResendMessageManger.swift
//  COD
//
//  Created by Sim Tsai on 2020/9/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import XMPPFramework


class CODAutoResendMessageManger: XMPPStreamDelegate {
    
    
    static let `default` = CODAutoResendMessageManger()
    
    /// 超时时间 30s
    let timeout: TimeInterval = 30 * 1000
    
    var timer: Timer?
    
    func setup() {
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: .messageQueue)
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (_) in

            
            DispatchQueue.autoResendMessageQueue.async {
                
                if UserManager.sharedInstance.isLogin != true {
                    return
                }
                
                let messages = CODResendMessageQModel.getNeedToResendMessages(qName: .paddingTimeOutResend, timeout: self.timeout)

                for messageModel in messages {
                    
                    if messageModel.statusType == .Succeed {
                        
                        CODRealmTools.getDB().writeAsync(obj: messageModel) { (_, model) in
                            CODResendMessageQModel.removeMessageFromQueue(qName: .paddingTimeOutResend, message: model)
                        }
                        
                        continue
                    }
                    
                    let model = messageModel.detached()

                    messageModel.setValue(\.resendDatetimeInt, value: Date.milliseconds.int + UserManager.sharedInstance.timeStamp)
                    (try? Realm())?.refresh()
                    DispatchQueue.autoResendMessageQueue.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        DDLogInfo("重发消息 message id: \(model.msgID)")
                        CODMessageSendTool.default.resendMessage(messageModel: model)
                    }
                    
                }

            }
        }

    }
    
    
    
    func xmppStream(_ sender: XMPPStream, willSend message: XMPPMessage) -> XMPPMessage? {
        
        guard let messageID = message.elementID else {
            return message
        }
        
        if let _ = CODResendMessageQModel.getMessageFromQueue(qName: .paddingTimeOutResend, messageID: messageID) {
            return message
        } else {
            
            if let messageModel = CODMessageRealmTool.getMessageByMsgId(messageID) {
                CODResendMessageQModel.addMessageToQueue(qName: .paddingTimeOutResend, message: messageModel)
            }
            
        }

        return message
        
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        
        guard let messageID = message.elementID else {
            return
        }
        
        if let messageModel = CODResendMessageQModel.getMessageFromQueue(qName: .paddingTimeOutResend, messageID: messageID) {
            
            CODRealmTools.getDB().writeAsync(obj: messageModel) { (_, model) in
                CODResendMessageQModel.removeMessageFromQueue(qName: .paddingTimeOutResend, message: model)
            }
            
//            CODResendMessageQModel.removeMessageFromQueue(qName: .paddingTimeOutResend, message: messageModel)
        }
        
    }
    
}
