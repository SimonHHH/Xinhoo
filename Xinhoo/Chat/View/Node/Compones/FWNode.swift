//
//  FWNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class FWNode: CODControlNode {
    
    
    let fwname: String
    let color: UIColor?
    
    let textNode1: ASTextNode2
    let textNode2: ASTextNode2
    
    init(fwname: String, color: UIColor?) {
        
        self.fwname = fwname
        self.color = color
        
        textNode1 = ASTextNode2(text: NSLocalizedString("转发的消息", comment: ""))
        textNode1.displaysAsynchronously = false
        
        textNode2 = ASTextNode2(attributedText:NSAttributedString(string: NSLocalizedString("来自", comment: ""))
            .font(UIFont.systemFont(ofSize: 14)).foregroundColor(self.color) + NSAttributedString(string: fwname).font(UIFont.boldSystemFont(ofSize: 14)).foregroundColor(self.color))
        textNode1.displaysAsynchronously = false
        
        super.init()
        
        
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            VStackLayout {
                
                textNode1
                    .font(UIFont.systemFont(ofSize: 14))
                    .foregroundColor(self.color)
                    .lineCount(count: 1)
                    .padding(.bottom, 2)
                    .flexShrink(1)
                
                textNode2
                    .lineCount(count: 1)
                    .flexShrink(1)
                
                
            }
            
        }
    }
    
}
