//
//  HttpTools.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/23.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

struct HttpTools {
    
    enum VaildandType {
        case CloudDiskToChat
        case ChatToCloudDisk
        case ChatToChat
        case MomentToChat
        case MomentToCloudDisk
    }
    
    static func vaildandTranfile(attIdList: [String], type: VaildandType, successBlock: ((NSDictionary,SwiftyJSON.JSON) -> Void)? = nil, faliedBlock : ((AFSErrorInfo) -> Void)? = nil) {
        
        var params = ["attIdList": attIdList] as [String: Any]
        
        var url = HttpConfig.COD_VaildTranfile
        
        switch type {
        case .CloudDiskToChat:
            params["type"] = "DTC"
        case .ChatToCloudDisk:
            params["type"] = "CTD"
        case .MomentToChat:
            params["type"] = "MTC"
        case .MomentToCloudDisk:
            params["type"] = "MTD"
        case .ChatToChat:
            url = HttpConfig.COD_Vaildfile
            params["storeType"] = "MESSAGE"
        }

        HttpManager.share.postWithUserInfo(url: url, param: params, successBlock: {(successDic, successJson) in
            successBlock?(successDic, successJson)
        }) { (error) in
            faliedBlock?(error)
        }
        
    }
    
}
