//
//  CODDiscoverNewMessageCellNodeVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODDiscoverNewMessageCellNodeVM: ASTableViewCellVM {
    
    var serverMsgId: String
    var headerUrl: URL?
    var nickName: String
    var momentsType: MomentsType
    var messageType: CODDiscoverCommentMessageType
    var replyAtt: NSMutableAttributedString
    var atAtt: NSMutableAttributedString
    
    var createTime: String {
        return DiscoverTools.toNewMessageTimeString(self.model?.createTime ?? 0)
    }
    
    
    var model: CODDiscoverNewMessageModel? {
        return CODDiscoverNewMessageModel.getModel(id: serverMsgId)
    }
    
    init(model: CODDiscoverNewMessageModel) {
        
        self.serverMsgId = model.serverMsgId
        self.headerUrl = URL(string: model.sender?.userpic.getHeaderImageFullPath(imageType: 0) ?? "")
        self.nickName = model.sender?.name ?? ""
        self.momentsType = model.momentsTypeEnum
        self.messageType = model.commentTypeEnum
        
        self.replyAtt = NSMutableAttributedString()
        
        self.atAtt = NSMutableAttributedString(string: NSLocalizedString("同时提到了你", comment: ""))
        self.atAtt.yy_color = UIColor(hexString: "#333333")
        self.atAtt.yy_font = UIFont.systemFont(ofSize: 14)
        
        if let spreadReplayUserNickName = model.spreadReplayUserNickName {
            var replyTmpAtt = NSMutableAttributedString(string: NSLocalizedString("回复了", comment: ""))
            replyTmpAtt.yy_color = UIColor(hexString: "#333333")
            replyTmpAtt.yy_font = UIFont.systemFont(ofSize: 14)
            
            replyAtt.append(replyTmpAtt)
            
            let nickName = NSMutableAttributedString(string: spreadReplayUserNickName)
            nickName.yy_color = UIColor(hexString: "#496CB8")
            nickName.yy_font = UIFont.boldSystemFont(ofSize: 14)
            
            replyAtt.append(nickName)
            
            
            replyTmpAtt = NSMutableAttributedString(string: "：")
            replyTmpAtt.yy_color = UIColor(hexString: "#333333")
            replyTmpAtt.yy_font = UIFont.systemFont(ofSize: 14)
            
            replyAtt.append(replyTmpAtt)
            
        }
        
        let replyTmpAtt = NSMutableAttributedString(string: model.comment)
        replyTmpAtt.yy_color = UIColor(hexString: "#333333")
        replyTmpAtt.yy_font = UIFont.systemFont(ofSize: 14)
        
        replyAtt.append(replyTmpAtt)
        replyAtt.yy_lineSpacing = 3
        
        super.init(name: CODDiscoverNewMessageCellNode.self)
        

    }


}
