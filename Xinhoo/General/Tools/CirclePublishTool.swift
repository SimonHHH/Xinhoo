//
//  CirclePublishTool.swift
//  COD
//
//  Created by xinhooo on 2020/5/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwifterSwift

class CirclePublishTool: NSObject {

    static let share = CirclePublishTool()
    
    func publishComment(momentsId: String, replayUser: String? = nil, comments: String, handler:@escaping(Bool) ->Void) {
        
        if let replyModel = CODDiscoverMessageModel.addReply(momentsId: momentsId, serverId: "", replayUser: replayUser ?? "", comments: comments) {
        
            CODDiscoverFailureAndSendingListModel.addReplyModel(replyModel: replyModel)
//            CirclePublishTool.share.publishReplyWithModel(replyModel: replyModel)
            CirclePublishTool.share.publishReplyWithModel(replyModel: replyModel) { (isSuccess) in
                handler(isSuccess)
            }
            
        }else{
            
        }
        
    }
    
    
    /// 发布朋友圈
    /// - Parameters:
    ///   - publishVM: 朋友圈页面VM数据
    ///   - compelte: 发布完成回调
    func publishCircle(publishVM:CODCirclePublishVM,compelte:((_ finish: Bool) -> ())? = nil) {
        
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            compelte?(false)
        }
        
        let publishModel = publishVM.publishModel
        
        let model = CODDiscoverMessageModel.createMessageModel()
        
        var msgType = MomentsType.text.rawValue
        switch publishModel.circleType {
        case .text:
            msgType = MomentsType.text.rawValue
            break
        case .image:
            msgType = MomentsType.image.rawValue
            break
        case .video:
            msgType = MomentsType.video.rawValue
            break
            
        }
        
        var privacyType = MessagePrivacyType.Public.rawValue
        switch publishModel.canLook.permissions {
        case .publicity:
            privacyType = MessagePrivacyType.Public.rawValue
            break
        case .onlySelf:
            privacyType = MessagePrivacyType.Private.rawValue
            break
        case .somePeople_canSee:
            privacyType = MessagePrivacyType.LimitVisible.rawValue
            break
        case .somePeople_notSee:
            privacyType = MessagePrivacyType.LimitInVisible.rawValue
            break

        }
        
        
        var location: LocationInfo?
        
        if let position = publishModel.position {
            location = LocationInfo()
            location?.longitude = position.longitude ?? 0.0
            location?.latitude = position.latitude ?? 0.0
            location?.name = position.name
            location?.address = position.address
        }
        
        
        let group = DispatchGroup()
        
        var imageList = Array<PhotoModelInfo>()
        var videoInfo: VideoModelInfo?
        
