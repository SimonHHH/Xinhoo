//
//  CODCanReadViewModel.swift
//  COD
//
//  Created by XinHoo on 5/22/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxCocoa

class CODCanReadViewModel: NSObject {
    
    enum CanReadType: Int {
        case `public` = 1
        case `private` = 2
        case partialCanRead = 3
        case partialNotRead = 4
    }
    
    var readType: CanReadType = .public
    
    var dataSource :BehaviorRelay<[CODCanReadCellModel]> = BehaviorRelay(value: [])
    
    var selectedContactModels :BehaviorRelay<[CODContactModel]> = BehaviorRelay(value: [])
    
    var selectedGroupModels :BehaviorRelay<[CODGroupChatModel]> = BehaviorRelay(value: [])
    
    override init() {
        super.init()
        self.dataSource = self.getDataSource()
        
    }
    
    func getDataSource() -> BehaviorRelay<[CODCanReadCellModel]> {
        var dataSource: [CODCanReadCellModel] = []
        let normalCellId = CODCanReadCell.description()
        
        let cell1 = CODCanReadCellModel(cellType: normalCellId, title: NSLocalizedString("公开", comment: ""), subTitle: NSLocalizedString("所有朋友可见", comment: ""), isSelected: true, readType: .public, selectAction: { [weak self] (cellVM)  in
            self?.clickCell(cellVM: cellVM)
            
        })
        let cell2 = CODCanReadCellModel(cellType: normalCellId, title: NSLocalizedString("私密", comment: ""), subTitle: NSLocalizedString("仅自己可见", comment: ""), isSelected: false, readType: .private, selectAction: { [weak self] (cellVM)  in
            self?.clickCell(cellVM: cellVM)
            
        })
        let cell3 = CODCanReadCellModel(cellType: normalCellId, title: NSLocalizedString("部分可见", comment: ""), subTitle: NSLocalizedString("选中的朋友可见", comment: ""), isSelected: false, readType: .partialCanRead, arrowType: CODCanReadCellModel.ArrowType.down, selectAction: { [weak self] (cellVM)  in
            self?.clickCell(cellVM: cellVM)
            
        })
        let cell4 = CODCanReadCellModel(cellType: normalCellId, title: NSLocalizedString("不给谁看", comment: ""), subTitle: NSLocalizedString("选中的朋友不可见", comment: ""), isSelected: false, readType: .partialNotRead, arrowType: CODCanReadCellModel.ArrowType.down, selectAction: { [weak self] (cellVM)  in
            self?.clickCell(cellVM: cellVM)
            
        })
        dataSource.append(contentsOf: [cell1, cell2, cell3, cell4])
        return BehaviorRelay(value: dataSource)
    }
    
    func clickCell(cellVM: CODCanReadCellModel) {
        if self.readType == cellVM.readType {
            self.setReadTypeOldValue(oldValue: cellVM.readType!)
        }else{
            
            self.selectedContactModels.accept([])
            self.selectedGroupModels.accept([])
            self.setReadTypeNewValue(newValue: cellVM.readType!)
        }
        self.readType = cellVM.readType!
    }
    
    func setReadTypeOldValue(oldValue: CODCanReadViewModel.CanReadType) {
        var dataSourceTemp = self.dataSource.value
        dataSourceTemp = dataSourceTemp.map { (cellModel) -> CODCanReadCellModel in
            if cellModel.readType == oldValue {
                if let _ = cellModel.arrowType {
                    cellModel.arrowType = self.dataSource.value.count > 4 ? .down : .up
                }
            }
            return cellModel
        }
        
        if dataSourceTemp.count > 4 {
            dataSourceTemp = self.hiddenSelectSource(dataSource: dataSourceTemp)
        }else{
            dataSourceTemp = self.showSelectSourceFor(type: oldValue, dataSource: dataSourceTemp)
        }
        self.dataSource.accept(dataSourceTemp)
    }
    
