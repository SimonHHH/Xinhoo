//
//  CODDiscoverPersonalListImageGroupNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverPersonalListImageGroupNode: CODDiscoverPersonalListCellNode {
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            HStackLayout {
                
                OverlayLayout(content: {
                    
                    CODDiscoverPersonalImageGroupNode(imageUrlList: vm.imageUrlList)
                    .preferredSize(CGSize(width: 75, height: 75).screenScale())
                    
                }) {
                    DiscoverNodeUITools.createLimitNode(model: self.vm.model)
                }
                

                VStackLayout(justifyContent: .spaceBetween) {
                    
                    
                    ASTextNode2(attributedText: vm.textAttr).lineCount(count: 3)
                    
                    
                    ASTextNode2(attributedText: vm.groupImageCountAttr)
                    
                }
                .padding(.left, 5)
                .flexGrow(1)
                .flexShrink(1)

                
            }
            .width(constrainedSize.max.width)
            
            
            
            
            
            
            
        }
    }
    
    override func didSelected() {
        
        pageVM?.showImageBrowser(msgId: self.vm.model?.msgId ?? "")
    }
    
}
