//
//  CODDiscoverPersonalListCellNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport


class CODDiscoverPersonalListCellNode: CODDisplayNode {
    
    var vm: CODDiscoverPersonalListCellVM!
    weak var pageVM: CODDiscoverPersonalListVCPageVM?
    
    required init (pageVM: CODDiscoverPersonalListVCPageVM?, vm: CODDiscoverPersonalListCellVM) {
        super.init()
        self.vm = vm
        self.pageVM = pageVM
    }
    
    func didSelected() {
        
        
        

    }
    
}
