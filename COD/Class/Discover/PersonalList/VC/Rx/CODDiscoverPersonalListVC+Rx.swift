//
//  CODDiscoverPersonalListVC+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: CODDiscoverPersonalListVC {
    
    var loadingState: Binder<CODDiscoverPersonalListVCPageVM.LoadState> {
        
        return Binder(base) { (vc, state) in
            
            switch state {
                
            case .loading:
                vc.adapter.performUpdates(animated: true, completion: nil)

                
            case .footerLoadingEnd:
                if vc.collectionView.mj_footer != nil && vc.collectionView.mj_footer.state != .noMoreData {
                    vc.collectionView.pageNum += 1

                    vc.collectionView.mj_footer.endRefreshing()
                    //                    vc.imageBrowser.dataSource =
                }
                vc.adapter.performUpdates(animated: true, completion: nil)
                
            case .headerLoadingEnd:
                vc.collectionView.pageNum = 1
                vc.adapter.performUpdates(animated: true, completion: nil)
                
            case .noAnyMore:
                if vc.collectionView.mj_footer != nil {
                    vc.collectionView.mj_footer.endRefreshingWithNoMoreData()
//                    vc.collectionView.mj_footer = nil
//                    vc.collectionView.
                }
                vc.adapter.performUpdates(animated: true, completion: nil)
                
            case .ide, .loadingError:
                break
                
            case .addMessage:
                vc.adapter.performUpdates(animated: true, completion: nil)
            case .reloadData:
                
                CustomUtil.isPlayVideo(isPlay: false,isDelete: true)

                vc.reloadImageBrowserData()
                vc.adapter.performUpdates(animated: true, completion: nil)
            }
            
        }
        
    }
    
    var showImageBrowserBinder: Binder<String> {
        
        return Binder(base) { (vc, msgId) in
            
            vc.createImageBrowser()
            
            guard let imageBrowser = vc.imageBrowser else { return }
            
            vc.reloadImageBrowserData()
            
            let dataSourceArray = imageBrowser.dataSourceArray
            
            let index = dataSourceArray.firstIndex { (data) -> Bool in
                
                if let imageData = data as? YBIBImageData, imageData.msgID == msgId {
                    return true
                }
                
                if let videoData = data as? YBIBVideoData, videoData.msgID == msgId {
                    return true
                }
                
                return false
                
            }
            imageBrowser.currentPage = index ?? 0
            imageBrowser.backgroundColor = UIColor.black
            imageBrowser.shouldHideStatusBar = false
            imageBrowser.show(to: vc.view)
            
        }
        
    }
    
}
