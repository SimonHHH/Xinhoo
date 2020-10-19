//
//  ChatNotificationCellProtocol.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

extension CODNoticeChatCell: TableViewCellDataSourcesType {
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
//        guard let cellVM = cellVM as? ChatNotificationCellVM  else {
//            return
//        }
        
        guard let pageVM = pageVM as? CODChatMessageDisplayPageVM,
            let cellVM = cellVM as? ChatNotificationCellVM else {
                return
        }
        
        
        self.viewModel = cellVM
        
        //因为tableView是反转的
        if let lastCellVM = lastCellVM as? ChatCellVM {
            viewModel?.nextCellVM = lastCellVM
        }
        
        if let nextCellVM = nextCellVM as? ChatCellVM {
            viewModel?.lastCellVM = nextCellVM
        }
        
        
        self.isFirst = cellVM.isFirst
        self.notificationMessageModel = cellVM.messageModel
        self.backgroundColor = UIColor.clear

    }
}

