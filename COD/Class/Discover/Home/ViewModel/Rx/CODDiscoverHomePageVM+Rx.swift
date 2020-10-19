//
//  CODDiscoverHomePageVM+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/8.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxRealm

extension Reactive where Base: CODDiscoverHomePageVM {
    
    var deleteMessageBinder: Binder<(AnyRealmCollection<Results<CODDiscoverMessageModel>.ElementType>, RealmChangeset?)> {
        
        return Binder(base) { (vm, value) in
            
            guard let updated = value.1?.updated, updated.count > 0 else { return }
            
            for index in updated {
                
                
                let model = value.0[index]
                
                if model.isDelete != true {
                    return
                }
                
                if let indexPath = vm.findCellVM(model: model) {
                    vm.removeItem(indexPath: indexPath)
                }

            }

        }
        
    }
    
}
