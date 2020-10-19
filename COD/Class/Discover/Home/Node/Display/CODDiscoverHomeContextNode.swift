//
//  CODDiscoverHomeContextNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport


class CODDiscoverHomeContextNode: YYLabelNode {
    
    @objc dynamic var realLineCount = 0
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        //        if let attributedText = self.attributedText {
        //
        //            let textContainer = YYTextContainer(size: CGSize(width: constrainedSize.max.width, height: CGFloat.greatestFiniteMagnitude))
        //            if let textLayout = YYTextLayout(container: textContainer, text: attributedText) {
        //                realLineCount = textLayout.lines.count
        //            }
        //
        //        }
        
        return super.layoutSpecThatFits(constrainedSize)
        
    }
    
    override func lineCount(count: Int) -> Self {
        
        _ = super.lineCount(count: count)
        
        DispatchQueue.main.async {
            
            self.yyLabel.numberOfLines = UInt(count)
            self.yyLabel.attributedText = self.attributedText
            self.yyLabel.sizeToFit()
//            self.setNeedsLayout()
        }
        
        return self
    }
    
    override func didLoad() {
        super.didLoad()
        
        if let attributedText = self.attributedText {
            
            let textContainer = YYTextContainer(size: CGSize(width: self.calculatedSize.width, height: CGFloat.greatestFiniteMagnitude))
            if let textLayout = YYTextLayout(container: textContainer, text: attributedText) {
                realLineCount = textLayout.lines.count
            }
            
        }
        
    }
    
}
