//
//  CODGroupLinkViewController.swift
//  COD
//
//  Created by XinHoo on 2020/4/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

class CODGroupLinkViewController: BaseViewController, TableViewDataSourcesAdapterDelegate {
    
    var linkId: String = ""
    var groupModel = CODGroupChatModel()
    
    var dataSources: [Any] = []
    let disposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let tv = UITableView.init(frame: CGRect.zero, style: .grouped)
        tv.backgroundColor = UIColor.clear
        tv.estimatedRowHeight = 44.0
        return tv
    }()
    
    lazy var tableViewAdapter: TableViewDataSourcesAdapter = {
        return TableViewDataSourcesAdapter<CODGroupLinkSectionModel>(self)
    }()
    
    lazy var viewModel: CODGroupLinkViewModel = {
        return CODGroupLinkViewModel.init(linkId: self.linkId, groupModel:self.groupModel)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(cellWithClass: CODGroupLinkTextCell.self)
        self.tableView.register(cellWithClass: CODGroupLinkOtherCell.self)
        self.tableView.register(nib: UINib(nibName: "CODGroupLinkFooterView", bundle: nil), withHeaderFooterViewClass: CODGroupLinkFooterView.self)
        self.initUI()
        self.initData()
        self.bindData()
        
        //保存链接
        if self.groupModel.userid.count <= 0 {
            self.viewModel.saveGroupLink(userId: self.linkId)
        }
        
        // Do any additional setup after loading the view.
    }
    
    convenience init(linkId: String, groupModel: CODGroupChatModel) {
        self.init()
        self.linkId = linkId
        self.groupModel = groupModel
    }
    
    deinit {
        print("ok")
    }
    
    func initUI() {
        self.title = NSLocalizedString("群链接", comment: "")
        self.setBackButton()
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func initData() {
        self.tableViewAdapter.pageVM = self.viewModel
        
    }
    
    func bindData() {

        self.viewModel.dataSource
            .bind(to: self.tableViewAdapter.dataSources)
            .disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] (indexPath) -> Void in
            guard let `self` = self else { return }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }.disposed(by: disposeBag)
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
