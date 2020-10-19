//
//  CODMomentsPicModel.swift
//  COD
//
//  Created by XinHoo on 7/14/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODMomentsPicModel: NSObject {
    
    var picId = ""
    
    /// 0: 图片， 1:视频
    var type = 0
    
    /// 初始化方法
    /// - Parameters:
    ///   - picId: 图片ID
    ///   - type: 类型 0: 图片， 1:视频
    convenience init(picId: String, type: Int) {
        self.init()
        self.picId = picId
        self.type = type
    }
    
    override init() {
        super.init()
    }
}
