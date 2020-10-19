//
//  CODDiscoverMessageModelTools.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON







extension CODDiscoverMessageModel: RealmWriteKeyPathable {
    
    class func getModel(id: String) -> CODDiscoverMessageModel? {
        return try? Realm().object(ofType: CODDiscoverMessageModel.self, forPrimaryKey: id)
    }
    
    
    class func getModel(serverMsgId: String) -> CODDiscoverMessageModel? {
        return try? Realm().objects(CODDiscoverMessageModel.self).filter("serverMsgId == '\(serverMsgId)'").first
    }
    
    class func createMessageModel() -> CODDiscoverMessageModel {
        
        let model = CODDiscoverMessageModel()
        
        model.senderJid = UserManager.sharedInstance.jid
        
        return model
        
    }
    
    class func addReply(momentsId: String, serverId: String, sender: String = UserManager.sharedInstance.jid, replayUser: String, comments: String) -> CODDiscoverReplyModel? {
        
        guard let model = self.getModel(serverMsgId: momentsId) else {
            return nil
        }
        
        let replyModel = CODDiscoverReplyModel.createModel(serverId: serverId,sender: sender, replayUser: replayUser, comments: comments)
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            
            model.addReply(replyModel: replyModel)
            replyModel.localMomentId = model.msgId
            
        }
        
        _ = try? Realm().refresh()
        
