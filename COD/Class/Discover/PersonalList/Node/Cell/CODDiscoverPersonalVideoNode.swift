//
//  CODDiscoverPersonalVideoNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverPersonalVideoNode: CODDiscoverPersonalListCellNode {
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            HStackLayout {
                
                OverlayLayout(content: {
                    
                    OverlayLayout(content: {
                        CODImageNode(url: vm.imageUrl, placeholderImage: UIImage(named: "video_placeholder"))
                            .preferredSize(CGSize(width: 75, height: 75).screenScale())
                    }) {
                        RelativeLayout(horizontalPosition: .start, verticalPosition: .end, sizingOption: .minimumSize) {
                            ASImageNode(image: UIImage(named: "personal_list_video"))
                        }
                        .padding([.left, .bottom], 2)
                        
                        
                    }
                    
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
    
    override func didLoad() {
        super.didLoad()
    }
    
    override func didSelected() {

        pageVM?.showImageBrowser(msgId: self.vm.model?.msgId ?? "")
    
    }
    
}
