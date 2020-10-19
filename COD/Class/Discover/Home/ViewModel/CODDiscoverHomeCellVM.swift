//
//  CODDiscoverHomeCellVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import SwiftDate
import RxRealm
import RxSwift
import RxCocoa

class CODDiscoverHomeCellVM: ASTableViewCellVM {
    
    var nickName: String
    var text: String?
    var headerUrl: URL?
    var msgId: String
    var atAttr: NSMutableAttributedString?

    override var identity: String {
        return self.msgId
    }
    
    static func == (lhs: CODDiscoverHomeCellVM, rhs: CODDiscoverHomeCellVM) -> Bool {
        return lhs.msgId == rhs.msgId
    }
    
    
    var model: CODDiscoverMessageModel? {
        return CODDiscoverMessageModel.getModel(id: self.msgId)
    }
    
    
    
    init(model: CODDiscoverMessageModel) {
        
        self.msgId = model.msgId

        if model.text.isEmpty == false {
            self.text = model.text
        }
        
        if model.senderJid == UserManager.sharedInstance.jid {
            self.headerUrl = URL(string: UserManager.sharedInstance.avatar ?? "")
            self.nickName = UserManager.sharedInstance.nickname ?? ""
        } else {
            let contact = CODPersonInfoModel.getPersonInfoModel(jid: model.senderJid)
            self.nickName = contact?.name ?? ""
            self.headerUrl = URL(string: contact?.userpic.getHeaderImageFullPath(imageType: 0) ?? "")
        }
        

        super.init(name: CODDiscoverHomeCellNode.self)
        
        if model.atList.count > 0 {
            var atString = NSLocalizedString("提到了:", comment: "")
            if self.isMeSend {
                
                for (index, at) in model.atList.enumerated() {
                    
                    if at.name.count <= 0 {
                        continue
                    }
                    
                    if index == model.atList.count - 1 {
                        atString += at.name
                    } else {
                        atString += "\(at.name)、"
                    }
                    
                }
                
                atAttr = NSMutableAttributedString(string: atString)
                
            } else {
                atString += NSLocalizedString("我", comment: "")
                atAttr = NSMutableAttributedString(string: atString)
            }

        }
        
        atAttr?.yy_color = UIColor(hexString: "#B3B3B3")
        atAttr?.yy_font = UIFont.systemFont(ofSize: 13)
        atAttr?.yy_lineSpacing = 4

    }
    
    var isMeSend: Bool {
        
        guard let model = CODDiscoverMessageModel.getModel(id: msgId) else {
            return false
        }
        
        return model.senderJid == UserManager.sharedInstance.jid
    }
    
    var canDelete: Bool {
        return self.isMeSend
    }
    
    var locationInfo: LocationInfo? {
        return self.model?.localInfo?.detached()
    }
    
    
    /**
     1-59分钟显示：XX分钟前
     昨天之前显示：x小时前
     隔天显示：昨天
     其他显示：X天前
     */
    var createTime: String {
        
        guard let model = self.model else {
            return ""
        }
        
        return DiscoverTools.toTimeString(model.createTime)
        
    }
    
    var isLike: Bool {
                
        if let model = CODDiscoverMessageModel.getModel(id: msgId),
           let _ = model.getLiker(UserManager.sharedInstance.jid) {
            return true
        } else {
            return false
        }
        
    }
    
    var showCheckLimit: Bool {
        
        if isMeSend {
            
            switch self.model?.msgPrivacyTypeEnum {
            case .LimitInVisible, .LimitVisible:
                return true
            default:
                return false
            }

        }
        
        return false
    }
    
}
