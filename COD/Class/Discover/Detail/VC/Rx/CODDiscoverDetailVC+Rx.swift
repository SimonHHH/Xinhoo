//
//  CODDiscoverDetailVC+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: CODDiscoverDetailVC {
    
    var actionKeyboradBinder: Binder<(momentsId: String, replayUser: String, replyUserName: String?)> {
        return Binder(base) { (vc, value) in
            
            vc.replyView.config(momentsId: value.momentsId, replyUser: value.replayUser, responder: vc, replyName: value.replyUserName)
            vc.replyView.show()
        }
    }
    
    var deleteMomentsBinder: Binder<Void> {
        return Binder(base) { (vc, _) in
            
            guard let navigationController = vc.navigationController else { return }
            

            for viewController in navigationController.viewControllers.reversed() {
                
                if viewController.isKind(of: CODDiscoverPersonalListVC.self) {
                    navigationController.popToViewController(viewController, animated: true)
                    return
                }
                
                if viewController.isKind(of: CODDiscoverHomeVC.self) {
                    navigationController.popToViewController(viewController, animated: true)
                    return
                }
                
            }
            
            navigationController.popViewController()
            
        }
    }
    
    var hiddenKeyboradBinder: Binder<Bool> {
        return Binder(base) { (vc, isHidden) in
            vc.replyView.isHidden = isHidden
        }
    }
    
    
}


