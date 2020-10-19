//
//  CODGroupMemberModel.swift
//  COD
//
//  Created by XinHoo on 2019/4/2.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RealmSwift
import HandyJSON

class CODGroupMemberModel: Object, NSMutableCopying {
    func mutableCopy(with zone: NSZone? = nil) -> Any {
        let object = CODGroupMemberModel()
        for propertyName in CODGroupMemberModel.propertyList() {
            object.setValue(self.value(forKey: propertyName), forKeyPath: propertyName)
        }
        return object
    }
    
    
    /// RoomId+Username
    @objc dynamic var memberId = ""
    
    /// cod_60000003
    @objc dynamic var username = ""
    @objc dynamic var usernameNumber = 0
    
    ///用户名
    @objc dynamic var userdesc = ""
    
    ///昵称
    @objc dynamic var name = ""
    
    ///群昵称
    @objc dynamic var nickname = ""
    
    @objc dynamic var userpic = ""
    
    @objc dynamic var gender = ""
    
    @objc dynamic var color = ""
    
    /// cod_60000003@cod.xinhoo.com
    @objc dynamic var jid = ""
    
    /// 10:群主；20:管理员；30:成员
    @objc dynamic var userpower = 0
    
    @objc dynamic var pinYin = ""
    
    @objc dynamic var status = ""
    var isActive: Bool {
        return status != "REMOVE"
    }
    
    @objc dynamic var loginStatus = ""
    
    @objc dynamic var lastlogintime = 0
    
    @objc dynamic var lastLoginTimeVisible: Bool = true
    
    /// U 是用户, B 是机器人
    @objc dynamic var userType = "U"
    
    var userTypeEnum: UserType {
        return UserType(str: self.userType)
    }

    var jsonModel: CODGroupMemberHJsonModel? {
        didSet{
            if let modelTemp = jsonModel {
                username = modelTemp.username
                usernameNumber = modelTemp.username.toUserNameNumber()
                userdesc = modelTemp.userdesc
                userpic = modelTemp.userpic
                name = modelTemp.name.aes128DecryptECB(key: .nickName)
                gender = modelTemp.gender
                color = modelTemp.color
                nickname = modelTemp.nickname.aes128DecryptECB(key: .nickName)
                
                if let contact = CODContactRealmTool.getContactByJID(by: modelTemp.jid) {
                    if contact.nick.count > 0 {
                        pinYin = ChineseString.getPinyinBy(contact.nick)
                    }else{
                        pinYin = ChineseString.getPinyinBy(modelTemp.zzs_getMemberNickName())
                    }
                }else{
                    pinYin = ChineseString.getPinyinBy(modelTemp.zzs_getMemberNickName())
                }
                
                jid = modelTemp.jid
                userpower = modelTemp.userpower
                status = modelTemp.status
                userType = modelTemp.xhtype
            }
        }
    }
    
    override static func primaryKey() -> String? {
        return "memberId"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["jsonModel"]
    }
    
    override static func indexedProperties() -> [String] {
        return ["name","jid"]
    }
}

class CODGroupMemberHJsonModel : HandyJSON{
    required init() {}

    var username = ""
    var userdesc = ""
    var nickname = ""
    var userpic = ""
    var gender = ""
    var color = ""
    var name = ""
    var jid = ""
    var userpower = 0
    var status = ""
    var xhtype: String = "U" /// U 是用户, B 是机器人
    
    @objc public func zzs_getMemberNickName() -> String {
        if nickname.count > 0 {
            return nickname
        }else{
            return name
        }
    }
}

// 操作数据库
class CODGroupMemberRealmTool: CODRealmTools {
    
    /// 根据群组中的成员ID
    public class func searchMemberPic(_ memberId: String) -> String? {
        guard let memberModel = self.getMemberById(memberId) else{
            return nil
        }
        return memberModel.userpic
    }
    
    /// 根据群组中的成员JID查找群成员name
    public class func searchMemberName(memberId: String) -> String? {
        guard let memberModel = self.getMemberById(memberId) else {
            return nil
        }
        return memberModel.name
    }
    
    /// 根据群组中的成员ID查找群成员Model
    public class func getMemberById(_ memberId: String) -> CODGroupMemberModel? {
        let defaultRealm = self.getDB()
        guard let model = defaultRealm.object(ofType: CODGroupMemberModel.self, forPrimaryKey: memberId) else {
            return nil
        }
        return model
    }
    
    public class func getMember(roomId: Int, jid: String) -> CODGroupMemberModel? {
        let memberId = self.getMemberId(roomId: roomId, jid: jid)
        
        return self.getMemberById(memberId)
    }
    
    /// 根据群组中的成员JID查找所有群成员Model
    public class func getMembersResultsByJid(_ memberJid: String) -> Results<CODGroupMemberModel> {
        let defaultRealm = self.getDB()
        let models = defaultRealm.objects(CODGroupMemberModel.self).filter("jid contains %@", memberJid)
        return models
    }

    public class func getMembersByJid(_ memberJid: String) -> Array<CODGroupMemberModel>? {
        let models = self.getMembersResultsByJid(memberJid)
        if models.count > 0 {
            var modelsTemp: Array<CODGroupMemberModel> = Array.init()
            for model in models {
                modelsTemp.append(model)
            }
            
            return modelsTemp
        }else{
            return nil
        }
    }
    
