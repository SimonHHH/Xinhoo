//
//  CODMobileContactModel.swift
//  COD
//
//  Created by xinhooo on 2019/4/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

public enum ContactStyle : Int {
    case unregistered   //未注册
    case isFriend       //已经添加
    case notFriend      //还未添加
}

class CODMobileContactModel: NSObject {

    @objc dynamic var name:String       = ""
    @objc dynamic var username:String   = ""
    @objc dynamic var jid:String = ""
    @objc dynamic var gender:String = ""
    var userpic:String    = ""
    @objc dynamic var tel:String        = ""
    var userdesc:String   = ""
    var style:ContactStyle = .notFriend
    
    override init() {
        super.init()
    }
}
