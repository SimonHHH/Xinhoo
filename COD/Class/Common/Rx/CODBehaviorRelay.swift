//
//  CODBehaviorRelay.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/6.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay


@propertyWrapper
public struct CODBehaviorRelay<Value> {
    
    var observed: RxRelay.BehaviorRelay<Value>
    
    public init(wrappedValue: Value) {
        self.observed = RxRelay.BehaviorRelay(value: wrappedValue)
    }
    
    public var wrappedValue: Value {
        get { return self.observed.value }
        set { self.observed.accept(newValue) }
    }
    
    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }

}

extension CODBehaviorRelay: ObservableType {
    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Self.Element == Observer.Element {
        self.observed.subscribe(observer)
    }
    
    public typealias Element = Value

}

extension ObservableType {
    public func bind(to codBehaviorRelay: CODBehaviorRelay<Element>) -> Disposable {
        return bind(to: codBehaviorRelay.observed)
    }
}

