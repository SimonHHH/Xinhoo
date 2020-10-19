//
//  CODProgressViewNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/23.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport

class CODProgressViewNode: CODControlNode {
    
    lazy var node: CODControlNode = {
        
        return CODControlNode { () -> UIView in
            
            let progressView = CODVideoCancleView()
            progressView.size = CGSize(width: 35, height: 35)

            return progressView
        }
        
    }()
    
    var progressView: CODVideoCancleView {
        return self.node.view as! CODVideoCancleView
    }
    
    var progress: Float = 0 {
        
        didSet {
            
            (self.node.view as! CODVideoCancleView).showVideoLoadingView(progress: progress)
            
        }
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            return self.node.preferredSize(constrainedSize.max)
        }

    }
    
    override func layoutDidFinish() {
        
        self.node.view.size = self.node.frame.size
       
        if progress > 0 {
            (self.node.view as! CODVideoCancleView).showVideoLoadingView(progress: progress)
        }
        
        
        
    }
    
}
