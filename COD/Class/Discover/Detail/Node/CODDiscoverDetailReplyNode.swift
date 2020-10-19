//
//  CODDiscoverDetailReplyNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/16.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverDetailReplyNode: YYLabelNode {
    
    convenience init(replyModel: CODDiscoverReplyModel) {

        let att = NSMutableAttributedString()
        let font = UIFont.systemFont(ofSize: 16)

        
        if let replyWho = replyModel.replyWho?.name {
            
            var temp = NSMutableAttributedString(string: NSLocalizedString("discover.reply", comment: ""))
            temp.yy_font = font
            temp.yy_color = .black
            att.append(temp)
            
            let replyWhoAtt = NSMutableAttributedString(string: replyWho)
            replyWhoAtt.yy_setTextHighlight(replyWhoAtt.yy_rangeOfAll(), color: UIColor(hexString: "#496CB8"), backgroundColor: UIColor(hexString: "#cbcbcb")) { (_, _, _, _) in
                
                CustomUtil.pushPersonInfoVC(jid: replyModel.replyWho?.jid ?? "")
                
            }
            replyWhoAtt.yy_font = UIFont.boldSystemFont(ofSize: 16)
            att.append(replyWhoAtt)
            

            temp = NSMutableAttributedString(string: "：")
            temp.yy_font = font
            temp.yy_color = .black
            
            att.append(temp)
            
        }
        
        
        let contect = NSMutableAttributedString(string: replyModel.text)
        contect.yy_font = font
        contect.yy_color = .black
        
        att.append(contect)
        

        self.init(attributedText: att)
        _ = self.lineCount(count: 0)
    }
    

}
