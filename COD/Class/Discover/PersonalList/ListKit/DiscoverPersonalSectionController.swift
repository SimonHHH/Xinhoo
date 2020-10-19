//
//  DiscoverPersonalSectionController.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import IGListKit

class DiscoverPersonalSectionController: ListSectionController {
    
    let pageVM: CODDiscoverPersonalListVCPageVM
     var cellVM: CODDiscoverPersonalListCellVM?
    
    init(pageVM: CODDiscoverPersonalListVCPageVM) {
        self.pageVM = pageVM
        super.init()
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {

        guard let cell: CODDiscoverPersonalListCell = collectionContext?.dequeueReusableCell(of: CODDiscoverPersonalListCell.self, for: self, at: index) as? CODDiscoverPersonalListCell else {
            fatalError()
        }
        
        if let cellVM = cellVM {
            cell.configNode(pageVM: pageVM, vm: cellVM)
        }

        return cell
        
    }
    
    override func didUpdate(to object: Any) {
        self.cellVM = object as? CODDiscoverPersonalListCellVM
    }
    
    override func didSelectItem(at index: Int) {
        if let cell = collectionContext?.cellForItem(at: index, sectionController: self) as? CODDiscoverPersonalListCell {
            cell.didSelected()
        }
    }
    
}