        return replyModel
                
    }
    
    func addReply(replyModel: CODDiscoverReplyModel) {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            
            replyModel.addToDB()
            
            if self.replyList.contains(replyModel) {
                return
            }
            
            self.replyList.append(replyModel)
            
            replyModel.localMomentId = self.msgId
            
        }

    }

    
    func addLiker(liker: CODPersonInfoModel) {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            
            liker.addToDB()
            
            if likerList.contains(liker) {
                return
            }
            
            likerList.append(liker)

        }
        
    }
    
    class func createMessageModel(jsonModel: CODDiscoverJsonModel) -> CODDiscoverMessageModel {
        
        var messageModel: CODDiscoverMessageModel!
        
        if let model = CODDiscoverMessageModel.getModel(serverMsgId: jsonModel.momentsId.string) {
            messageModel = model
        } else {
            messageModel = CODDiscoverMessageModel()
            messageModel.addToDB()
        }
        
        try? Realm().safeWrite {
            
            
            
            let sender = CODPersonInfoModel.createModel(jid: jsonModel.userName, name: jsonModel.userNickName, userpic: jsonModel.userPic)
            
            sender.addToDB()
            
            messageModel.text = jsonModel.content ?? ""
            messageModel.senderJid = jsonModel.userName
            messageModel.createTime = jsonModel.createTime
            messageModel.serverMsgId = jsonModel.momentsId.string
            messageModel.msgTypeEnum = jsonModel.momentsType
            messageModel.msgPrivacyTypeEnum = jsonModel.sharingScope
            messageModel.isDelete = false
            
            
            
            
            if let visibleUserIds = jsonModel.visibleUserIds {
                
                messageModel.somePeople.removeAll()
                let userIds = visibleUserIds.split(separator: ",").map { String($0) }
                messageModel.somePeople.append(objectsIn: userIds)
                
            }
            
            if jsonModel.momentsStatus == .delete {
                messageModel.isDelete = true
            }
            
            if jsonModel.forbidCommentPraise == .allowComment {
                messageModel.allowReviewAndLike = true
            } else {
                messageModel.allowReviewAndLike = false
            }
            
            if jsonModel.openCommentPraise == .publicComment {
                messageModel.allowReviewAndLikePublic = true
            } else {
                messageModel.allowReviewAndLikePublic = false
            }
            
            messageModel.likerList.removeAll()
            if let praiseList = jsonModel.praiseList {
                
                for praise in praiseList {
                    
                    let personInfo = CODPersonInfoModel(likerJsonModel: praise)
                    
                    if praise.userName == UserManager.sharedInstance.jid {
                        messageModel.likerId = praise.messageId.string
                    }
                    
                    personInfo.addToDB()
                    messageModel.likerList.append(personInfo)
                    
                }
                
            }
            
            if let position = jsonModel.position, position.count > 0 {
                
                var localInfo: LocationInfo! = messageModel.localInfo
                if localInfo == nil {
                    localInfo = LocationInfo()
                }
                
                _ = localInfo
                .setValue(jsonModel.lng?.double() ?? 0, forKey: \.longitude)
                .setValue(jsonModel.lat?.double() ?? 0, forKey: \.latitude)
                .setValue(position, forKey: \.name)
                

                messageModel.localInfo = localInfo
                
            }
            
            
            
            if let commentList = jsonModel.commentList {
                
                let sendingReplyList = CODDiscoverFailureAndSendingListModel.getFailureComments(localMomentId: messageModel.msgId)
                
                messageModel.replyList.removeAll()
                var replyList = commentList.map { CODDiscoverReplyModel.createModel($0, moment: messageModel) }
                replyList.append(contentsOf: sendingReplyList)
                replyList = replyList.sort(by: \.createTime)
                replyList.addToDB()
                messageModel.replyList.append(objectsIn: replyList)

            }
            
            if let referToList = jsonModel.referToList {
                
                messageModel.atList.removeAll()
                
                let atList = referToList.map { CODPersonInfoModel.createModel(jid: $0) }
                messageModel.atList.append(objectsIn: atList)
                
            }
            
            if let fileProperties = jsonModel.fileProperties {
                
                switch jsonModel.momentsType {
                case .image:
                    messageModel.imageList.removeAll()
                    let photos = JSON(parseJSON: fileProperties).arrayValue.map { PhotoModelInfo.createModel(json: $0) }
                    photos.addToDB()
                    messageModel.imageList.append(objectsIn: photos)
                    
                case .video:
                    
                    let videos = JSON(parseJSON: fileProperties).arrayValue.map { VideoModelInfo.createModel(json: $0) }
                    let video = videos.first
                    video?.addToDB()
                    messageModel.video = video

                default:
                    break
                }
                
                
            }
            
            
        }
        
        return messageModel
        
    }
    
    func addText(text: String) -> Self {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            self.text = text
        }
        
        return self
        
    }
    
    func deleteComment(serverId: String) {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            
            for (index, value) in self.replyList.enumerated() {
                
                if value.serverId == serverId {
                    
                    self.replyList.remove(at: index)
                    realm?.delete(value)
                    
                    return
                    
                }
                
            }

        }

    }
    
    func addImageList(photoList: [PhotoModelInfo]) -> Self {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            self.imageList.append(objectsIn: photoList)
        }
        
        return self
    }
    
    func addVideo(video: VideoModelInfo?) -> Self {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            
            if let video = video {
                self.video = video
            }

        }
        
        return self
        
    }
    
    func addAllowReviewAndLike(allow:Bool) -> Self {
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            self.allowReviewAndLike = allow
        }
        
        return self
    }
    
    func addAllowReviewAndLikePublic(allow:Bool) -> Self {
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            self.allowReviewAndLikePublic = allow
        }
        
        return self
    }
    
    func addLocation(location:LocationInfo?) -> Self {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            self.localInfo = location
        }
        
        return self
    }
    
    func addMsgType(type:Int) -> Self {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            self.msgType = type
        }
        
        return self
    }
    
    func addMsgPrivacyType(type:Int) -> Self {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            self.msgPrivacyType = type
        }
        
        return self
    }
    
    func addStatus(status:Int) -> Self {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            self.status = status
        }
        
        return self
    }
    
    func addAtList(jids: [String]) -> Self{
        
        let realm = try? Realm()
        
        let personInfoList = jids.map { (jid) -> CODPersonInfoModel in
            
            return CODPersonInfoModel.createModel(jid: jid)
            
        }
        
        let atList: List<CODPersonInfoModel> = List<CODPersonInfoModel>()
        
        atList.append(objectsIn: personInfoList)
        
        try? realm?.safeWrite {
            self.atList = atList
        }
        
        return self
    }
    
    func addSomePeople(jids: [String]) -> Self{
        
        let realm = try? Realm()
        
        let somePeople = List<String>()
        somePeople.append(objectsIn: jids)
        
        try? realm?.safeWrite {
            self.somePeople = somePeople
        }
        
        return self
    }
    
    func removeLiker(_ jid: String) {
        
        let realm = try? Realm()
        
        for (index, value) in self.likerList.enumerated() {
            
            if value.jid == jid {
                
                try? realm?.safeWrite {
                    self.likerList.remove(at: index)
                    self.likerId = ""
                }
                
                
            }
            
        }
        
        
    }
    
    func like(likerId: String? = nil) {
        
        let realm = try? Realm()
        
        let personInfo = CODPersonInfoModel()
        personInfo.jid = UserManager.sharedInstance.jid
        personInfo.userpic = UserManager.sharedInstance.avatar ?? ""
        personInfo.name = UserManager.sharedInstance.nickname ?? ""
        personInfo.addToDB()
        
        try? realm?.safeWrite {
            
            if let _ = self.getLiker(UserManager.sharedInstance.jid) {
                return
            }
            
            if let personInfo = CODPersonInfoModel.getPersonInfoModel(jid: UserManager.sharedInstance.jid) {
                self.likerList.append(personInfo)
            }
            
            
            if let likerId = likerId {
                self.likerId = likerId
            }

            
        }
        
        
    }
    
    func getLiker(_ jid: String) -> CODPersonInfoModel? {
        return likerList.filter("jid == '\(jid)'").first
    }
    

    func delete() {
        
        try? Realm().safeWrite {
            CODDiscoverFailureAndSendingListModel.deleteDiscoverModel(discoverModel: self)
            self.isDelete = true
        }
        
    }
    
    
    /// 加载某个时间之后的数据
    /// - Parameters:
    ///   - senderJid: 指定某个发送者
    ///   - afterTime: 指定时间点
    /// - Returns: 本地消息
    class func loadMessageList(senderJid: String? = nil, afterTime: Int) -> [CODDiscoverMessageModel] {
        
        var result = try? Realm().objects(CODDiscoverMessageModel.self)
        
        if let senderJid = senderJid {
            result = result?.filter("senderJid == '\(senderJid)'")
        }
        
        return (result?.filter("createTime >= \(afterTime) && isDelete == false").sorted(byKeyPath: "createTime", ascending: false).toArray()) ?? []
        
    }
    
    
    /// 根据时间段加载本地实际 (不包含结束时间)
    /// - Parameters:
    ///   - senderJid: 指定某个发送者
    ///   - msgTypes: 指定加载的消息类型
    ///   - beginTime: 开始时间
    ///   - endTime: 结束时间
    /// - Returns: 本地消息
    class func loadMessageList(senderJid: String? = nil, msgTypes: [MomentsType] = [], beginTime: Int, endTime: Int) -> [CODDiscoverMessageModel] {
        
        var result = try? Realm().objects(CODDiscoverMessageModel.self)
        
        if let senderJid = senderJid {
            result = result?.filter("senderJid == '\(senderJid)'")
        }
        
        if msgTypes.count > 0 {
            
            
            var predicate = ""
            for (index, type) in msgTypes.enumerated() {
                
                if index > 0 {
                    predicate += " || "
                }
                
                predicate += "msgType == \(type.rawValue)"
            }
            
            result = result?.filter(predicate)
            
        }
        
        return result?.filter("createTime >= \(beginTime) && createTime < \(endTime) && isDelete == false").sorted(byKeyPath: "createTime", ascending: false).toArray() ?? []

    }
    
    /// 根据时间段加载本地实际 (包含结束时间)
    /// - Parameters:
    ///   - senderJid: 指定某个发送者
    ///   - msgTypes: 指定加载的消息类型
    ///   - beginTime: 开始时间
    ///   - endTime: 结束时间
    /// - Returns: 本地消息
    class func loadMessageList(senderJid: String? = nil, msgTypes: [MomentsType] = [], beginTime: Int, include endTime: Int) -> [CODDiscoverMessageModel] {
        
        var result = try? Realm().objects(CODDiscoverMessageModel.self)
        
        if let senderJid = senderJid {
            result = result?.filter("senderJid == '\(senderJid)'")
        }
        
        if msgTypes.count > 0 {
            
            
            var predicate = ""
            for (index, type) in msgTypes.enumerated() {
                
                if index > 0 {
                    predicate += " || "
                }
                
                predicate += "msgType == \(type.rawValue)"
            }
            
            result = result?.filter(predicate)
            
        }
        
        return result?.filter("createTime >= \(beginTime) && createTime <= \(endTime) && isDelete == false").sorted(byKeyPath: "createTime", ascending: false).toArray() ?? []

    }
    
    class func loadLastMessages(count: Int) -> [CODDiscoverMessageModel] {
        
        guard let messages = try? Realm().objects(CODDiscoverMessageModel.self).filter("isDelete == false").sorted(byKeyPath: "createTime", ascending: false).toArray().prefix(count) else { return [] }
        
        return Array(messages)
    }
    
    class func loadLastMessages(senderJid: String, count: Int) -> [CODDiscoverMessageModel] {
        
        guard let messages = try? Realm().objects(CODDiscoverMessageModel.self).filter("isDelete == false && senderJid == '\(senderJid)'").sorted(byKeyPath: "createTime", ascending: false).toArray().prefix(count) else { return [] }
        
        return Array(messages)
    }
    
    class func loadLastMessages(senderJid: String, beforeTime: Int, count: Int) -> [CODDiscoverMessageModel] {
        
        guard let messages = (try? Realm().objects(CODDiscoverMessageModel.self).filter("createTime < \(beforeTime) && isDelete == false && senderJid == '\(senderJid)'").sorted(byKeyPath: "createTime", ascending: false).toArray())?.prefix(count) else { return [] }
        
        return Array(messages)
        
    }
    
    class func loadMessageList(beforeTime: Int, count: Int) -> [CODDiscoverMessageModel] {
        
        guard let messages = (try? Realm().objects(CODDiscoverMessageModel.self).filter("createTime < \(beforeTime) && isDelete == false").sorted(byKeyPath: "createTime", ascending: false).toArray())?.prefix(count) else { return [] }
        
        return Array(messages)
        
    }
    
    
    
    /// 同步已经被删除的消息
    /// - Parameters:
    ///   - dbmessageModels: 数据库（本地）中的Model
    ///   - messageModels: 从外部（从服务器）获取到的Model
    
    
    /// 同步已经被删除的消息
    /// - Parameters:
    ///   - dbmessageModels: 数据库（本地）中的Model
    ///   - messageModels: 从外部（从服务器）获取到的Model
    /// - Returns: 同步后的数据
    class func syncDeletedMessage(dbmessageModels: [CODDiscoverMessageModel], messageModels: [CODDiscoverMessageModel]) -> [CODDiscoverMessageModel] {
        
        let set2 = Set(dbmessageModels)
        
        let subMessages = set2.subtracting(messageModels)
        
        let succeedMessages = subMessages.filter { (model) -> Bool in
            model.statusEnum == .Succeed
        }
        
        _ = List(succeedMessages).setValue(\.isDelete, value: true)
        
        return dbmessageModels.filter{ $0.isDelete == false }
        
    }
    
    func toYBIBVideoData() -> YBIBVideoData? {
        
        guard let video = self.video else {
            return nil
        }
        
        let videoData = video.toYBIBVideoData()
        videoData.msgID = self.msgId
        videoData.isHiddenPlayBtn = true
        videoData.isHiddenPlayTool = true
        videoData.repeatPlayCount = UInt(NSIntegerMax)
        return videoData
        
    }
    
    func toYBIBImageData() -> YBIBImageData? {
        
        guard let image = self.imageList.first else {
            return nil
        }
        
        let imageData = image.toYBIBImageData()
        imageData.msgID = self.msgId
        imageData.photoId = image.photoId
        return imageData
        
    }
    
    
    func toYBIBImageListData() -> [YBIBImageData] {

        return self.imageList.map { value in
            let imageData = value.toYBIBImageData()
            imageData.msgID = self.msgId
            imageData.photoId = value.photoId
            return imageData
        }
        
    }
    
    

}

extension Sequence where Element: CODDiscoverMessageModel {
    
    func addToDB() {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            realm?.add(self, update: .all)
        }
        
    }
    
    func toYBIBData() -> [YBIBDataProtocol] {
        
        var data: [YBIBDataProtocol] = []
        
        for value in self {
            
            if value.msgTypeEnum == .image {
                data.append(contentsOf: value.toYBIBImageListData())
            }
            
            if value.msgTypeEnum == .video {
                if let video = value.toYBIBVideoData() {
                    data.append(video)
                }
            }
            
        }
        
        return data
        
    }
    
}
