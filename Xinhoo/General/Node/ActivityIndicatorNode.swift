//
//  ActivityIndicatorNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/27.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport


class ActivityIndicatorNode: CODDisplayNode {
    
    lazy var node: ASDisplayNode! = {
        
        let node = ASDisplayNode { () -> UIView in
            
            let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
            indicatorView.backgroundColor = UIColor.clear
            indicatorView.color = grayBackColor
            indicatorView.startAnimating()
            return indicatorView
            
        }
        
        node.backgroundColor = .clear
        node.style.preferredSize = CGSize(width: 20, height: 20)
        
        return node
        
    }()
    

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            return node
        }
    }
    
}
