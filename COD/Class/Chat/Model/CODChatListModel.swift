//
//  CODChatListModel.swift
//  COD
//
//  Created by XinHoo on 2019/3/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RealmSwift

protocol CODChatObjectType {
    var chatId: Int { get }
    var jid: String { get }
    var title: String { get }
    var icon: String { get }
    var chatTypeEnum: CODMessageChatType { get }
    var stickytop: Bool { get }
    var lastChatTime :Int { get }
    var lastChatMsgID :String { get }
    var mute :Bool { get }
}


protocol CODChatGroupType: CODChatObjectType {
    var member: List<CODGroupMemberModel> { get }
    func isMember(by jid: String) -> Bool
}


final class CODChatListModel: Object {
    
    @objc dynamic var lastMessage = ""
    
    var referToMessageID:List<String> = List<String>()
    
    /// 如果是单聊，id就是联系人的ID。否则id就是群ID
    @objc dynamic var id = 0
    
    @objc dynamic var chatType: String  = "1"
    
    var chatTypeEnum: CODMessageChatType {
        set {
            self.chatType = newValue.rawValue
        }
        get {
            return CODMessageChatType(rawValue: self.chatType) ?? .privateChat
        }
    }
    
    @objc dynamic var jid = ""
    
    @objc dynamic var title = ""
    
    @objc dynamic var subTitle = ""
    
    @objc dynamic var icon = ""
    
    ///
    @objc dynamic var lastDateTime = ""
    
    //消息的最后一条信息的已读回执
    @objc dynamic var lastReadTime = ""
    
    @objc dynamic var contact: CODContactModel?
    
    @objc dynamic var groupChat: CODGroupChatModel?
    
    @objc dynamic var channelChat: CODChannelModel?
    
    /// false 有效，true 无效
    @objc dynamic var isInValid: Bool = false

    @objc dynamic var finalPushTime: Int = 0
    
    var charModelObj: CODChatObjectType {
        
        set {
            switch newValue.chatTypeEnum {
            case .channel:
                self.channelChat = newValue as? CODChannelModel
                
            case .groupChat:
                self.groupChat = newValue as? CODGroupChatModel
                
            case.privateChat:
                self.contact = newValue as? CODContactModel
            }
        }
        get {
            switch self.chatTypeEnum {
            case .channel:
                return self.channelChat!
            case .groupChat:
                return self.groupChat!
            case .privateChat:
                return self.contact!
            }
        }
    }
    
    @objc dynamic var chatHistory: CODChatHistoryModel?
    
    @objc dynamic var count = 0
    
    /// 0-未通话   1-通话中
    @objc dynamic var groupRtc = 0
    
    /// 1-语音  2-视频
    @objc dynamic var rtcType = 1
    
    /// rtc room id
    @objc dynamic var groupRtcRoomId = ""
    
    /// 语音发起者
    @objc dynamic var groupRtcRequester = ""
    
    @objc dynamic var stickyTop: Bool = false
    
    @objc dynamic var stickyTopIndex: Int = 0
    
    @objc dynamic var atCount : Int = 0
    
    @objc dynamic var isShowBurned: Bool = false
    /// 消息免打扰
    @objc dynamic var mute :Bool = false
    
    @objc dynamic var editMessage: CODMessageModel?
    @objc dynamic var replyMessage: CODMessageModel?
    
    var isCloudDisk: Bool {
        return self.id == CloudDiskRosterID
    }
    
    var isNewFirend: Bool {
        return self.id == NewFriendRosterID
    }
    

    let savedTransMessages = List<CODMessageModel>()
    
    @objc dynamic var lastReadTimeOfMe = 0
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["title","jid"]
    }
    
}


extension CODChatListModel: RealmWriteKeyPathable {}

extension CODChatListModel{
    
