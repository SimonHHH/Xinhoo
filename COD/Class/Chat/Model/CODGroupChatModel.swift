//
//  CODGroupChatModel.swift
//  COD
//
//  Created by XinHoo on 2019/3/29.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RealmSwift
import HandyJSON
import SwiftyJSON

extension CODGroupChatModel: CODChatObjectType {
    var title: String {
        self.getGroupName()
    }
    var icon: String {
        return self.grouppic
    }
    var chatTypeEnum: CODMessageChatType {
        return .groupChat
    }
    var chatId: Int {
        return self.roomID
    }
}

extension CODGroupChatModel: CODChatGroupType { }

enum CODGroupType: String {
    
    /// 共有群
    case MPUB
    
    /// 私有群
    case MPRI
}


class CODGroupChatModel: Object {
    
    @objc dynamic var roomID :Int = 0
    
    /// 是否已读公告（用于判断是否展示群公告）
    @objc dynamic var readednotice :Bool = false
    
    @objc dynamic var jid = ""
    
    /// codm_8000074
    @objc dynamic var name = ""
    
    let member = List<CODGroupMemberModel>()
    
    @objc dynamic var savecontacts :Bool = false
    
    /// : 0
    @objc dynamic var timingcleanup :Bool = false
    
    /// 群聊链接
    @objc dynamic var userid = ""
    
    var typeEnum: CODGroupType {
        get {
            return CODGroupType(rawValue: self.type) ?? .MPRI
        }
        
        set {
            self.type = newValue.rawValue
        }
    }
    
    @objc dynamic var type = CODGroupType.MPRI.rawValue
    
    var shareLink: String {
        
        return "\(CODAppInfo.channelSharePrivateLink)\(self.userid)"
    }
    
    /// 群名称
    @objc dynamic var descriptions = ""
    
    /// 群公告
    @objc dynamic var notice = ""
    
    /// ：Administrator、tommy、jimmy
    @objc dynamic var naturalname = ""
    
    /// 如果获取的群descriptions为空就自定义群名
    @objc dynamic var customName = ""
    
    /// 阅后即焚
    @objc dynamic var burn :String = ""
    
    //上次焚烧消息的时间
    @objc dynamic var lastBurnTime :Int = 0
    
    //上次退出聊天页面的时间
    @objc dynamic var lastChatTime :Int = 0
    
    /// 上次退出聊天页面的最后一条消息的时间 防止发送消息的时候最后一条消息服务器返回的时间和本地时间有很大偏差的时候使用
    @objc dynamic var lastChatMsgID :String = ""
    
    /// 消息免打扰
    @objc dynamic var mute :Bool = false
    
    /// 截屏通知
    @objc dynamic var screenshot :Bool = false
    
    /// 置顶聊天
    @objc dynamic var stickytop :Bool = false
    
    /// 显示名称
    @objc dynamic var showname: Bool = true
    
    /// 群组是否有效
    @objc dynamic var isValid: Bool = false
    
    /// 是否禁止邀请入群
    @objc dynamic var notinvite: Bool = false
    
    /// 头像ID
    @objc dynamic var grouppic = ""
    
    /// 创建时间 ，用于本地创建时显示在聊天列表。特殊：手动赋值
    @objc dynamic var createDate = ""
    
    /// 群置顶消息
    @objc dynamic var topmsg: String = ""
    
    /// 群成员@所有人
    @objc dynamic var xhreferall: Bool = false
    
    /// 允许查看入群前消息
    @objc dynamic var xhshowallhistory: Bool = false
    
    /// 允许查看添加好友
    @objc dynamic var userdetail: Bool = true
    
    /// 允许群成员聊天
    @objc dynamic var canspeak: Bool = true
    
    @objc dynamic var isDelete: Bool = false
    
    let master = LinkingObjects(fromType: CODChatListModel.self, property: "groupChat")
    
    var jsonModel: CODGroupChatHJsonModel? {
        didSet{
            if let modelTemp = jsonModel {
                
                roomID = modelTemp.roomID
                setJsonModel(jsonModel: modelTemp)
                
            }
        }
    }
    
