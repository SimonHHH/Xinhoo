//
//  CODCanReadListSectionVM.swift
//  COD
//
//  Created by XinHoo on 6/8/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODCanReadListCellVM: TableViewCellVM {
    
    var model: CODContactModel!
    
    convenience init(model: CODContactModel, identity: String, selectAction: CellSelectType) {
        self.init(name: identity)
        self.model = model
        self.selectAction = selectAction
    }
}

class CODCanReadListSectionVM: TableViewSectionVM<String, TableViewCellVM> {
    
}
