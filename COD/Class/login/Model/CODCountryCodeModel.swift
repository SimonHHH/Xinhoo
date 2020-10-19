//
//  CODCountryCodeModel.swift
//  COD
//
//  Created by xinhooo on 2019/8/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON

class CODCountryCodeModel: NSObject,HandyJSON {

    var abbreviation = ""
    @objc dynamic var name = ""
    @objc dynamic var phonecode = ""
    
    required override init() {
        super.init()
    }
}