        for circleImage in publishModel.itemList {
            
            
            
            if publishModel.circleType == .image {
                group.enter()
                
                if let data = circleImage.image.jpegData(compressionQuality: 0.8) {
                    imageList.append(PhotoModelInfo(imageData: data, ishdimg: false))
                    group.leave()
                }
                
            
            }else {
                
                group.enter()
                
                
                if let video = publishModel.video {
                
                    do {
                    
                        let uuid = UUID().uuidString
                        
                        let localPath = "\(CODFileManager.shareInstanceManger().conversationVideosPath ?? "")/\(uuid).mp4"
                        
                        try FileManager.default.moveItem(atPath: video.localURL, toPath: localPath)
                        videoInfo = VideoModelInfo(videoId: uuid, videoData: video.videoData, firstpic: video.firstImage, duration: Float(video.duration.int), localURL:  localPath)
                        group.leave()
                    }catch{
                        compelte?(false)
                        group.leave()
                    }
                    
                    
                }
                
            }

        }
        
        
        group.notify(queue: DispatchQueue.main) {
            
            model.addText(text: publishModel.content)
                .addMsgType(type: msgType)
                .addMsgPrivacyType(type: privacyType)
                .addLocation(location: location)
                .addAllowReviewAndLike(allow: (publishModel.isCanCommentAndLike == 2))
                .addAllowReviewAndLikePublic(allow: (publishModel.isPublicCommentAndLike == 1))
                .addStatus(status: CODDiscoverMessageModel.StatusType.Sending.rawValue)
                .addImageList(photoList: imageList)
                .addVideo(video: videoInfo)
                .addAtList(jids: publishModel.atList)
                .addSomePeople(jids: publishModel.canLook.somePeopleList)
                .addToDB()
            
            
            
                
            
            
            self.publishCircleWithDiscoverMessageModel(model: model, compelte: compelte)
            
        }
        
        
        
        
    }
    
    /// 根据朋友圈model模型 发布朋友圈
    /// - Parameters:
    ///   - model: 朋友圈模型
    ///   - compelte: 发布完成回调
    func publishCircleWithDiscoverMessageModel(model: CODDiscoverMessageModel,compelte:((_ finish: Bool) -> ())? = nil) {
        
        var param = ["momentsType":model.msgType,
                     "content":model.text,
                     "forbidCommentPraise":model.allowReviewAndLike ? 2 : 1,
                     "openCommentPraise":model.allowReviewAndLikePublic ? 1 : 2,
                     "sharingScope":model.msgPrivacyType,
                     "userName":UserManager.sharedInstance.jid,
                     "lat":model.localInfo?.latitude as Any,
                     "lng":model.localInfo?.longitude as Any,
                     "position":model.localInfo?.name ?? "",
                     "remindUserIds":model.atListWithJis.joined(separator: ","),
                     "fileProperties":"",
                     "visibleUserIds":model.somePeople.joined(separator: ",")] as [String : Any]
        
        
        CODDiscoverFailureAndSendingListModel.addDiscoverModel(discoverModel: model)
        model.setValue(\.status, value: CODDiscoverMessageModel.StatusType.Sending.rawValue)
        
        _ = try? Realm().refresh()
        

        if model.msgTypeEnum == .text {
            
            self.publishWithRest(model: model, param: param, compelte: compelte)
            
        } else if model.msgTypeEnum == .image {
            
            UploadTool.upload(fileType: .multipleImage(imageInfos: model.imageList.toImageInfo()), progressHandle: nil) { (responses) in
                
                switch responses.result {
                case .success( _) :
                    
                    let jsonList = model.imageList.toArray().map { (photoModel) in
                        return photoModel.toJSON()
                    }.compactMap { $0 }
                    
                    let fileProperties = jsonList.jsonString()
                    
                    param["fileProperties"] = fileProperties

                    self.publishWithRest(model: model, param: param, compelte: compelte)
                    
                    break
                case .failure(_) :
                    compelte?(false)
                    self.publishFailureWithResend(model: model)
                    break
                    
                }
                
            }
            
        } else {
            
            if let videoInfo = model.video {
                
                UploadTool.upload(fileType: .video(videoInfo: videoInfo.toVideoInfo()), progressHandle: nil) { (responses) in
                    switch responses.result {
                    case .success(_) :
                        
                        
                        if let videoJson = videoInfo.toJSON() {
                            param["fileProperties"] = [videoJson].jsonString() ?? ""
                        }

                        self.publishWithRest(model: model, param: param, compelte: compelte)
                        
                        break
                    case .failure(let error) :
                        compelte?(false)
                        self.publishFailureWithResend(model: model)
                        break
                        
                    }
                }
                
            }
            
            
        }
    }
    
    /// 发布朋友圈接口
    /// - Parameters:
    ///   - model: 朋友圈模型
    ///   - param: 参数
    ///   - compelte: 发布完成回调
    func publishWithRest(model:CODDiscoverMessageModel, param: Dictionary<String, Any>,compelte:((_ finish: Bool) -> ())? = nil) {
        HttpManager.share.post(url: HttpConfig.COD_add_moments, param: param,isShowNoNetwork: false, successBlock: { (_, json) in
            
            compelte?(true)
            let momentsId = JSON(json)["data"]["momentsId"].stringValue
            if momentsId.count != 0 {
                
                model.setValue(\.status, value: CODDiscoverMessageModel.StatusType.Succeed.rawValue)
                model.setValue(\.serverMsgId, value: momentsId)
                CODDiscoverFailureAndSendingListModel.deleteDiscoverModel(discoverModel: model)
            }
            
        }) { (error) in
            compelte?(false)
            self.publishFailureWithResend(model: model)
        }
    }
    
    /// 发布失败处理 失败次数等于3次时，认为是真的失败了，不到三次就走重发逻辑 10s间隔重发
    /// - Parameter model: 朋友圈模型
    func publishFailureWithResend(model:CODDiscoverMessageModel) {
        
        if model.isDelete == true {
            CODDiscoverFailureAndSendingListModel.deleteDiscoverModel(discoverModel: model)
            return
        }
        
        if  model.resendCount < 3 {
            try? Realm().safeWrite {
                model.resendCount += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                
                self.publishCircleWithDiscoverMessageModel(model: model)
            }
        }else{
            model.setValue(\.status, value: CODDiscoverMessageModel.StatusType.Failure.rawValue)
        }
    }
    
    
}
