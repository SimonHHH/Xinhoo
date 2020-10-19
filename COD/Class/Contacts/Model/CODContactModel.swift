//
//  CODContactModel.swift
//  COD
//
//  Created by XinHoo on 2019/3/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RealmSwift
import HandyJSON

extension CODContactModel: CODChatObjectType {
    var chatId: Int {
        return self.rosterID
    }
    var title: String {
        return self.getContactNick()
    }
    var icon: String {
        return self.userpic
    }
    var chatTypeEnum: CODMessageChatType {
        return .privateChat
    }
}

enum UserType {
    case user
    case bot
    
    init(str: String) {
        switch str {
        case "U":
            self = UserType.user
        case "B":
            self = UserType.bot
        default:
            self = UserType.user
        }
    }
    
    var string: String {
        switch self {
        case .bot:
            return "B"
        case .user:
            return "U"
        }
    }
}

class CODContactModel: Object,HandyJSON {
    
    
    
    @objc dynamic var rosterID :Int = 0
    
    /// 昵称
    @objc dynamic var name = ""
    
    /// 头像刷新时间节点
    @objc dynamic var timestamp:Int64 = Int64(Date.milliseconds)
    
    @objc dynamic var username = ""
    
    /// 用户名（唯一）
    @objc dynamic var userdesc = ""
    
    /// 是否有效
    @objc dynamic var isValid: Bool = false
    
    /// 我对该好友的备注名
    @objc dynamic var nick = ""
    
    @objc dynamic var gender = ""
    
    @objc dynamic var pinYin = ""
    
    @objc dynamic var descriptions = ""
    
    @objc dynamic var blacklist :Bool = false
    
    @objc dynamic var jid = ""
    
    @objc dynamic var defareacode = ""
    
    @objc dynamic var deftel = ""
    /// 最后登录时间是否对好友可见
    @objc dynamic var lastLoginTimeVisible :Bool = true
    /// 最后登录时间
    @objc dynamic var lastlogintime: Int = 0
    /// 登录状态
    @objc dynamic var loginStatus = ""
    
    @objc dynamic var last_loginStatus = ""
    
    /// 是否可接收消息
    @objc dynamic var messageVisible :Bool = true
    /// 是否可被语音通话
    @objc dynamic var callVisible :Bool = true
    /// 是否可被邀请进入群组
    @objc dynamic var inviteJoinRoomVisible :Bool = true
    /// 是否允许邀请进入频道
    @objc dynamic var xhinvitejoinchannel :Bool = true
    /// 是否显示手机号码
    @objc dynamic var showtel = ""
    
    @objc dynamic var color = ""
    
    /// 个性签名
    @objc dynamic var about = ""
    
    var tels = List<String>()
    
    /// 阅后即焚
    @objc dynamic var burn :Int = 0
    /// 上次焚烧消息的时间
    @objc dynamic var lastBurnTime :Int = 0
    /// 上次退出聊天页面的时间
    @objc dynamic var lastChatTime :Int = 0
    /// 上次退出聊天页面的最后一条消息的时间 防止发送消息的时候最后一条消息服务器返回的时间和本地时间有很大偏差的时候使用
    @objc dynamic var lastChatMsgID :String = ""
    /// 消息免打扰
    @objc dynamic var mute :Bool = false
    /// 截屏通知
    @objc dynamic var screenshot :Bool = false
    /// 置顶聊天
    @objc dynamic var stickytop :Bool = false
    /// 头像ID
    @objc dynamic var userpic = ""
    
    /// U 是用户, B 是机器人
    @objc dynamic var userType = "U"
    
    var userTypeEnum: UserType {
        return UserType(str: self.userType)
    }
    
    /// 是否可以点击（用于添加群成员时区别是否为已添加的好友）
    var isUnableClick = false
    
    /// 用于记录添加成员创建群聊时的位置
    var index: Int = 0
    
    let master = LinkingObjects(fromType: CODChatListModel.self, property: "contact")
    
    var isCloudDisk: Bool {
        return self.jid.contains(kCloudJid)
    }
    
