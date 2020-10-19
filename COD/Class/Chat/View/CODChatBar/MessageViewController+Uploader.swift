//
//  MessageViewController+Uploader.swift
//  COD
//
//  Created by 1 on 2019/3/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension MessageViewController{
   
    func judgeIsSendHaveReadMsg(lastMessage: CODMessageModel,chatLastReadTime: String) {

        //1.先判断最后一条消息是不是来自于自己 是就判断时间 不是就更新自己的状态全部标志成为已读
        let fromWho = lastMessage.fromWho
        let me = UserManager.sharedInstance.loginName
        var fromMe = false

        if !fromWho.contains(me!) {
           fromMe = false
        }else{
           fromMe = true
        }

        if fromMe { //是就判断时间
            let timestr =  Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
            if let unReadMessages = CODChatHistoryRealmTool.getChatHistoryMessage(from: self.chatId, lastMessageTime: timestr, isRead: false), unReadMessages.count > 0{
                dispatch_async_safely_to_main_queue({[weak self] in
                    for model in unReadMessages {
                        if chatLastReadTime.int ?? 0 >= model.datetime.int ?? 0 || self?.isCloudDisk ?? false || self?.toJID.contains("cod_60000000") ?? false{
                            CODMessageRealmTool.updateMessageHaveReadedByMsgId(model.msgID, isReaded: true)
//                            self?.messageView.updateMeassage = model
                        }
                    }
                })
                
            }
//            if lastMessage.datetime.int ?? 0 > chatLastReadTime.int ?? 0 {
//                self.remainingSeconds = -1
//                self.sendHaveReadedMessage(messageModel: lastMessage)
//            }
            
        }else{ //将此会话列表里面的数据全部标志成为已读
        
            let timestr =  Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
        
            if let unReadMessages = CODChatHistoryRealmTool.getChatHistoryMessage(from: self.chatId, lastMessageTime: timestr, isRead: false), unReadMessages.count > 0{
                dispatch_async_safely_to_main_queue({[weak self] in
                    for model in unReadMessages {
                        if chatLastReadTime.int ?? 0 >= model.datetime.int ?? 0 || self?.isCloudDisk ?? false || self?.toJID.contains("cod_60000000") ?? false{
                            CODMessageRealmTool.updateMessageHaveReadedByMsgId(model.msgID, isReaded: true)
//                            self?.messageView.updateMeassage = model
                        }
                    }
                })
                
            }
            self.remainingSeconds = -1
            self.sendHaveReadedMessage(messageModel: lastMessage)
        }
    }
  
}
extension MessageViewController{
    
    func updateReadMessage(lastTime: String?) {
        
        var lastMessageTime = lastTime?.int ?? 0
        
        if self.isCloudDisk {
            lastMessageTime = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
        }
        
        if let unReadMessages = CODChatHistoryRealmTool.getChatHistoryMessage(from: self.chatId, lastMessageTime: lastMessageTime, isRead: false), unReadMessages.count > 0{
            print("进来了") 
            dispatch_async_safely_to_main_queue({[weak self] in
                for model in unReadMessages {
//                    if lastTime?.int ?? 0 > model.datetime.int ?? 0 {
                        CODMessageRealmTool.updateMessageHaveReadedByMsgId(model.msgID, isReaded: true)
                        self?.messageView.updateMeassage = model
//                    }
                }
                
            })
        }
    }
    
    func sendHaveReadedMessage(messageModel: CODMessageModel) {
        
        let fromWho = messageModel.fromWho
        let me = UserManager.sharedInstance.loginName
        if !fromWho.contains(me!) {
            if self.remainingSeconds <= 0 {
                if !self.isCloudDisk || !self.toJID.contains("cod_60000000") {
                    CODMessageSendTool.default.sendHaveReadMessage(messageModel: messageModel)
                }
                lastMessage = messageModel
                self.timeIsCounting(isBegin: true)
            }
        }
    }
    
    //倒计时完成之后是不是需要发送已读的回执消息
    func compareAndSendHaveReadMessage() {
        
//        let chatModel = try! Realm.init().object(ofType: CODChatListModel.self, forPrimaryKey: self.chatId)
//
//        if self.isGroupChat {
//            var lastModel = self.lastMessage
//            if lastModel?.isInvalidated ?? false{
//                lastModel = self.messageList.lastObject as? CODMessageModel
//            }
//            
//            if chatModel?.lastReadTime.int ?? 0 < lastModel?.datetime.int ?? 0{
//                if !self.isCloudDisk {
//                    CODMessageSendTool.default.sendHaveReadMessage(messageModel: lastModel ?? CODMessageModel())
//                }
//            }
//            return
//        }
//        
//        if let model = self.messageList.lastObject as? CODMessageModel {
//            
//            if model.isInvalidated || lastMessage?.isInvalidated ?? false{
//                return
//            }
//            let fromWho = model.fromWho
//            let me = UserManager.sharedInstance.loginName
//            if !fromWho.contains(me!) {
//                if lastMessage?.datetime.int ?? 0 <= model.datetime.int ?? 0{
//                    if !self.isCloudDisk {
//                        CODMessageSendTool.default.sendHaveReadMessage(messageModel: model)
//                    }
//                }
//            }
//        }
    }
    
}

extension MessageViewController{
    // 倒计时
    func timerRemainingSeconds(seconds:Int) -> () {
        if seconds == 0 {
            isCounting = false
            self.compareAndSendHaveReadMessage()
        }
    }
    
    // 创建/销毁定时器
    func timeIsCounting(isBegin:Bool) -> () {
        if isBegin {
            
            countdownTimer?.invalidate()
            countdownTimer = nil
            
            countdownTimer = Timer.scheduledTimer(timeInterval: 1,
                                                  target: self,
                                                  selector: #selector(self.updateTime),
                                                  userInfo: nil,
                                                  repeats: true)
            remainingSeconds = 2
            
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }
    
    @objc private func updateTime() {
        remainingSeconds -= 1
    }
}
