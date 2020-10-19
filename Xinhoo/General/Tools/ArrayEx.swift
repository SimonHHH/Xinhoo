//
//  ArrayEx.swift
//  COD
//
//  Created by xinhooo on 2020/5/22.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

extension Array {
    
    func jsonString(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    
    func rearrange(fromIndex: Int, toIndex: Int) -> [Element]{
        var arr = Array(self)
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        return arr
    }
    
}
