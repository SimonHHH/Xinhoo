//
//  CirclePublishTool+Reply.swift
//  COD
//
//  Created by xinhooo on 2020/6/10.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

extension CirclePublishTool {
    
    /// 发布评论
    /// - Parameters:
    ///   - replyModel: 评论Model
    func publishReplyWithModel(replyModel: CODDiscoverReplyModel, handler:@escaping(Bool) ->Void) {
        
        guard let messageModel = CODDiscoverMessageModel.getModel(id: replyModel.localMomentId ?? "") else {
            return
        }
        
        replyModel.setValue(\.status, value: CODDiscoverReplyModel.StatusType.Sending.rawValue)
        
        var param = ["comments":replyModel.text,
                     "momentsId":messageModel.serverMsgId,
                     "userName":UserManager.sharedInstance.jid] as [String : Any]
        
        if let jid = replyModel.replyWho?.jid {
            param["replayUser"] = jid
        }
        
        HttpManager.share.post(url: HttpConfig.COD_moments_add_comment, param: param,isShowNoNetwork: false, successBlock: {  (_, json) in
            
            
            let serverId = json["data"]["messageId"].stringValue
            CODDiscoverFailureAndSendingListModel.deleteReplyModel(replyModel: replyModel)
            replyModel.setValue(\.status, value: CODDiscoverReplyModel.StatusType.Succeed.rawValue)
            replyModel.setValue(\.serverId, value: serverId)
            replyModel.addToDB()
            
            handler(true)
            
        }) { (errorInfo) in
            
            if errorInfo.code == DiscoverHttpTools.DiscoverHttpError.momentIsDelete.rawValue {
            
                CODDiscoverFailureAndSendingListModel.addDiscoverModelWithDelete(discoverModel: messageModel)
                CODDiscoverFailureAndSendingListModel.deleteReplyModel(replyModel: replyModel)
                
            } else {
                self.publishFailureReplyWithResend(model: replyModel)
            }
            handler(false)

        }
    }
    
    /// 发布失败处理 失败次数等于3次时，认为是真的失败了，不到三次就走重发逻辑 10s间隔重发
    /// - Parameter model: 回复评论model
    func publishFailureReplyWithResend(model: CODDiscoverReplyModel) {
        
//        if model.isDelete == true {
//            CODDiscoverFailureAndSendingListModel.deleteReplyModel(replyModel: model)
//            return
//        }
        
        if  model.resendCount < 3 {
            try? Realm().safeWrite {
                model.resendCount += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    
                self.publishReplyWithModel(replyModel: model) { (isSuccess) in
                    
                }
            }
        }else{
            model.setValue(\.status, value: CODDiscoverReplyModel.StatusType.Failure.rawValue)
        }
    }
    
}