    func setJsonModel(jsonModel: CODGroupChatHJsonModel?) {
        
        guard let modelTemp = jsonModel else {
            return
        }
        
        name = modelTemp.name
        jid = modelTemp.jid
        savecontacts = modelTemp.savecontacts
        timingcleanup = modelTemp.timingcleanup
        descriptions = modelTemp.description
        notice = modelTemp.notice
        naturalname = modelTemp.naturalname
        userid = modelTemp.userid
        burn = modelTemp.burn
        mute = modelTemp.mute
        showname = modelTemp.showname
        screenshot = modelTemp.screenshot
        stickytop = modelTemp.stickytop
        grouppic = modelTemp.grouppic
        notinvite = modelTemp.notinvite
        topmsg = modelTemp.topmsg
        xhreferall = modelTemp.xhreferall
        xhshowallhistory = modelTemp.xhshowallhistory
        userdetail = modelTemp.userdetail
        canspeak = modelTemp.canspeak
        readednotice = modelTemp.readednotice
    }
    
    func updateModel(topmsg: String? = nil) {
        
        try! Realm().safeWrite {
            
            if let topmsg = topmsg {
                self.topmsg = topmsg
            }
            
        }
        
        
        
    }

    override static func primaryKey() -> String?{
        return "roomID"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["jsonModel"]
    }
    
    override static func indexedProperties() -> [String] {
        return ["customName","descriptions"]
    }
    

}

extension CODGroupChatModel{
    
    public func isICanCheckUserInfo() -> Bool {
        
        if userdetail == false && !isOwner(jid: UserManager.sharedInstance.jid) && !isAdmin(jid: UserManager.sharedInstance.jid) {
            return false
        }

        return true
        
    }
    
    func isOwner(jid: String) -> Bool {
        
        if let member = self.getMember(jid: jid) {
            return member.userpower == 10
        }
        
        return false

    }
    
   

    func isAdmin(jid: String) -> Bool {
        
        if let member = self.getMember(jid: jid) {
            return member.userpower == 20
        }
        
        return false

    }
    
    func isMember(by jid: String) -> Bool {
        
        if let _ = self.getMember(jid: jid) {
            return true
        }
        
        return false

    }
    
    func getMember(jid: String) -> CODGroupMemberModel? {
        
        return self.member.filter("memberId == '\(CODGroupMemberModel.getMemberId(roomId: roomID, userName: jid))'").first
//        return CODGroupMemberRealmTool.getMemberById(CODGroupMemberModel.getMemberId(roomId: roomID, userName: jid))
    }
    
    func isCanSpeak() -> Bool {
        if self.canspeak {
            return true
        }
        return self.member.filter { (model) -> Bool in
            return model.userpower == 10 || model.userpower == 20
        }
        .contains { (model) -> Bool in
            return model.jid == UserManager.sharedInstance.jid
        }
    }
    
    
    
    public class func getCustomGroupName(memberList: List<CODGroupMemberModel>) -> String {
        var groupName = ""
        var arrayCount = 3
        if memberList.count < 3 { arrayCount = memberList.count }
        for i in 0..<arrayCount {
            let model = memberList[i]
            let nameStr = model.getMemberNickName()
            if i == 2{
                groupName.append(contentsOf: "\(nameStr)")
            }else{
                groupName.append(contentsOf: "\(nameStr)、")
            }
        }
//        let customName = groupName.subStringToIndex(groupName.count)
        return groupName
    }
    
    public func kickOut() {
        
        if let videoCallJid = CustomUtil.getRoomJid() {
            
            if videoCallJid == self.jid{
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.init(kLoginoutNoti), object: nil, userInfo: nil)
                }
            }
            
        }
        
        CODGroupMemberRealmTool.deleteMember(roomId: self.roomID, jid: UserManager.sharedInstance.jid)
        try! Realm.init().write {
            self.isValid = false
            self.burn = ""
            self.stickytop = false
            self.mute = false
            self.savecontacts = false
            
            if let chatlist = CODChatListRealmTool.getChatList(id: self.roomID) {
                chatlist.stickyTop = false
                chatlist.count = 0
                chatlist.groupRtc = 0
            }
        }
        
        //TODO: 退群处理
