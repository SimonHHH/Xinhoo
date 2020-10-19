//
//  CODAddFriendModel.swift
//  COD
//
//  Created by 1 on 2019/4/10.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON
import RealmSwift
enum CODNewFriendStatus:Int {
    case beAdd = 1 //添加
    case added = 5 //已添加
    case recived = 10 //接受
    case isValidation = 20 //正在等待验证
    
}

class CODAddFriendModel:Object, HandyJSON {
    
    @objc dynamic var requester = ""
    @objc dynamic var sender = ""
    @objc dynamic var receiver = ""
    @objc dynamic var chatType = ""
    @objc dynamic var msgType = ""
    @objc dynamic var burn = ""
    @objc dynamic var body = ""
    @objc dynamic var sendTime = ""
    @objc dynamic var owner = ""
    @objc dynamic var userpic = ""
    @objc dynamic var haveRead = false


    var addType: CODNewFriendStatus = .beAdd {
        didSet{
            isAddStatus = addType.rawValue
        }
    }
    
    //1.添加 5.已添加 10.接受 20.正在等待验证
    @objc dynamic var isAddStatus = 0

    @objc dynamic var setting: CODAddSettingModel?

    override static func primaryKey() -> String? {
        return  "sendTime"
    }
    override static func indexedProperties() -> [String] {
        return ["sender"]
    }
}
class CODAddSettingModel:Object, HandyJSON{

    @objc dynamic var desc = ""
    @objc dynamic var request: CODAddRequestModel?
    @objc dynamic var name = ""
    @objc dynamic var userdesc = ""
    @objc dynamic var userpic = ""
    @objc dynamic var username = ""
    @objc dynamic var tel = ""
    @objc dynamic var gender = ""

    
    @objc dynamic var xhaddincard = 0
    @objc dynamic var xhnoticedetail = 0
    @objc dynamic var xhtel = 0
    @objc dynamic var xhcallVisible = true
    @objc dynamic var xhinviteJoinRoomVisible = true
    @objc dynamic var xhinvitejoinchannel = true
    @objc dynamic var xhmessageVisible = true
    @objc dynamic var xhlastlogintime = 0
    @objc dynamic var xhnotice = 0
    @objc dynamic var xhdefaultpic = 0
    @objc dynamic var xhvoipnotice = 0
    @objc dynamic var xhcolor = ""
    @objc dynamic var xhlastLoginTimeVisible = true
    
    @objc dynamic var xhareacode = ""
    @objc dynamic var xhaddingroup = 0
    @objc dynamic var xhaddinqrcode = 0
}
class CODAddRequestModel:Object, HandyJSON{
    @objc dynamic var desc = ""
}
// 操作数据库
class CODAddFriendRealmTool: CODRealmTools {
    //删除好友
    public class func deleteAddFriend(by addFriend : CODAddFriendModel) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.delete(addFriend)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }

    /// 增加新的好友添加
    public class func insertAddFriend(by addFriend : CODAddFriendModel) -> Void {
        let defaultRealm = self.getDB()
        
        try! defaultRealm.write {
            defaultRealm.add(addFriend, update: .all)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
    
    /// 查询所有的添加好友
    public class func getAddFriendList() -> Results<CODAddFriendModel> {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(CODAddFriendModel.self)
    }
    /// 查询所有的添加好友
    public class func readAllAddFriend() {
        let defaultRealm = self.getDB()
        let newFriendArrray = defaultRealm.objects(CODAddFriendModel.self);
        
        try! defaultRealm.write {
            for model in newFriendArrray {
                model.haveRead = true
            }
        }
        
    }
    
    /// 更新指定JID的好友申请的已读状态
    public class func updateReadAllAddFriend(fromJID JID: String, isRead:Bool) {
        let defaultRealm = self.getDB()
        if let newFriendModel = self.getAddFriend(fromJID: JID) {
            try! defaultRealm.write {
                newFriendModel.haveRead = isRead
            }
        }
    }
    
    /// 查询指定JID的添加好友
    public class func getAddFriend(fromJID JID: String) -> CODAddFriendModel? {
        let defaultRealm = self.getDB()
        let list = defaultRealm.objects(CODAddFriendModel.self).filter("sender == %@", JID)
        return list.first
    }
    
    /// 查询某ID好友
    public class func getAddFriend(fromPrimaryKey id : Int) -> CODAddFriendModel? {
        let defaultRealm = self.getDB()
        return defaultRealm.object(ofType:CODAddFriendModel.self, forPrimaryKey: id)
    }
    
    //删除好友请求
    public class func deleteAddFriendApple(by JID: String) {
        let defaultRealm = self.getDB()
        if let addFriendModel = self.getAddFriend(fromJID: JID) {
            try! defaultRealm.write {
                defaultRealm.delete(addFriendModel)
            }
        }
    }
    

    ///好友模糊查询
    public class func getContactBySender(requester : String) -> [CODAddFriendModel]? {
        let defaultRealm = self.getDB()
        let list = defaultRealm.objects(CODAddFriendModel.self).filter("sender == %@", requester)
        var array = Array<CODAddFriendModel>()
        guard list.count > 0 else {
            print("————————————查询不到联系人————-——————")
            return nil
        }
        for contact in list {
            array.append(contact)
        }
        return array
    }
}

