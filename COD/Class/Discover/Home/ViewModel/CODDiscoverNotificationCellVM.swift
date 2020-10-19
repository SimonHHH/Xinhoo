//
//  CODDiscoverNotificationCellVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/1.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


class CODDiscoverNotificationCellVM: ASTableViewCellVM {
    
    enum Style {
        case normal
        case fail(failType: FailType, id: String)
        
        enum FailType {
            case moment
            case like
            case comment
        }
        
        var failType: FailType? {
            
            if case .fail(failType: let failType, id: _) = self {
                return failType
            } else {
                return nil
            }

        }
        
        var title: String {
            
            switch self.failType {
            case .comment:
                return NSLocalizedString("评论未发送", comment: "")
            case .like:
                return NSLocalizedString("点赞未发送", comment: "")
            case .moment:
                return NSLocalizedString("未发送成功", comment: "")
            default:
                return ""
            }

            
        }
        
        
        
        var isFail: Bool {
            
            if case .fail(id: _) = self {
                return true
            }
            
            return false
            
        }
        
        var id: String {
            
            if case .fail(failType: _, id: let id) = self {
                return id
            }
            
            return ""
            
        }
        
    }
    
    
    let style: CODDiscoverNotificationCellVM.Style
    
    init(style: CODDiscoverNotificationCellVM.Style) {
        self.style = style
        super.init(name: CODDiscoverNotificationNode.self)
    }
    
    
}
