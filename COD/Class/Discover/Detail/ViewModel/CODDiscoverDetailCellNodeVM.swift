//
//  CODDiscoverDetailCellNodeVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

class CODDiscoverDetailCellNodeVM: CODDiscoverHomeCellVM {
    
    override init(model: CODDiscoverMessageModel) {
        super.init(model: model)
        self.cellType = CODDiscoverDetailCellNode.self

    }
    
}
