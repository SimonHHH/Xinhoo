//
//  NSObject+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/27.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


extension Reactive where Base: NSObject {
    
    /**
     Specialization of generic `observe` method.
     
     This is a special overload because to observe values of some type (for example `Int`), first values of KVO type
     need to be observed (`NSNumber`), and then converted to result type.
     
     For more information take a look at `observe` method.
     */
    @available(swift 4.0)
    public func observe<E>(_ keyPath: KeyPath<Base, E>, options: KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> Observable<E?> {
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Key path cannot be observed. You may need to prefix it with @objc.")
        }
//        return observeWeakly(E.self, keyPathString)
        return observe(E.self, keyPathString, options: options, retainSelf: retainSelf)
    }
}
