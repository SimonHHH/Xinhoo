//
//  ASButtonNodeExt.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit

extension ASButtonNode {
    
    convenience init(text: String, font: UIFont? = nil, textColor: UIColor?, state: UIControl.State = .normal) {
        
        self.init()
        self.setTitle(text, with: font, with: textColor, for: state)
        
    }
    
    convenience init(image: UIImage?, state: UIControl.State = .normal) {
        
        self.init()
        self.setImage(image, for: state)
        
    }
    
    func title(title: String) -> ASButtonNode {
        
//        self.setTitle(title, with: nil, with: nil, for: .normal)
        
        let att = self.attributedTitle(for: .normal)?.mutableCopy() as! NSMutableAttributedString
        
        att.replaceCharacters(in: att.yy_rangeOfAll(), with: title)
        
        self.setAttributedTitle(att, for: .normal)
        
        return self
        
    }
    
}
