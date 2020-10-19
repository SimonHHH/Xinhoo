//
//  TableViewCell+Rx.swift .swift
//  COD
//
//  Created by Sim Tsai on 2019/12/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


@objc public protocol Reusable : class {
    func prepareForReuse()
}

struct AssociatedKeys {
    static var _prepareForReuseBag: UInt8 = 0
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}
extension UICollectionReusableView: Reusable {}



extension Reactive where Base: Reusable {
        
    var prepareForReuse: Observable<Void> {
        return Observable.of(sentMessage(#selector(Base.prepareForReuse)).map { _ in }, deallocated).merge()
    }
    
    var prepareForReuseBag: DisposeBag {
        MainScheduler.ensureExecutingOnScheduler()
        
        if let bag = objc_getAssociatedObject(base, &AssociatedKeys._prepareForReuseBag) as? DisposeBag {
            return bag
        }
        
        let bag = DisposeBag()
        objc_setAssociatedObject(base, &AssociatedKeys._prepareForReuseBag, bag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        _ = prepareForReuse
            .takeUntil(self.deallocated)
            .subscribe(onNext: { [weak base] _ in
                let newBag = DisposeBag()
                objc_setAssociatedObject(base, &AssociatedKeys._prepareForReuseBag, newBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            })
        
        return bag
    }
}
