//
//  CODRealmTools.swift
//  COD
//
//  Created by XinHoo on 2019/3/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RealmSwift

class CODRealmTools: NSObject {
    typealias ReturnSuccessBlock = () ->Void
    var returnSuccessBlock:ReturnSuccessBlock?
    
    var contactNotificationToken: NotificationToken? = nil    

    static var `default`: CODRealmTools  = CODRealmTools()
    public func configRealm() {
        /// 如果要存储的数据模型属性发生变化,需要配置当前版本号比之前大

        let dbVersion : UInt64 = 178
        
        let change220dbVersion: UInt64 = 172
        
        let change2181dbVersion: UInt64 = 168
        
        let change2168dbVersion: UInt64 = 165
        
        let change216dbVersion: UInt64 = 165
        
        let change215dbVersion: UInt64 = 164
        
        let change211dbVersion: UInt64 = 160

        let change210dbVersion: UInt64 = 155

        
        let change290dbVersion: UInt64 = 148
        
        let change280dbVersion: UInt64 = 145

        let change260dbVersion : UInt64 = 131
        
        // 1.11.2 版本修改 CODGroupChatModel ( isFristJoin -> readednotice)
        let change111dbVersion : UInt64 = 103
        
        // 1.10.0 版本修改
        let change110dbVersion : UInt64 = 102

        // 1.7.0 版本修改 CODChatListModel ( isAt -> atCount)
        let changeDBVersion : UInt64 = 88
        // 1.7.0 版本支持频道功能
        let changeDBVersion2: UInt64 = 89
        
        // 升级 Realm 版本
        let changeDBVersion3: UInt64 = 90

        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let dbPath = docPath.appending("/\(UserManager.sharedInstance.loginName!).realm")
        print("数据库存储地址:\(dbPath)")
        let config = Realm.Configuration(fileURL: URL.init(string: dbPath), inMemoryIdentifier: nil, syncConfiguration: nil, encryptionKey: nil, readOnly: false, schemaVersion: dbVersion, migrationBlock: { (migration, oldSchemaVersion) in
            
            if oldSchemaVersion < change220dbVersion {
                
                migration.enumerateObjects(ofType: CODGroupMemberModel.className()) { (oldObject, newObject) in
                    
                    if let username = oldObject?["username"] as? String {
                        newObject?["usernameNumber"] = username.toUserNameNumber()
                    }

                }
                
            }
            
            if oldSchemaVersion < change2181dbVersion {
                migration.enumerateObjects(ofType: AudioModelInfo.className()) { (oldObject, newObject) in
                    
                    if let audioLocalURL = oldObject?["audioLocalURL"] as? String {
                    
                        newObject?["audioLocalURL"] = audioLocalURL.lastPathComponent.deletingPathExtension
                    }
                    
                    
                }
            }
            
            if oldSchemaVersion < change2168dbVersion {
                migration.enumerateObjects(ofType: CODGroupMemberModel.className()) { (oldObject, newObject) in
                    newObject?["userType"] = "U"
                }
            }
            
            if oldSchemaVersion < change216dbVersion {
                migration.enumerateObjects(ofType: CODContactModel.className()) { (oldObject, newObject) in
                    newObject?["userType"] = "U"
                }
            }
            
            
            if oldSchemaVersion < change215dbVersion {
                migration.enumerateObjects(ofType: FileModelInfo.className()) { (oldObject, newObject) in
                    newObject?["localFileID"] = UUID().uuidString
                }
            }
            
            if oldSchemaVersion < change211dbVersion {
                migration.enumerateObjects(ofType: CODContactModel.className()) { (oldObject, newObject) in
                    guard let nick = oldObject?["nick"] as? String, let name = oldObject?["name"] as? String else {
                        return
                    }
                    if nick.count > 0 {
                        newObject?["pinYin"] = ChineseString.getPinyinBy(nick)
                    }else{
                        newObject?["pinYin"] = ChineseString.getPinyinBy(name)
                    }
                }
            }
            
            if oldSchemaVersion < change210dbVersion {
                migration.enumerateObjects(ofType: PhotoModelInfo.className()) { (oldObject, newObject) in
                    
                    if let serverImageId = newObject?["serverImageId"] as? String {
                    
                        if serverImageId.count == 0 {
                            
                            if let photoImageURL = oldObject?["photoImageURL"] as? String, photoImageURL.count != 0 {
                            
                                newObject?["serverImageId"] = CustomUtil.getPictureID(picUrl: URL(string: photoImageURL))
                            }
                            
                            
                        }
                        
                    }
                    
                    
                }
                
                
                
                migration.enumerateObjects(ofType: VideoModelInfo.className()) { (oldObject, newObject) in
                    
                    if let serverImageId = newObject?["serverVideoId"] as? String {
                    
                        if serverImageId.count == 0 {
                            
                            if let videoURL = oldObject?["videoURL"] as? String, videoURL.count != 0 {
                            
                                newObject?["serverVideoId"] = CustomUtil.getPictureID(picUrl: URL(string: videoURL))
                            }
                            
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
            if oldSchemaVersion < change290dbVersion {
                migration.enumerateObjects(ofType: CODDiscoverNewMessageModel.className()) { (oldObject, newObject) in
                    newObject?["read"] = 1
                }
            }
            
            if oldSchemaVersion < change280dbVersion {
                
                migration.enumerateObjects(ofType: VideoModelInfo.className()) { (oldObject, newObject) in
                    newObject?["videoId"] = UUID().uuidString
                }
                
            }
            
            if oldSchemaVersion < change260dbVersion {
                
                migration.enumerateObjects(ofType: PhotoModelInfo.className()) { (oldObject, newObject) in
                    newObject?["photoId"] = UUID().uuidString
                }
                
            }
            
            if oldSchemaVersion == change111dbVersion {
                migration.enumerateObjects(ofType: CODGroupChatModel.className()) { (oldObject, newObject) in
                    if let isFristJoin = oldObject?["isFristJoin"] {
                        newObject?["readednotice"] = isFristJoin
                    }
                }
            }
            
            if oldSchemaVersion < change110dbVersion {
                
                migration.enumerateObjects(ofType: CODGroupChatModel.className()) { oldObject, newObject in
                    newObject?["canspeak"] = true
                }
                
            }
            
            if (oldSchemaVersion < changeDBVersion2) {

                migration.enumerateObjects(ofType: CODChatListModel.className()) { oldObject, newObject in

                    guard let isGroup = oldObject?["isGroup"] as? Bool else {
                        return
                    }
                    
                    if isGroup {
                        newObject?["chatType"] = CODMessageChatType.groupChat.rawValue
                    } else {
                        newObject?["chatType"] = CODMessageChatType.privateChat.rawValue
                    }
                }
                
                migration.enumerateObjects(ofType: CODMessageModel.className()) { oldObject, newObject in
                    
                    guard let isGroup = oldObject?["isGroupChat"] as? Bool else {
                        return
                    }
                    
                    if isGroup {
                        newObject?["chatType"] = CODMessageChatType.groupChat.rawValue
                    } else {
                        newObject?["chatType"] = CODMessageChatType.privateChat.rawValue
                    }
                    
                }
            }
            

            if oldSchemaVersion < changeDBVersion {
                
                migration.enumerateObjects(ofType: CODChatListModel.className()) { (oldObject, newObject) in
                    
                    let isAt = oldObject?["isAt"] as? Bool
                    
                    if isAt == true {
                        newObject!["atCount"] = 1
                    } else {
                        newObject!["atCount"] = 0
                    }

                }
                
            }
            
            if (oldSchemaVersion < changeDBVersion3) {
                
                migration.enumerateObjects(ofType: CODMessageModel.className()) { (oldObject, newObject) in
                    newObject!["imageHeight"] = Float(oldObject!["imageHeight"] as! Double)
                    newObject!["imageWidth"] = Float(oldObject!["imageWidth"] as! Double)
                    
                }
                
                migration.enumerateObjects(ofType: PhotoModelInfo.className()) { (oldObject, newObject) in
                    newObject!["w"] = Float(oldObject!["w"] as! Double)
                    newObject!["h"] = Float(oldObject!["h"] as! Double)
                }
                
                migration.enumerateObjects(ofType: AudioModelInfo.className()) { (oldObject, newObject) in
                    newObject!["audioDuration"] = Float(oldObject!["audioDuration"] as! Double)
                }
                
                migration.enumerateObjects(ofType: VideoModelInfo.className()) { (oldObject, newObject) in
                    newObject!["w"] = Float(oldObject!["w"] as! Double)
                    newObject!["h"] = Float(oldObject!["h"] as! Double)
                    newObject!["videoDuration"] = Float(oldObject!["videoDuration"] as! Double)
                }
                
            }

        }, deleteRealmIfMigrationNeeded: false, shouldCompactOnLaunch: nil, objectTypes: nil)
        
        Realm.Configuration.defaultConfiguration = config
        
        
        Realm.asyncOpen { (realm, error) in
            if let _ = realm {
                print("Realm 服务器配置成功!")

//                NotificationCenter.default.post(name: NSNotification.Name.init(kConfigRealmSuccess), object: nil, userInfo: nil)
                if self.returnSuccessBlock != nil {
                    self.returnSuccessBlock!()
                }
                
                FileModelInfo.dowloadingTypeSetToNone()

            }else if let error = error {
                print("Realm 数据库配置失败：\(error.localizedDescription)")
            }
        }
    }
    
    public class func getDB() -> Realm {
//        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
//        let dbPath = docPath.appending("/\(UserManager.sharedInstance.loginName!).realm")
        /// 传入路径会自动创建数据库
        let defaultRealm = try! Realm()
        
        return defaultRealm
    }
    
}
extension CODRealmTools{
    /// 获取当前默认的数据
    ///
    /// - Returns: 返回默认的Realm的数据库实例
    @discardableResult
    public func getDefaultRealm() -> Realm? {
        do {
            return try Realm()
        }catch let error {
            print("获取默认的Realm的数据库失败:\n\(error.localizedDescription)")
            return nil
        }
    }
    
    
    //MARK: - 增
    /// 创建表 || 更新表
    ///
    /// - Parameters:
    ///   - type: 表向对应的对象
    ///   - value: 值
    ///   - update: 是否是更新, 如果是"true", Realm会查找对象并更新它, 否则添加对象
    ///   - result: 最后添加对象是成功, 如果成功将对象返回
    public func creatObject(_ type: RealmSwift.Object.Type, value: Any? = nil, update: Bool = false, result: ((RealmSwift.Object?, Error?) -> Void)? = nil){
        let realm = getDefaultRealm()
        do {
            try realm?.write {
                let object = (value == nil) ? realm?.create(type) : realm?.create(type, value: value!, update: .all)
                result?(object, nil)
            }
        } catch let error {
            print("获取默认的Realm的数据库失败:\n\(error.localizedDescription)")
            result?(nil, error)
        }
    }
    
    /// 添加数据 || 根据主键更新数据
    ///
    /// - Parameters:
    ///   - object: 要添加的数据
    ///   - update: 是否更新, 如果是true
    ///   - result: 添加数据的状态
    public func addObject(_ object: RealmSwift.Object, update: Realm.UpdatePolicy = .error, result: ((Error?) -> Void)? = nil) {
        let realm = getDefaultRealm()
        do {
            try realm?.write {
                realm?.add(object, update: update)
                result?(nil)
            }
        } catch let error {
            print("添加数据失败:\n \(error.localizedDescription)")
            result?(error)
        }
    }
    
    //MARK: - 删
    /// 删除数据
    ///
    /// - Parameters:
    ///   - object: 要删除的对象
    ///   - result: 删除的状态
    public func deleteObject(_ object: RealmSwift.Object, result: ((Error?) -> Void)? = nil) {
        let realm = getDefaultRealm()
        do {
            try realm?.write {
                realm?.delete(object)
                result?(nil)
            }
        } catch let error {
            print("删除数据失败:\n \(error.localizedDescription)")
            result?(error)
        }
    }
    
    /// 删除当前数据库中所有的数据
    ///
    /// - Parameter result: 删除的状态
    public func deleteAllObject(result: ((Error?) -> Void)? = nil) {
        let realm = getDefaultRealm()
        do {
            try realm?.write {
                realm?.deleteAll()
                result?(nil)
            }
        } catch let error {
            print("添加数据失败:\n \(error.localizedDescription)")
            result?(error)
        }
    }
    
    /// 删除当前打开的数据库
    ///
    /// - Parameter dataBaseName: 数据库的名字
    /// - Returns: 删除的状态
    @discardableResult
    public func deleteCreatDBFile() -> Bool {
        return  autoreleasepool { () -> Bool in
            let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
            let realmURLs = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("note"),
                realmURL.appendingPathExtension("management")
            ]
            for URL in realmURLs {
                do {
                    try FileManager.default.removeItem(at: URL)
                    return true
                } catch {
                    // 错误处理
                    return false
                }
            }
            return false
        }
    }
    
    
    //MARK: - 改
    /// 根据主键进行更新
    ///
    /// - Parameters:
    ///   - object: 要更新的对象
    ///   - update: 是否根据主键更新, 如果是"false"则是添加数据
    ///   - result: 更新数据的结果
    public func updateObject(_ object: RealmSwift.Object, update: Realm.UpdatePolicy = .all, result: ((Error?) -> Void)? = nil) {
        
        addObject(object, update: update, result: result)
    }
    
    
    /// 根据主键进行更新
    ///
    /// - Parameters:
    ///   - type: 要更新的对象类型
    ///   - value: 要更新的值, 例如: ["id": 1, "price": 9000.0]
    ///   - update: 是否根据主键进行更新, 如果为"false"则为创建表
    ///   - result: 更新的结果
    public func updateObject(_ type: RealmSwift.Object.Type, value: Any? = nil, update: Bool = true, result: ((RealmSwift.Object?, Error?) -> Void)? = nil) {
        creatObject(type, value: value, update: update, result: result)
    }
    
    
    /// 直接更新对象
    ///
    /// - Parameters:
    ///   - property: 要更改的属性
    ///   - value: 更改的值
    /// - Returns: 更改的结果
    @discardableResult
    public func updateObject( property: inout Any, value: Any) -> Bool {
        let realm = getDefaultRealm()
        do {
            try realm?.write {
                property = value
            }
            return true
        } catch let error {
            print("直接更新对象属性错误: \(error.localizedDescription)")
            return false
        }
    }
    
    
    /// 更改表中所有的字段的值
    ///
    /// - Parameters:
    ///   - type: 表的对象类型
    ///   - key: 要更改的字段名
    ///   - value: 更改的值
    /// - Returns: 返回更改结果
    public func updateObjects(type: RealmSwift.Object.Type, key: String, value: Any) -> Bool {
        let objects = getObjects(type: type)
        do {
            try getDefaultRealm()?.write {
                objects?.setValue(value, forKey: key)
            }
            return true
        } catch let error {
            print("更改一个表中的所有数据错误: \(error.localizedDescription)")
            return false
        }
    }
    
    
    /// 根据主键进行对某个对象中的数据进行更新
    ///
    /// - Parameters:
    ///   - type: 表类型
    ///   - primaryKey: 主键
    ///   - key: 要更改属性
    ///   - value: 更改的值
    /// - Returns: 更改的状态
    public func updateObject(type: RealmSwift.Object.Type, primaryKey: Any, key: String, value: Any) -> Bool {
        let object = getObjectWithPrimaryKey(type: type, primaryKey: primaryKey)
        do {
            try getDefaultRealm()?.write {
                object?.setValue(value, forKeyPath: key)
            }
            return true
        } catch let error {
            print("更新数据出错: \(error.localizedDescription)")
            return false
        }
    }
    
    //MARK: - 查
    /// 查找一个表中的所有的数据
    ///
    /// - Parameter type: 对象类型
    /// - Returns: 查到的数据
    public func getObjects(type: RealmSwift.Object.Type) -> RealmSwift.Results<RealmSwift.Object>?{
        return getDefaultRealm()?.objects(type)
    }
    
    /// 根据主键查找某个对象
    ///
    /// - Parameters:
    ///   - type: 对象类型
    ///   - primaryKey: 主键
    /// - Returns: 查到的数据
    public func getObjectWithPrimaryKey(type: RealmSwift.Object.Type, primaryKey: Any) -> RealmSwift.Object? {
        return getDefaultRealm()?.object(ofType: type, forPrimaryKey: primaryKey)
    }
    
    
    /// 使用断言字符串查询
    ///
    /// - Parameters:
    ///   - type: 对象类型
    ///   - filter: 过滤条件
    /// - Returns: 查询到的数据
    /// - example:
    ///   - var tanDogs = realm.objects(Dog.self).filter("color = 'tan' AND name BEGINSWITH 'B'")
    public func getObject(type: RealmSwift.Object.Type, filter: String) -> RealmSwift.Results<RealmSwift.Object>? {
        return getObjects(type: type)?.filter(filter)
    }
    
    
    /// 使用谓词进行查询
    ///
    /// - Parameters:
    ///   - type: 对象类型
    ///   - predicate: 谓词对象
    /// - Returns: 查询到的数据
    /// - example:
    ///   - let predicate = NSPredicate(format: "color = %@ AND name BEGINSWITH %@", "tan", "B")
    ///   - tanDogs = realm.objects(Dog.self).filter(predicate)
    public func getObject(type: RealmSwift.Object.Type, predicate: NSPredicate) -> RealmSwift.Results<RealmSwift.Object>? {
        return getObjects(type: type)?.filter(predicate)
    }
    
    
    /// 对查询的数据进行排序,请注意, 不支持 将多个属性用作排序基准，此外也无法链式排序（只有最后一个 sorted 调用会被使用）。 如果要对多个属性进行排序，请使用 sorted(by:) 方法，然后向其中输入多个 SortDescriptor 对象。
    ///
    /// - Parameters:
    ///   - type: 对象类型
    ///   - filter: 过滤条件
    ///   - sortedKey: 需要排序的字段
    /// - Returns: 最后的结果
    public func getObject(type: RealmSwift.Object.Type, filter: String, sortedKey: String) -> RealmSwift.Results<RealmSwift.Object>? {
        return getObject(type: type, filter: filter)?.sorted(byKeyPath: sortedKey)
    }
    
    
    /// 对查询的数据进行排序, 请注意, 不支持 将多个属性用作排序基准，此外也无法链式排序（只有最后一个 sorted 调用会被使用）。 如果要对多个属性进行排序，请使用 sorted(by:) 方法，然后向其中输入多个 SortDescriptor 对象。
    ///
    /// - Parameters:
    ///   - type: 队形类型
    ///   - predicate: 谓词对象
    ///   - sortedKey: 排序的字段
    /// - Returns: 排序后的数据
    public func getObject(type: RealmSwift.Object.Type, predicate: NSPredicate, sortedKey: String) -> RealmSwift.Results<RealmSwift.Object>? {
        return getObject(type: type, predicate: predicate)?.sorted(byKeyPath: sortedKey)
    }
    
    public func beginWriteTransaction(){
        
        let realm = getDefaultRealm()
        realm?.beginWrite()
        
    }

}

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
    
    func writeAsync<T: Object>(write: Bool = false, queue: DispatchQueue = .realmBackgroundQueue, obj: T,
               errorHandler: ((Realm.Error) -> Void)? = nil,
               block: @escaping (Realm, T) -> Void) {
        
        if obj.realm != nil {
            let ref = ThreadSafeReference(to: obj)
            
            queue.async {
                do {
                    let realm = try Realm()
                    
                    if let obj = realm.resolve(ref) {
                        if write { realm.beginWrite() }
                        block(realm, obj)
                        if write { try realm.commitWrite() }
                    } else {
                        // throw "object deleted" error
                    }
                    
                } catch {
                    errorHandler?(error as! Realm.Error)
                }
            }
            
        } else {
            
            queue.async {
                do {
                    
                    let realm = try Realm()
                
                    if write { realm.beginWrite() }
                    block(realm, obj)
                    if write { try realm.commitWrite() }

                } catch {
                    errorHandler?(error as! Realm.Error)
                }
            }
            
        }

    }
}
