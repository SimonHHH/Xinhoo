//
//  CODDiscoverMessageModel.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/11.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RealmSwift

/// 1：所有可见 2：自己可见 3：指定朋友可见 4：指定不可见列表
enum MessagePrivacyType: Int, Codable {
    case Public = 1
    case Private = 2
    case LimitVisible = 3
    case LimitInVisible = 4
}

final class CODDiscoverMessageModel: Object {
    
    
    
    enum StatusType: Int {
        case Succeed
        case Sending
        case Failure
    }
    
    /// 本地消息ID
    @objc dynamic var msgId: String = UUID().uuidString
    
    /// 消息类型： 私密，公开, 限制
    @objc dynamic var msgPrivacyType: Int = 0
    
    var msgPrivacyTypeEnum: MessagePrivacyType {
        
        get {
            return MessagePrivacyType(rawValue: msgPrivacyType) ?? .Public
        }
        
        set {
            msgPrivacyType = newValue.rawValue
        }
        
    }
    
    /// 消息状态
    @objc dynamic var status: Int = 0
    
    var statusEnum: CODDiscoverMessageModel.StatusType {
        
        get {
            return CODDiscoverMessageModel.StatusType(rawValue: status) ?? CODDiscoverMessageModel.StatusType.Sending
        }
        
        set {
            status = newValue.rawValue
        }
        
    }
    
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
    
    
    /// 服务器给的消息ID
    @objc dynamic var serverMsgId: String = ""
    
    /// 发送者的JID
    @objc dynamic var senderJid: String = ""
    
    /// 文本
    @objc dynamic var text: String = ""
    
    /// 创建时间
    @objc dynamic var createTime = Int(Date.milliseconds)
    
    /// 图片列表
    dynamic var imageList: List<PhotoModelInfo> = List<PhotoModelInfo>()
    
    /// 地址信息
    @objc dynamic var localInfo: LocationInfo? = nil
    
    /// 视频
    @objc dynamic var video: VideoModelInfo? = nil
    
    /// 点赞人
    dynamic var likerList: List<CODPersonInfoModel> = List<CODPersonInfoModel>()
    
    /// 回复列表
    dynamic var replyList: List<CODDiscoverReplyModel> = List<CODDiscoverReplyModel>()
    
    /// 提醒
    dynamic var atList: List<CODPersonInfoModel> = List<CODPersonInfoModel>()
    
    var atListWithJis: Array<String> {
        
        return atList.map { (personInfoModel) -> String in
            return personInfoModel.jid
        }
        
    }
    
    /// 是否被删除
    @objc dynamic var isDelete = false
    
    /// 允许评论/点赞
    @objc dynamic var allowReviewAndLike = true
    
    /// 允许评论/点赞公开
    @objc dynamic var allowReviewAndLikePublic = true
    
    /// 点赞的ID，取消点赞要用(什么垃圾接口设计)
    @objc dynamic var likerId: String = ""
    
    /// 部分 可见/不可见 集合 jid
    dynamic var somePeople: List<String> = List<String>()
    
    /// 版本号
    @objc dynamic var version = 2
    
    /// 发送失败次数
    @objc dynamic var resendCount = 0
    
    override class func primaryKey() -> String? {
        return "msgId"
    }
    
    override class func ignoredProperties() -> [String] {
        return ["atListWithJis"]
    }
    
}
