//
//  CODDiscoverNewMessageModel.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/23.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RealmSwift

class CODDiscoverNewMessageModel: Object {
    
    @objc dynamic var serverMsgId: String = ""
    
    @objc dynamic var momentsId: String = ""
    
    /// 消息类型: 文本，图片，视频
    @objc dynamic var msgType: Int = 0
    
    var msgTypeEnum: MomentsType {
        
        get {
            return MomentsType(rawValue: msgType) ?? MomentsType.text
        }
        
        set {
            msgType = newValue.rawValue
        }
        
    }
    
    /// 消息类型: 文本，图片，视频
    @objc dynamic var commentType: Int = 0
    
    var commentTypeEnum: CODDiscoverCommentMessageType {
        
        get {
            return CODDiscoverCommentMessageType(rawValue: commentType) ?? CODDiscoverCommentMessageType.comment
        }
        
        set {
            commentType = newValue.rawValue
        }
        
    }
    
    @objc dynamic var video: VideoModelInfo?
    
    @objc dynamic var image: PhotoModelInfo?
    
    @objc dynamic var sender: CODPersonInfoModel?
    
    @objc dynamic var spreadReplayUserNickName: String?
    
    @objc dynamic var createTime: Int = 0
    
    @objc dynamic var comment: String = ""
    
    @objc dynamic var content: String = ""
    
    // 消息类型: 文本，图片，视频
    @objc dynamic var momentsType: Int = 0
    
    @objc dynamic var momentsStatus: Int = 0
    
    @objc dynamic var read: Int = 1
    
    var momentsStatusEnum: MomentsStatus {
        
        get {
            return MomentsStatus(rawValue: momentsStatus) ?? .normal
        }
        
        set {
            momentsStatus = newValue.rawValue
        }
        
    }
    
    @objc dynamic var isDelete: Bool = false
    
    var momentsTypeEnum: MomentsType {
        
        get {
            return MomentsType(rawValue: msgType) ?? MomentsType.text
        }
        
        set {
            msgType = newValue.rawValue
        }
        
    }

    override class func primaryKey() -> String? {
        return "serverMsgId"
    }
        
}

extension CODDiscoverNewMessageModel {
    
    class func getModel(id: String) -> CODDiscoverNewMessageModel? {
        
        return try? Realm().object(ofType: CODDiscoverNewMessageModel.self, forPrimaryKey: id)
        
    }
    
    class func createModel(jsonModel: CODDiscoverNewMessageJsonModel) -> CODDiscoverNewMessageModel {
        
        var model: CODDiscoverNewMessageModel! = CODDiscoverNewMessageModel.getModel(id: jsonModel.messageId.string)
        if model == nil {
            model = CODDiscoverNewMessageModel()
            model.serverMsgId = jsonModel.messageId.string
        }
        
        model.setModel(jsonModel: jsonModel)
        
        
        return model
        
    }
    
    func setModel(jsonModel: CODDiscoverNewMessageJsonModel) {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            
            
            self.momentsId = jsonModel.momentsId.string
            self.commentTypeEnum = jsonModel.messageType
            self.createTime = jsonModel.createTime ?? 0
            self.comment = jsonModel.comments ?? ""
            self.content = jsonModel.content ?? ""
            self.momentsTypeEnum = jsonModel.momentsType
            self.momentsStatusEnum = jsonModel.momentsStatus ?? MomentsStatus.normal
            self.spreadReplayUserNickName = jsonModel.spreadReplayUserNickName?.aes128DecryptECB(key: .nickName)
            self.read = jsonModel.read
            
            if jsonModel.messageStatus == .delete {
                 self.isDelete = true
            }
            
            self.sender = CODPersonInfoModel.createModel(jid: jsonModel.spreadUserName, name: jsonModel.spreadUserNickName, userpic: jsonModel.spreadUserPic)
            
            if let fileProperties = jsonModel.fileProperties, fileProperties.count > 0 {
                
                switch momentsTypeEnum {
                case .image:
                    self.image = PhotoModelInfo.createModel(json: JSON(parseJSON: fileProperties))
                    
                case .video:
                    self.video = VideoModelInfo.createModel(json: JSON(parseJSON: fileProperties))
                    
                default:
                    break
                }
                
            }

        }
        
    }
    
}
