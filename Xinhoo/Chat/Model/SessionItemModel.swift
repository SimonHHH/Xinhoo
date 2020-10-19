//
//  SessionItemModel.swift
//  COD
//
//  Created by zzs on 2020/2/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON
class SessionItemModel: NSObject,HandyJSON {
    
    enum SessionItemType {
        case delete
        case active
    }
    
    /// 0-未通话   1-通话中
    var groupRtc = 0
    
    /// 1-语音  2-视频
    var rtcType = 1
    
    /// rtc room id
    var groupRtcRoomId = ""
    
    /// 语音通话发起者
    var groupRtcRequester = ""
    
    /// 小红点数量
    var badge = 0
    
    /// 阅后即焚
    var burn = ""
    
    /// 背景色
    var itemBgColor = ""
    
    /// jid
    var itemID = ""
    
    /// 名字
    var itemName = ""
    
    /// 头像
    var itemPic = ""
    
    /// 聊天类型（私聊，群聊，频道）
    var itemType = 0
    
    /// 最后一条消息
    var lastMessage = ""
    
    /// 单双勾时间
    var lastReadTime = ""
    
    var lastReadTimeOfMe = 0
    
    /// 静音
    var mute = ""
    
    /// @集合
    var referToResultVoList = Array<Dictionary<String, Any>>()
    
    /// 置顶
    var stickytop = false
    
    /// 清除消息时间
    var clearTime = ""
    
    /// 会话状态 1为删除，2为活跃
    var deleteStatus = 0
    var deleteTypeEnum: SessionItemType {
        switch deleteStatus {
        case 1:
            return .delete
        case 2:
            return .active
        default:
            return .active
        }
    }
    
    var chatTypeEnum: CODMessageChatType {
        
        switch itemType {
        case 1:
            return .privateChat
        case 2:
            return .groupChat
        case 3:
            return .channel
        default:
            return .privateChat
        }
    }
    required override init() {
        super.init()
    }
}
