//
//  RosterRequestModel.swift
//  COD
//
//  Created by xinhooo on 2020/3/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON
import RxSwift
import RxCocoa

class RosterRequestModel: HandyJSON {

    var requestID = ""
    var sender = ""
    var receiver = ""
    var status: Int = 0
    var invalidTime = ""
    var requestTime = ""
    var requestQty = 0
    var readed = ""
    var desc = ""
    var senderPic = ""
    var senderNickName = ""
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        // specify 'cat_id' field in json map to 'id' property in object
        mapper <<<
            self.desc <-- "description"

    }
}
