//
//  Xinhoo_TextViewModel.swift
//  COD
//
//  Created by xinhooo on 2019/12/5.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class Xinhoo_TextViewModel: ChatCellVM {
    

    override init(name: String = UITableViewCell.self.description(), messageModel: CODMessageModel, cellHeight: CGFloat = UITableView.automaticDimension) {
        super.init(name: name, messageModel: messageModel)
        
        switch cellDirection {
        case .left:
            self.cellType = CODZZS_TextLeftTableViewCell.self.description()
        case .right:
            self.cellType = CODZZS_TextRightTableViewCell.self.description()
        }
        
    }

}
