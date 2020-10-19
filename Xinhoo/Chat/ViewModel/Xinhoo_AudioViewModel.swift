//
//  Xinhoo_AudioViewModel.swift
//  COD
//
//  Created by xinhooo on 2019/12/10.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class Xinhoo_AudioViewModel: ChatCellVM {
    

    override init(name: String = UITableViewCell.self.description(), messageModel: CODMessageModel, cellHeight: CGFloat = UITableView.automaticDimension) {
        super.init(name: name, messageModel: messageModel)
        
        switch cellDirection {
        case .left:
            self.cellType = CODZZS_AudioLeftTableViewCell.self.description()
        case .right:
            self.cellType = CODZZS_AudioRightTableViewCell.self.description()
        }
        
    }

}
