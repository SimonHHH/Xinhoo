//
//  CODMoreKeyboardItem.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODMoreKeyboardItem: NSObject {
    var type:CODMoreKeyboardItemType?
    var title:String?
    var imagePath:String?
    
    class func createMoreItem(type:CODMoreKeyboardItemType,title:String,imagePath:String) -> CODMoreKeyboardItem {
        let item = CODMoreKeyboardItem()
        item.type = type
        item.title = title
        item.imagePath = imagePath
        return item
    }
}
