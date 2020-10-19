//
//  ResendMessageQ.swift
//  COD
//
//  Created by Sim Tsai on 2020/9/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RealmSwift


enum ResendMessageQName: String {
    
    case paddingTimeOutResend
    
}


class CODResendMessageQModel: Object {
    
    @objc dynamic var queueName: String = ""
    
    let messageList = List<CODMessageModel>()
    
    override class func primaryKey() -> String? {
        return "queueName"
    }
    
    
    
}


extension CODResendMessageQModel {
    
    
    class func createResendMessageQueue(qName: ResendMessageQName) -> CODResendMessageQModel {
        
        
        let realm  = CODRealmTools.getDB()
        
        if let model = realm.object(ofType: CODResendMessageQModel.self, forPrimaryKey: qName.rawValue) {
            return model
        } else {
            
            let model = CODResendMessageQModel()
            model.queueName = qName.rawValue
            
            model.addToDB()
            
            return model
            
        }
        
        
    }
    
    class func addMessageToQueue(qName: ResendMessageQName, message: CODMessageModel) {
        
        let model = createResendMessageQueue(qName: qName)
        
        let realm  = CODRealmTools.getDB()
        
        try? realm.safeWrite {
            message.resendDatetimeInt = message.datetimeInt
            model.messageList.append(message)
        }
        
        
        
        
    }
    
    class func removeMessageFromQueue(qName: ResendMessageQName, message: CODMessageModel) {
        
        let model = createResendMessageQueue(qName: qName)
        
        let realm  = CODRealmTools.getDB()
        
        try? realm.safeWrite {
            
            model.messageList.remove(model: message)
        
        }
        
    }
    
    class func getNeedToResendMessages(qName: ResendMessageQName, timeout: TimeInterval) -> Results<CODMessageModel> {
        
        let nowTime = (Int(Date.milliseconds) + UserManager.sharedInstance.timeStamp)
        
        let model = createResendMessageQueue(qName: qName)
        
        return model.messageList.filter("resendDatetimeInt <= \(nowTime - timeout.int)").sorted(byKeyPath: "resendDatetimeInt")
        
    }
    
    class func getMessageFromQueue(qName: ResendMessageQName, messageID: String) -> CODMessageModel? {
        
        let model = createResendMessageQueue(qName: qName)
        
        return model.messageList.filter("msgID == '\(messageID)'").first
        
        
        
    }
    
}
