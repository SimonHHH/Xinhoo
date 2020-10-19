//
//  CODPublishRelay.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay


@propertyWrapper
public struct CODPublishRelay<Value> {
    
    var observed: RxRelay.PublishRelay<Value>
    var _value: Value
    
    public init(wrappedValue: Value) {
        self.observed = RxRelay.PublishRelay()
        _value = wrappedValue
    }
    
    public var wrappedValue: Value {
        get { return _value }
        set {
            _value = newValue
            self.observed.accept(newValue)
        }
    }
    
    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }

}

extension CODPublishRelay: ObservableType {
    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Self.Element == Observer.Element {
        self.observed.subscribe(observer)
    }

    public typealias Element = Value

}

extension ObservableType {
    public func bind(to codPublishRelay: CODPublishRelay<Element>) -> Disposable {
        return bind(to: codPublishRelay.observed)
    }
}


