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

class CODDiscoverDetailLikeCellNode: CODCellNode {
    
    @_NodeLayout var likeNode: CODDiscoverLikerHeaderNode!
    
    let bgNode = ASDisplayNode()
    
    override init() {
        super.init()
        
        
        let person1 =  CODPersonInfoModel()
        person1.name = "放风筝的的的的的的的的的的的的的的的的他"
        
        let person2 =  CODPersonInfoModel()
        person2.name = "小王子"
        
        self.likeNode = CODDiscoverLikerHeaderNode(likerList: [
            person1,
            person2,
            CODPersonInfoModel(),
            CODPersonInfoModel(),
            CODPersonInfoModel(),
            CODPersonInfoModel(),
            CODPersonInfoModel(),
            CODPersonInfoModel(),
            CODPersonInfoModel(),
            CODPersonInfoModel(),
            CODPersonInfoModel(),
            CODPersonInfoModel(),
        ])
        
        self.likeNode.style.width = ASDimension(unit: .fraction, value: 0.8)
        
        bgNode.backgroundColor = UIColor(hexString: "#F7F7F7")
        
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return LayoutSpec {
            
            HStackLayout(alignItems: .center) {
                
                ASImageNode(image: UIImage(named: "circle_like_blue"))
                    .padding(7)
                    .alignSelf(.start)
                
                
                self.likeNode
            }
            .padding([.top, .bottom], 8)
            .background(bgNode)
            .padding(.right, 10)
            .padding(.left, 15)
            .width(constrainedSize.max.width)
        }
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        bgNode.view.addBorder(toSide: .bottom, withColor: UIColor(hexString: "#DEDEDE")!)
    }
    
    
}
