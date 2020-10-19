//
//  CODChatFileCellNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/29.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODChatFileCellNode: CODChatCellNode {
    
    var fileContectNode: CODChatFileContentNode
    
    override init(vm: ChatCellVM, pageVM: CODChatMessageDisplayPageVM) {
        
        fileContectNode = CODChatFileContentNode(vm: vm, pageVM: pageVM)
        
        super.init(vm: vm, pageVM: pageVM)
        
        
    
    }
    
    override var chatContentNode: ASLayoutSpec {
        return  LayoutSpec {
            fileContectNode
                .background(self.backgroundNode)
                
        }
    }
    
    override var cellWidth: CGFloat {
        
        if pageVM.isMultipleSelelct.value {
            return KScreenWidth - 47
        } else {
            return KScreenWidth
        }

    }
    
}
