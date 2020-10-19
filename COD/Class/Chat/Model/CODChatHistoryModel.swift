//
//  CODChatHistoryModel.swift
//  COD
//
//  Created by XinHoo on 2019/3/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RealmSwift

class CODChatHistoryModel: Object {
    
    /// 如果是单聊，id就是联系人的ID。否则id就是群ID
    @objc dynamic var id = 0
    
    let messages = List<CODMessageModel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}

// 操作数据库
class CODChatHistoryRealmTool: CODRealmTools {
//    public class func insertMessageWithoutChatModel(by chatId: Int, messageModel: CODMessageModel) {
//        if let historyModel = CODChatHistoryRealmTool.getChatHistory(from: chatId) {
//            try! Realm().write {
//                historyModel.messages.append(messageModel)
//            }
//        }else{
//            let historyModel = CODChatHistoryModel()
//            historyModel.id = messageModel.roomId
//            historyModel.messages.append(messageModel)
//            try! Realm().write {
//                try! Realm.init().add(historyModel)  //找不到群，先加入
//            }
//        }
//    }
    
    /// 增加更新聊天记录
    public class func insertChatHistory(by chatHistory : CODChatHistoryModel) -> Void {
        let defaultRealm = self.getDB()
        
        try! defaultRealm.write {
            defaultRealm.add(chatHistory, update: .all)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
    
    /// 查询某ID(联系人或群)聊天记录
    public class func getChatHistory(from id : Int) -> CODChatHistoryModel? {
        let defaultRealm = self.getDB()
        return defaultRealm.object(ofType:CODChatHistoryModel.self, forPrimaryKey: id)
    }
    /// 查询某ID(联系人或群)聊天记录
    public class func getChatHistoryMessage(from id : Int, lastMessageTime: Int, isRead: Bool) -> Results<CODMessageModel>? {
        let defaultRealm = self.getDB()
        if let messageHistory = defaultRealm.object(ofType: CODChatHistoryModel.self, forPrimaryKey: id) {
            let messageList = messageHistory.messages.filter("fromWho contains[cd] %@ && isReaded == %@ && datetimeInt =< %ld && isDelete != true && status != 15", UserManager.sharedInstance.loginName ?? "", isRead , lastMessageTime)
            if messageList.count > 0 {
                return messageList
            }
        }
        return nil
    }
    /// 查询某ID(联系人或群)聊天记录
    public class func getChatHistoryPendingMessage(from id : Int) -> Results<CODMessageModel>? {
        let defaultRealm = self.getDB()
        if let messageHistory = defaultRealm.object(ofType:CODChatHistoryModel.self, forPrimaryKey: id) {
            let messageList = messageHistory.messages.filter("fromWho contains[cd] %@ && status <= %ld && isDelete != true", UserManager.sharedInstance.loginName ?? "", 5)
            if messageList.count > 0 {
                return messageList
            }
        }
        return nil
    }
    
    /// 查询某ID(联系人或群)聊天记录
    public class func getChatHistoryMessage(from id : Int, lastMessageTime: Int) -> Results<CODMessageModel>? {
        let defaultRealm = self.getDB()
        if let messageHistory = defaultRealm.object(ofType:CODChatHistoryModel.self, forPrimaryKey: id) {
            let messageList = messageHistory.messages.filter("datetimeInt < %ld && burn > %ld && isDelete != true", lastMessageTime,0)
            if messageList.count > 0 {
                return messageList
            }
        }
        return nil
    }
    
    /// 查询某ID(联系人或群)聊天记录，在指定时间戳之后的消息
    public class func getChatHistoryMessage(from id : Int, afterThe time: Int) -> Results<CODMessageModel>? {
        let defaultRealm = self.getDB()
        if let messageHistory = defaultRealm.object(ofType:CODChatHistoryModel.self, forPrimaryKey: id) {
            let messageList = messageHistory.messages.filter("datetimeInt > %ld && isDelete != true", time).sorted(byKeyPath: "datetime", ascending: true)
            if messageList.count > 0 {
                return messageList
            }
        }
        return nil
    }
    
    public class func searchTextMessage(from id: Int, textStr: String) -> Array<CODMessageModel>? {
        guard let history = self.getChatHistory(from: id) else {
            return nil
        }
        let messageArr = history.messages
        guard messageArr.count > 0 else {
            return nil
        }
        let list = messageArr.filter("text contains[c] %@ && msgType = 1 && isDelete != true", textStr)
            .sorted(byKeyPath: "datetime")
        var array = Array<CODMessageModel>()
        guard list.count > 0 else {
            print("————————————查询不到匹配的消息————-——————")
            return nil
        }
        for contact in list {
            array.append(contact)
        }
        return array
    }
    
    public class func searchFileMessage(from id: Int, textStr: String) -> Array<CODMessageModel>? {
        guard let history = self.getChatHistory(from: id) else {
            return nil
        }
        let messageArr = history.messages
        guard messageArr.count > 0 else {
            return nil
        }
        
        let listT = messageArr.map({ (messageModel) -> CODMessageModel? in
            if messageModel.fileModel?.filename.contains(textStr, caseSensitive: false) ?? false && messageModel.msgType == 7 && messageModel.isDelete == false {
                return messageModel
            }else{
                return nil
            }
        }).compactMap{$0}
        
        var array = Array<CODMessageModel>()
        guard listT.count > 0 else {
            print("————————————查询不到匹配的消息————-——————")
            return nil
        }
        for contact in listT {
            array.append(contact)
        }
        return array
    }
    
    public class func searchMessageContainFile(from id: Int, textStr: String) -> Array<CODMessageModel>? {
        let list1 = self.searchTextMessage(from: id, textStr: textStr) ?? []
        let list2 = self.searchFileMessage(from: id, textStr: textStr) ?? []
        var list = list1+list2
        
        if list.count > 0 {
            return list.sort(by: \.datetime)
        }else{
            return nil
        }
    }
    
    public class func searchMessageByMember(from id: Int, textStr: String,fromJID: String) -> Array<CODMessageModel>? {
        guard let history = self.getChatHistory(from: id) else {
            return nil
        }
        let messageArr = history.messages
        guard messageArr.count > 0 else {
            return nil
        }
        let list = messageArr.filter("text contains[c] %@ && msgType = 1 && isDelete != true && fromJID contains[c] %@", textStr,fromJID).sorted(byKeyPath: "datetime", ascending: true)
        var array = Array<CODMessageModel>()
        guard list.count > 0 else {
            print("————————————查询不到匹配的消息————-——————")
            return nil
        }
        for contact in list {
            array.append(contact)
        }
        return array
    }
    
}
