//
//  CODDiscoverDetailCommentCellNodeVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/16.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CODDiscoverDetailCommentCellNodeVM: ASTableViewCellVM {
    
    
    let replyModel: CODDiscoverReplyModel
    var replyModelForDB: CODDiscoverReplyModel? {
        return CODDiscoverReplyModel.getModel(id: replyModel.replyId)
    }
    
    
    init(replyModel: CODDiscoverReplyModel) {
        
        self.replyModel = replyModel
        
        super.init(name: CODDiscoverDetailCommentCellNode.self)
        
    }
    
    var headerUrl: URL? {
        return URL(string: self.replyModel.sender?.userpic.getHeaderImageFullPath(imageType: 0) ?? "")
    }
    
    var nickName: String {
        return self.replyModel.sender?.name ?? ""
    }
    
    var time: String {
        return DiscoverTools.toTimeString(self.replyModel.createTime)
    }
}
