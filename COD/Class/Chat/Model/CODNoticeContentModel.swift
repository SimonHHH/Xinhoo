//
//  CODNoticeContentModel.swift
//  COD
//
//  Created by XinHoo on 2019/4/30.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON

class CODNoticeContentModel: HandyJSON {
    required init() {}
    
    var userpic = ""
    var nickname = ""
    var name = ""
    var pulisher = ""
    var pulishdate = 0
    var notice = ""
    
    var nameResult: String {
        if nickname.count > 0 {
            return nickname
        }
        return name
    }
    
}
