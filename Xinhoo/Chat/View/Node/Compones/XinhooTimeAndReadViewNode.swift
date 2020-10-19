//
//  XinhooTimeAndReadViewNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport


class XinhooTimeAndReadViewNode: CODDisplayNode {
    
    lazy var node: ASDisplayNode = {
        
        
        return ASDisplayNode { () -> UIView in
            let timeAndReadView: XinhooTimeAndReadView = XinhooTimeAndReadView()
            return timeAndReadView
        }
        
    }()
    
    var timeAndReadView: XinhooTimeAndReadView {
        return (self.node.view as! XinhooTimeAndReadView)
    }
    
    
    override init() {
        super.init()
        
        self.node.backgroundColor = UIColor.clear
        
    }
    
    convenience init(messageModel: CODMessageModel, style: XinhooTimeAndReadView.Style = .white) {
        self.init()
        

        (self.node.view as! XinhooTimeAndReadView).configMessageModel(messageModel, style: style)
        
        
    }
    
    convenience init(nikename: NSMutableAttributedString?, time: NSMutableAttributedString, status: XinhooTimeAndReadView.Status, style: XinhooTimeAndReadView.Style = .white) {
        self.init()
                
        self.timeAndReadView.set(nikename: nikename, time: time, status: status, style: style)
        
    }
    
    func setStatuImage(_ status: XinhooTimeAndReadView.Status, style: XinhooTimeAndReadView.Style = .white) {
        self.timeAndReadView.setStatuImage(status, style: style)
    }
    
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let size = self.node.view.systemLayoutSizeFitting(constrainedSize.max)
        
        return LayoutSpec {
            node.preferredSize(size)
        }
        
    }
    
    
    
}
