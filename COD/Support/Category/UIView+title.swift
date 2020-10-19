//
//  UIView+title.swift
//  COD
//
//  Created by xinhooo on 2019/4/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation
import RDVTabBarControllerSwift

extension UILabel {
    public class func initializeMethod() {
        
        
        let originalSelector = #selector(setter: UILabel.text)
        let swizzledSelector = #selector(UILabel.customSetText(text:))
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        
        //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
        let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    public class func initializeMethodWithAttr() {
    
        let originalSelector = #selector(setter: UILabel.attributedText)
        let swizzledSelector = #selector(UILabel.customSetattributedText(text:))
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        
        //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
        let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    @objc func customSetText(text: String) {
        self.customSetText(text: NSLocalizedString(text, comment: ""))
    }
    
    @objc func customSetattributedText(text: NSAttributedString) {
        
        let attStr = NSMutableAttributedString.init(string: NSLocalizedString(text.string, comment: ""))
        attStr.addAttributes(text.attributes, range: NSMakeRange(0, attStr.length))
        self.customSetattributedText(text: attStr)
    }
}

extension UIButton {
    public class func initializeMethod() {
        
        let originalSelector = #selector(UIButton.setTitle(_:for:))
        let swizzledSelector = #selector(UIButton.customSetTitle(text:state:))
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        
        //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
        let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    @objc func customSetTitle(text: String, state:UIButton.State) {
        self.customSetTitle(text: NSLocalizedString(text, comment: ""), state: state)
    }
}