    public func fixChatList(id: Int, chatType: CODMessageChatType = .privateChat) {
        
        try? Realm().write {
            
            switch chatType {
            case .privateChat:
                
                if self.contact == nil {
                    self.contact = CODContactRealmTool.getContactById(by: id)
                }
                
            case .groupChat:
                if self.groupChat == nil {
                    self.groupChat = CODGroupChatRealmTool.getGroupChat(id: id)
                }
                
            case .channel:
                if self.channelChat == nil {
                    self.channelChat = CODChannelModel.getChannel(by: id)
                }

            }
            
            
        }

    }
    
    func delete() {
        
        try! realm?.safeWrite {
            self.isInValid = true
            self.chatHistory?.messages.setValue(true, forKey: "isDelete")
            self.finalPushTime = Int(Date().timeIntervalSince1970 * 1000) + UserManager.sharedInstance.timeStamp
            
        }
        
    }
    
    func setChatList(isInValid: Bool? = nil) {
        
        try! realm?.safeWrite {
            
            if let isInValid = isInValid {
                self.isInValid = isInValid
            }
            
        }
        
    }
    
    class func insertOrUpdateChatListModel(by contactModel: CODContactModel, message: CODMessageModel) {
        
        let chatHistory = CODChatHistoryModel()
        chatHistory.id = contactModel.rosterID
        
        // 如果从数据库取到指定联系人的聊天记录，就把它遍历放到新建的chatHistory.messages中
        if let messageHistoryModelTemp = CODChatHistoryRealmTool.getChatHistory(from: contactModel.rosterID) {
            
            let messageHistoryList = messageHistoryModelTemp.messages
            try! Realm.init().write {
                messageHistoryList.append(message)
                
            }
            
        }else{
            let chatListModel = CODChatListModel()
            chatListModel.id = contactModel.rosterID
            chatListModel.chatTypeEnum = .privateChat
            chatListModel.contact = contactModel
            chatListModel.lastDateTime = message.datetime
            chatListModel.title = contactModel.getContactNick()
            chatListModel.jid = contactModel.jid
            chatListModel.icon = contactModel.userpic
            chatListModel.stickyTop = contactModel.stickytop
            // 插入一条新的消息
            chatHistory.messages.append(message)
            chatListModel.chatHistory = chatHistory
            
            // 更新数据库
            CODChatListRealmTool.insertChatList(by: chatListModel)
        }
        //通知去聊天列表中更新数据
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
    }
    
    class func insertOrUpdateGroupChatListModel(by groupChatModel: CODGroupChatModel, message: CODMessageModel?) {
        let chatListModel = CODChatListModel()
        chatListModel.id = groupChatModel.roomID
        chatListModel.chatTypeEnum = .groupChat
        
        chatListModel.groupChat = groupChatModel
        chatListModel.title = groupChatModel.getGroupName()
        chatListModel.icon = groupChatModel.grouppic
        chatListModel.stickyTop = groupChatModel.stickytop
        chatListModel.jid = groupChatModel.jid
        chatListModel.lastDateTime = groupChatModel.createDate
        
        let chatHistory = CODChatHistoryModel()
        chatHistory.id = groupChatModel.roomID
        
        // 如果从数据库取到指定联系人的聊天记录，就把它遍历放到新建的chatHistory.messages中
        if let messageHistoryModelTemp = CODChatHistoryRealmTool.getChatHistory(from: groupChatModel.roomID) {
            let messageHistoryList = messageHistoryModelTemp.messages
            for message in messageHistoryList{
                chatHistory.messages.append(message)
            }
        }
        
        // 如果message不为空，就插入一条新的消息
        if let messageTemp = message {
            chatHistory.messages.append(messageTemp)
            chatListModel.lastDateTime = messageTemp.datetime
        }
        
        chatListModel.chatHistory = chatHistory
        
        // 更新数据库
        CODChatListRealmTool.insertChatList(by: chatListModel)
    }
    
    class func insertOrUpdateChannelListModel(by channelModel: CODChannelModel, message: CODMessageModel?) {
        let chatListModel = CODChatListModel()
        chatListModel.id = channelModel.roomID
        chatListModel.chatTypeEnum = .channel
        
