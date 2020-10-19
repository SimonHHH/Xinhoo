//
//  ChatCellVM+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/31.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa


extension Reactive where Base: ChatCellVM {
    
    var messageStatus: Observable<XinhooTimeAndReadView.Status> {
        
        let messageSendStatus = base.model.rx.observe(\.status)
            .filterNil()
            .map { CODMessageStatus(rawValue: $0) ?? CODMessageStatus.Succeed }
            .distinct()
        
        let isReaded = base.model.rx.observe(\.isReaded).filterNil().distinct()
        
        return Observable.combineLatest(messageSendStatus, isReaded).map { (messageSendStatus, isReaded) in
            
            switch (messageSendStatus, isReaded) {
                
            case (.Pending, _), (.Delivering, _), (.Failed, _):
                return .sending
            case (.Succeed, false):
                return .sendSuccessful
                
            case (.Succeed, true):
                return .haveRead
                
            default:
                return .unknown
                
            }
            
        }
        
            
        
        
        
    }
    
}
