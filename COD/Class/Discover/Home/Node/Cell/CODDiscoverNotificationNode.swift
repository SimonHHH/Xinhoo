//
//  CODDiscoverNotificationNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/1.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverNotificationNode: CODCellNode, ASCellNodeDataSourcesType {
    
     var notificationButton: CODDiscoverNotificationButton!
    
    var vm: CODDiscoverNotificationCellVM {
        return cellVM as! CODDiscoverNotificationCellVM
    }
    
    required init(_ cellVM: ASTableViewCellVM) {
        super.init(cellVM)
        
        selectionStyle = .none
        
        notificationButton = CODDiscoverNotificationButton(style: vm.style)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            CenterLayout(centeringOptions: .XY) {
                notificationButton
                .minSize(CGSize(width: 180, height: 40))
            }
            .minSize(CGSize(width: 180, height: 40))
            .padding(.bottom, 5)

        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        notificationButton.addTarget(self, action: #selector(gotoNewMessageList), forControlEvents: .touchUpInside)
    }
    
    @objc func gotoNewMessageList() {
        
        if vm.style.isFail {
            let vc = CODDiscoverDetailVC(pageType: .fail(localMomentsId: vm.style.id), failType: vm.style.failType)
            UIViewController.current()?.navigationController?.pushViewController(vc)
            
        } else {
            
            let vc = CODDiscoverNewMessageListVC()
            UIViewController.current()?.navigationController?.pushViewController(vc)
            
        }
        
        
        
    }
    
}
