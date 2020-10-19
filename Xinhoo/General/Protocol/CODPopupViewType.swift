//
//  CODPopViewType.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import PopupKit

struct AssociatedPopViewKeys {
    static var _popupView: UInt8 = 0
}

extension UIView {
    
    var popView: PopupView {
        
        get {
            
            if let popView = objc_getAssociatedObject(self, &AssociatedPopViewKeys._popupView) as? PopupView {
                return popView
            }
            
            let popView = PopupView(contentView: self)
            objc_setAssociatedObject(self, &AssociatedPopViewKeys._popupView, popView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            
            return popView
            
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedPopViewKeys._popupView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
        
    }
    
    

}


protocol CODPopupViewType {
        
    func dismiss(animated: Bool)
    
    func show(showType: PopupView.ShowType, dismissType: PopupView.DismissType, maskType: PopupView.MaskType, layout: PopupView.Layout, duration: TimeInterval)
    func show(layout: PopupView.Layout, duration: TimeInterval)
    func show(layout: PopupView.Layout, in view: UIView)
    func show()
    
}

extension CODPopupViewType where Self: UIView {
    
    func show() {
        self.popView.show()
    }
    
    func dismiss(animated: Bool) {
        self.popView.dismiss(animated: animated)
    }
    
    func show(layout: PopupView.Layout, in view: UIView) {
        self.popView.show(with: layout, in: view)

    }
    
    func show(layout: PopupView.Layout, duration: TimeInterval) {
        self.popView.show(with: layout, duration: duration)
    }
    
    func show(showType: PopupView.ShowType, dismissType: PopupView.DismissType, maskType: PopupView.MaskType, layout: PopupView.Layout, duration: TimeInterval) {
        
        self.popView.showType = showType
        self.popView.dismissType = dismissType
        self.popView.maskType = maskType
        
        self.popView.show(with: layout, duration: duration)
        
    }
    

}