//        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kNotificationUpdateGroupMember), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kUpdateGroupMemberCountNoti), object: nil)
    }
    
    public func setGroupChatModel(_ modelTemp: CODGroupChatModel) {
        roomID = modelTemp.roomID
        name = modelTemp.name
        jid = modelTemp.jid
        customName = modelTemp.customName
        savecontacts = modelTemp.savecontacts
        timingcleanup = modelTemp.timingcleanup
        descriptions = modelTemp.descriptions
        notice = modelTemp.notice
        naturalname = modelTemp.naturalname
        showname = modelTemp.showname
        burn = modelTemp.burn
        mute = modelTemp.mute
        screenshot = modelTemp.screenshot
        stickytop = modelTemp.stickytop
        grouppic = modelTemp.grouppic
        isValid = modelTemp.isValid
        notinvite = modelTemp.notinvite
        xhreferall = modelTemp.xhreferall
        xhshowallhistory = modelTemp.xhshowallhistory
    }
    
    public func setInvalidGroupModel(_ modelTemp: CODGroupChatModel) {
        roomID = modelTemp.roomID
        name = modelTemp.name
        jid = modelTemp.jid
        customName = modelTemp.customName
        timingcleanup = modelTemp.timingcleanup
        descriptions = modelTemp.descriptions
        notice = modelTemp.notice
        naturalname = modelTemp.naturalname
        showname = modelTemp.showname
        screenshot = modelTemp.screenshot
        grouppic = modelTemp.grouppic
        notinvite = modelTemp.notinvite
        lastChatTime = modelTemp.lastChatTime
        lastBurnTime = modelTemp.lastBurnTime
        for memberTemp in modelTemp.member {
            member.append(memberTemp)
        }
        createDate = modelTemp.createDate
        isValid = false
        burn = "0"
        stickytop = false
        mute = false
        savecontacts = false
        xhreferall = false
        xhshowallhistory = false
    }
}

class CODGroupChatHJsonModel: HandyJSON {
    required init() {}
    
    var roomID :Int = 0
    var name = ""                 ///群JID
    var jid = ""
    var savecontacts :Bool = false     ///保存到通讯录
    var timingcleanup :Bool = false    ///定时清理
    var notice = ""     /// 群公告
    var userid = ""     ///群链接
    var description = ""    /// ：cod_60000007
    var naturalname = ""     /// ：cod_60000007
    var burn :String = ""        /// 阅后即焚
    var mute :Bool = false        /// 消息免打扰
    var screenshot :Bool = false   /// 截屏通知
    var stickytop :Bool = false    /// 置顶聊天
    var showname: Bool = true     /// 显示昵称
    var grouppic = ""              /// 头像ID
    var notinvite: Bool = false    /// 禁止入群
    var topmsg: String = ""    /// 消息置顶
    var xhreferall: Bool = false    /// 群成员@所有人
    var xhshowallhistory: Bool = false
    var userdetail: Bool = true /// 允许查看添加好友
    var canspeak: Bool = true /// 允许群成员聊天
    var readednotice: Bool = false /// 已读公告
}

extension CODGroupChatModel {
    
    func delete() {
        
        try! realm?.safeWrite {
            self.isDelete = true
            self.isValid = false
        }
        

    }
    
}


// 操作数据库
class CODGroupChatRealmTool: CODRealmTools {
    
    public class func createGroupChat(roomID: Int, json: JSON) {
            
        let groupJsonModel = CODGroupChatHJsonModel.deserialize(from: json.dictionaryObject)
        
        if let groupModelT = self.getGroupChat(id: roomID) {
            
            try! Realm().safeWrite {
                groupModelT.setJsonModel(jsonModel: groupJsonModel)
                groupModelT.isDelete = false
                groupModelT.isValid = true
                try! Realm().delete(groupModelT.member)
            }
        }else{
            let groupModel = CODGroupChatModel()
            groupModel.jsonModel = groupJsonModel
            groupModel.isValid = true
            try! Realm().safeWrite {
                try! Realm().add(groupModel, update: .all)
            }
        }
        
