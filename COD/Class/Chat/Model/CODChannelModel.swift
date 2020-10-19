//
//  CODChannelModel.swift
//  COD
//
//  Created by Sim Tsai on 2019/12/16.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation
import RealmSwift
import HandyJSON
import SwiftyJSON

extension CODChannelModel: CODChatObjectType {
    var title: String {
        self.getGroupName()
    }
    var icon: String {
        return self.grouppic
    }
    var chatTypeEnum: CODMessageChatType {
        return .channel
    }
    var chatId: Int {
        return self.roomID
    }
    
    
}

extension CODChannelModel: CODChatGroupType { }

class CODChannelHJsonModel: HandyJSON {
    required init() {}
    
    var roomID :Int = 0
    var name = ""                 ///群JID
    var jid = ""
    var savecontacts :Bool = false     ///保存到通讯录
    var timingcleanup :Bool = false    ///定时清理
    var notice = ""     /// 群公告
    var description = ""    /// ：cod_60000007
    var naturalname = ""     /// ：cod_60000007
    var burn :String = ""        /// 阅后即焚
    var mute :Bool = false        /// 消息免打扰
    var screenshot :Bool = false   /// 截屏通知
    var stickytop :Bool = false    /// 置顶聊天
    var showname: Bool = true     /// 显示昵称
    var signmsg: Bool = false     /// 显示署名
    var grouppic = ""              /// 头像ID
    var notinvite: Bool = false    /// 禁止入群
    var topmsg: String = ""    /// 消息置顶
    var xhreferall: Bool = false    /// 群成员@所有人
    var noticecontent: Dictionary<String, Any> = [:]
    var userid: String = ""
    var type: String = ""
    
    var channelTypeEnum: CODChannelType {
        set {
            self.type = newValue.rawValue
        }
        get {
            return CODChannelType(rawValue: self.type) ?? .CPUB
        }
    }
    
    func mapping(mapper: HelpingMapper) {

        mapper <<<
            self.notice <-- "noticecontent.notice"
            
    }
    
}

enum CODChannelType: String {
    case CPUB
    case CPRI
}

extension CODChannelType {
    var name: String {
        switch self {
        case .CPRI:
            return NSLocalizedString("私人", comment: "")
            
        case .CPUB:
            return NSLocalizedString("公开", comment: "")
        }
    }
}

class CODChannelModel: Object {
    
    @objc dynamic var roomID :Int = 0
    
    @objc dynamic var jid = ""
    
    @objc dynamic var channelType: String = CODChannelType.CPUB.rawValue
    
    var channelTypeEnum: CODChannelType {
        set {
            self.channelType = newValue.rawValue
        }
        get {
            return CODChannelType(rawValue: self.channelType) ?? .CPUB
        }
    }

    
    /// codm_8000074
    @objc dynamic var name = ""
    
    let member = List<CODGroupMemberModel>()
    
    @objc dynamic var savecontacts :Bool = false
    
    /// : 0
    @objc dynamic var timingcleanup :Bool = false
    
    /// 群名称
    @objc dynamic var descriptions = ""
    
    /// 频道简介
    @objc dynamic var notice = ""
    
    /// 频道链接
    @objc dynamic var userid = ""
    
    var shareLink: String {
        if self.channelTypeEnum == .CPUB {
            return "\(CODAppInfo.channelSharePublicLink)\(self.userid)"
            
        } else {
            return "\(CODAppInfo.channelSharePrivateLink)\(self.userid)"
        }
    }
    
    var pubLink = ""
    
    /// ：Administrator、tommy、jimmy
    @objc dynamic var naturalname = ""
    
    /// 如果获取的群descriptions为空就自定义群名
    @objc dynamic var customName = ""
    
    /// 阅后即焚
    @objc dynamic var burn :String = ""
    
    //上次焚烧消息的时间
    @objc dynamic var lastBurnTime :Int = 0
    
    //上次退出聊天页面的时间
    @objc dynamic var lastChatTime :Int = 0
    
    /// 上次退出聊天页面的最后一条消息的时间 防止发送消息的时候最后一条消息服务器返回的时间和本地时间有很大偏差的时候使用
    @objc dynamic var lastChatMsgID :String = ""
    
    /// 消息免打扰
    @objc dynamic var mute :Bool = false
    
    /// 截屏通知
    @objc dynamic var screenshot :Bool = false
    
    /// 置顶聊天
    @objc dynamic var stickytop :Bool = false
    
    /// 显示名称
    @objc dynamic var showname: Bool = true
    
    /// 署名
    @objc dynamic var signmsg:  Bool = true
    
    /// 群组是否有效
    @objc dynamic var isValid: Bool = false
    
    /// 是否禁止邀请入群
    @objc dynamic var notinvite: Bool = false
    
    /// 头像ID
    @objc dynamic var grouppic = ""
    
    /// 创建时间 ，用于本地创建时显示在聊天列表。特殊：手动赋值
    @objc dynamic var createDate = ""
    
    /// 群置顶消息
    @objc dynamic var topmsg: String = ""
    
    public func getGroupName() -> String {
        if descriptions.count > 0 {
            return descriptions
        }else{
            return customName
        }
    }
    
    let master = LinkingObjects(fromType: CODChatListModel.self, property: "channelChat")
    

    
    override static func primaryKey() -> String?{
        return "roomID"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["jsonModel"]
    }
    
    override static func indexedProperties() -> [String] {
        return ["customName","descriptions", "pubLink"]
    }
}



