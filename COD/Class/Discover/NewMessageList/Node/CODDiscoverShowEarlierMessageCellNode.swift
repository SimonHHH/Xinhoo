//
//  CODDiscoverShowEarlierMessageCellNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/2.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverShowEarlierMessageCellNode: CODCellNode, ASCellNodeDataSourcesType {
    
    weak var pageVM: CODDiscoverNewMessageListPageVM?
    
    required init(_ cellVM: ASTableViewCellVM) {
        super.init(cellVM)
        self.selectionStyle = .none
    }
    
    func configPageVM(pageVM: Any?, indexPath: IndexPath) {
        self.pageVM = pageVM as? CODDiscoverNewMessageListPageVM
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            CenterLayout(centeringOptions: .XY) {
                
                ASTextNode2(text: NSLocalizedString("查看更早的消息...", comment: ""))
                    .font(UIFont.systemFont(ofSize: 14))
                    .foregroundColor(UIColor(hexString: "#808080"))
                
            }
            .height(60)
        }
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.addBorder(toSide: .bottom, withColor: UIColor(hexString: "#E5E5E5")!, borderWidth: 0.5)
    }
    
    func didSelected(pageVM: Any?, cellVM: ASTableViewCellVM, indexPath: IndexPath) {
        
        self.pageVM?.showEarlierMessage()
        
    }
    
}