        var memberList: [CODGroupMemberModel] = []
        for memberTemp in json["member"].arrayValue {
            
            let memberModel = CODGroupMemberModel()
            memberModel.jsonModel = CODGroupMemberHJsonModel.deserialize(from: memberTemp.dictionaryObject)
            memberModel.memberId = CODGroupMemberModel.getMemberId(roomId: roomID, userName: memberModel.username)
            
            CODGroupMemberRealmTool.deleteMemberById(memberModel.memberId)
            memberList.append(memberModel)
            
        }
        
        CODGroupChatRealmTool.insertGroupMemberByChatId(id: roomID, and: memberList)
                
        if let chatList = CODChatListRealmTool.getChatList(id: roomID) {
            
            try? Realm().safeWrite {
                chatList.groupRtc = json["groupRtc"].int ?? 0
                chatList.groupRtcRoomId = json["groupRtcRoomId"].string ?? ""
                chatList.groupRtcRequester = json["groupRtcRequester"].string ?? ""
            }
            
            if chatList.isInValid == true  {
                chatList.setChatList(isInValid: false)
            }
        } else {
            if let chatList = CODChatListRealmTool.createChatList(chatId: roomID, type: .groupChat) {
                chatList.groupRtc = json["groupRtc"].int ?? 0
                chatList.groupRtcRoomId = json["groupRtcRoomId"].string ?? ""
                chatList.groupRtcRequester = json["groupRtcRequester"].string ?? ""
                try! Realm().safeWrite {
                    try! Realm().add(chatList, update: .all)
                }
            }
        }

    }
    
    /// 增加一个群组
    public class func insertGroupChat(by groupChat: CODGroupChatModel) -> Void {
        let defaultRealm = self.getDB()
        
