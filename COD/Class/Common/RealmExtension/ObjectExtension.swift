//
//  ObjectExtension.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/23.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension Sequence where Element: Object {
    
    func addToDB() {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            realm?.add(self, update: .all)
        }
        
    }

}

extension Object {

    func addToDB() {
        
        let realm = try? Realm()
                
        try? realm?.safeWrite {
            realm?.add(self, update: .all)
            
        }
        
    }
    
    func deleteFormDB() {
        
        let realm = try? Realm()
                
        try? realm?.safeWrite {
            realm?.delete(self)
            
        }
        
    }
    
    
    
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }

        return array
    }
}
