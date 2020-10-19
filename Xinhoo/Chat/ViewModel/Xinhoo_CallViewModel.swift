//
//  Xinhoo_CallViewModel.swift
//  COD
//
//  Created by Xinhoo on 2019/12/9.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation

class Xinhoo_CallViewModel: ChatCellVM {
    
    override init(name: String = UITableViewCell.self.description(), messageModel: CODMessageModel, cellHeight: CGFloat = UITableView.automaticDimension) {
        super.init(name: name, messageModel: messageModel)
        
        switch cellDirection {
        case .left:
            self.cellType = Xinhoo_CallLeftTableViewCell.self.description()
        case .right:
            self.cellType = Xinhoo_CallRightTableViewCell.self.description()
        }
    }
    
}
