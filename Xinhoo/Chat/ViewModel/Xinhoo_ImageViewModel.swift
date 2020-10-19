//
//  Xinhoo_ImageViewModel.swift
//  COD
//
//  Created by xinhooo on 2019/12/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class Xinhoo_ImageViewModel: ChatCellVM {
    

    override init(name: String = UITableViewCell.self.description(), messageModel: CODMessageModel, cellHeight: CGFloat = UITableView.automaticDimension) {
        super.init(name: name, messageModel: messageModel)
        
        switch cellDirection {
        case .left:
            self.cellType = Xinhoo_ImageLeftTableViewCell.self.description()
        case .right:
            self.cellType = Xinhoo_ImageRightTableViewCell.self.description()
        }
        
    }

}
