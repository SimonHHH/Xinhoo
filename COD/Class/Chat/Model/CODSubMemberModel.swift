//
//  CODSubMemberModel.swift
//  COD
//
//  Created by XinHoo on 2019/9/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON
import RealmSwift

class CODSubMemberModel: Object, HandyJSON {
    
    
    
    @objc dynamic var jid = ""
    @objc dynamic var username = ""
    @objc dynamic var name = ""
    @objc dynamic var userdesc = ""
    @objc dynamic var gender = ""
    @objc dynamic var userpic = ""

    
    override static func primaryKey() -> String? {
        return  "jid"
    }
    
    override static func indexedProperties() -> [String] {
        return ["username"]
    }
    
    class func getSubMemberModel(withJid jid: String, resultBlock: @escaping ((_ model: CODSubMemberModel?) -> ())) {
        let model = try! Realm.init().object(ofType: CODSubMemberModel.self, forPrimaryKey: jid)
        if let model = model {
            resultBlock(model)
        }else{
            XMPPManager.shareXMPPManager.requestUserInfo(userJid: jid, success: { (response) in
                guard let data = response.data as? Dictionary<String, Any> else{
                    print("解析data失败")
                    return
                }
                guard let users = data["users"] as? Array<Dictionary<String, Any>> else{
                    print("解析users失败")
                    return
                }
                
                if let model = CODSubMemberModel.deserialize(from: users.first) {
                    try! Realm.init().write {
                        try! Realm.init().add(model)
                    }
                    resultBlock(model)
                }
                
            }) {
                print("根据JID获取用户失败")
                resultBlock(nil)
                return
            }
            
        }
    }
    
    class func getSubMemberModelWithJid(jid: String) -> CODSubMemberModel {
        return try! Realm.init().object(ofType: CODSubMemberModel.self, forPrimaryKey: jid)!
    }
}