        try! defaultRealm.write {
            defaultRealm.add(groupChat, update: .all)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
    
    /// 查询所有的群组
    public class func getGroupChatList() -> Results<CODGroupChatModel> {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(CODGroupChatModel.self).filter("isDelete != \(true)")
    }
    
    /// 查询所有的有效的群组
    public class func getAllValidGroupChatList() -> Results<CODGroupChatModel> {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(CODGroupChatModel.self).filter("isValid == \(true) && isDelete != \(true)")
    }
    
    /// 查询所有已保存的群组
    public class func getSavedGroupChatList() -> Results<CODGroupChatModel> {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(CODGroupChatModel.self).filter("savecontacts == \(true) && isValid == \(true) && isDelete != \(true)")
    }
    
    /// 根据主键查询某一项的群组
    public class func getGroupChat(id: Int) -> CODGroupChatModel? {
        let defaultRealm = self.getDB()
        if let model = defaultRealm.object(ofType: CODGroupChatModel.self, forPrimaryKey: id) {
            return model
        }
        return nil
    }
    
    /// 根据群组JID 查询群组
    public class func getGroupChatByJID(by JID : String) -> CODGroupChatModel? {
        let defaultRealm = self.getDB()
        let list = defaultRealm.objects(CODGroupChatModel.self).filter("jid == %@ && isDelete != \(true)", JID)
        var model = CODGroupChatModel()
        guard let modelTemp = list.first else {
            print("————————————查询不到该JID指定的群组————-——————")
            return nil
        }
        model = modelTemp
        return model
    }
    
    ///群组模糊查询
    public class func getGroupChatByKeyword(word : String) -> [CODGroupChatModel]? {
        let list = self.getAllValidGroupChatList().filter("descriptions contains[c] %@", word)
        var array = Array<CODGroupChatModel>()
        guard list.count > 0 else {
            print("————————————查询不到群组————-——————")
            return nil
        }
        for group in list {
            array.append(group)
        }
        return array
    }
    
    /// 根据群ID修改群名称
    public class func modifyGroupChatNameByRoomID(by roomId: Int, newRoomName: String) {
        let defaultRealm = self.getDB()

        if let chatlistModel = CODChatListRealmTool.getChatList(id: roomId) {
            try! Realm.init().write {
                chatlistModel.title = newRoomName
            }

            let _ = CODDownLoadManager.sharedInstance.cod_loadHeader(url: URL(string: chatlistModel.icon.getHeaderImageFullPath(imageType: 1)))
            
            switch chatlistModel.chatTypeEnum {
            case .channel:
                chatlistModel.channelChat?.updateChannel(name:newRoomName)
            case .groupChat:
                if let model = defaultRealm.object(ofType: CODGroupChatModel.self, forPrimaryKey: roomId) {
                    try! defaultRealm.write {
                        model.setValue(newRoomName, forKey: "descriptions")
                    }
                }
            default:
                break
            }
        }
    }
    
    /// 根据群ID更换群主
    public class func updateGroupAdminByRoomID(by roomId: Int, newAdminJid: String, oldAdminJid: String) {
        var memberId = CODGroupMemberModel.getMemberId(roomId: roomId, userName: newAdminJid.subStringTo(string: "@"))
        let newAdmin = CODGroupMemberRealmTool.getMemberById(memberId)
        try! Realm.init().write {
            newAdmin?.userpower = 10
        }
        
        memberId = CODGroupMemberModel.getMemberId(roomId: roomId, userName: oldAdminJid.subStringTo(string: "@"))
        let oldAdmin = CODGroupMemberRealmTool.getMemberById(memberId)
        try! Realm.init().write {
            oldAdmin?.userpower = 30
        }
    }
    
    public class func updateContactModelLastChatTimeStamp(by chatId: Int,lastChatTime: Int,lastChatMsgID: String) {
        if let groupModel = self.getGroupChat(id: chatId) {
            try! Realm.init().write {
                groupModel.lastChatTime = lastChatTime
                groupModel.lastChatMsgID = lastChatMsgID
            }
        }
    }
    
    public class func updateContactModelLastBurnTimeStamp(by chatId : Int, lastBurnTime: Int) {
        if let groupModel = self.getGroupChat(id: chatId) {
            try! Realm.init().write {
                groupModel.lastBurnTime = lastBurnTime
            }
        }
    }
    
    /// 根据群组ID添加群成员
    public class func insertGroupMemberByChatId(id: Int, and memberList: Array<CODGroupMemberModel>) {
        

        do {
            
//            for member in memberList {
//                CODGroupMemberRealmTool.deleteMemberById(member.memberId)
//            }
            
            try Realm().safeWrite {
                
                
                if let groupModel = self.getGroupChat(id: id) {
                    
//                    let members = memberList.filter { model in
//                        let res = groupModel.member.contains { (member) -> Bool in
//                            return member.memberId == model.memberId
//                        }
//                        return !res
//                    }
                    
                    groupModel.member.append(objectsIn: memberList)
                    
                } else if let channel = CODChannelModel.getChannel(by: id) {
                    channel.addMembers(memberList)
                }

            }
            
        } catch {
        }
        
        
//        
//        let groupModelTemp = CODGroupChatModel()
//        groupModelTemp.setGroupChatModel(groupModel)
//        for member in groupModel.member {
//            groupModelTemp.member.append(member)
//        }
//        for member in memberList {
//            groupModelTemp.member.append(member)
//        }
//
//        let defaultRealm = self.getDB()
//        try! defaultRealm.write {
//            defaultRealm.add(groupModelTemp, update: .all)
//        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kUpdateGroupMemberCountNoti), object: nil)
    }
    
    
    /// 根据群组ID删除所有成员
    public class func deleteAllGroupMemberByChatId(id: Int) {
        guard let groupModel = self.getGroupChat(id: id) else {
            print("查询不到指定ID的群")
            return
        }
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            groupModel.member.removeAll()
        }
    }
    
    /// 根据群组ID删除群组
    public class func deleteGroupChatByChatId(id: Int) {
        guard let groupModel = self.getGroupChat(id: id) else {
            print("查询不到指定ID的群")
            return
        }
        groupModel.delete()
    }
    
    /// 根据群组ID删除指定成员,
    /// 自主退群不删除本地群model，需要保留聊天记录
    public class func deleteGroupMemberByChatId(id: Int, and memberJid: String) {
        let memberId = CODGroupMemberModel.getMemberId(roomId: id, userName: memberJid.subStringTo(string: "@"))
        guard let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) else {
            return
        }
        try! Realm.init().write {
            try! Realm.init().delete(memberModel)
        }
    }
    