    /// 根据群组中的成员ID删除群成员Model
    public class func deleteMemberById(_ memberId: String) {
        let defaultRealm = self.getDB()
        if let model = defaultRealm.object(ofType: CODGroupMemberModel.self, forPrimaryKey: memberId) {
            try! defaultRealm.write {
                defaultRealm.delete(model)
            }
        }
    }
    
    public class func deleteMember(roomId: Int, jid: String) {
        let defaultRealm = self.getDB()
        if let model = defaultRealm.object(ofType: CODGroupMemberModel.self, forPrimaryKey: self.getMemberId(roomId: roomId, jid: jid)) {
            
            if defaultRealm.isInWriteTransaction {
                defaultRealm.delete(model)
            } else {
                try! defaultRealm.write {
                    defaultRealm.delete(model)
                }
            }
            
        }
    }
    
    public class func getMemberId(roomId: Int, jid: String) -> String {
        
        var name = jid
        
        if jid.contains(XMPPDomainTemp) {
            name = jid.subStringTo(string: "@")
        }
        
        let str = String(format: "%d%@", roomId, name)
        return str
    }
}

extension CODGroupMemberModel {

    class func propertyList() -> [String] {
        // 接受属性个数
        var count: UInt32 = 0
        // 1. 获取"类"的属性列表,返回属性列表的数组,可选项
        let list = class_copyPropertyList(self, &count)
        // 2. 遍历
        
        var proNames = Array<String>()
        
        for i in 0..<Int(count) {
            // 3. 根据下标获取属性
            let pty = list?[i] // objc_property_t?
            // 4. 获取'属性'的名称 C语言字符串
            // Int8 -> Byte -> Char => C 语言的字符串
            let  cName = property_getName(pty!)
            // 5. 转换成String 的字符串
            let name = String(utf8String: cName)!
            proNames.append(name)
        }
        // 释放C 语言的对象
        free(list)
        return proNames
    }
    
    public class func getMemberId(roomId: Int, userName: String) -> String {
        
        var name = userName
        
        if userName.contains(XMPPDomainTemp) {
            name = userName.subStringTo(string: "@")
        }
        
        let str = String(format: "%d%@", roomId, name)
        return str
    }
    
    
    /// 获取群成员昵称，优先获取我对该成员（是我好友）的备注名
    ///
    /// - Returns: 群成员昵称
    @objc public func getMemberNickName() -> String {
        if let contact = CODContactRealmTool.getContactByJID(by: self.jid) {
            if contact.nick.count > 0 {
                return contact.nick
            }
        }
        if nickname.count > 0 {
            return nickname
        }else{
            return name
        }
    }
    
    @objc public func zzs_getMemberNickName() -> String {
        if nickname.count > 0 {
            return nickname
        }else{
            return name
        }
    }
    
    /// 获取群成员昵称，优先获取该成员在本群的昵称
    ///
    /// - Returns: 群成员昵称
    @objc public func getTheGroupNickName() -> String{
        if nickname.count > 0 {
            return nickname
        }else{
            return name
        }
    }
    
    public class func isGroupMemberForMe(byRoomId roomId: Int) -> Bool {
        let memberId = CODGroupMemberModel.getMemberId(roomId: roomId, userName: UserManager.sharedInstance.loginName ?? "")
        if let _ = CODGroupMemberRealmTool.getMemberById(memberId) {
            return true
        }
        return false
    }
    
    
    class func removeMembers(_ members: [CODGroupMemberModel]) {
        
        do {
            
            let defaultRealm = try Realm()
            
            let write = {
                defaultRealm.delete(members)
            }
            
            if defaultRealm.isInWriteTransaction {
                write()
            } else {
                try defaultRealm.write(write)
            }
            
        } catch {
        }
        
    }
    
}

class CODGroupMemberOnlineModel : HandyJSON{
    required init() {}
    
    var active = ""
    var userName = ""
    var lastlogintime = 0
    var lastLoginTimeVisible = true
}


extension Sequence where Element: CODGroupMemberModel {
    
    func chennalMemberSorted() -> [CODGroupMemberModel] {
        
        var members: [Self.Element] = []
        
        members.append(contentsOf: self)

        return members.sorted { (value1, value2) -> Bool in
            
            let value1First =  value1.pinYin.first
            let value2First =  value2.pinYin.first
            
            
            let isLetterValue1 = value1First?.isLetter ?? false
            let isLetterValue2 = value2First?.isLetter ?? false
            
            if isLetterValue1 == isLetterValue2 {
                
                if value1First == value2First {
                    return value1.name < value2.name
                } else {
                    return value1.pinYin < value2.pinYin
                }

            } else if isLetterValue1 == true {
                return true
            } else if isLetterValue2 == true {
                return false
            } else {
                return value1.name < value2.name
            }
        }
        
    }
    
    
    
    
    
}

extension List where Element: CODGroupMemberModel {
    
    func getOnlineMembers() -> Results<Element> {
        return self.filter("loginStatus CONTAINS[c] 'ONLINE'")
    }
    
    func getOfflineMembers() -> Results<Element> {
        return self.filter("NOT loginStatus  CONTAINS[c] 'ONLINE' ")
    }
    
}

extension Results where Element: CODGroupMemberModel {
    
    func groupMemberSorted() -> Results<Element> {
        return self.sorted(byKeyPath: "usernameNumber")
    }
    
    
    
}

