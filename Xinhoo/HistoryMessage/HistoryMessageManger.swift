//
//  HistoryMessageManger.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import SwifterSwift
import XMPPFramework
import SwiftDate

class HistoryMessageManger {
    
    static let `default` = HistoryMessageManger()
    
    
    let semaphore = DispatchSemaphore(value: 1)
    
    func getLocatImageAndVideoList(chatId: Int) -> [CODMessageModel] {
        
        guard let chatList = CODChatListRealmTool.getChatList(id: chatId), let chatHistory = chatList.chatHistory else {
            return []
        }
        
        return chatHistory.messages.filter("(msgType == \(EMMessageBodyType.image.rawValue) || msgType == \(EMMessageBodyType.video.rawValue) || msgType == \(EMMessageBodyType.multipleImage.rawValue))  && isDelete == \(false)")
            .sorted(byKeyPath: "datetimeInt", ascending: false)
            .toArray()
        
    }
    
    func getLocatFileImageList(chatId: Int) -> [CODMessageModel] {
        
        guard let chatList = CODChatListRealmTool.getChatList(id: chatId), let chatHistory = chatList.chatHistory else {
            return []
        }
        
        return chatHistory.messages.filter("(msgType == \(EMMessageBodyType.file.rawValue)) && isDelete == \(false)")
            .sorted(byKeyPath: "datetimeInt", ascending: true)
            .toArray()
        
    }
    
    func getLocatImageList(chatId: Int) -> [CODMessageModel] {
        
        guard let chatList = CODChatListRealmTool.getChatList(id: chatId), let chatHistory = chatList.chatHistory else {
            return []
        }
        
        return chatHistory.messages.filter("(msgType == \(EMMessageBodyType.image.rawValue) || msgType == \(EMMessageBodyType.multipleImage.rawValue))  && isDelete == \(false)")
            .sorted(byKeyPath: "datetimeInt", ascending: false)
            .toArray()
        
    }
    
    func getLocalHistoryList(chatId: Int, lastMessageId: String = "0", count: Int = 20) -> [CODMessageModel] {
        
        guard let chatList = CODChatListRealmTool.getChatList(id: chatId), let chatHistory = chatList.chatHistory else {
            return []
        }
        
        
//        let begainTime = Date().getTimeStamp().int!

        var messageList: Results<CODMessageModel>
        
        if let message = CODMessageRealmTool.getMessageByMsgId(lastMessageId), lastMessageId != "0" {
            
            messageList = chatHistory.messages.filter("isDelete == false && datetimeInt < \(message.datetimeInt)")
                .sorted(byKeyPath: "datetimeInt", ascending: false)
      

        } else {
            messageList = chatHistory.messages
                .filter("isDelete == false")
                .sorted(byKeyPath: "datetimeInt", ascending: false)
        }
        
//        let endTime = Date().getTimeStamp().int!

        
        var maxCount = count
        
        if messageList.count < maxCount {
            maxCount = messageList.count
        }
        
        if maxCount <= 0 {
            return []
        }
        
        let maxIndex = maxCount - 1
        
        var list: [CODMessageModel] = []
        
        for (index, value) in messageList.enumerated() {
            
            if index > maxIndex {
                break
            }
            
            list.append(value)
        }
        
//        let list = Array(messageList.toArray()[0...maxIndex])
        
//        if let last = list.last, let first = list.first {
//            CODChatListRealmTool.updateTimeFrame(id: chatId, beginTime: last.datetimeInt, endTime: first.datetimeInt)
//        }
        
        return list
        
        
    }
    
    func getLocalHistoryList(chatId: Int, beginTime: String, endTime: String) -> [CODMessageModel]  {
        
        guard let chatList = CODChatListRealmTool.getChatList(id: chatId), let chatHistory = chatList.chatHistory else {
            return []
        }
        
        var predicate = "isDelete == false AND datetimeInt >= \(beginTime) AND datetimeInt < \(endTime)"
        
        if endTime == "0" {
            predicate = "isDelete == false AND datetimeInt >= \(beginTime)"
        }
        
        let messageList = chatHistory.messages.filter(predicate)
        .sorted(byKeyPath: "datetimeInt", ascending: false)
        
        let list = messageList.toArray()
        
        return list
        
    }
    

    func getRemoteHistoryList(chatIds: [Int], complete: (() -> Void)?) {
        
        let semaphore = DispatchSemaphore(value: chatIds.count)
        
        for chatId in chatIds {
            
            self.getRemoteHistoryList(chatId: chatId) { (_, _, _) in
                semaphore.signal()
            }
            
        }
        
        semaphore.wait()
        complete?()

    }
    
    
    
