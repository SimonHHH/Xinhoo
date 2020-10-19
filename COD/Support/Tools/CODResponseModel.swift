//
//  CODResponseModel.swift
//  COD
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON
import SwiftyJSON

class CODResponseModel: HandyJSON {
    var success: Bool = false          //请求成功
    var msg: String! = ""     // 提示信息
    var data: Any?  = nil      // 请求内容
    var dataJson: JSON? = nil
    var actionJson: JSON? = nil
    var errorCode: Int = 0    // 请求成功的 错误码
    var statusCode: Int = 0   // 服务器出错时的状态
    var code: Int = 0         // IQ错误码
    var errorData: Array<Any> = []
    var name: String?
    
    required init() {
        
    }
    
    // 网络异常
    func isNetWorkError() -> Bool {
        if (errorCode == -1009) || (errorCode == -1005) || (errorCode == -1004) {
            return true
        }
        return false
    }
    
}

