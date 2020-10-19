//
//  SimpleTableDataSourcesAdapter.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/6.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SimpleTableDataSourcesAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var dataSources: BehaviorRelay<[[CODCellModel]]> = BehaviorRelay(value: [])
    
    func bindDataSources(_ tableView: UITableView, _ dataSources: CODBehaviorRelay<[[CODCellModel]]>) {
        self.bindDataSources(tableView, dataSources.observed.asObservable())
    }
    
    func bindDataSources(_ tableView: UITableView, _ dataSources: BehaviorRelay<[[CODCellModel]]>) {
        self.bindDataSources(tableView, dataSources.asObservable())
    }
    
    func bindDataSources(_ tableView: UITableView, _ dataSources: Observable<[[CODCellModel]]>) {
        
        registerCellClassForTableView(tableView: tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        dataSources
            .bind(to: self.dataSources)
            .disposed(by: self.rx.disposeBag)
        
        self.dataSources.bind { [weak tableView] (_) in
            
            guard let tableView = tableView else { return }
            
            tableView.reloadData()
            
        }
        .disposed(by: self.rx.disposeBag)
        

    }
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODMessageDetailCell.self, forCellReuseIdentifier: "CODMessageDetailCellID")
        tableView.register(CODMessageDetailImageCell.self, forCellReuseIdentifier: "CODMessageDetailImageCellID")
        tableView.register(CODMessageDetailSwitchCell.self, forCellReuseIdentifier: "CODMessageDetailSwitchCellID")
        tableView.register(CODLongLongTextCell.self, forCellReuseIdentifier: "CODLongLongTextCellID")
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSources.value[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = self.dataSources.value[indexPath.section][indexPath.row]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailCellID", for: indexPath) as? CODMessageDetailCell
        if cell == nil{
            cell = CODMessageDetailCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailCellID")
        }
        if case .deleteType = model.type {
            cell?.isDelete = true
        }else{
            cell?.isDelete = false
        }
        if indexPath.row == 0 {
            cell?.isTop = true
        }else{
            cell?.isTop = false
        }
        
        cell?.placeholer = model.placeholderString
        cell?.imageStr = model.iconName
        cell?.isHiddenArrow = model.ishiddenArrow
        if indexPath.section == 0 {
            cell?.selectionStyle = .none
        }else{
            cell?.selectionStyle = .gray
        }
        
        
        model.$title
            .bind(to: cell!.titleLab.rx.text)
            .disposed(by: cell!.rx.prepareForReuseBag)

        model.$subTitle
            .bind(to: cell!.subTitleLab.rx.text)
            .disposed(by: cell!.rx.prepareForReuseBag)

        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = self.dataSources.value[indexPath.section][indexPath.row]
        
        model.action.didSelected?()
        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    
    
}
