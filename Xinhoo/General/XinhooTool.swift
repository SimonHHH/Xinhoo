//
//  XinhooTool.swift
//  COD
//
//  Created by xinhooo on 2019/12/4.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class XinhooTool: NSObject {
    
    
    static let telegram_left_normal_image           = UIImage.init(named: "left_normal")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_left_top_image              = UIImage.init(named: "left_top")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_left_mid_image              = UIImage.init(named: "left_mid")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_left_bottom_image           = UIImage.init(named: "left_bottom")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    
    static let telegram_left_normal_flash_image     = UIImage.init(named: "left_normal_flash")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_left_top_flash_image        = UIImage.init(named: "left_top_flash")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_left_mid_flash_image        = UIImage.init(named: "left_mid_flash")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_left_bottom_flash_image     = UIImage.init(named: "left_bottom_flash")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    
    static let telegram_right_normal_image          = UIImage.init(named: "right_normal")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_right_top_image             = UIImage.init(named: "right_top")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_right_mid_image             = UIImage.init(named: "right_mid")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_right_bottom_image          = UIImage.init(named: "right_bottom")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    
    static let telegram_right_normal_flash_image    = UIImage.init(named: "right_normal_flash")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_right_top_flash_image       = UIImage.init(named: "right_top_flash")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_right_mid_flash_image       = UIImage.init(named: "right_mid_flash")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    static let telegram_right_bottom_flash_image    = UIImage.init(named: "right_bottom_flash")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch)
    
    static var is12Hour = false
    
    static var isEdit_MessageView = false
    
    static var isMultiSelect_ShareMedia = false
    
    static var xinhoo_Logs = Array<String>()
    static var dateformatter = DateFormatter()
    class func addLog(log: String) {
        
        DDLogInfo("【日志平台】\(log)")
        
        XinhooTool.dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let date = XinhooTool.dateformatter.string(from: Date())
        
        XinhooTool.xinhoo_Logs.append("\(log) -- \(date)")
    }
}
