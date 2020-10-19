//
//  CODDiscoverFailureAndSendingListModel.swift
//  COD
//
//  Created by xinhooo on 2020/5/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODDiscoverFailureAndSendingListModel: Object {

    var modelList:List<CODDiscoverMessageModel> = List<CODDiscoverMessageModel>()
   
    var commentList: List<CODDiscoverReplyModel> = List<CODDiscoverReplyModel>()
    
    var messageDeletedLikeFailList: List<CODDiscoverMessageModel> = List<CODDiscoverMessageModel>()
    
    var messageDeletedCommentFailList: List<CODDiscoverMessageModel> = List<CODDiscoverMessageModel>()
    
    
    @objc dynamic  var id: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension CODDiscoverFailureAndSendingListModel {
    
    class func insertModelToDeletedLikeFailList(_ model: CODDiscoverMessageModel) {
        
        let failureMode = self.getFailureModel()
        
        
        try? Realm().safeWrite {
            failureMode.messageDeletedLikeFailList.append(model)
        }
        
    }
    
    class func removeModelFromDeletedLikeFailList(_ model: CODDiscoverMessageModel) {
        
        let failureMode = self.getFailureModel()
        
        try? Realm().safeWrite {
            failureMode.messageDeletedLikeFailList.remove(model: model)
        }
        
    }
    
    class func removeModelFromDeletedCommentFailList(_ model: CODDiscoverMessageModel) {
        
        let failureMode = self.getFailureModel()
        
        try? Realm().safeWrite {
            failureMode.messageDeletedCommentFailList.remove(model: model)
        }
        
    }
    
    class func getFailureComments(localMomentId: String) -> [CODDiscoverReplyModel] {
        
        let failureModel = self.getFailureModel()
        
        return failureModel.commentList.filter("localMomentId == '\(localMomentId)'").toArray()

    }

    class func getFailureModel() -> CODDiscoverFailureAndSendingListModel {
        
        if let model = try? Realm().object(ofType: CODDiscoverFailureAndSendingListModel.self, forPrimaryKey: UserManager.sharedInstance.jid) {
            return model
        }else{
            
            let model = CODDiscoverFailureAndSendingListModel()
            model.id = UserManager.sharedInstance.jid
            
            let realm = try? Realm()
            
            try? realm?.safeWrite {
                
                realm?.add(model, update: .all)
                
            }
            
            return model
        }
        
    }
    
    class func getFailureList() -> [CODDiscoverMessageModel] {
        return self.getFailureModel().modelList.filter("status == \(CODDiscoverMessageModel.StatusType.Failure.rawValue)").toArray()
    }
    
    class func getSendingList() -> [CODDiscoverMessageModel] {
        return self.getFailureModel().modelList.filter("status != \(CODDiscoverMessageModel.StatusType.Succeed.rawValue)").toArray()
    }
    
    class func getMessageDeletedLikeFailList() -> [CODDiscoverMessageModel] {
        return self.getFailureModel().messageDeletedLikeFailList.toArray()
    }
    
    class func getMessageDeletedCommentFailList() -> [CODDiscoverMessageModel] {
        return self.getFailureModel().messageDeletedCommentFailList.toArray()
    }

    /// 添加数据到朋友圈发送失败集合
    /// - Parameter discoverModel: 朋友圈model
    class func addDiscoverModel(discoverModel:CODDiscoverMessageModel) {
        
        let isContains = self.getFailureModel().modelList.contains { (model) -> Bool in
            return model.msgId == discoverModel.msgId
        }
        
        if isContains {
            return
        }
        
        try? Realm().safeWrite {
            self.getFailureModel().modelList.append(discoverModel)
        }
    }
    
    /// 添加数据到评论发送失败集合
    /// - Parameter replyModel: 评论model
    class func addReplyModel(replyModel: CODDiscoverReplyModel) {
        
        let isContains = self.getFailureModel().commentList.contains { (model) -> Bool in
            return model.replyId == replyModel.replyId
        }
        
        if isContains {
            return
        }
        
        try? Realm().safeWrite {
            self.getFailureModel().commentList.append(replyModel)
        }
    }
    
    /// 评论了被删除的朋友圈，往messageDeletedCommentFailList集合添加数据
    /// - Parameter discoverModel: 朋友圈model
    class func addDiscoverModelWithDelete(discoverModel: CODDiscoverMessageModel) {
        
        let isContains = self.getFailureModel().messageDeletedCommentFailList.contains { (model) -> Bool in
            return model.msgId == discoverModel.msgId
        }
        
        if isContains {
            return
        }
        
        try? Realm().safeWrite {
            self.getFailureModel().messageDeletedCommentFailList.append(discoverModel)
        }
    }
    
    class func setSendingMessagToFailure() {
        
        DispatchQueue.main.async {
            
            self.getFailureModel().modelList.forEach { (model) in
                CirclePublishTool.share.publishFailureWithResend(model: model)
            }
            
            self.getFailureModel().commentList.forEach { (model) in
                CirclePublishTool.share.publishFailureReplyWithResend(model: model)
            }
        }

    }
    
    /// 从失败集合中删除朋友圈model
    /// - Parameter discoverModel: 朋友圈model
    class func deleteDiscoverModel(discoverModel:CODDiscoverMessageModel) {
        
        let model = self.getFailureModel()
        
        try? Realm().safeWrite {
            
            if let index = model.modelList.index(of: discoverModel) {
            
                model.modelList.remove(at: index)
            }
        }
    }
    
    /// 从失败集合中删除回复model
    /// - Parameter replyModel: 回复model
    class func deleteReplyModel(replyModel: CODDiscoverReplyModel) {
        
        let model = self.getFailureModel()
        
        try? Realm().safeWrite {
            
            if let index = model.commentList.index(of: replyModel) {
            
                model.commentList.remove(at: index)
            }
        }
    }
    
    
}
