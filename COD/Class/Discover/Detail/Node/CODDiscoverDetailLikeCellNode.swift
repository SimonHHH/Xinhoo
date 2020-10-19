//
//  CODDiscoverHomeLikeCellNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import RxSwift
import RxCocoa
import RxRealm

class CODDiscoverDetailLikeCellNode: CODCellNode, ASCellNodeDataSourcesType {
    
    @_NodeLayout var likeNode: CODDiscoverLikerHeaderNode!
    
    let bgNode = ASDisplayNode()
    
    weak var pageVM: CODDiscoverDetailPageVM?
    
    var likerCellVM: CODDiscoverDetailLikerCellNodeVM {
        return self.cellVM as! CODDiscoverDetailLikerCellNodeVM
    }
    

    required init(_ cellVM: ASTableViewCellVM) {
        
        super.init(cellVM)
        
        self.likeNode = CODDiscoverLikerHeaderNode(likerList: likerCellVM.likerList)
        
        bgNode.backgroundColor = UIColor(hexString: kVCBgColorS)
        
        self.selectionStyle = .none

    }
    
    func configPageVM(pageVM: Any?, indexPath: IndexPath) {
        self.pageVM = pageVM as? CODDiscoverDetailPageVM
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return LayoutSpec {
            
            HStackLayout(alignItems: .center) {
                
                ASImageNode(image: UIImage(named: "circle_like_blue"))
                    .padding(7)
                    .padding(.left, 3)
                    .alignSelf(.start)
                
                
                self.likeNode.width(constrainedSize.max.width - 100)
            }
            .padding([.top, .bottom], 8)
            .padding(.top, 10)
            .background(bgNode)
            .padding(.right, 15)
            .padding(.left, 10)
            .width(constrainedSize.max.width)
        }
        
    }
    
    
    
    override func didLoad() {
        super.didLoad()
        
        guard let momentsId = self.pageVM?.pageType.momentsId else {
            return
        }
        
        if let likerList = CODDiscoverMessageModel.getModel(id: momentsId)?.likerList {
            
            Observable.collection(from: likerList)
                .bind { (list) in
                    self.likeNode.configLikerList(likerList: list.toArray())
            }
            .disposed(by: self.rx.disposeBag)
            
        }
        

    }
    
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        var bubbleLayer: BubbleLayer?
        
        if self.pageVM?.dataSource.value.count ?? 0 > (indexPath?.section ?? 0) + 1 {
            bubbleLayer = CODDiscoverBubbleBottomLayer(size: bgNode.view.size)
        } else {
            bubbleLayer = BubbleLayer(size: bgNode.view.size)
        }
        
        
        bubbleLayer?.arrowWidth = 14
        bubbleLayer?.arrowHeight = 6
        bubbleLayer?.arrowRadius = 0
        bubbleLayer?.arrowDirection = ArrowDirectionTop
        bubbleLayer?.arrowPosition = 0.02
        bubbleLayer?.cornerRadius = 6
        
        bgNode.view.layer.mask = bubbleLayer?.layer()
    }

    
    
}
