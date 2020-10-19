//
//  CODDiscoverPersonalListYearNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverPersonalListYearNode: CODDiscoverPersonalListCellNode {
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            CenterLayout(centeringOptions: .Y, sizingOptions: .minimumXY) {
                ASTextNode2(attributedText: self.vm.yearAttr)
            }
            .padding(.right, 8)

        }
        
        
    }
    
    
}
