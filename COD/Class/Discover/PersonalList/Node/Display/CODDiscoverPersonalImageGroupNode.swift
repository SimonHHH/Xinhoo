//
//  CODDiscoverPersonalImageGroupNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverPersonalImageGroupNode: CODDisplayNode {
    
    var imageUrlList: [URL?] = []
    
    init(imageUrlList: [URL?]) {
        super.init()
        self.imageUrlList = imageUrlList
        
    }
    
    func createImageNode(url: URL?) -> CODImageNode {
        return CODImageNode(url: url, placeholderImage: UIImage(color: UIColor(hexString: kVCBgColorS)!))
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            if imageUrlList.count == 2 {
                
                HStackLayout(spacing: 1) {
                    
                    self.createImageNode(url: imageUrlList[0]).width(constrainedSize.max.width / 2)
                    self.createImageNode(url: imageUrlList[1]).width(constrainedSize.max.width / 2)
                    
                }
                
            } else if imageUrlList.count == 3 {
                
                HStackLayout(spacing: 1) {
                    
                    VStackLayout(spacing: 1) {
                        
                        self.createImageNode(url: imageUrlList[0]).preferredSize(CGSize(width: constrainedSize.max.width / 2, height: constrainedSize.max.height))
                        
                    }
                    
                    VStackLayout(spacing: 1) {
                        
                        self.createImageNode(url: imageUrlList[1]).preferredSize(CGSize(width: constrainedSize.max.width / 2, height: constrainedSize.max.height / 2))
                        
                        self.createImageNode(url: imageUrlList[2]).preferredSize(CGSize(width: constrainedSize.max.width / 2, height: constrainedSize.max.height / 2))
                        
                    }
                    
                }
                
            } else if imageUrlList.count >= 4 {
                
                HStackLayout(spacing: 1) {
                    
                    VStackLayout(spacing: 1) {
                        
                        self.createImageNode(url: imageUrlList[0]).preferredSize(CGSize(width: constrainedSize.max.width / 2, height: constrainedSize.max.height / 2))
                        
                        self.createImageNode(url: imageUrlList[2]).preferredSize(CGSize(width: constrainedSize.max.width / 2, height: constrainedSize.max.height / 2))
                        
                    }
                    
                    VStackLayout(spacing: 1) {
                        
                        self.createImageNode(url: imageUrlList[1]).preferredSize(CGSize(width: constrainedSize.max.width / 2, height: constrainedSize.max.height / 2))
                        
                        self.createImageNode(url: imageUrlList[3]).preferredSize(CGSize(width: constrainedSize.max.width / 2, height: constrainedSize.max.height / 2))
                        
                    }
                    
                }
                
            } else {
                
                HStackLayout {
                    
                    ASDisplayNode()
                    
                }
                
            }

        }
    }
}
