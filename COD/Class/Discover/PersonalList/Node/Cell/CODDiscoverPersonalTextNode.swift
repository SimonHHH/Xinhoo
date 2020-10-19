//
//  CODDiscoverPersonalTextNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverPersonalTextNode: CODDiscoverPersonalListCellNode {
    
    var textNode = ASTextNode2()
    
    
    required init(pageVM: CODDiscoverPersonalListVCPageVM?, vm: CODDiscoverPersonalListCellVM) {
        super.init(pageVM: pageVM, vm: vm)
        self.backgroundColor = UIColor(hexString: kVCBgColorS)
        textNode.attributedText = vm.textAttr
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            CenterLayout(centeringOptions: .Y, sizingOptions: .minimumXY) {
                textNode
                
            }
            .padding(.left, 4)
            
            
        }
    }
    
    override func didSelected() {
        
        let vc = CODDiscoverDetailVC(pageType: .normal(momentsId: vm.model?.msgId ?? ""))
        UIViewController.current()?.navigationController?.pushViewController(vc)
        
    }
    
}
