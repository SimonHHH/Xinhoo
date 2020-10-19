//
//  CODMultipleImageCellNode+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/6.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: CODChatContentNode {
    
    var statusBinder: Binder<CODMessageStatus> {
        
        return Binder(base) { (node, value) in
            if value  == .Failed {
                node.setNeedsLayout()
            }
        }
        
    }
    
    var isHaveReadBinder: Binder<Void> {
        
        return Binder(base) { (node, _) in
            
            node.setNeedsLayout()
            
        }
        
    }
    
    var messageStatusBinder: Binder<XinhooTimeAndReadView.Status> {
        return Binder(base) { (node, value) in
            node.configMessageStatus(status: value)
        }
    }
    
}
