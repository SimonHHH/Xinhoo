//
//  CODChatPersonModel.swift
//  COD
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON

class CODChatPersonModel: HandyJSON {
    
    var username:String? = ""
    var tel:String? = ""
    var name:String? = ""
    var userdesc:String? = ""
    var userpic:String? = ""
    var tojid:String? = ""
    var owner:String? = ""
    var desc:String? = ""
    var isAdd: Bool? = false

    required init() {
        
    }
    
}

class CODNewFriendModel: HandyJSON {
    var tojid:String? = ""
    var owner:String? = ""
    var desc:String? = ""
    var status:Int = 0 //0 添加 1 已添加

    required init() {
        
    }
}

