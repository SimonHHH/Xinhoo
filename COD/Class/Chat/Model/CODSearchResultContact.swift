//
//  CODSearchResultContact.swift
//  COD
//
//  Created by 黄玺 on 2020/2/6.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON

/// 全局搜索结果对象（含用户、群组、频道、机器人）
class CODSearchResultContact: HandyJSON {
    required init() {}
    var count: Int = 0
    /// 昵称，如“Simon_HHH”
    var name: String = ""
    var pic: String = ""
    /// 类型：U=用户；C=频道；G=群组；B=机器人
    var type: String = ""
    /// 用户名,如：a12345
    var userid: String = ""
    /// JID(无后缀@xinhoo.com)
    var username: String = ""
    
    var isUnableClick: Bool = false
}
