//
//  UITableViewExt.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

struct UIScrollViewAssociatedKeys {
    static var _pageNum: UInt8 = 0
    static var _pageSize: UInt8 = 0
}

extension UIScrollView {
    
    var pageNum: Int {
        
        get {
            
            if objc_getAssociatedObject(self, &UIScrollViewAssociatedKeys._pageNum) == nil {
                objc_setAssociatedObject(self, &UIScrollViewAssociatedKeys._pageNum, 1, .OBJC_ASSOCIATION_RETAIN)
            }
            
            return objc_getAssociatedObject(self, &UIScrollViewAssociatedKeys._pageNum) as! Int
        }
        
        set {
            objc_setAssociatedObject(self, &UIScrollViewAssociatedKeys._pageNum, newValue, .OBJC_ASSOCIATION_RETAIN)
        }

    }
    
    var pageSize: Int {
        
        get {
            
            if objc_getAssociatedObject(self, &UIScrollViewAssociatedKeys._pageSize) == nil {
                objc_setAssociatedObject(self, &UIScrollViewAssociatedKeys._pageSize, 20, .OBJC_ASSOCIATION_RETAIN)
            }
            
            return objc_getAssociatedObject(self, &UIScrollViewAssociatedKeys._pageSize) as! Int
        }
        
        set {
            objc_setAssociatedObject(self, &UIScrollViewAssociatedKeys._pageSize, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        
    }
    
}
