//
//  CODDiscoverPersonalListCameraNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverPersonalListCameraNode: CODDiscoverPersonalListCellNode {
    
    required init(pageVM: CODDiscoverPersonalListVCPageVM?, vm: CODDiscoverPersonalListCellVM) {
        super.init(pageVM: pageVM, vm: vm)
        self.backgroundColor = UIColor(hexString: "#F7F7F7")
    }
    
    var cameraNode = ASButtonNode(image: UIImage(named: "personal_list_camera"))
    

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            CenterLayout {
                cameraNode
            }

        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        cameraNode.addTarget(self, action: #selector(gotoPublish), forControlEvents: .touchUpInside)
        
    }
    
    @objc func gotoPublish() {
        DiscoverTools.openDiscoverPublishPage()
    }
    

}
