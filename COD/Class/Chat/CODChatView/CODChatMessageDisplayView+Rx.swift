//
//  CODChatMessageDisplayView+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: CODChatMessageDisplayView {
    var rpIndexPath: Binder<IndexPath?> {
        return Binder(self.base) { (view, indexPath) in
            
            view.rpIndexPath = indexPath
            
            guard let indexPath = indexPath else { return }
            
            guard let isVisible = view.tableView.indexPathsForVisibleRows?.contains(indexPath) else { return }
            
            if isVisible {
                
                if let cell = view.tableView.cellForRow(at: indexPath) as? CODBaseChatCell{
                    view.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                    cell.flashingCell()
                }
                
            } else {
                view.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
            
            
        }
    }
    
    var newMessageScrollToBottom: Binder<CODMessageModel?> {
        return Binder(self.base) { (view, message) in
            
            if view.isAutoScrollToBottom == false {
                return
            }
            
            view.scrollToLastMessage()
 
        }
    }
    
    var newMessageCounter: Binder<CODMessageModel?> {
        return Binder(self.base) { (view, message) in

            if view.isShowOperationView == "show" {
                
                
                view.gotoBottomView.setCount(count: Int(view.gotoBottomView.countLab!.text!)! + 1)
            }
        }
    }
    
    var editMessageBinder: Binder<IndexPath> {
        return Binder(self.base) { (view, indexPath) in
            
            if view.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                view.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
        }
    }
    
    var resendMessageReloadCellBinder: Binder<IndexPath> {
        
        return Binder(self.base) { (view, indexPath) in
            
            if view.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                view.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
        }
        
    }
    
    var cellDidTapedAvatarImageBinder: Binder<(CODBaseChatCell, CODMessageModel)> {
        
        return Binder(self.base) { (view, value) in
            view.cellDidTapedAvatarImage(value.0, model: value.1)
        }
        
    }
    
    var cellDidTapedFwdImageViewBinder: Binder<(CODBaseChatCell, CODMessageModel)> {
        return Binder(self.base) { (view, value) in
            view.cellDidTapedFwdImageView(value.0, model: value.1)
        }
    }
    
    var cellDidLongTapedAvatarImageBinder: Binder<(CODBaseChatCell, CODMessageModel)> {
        return Binder(self.base) { (view, value) in
            view.cellDidLongTapedAvatarImage(value.0, model: value.1)
        }
    }
    
    var cellDidTapedLinkBinder: Binder<(CODBaseChatCell, URL)> {
        return Binder(self.base) { (view, value) in
            view.cellDidTapedLink(value.0, linkString: value.1)
        }
    }
    

    
    var cellDidTapedPhoneBinder: Binder<(CODBaseChatCell, String)> {
        return Binder(self.base) { (view, value) in
            view.cellDidTapedPhone(value.0, phoneString: value.1)
        }
    }
    

    
    var cellCardActionBinder: Binder<(CODBaseChatCell, CODMessageModel?)> {
        return Binder(self.base) { (view, value) in
            view.cellCardAction(value.0, message: value.1)
        }
    }
    
    var cellTapMessageBinder: Binder<(CODBaseChatCell, CODMessageModel?)> {
        return Binder(self.base) { (view, value) in
            view.cellTapMessage(message: value.1, value.0)
        }
    }
    
    var cellLongPressMessageBinder: Binder<(UIView, ChatCellVM?, UIView)> {
        return Binder(self.base) { (view, value) in
            view.cellLongPressMessage(cellVM: value.1, value.0, value.2)
        }
    }
    
    var cellTapViewerBinder: Binder<(CODBaseChatCell,CODMessageModel)> {
        return Binder(self.base) { (view, value) in
            view.cellTapViewer(cell: value.0, message: value.1)
        }
    }
    
    var cellDeleteMessageBinder: Binder<CODMessageModel?> {
        return Binder(self.base) { (view, value) in
            view.cellDeleteMessage(message: value)
        }
    }
    
    var cellTapAtAllBinder: Binder<(CODBaseChatCell, CODMessageModel?)> {
        return Binder(self.base) { (view, value) in
            view.cellTapAtAll(message: value.1, cell: value.0)
        }
    }
    
    var referToMessageIDBinder: Binder<([(sendTime: String, msgId: String)])> {
        return Binder(self.base) { (view, value) in
            
            if value.count > 0 {
                view.gotoAtView.isHidden = false
            } else {
                view.gotoAtView.isHidden = true
            }
            view.gotoAtView.setCount(count: value.count)
        }
    }
    
    var referToMessageRemoveBinder: Binder<(sendTime: String, msgId: String)> {
        return Binder(self.base) { (view, value) in

            var count = view.gotoAtView.countLab?.text?.int ?? 0
            count -= 1
            
            if count > 0 {
                view.gotoAtView.isHidden = false
            } else {
                view.gotoAtView.isHidden = true
            }
            
            view.gotoAtView.setCount(count: count)
        }
    }
    
    var referToMessageAddBinder: Binder<(sendTime: String, msgId: String)> {
        return Binder(self.base) { (view, value) in

            var count = view.gotoAtView.countLab?.text?.int ?? 0
            count += 1
            
            if count > 0 {
                view.gotoAtView.isHidden = false
            } else {
                view.gotoAtView.isHidden = true
            }
            
            view.gotoAtView.setCount(count: count)
        }
    }
    
    var removeAllMessageBinder: Binder<Void> {
        return Binder(self.base) { (view, _) in
            view.newMessageCount = 0
        }
    }
    
    var updateNewMessageCountBinder: Binder<Int> {
        return Binder(self.base) { (view, value) in
            view.newMessageCount = value
        }
    }
    
    var playNextAudioBinder: Binder<(indexPath: IndexPath, cellVM: ChatCellVM)> {
        return Binder(self.base) { (view, value) in
            if let cell = view.tableView.cellForRow(at: value.indexPath) as? CODAudioTableViewCellType {
                cell.playAudio()
            } else {
                view.playAudio(cellVM: value.cellVM)
            }
        }
    }
    
    var reloadTableViewBinder: Binder<IndexPath> {
        
        return Binder(self.base) { (view, value) in
            view.tableView.reloadRows(at: [value], with: .none)
        }
        
    }
    

    
    
    
}

