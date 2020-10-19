//
//  CODDiscoverDetailCommentCellNode+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/11.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: CODDiscoverDetailCommentCellNode {
    
    var statusBinder: Binder<CODDiscoverReplyModel.StatusType> {
        return Binder(base) { (node, value) in
            
            node.createResendButton()
            node.setNeedsLayout()

        }
    }
    
}
