//
//  CODDiscoverLikerHeaderNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverLikerHeaderNode: CODDisplayNode {
    
    var node: CODDisplayNode!
    
    var likerList: [CODPersonInfoModel] = []
    
    convenience init(likerList: [CODPersonInfoModel]) {
        self.init()

        self.likerList = likerList
        
        dispatch_sync_safely_to_main_queue {
            self.discoverLikerHeaderView = CODDiscoverLikerHeaderView()
            
            self.discoverLikerHeaderView.collectionView.rx.observe(\.contentSize)
            .skip(1)
            .distinct()
                .bind { [weak self] (_) in
                    guard let `self` = self else { return }
                    self.setNeedsLayout()
            }
            .disposed(by: self.rx.disposeBag)
            
        }
        
    }
    
    var discoverLikerHeaderView: CODDiscoverLikerHeaderView!
    
    var collectionViewSize = CGSize.zero
    
    func configLikerList(likerList: [CODPersonInfoModel]) {
        
        self.likerList = likerList
        self.setNeedsLayout()
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var size = CGSize.zero

        dispatch_sync_safely_to_main_queue {
            
            size = self.discoverLikerHeaderView.sizeThatFits(constrainedSize.max)

            if self.discoverLikerHeaderView.likerList != self.likerList {
                self.discoverLikerHeaderView.likerList = self.likerList
            }

        }
        
        
        return LayoutSpec {
            
            ASDisplayNode { () -> UIView in
                self.discoverLikerHeaderView
            }
            .preferredSize(size)
            
        }

    }
    
}
