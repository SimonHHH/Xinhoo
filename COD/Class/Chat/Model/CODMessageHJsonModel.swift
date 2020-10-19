//
//  CODMessageHJsonModel.swift
//  COD
//
//  Created by XinHoo on 2019/4/13.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON
import SwiftyJSON

class CODSettingHJsonModel: HandyJSON {
    required init() {}

    var description = ""

    // 图片消息
    var ishdimg = false
    var w = 0.0
    var h = 0.0

    // 微音频消息
    var duration = 0.0
    var firstpic = ""

    // 位置消息
    var lng: Double = 0.0
    var lat: Double = 0.0
    var title = ""
    var subtitle = ""

    // 附件消息
    var filename = ""
    var size: Double = 0.0

    // 消息已读
    var badge = 0

    // 发送名片
    var username = ""
    var name = ""
    var userdesc = ""
    var jid = ""
    var gender = ""
    var userpic: String?

    // 删除消息
    var msgID = ""

    var room: String?
    
    var rosterID: Int?

    var newGroupOwner: String?

    var notice: String?

    var notinvite: Bool = false
    
    var canspeak: Bool = true

    var grouppic: String?

    var burn = 0

    var screenshot = false

    var xhreferall: Bool = false
    
    //邀请人
    var inviter: String?

    var xhshowallhistory: Bool? = false
    
    var nick: String?
    
    var stickytop: Bool? = false
    
    var mute: Bool? = false
    
    var topmsg: String?
    
    var showname: Bool? = false
    
    var savecontacts: Bool? = false
    
    var userdetail: Bool? = false
}

extension CODMessageChatType {
    var scope: String {
        switch self {
        case .privateChat:
            return "0"
        case .groupChat:
            return "1"
        case .channel:
            return "2"
        }
    }
}

enum CODMessageChatType: String, HandyJSONEnum {
    case privateChat = "1"
    case groupChat = "2"
    case channel = "3"
}

extension CODMessageChatType {
    
    var intValue: Int {
        
        switch self {
        case .privateChat:
            return 1
        case .groupChat:
            return 2
        case .channel:
            return 3
        }
        
    }
    
    var fwf: String {
        switch self {
        case .privateChat:
            return "U"
        case .groupChat:
            return "G"
        case .channel:
            return "C"
        }
    }
    
}

enum CODMessageTransType: String, HandyJSONEnum {

    case privateType = "U"
    case groupType = "G"
    case channelType = "C"
}

extension CODMessageChatType {
    var stringValue: String {
        switch self {
        case .groupChat:
            return "groupChat"
            
        case .channel:
            return "channel"
            
        case .privateChat:
            return "roster"
        }
    }
}

class CODMessageHJsonModel: HandyJSON {
    required init() {}
    
    var burn = 0
    var msgType: Int = EMMessageBodyType.unknown.rawValue
    var msgTypeEnum: EMMessageBodyType {
        return EMMessageBodyType(rawValue: msgType) ?? .unknown
    }
    var receiver = ""
    var sender = ""
    var roomID = 0
    var chatType: CODMessageChatType = .privateChat
    var sendTime = 0
    var body = ""
    var received = 0
    var edited = 0
    var reply = 0
    var rp = ""
    var fw = ""
    var fwn = ""
    var l = 0
    var fwf = ""
    var n = ""
    var itemID: String?
    var smsgID: String?

    var referTo: Array<String> = []

    
    var entities: Array<Dictionary<String,Any>> = []
    
    var setting: CODSettingHJsonModel?
    var settingJson: JSON = JSON()
    var dataJson: JSON = JSON()
    
    var isCloudDiskMessage: Bool {
        
        if self.receiver.contains(kCloudJid) {
            return true
        }
        
        return false
    }
    
    var isMeSend: Bool {
        return sender.compareNoCaseForString(UserManager.sharedInstance.jid)
    }


    
}
