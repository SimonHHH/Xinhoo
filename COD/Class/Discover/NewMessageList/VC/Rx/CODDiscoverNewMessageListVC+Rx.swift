//
//  CODDiscoverNewMessageListVC+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/2.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MJRefresh


extension Reactive where Base: CODDiscoverNewMessageListVC {
    
    var installFooterBinder: Binder<Void> {
        
        return Binder(base) { (vc, _) in
            
            let refreshFooter = MJRefreshAutoNormalFooter { [weak vc] in
                
                guard let vc = vc else { return }
                
                vc.newMessageListPageVM.fetchData(isHeader: false, pageNum: vc.tableNode.view.pageNum + 1)
                
            }
            
            refreshFooter?.setTitle(NSLocalizedString("正在加载", comment: ""), for: .refreshing)
            refreshFooter?.setTitle("", for: .idle)
            refreshFooter?.setTitle("", for: .noMoreData)
            refreshFooter?.stateLabel.textColor = UIColor(hexString: "#8E8E8E")
            
            vc.tableNode.view.mj_footer = refreshFooter
            
            vc.tableNode.view.pageNum = 1
            
        }
        
    }
    
    var fetchDataErrorBinder: Binder<Void> {
        return Binder(base) { (vc, _) in
            
            if vc.tableNode.view.mj_footer != nil {
                vc.tableNode.view.mj_footer.endRefreshing()
            }
            
        }
    }
    
    var clearButtonEnableBinder: Binder<[DiscoverHomeSectionVM]> {
        return Binder(base) { (vc, value) in
            
            if value.first?.items.count ?? 0 > 0 {
                vc.clearItem?.isEnabled = true
            } else {
                vc.clearItem?.isEnabled = false
            }
            
            
            
        }
    }
    
    var endFooterLoadDataBinder: Binder<Void> {
        
        return Binder(base) { (vc, _) in
            
            if vc.tableNode.view.mj_footer != nil {
                vc.tableNode.view.mj_footer.endRefreshing()
            }
            
            vc.tableNode.view.pageNum += 1
            
        }
        
    }
    
    var notUnreadBinder: Binder<Void> {
        return Binder(base) { (vc, _) in
            
            if vc.tableNode.view.mj_footer != nil {
                vc.tableNode.view.mj_footer.endRefreshingWithNoMoreData()
                vc.tableNode.view.mj_footer = nil
            }
            
        }
    }
    
}
