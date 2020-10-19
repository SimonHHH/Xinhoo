//
//  CODDiscoverPersonalListImageNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport


class CODDiscoverPersonalListImageNode: CODDiscoverPersonalListCellNode {
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            OverlayLayout(content: {
                
                CODImageNode(url: vm.imageUrl, placeholderImage: UIImage(color: UIColor(hexString: kVCBgColorS)!))
                .preferredSize(constrainedSize.max)
                
            }) {
                DiscoverNodeUITools.createLimitNode(model: self.vm.model)
            }
            
            
            
            
            
        }
    }
    
    override func didSelected() {
        pageVM?.showImageBrowser(msgId: self.vm.model?.msgId ?? "")
    }
    
}