    var jsonModel: CODContactHJsonModel? {
        didSet{
            if let modelTemp = jsonModel {
                rosterID = modelTemp.rosterID
                
                if modelTemp.nick.count > 0 {
                    pinYin = ChineseString.getPinyinBy(modelTemp.nick)
                }else{
                    pinYin = ChineseString.getPinyinBy(modelTemp.name)
                }
                if modelTemp.name.count > 0 {
                    name = modelTemp.name.aes128DecryptECB(key: .nickName)
                }
                if modelTemp.nick.count > 0 {
                    nick = modelTemp.nick
                }
                
                if modelTemp.username.count > 0 {
                    username = modelTemp.username
                }
                if modelTemp.userdesc.count > 0 {
                    userdesc = modelTemp.userdesc
                }
                defareacode = modelTemp.defareacode
                deftel = modelTemp.deftel.aes128DecryptECB(key: .phoneNum)
                blacklist = modelTemp.blacklist
                gender = modelTemp.gender
                color = modelTemp.color
                jid = modelTemp.jid
                descriptions = modelTemp.descriptions
                for tel in modelTemp.tels {
                    tels.append(tel)
                }
                burn = modelTemp.burn
                mute = modelTemp.mute
                screenshot = modelTemp.screenshot
                stickytop = modelTemp.stickytop
                if modelTemp.userpic.count > 0 {
                    userpic = modelTemp.userpic
                }
                about = modelTemp.about
                
                lastLoginTimeVisible = modelTemp.lastLoginTimeVisible
                lastlogintime = modelTemp.lastlogintime
                if modelTemp.loginStatus.count > 0 {
                    loginStatus = modelTemp.loginStatus
                    CODGroupMemberRealmTool.getMembersResultsByJid(modelTemp.username).setValue(\.loginStatus, value: modelTemp.loginStatus)
                }
                
                CODGroupMemberRealmTool.getMembersResultsByJid(modelTemp.username).setValue(\.lastLoginTimeVisible, value: modelTemp.lastLoginTimeVisible)
                CODGroupMemberRealmTool.getMembersResultsByJid(modelTemp.username).setValue(\.lastlogintime, value: modelTemp.lastlogintime)
                
                
                messageVisible = modelTemp.messageVisible
                callVisible = modelTemp.callVisible
                inviteJoinRoomVisible = modelTemp.inviteJoinRoomVisible
                xhinvitejoinchannel = modelTemp.xhinvitejoinchannel
                showtel = modelTemp.showtel
                userType = modelTemp.xhtype
            }
        }
    }
    
    
    override static func primaryKey() -> String?{
        return "rosterID"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["isUnableClick","jsonModel"]
    }
    
    override static func indexedProperties() -> [String] {
        return ["nick","jid","username","deftel"]
    }
    
    
    
}

extension CODContactModel {
    public func setInvalidContactModel(_ modelTemp: CODContactModel) {
        rosterID = modelTemp.rosterID
        name = modelTemp.name
        timestamp = modelTemp.timestamp
        username = modelTemp.username
        userdesc = modelTemp.userdesc
        descriptions = modelTemp.descriptions
        nick = modelTemp.nick
        pinYin = modelTemp.pinYin
        gender = modelTemp.gender
        color = modelTemp.color
        screenshot = modelTemp.screenshot
        blacklist = modelTemp.blacklist
        jid = modelTemp.jid
        defareacode = modelTemp.defareacode
        deftel = modelTemp.deftel
        for tel in modelTemp.tels {
            tels.append(tel)
        }
        userpic = modelTemp.userpic
        lastBurnTime = modelTemp.lastBurnTime
        lastChatTime = modelTemp.lastChatTime
        lastChatMsgID = modelTemp.lastChatMsgID
        isValid = false
        burn = 0
        stickytop = false
        mute = false
        
        lastLoginTimeVisible = true
        lastlogintime = 0
        loginStatus = ""
        messageVisible = true
        callVisible = true
        inviteJoinRoomVisible = true
        xhinvitejoinchannel = true
        showtel = ""
    }
    
    public func getContactNick() -> String {
        if nick.count > 0 {
            return nick
        }else if name.count > 0{
            return name
        }else{
            return username
        }
    }
}




class CODContactHJsonModel: HandyJSON {
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        // 指定 descriptions 字段用 "description" 去解析
        mapper.specify(property: &descriptions, name: "description")
    }
    
    var rosterID :Int = 0
    var name = ""
    var nick = ""
    var username = ""
    var userdesc = ""
    var blacklist :Bool = false
    var gender = ""
    var color = ""
    var descriptions = ""
    var jid = ""
    var defareacode = ""
    var deftel = ""
    var tels = Array<String>()
    /// 阅后即焚
    var burn :Int = 0
    /// 消息免打扰
    var mute :Bool = false
    /// 截屏通知
    var screenshot :Bool = false
    /// 置顶聊天
    var stickytop :Bool = false
    /// 头像ID
    var userpic = ""
    
    /// 显示电话号码
    var showtel = ""
    /// 是否显示最后上线时间
    var lastLoginTimeVisible :Bool = true
    /// 最后上线时间
    var lastlogintime: Int = 0
    /// 登录状态
    var loginStatus = ""
    
    /// 个性签名
    var about = ""
    
    /// 是否接收消息
    var messageVisible :Bool = true
    /// 是否可被语音通话
    var callVisible :Bool = true
    /// 是否可被邀请进入群组
    var inviteJoinRoomVisible :Bool = true
    /// 是否允许邀请进入频道
    var xhinvitejoinchannel :Bool = true
    
    /// 机器人: B, 用户: U
    var xhtype: String = "U"
}

