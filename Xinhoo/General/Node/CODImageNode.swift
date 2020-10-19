//
//  CODImageNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import SDWebImage

class CODImageNode: CODControlNode {
    
    lazy var node: ASDisplayNode = {
        
        
        return ASDisplayNode { () -> UIView in
            
            let view = UIImageView()
            view.backgroundColor = .clear
            view.image = CustomUtil.getPlaceholderImage()
            
            return view
        }
        
    }()
    
    var imageView: UIImageView {
        return (self.node.view as! UIImageView)
    }
    
    override init() {
        super.init()

        
        self.node.clipsToBounds = true
        
    }
    
    convenience init(image: UIImage?) {
        self.init()
        
        dispatch_async_safely_to_main_queue {
            (self.node.view as! UIImageView).image = image
            (self.node.view as! UIImageView).contentMode = .scaleAspectFill
        }
        
        
    }
    
    convenience init(url: URL?, placeholderImage: UIImage? = nil) {
        
        self.init()
        
        dispatch_async_safely_to_main_queue {
            self.setImageURL(url, placeholderImage: placeholderImage)
        }
        
        
                
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
    
        return LayoutSpec {
            node.preferredSize(constrainedSize.max)
        }
        
    }
    
    func setImageURL(_ url: URL?, placeholderImage: UIImage? = nil) {
        
        (self.node.view as! UIImageView).sd_setImage(with: url, placeholderImage: placeholderImage, options: [.retryFailed]) { [weak self] (image, error, _, _) in
            guard let `self` = self else { return }
            
            if error != nil {
                return
            }
            
            (self.node.view as! UIImageView).image = image
            (self.node.view as! UIImageView).contentMode = .scaleAspectFill
        }
        
    }
    
    
}

extension ASImageNode {
    
    convenience init(image: UIImage?) {
        self.init()
        self.image = image
    }
    
}
