//
//  DiscoverNodeUITools.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/16.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport

struct DiscoverNodeUITools {
    
    static func createLimitNode(model: CODDiscoverMessageModel?) -> ASLayoutSpec {

        var iconNode: ASDisplayNode!
        
        if model?.msgPrivacyTypeEnum == .Private {
            iconNode = ASImageNode(image: UIImage(named: "discover_personal_lock"))
        } else if model?.msgPrivacyTypeEnum == .LimitVisible || model?.msgPrivacyTypeEnum == .LimitInVisible {
            iconNode = ASImageNode(image: UIImage(named: "discover_personal_Roster"))
        } else {
            iconNode = ASDisplayNode()
        }
        
        return LayoutSpec {
            
            
            RelativeLayout(horizontalPosition: .end, verticalPosition: .end, sizingOption: .minimumSize) {
                return iconNode
            }
            .padding([.right, .bottom], 1)
            
        }
        
    }
    
}