        chatListModel.channelChat = channelModel
        chatListModel.title = channelModel.getGroupName()
        chatListModel.icon = channelModel.grouppic
        chatListModel.stickyTop = channelModel.stickytop
        chatListModel.jid = channelModel.jid
        chatListModel.lastDateTime = channelModel.createDate
        
        let chatHistory = CODChatHistoryModel()
        chatHistory.id = channelModel.roomID
        
        // 如果从数据库取到指定联系人的聊天记录，就把它遍历放到新建的chatHistory.messages中
        if let messageHistoryModelTemp = CODChatHistoryRealmTool.getChatHistory(from: channelModel.roomID) {
            let messageHistoryList = messageHistoryModelTemp.messages
            for message in messageHistoryList{
                chatHistory.messages.append(message)
            }
        }
        
        // 如果message不为空，就插入一条新的消息
        if let messageTemp = message {
            chatHistory.messages.append(messageTemp)
            chatListModel.lastDateTime = messageTemp.datetime
        }
        
        chatListModel.chatHistory = chatHistory
        
        // 更新数据库
        CODChatListRealmTool.insertChatList(by: chatListModel)
    }
}

// 操作数据库
class CODChatListRealmTool: CODRealmTools {
    
    class func updateNewFriendModel(name:String?,desc:String?,dateTime:String = "\(Date.milliseconds)") {
        
        if let listModel = CODChatListRealmTool.getChatList(id: NewFriendRosterID) {
            
            try! Realm().safeWrite({
                listModel.title = name ?? ""
                listModel.subTitle = desc ?? ""
                listModel.lastDateTime = dateTime
            })
        }
        
        
    }
    
    
    /// 根据时间点，删除之前的消息
    /// - Parameters:
    ///   - time: 时间点
    ///   - id: 对象ID
    class func deleteMessageWithTime(time:String,id: Int){
        if let chatModel = CODChatListRealmTool.getChatList(id: id) {
        
            try! Realm().safeWrite {
                chatModel.chatHistory?.messages.filter("datetimeInt < \(time.int ?? 0)").setValue(true, forKey: "isDelete")
            }
        }
        
    }
    
    /// 根据后台返回的sessionItem构建一个chatlistmodel
    /// - Parameter sessionItem: sessionItem
    class func buildChatModel(sessionItem:SessionItemModel) -> CODChatListModel? {
        
        
        /// 不知道以前哪一段的问题，会出现自己给自己发送好友请求，导致服务器返回通讯录里面会包含自己。
        /// 语音通话，服务器会构建一条自己发给自己的消息，所以，服务器构建会话列表的时候，也有可能会返回自己跟自己聊天的会话列表
        /// iOS现在处理会话列表的时候，如果发现对应的ID是自己，那就把这个会话抛掉，不做处理
        if sessionItem.itemID == UserManager.sharedInstance.jid {
            return nil
        }
        
        let chatModel = CODChatListModel.init()
        
        let historyModel = CODChatHistoryModel.init()
        
        if sessionItem.lastMessage.count > 0 {
            
            do{
                let message = try XMPPMessage.init(xmlString: sessionItem.lastMessage)
                if let messageModel = XMPPManager.shareXMPPManager.xmppMessageToRealmMessage(message: message) {
                    
                    if (messageModel.type == .notification && messageModel.text == "") || messageModel.type == .haveRead  {
                    } else {
                        historyModel.messages.append(messageModel)
                        chatModel.lastDateTime = messageModel.datetime
//                        CustomUtil.updateLastPushTime(message: messageModel)
                        if (CustomUtil.pushTime.int ?? 0) < messageModel.datetimeInt {
                            CustomUtil.pushTime = messageModel.datetime
                        }
                    }
                    
                    
                }
            }catch{}
            
        }
        
        chatModel.icon = sessionItem.itemPic
        chatModel.chatTypeEnum = sessionItem.chatTypeEnum
        chatModel.count = sessionItem.badge
        chatModel.lastMessage = sessionItem.lastMessage
        chatModel.jid = sessionItem.itemID
        chatModel.title = sessionItem.itemName
        
