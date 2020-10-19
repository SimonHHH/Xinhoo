//
//  CODDiscoverHomeVC+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import EmptyDataSet_Swift

extension Reactive where Base: CODDiscoverHomeVC {
    
    var bindHeaderRefresh: Binder<Void> {
        
        return Binder(base) { (vc, _) in
            vc.tableNode.view.mj_header.endRefreshing()
            vc.headerView.hideLoading()
            
            if (vc.tableNode.view.mj_footer != nil) {
                 vc.tableNode.view.mj_footer.endRefreshing()
            }
           
            vc.headerView.hideLoading()
            
            vc.tableNode.view.pageNum = 1
        }
        
    }
    
    var bindFooterRefresh: Binder<Void> {
        
        return Binder(base) { (vc, _) in
            if (vc.tableNode.view.mj_footer != nil) {
                vc.tableNode.view.mj_footer.endRefreshing()
                vc.tableNode.view.pageNum += 1
            }
        }
        
    }
    
    var bindNewMessageCountBinder: Binder<Void> {
        
        return Binder(base) { (vc, _) in
            
            vc.configHeaderView()
            
        }
        
    }
    
    var fetchDataErrorBinder: Binder<Void> {
        
        return Binder(base) { (vc, _) in
            
            if vc.tableNode.view.mj_footer != nil {
                vc.tableNode.view.mj_footer.endRefreshing()
            }

        }
        
    }
    
    var lastDataBinder: Binder<Void> {
        
        return Binder(base) { (vc, _) in
            
            if vc.tableNode.view.mj_footer != nil {
                vc.tableNode.view.mj_footer.endRefreshingWithNoMoreData()
            }

        }
        
    }
    
    var installFooterBinder: Binder<Void> {
        return Binder(base) { (vc, _) in
            
            let refreshFooter = MJRefreshAutoNormalFooter { [weak vc] in
                
                guard let vc = vc else { return }
                
                vc.discoverHomePageVM.fetchData(isHeaderLoad: false, pageNum: vc.tableNode.view.pageNum + 1, size: vc.tableNode.view.pageSize)
                
            }
            
            refreshFooter?.setTitle(NSLocalizedString("正在加载", comment: ""), for: .refreshing)
            refreshFooter?.setTitle("", for: .idle)
            refreshFooter?.setTitle("", for: .noMoreData)
            refreshFooter?.stateLabel.textColor = UIColor(hexString: "#8E8E8E")
            
            refreshFooter?.triggerAutomaticallyRefreshPercent = 0.1
            
            vc.tableNode.view.mj_footer = refreshFooter
            
            
        }
    }
    
    
    var installEmptyBinder: Binder<Void> {
        
        return Binder(base) { (vc, _) in
            vc.tableNode.view.emptyDataSetSource = vc
        }
        
    }
    
    
    var actionKeyboradBinder: Binder<(momentsId: String, replayUser: String, replyUserName: String?)> {
        return Binder(base) { (vc, value) in
            vc.replyView.isHidden = false
            vc.replyView.config(momentsId: value.momentsId, replyUser: value.replayUser, responder: vc, replyName: value.replyUserName)
            vc.replyView.show()
        }
    }
    
    var scrollBinder: Binder<(CGFloat)> {
        return Binder(base) { (vc, maxy) in
            vc.currentPointY = maxy
        }
    }
    
    var reloadCellBinder: Binder<IndexPath> {
        return Binder(base) { (vc, value) in
            
            vc.tableNode.reloadRows(at: [value], with: .automatic)
            
        }
    }
    
    
}
