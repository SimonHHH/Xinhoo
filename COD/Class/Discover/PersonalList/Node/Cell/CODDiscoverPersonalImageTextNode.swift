//
//  CODDiscoverPersonalImageTextNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverPersonalImageTextNode: CODDiscoverPersonalListCellNode {
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            HStackLayout {
                
                OverlayLayout(content: {
                    
                    CODImageNode(url: vm.imageUrl, placeholderImage: UIImage(color: UIColor(hexString: kVCBgColorS)!))
                    .preferredSize(CGSize(width: 75, height: 75).screenScale())
                    
                }) {
                    DiscoverNodeUITools.createLimitNode(model: self.vm.model)
                }
                
                
                
                
                ASTextNode2(attributedText: vm.textAttr).lineCount(count: 3)
                    .padding(.left, 5)
                    .flexShrink(1)
                    .flexGrow(1)
                
            }
            .width(constrainedSize.max.width)
            
            
            
            
        }
    }
    
    override func didSelected() {
        pageVM?.showImageBrowser(msgId: self.vm.model?.msgId ?? "")
    }
    
}
