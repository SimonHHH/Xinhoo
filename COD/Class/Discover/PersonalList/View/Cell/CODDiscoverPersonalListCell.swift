//
//  CODDiscoverPersonalListCell.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit


class CODDiscoverPersonalListCell: UICollectionViewCell {
    
    var node: CODDiscoverPersonalListCellNode?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func configNode(pageVM: CODDiscoverPersonalListVCPageVM?, vm: CODDiscoverPersonalListCellVM) {
        
        node?.removeFromSupernode()
        
        node = vm.cellType.nodeType.init(pageVM: pageVM, vm: vm)
        
        node?.frame = self.bounds
        
        self.contentView.addSubnode(node!)
        

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func didSelected() {
        node?.didSelected()
    }
    
}
