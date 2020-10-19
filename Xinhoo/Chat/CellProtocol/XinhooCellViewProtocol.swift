//
//  ChatCellViewProtocol.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt


protocol XinhooCellViewProtocol where Self: CODBaseChatCell, CellViewModelType: ChatCellVM {
    associatedtype CellViewModelType
    var viewModel: CellViewModelType? { get set }
    func commandConfig(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath)
    var isFirst:Bool { get set }
}

extension Reactive where Base: CODBaseChatCell {
    
    var sendFailBinder: Binder<String> {
        return Binder(base) { (view, messageId) in
            
            if view.isHidden == true {
                return
            }
            
            if messageId != view.messageModel.msgID {
                return
            }
            
            view.messageModel.editMessage(model: nil, status: .Failed)
            view.configModel(lastModel: view.lastMessage, model: view.messageModel, nextModel: view.nextModel)
            
            var showName = false
            if view.pageVM?.chatListModel.chatTypeEnum == .channel || CustomUtil.getIsCloudMessage(messageModel: view.messageModel){
                showName = true
            } else if view.pageVM?.chatListModel.chatTypeEnum == .groupChat {
                showName = view.pageVM?.chatListModel.groupChat?.showname ?? false
            }
            
            view.showName(showName: showName)
        }
    }
    
    var messageStatusBinder: Binder<Void> {
        return Binder(base) { (view, value) in
            
            if view.isHidden == true {
                return
            }
            
            view.configModel(lastModel: view.lastMessage, model: view.messageModel, nextModel: view.nextModel)
           
            var showName = false
            if view.pageVM?.chatListModel.chatTypeEnum == .channel || CustomUtil.getIsCloudMessage(messageModel: view.messageModel){
                showName = true
            } else if view.pageVM?.chatListModel.chatTypeEnum == .groupChat {
                showName = view.pageVM?.chatListModel.groupChat?.showname ?? false
            }
            
            view.showName(showName: showName)
        }
    }
    
}

extension XinhooCellViewProtocol {
    
    func commandConfig(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
        guard let pageVM = pageVM as? CODChatMessageDisplayPageVM,
            let cellVM = cellVM as? Self.CellViewModelType else {
                return
        }
        
        viewModel = cellVM
        viewModel?.indexPath = indexPath
        self.indexPath = indexPath
        
        //因为tableView是反转的
        if let lastCellVM = lastCellVM as? ChatCellVM {
            viewModel?.nextCellVM = lastCellVM
        }
        
        if let nextCellVM = nextCellVM as? ChatCellVM {
            viewModel?.lastCellVM = nextCellVM
        }
        
        self.isFirst = cellVM.isFirst
        self.isCloudDisk = pageVM.isCloudDisk
        self.chatDelegate = pageVM
        self.pageVM = pageVM
        
        self.tapRpViewBlock = { [weak pageVM]  (messageModel) in
            
            guard let pageVM = pageVM else { return }
            
            pageVM.jumpToMessage(msgID: messageModel.msgID)

            
        }
        
        
        
        self.configModel(lastModel:cellVM.lastModel, model: cellVM.messageModel, nextModel: cellVM.nextModel)
        
        
        var showName = false
        if pageVM.chatListModel.chatTypeEnum == .channel || CustomUtil.getIsCloudMessage(messageModel: cellVM.messageModel){
            showName = true
        } else if pageVM.chatListModel.chatTypeEnum == .groupChat {
            showName = pageVM.chatListModel.groupChat?.showname ?? false
        }
        
        self.showName(showName: showName)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.init(kUpdataMessageStatueView))
            .map{ $0.userInfo?["id"] as? String }
            .filterNil()
            .bind(to: self.rx.sendFailBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        
        messageModel.rx.observe(\.status)
            .filterNil()
            .distinct()
            .mapTo(Void())
            .bind(to: self.rx.messageStatusBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        
        messageModel.rx.observe(\.isReaded)
            .filterNil()
            .distinct()
            .mapTo(Void())
            .bind(to: self.rx.messageStatusBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        
    }
}