// 操作数据库
class CODContactRealmTool: CODRealmTools {
    /// 增加联系人
    public class func insertContact(by contact : CODContactModel) -> Void {
        let defaultRealm = self.getDB()
        
        try! defaultRealm.write {
            defaultRealm.add(contact, update: .all)
        }
        
    }
    
    /// 删除指定Id的联系人
    public class func deleteContact(by contactId : Int) -> Void {
        let defaultRealm = self.getDB()
        guard let contact = CODContactRealmTool.getContactById(by: contactId) else {
            return
        }
        try! defaultRealm.write {
            contact.isValid = false
        }
    }
    /// 删除指定Id的联系人
    public class func updateContactIsValid(by contact : CODContactModel,isValid: Bool) -> Void {
        let defaultRealm = self.getDB()
//        guard let contact = CODContactRealmTool.getContactById(by: contactId) else {
//            return
//        }
        try! defaultRealm.write {
            contact.isValid = isValid
        }
    }
    /// 查询所有的联系人
    public class func getContacts() -> Results<CODContactModel>? {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(CODContactModel.self).filter("rosterID > \(CloudDiskRosterID) && rosterID > \(NewFriendRosterID)")
    }
    
    /// 查询所有的联系人(非黑名单好友，不包括临时好友)
    public class func getContactsNotBlackList() -> Results<CODContactModel>? {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(CODContactModel.self).filter("blacklist == \(false) and isValid = \(true) and rosterID > \(CloudDiskRosterID) and rosterID > \(NewFriendRosterID)")
    }
    
    /// 通过JID 查询好友
    public class func getMyFriend(jid: String) -> CODContactModel? {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(CODContactModel.self).filter("jid == \(jid) and blacklist == \(false) and isValid = \(true) and rosterID > \(CloudDiskRosterID) and rosterID > \(NewFriendRosterID)").first
    }
    
    /// 查询所有的联系人(非黑名单好友，包括临时好友)
    public class func getContactsNotBlackListContainTempFriends() -> Results<CODContactModel>? {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(CODContactModel.self).filter("blacklist == \(false) and rosterID > \(CloudDiskRosterID) and rosterID > \(NewFriendRosterID)")
    }
    
    /// 查询指定id联系人
    public class func getContactById(by id : Int) -> CODContactModel? {
        let defaultRealm = self.getDB()
        return defaultRealm.object(ofType:CODContactModel.self ,forPrimaryKey: id)
    }

    /// 根据联系人JID查询联系人
    public class func getContactByJID(by JID : String) -> CODContactModel? {
        let defaultRealm = self.getDB()
        let list = defaultRealm.objects(CODContactModel.self).filter("jid contains %@", JID)
        var model = CODContactModel()
        guard let modelTemp = list.first else {
//            print("————————————查询不到该JID指定的联系人————-——————")
            return nil
        }
        model = modelTemp
        return model
    }
    
    public class func updateLoginStatus(jid: String, presence: XMPPPresence) {
        
