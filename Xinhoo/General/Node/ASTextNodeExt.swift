//
//  ASTextNodeExt.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport
import YYText

extension ASTextNode {
    
    convenience init(text: String) {
        self.init()
        self.attributedText = NSAttributedString(string: text)
    }
    
    convenience init(attributedText: NSAttributedString) {
        self.init()
        self.attributedText = attributedText
    }
    
    func font(_ font: UIFont) -> ASTextNode {
        
        guard let attributedText = self.attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return self
        }
        
        attributedText.yy_setFont(font, range: attributedText.yy_rangeOfAll())
        self.attributedText = attributedText
        
        return self
        
    }
    
    
    func foregroundColor(_ color: UIColor?) -> ASTextNode {
        
        guard let attributedText = self.attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return self
        }
        
        attributedText.yy_setColor(color, range: attributedText.yy_rangeOfAll())
        self.attributedText = attributedText
        
        return self
        
    }
    
    
    
}


extension ASTextNode2 {
    
    convenience init(text: String) {
        self.init()
        self.attributedText = NSAttributedString(string: text)
    }
    
    convenience init(attributedText: NSAttributedString) {
        self.init()
        self.attributedText = attributedText
    }
    
    func font(_ font: UIFont) -> ASTextNode2 {
        
        guard let attributedText = self.attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return self
        }
        
        attributedText.yy_setFont(font, range: attributedText.yy_rangeOfAll())
        self.attributedText = attributedText
        
        return self
        
    }
    
    
    func foregroundColor(_ color: UIColor?) -> ASTextNode2 {
        
        guard let attributedText = self.attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return self
        }
        
        attributedText.yy_setColor(color, range: attributedText.yy_rangeOfAll())
        self.attributedText = attributedText
        
        return self
        
    }
    
    func lineCount(count: Int) -> ASTextNode2 {
        
        self.maximumNumberOfLines = UInt(count)
                        
        return self
        
    }
    
    func lineSpacing(_ lineSpacing: CGFloat) -> ASTextNode2 {
        
        guard let attributedText = self.attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return self
        }
        
        attributedText.yy_lineSpacing = lineSpacing
        self.attributedText = attributedText
        
        return self
        
    }
    
    
    
    
}
