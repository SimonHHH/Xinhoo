//
//  CODCanReadListViewController+Rx.swift
//  COD
//
//  Created by XinHoo on 6/8/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base : CODCanReadListViewController {
    var setTitle: Binder<CODCanReadListViewModel.CanReadType> {
        return Binder(base) { (vc, type) in
            if type == .read {
                vc.title = NSLocalizedString("可见的朋友", comment: "")
            }else{
                vc.title = NSLocalizedString("不可见的朋友", comment: "")
            }
        }
    }
}