        chatModel.groupRtc = sessionItem.groupRtc
        chatModel.groupRtcRoomId = sessionItem.groupRtcRoomId
        chatModel.groupRtcRequester = sessionItem.groupRtcRequester
        
        if sessionItem.itemID.contains("cod_60000000") {
            chatModel.title = "\(kApp_Name)小助手"
        }
        chatModel.stickyTop = sessionItem.stickytop
        chatModel.chatHistory = historyModel
        chatModel.lastReadTime = sessionItem.lastReadTime
        chatModel.lastReadTimeOfMe = sessionItem.lastReadTimeOfMe
        
        chatModel.finalPushTime = (sessionItem.clearTime.int ?? 0)

        if chatModel.lastDateTime == "" && chatModel.finalPushTime != 0 {
            chatModel.lastDateTime = sessionItem.clearTime
        }
        
        switch sessionItem.deleteTypeEnum {
        case .delete:
            chatModel.isInValid = true
            break

        case .active:
            chatModel.isInValid = false
            break

        }
        
        for referto in sessionItem.referToResultVoList {
            if let jsonString = referto.jsonString(),chatModel.count > 0 {
                chatModel.referToMessageID.append(jsonString)
            }
        }
        
        if chatModel.count == 0 {
            chatModel.referToMessageID.removeAll()
        }
        
        if let contact = CODContactRealmTool.getContactByJID(by: sessionItem.itemID) {
            chatModel.id = contact.rosterID
            chatModel.contact = contact
            historyModel.id = contact.rosterID
            return chatModel
        }
        
        if let group = CODGroupChatRealmTool.getGroupChatByJID(by: sessionItem.itemID) {
            chatModel.id = group.roomID
            chatModel.groupChat = group
            historyModel.id = group.roomID
            return chatModel
        }
        
        if let channel = CODChannelModel.getChannel(jid: sessionItem.itemID) {
            chatModel.id = channel.roomID
            chatModel.channelChat = channel
            historyModel.id = channel.roomID
            return chatModel
        }
        
        return nil
        
    }
    
    
    /// 获取新的朋友数量
    class func getNewFriendCount() -> Int {
        if let chatListModel = CODChatListRealmTool.getChatList(id: NewFriendRosterID) {
            return chatListModel.count
        }else{
            return 0
        }
    }
    
    
    /// 修改新的朋友数量
    /// - Parameter count: 数量
    class func setNewFriendCount(count: Int) {
        if let chatListModel = CODChatListRealmTool.getChatList(id: NewFriendRosterID) {
            try! Realm().safeWrite {
                chatListModel.count = count
            }
        }
    }
    
    public class func updateMessageHaveReaded(id: Int) {
        
        if let chatList = CODChatListRealmTool.getChatList(id: id), let lastReadTime = chatList.lastReadTime.int {
            try! Realm().safeWrite {
                chatList.chatHistory?.messages.filter("datetimeInt <= \(lastReadTime) && status == 10")
                    .setValue(true, forKey: "isReaded")
            }
        }
        
    }
    
    public class func updateLastMessageReadTime(id: Int,lastReadTime: String)  {
        
        if lastReadTime.int != nil {
            if let chatModel = self.getChatList(id: id) {
                let defaultRealm = CODRealmTools.getDB()
                try! defaultRealm.safeWrite {
                    if chatModel.lastReadTime < lastReadTime {
                        chatModel.lastReadTime = lastReadTime
                    }
                }
            }
        }
        
    }
    
    
    
    /// 删除一个会话
    /// - Parameter id: 会话ID
    public class func removeChatList(id: Int) {
        
        if let chatModel = self.getChatList(id: id) {
            CODChatListRealmTool.deleteChatListHistory(by: id)
            try! Realm.init().write {
                chatModel.lastDateTime = "0"
                chatModel.isInValid = true
            }
        }
        
    }
    
    public class func setIsInValid(id: Int, isInValid: Bool) {
        
        if let chatModel = self.getChatList(id: id) {
            chatModel.setChatList(isInValid: isInValid)
        }
        
    }
    
