//
//  CODCellNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import SwifterSwift

class CODCellNode: ASCellNode {
    
    var cellVM: ASTableViewCellVM!
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.clear
        self.automaticallyManagesSubnodes = true
        
    }
    
    
    
    required init(_ cellVM: ASTableViewCellVM) {
        super.init()
        self.cellVM = cellVM
        self.backgroundColor = UIColor.clear
        self.automaticallyManagesSubnodes = true
    }
    
    
}
