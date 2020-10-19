//
//  ListExtension.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/27.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension Results {
    func setValue<E>(_ keyPath: KeyPath<Element, E>, value: E) {
        
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Key path cannot be observed. You may need to prefix it with @objc.")
        }
        
        try? Realm().safeWrite {
            self.setValue(value, forKey: keyPathString)
        }
        
    }
}


extension List {
    
    func setValue<E>(_ keyPath: KeyPath<Element, E>, value: E) {
        
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Key path cannot be observed. You may need to prefix it with @objc.")
        }
        
        try? Realm().safeWrite {
            self.setValue(value, forKeyPath: keyPathString)
        }
        
    }
    
    
    func remove(model: Element) {
        
        if let index = self.index(of: model) {
            self.remove(at: index)
        }
        
    }

    
    convenience init<S: Sequence>(_ value: S) where S.Iterator.Element == Element {
        self.init()
        
        self.append(objectsIn: value)
    }
    
}


