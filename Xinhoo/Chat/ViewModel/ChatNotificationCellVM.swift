//
//  ChatNotificationCellVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

class ChatNotificationCellVM: ChatCellVM {
    

    override init(name: String = CODNoticeChatCell.self.description(), messageModel: CODMessageModel, cellHeight: CGFloat = UITableView.automaticDimension) {
        super.init(name: CODNoticeChatCell.self.description(), messageModel: messageModel)
    }

}
