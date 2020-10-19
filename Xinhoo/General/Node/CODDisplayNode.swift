//
//  CODDisplayNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import SwifterSwift

class CODDisplayNode: ASDisplayNode {
    override init() {
        super.init()
        self.backgroundColor = UIColor.clear
        self.automaticallyManagesSubnodes = true
        
    }
    
}

extension CODDisplayNode {
    
    func getSuperTableViewCell() -> UITableViewCell? {
        
        var view = self.view
        while view.superview != nil {
            
            if view.superview!.isKind(of: UITableViewCell.self) == true {
                return view.superview as? UITableViewCell
            }
            
            view = view.superview!
            
        }
        
        return nil
        
        
        
    }
    
}

extension CODControlNode {
    
    func getSuperTableViewCell() -> UITableViewCell? {
        
        var view = self.view
        while view.superview != nil {
            
            if view.superview!.isKind(of: UITableViewCell.self) == true {
                return view.superview as? UITableViewCell
            }
            
            view = view.superview!
            
        }
        
        return nil
        
        
        
    }
    
}
