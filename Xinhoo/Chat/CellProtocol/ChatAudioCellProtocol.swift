//
//  ChatAudioCellProtocol.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

extension CODZZS_AudioLeftTableViewCell: TableViewCellDataSourcesType, Xinhoo_BaseLeftCellProtocol {

    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
        self.commandConfig(pageVM: pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)
        
        configRefreshHeadImage()
        

    }
}

extension CODZZS_AudioRightTableViewCell: TableViewCellDataSourcesType {
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        self.commandConfig(pageVM: pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)

    }
}

extension CODZZS_AudioLeftTableViewCell: XinhooCellViewProtocol { }
extension CODZZS_AudioRightTableViewCell: XinhooCellViewProtocol { }