        DispatchQueue.realmWriteQueue.async {
            
            guard let contact = CODContactRealmTool.getContactByJID(by: jid) else {
                return
            }
            
            guard let presenceType = presence.type else {
                return
            }
            
            let onlineState = CustomUtil.getPresencePriority(presence: presence)
            
            if let presenceType = presence.show {
                
                if presenceType == "away" && contact.last_loginStatus != "away" && onlineState != .online {
                    try? Realm().safeWrite {
                        contact.last_loginStatus = "away"
                        contact.loginStatus = "OFFLINE"
                        contact.lastlogintime = Int(Date.milliseconds)
                        switch onlineState {
                            
                        case .offline_ban:
                            contact.lastLoginTimeVisible = false
                            break
                        case .offline_all:
                            contact.lastLoginTimeVisible = true
                            break
                        case .offline_onlyFriend:
                            contact.lastLoginTimeVisible = contact.isValid
                            break
                        default:
                            break
                            
                        }
                    }
                }
                
            } else {
                
                if presenceType == "unavailable" {
                    
                    let onlineState = CustomUtil.getPresencePriority(presence: presence)
                    
                    if contact.last_loginStatus != "unavailable" && onlineState != .online  {
                        try? Realm().safeWrite  {
                            contact.last_loginStatus = "unavailable"
                            contact.loginStatus = "OFFLINE"
                            contact.lastlogintime = Int(Date.milliseconds)
                            
                            switch onlineState {
                                
                            case .offline_ban:
                                contact.lastLoginTimeVisible = false
                                break
                            case .offline_all:
                                contact.lastLoginTimeVisible = true
                                break
                            case .offline_onlyFriend:
                                contact.lastLoginTimeVisible = contact.isValid
                                break
                            default:
                                break
                                
                            }
                            
                        }
                    }
                    
                } else {
                    
                    try? Realm().safeWrite  {
                        contact.last_loginStatus = ""
                        contact.loginStatus = "ONLINE"
                    }
                    
                }
                
            }
            
            let members = CODGroupMemberRealmTool.getMembersResultsByJid(contact.username)
            members.setValue(\.loginStatus, value: contact.loginStatus)
            members.setValue(\.lastlogintime, value: contact.lastlogintime)
            members.setValue(\.lastLoginTimeVisible, value: contact.lastLoginTimeVisible)
            
        }
        
        
        
    }
    

    /// 根据联系人username 查询联系人
    public class func getContactByUsername(username : String) -> CODContactModel? {
        let defaultRealm = self.getDB()
        let list = defaultRealm.objects(CODContactModel.self).filter("username == %@", username)
        var model = CODContactModel()
        guard let modelTemp = list.first else {
            print("————————————查询不到该username指定的联系人————-——————")
            return nil
        }
        model = modelTemp
        return model
    }
    
    /// 根据联系人nick 查询联系人
    public class func getContactByNick(nick : String) -> CODContactModel? {
        let defaultRealm = self.getDB()
        let list = defaultRealm.objects(CODContactModel.self).filter("nick == %@", nick)
        var model = CODContactModel()
        guard let modelTemp = list.first else {
            print("————————————查询不到该nick指定的联系人————-——————")
            return nil
        }
        model = modelTemp
        return model
    }
    
    ///联系人模糊查询，默认不包含临时好友
    public class func getContactByKeyword(word : String, isContrainsTempFriends: Bool = false) -> [CODContactModel]? {
        let defaultRealm = self.getDB()
        var contacts = defaultRealm.objects(CODContactModel.self)
        if !isContrainsTempFriends {
            contacts = contacts.filter("isValid == \(true)")
        }
        if contacts.count <= 0 {
            return nil
        }
        let list = contacts.filter("nick contains[c] %@ OR userdesc contains[c] %@ OR name contains[c] %@ OR pinYin contains[c] %@", word, word, word, word)
        var array = Array<CODContactModel>()
        guard list.count > 0 else {
            print("————————————查询不到联系人————-——————")
            return nil
        }
        for contact in list {
            array.append(contact)
        }
        return array
    }
    
    /// 根据联系人JID查找他的userPic
    public class func searchContactPic(_ jidOrUsername: String) -> String? {
        guard let model = self.getContactByJID(by: jidOrUsername) else {
            print("查询联系人的UserPic，为空")
            return nil
        }
        return model.userpic
    }
    
    public class func updateContactModelTimeStamp(by JID : String,timeStamp: Int64) {
        if let contectModel = CODContactRealmTool.getContactByJID(by: JID) {
            let defaultRealm = self.getDB()
            try! defaultRealm.write {
                contectModel.timestamp = timeStamp
            }
        }
    }
    
    public class func updateContactModelLastChatTimeStamp(by JID : String,lastChatTime: Int,lastChatMsgID: String) {
        if let contectModel = CODContactRealmTool.getContactByJID(by: JID) {
            let defaultRealm = self.getDB()
            defaultRealm.beginWrite()
            contectModel.lastChatTime = lastChatTime
            contectModel.lastChatMsgID = lastChatMsgID
            if let notificationToken = CODRealmTools.default.contactNotificationToken {
                do{
                    try defaultRealm.commitWrite(withoutNotifying: [notificationToken])
                }catch{
                    
                }
                
            }else{
                do{
                    try defaultRealm.commitWrite()
                }catch{
                    
                }
                
            }
        }
    }
    
    public class func updateContactModelLastBurnTimeStamp(by id: Int,lastBurnTime: Int) {
        if let contectModel = CODContactRealmTool.getContactById(by: id) {
            let defaultRealm = self.getDB()
            try! defaultRealm.write {
                contectModel.lastBurnTime = lastBurnTime
            }
            
        }
    }
}



