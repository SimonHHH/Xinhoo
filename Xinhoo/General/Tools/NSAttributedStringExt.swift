//
//  NSAttributedStringExt.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    func font(_ font: UIFont) -> NSAttributedString {
        
        if let attributedString = self.mutableCopy() as? NSMutableAttributedString {
            attributedString.yy_font = font
            return attributedString
        }
        
        return self
        
    }
    
    func foregroundColor(_ color: UIColor?) -> NSAttributedString {
        
        if let attributedString = self.mutableCopy() as? NSMutableAttributedString {
            attributedString.yy_color = color
            return attributedString
        }
        
        return self
        
    }
    

    
}

