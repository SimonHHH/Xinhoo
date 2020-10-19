//
//  CODDiscoverHomeDataSourcesAdapter.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

protocol DiscoverScrollChangedNavigationBarType where Self: UIView  {
    func configAlpha(_ alpha: CGFloat)
}

protocol DiscoverScrollChangedNavigationBarPageType where Self: UIViewController {
    

    var tableHeaderView: UIView { get }
    var navigationBar: DiscoverScrollChangedNavigationBarType { get }
    
    
}

class CODDiscoverHomeDataSourcesAdapter: ASTableDataSourcesAdapter<CODDiscoverHomePageSectionVM> {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let vc = self.delegate as? DiscoverScrollChangedNavigationBarPageType else {
            return
        }
        
        
        let tableHeaderView = vc.tableHeaderView
        
        if let discoverHeaderView = tableHeaderView as? DiscoverHeaderView {
            
            if scrollView.contentOffset.y <= 30 {
                discoverHeaderView.topShadow.alpha =  scrollView.contentOffset.y / CGFloat(30)
            }
            
        }
        
        if scrollView.contentOffset.y > tableHeaderView.height {
            vc.navigationBar.configAlpha(1)
            return
        }
        
        vc.navigationBar.configAlpha((scrollView.contentOffset.y / tableHeaderView.height))
        
    }

}
