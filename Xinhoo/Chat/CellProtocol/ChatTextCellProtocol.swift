//
//  ChatCellDataSourcesProtocol.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension CODZZS_TextLeftTableViewCell: TableViewCellDataSourcesType, Xinhoo_BaseLeftCellProtocol {
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
        guard let cellVM = cellVM as? CellViewModelType  else {
            return
        }
        
        self.commandConfig(pageVM: pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)
        
        cellVM.cellLocationBR
            .skip(1)
            .distinct()
            .bind(to: self.rx.cellLocationBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        
        configRefreshHeadImage()
        

    }
}
extension CODZZS_TextRightTableViewCell: TableViewCellDataSourcesType {
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
        guard let cellVM = cellVM as? CellViewModelType  else {
            return
        }
        
        self.commandConfig(pageVM: pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)
        
        cellVM.cellLocationBR
            .skip(1)
            .distinct()
            .bind(to: self.rx.cellLocationBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        

    }
}

extension CODZZS_TextLeftTableViewCell: XinhooCellViewProtocol {
}

extension CODZZS_TextRightTableViewCell: XinhooCellViewProtocol {
}
