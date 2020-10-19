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
        
        if let popView = objc_getAssociatedObject(self, &AssociatedPopViewKeys._popupView) as? PopupView {
            return popView
        }
        
        let popView = PopupView(contentView: self)
        objc_setAssociatedObject(self, &AssociatedPopViewKeys._popupView, popView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        return popView
    }
    
    
    
}


protocol CODPopupViewType {
        
    func show()
    
    func dismiss(animated: Bool)
    
    func show(with: PopupView.Layout, in: UIView)
}

extension CODPopupViewType where Self: UIView {
    
    func show() {
        self.popView.show()
    }
    
    func dismiss(animated: Bool) {
        self.popView.dismiss(animated: animated)
    }
    
    func show(with layout: PopupView.Layout, in view: UIView) {
        self.popView.show(with: layout, in: view)
    }
    
}
