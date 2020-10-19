//
//  CODButtonNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/31.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class CODHitScaleButtonNode: CODButtonNode {
    

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let width = self.bounds.size.width * 3;
        let height = self.bounds.size.height * 3;
        let hitEdgeInsets = UIEdgeInsets(top: -height, left: -width, bottom: -height, right: -width)
        
        if hitEdgeInsets == .zero || !self.isEnabled || self.isHidden || self.alpha == 0 {
            return super.point(inside: point, with: event)
        }
        
        
        let relativeFrame = self.bounds
        let hitFrame = relativeFrame.inset(by: hitEdgeInsets)
        return hitFrame.contains(point)
    }

}

class CODButtonNode: ASButtonNode {
    
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
    }

}
