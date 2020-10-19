//
//  CODCanReadListViewModel.swift
//  COD
//
//  Created by XinHoo on 6/8/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CODCanReadListViewModel: NSObject {
    
    enum CanReadType: Int {
        case read = 1
        case unread = 2
    }
    
    enum ChatType: Int {
        case `private` = 1
        case groupChat = 2
    }
    
    var readType = BehaviorRelay<CanReadType>(value: .read)
    
    var chatType = BehaviorRelay<ChatType>(value: .private)
    
    var dataSources = BehaviorRelay<[CODCanReadListSectionVM]>(value: [])
        
    func fetchJidsDataSource(jids: [String]) {
        let cellId = CODCanReadListTVCell.description()
        let modelList = jids.map { (jid) -> CODCanReadListCellVM? in
            if let model = CODContactRealmTool.getContactByJID(by: jid) {
                return CODCanReadListCellVM(model: model, identity: cellId, selectAction: CanReadListSelect())
            }else{
                return nil
            }
        }.compactMap{ $0 }

        let sectionVM = CODCanReadListSectionVM(model: "", items: modelList, footViewHeight: 0.0, headViewHeight: 0.0)
        self.dataSources.accept([sectionVM])
    }
    
}

class CanReadListSelect: CellSelectType {
    func didSelected(view: UIView, pageVM: Any?, cellVM: TableViewCellVM, indexPath: IndexPath) {
        print("CanReadListSelect")
    }
}
