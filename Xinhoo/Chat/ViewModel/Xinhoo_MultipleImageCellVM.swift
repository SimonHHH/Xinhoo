//
//  Xinhoo_MultipleImageCellVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/17.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class Xinhoo_MultipleImageCellVM: Xinhoo_ImageViewModel {
    override init(name: String = UITableViewCell.self.description(), messageModel: CODMessageModel, cellHeight: CGFloat = UITableView.automaticDimension) {
        super.init(name: name, messageModel: messageModel, cellHeight: cellHeight)
        self.cellType = CODChatTextureCell.self.description()
    }

}
