//
//  MessageViewController+Rx.swift
//  COD
//
//  Created by xinhooo on 2020/3/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base : MessageViewController {
    
    var removeAllMessageBinder: Binder<Void> {
        return Binder(base) { (vc, _) in
            vc.updateTopMessage()
        }
    }
    
    var editMessageBinder: Binder<CODMessageModel> {
        return Binder(base) { (vc, model) in
            
            if model.msgID == vc.chatListModel?.groupChat?.topmsg || model.msgID == vc.chatListModel?.channelChat?.topmsg {
                vc.updateTopMessage()
            }
            
        }
    }
    
    var updateTopMsgBinder: Binder<CODMessageModel?> {
        return Binder(base) { (vc, _) in
            vc.updateTopMessage()
        }
    }
    
    var removeMeesageBinder: Binder<Void> {
        return Binder(self.base) { (vc, value) in
            
            vc.messageView.messageDisplayViewVM.fetchImageData()
            vc.photoBrowser?.dataSourceArray = vc.messageView.messageDisplayViewVM.imageData
            vc.photoBrowser?.reloadData()

        }
    }
    
    var onClickImageBinder: Binder<(cellVM: ChatCellVM, imageIndex: Int)> {
        
        return Binder(self.base) { (view, value) in
            view.photoClick(message: value.cellVM.messageModel, imageView: UIImageView(), imageIndex: value.imageIndex)
        }
        
    }
    
    var cellSendMsgReationBinder: Binder<CODMessageModel?> {
        return Binder(self.base) { (vc, value) in
            vc.cellSendMsgReation(message: value)
        }
    }
    
    var cellTapAtBinder: Binder<(jid: String, cell: CODBaseChatCell, model: CODMessageModel)> {
        return Binder(self.base) { (vc, value) in
            vc.clickAtAction(jidStr: value.jid, model: value.model, cell: value.cell)
        }
    }
}
