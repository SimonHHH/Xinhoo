//
//  Xinhoo_CardViewModel.swift
//  COD
//
//  Created by xinhooo on 2019/12/2.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class Xinhoo_CardViewModel: ChatCellVM {
    
    override init(name: String = UITableViewCell.self.description(), messageModel: CODMessageModel, cellHeight: CGFloat = UITableView.automaticDimension) {
        super.init(name: name, messageModel: messageModel)
        
        switch cellDirection {
        case .left:
            self.cellType = Xinhoo_CardLeftTableViewCell.self.description()
        case .right:
            self.cellType = Xinhoo_CardRightTableViewCell.self.description()
        }
        
    }
    
    /// 名片cell操作按钮图片
    var cardActionImage: UIImage? {
        var image = UIImage(named: "businessCardAddFriend")
        if let contectModel: CODContactModel = CODContactRealmTool.getContactByJID(by: self.messageModel.businessCardModel?.jid ?? "") ,contectModel.isValid == true {
            image = UIImage(named: "businessCard")
        }
        if self.messageModel.businessCardModel?.jid.contains(UserManager.sharedInstance.loginName ?? "") ?? false{
            image = UIImage(named: "businessCard")
        }
        return image
    }
    
    var cardName: String? {
        return messageModel.businessCardModel?.name
    }
    
    var cardUserName: String {
        if let userString = messageModel.businessCardModel?.userdesc , userString.removeAllSapce.count > 0 {
            return "@" + userString
        }else{
            return " "
        }
    }
}
