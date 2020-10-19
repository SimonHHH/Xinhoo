//
//  CODJSON+Extension.swift
//  COD
//
//  Created by XinHoo on 2019/3/21.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension String{
    
    /// JSONString转换为字典
    ///
    /// - Returns: 字典
    func getDictionaryFromJSONString() ->NSDictionary{
        let jsonData:Data = self.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    
    
    /// JSONString转换为数组
    ///
    /// - Returns: 数组
    func getArrayFromJSONString() ->NSArray{
        let jsonData:Data = self.data(using: .utf8)!
        let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if array != nil {
            return array as! NSArray
        }
        return array as! NSArray
        
    }
    
}
