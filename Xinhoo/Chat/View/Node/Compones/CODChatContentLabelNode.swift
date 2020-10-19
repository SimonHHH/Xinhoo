//
//  CODChatContentLabelNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/29.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport


class CODChatContentLabelNode: CODDisplayNode {
    
    let node: ASDisplayNode
    
    var chatContentLabel: CODChatContentLabel {
        return self.node.view as! CODChatContentLabel
    }
    
    let content: NSAttributedString
    let timeAtt: NSAttributedString
    let nikeName: NSMutableAttributedString?
    var status: XinhooTimeAndReadView.Status
    let timeStyle: XinhooTimeAndReadView.Style
    
    init(content: NSAttributedString,
         timeAtt: NSAttributedString,
         nikeName: NSMutableAttributedString? = nil,
         status: XinhooTimeAndReadView.Status = .unknown,
         style: XinhooTimeAndReadView.Style = .white) {
        
        
        self.node = ASDisplayNode { () -> UIView in
            return CODChatContentLabel()
        }
        
        self.content = content
        self.timeAtt = timeAtt
        self.nikeName = nikeName
        self.status = status
        self.timeStyle = style

        
        super.init()
        
        self.chatContentLabel.numberOfLines = 0
    }
    
    func setStatus(status: XinhooTimeAndReadView.Status) {
        self.status = status
        setNeedsLayout()
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        chatContentLabel.config(content: content.mutableCopy() as! NSMutableAttributedString, timeAtt: timeAtt.mutableCopy() as! NSMutableAttributedString, nikeName: nikeName, maxWidth: constrainedSize.max.width, minWidth: constrainedSize.min.width, status: status, style: self.timeStyle)
        
        let size = chatContentLabel.sizeThatFits(constrainedSize.max)
        
        return LayoutSpec {
            
            node
                .preferredSize(size)
            
        }
    }
    
}

