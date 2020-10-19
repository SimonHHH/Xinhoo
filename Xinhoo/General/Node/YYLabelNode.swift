//
//  YYLabelNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import YYText
import AsyncDisplayKit
import TextureSwiftSupport


class YYLabelNode: CODDisplayNode {
    
   
    var numberOfLines = 0
    
    @_NodeLayout var attributedText: NSAttributedString? {
        didSet {
            dispatch_sync_safely_to_main_queue {
                self.yyLabel.attributedText = self.attributedText
            }
            
            //            self.setNeedsLayout()
        }
    }
    
    var yyLabel: YYLabel!
    var node: ASDisplayNode!
    
    override init() {
        
        super.init()
        
        dispatch_sync_safely_to_main_queue {
            self.yyLabel = YYLabel()
            
            self.node = ASDisplayNode(viewBlock: { [weak self] () -> UIView in
                guard let `self` = self else { return YYLabel() }
                return self.yyLabel
            })
        }
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var size = CGSize.zero

        dispatch_sync_safely_to_main_queue {
            
            size = self.yyLabel.sizeThatFits(CGSize(width: constrainedSize.max.width, height: CGFloat.greatestFiniteMagnitude))
            self.node.style.preferredSize = size

        }
        
        let layout = ASWrapperLayoutSpec(layoutElement: self.node)
        
        layout.style.preferredSize = size
        
        return layout
        
    }
    
    convenience init(text: String) {
        self.init()
        
        self.attributedText = NSAttributedString(string: text)        
        
    }
    
    convenience init(attributedText: NSAttributedString) {
        self.init()
        
        self.attributedText = attributedText
        
    }
    
    
    func font(_ font: UIFont) -> Self {
        
        guard let attributedText = self.attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return self
        }
        
        attributedText.yy_font = font
        
        self.attributedText = attributedText
        
        
        return self
        
    }
    
    
    func foregroundColor(_ color: UIColor?) -> Self {
        
        guard let attributedText = self.attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return self
        }
        
        attributedText.yy_color = color
        
        self.attributedText = attributedText
        
        
        return self
        
    }
    
    func lineCount(count: Int) -> Self {
        
        numberOfLines = count
        
        dispatch_async_safely_to_main_queue {
            self.yyLabel.numberOfLines = UInt(count)
        }
        
        return self
        
    }
    
}
