//
//  BaseViewController+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/27.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: BaseViewController {
    
    var showErrorInfoBinder: Binder<String> {
        
        
        return Binder(base) { (_, errorString) in
            CODProgressHUD.showErrorWithStatus(errorString)
        }
        
    }
    
    
}