    public class func updateLastDateTime(id: Int,lastDateTime: String)  {
        
        if let chatModel = self.getChatList(id: id) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.safeWrite {
                if chatModel.lastDateTime < lastDateTime {

                    chatModel.lastDateTime = lastDateTime
                }
            }
        }
    }
    
    
    public class func updateLastDatetimeWithMessageModel(messageModel:CODMessageModel) {
        
        if let contactModel = CODContactRealmTool.getContactByJID(by: messageModel.toJID) {
            if let listModel = CODChatListRealmTool.getChatList(id: contactModel.rosterID) {
                try! Realm.init().write {
                    listModel.lastDateTime = "\(messageModel.datetimeInt)"
                }
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
            }
        }
        
        if let groupModel = CODGroupChatRealmTool.getGroupChatByJID(by: messageModel.toJID) {
            if let listModel = CODChatListRealmTool.getChatList(id: groupModel.roomID) {
                try! Realm.init().write {
                    listModel.lastDateTime = "\(messageModel.datetimeInt)"
                }
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
            }
        }
        
        if let channelModel = CODChannelModel.getChannel(jid: messageModel.toJID) {
            if let listModel = CODChatListRealmTool.getChatList(id: channelModel.roomID) {
                try! Realm.init().write {
                    listModel.lastDateTime = "\(messageModel.datetimeInt)"
                }
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
            }
        }
        
    }
    
    public class func updateLastDateTimeWithDeleteMsg(id: Int,lastDateTime: String)  {
        
        if let chatModel = self.getChatList(id: id) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.safeWrite {
                chatModel.lastDateTime = lastDateTime
            }
        }
    }
    
    /// 增加聊天列表
    public class func insertChatList(by chatList : CODChatListModel) -> Void {
        let defaultRealm = self.getDB()
        
        try! defaultRealm.write {
            defaultRealm.add(chatList, update: .all)
        }
        print(defaultRealm.configuration.fileURL ?? "")
        
        //通知去聊天列表中更新数据
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
    }
    
    public class func createChatList(chatId: Int, type: CODMessageChatType) -> CODChatListModel? {
        
        var history: CODChatHistoryModel = CODChatHistoryModel()
        history.id = chatId
        if let historyModel = CODChatHistoryRealmTool.getChatHistory(from: chatId) {
            history = historyModel
        }
        
        switch type {
        case .privateChat:
            if let contact = CODContactRealmTool.getContactById(by: chatId) {
                
                let chatListModel = CODChatListModel()
                chatListModel.id = contact.rosterID
                chatListModel.icon = contact.userpic
                chatListModel.chatTypeEnum = .privateChat
                chatListModel.contact = contact
                chatListModel.jid = contact.jid
                chatListModel.chatHistory = history
                chatListModel.title = contact.getContactNick()
                chatListModel.stickyTop = contact.stickytop
                if let lastMsg = history.messages.last {
                    chatListModel.lastDateTime = lastMsg.datetime
                }
                return chatListModel
            }
            
        case .groupChat:
            
            if let group = CODGroupChatRealmTool.getGroupChat(id: chatId) {
                let chatListModel = CODChatListModel()
                chatListModel.id = group.roomID
                chatListModel.icon = group.grouppic
                chatListModel.chatTypeEnum = .groupChat
                chatListModel.groupChat = group
                chatListModel.jid = group.jid
                chatListModel.title = group.getGroupName()
                chatListModel.stickyTop = group.stickytop
                chatListModel.chatHistory = history
                if let lastMsg = history.messages.last {
                    chatListModel.lastDateTime = lastMsg.datetime
                }
                return chatListModel
            }
            
            
        case .channel:
            
            if let channel = CODChannelModel.getChannel(by: chatId) {
                let chatListModel = CODChatListModel()
                chatListModel.id = channel.roomID
                chatListModel.icon = channel.grouppic
                chatListModel.chatTypeEnum = .channel
                chatListModel.channelChat = channel
                chatListModel.jid = channel.jid
                chatListModel.title = channel.getGroupName()
                chatListModel.stickyTop = channel.stickytop
                chatListModel.chatHistory = history
                if let lastMsg = history.messages.last {
                    chatListModel.lastDateTime = lastMsg.datetime
                }
                return chatListModel

                
            }
            
        }
        
        return nil
        
    }
    
    public class func insertChatList(chatId: Int, type: CODMessageChatType) -> Void {
        let defaultRealm = self.getDB()
        
        guard let chatList = createChatList(chatId: chatId, type: type) else { return }
        
        try! defaultRealm.safeWrite {
            defaultRealm.add(chatList, update: .all)
        }
        
        
    }
    
    public class func insertChatList_ZZS(by chatList : CODChatListModel) -> Void {
        let defaultRealm = self.getDB()
        
        try! defaultRealm.write {
            defaultRealm.add(chatList, update: .all)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
    
    /// 查询所有的聊天列表
    public class func getChatList() -> Array<CODChatListModel> {
        let defaultRealm = self.getDB()
        var chatList:Array<CODChatListModel> = []
        
        // 先取置顶的
        let stickytopArr = defaultRealm.objects(CODChatListModel.self).filter("stickyTop == \(true)").sorted(byKeyPath: "lastDateTime", ascending: false)
        if stickytopArr.count > 0 {
            chatList.append(contentsOf: stickytopArr)
        }
        // 再取其他的
        let normalArr = defaultRealm.objects(CODChatListModel.self).filter("stickyTop == \(false)").sorted(byKeyPath: "lastDateTime", ascending: false)
        chatList.append(contentsOf: normalArr)
        return chatList
    }
    
    /// 查询所有的置顶聊天列表
    public class func getStickyTopList(filterNewFriend:Bool = true) -> Array<CODChatListModel> {
        let defaultRealm = self.getDB()
        var chatList:Array<CODChatListModel> = []
        
        if filterNewFriend {
            let stickytopArr = defaultRealm.objects(CODChatListModel.self).filter("stickyTop == \(true) && isInValid == \(false)").sorted(byKeyPath: "stickyTopIndex")
            
            
            if stickytopArr.count > 0 {
                chatList.append(contentsOf: stickytopArr)
            }
            return chatList
        }else{
            let stickytopArr = defaultRealm.objects(CODChatListModel.self).filter("stickyTop == \(true) && isInValid == \(false) && id != -999").sorted(byKeyPath: "stickyTopIndex")
            
            
            if stickytopArr.count > 0 {
                chatList.append(contentsOf: stickytopArr)
            }
            return chatList
        }
        
    }
    
    /// 查询所有的非置顶聊天列表
    public class func getNoneStickyTopList(filterNewFriend:Bool = true) -> Array<CODChatListModel> {
        let defaultRealm = self.getDB()
        var chatList:Array<CODChatListModel> = []
        
        if filterNewFriend {
            
            let normalArr = defaultRealm.objects(CODChatListModel.self).filter("stickyTop == \(false) && isInValid == \(false)").sorted(byKeyPath: "lastDateTime", ascending: false)
            
            chatList.append(contentsOf: normalArr)
            return chatList
        }else{
            let normalArr = defaultRealm.objects(CODChatListModel.self).filter("stickyTop == \(false) && isInValid == \(false) && id != -999").sorted(byKeyPath: "lastDateTime", ascending: false)
            
            chatList.append(contentsOf: normalArr)
            return chatList
        }
        
    }
    
    /// 查询所有的群聊列表
    public class func getGroupChatList() -> Array<CODGroupChatModel> {
        let chatlistArr = self.getChatList()
        let groupList = chatlistArr
            .filter { (listModel) -> Bool in
                return listModel.chatTypeEnum == .groupChat
            }
            .map { (listModel) -> CODGroupChatModel? in
                if listModel.groupChat != nil {
                    return listModel.groupChat!
                }
                return nil
        }.compactMap{$0}
        
        return groupList
    }
    
    /// 查询某一项的聊天列表
    public class func getChatList(id: Int) -> CODChatListModel? {
        let defaultRealm = self.getDB()
        if let model = defaultRealm.object(ofType: CODChatListModel.self, forPrimaryKey: id) {
            return model
        }
        return nil
    }
    

    
    /// 查询某一项的聊天列表
    public class func addChatListMessage(id: Int,message: CODMessageModel){
        let defaultRealm = try! Realm()
        if let model = defaultRealm.object(ofType: CODChatListModel.self, forPrimaryKey: id) {
            
            if let loginName = UserManager.sharedInstance.loginName {
                if !message.fromJID.contains(loginName) {
                    CODChatListRealmTool.updateLastMessageReadTime(id: model.id, lastReadTime: message.datetime)
                }
            }
            CODChatListRealmTool.updateLastDateTime(id: model.id, lastDateTime: message.datetime)
            
            try! defaultRealm.safeWrite {
                
                if model.chatTypeEnum == .channel {
                    
                    if model.channelChat?.isMember(by: UserManager.sharedInstance.jid) ?? false {
                        model.setChatList(isInValid: false)
                    }
                    
                } else {
                    model.setChatList(isInValid: false)
                }
                                
                
                let chatHistory = model.chatHistory ?? CODChatHistoryModel()
                if model.chatHistory == nil {
                    model.chatHistory = chatHistory
                }
                
                if (model.lastDateTime.int ?? 0) < (message.datetime.int ?? 0) {
                    model.lastDateTime = message.datetime
                }
                
                if let messageModel = CODMessageRealmTool.getMessageByMsgId(message.msgID) {
                    
                    messageModel.userPic = message.userPic
                    
                    if message.statusType == .Failed {
                        messageModel.statusType = .Failed
                        return
                    }
                    
                    /// 千万不能刷新时间，会影响拉历史
//                    messageModel.setValue(\.datetimeInt, value: message.datetimeInt)
//                    messageModel.setValue(\.datetime, value: message.datetime)
                    
            
                    // 这里可能有问题，但先这么改 xuemin.cai
                    message.imageList.setValue(\.uploadState, value: UploadStateType.None.intValue)
                    
                    /// 如果
                    if messageModel.needUpdateMsg != true {
                        
                        if messageModel.edited == message.edited  {
                            
                            if messageModel.statusType == .Pending {
                                CODMessageRealmTool.updateMessageStyleByMsgId(messageModel.msgID, status: CODMessageStatus.Succeed.rawValue, sendTime: message.datetimeInt)
                            }
                            
                            messageModel.statusType = .Succeed
                            messageModel.editMessage(model: nil, status: .Succeed)
                            if messageModel.photoModel?.descriptionImage != message.photoModel?.descriptionImage {
                                messageModel.photoModel?.descriptionImage = message.photoModel?.descriptionImage ?? ""
                            }
                            if messageModel.videoModel?.descriptionVideo != message.videoModel?.descriptionVideo {
                                messageModel.videoModel?.descriptionVideo = message.videoModel?.descriptionVideo ?? ""
                            }
                            
                            messageModel.entities.removeAll()
                            messageModel.entities.append(objectsIn: message.entities)
                            messageModel.l = message.l
                            
                            return
                        }
                        
                        if messageModel.edited > message.edited  {
                            return
                        }
                        
                    } else {
                        message.needUpdateMsg = false
                    }
                    
                    
                    message.isDelete = messageModel.isDelete
                    message.cellHeight = messageModel.cellHeight
                    message.isReaded = messageModel.isReaded
                    

                    if messageModel.editMessage != nil {
                        
                        if let videoModel = messageModel.editMessage?.videoModel, messageModel.type == .video {
                            message.videoModel = videoModel
                        } else if let photoModel = messageModel.editMessage?.photoModel, messageModel.type == .image {
                            message.photoModel = photoModel
                        }
                        
                    }

                    defaultRealm.add(message, update: .modified)
                } else {
                    defaultRealm.add(message, update: .modified)
                    chatHistory.messages.append(message)
                }
                
            }
        }
        
    }
    
    class func asyncAddChatListMessage(id: Int,message: CODMessageModel) {
        
        let newMessage = CODMessageModel(value: message)
        DispatchQueue.realmWriteQueue.async {
            self.addChatListMessage(id: id, message: newMessage)
        }
    }
    
    public class func addChatListMessages(id: Int, messages: [CODMessageModel]) {
        
        try! Realm().safeWrite {
            for message in messages {
                self.addChatListMessage(id: id, message: message)
            }
        }
        
    }
    
    class func asyncAddChatListMessages(id: Int, messages: [CODMessageModel]) {
        let newMessages = messages.map { CODMessageModel(value: $0) }
        DispatchQueue.realmWriteQueue.async {
            self.addChatListMessages(id: id, messages: newMessages)
        }
    }
    
    
    
    /// jid查询某一项的聊天列表
    public class func getChatList(jid: String) -> CODChatListModel? {
        let defaultRealm = self.getDB()
        let modelList = defaultRealm.objects(CODChatListModel.self).filter("jid contains %@", jid)
        guard let modelTemp = modelList.first else {
            print("———————————— 查询不到该JID指定的聊天列表 ————-——————")
            return nil
        }
        return modelTemp
    }
    
    /// 根据聊天对象的ID插入一条Message
    //    public class func insertMessageToChatList(message: CODMessageModel ,chatId: Int){
    //        let defaultRealm = self.getDB()
    //        guard let model = defaultRealm.object(ofType: CODChatListModel.self, forPrimaryKey: chatId) else {
    //            print("插入聊天MessageHistory时，查询ChatList为空")
    //            return
    //        }
    //        try! defaultRealm.write {
    //            model.chatHistory?.messages.append(message)
    //        }
    //    }
    
    /// 清除会话所有的消息
    /// - Parameter chatId: 会话ID
    /// - Returns: 
    public class func deleteChatListHistory(by chatId : Int) -> Void {
        let defaultRealm = self.getDB()
        guard let chatListModel = self.getChatList(id: chatId) else {
            return
        }
        
        try! defaultRealm.safeWrite {
            chatListModel.chatHistory?.messages.setValue(true, forKey: "isDelete")
            chatListModel.finalPushTime = Int(Date().timeIntervalSince1970 * 1000) + UserManager.sharedInstance.timeStamp
            chatListModel.count = 0
            chatListModel.referToMessageID.removeAll()
            chatListModel.isShowBurned = false
        }
        
    }
    
    public class func updateChatListTitleByChatId(chatId: Int ,andTitle title: String) {
        let defaultRealm = self.getDB()
        guard let chatListModel = self.getChatList(id: chatId) else {
            return
        }
        
        try! defaultRealm.write {
            chatListModel.title = title
        }
        
        //通知去聊天列表中更新数据
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
    }
    
    //保存转发的消息集合
    public class func saveTransMsgs(chatId: Int, msgs: Array<CODMessageModel>)  {
        if let chatModel = self.getChatList(id: chatId) {
            let defaultRealm = CODRealmTools.getDB()
            if msgs.count > 0 {
                try! defaultRealm.write {
                    chatModel.savedTransMessages.removeAll()
                    for msg in msgs {
                        chatModel.savedTransMessages.append(msg)
                    }
                }
            }
        }
    }
    
    //获取转发的消息集合
    public class func getSaveTransMsgs(chatId: Int) -> Array<CODMessageModel>?  {
        var msgArr: Array<CODMessageModel> = []
        if let chatModel = self.getChatList(id: chatId) {
            for msg in chatModel.savedTransMessages {
                msgArr.append(msg)
            }
            return msgArr
        }else{
            return nil
        }
        
    }
    
    // 删除已保存的转发消息集合
    public class func deleteSavedTransMsgs(chatId: Int)  {
        if let chatModel = self.getChatList(id: chatId) {
            let defaultRealm = CODRealmTools.getDB()
            if chatModel.savedTransMessages.count > 0 {
                try! defaultRealm.write {
                    chatModel.savedTransMessages.removeAll()
                }
            }
        }
    }
    
}
