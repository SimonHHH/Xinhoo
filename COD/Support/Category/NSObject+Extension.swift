//
//  NSObject+Extension.swift
//  COD
//
//  Created by XinHoo on 2019/3/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation

public extension NSObject{
    public class var nameOfClass: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    // MARK:返回className
    var nameOfClass:String{
        get{
            let name =  type(of: self).description()
            if(name.contains(".")){
                return name.components(separatedBy: ".")[1];
            }else{
                return name;
            }
            
        }
    }
    
    func getPropertyNames() -> Array<String>{
        
        var outCount:UInt32
        outCount = 0
        let propers:UnsafeMutablePointer<objc_property_t>! =  class_copyPropertyList(self.classForCoder, &outCount)
        let count:Int = Int(outCount);
        
        var proNames = Array<String>()
        
        for i in 0...(count-1) {
            let aPro: objc_property_t = propers[i]
            let proName:String! = String(utf8String: property_getName(aPro))
            proNames.append(proName)
        }
        
        return proNames
    }
}
