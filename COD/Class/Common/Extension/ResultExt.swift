//
//  ResultExt.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/11.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

extension Result {
    
    var isFailure: Bool {
        
        if case .failure(_) = self {
            return true
        } else {
            return false
        }
        
    }
    
}
