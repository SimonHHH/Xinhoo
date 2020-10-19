//
//  DiscoverPersonalListRefreshFooter.swift
//  COD
//
//  Created by Sim Tsai on 2020/8/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class DiscoverPersonalListRefreshFooter: MJRefreshAutoNormalFooter {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func endRefreshingWithNoMoreData() {
        
        super.endRefreshingWithNoMoreData()
        
        let view = PersonalListFooterView()
        self.bounds = view.frame
        self.addSubview(view)
    }
    

}
