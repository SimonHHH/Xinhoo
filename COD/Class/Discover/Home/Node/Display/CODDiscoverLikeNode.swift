//
//  CODDiscoverLikeNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverLikeNode: YYLabelNode {
    
    convenience init(likerList: [CODPersonInfoModel], pageVM: CODDiscoverHomePageVM) {
        
        var att = NSMutableAttributedString(string: "")
                
        dispatch_sync_safely_to_main_queue {
            
            let font = UIFont.boldSystemFont(ofSize: 15)
            
            let likeImageView = UIImageView(image: UIImage(named: "circle_like_blue"))
            
            att = NSMutableAttributedString.yy_attachmentString(withContent: likeImageView, contentMode: .center, attachmentSize: likeImageView.size, alignTo: font, alignment: .center)
            
            att.yy_appendString(" ")
            
            for (index, liker) in likerList.enumerated() {
                
                let likerName = NSMutableAttributedString(string: liker.name)
                
                likerName.yy_setTextHighlight(likerName.yy_rangeOfAll(), color: UIColor(hexString: "#496CB8"), backgroundColor: UIColor(hexString: "#cbcbcb")) { (_, str, _, _) in
                    
                    pageVM.goToPersonInfo(jid: liker.jid)

                }
                
                likerName.yy_font = UIFont.boldSystemFont(ofSize: 15)
                
                att.append(likerName)
                
                if index < likerList.count - 1 {
                    att.append(NSAttributedString(string: "、"))
                }
                
            }
            
        }
        
        
        self.init(attributedText: att)
        
        _ = self.lineCount(count: 0)
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = super.layoutSpecThatFits(constrainedSize)
        
        return LayoutSpec {
            layout
                .padding([.left, .right], 8)
                .padding([.top, .bottom], 6)
        }
    }

    
}
