//
//  CODChatCellNode+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/27.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit

extension ASDisplayNode {
    
    func setSubNodeUserInteractionEnabled(_ enabled: Bool) {
        
        guard let subnodes = self.subnodes else {
            return
        }
        
        for subnode in subnodes {
            
            subnode.isUserInteractionEnabled = enabled
            subnode.setSubNodeUserInteractionEnabled(enabled)
            
        }
        
    }
    
}

extension Reactive where Base: CODChatCellNode {
    
    var statusBinder: Binder<CODMessageStatus> {
        
        return Binder(base) { (node, value) in
            node.setNeedsLayout()
        }
        
    }
    
    var cellLocationBinder: Binder<LocationType> {
        return Binder(self.base) { (node, value) in
            node.setNeedsLayout()
            
            if value == .bottom || value == .only {
                node.headerImageNode.isHidden = false
            } else {
                node.headerImageNode.isHidden = true
            }
            
        }
    }
    
    var isMultipleSelelctBinder: Binder<Bool> {
        return Binder(self.base) { (node, value) in
            node.fwButton.isUserInteractionEnabled = !value
            node.setSubNodeUserInteractionEnabled(!value)
            node.setNeedsLayout()
        }
    }
    
}
