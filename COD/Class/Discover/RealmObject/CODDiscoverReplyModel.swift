//
//  CODDiscoverReplyModel.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/11.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RealmSwift

class CODDiscoverReplyModel: Object {
    
    enum StatusType: Int {
        case Succeed
        case Sending
        case Failure
    }
    
    /// 回复ID
    @objc dynamic var replyId: String = UUID().uuidString
    
    /// 对应服务器的ID
    @objc dynamic var serverId: String = ""
    
    /// 回复谁
    @objc dynamic var replyWho: CODPersonInfoModel? = nil
    
    /// 谁发的
    @objc dynamic var sender: CODPersonInfoModel? = nil
    
    /// 内容
    @objc dynamic var text: String = ""
    
    /// 创建时间
    @objc dynamic var createTime = Int(Date.milliseconds)
    
    /// 本地朋友圈ID
    @objc dynamic var localMomentId: String?
    
    /// 消息状态
    @objc dynamic var status: Int = 0

    /// 发送失败次数
    @objc dynamic var resendCount = 0
    
    var statusEnum: CODDiscoverReplyModel.StatusType {
        
        get {
            return CODDiscoverReplyModel.StatusType(rawValue: status) ?? CODDiscoverReplyModel.StatusType.Sending
        }
        
        set {
            status = newValue.rawValue
        }
        
    }
    
    override class func primaryKey() -> String? {
        return "replyId"
    }
    
    func setValue<E>(_ keyPath: KeyPath<CODDiscoverReplyModel, E>, value: E) {
        
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Key path cannot be observed. You may need to prefix it with @objc.")
        }
        
        try? Realm().safeWrite {
            self.setValue(value, forKeyPath: keyPathString)
        }

    }

}

extension CODDiscoverReplyModel {
    
    var isMeSend: Bool {
        return self.sender?.jid == UserManager.sharedInstance.jid
    }
    
    class func getModel(serverId: String) -> CODDiscoverReplyModel? {
        return try? Realm().objects(CODDiscoverReplyModel.self).filter("serverId == '\(serverId)'").first
    }
    
    class func getModel(id: String) -> CODDiscoverReplyModel? {
        return try? Realm().object(ofType: CODDiscoverReplyModel.self, forPrimaryKey: id)
    }
    
    class func createModel(_ jsonModel: CODDiscoverCommentJsonModel, moment: CODDiscoverMessageModel?) -> CODDiscoverReplyModel {
        
        let realm = try? Realm()
        var model = CODDiscoverReplyModel()
        
        if let localModel = CODDiscoverReplyModel.getModel(serverId: jsonModel.messageId.string) {
            model = localModel
        }
        
        
        try? realm?.safeWrite {
            
            model.serverId = jsonModel.messageId.string
            
            if let replayUser = jsonModel.replayUser, replayUser.count > 0 {
                
                if let personInfo = CODPersonInfoModel.getPersonInfoModel(jid: replayUser) {
                    model.replyWho = personInfo
                } else {
                    
                    if let contact = CODContactRealmTool.getContactByJID(by: replayUser) {
                        
                        let person = CODPersonInfoModel()
                        person.jid = replayUser
                        person.userpic = contact.userpic
                        person.name = jsonModel.replayUserNickName ?? ""
                        model.replyWho = person
                        
                    }
                    
                }
                
            }
            
            model.sender = CODPersonInfoModel.createModel(jid: jsonModel.userName, name: jsonModel.userNickName, userpic: jsonModel.userPic)
            
            model.serverId = jsonModel.messageId.string
            model.createTime = jsonModel.createTime ?? 0
            model.text = jsonModel.comments ?? ""
            model.localMomentId = moment?.msgId
            
        }
        
        return model

    }
    

    class func createModel(serverId: String, sender: String, replayUser: String, comments: String) -> CODDiscoverReplyModel {
        
        let model = CODDiscoverReplyModel()
        
        model.sender = CODPersonInfoModel.createModel(jid: sender)
        
        if replayUser.count > 0 {
            model.replyWho = CODPersonInfoModel.createModel(jid: replayUser)
        }
        
        model.text = comments
        model.serverId = serverId
        
        return model
        
        
    }
    

    
}
