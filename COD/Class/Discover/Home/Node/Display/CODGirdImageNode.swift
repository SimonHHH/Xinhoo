//
//  CODGirdImageNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/25.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


class CODGirdImageNode: CODImageNode {
    
    var onClickCloser: (() ->())?
    
    var index = 0
    
    
    override func didLoad() {
        super.didLoad()
        
        self.addTarget(self, action: #selector(onClickImage), forControlEvents: .touchUpInside)
        
        
    }
    
    @objc func onClickImage() {
        
        self.onClickCloser?()
        
    }
    
}
