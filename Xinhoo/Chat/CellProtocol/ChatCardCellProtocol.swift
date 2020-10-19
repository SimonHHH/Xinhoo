//
//  ChatCardCellProtocol.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


extension Xinhoo_CardLeftTableViewCell: TableViewCellDataSourcesType {
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
        guard let cellVM = cellVM as? CellViewModelType  else {
            return
        }
        
        self.commandConfig(pageVM: pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)
        
        cellVM.cellLocationBR
            .distinctUntilChanged()
            .bind(to: self.rx.cellLocationBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        
        configRefreshHeadImage()
        

    }
}

extension Xinhoo_CardRightTableViewCell: TableViewCellDataSourcesType {
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
        guard let cellVM = cellVM as? CellViewModelType  else {
            return
        }
        
        self.commandConfig(pageVM: pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)
        
        cellVM.cellLocationBR
            .distinctUntilChanged()
            .bind(to: self.rx.cellLocationBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        

    }
}

extension Xinhoo_CardLeftTableViewCell: XinhooCellViewProtocol, Xinhoo_BaseLeftCellProtocol { }
extension Xinhoo_CardRightTableViewCell: XinhooCellViewProtocol { }
