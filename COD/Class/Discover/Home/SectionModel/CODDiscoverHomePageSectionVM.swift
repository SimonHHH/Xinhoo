//
//  CODDiscoverHomePageSectionVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/3.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

typealias DiscoverHomeSectionVM = ASTableViewSectionVM<String, ASTableViewCellVM>

class CODDiscoverHomePageSectionVM: ASTableViewSectionVM<String, ASTableViewCellVM> {
    
    override init(model: String, items: [ASTableViewCellVM], title: String = "", sectionFootViewType: UIView.Type? = nil, sectionHeadViewType: UIView.Type? = nil, footViewHeight: CGFloat = UITableView.automaticDimension, headViewHeight: CGFloat = UITableView.automaticDimension) {
        super.init(model: model, items: items, title: title, sectionFootViewType: sectionFootViewType, sectionHeadViewType: sectionHeadViewType, footViewHeight: 10, headViewHeight: 0)
    }
    
    
    required public init(original: ASTableViewSectionVM<String, ASTableViewCellVM>, items: [Item]) {
        super.init(original: original, items: items)
    }
    
}


