//
//  CODCanReadListViewController.swift
//  COD
//
//  Created by XinHoo on 6/8/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CODCanReadListViewController: BaseViewController, TableViewDataSourcesAdapterDelegate {
    
    var dataSources = [Any]()
    
    var pageVM: Any? {
        get {
            return self.viewModel
        }
    }
    
    let viewModel = CODCanReadListViewModel()
            
    let disposeBag = DisposeBag()
        
    lazy var tableViewAdapter: TableViewDataSourcesAdapter = {
        return TableViewDataSourcesAdapter<CODCanReadListSectionVM>(self)
    }()
    
    init(readType: CODCanReadListViewModel.CanReadType, jids: Array<String>) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.readType.accept(readType)
        self.viewModel.chatType.accept(.private)
        self.viewModel.fetchJidsDataSource(jids: jids)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.bindData()
        
        // Do any additional setup after loading the view.
    }
    
    lazy var tableView: UITableView = {
        let tv = UITableView.init(frame: CGRect.zero, style: .plain)
        tv.backgroundColor = UIColor.white
        tv.separatorStyle = .none
        tv.estimatedRowHeight = 47.0
        return tv
    }()

    func initUI() {
        tableView.register(UINib(nibName: "CODCanReadListTVCell", bundle: Bundle.main), forCellReuseIdentifier: "CODCanReadListTVCell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.setBackButton()
    }
    
    func bindData() {
        
        self.tableViewAdapter.pageVM = self.viewModel
                
        self.viewModel.readType.bind(to: self.rx.setTitle)
            .disposed(by: disposeBag)
        
        self.viewModel.dataSources.bind(to: self.tableViewAdapter.dataSources)
            .disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind(onNext: { [weak self] (indexPath) in
            self?.tableView.deselectRow(at: indexPath, animated: true)
        }).disposed(by: disposeBag)
    }

}