    func setReadTypeNewValue(newValue: CODCanReadViewModel.CanReadType) {
        var dataSourceTemp = self.dataSource.value
        if self.dataSource.value.count > 4 {
            dataSourceTemp = self.hiddenSelectSource(dataSource: dataSourceTemp)
        }
        dataSourceTemp = dataSourceTemp.map { (cellModel) -> CODCanReadCellModel in
            if cellModel.readType == newValue {
                cellModel.isSelected = true
                if let _ = cellModel.arrowType {
                    cellModel.arrowType = .up
                }
                
            }else{
                cellModel.isSelected = false
                if let _ = cellModel.arrowType {
                    cellModel.arrowType = .down
                }
            }
            return cellModel
        }
        dataSourceTemp = self.showSelectSourceFor(type: newValue, dataSource: dataSourceTemp)
        self.dataSource.accept(dataSourceTemp)
    }
    
    func setData() {
        var dataSourceTemp = self.dataSource.value
        dataSourceTemp = self.showSelectSourceFor(type: self.readType, dataSource: dataSourceTemp)
        self.dataSource.accept(dataSourceTemp)
    }
    
    func showSelectSourceFor(type: CanReadType, dataSource: [CODCanReadCellModel]) -> [CODCanReadCellModel] {
        let subCellId = CODCanReadSubCell.description()
        var dataSourceTemp = dataSource
        /*
        let subCell1 = CODCanReadCellModel(cellType: subCellId, title: NSLocalizedString("从群选择", comment: ""), subTitle: self.setGroupsCanReadSubTitle(), selectAction: { [weak self] (cellVM)  in
            guard let `self` = self else { return }
            if let vc = UIViewController.current() {
                let ctl = CODSelectGroupViewController()
                ctl.selectedArray = self.selectedGroupModels.value
                ctl.selectedGroupsSuccess = { [weak self] (groupList: [CODGroupChatModel]?) in
                    guard let `self` = self, let groupList = groupList else { return }
                    self.selectedGroupModels.accept(groupList)
                    
                    cellVM.subTitle = self.setGroupsCanReadSubTitle()
                }
                vc.navigationController?.pushViewController(ctl, animated: true)
            }
        })*/
        
        let subCell2 = CODCanReadCellModel(cellType: subCellId, title: NSLocalizedString("从联系人选择", comment: ""), subTitle: self.setContactsCanReadSubTitle(), selectAction: { [weak self] (cellVM) in
            if let vc = UIViewController.current() {
                let ctl = CreGroupChatViewController()
                ctl.ctlType = .friendsCcCanRead
                ctl.selectedArray = self?.selectedContactModels.value
                ctl.selectedRemindsSuccess = { [weak self] (contactList) in
                    guard let `self` = self else { return }
                    self.selectedContactModels.accept(contactList)
                    
                    cellVM.subTitle = self.setContactsCanReadSubTitle()
                }
                vc.navigationController?.pushViewController(ctl, animated: true)
            }
        })
        switch type {
        case .public, .private:
            return dataSourceTemp
        case .partialCanRead:
            dataSourceTemp.insert(contentsOf: [subCell2], at: 3)
            return dataSourceTemp
        case .partialNotRead:
            dataSourceTemp.insert(contentsOf: [subCell2], at: 4)
            return dataSourceTemp
        }
    }
    
    func hiddenSelectSource(dataSource: [CODCanReadCellModel]) -> [CODCanReadCellModel] {
        return dataSource.filter { (readCellModel) -> Bool in
            return readCellModel.cellType.contains(CODCanReadCell.description())
        }
    }
    
    func setGroupsCanReadSubTitle() -> String? {
        var subTemp:String? = nil
        if self.selectedGroupModels.value.count > 0 {
            subTemp = ""
            self.selectedGroupModels.value.forEach({ (groupModel) in
                subTemp?.append(contentsOf: "\(groupModel.getGroupName())、")
            })
            subTemp!.slice(from: 0, length: subTemp!.count-1)
        }
        return subTemp
    }
    
    func setContactsCanReadSubTitle() -> String? {
        var subTemp:String? = nil
        if self.selectedContactModels.value.count > 0 {
            subTemp = ""
            self.selectedContactModels.value.forEach({ (contactModel) in
                subTemp?.append(contentsOf: "\(contactModel.getContactNick())、")
            })
            subTemp!.slice(from: 0, length: subTemp!.count-1)
        }
        return subTemp
    }
}

protocol CanReadCellDataSourcesType {
    func configCellVM(pageVM: CODCanReadViewModel, cellVM: CODCanReadCellModel, indexPath: IndexPath)
}
