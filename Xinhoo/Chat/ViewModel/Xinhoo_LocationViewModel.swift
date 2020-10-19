//
//  Xinhoo_LocationViewModel.swift
//  COD
//
//  Created by xinhooo on 2019/12/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation

class Xinhoo_LocationViewModel: ChatCellVM {
    
    override init(name: String = UITableViewCell.self.description(), messageModel: CODMessageModel, cellHeight: CGFloat = UITableView.automaticDimension) {
        super.init(name: name, messageModel: messageModel)
        
        switch cellDirection {
        case .left:
            self.cellType = Xinhoo_LocationLeftTableViewCell.self.description()
        case .right:
            self.cellType = Xinhoo_LocationRightTableViewCell.self.description()
        }
        
    }
    
    var locationTitle: String? {
        return self.messageModel.location?.name
    }
    
    var locationContent: String? {
        return self.messageModel.location?.address
    }

}
