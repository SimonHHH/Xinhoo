//
//  CODNewMessageListVC.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverNewMessageListVC: BaseViewController, ASTableDataSourcesAdapterDelegate {
    
    enum PageType {
        case all
        case new
    }
    
    let newMessageListPageVM: CODDiscoverNewMessageListPageVM
    
    var pageVM: Any? {
        return self.newMessageListPageVM
    }
    
    let tableNode = ASTableNode()
    
    let pageType: PageType
    
    var adapter: ASTableDataSourcesAdapter<DiscoverHomeSectionVM>!
    
    var clearItem: UIBarButtonItem?
    
    init(pageType: PageType = .new) {
        self.pageType = pageType
        self.newMessageListPageVM = CODDiscoverNewMessageListPageVM(pageType: pageType)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.pageType = .new
        self.newMessageListPageVM = CODDiscoverNewMessageListPageVM(pageType: .new)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("朋友圈", comment: "")
        
        if pageType == .all {
            self.clearItem = UIBarButtonItem(title: NSLocalizedString("清空", comment: ""), style: .plain, target: self, action: #selector(onClickClear))
            self.navigationItem.rightBarButtonItem = self.clearItem
        }
        
        adapter = ASTableDataSourcesAdapter<DiscoverHomeSectionVM>(self)
        
        tableNode.frame = CGRect(origin: .zero, size: CGSize(width: view.width, height: view.height - (view.cod_safeAreaInsets.top + 44 + UIApplication.shared.statusBarFrame.height)))
        
        tableNode.view.tableHeaderView = UIView()
        tableNode.view.tableFooterView = UIView()
        tableNode.view.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        tableNode.view.separatorColor = UIColor(hexString: "#E5E5E5")
        tableNode.view.separatorStyle = .none
        
        view.addSubnode(tableNode)
        
        self.newMessageListPageVM
            .dataSourceSignle.bind(to: self.adapter.dataSources)
            .disposed(by: self.rx.disposeBag)
        
        self.newMessageListPageVM.installFooter
            .bind(to: self.rx.installFooterBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.newMessageListPageVM.endFooterLoadData
            .bind(to: self.rx.endFooterLoadDataBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.newMessageListPageVM.notUnreadPR
            .bind(to: self.rx.notUnreadBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.newMessageListPageVM.fetchDataErrorPR
            .bind(to: self.rx.fetchDataErrorBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.newMessageListPageVM.fetchData()
        
        self.newMessageListPageVM
            .dataSourceSignle.bind(to: self.rx.clearButtonEnableBinder)
            .disposed(by: self.rx.disposeBag)

        
    }
    
    @objc func onClickClear() {
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: NSLocalizedString("清空所有消息", comment: ""), style: .destructive) { (action) in
            self.newMessageListPageVM.clear()
        }
        alert.addAction(action)

        alert.addAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, isEnabled: true, handler: nil)
        
        UIViewController.current()?.navigationController?.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DiscoverHttpTools.getAndUpdateNewMoments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserManager.sharedInstance.spreadMessageCount = 0
    }
    
}
