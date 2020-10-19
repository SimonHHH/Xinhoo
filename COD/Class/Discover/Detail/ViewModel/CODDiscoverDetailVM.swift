//
//  CODDiscoverDetailVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CODDiscoverDetailPageVM {
    
    let dataSource = BehaviorRelay<[DiscoverHomeSectionVM]>(value: [])
    
    init() {
        
        var items = [CODDiscoverDetailCellNodeVM]()
        items.append(CODDiscoverDetailCellNodeVM(name: CODDiscoverDetailCellNode.self))
        
        dataSource.accept([
            DiscoverHomeSectionVM(model: "", items: items)
        ])
        
    }
    
    
    
}