    func getRemoteHistoryList(chatId: Int, beginTime: String, endTime: String, complete: (([CODMessageModel]) -> Void)?) {
        
        DispatchQueue.global().async {
            
            let beginDateTime = Date(milliseconds: beginTime.int ?? 0)
            let endDateTime = Date(milliseconds: endTime.int ?? 0)

            if endDateTime.daysSince(beginDateTime) > 1 {
                
                var loadBeginDateTime = (endDateTime - 1.days)
                var loadEndDateTime = endDateTime
                
               
                while loadBeginDateTime > beginDateTime {
                    
                    self.semaphore.wait()
                    self.getRemoteHistoryList(chatId: chatId, beginTime: "\(Int(loadBeginDateTime.timeIntervalSince1970 * 1000))", endTime: "\(Int(loadEndDateTime.timeIntervalSince1970 * 1000))") { (_) in
                        self.semaphore.signal()
                    }
                    
                    
                    
                    loadBeginDateTime = (loadBeginDateTime - 1.days)
                    loadEndDateTime = (loadEndDateTime - 1.days)
                }
                
                self.getRemoteHistoryList(chatId: chatId, lastPushTime: "\(Int(loadEndDateTime.timeIntervalSince1970 * 1000))", skipPushTime: "\(Int(loadBeginDateTime.timeIntervalSince1970 * 1000))") { [weak self] _, _, _ in
                    
                    guard let `self` = self else { return }

                    DispatchQueue.main.async {
                        let messages = self.getLocalHistoryList(chatId: chatId, beginTime: beginTime, endTime: endTime)
                        complete?(messages)
                    }
                    

                }


            } else {
                self.getRemoteHistoryList(chatId: chatId, lastPushTime: endTime, skipPushTime: beginTime) { (messages, _, _) in
                    complete?(messages)
                }
            }
            
        }
                
    }
    
    func getRemoteHistoryList(chatId: Int, lastPushTime: String = "\(Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)", skipPushTime: String? = nil, count: Int? = 20, complete: (([CODMessageModel], Bool, Bool) -> Void)?) {
        
//        if lastPushTime == "0" {
//            hadGetFormInitialInitChatList.insert(chatId)
//        }
        
        guard let chatList = CODChatListRealmTool.getChatList(id: chatId) else {
            DispatchQueue.main.async {
                complete?([], false, true)
            }
            return
        }
        
        var scope = chatList.chatTypeEnum.scope
        
        if chatId == CloudDiskRosterID {
            scope = "4"
        } else if chatId == RobotRosterID {
            scope = "3"
        }
        

        var params: [String: Any] = [
            "name": COD_getHistoryMessageByPaging,
            "requester": UserManager.sharedInstance.jid,
            "targeted": chatList.jid,
            "scope": scope,
            "lastPushTime": lastPushTime,
        ]
                
        if let count = count {
            params["rowsPerPage"] = count
        }
        
        if let skipPushTime = skipPushTime {
            params["skipPushTime"] = skipPushTime
        }
        
        if chatList.finalPushTime > 0 {
            params["finalPushTime"] = "\(chatList.finalPushTime)"
        }
        
        XMPPManager.shareXMPPManager.getRequest(param: params, xmlns: COD_com_xinhoo_groupChat) { [weak self] (result) in
            
            guard let `self` = self else { return }
            
            switch result {
                
            case .success(let model):
                
                DispatchQueue.realmWriteQueue.async {
                    
                    self.addToRealm(chatId: chatId, model: model)
                    
                    DispatchQueue.main.async {
                        let messageModels = self.jsonModelToMessageModels(model: model)
                        try! Realm().refresh()
                        complete?(messageModels, model.dataJson?["complete"].boolValue ?? false, false)
                    }

                }
                
            case .failure(_):
                complete?([], false, true)
                break
                
            }
            
        }
        
    }
    
    
    func addToRealm(chatId: Int, model: CODResponseModel) {
        
        let messageModels = self.jsonModelToMessageModels(model: model).filter { (model) -> Bool in
            return self.checkInsertToDB(model: model)
        }
        CODChatListRealmTool.addChatListMessages(id: chatId, messages: messageModels)
        CODChatListRealmTool.updateMessageHaveReaded(id: chatId)

    }
    
    func checkInsertToDB(model: CODMessageModel) -> Bool {
        
        if (model.type == .notification && model.text.count == 0) {
            return false
        }
        
        if model.type == .videoCall || model.type == .voiceCall {
            
            if model.videoCallModel?.videoCalltype == .request {
                return false
            }
            
        }

        if model.type == .haveRead {
            return false
        }
        
        return true
    }
    
    func jsonModelToMessageModels(model: CODResponseModel) -> [CODMessageModel] {
        
        guard let msgList = model.dataJson?["msgList"].array else {
            return []
        }
        
        return msgList.map { (msg) -> CODMessageModel? in
            guard let xmppMessage = try? XMPPMessage(xmlString: msg.stringValue) else { return nil }
            return XMPPManager.shareXMPPManager.xmppMessageToRealmMessage(message: xmppMessage)
        }
        .compactMap { $0 }
        .filter { (model) -> Bool in
            return self.checkInsertToDB(model: model)
        }
        .sorted(by: \.datetimeInt, ascending: false)

    }
    
    
    
}
