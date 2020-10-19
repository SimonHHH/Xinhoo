//
//  CODNewMessageListPageVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//


import Foundation
import RxSwift
import RxCocoa

class CODDiscoverNewMessageListPageVM {
    
    let dataSource = BehaviorRelay<[DiscoverHomeSectionVM]>(value: [])
    
    init() {
        
//        var items = [CODDiscoverDetailCellNodeVM]()
//        items.append(CODDiscoverDetailCellNodeVM(name: CODDiscoverDetailCellNode.self))
//
//        let person1 =  CODPersonInfoModel()
//        person1.name = "放风筝的的的的的的的的的的的的的的的的他"
//
//        let person2 =  CODPersonInfoModel()
//        person2.name = "小王子"
//
//        let reply1 = CODDiscoverReplyModel()
//        reply1.sender = person2
//        reply1.text = "+1上车"
//
//        let reply2 = CODDiscoverReplyModel()
//        reply2.sender = person1
//        reply2.replyWho = person2
//        reply2.text = "滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴"
//
        
        
        dataSource.accept([
            DiscoverHomeSectionVM(model: "", items: [
            ]),

        ])
        
    }
    
    
    
}

