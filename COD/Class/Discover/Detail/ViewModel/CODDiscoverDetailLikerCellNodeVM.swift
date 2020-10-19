//
//  CODDiscoverDetailLikerCellNodeVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


class CODDiscoverDetailLikerCellNodeVM: ASTableViewCellVM {

    let likerList: [CODPersonInfoModel]
    
    init(likerList: [CODPersonInfoModel]) {
        
        self.likerList = likerList
        
        super.init(name: CODDiscoverDetailLikeCellNode.self)

    }
}