    /// 根据群组ID更新群信息
    public class func updateGroup(roomId: Int!,
                                  groupType: CODGroupType? = nil, link: String? = nil, notice: String? = nil,
                                  grouppic: String? = nil, topmsg: String? = nil, burn: Int? = nil,
                                  stickytop: Bool? = nil, mute: Bool? = nil, savecontacts: Bool? = nil,
                                  showname: Bool? = nil, canspeak: Bool? = nil, notinvite: Bool? = nil,
                                  xhreferall: Bool? = nil, showallhistory: Bool? = nil, screenshot: Bool? = nil,
                                  userdetail: Bool? = nil) {
        
        guard let group = CODGroupChatRealmTool.getGroupChat(id: roomId) else { return }
        
        do {
            
            let defaultRealm = try Realm()

            try defaultRealm.write {
                
                if let groupType = groupType {
                    group.typeEnum = groupType
                }
                
                if let link = link {
                    group.userid = link
                }
                
                if let stickytop = stickytop {
                    if let chatList = defaultRealm.object(ofType: CODChatListModel.self, forPrimaryKey: roomId) {
                        chatList.stickyTop = stickytop
                    }
                    group.stickytop = stickytop
                }

                if let notice = notice {
                    group.notice = notice
                }
                
                if let mute = mute {
                    group.mute = mute
                }
                
                if let savecontacts = savecontacts {
                    group.savecontacts = savecontacts
                }
                
                if let topmsg = topmsg {
                    group.topmsg = topmsg
                }
                
                if let grouppic = grouppic {
                    
                    if let chatList = defaultRealm.object(ofType: CODChatListModel.self, forPrimaryKey: roomId) {
                        chatList.icon = grouppic
                    }
                    
                    group.grouppic = grouppic
                }
                
                if let showname = showname {
                    group.showname = showname
                }
                
                if let canspeak = canspeak {
                    group.canspeak = canspeak
                }
                
                if let notinvite = notinvite {
                    group.notinvite = notinvite
                }
                
                if let xhreferall = xhreferall {
                    group.xhreferall = xhreferall
                }
                
                if let showallhistory = showallhistory {
                    group.xhshowallhistory = showallhistory
                }
                
                if let burn = burn {
                    group.burn = "\(burn)"
                }
                
                if let screenshot = screenshot {
                    group.screenshot = screenshot
                }
                
                if let userdetail = userdetail {
                    group.userdetail = userdetail
                }
            }
            
        } catch {
        }

    }
    
    
    /// 设置群管理员，不区分群组频道
    public class func setAdmins(roomID: Int, jids: Array<String>, isAdd: Bool) {
        for jid in jids{
            let memberId = CODGroupMemberModel.getMemberId(roomId: roomID, userName: jid)
            if let member = CODGroupMemberRealmTool.getMemberById(memberId) {
                try! Realm.init().write {
                    if isAdd {
                        member.userpower = 20
                    } else {
                        member.userpower = 30
                    }
                }
            }
        }
    }
    
}



extension CODGroupChatModel {
    public class func getLocalGroupChatList() {
        let list = CODGroupChatRealmTool.getGroupChatList()
        for groupChat in list {
            XMPPManager.shareXMPPManager.joinGroupChatWith(groupJid: groupChat.jid)
        }
    }
    
    public func getGroupName() -> String {
        if descriptions.count > 0 {
            return descriptions
        }else{
            return customName
        }
    }
    
    public func getGroupNameForDetailVC() -> String {
        if descriptions.count > 0 {
            return descriptions
        }else{
            return "未命名"
        }
    }
    
    public func getGroupNoticeForDetailVC() -> String {
        if notice.count > 0 {
            return notice
        }else{
            return "未设置"
        }
    }
    
    func getMember(jid:String?) -> CODGroupMemberModel? {
        
        return self.member.filter("jid == %@",jid ?? "").first
    }
    
}
