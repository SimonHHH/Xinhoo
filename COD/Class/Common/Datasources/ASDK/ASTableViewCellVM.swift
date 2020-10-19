//
//  ASTableViewCellVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxDataSources
import RxDataSources_Texture
import RxSwift
import RxCocoa
import AsyncDisplayKit

protocol ASTableCellViewModelType: IdentifiableType, Equatable {
    
    var cellType: CODCellNode.Type { get }
    var cellHeight: CGFloat { get set }
    
}

class ASTableViewCellVM: NSObject, ASTableCellViewModelType {
    
    var identity: String {
        return self.cellType.description()
    }
    
    static func == (lhs: ASTableViewCellVM, rhs: ASTableViewCellVM) -> Bool {
        return lhs.cellType == rhs.cellType && lhs.identity == rhs.identity
    }
    
    var cellType: CODCellNode.Type
    var cellHeight: CGFloat
    
    init(name: CODCellNode.Type, cellHeight: CGFloat = UITableView.automaticDimension) {
        self.cellType = name
        self.cellHeight = cellHeight
    }
    
    var selectAction: CellSelectType?
}

protocol ASCellNodeDataSourcesType {
    func configCellVM(cellVM: ASTableViewCellVM, indexPath: IndexPath)
    func configPageVM(pageVM: Any?, indexPath: IndexPath)
    func configCellVM(pageVM: Any?, cellVM: ASTableViewCellVM, lastCellVM: ASTableViewCellVM?, nextCellVM: ASTableViewCellVM?, indexPath: IndexPath)
    func didSelected(pageVM: Any?, cellVM: ASTableViewCellVM, indexPath: IndexPath)
}

extension ASCellNodeDataSourcesType {
    func configCellVM(pageVM: Any?, cellVM: ASTableViewCellVM, lastCellVM: ASTableViewCellVM?, nextCellVM: ASTableViewCellVM?, indexPath: IndexPath) {}
    func configCellVM(cellVM: ASTableViewCellVM, indexPath: IndexPath) {}
    func configPageVM(pageVM: Any?, indexPath: IndexPath) {}
    func didSelected(pageVM: Any?, cellVM: ASTableViewCellVM, indexPath: IndexPath) {}
}

