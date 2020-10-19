//
//  CODPersonInfoModel.swift
//  COD
//
//  Created by xinhooo on 2019/8/2.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODPersonInfoModel: Object {
    
    @objc dynamic var jid = ""
    @objc dynamic var name = ""
    
    /// 头像ID
    @objc dynamic var userpic = ""
    override static func primaryKey() -> String?{
        return "jid"
    }
    
    class func getPersonInfoModel(jid:String) -> CODPersonInfoModel? {
        return try? Realm.init().object(ofType: CODPersonInfoModel.self, forPrimaryKey: jid)
    }
    
    class func createModel(jid: String, name: String? = nil, userpic: String? = nil) -> CODPersonInfoModel {
        
        let realm = try? Realm()
        var personInfo: CODPersonInfoModel! = CODPersonInfoModel.getPersonInfoModel(jid: jid)
        
        
        
        
        if personInfo == nil {
            
            
            if let model = CODContactRealmTool.getContactByJID(by: jid) {
                
                personInfo = CODPersonInfoModel()
                personInfo.jid = jid
                personInfo.name = model.getContactNick()
                personInfo.userpic = model.userpic
                
                
            }else {
                
                personInfo = CODPersonInfoModel()
                personInfo.jid = jid
                
                if jid == UserManager.sharedInstance.jid {
                    personInfo.userpic = UserManager.sharedInstance.avatar ?? ""
                    personInfo.name = UserManager.sharedInstance.nickname ?? ""
                }
                
            }
            
            
        }
        
        try? realm?.safeWrite {
            
            if let userpic = userpic, userpic.count > 0 {
                personInfo.userpic = userpic
            }

            if let name = name, name.count > 0 {
                personInfo.name = name.aes128DecryptECB(key: .nickName)
            }
            
        }

        return personInfo
        
    }
    

    
}

extension CODPersonInfoModel {
    
    convenience init(likerJsonModel: CODLikerPersonModel) {
        self.init()
        self.jid = likerJsonModel.userName
        self.name = (likerJsonModel.userNickName ?? "").aes128DecryptECB(key: .nickName)
        self.userpic = likerJsonModel.userPic ?? ""
    }

    
}
