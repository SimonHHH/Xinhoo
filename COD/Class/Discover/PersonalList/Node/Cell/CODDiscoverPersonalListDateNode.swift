//
//  CODDiscoverPersonalListDateNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport


class CODDiscoverPersonalListDateNode: CODDiscoverPersonalListCellNode {
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            ASTextNode2(attributedText: vm.dateAttr)
                .padding(.left, 8)
        }
    }
    
}
