//
//  CODDiscoverHomeCellNode+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


extension Reactive where Base: CODDiscoverHomeCellNode {
    
    var realLineCountBinder: Binder<Int> {
        return Binder(base) { (node, _) in
            
            DispatchQueue(label: "setNeedsLayout").async {
                node.setNeedsLayout()
            }
        }
    }
    
    var likeBinder: Binder<IndexPath> {
        
        return Binder(base) { (node, indexPath) in
            
            if indexPath == node.indexPath {
                
                node.reloadLikerNode()
                node.setNeedsLayout()
                
            }
            
        }
        
    }
    
    var failureBinder: Binder<CODDiscoverMessageModel.StatusType> {
        return Binder(base) { (node, state) in
            
            if state == .Failure {
                node.createResendBtn()
            } else {
                node.resendBtn = nil
            }
            
            
            node.setNeedsLayout()
            
        }
    }
    
}
