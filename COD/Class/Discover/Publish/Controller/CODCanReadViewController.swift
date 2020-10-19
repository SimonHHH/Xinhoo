//
//  CODCanReadViewController.swift
//  COD
//
//  Created by XinHoo on 5/22/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CODCanReadViewController: BaseViewController {
    
    let viewModel = CODCanReadViewModel()
    
    let disposeBag = DisposeBag()
    
    var type: CODCanReadViewModel.CanReadType = .public
    var canReadGroups: [String]?
    var canReadContacts: [String]?
    
    
    typealias CanReadSelectComplete = (_ canReadType: CODCanReadViewModel.CanReadType,
                                        _ canReadGroups: [String]?,
                                        _ canReadContacts: [String]?) -> Void
    
    var canReadSelectComplete: CanReadSelectComplete?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.setData()
        
        // Do any additional setup after loading the view.
    }
    
    func initUI() {
        self.title = NSLocalizedString("谁可以看", comment: "")
        
        self.setCancelButton()
        self.setRightTextButton()
        self.rightTextButton.setTitle(NSLocalizedString("完成", comment: ""), for: .normal)
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.viewModel.dataSource.bind { [weak self] (_) in
            self?.tableView.reloadData()
        }.disposed(by: self.disposeBag)
        
    }
    
    func setData() {
        if let groups = self.canReadGroups {
            let groupsTemp = groups.map { (jid) -> CODGroupChatModel? in
                return CODGroupChatRealmTool.getGroupChatByJID(by: jid)
            }.compactMap{ $0 }
            self.viewModel.selectedGroupModels.accept(groupsTemp)
        }
        if let contacts = self.canReadContacts {
            let contactsTemp = contacts.map { (jid) -> CODContactModel? in
                return CODContactRealmTool.getContactByJID(by: jid)
            }.compactMap{ $0 }
            self.viewModel.selectedContactModels.accept(contactsTemp)
        }
        self.viewModel.readType = type
        self.viewModel.setReadTypeNewValue(newValue: type)
        
    }
    
    override func navCancelClick() {
        self.navBackClick()
    }
    
    override func navRightTextClick() {
        if self.canReadSelectComplete != nil {
            var groupJids: [String]?
            var contactJids: [String]?
            if self.viewModel.readType == .partialCanRead || self.viewModel.readType == .partialNotRead {
                if self.viewModel.selectedGroupModels.value.count > 0 {
                    groupJids = self.viewModel.selectedGroupModels.value.map({ (groupModel) -> String in
                        return groupModel.jid
                    })
                }
                if self.viewModel.selectedContactModels.value.count > 0 {
                    contactJids = self.viewModel.selectedContactModels.value.map({ (contactModel) -> String in
                        return contactModel.jid
                    })
                }
                
                if groupJids == nil && contactJids == nil {
                    
                    let alert = UIAlertController(title: nil, message: NSLocalizedString("请选择至少一个标签", comment: ""), preferredStyle: .alert)
                    alert.addAction(title: NSLocalizedString("知道了", comment: ""), style: .cancel, isEnabled: true, handler: nil)
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
            }
            
            self.navigationController?.popViewController(animated: true)
            canReadSelectComplete!(self.viewModel.readType, groupJids, contactJids)
        }
    }
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: .plain)
        tabelV.estimatedRowHeight = 64
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor.clear
        tabelV.delegate = self
        tabelV.dataSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    func registerCellClassForTableView(tableView: UITableView) {
        tableView.register(UINib(nibName: "CODCanReadCell", bundle: Bundle.main), forCellReuseIdentifier: "CODCanReadCell")
        tableView.register(UINib(nibName: "CODCanReadSubCell", bundle: Bundle.main), forCellReuseIdentifier: "CODCanReadSubCell")
    }

}

extension CODCanReadViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.dataSource.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = self.viewModel.dataSource.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withClass: stringClassFromString(cellModel.cellType) as! UITableViewCell.Type)
        if let cell = cell as? CanReadCellDataSourcesType {
            cell.configCellVM(pageVM: self.viewModel, cellVM: cellModel, indexPath: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let cellModel = self.viewModel.dataSource.value[indexPath.row]
        cellModel.selectAction!(cellModel)
    }
    
    
}


