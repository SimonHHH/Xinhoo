//
//  NodeExt.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/29.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport

extension ASDisplayNode {
    
    func backgroupColor(color: UIColor?) -> ASDisplayNode {
        
        self.backgroundColor = color
        
        return self
        
    }
    
}
