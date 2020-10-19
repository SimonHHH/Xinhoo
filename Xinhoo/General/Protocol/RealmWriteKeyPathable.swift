//
//  RealmWriteKeyPathable.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/17.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

protocol RealmWriteKeyPathable where Self: Object {
    
    func setValue<E>(_ keyPath: KeyPath<Self, E>, value: E)
    

    
}

extension RealmWriteKeyPathable {
    
    func setValue<E>(_ keyPath: KeyPath<Self, E>, value: E) {
        
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Key path cannot be observed. You may need to prefix it with @objc.")
        }
        
        try? Realm().safeWrite {
            self.setValue(value, forKeyPath: keyPathString)
        }

    }
    
}
