//
//  CODUserInfoAndSetting.swift
//  COD
//
//  Created by XinHoo on 2019/4/4.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON

class CODUserInfoAndSetting: HandyJSON {
    
    required init() {}
    
    /// 昵称
    var name :String?
    /// 用户名
    var userdesc :String?
    /// 头像ID
    var userpic :String?
    /// 性别
    var gender :String?
    /// 邮箱
    var email :String?
    /// 新消息通知
    var notice :Bool?
    /// 语音聊天通知
    var voipnotice :Bool?
    /// 通知显示s发送人信息
    var noticedetail :Bool?
    /// 声音
    var sound :Bool?
    /// 震动
    var vibrate :Bool?
    /// 禁用验证码登录
    var smslogin :Bool?
    /// 用户名被搜索
    var searchuser :Bool?
    /// 手机号码被搜索
    var searchtel :Bool?
    /// 二维码添加
    var addinqrcode :Bool?
    /// 群组添加
    var addingroup :Bool?
    /// 名片添加
    var addincard :Bool?
    /// 
    var readreceipt :Bool?
    
    /// 最后上线时间
    var lastLoginTimeVisible: String?
    
    /// 语音通话
    var callVisible : String?
    
    /// 电话号码
    var showtel : String?
    
    /// 云盘置顶标识
    var xhassstickytop:Bool?
    
    /// 群组
    var inviteJoinRoomVisible :String?
    
    /// 频道
    var xhinvitejoinchannel :String?
    
    /// 信息
    var messageVisible :String?
    
    var tel :String?
    
    var areacode: String?
    
    /// 是否修改过密码
    var changePwd: Bool?
    
    /// 个人签名
    var xhabout: String?
    var about: String?
    
    /// 新的好友静音
    var xhnfmute: Bool?
    var xhnfsticktop: Bool?
    
}


