//
//  CODDiscoverCommendListView.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverCommentListNode: CODDisplayNode {
    
    var nodeList: [YYLabelNode] = []
    
    var pageVM: CODDiscoverHomePageVM!
    var indexPath: IndexPath?
    
    
    
    convenience init(likerList: [CODPersonInfoModel], commentList: [CODDiscoverReplyModel], pageVM: CODDiscoverHomePageVM, indexPath: IndexPath?) {
        
        self.init()
        
        self.pageVM = pageVM
        self.indexPath = indexPath
        
        if likerList.count > 0 {
            nodeList.append(createLikerNode(likerList: likerList))
        }
                
        nodeList.append(contentsOf: createReplyList(commentList: commentList))
        

    }
    
    func createReplyList(commentList: [CODDiscoverReplyModel]) -> [YYLabelNode] {
        
        let nodeList = commentList.map { createReply(replyModel: $0) }.compactMap { $0 }
        
        return nodeList
    }
    
    func createReply(replyModel: CODDiscoverReplyModel) -> YYLabelNode? {
        
        let replyNode = CODDiscoverReplyNode(replyModel: replyModel, indexPath: self.indexPath, pageVM: self.pageVM)
        
        replyNode.replyCloser = { [weak self] (jid,replyWhoName) in
            
            guard let `self` = self, let indexPath = self.indexPath else { return }
            
            let rect = self.convert(self.bounds, to: nil)
            self.pageVM.srcollOffset(offset: rect.maxY)
            
            self.pageVM.comment(indexPath: indexPath, replayUser: jid, replyUserName: replyWhoName)
            
        }
        
        return replyNode

    }
    
    
    func createLikerNode(likerList: [CODPersonInfoModel]) -> YYLabelNode {
        
        return CODDiscoverLikeNode(likerList: likerList, pageVM: self.pageVM)

    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            VStackLayout {
                
                nodeList
                
            }

        }
        
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        if nodeList.count >= 2 && nodeList.first?.isKind(of: CODDiscoverLikeNode.self) ?? false {
            nodeList.first?.view.addBorder(toSide: .bottom, withColor: UIColor(hexString: "#DEDEDE")!)
        }
        
    }
    
    
    
    
}
