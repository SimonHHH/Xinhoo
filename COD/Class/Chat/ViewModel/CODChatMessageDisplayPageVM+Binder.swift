//
//  CODChatMessageDisplayPageVM+Binder.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/24.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


extension Reactive where Base: CODChatMessageDisplayPageVM {
    var removeMeesageBinder: Binder<[String]> {
        return Binder(self.base) { (viewModel, value) in
            
            var cellVMs: [ChatCellVM] = [ChatCellVM]()
            
            value.forEach { (msgID) in
                CODMessageRealmTool.deleteMessage(by: msgID)
                viewModel.dataSources.first?.items.forEachReversed({ (vm) in
                    if vm.messageModel.msgID == msgID {
                        cellVMs.append(vm)
                    }
                })
            }
            
            let lastMsg = viewModel.chatListModel.chatHistory?.messages.filter("isDelete == false").sorted(byKeyPath: "datetime", ascending: true).last
            
            CODChatListRealmTool.updateLastDateTimeWithDeleteMsg(id: viewModel.chatListModel.id, lastDateTime: lastMsg?.datetime ?? "0")
            
            guard var items = viewModel.dataSources.first?.items else  {
                return
            }
            
            for willDelVM in cellVMs {
                
                if items.contains(willDelVM) {
                    
                    willDelVM.lastCellVM?.nextCellVM = willDelVM.nextCellVM
                    willDelVM.nextCellVM?.lastCellVM = willDelVM.lastCellVM
                    
                    items.removeAll(willDelVM)
                    
                }
                
            }
            
            
           
            
            viewModel.dataSources.first?.items.removeAll(cellVMs)
            viewModel.dataSouecesBR.accept(viewModel.dataSources)

        }
    }
    
    var removeAllMeesageBinder: Binder<Void> {
        return Binder(self.base) { (viewModel, value) in

            CustomUtil.clearChatRecord(chatId: viewModel.chatObj.chatId) {

                viewModel.dataSources.first?.items.removeAll()
                viewModel.dataSouecesBR.accept(viewModel.dataSources)
                CODChatListRealmTool.deleteChatListHistory(by: viewModel.chatObj.chatId)
            }
            
        }
    }
    
    var resendMessageBinder: Binder<CODMessageModel> {
        return Binder(self.base) { (viewModel, value) in

            if let indexPath = viewModel.findIndexPath(messageId: value.msgID) {
                viewModel.resendMessageReloadCellBR.accept(indexPath)
            }
            
        }
    }
}
