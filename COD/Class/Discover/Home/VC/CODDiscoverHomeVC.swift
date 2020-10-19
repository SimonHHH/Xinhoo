//
//  CODDiscoverHomeVC.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/11.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import MJRefresh
import IQKeyboardManagerSwift
import RxSwift
import RxRealm
import RxCocoa
import EmptyDataSet_Swift
import RealmSwift

class CODDiscoverHomeVC: BaseViewController, ASTableDataSourcesAdapterDelegate, EmptyDataSetSource, DiscoverScrollChangedNavigationBarPageType  {
    
    var navigationBar: DiscoverScrollChangedNavigationBarType {
        return self.discoverNavigationBar
    }
    
    var tableHeaderView: UIView {
        return self.headerView
    }
    

    let discoverHomePageVM = CODDiscoverHomePageVM()
    
    var pageVM: Any? {
        return self.discoverHomePageVM
    }
    
    let discoverNavigationBar = DiscoverNavigationBar()
    
    let tableNode = ASTableNode(style: .grouped)
    
    var adapter: CODDiscoverHomeDataSourcesAdapter!
    
    var headerView: DiscoverHeaderView!
    
    var currentPointY: CGFloat = 0.0
    var keyboardHeight: CGFloat = 0.0
    
    var bottomView = UIView()
    
    lazy var replyView: ReplyView = {
        
        let replyView = Bundle.main.loadNibNamed("ReplyView", owner: self, options: nil)?.last as! ReplyView
        replyView.isHidden = true
        return replyView
        
    }()
    
    override var inputAccessoryView: UIView? {
        get{
            return replyView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DiscoverHttpTools.getMomentBackground()
        
        self.fd_prefersNavigationBarHidden = true
        
        adapter = CODDiscoverHomeDataSourcesAdapter(self)
        
        tableNode.backgroundColor = .white
        tableNode.frame = view.bounds
        tableNode.view.separatorStyle = .none
        tableNode.view.pageSize = 10

        headerView = DiscoverHeaderView(pageVM: self.discoverHomePageVM)
        configHeaderView()
        
        discoverHomePageVM.footLoadPR
            .bind(to: self.rx.bindFooterRefresh)
            .disposed(by: self.rx.disposeBag)
        
        discoverHomePageVM.hearLoadPR
            .bind(to: self.rx.bindHeaderRefresh)
            .disposed(by: self.rx.disposeBag)
        
        discoverHomePageVM.showErrorPR
            .bind(to: self.rx.showErrorInfoBinder)
            .disposed(by: self.rx.disposeBag)
        
        discoverHomePageVM.installEmptyPR
            .bind(to: self.rx.installEmptyBinder)
            .disposed(by: self.rx.disposeBag)
        
        
        let refreshHeader = MJRefreshHeader { [weak self] in
            
            guard let `self` = self else { return }
            
            self.tableNode.view.pageNum = 1
            self.tableNode.view.pageSize = 10
            
            self.discoverHomePageVM.fetchData(pageNum: self.tableNode.view.pageNum, size: self.tableNode.view.pageSize)
            self.discoverHomePageVM.getInfo()
            
            self.headerView.showLoading()
            
        }
        

        tableNode.view.mj_header = refreshHeader
        
        view.addSubnode(tableNode)
        view.addSubview(discoverNavigationBar)
        
        /// 解决非手势冲突问题
        /// COD-11932 朋友圈【iOS】在朋友圈页面从屏幕底部上滑出手机菜单，朋友圈界面也被拖动了
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (maker) in
            maker.right.bottom.left.equalTo(self.view)
            maker.height.equalTo(20)
        }
        
        bottomView.isUserInteractionEnabled = true
        let swipe = UISwipeGestureRecognizer()
        bottomView.addGestureRecognizer(swipe)
        
        self.discoverHomePageVM.installFooterPR
            .bind(to: self.rx.installFooterBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.discoverHomePageVM
            .dataSource.bind(to: self.adapter.dataSources)
            .disposed(by: self.rx.disposeBag)
        
        self.discoverHomePageVM.commentPR
            .bind(to: self.rx.actionKeyboradBinder)
            .disposed(by: self.rx.disposeBag)
        
        
        self.discoverHomePageVM.scrollOffsetPR
            .bind(to: self.rx.scrollBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.discoverHomePageVM.reloadCellPR.filterNil()
            .bind(to: self.rx.reloadCellBinder)
            .disposed(by: self.rx.disposeBag)
        
        CODFileManager.shareInstanceManger().getEMConversationFilePath(sessionID: DiscoverHomeCache)

        self.discoverHomePageVM.fetchDataErrorPR
            .bind(to: self.rx.fetchDataErrorBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.discoverHomePageVM.lastDataNoAnymorePR
            .bind(to: self.rx.lastDataBinder)
            .disposed(by: self.rx.disposeBag)

        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        discoverHomePageVM.fetchData()
        
        NotificationAction.default.addTarget(target: self, body: COD_momentsbage) { [weak self] (jsonModel) in
            
            guard let `self` = self else { return }
            
            if jsonModel.settingJson["messageStatus"].intValue == 1 {
                self.discoverHomePageVM.getInfo()
            }

        }
        

        

    }
    
    @objc func keyBoardWillShow( notification:NSNotification){
        
        if let dic = notification.userInfo {
            if let bounds = dic["UIKeyboardBoundsUserInfoKey"] as? CGRect, keyboardHeight != bounds.height {
                keyboardHeight = bounds.height
                if bounds.height != 50 {
                    
                    let offset = (bounds.height + currentPointY) - KScreenHeight
                    
                    if offset > 0  {
                        currentPointY = currentPointY - (offset + 8)
                        self.tableNode.contentOffset.y += offset + 8
                    }
                }
            }
        }
        
    }
    
    
    @objc func keyBoardWillHide( notification:NSNotification){
        
        currentPointY = 0.0
        keyboardHeight = 0.0
    }
    
    func configHeaderView() {
        
        headerView.mj_size = headerView.sizeThatFits(CGSize(width: kScreenWidth, height: kScreenHeight))
        tableNode.view.tableHeaderView = headerView
        tableNode.view.tableFooterView = UIView()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableNode.contentInset = UIEdgeInsets(top: -(self.view.cod_safeAreaInsets.top + 30), left: 0, bottom: 10, right: 0)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.discoverHomePageVM.getInfo()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
            self.discoverHomePageVM.checkSendFailMessage()
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    

    deinit {
        NotificationAction.default.removeTarget()
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        
        let title = NSMutableAttributedString(string: NSLocalizedString("朋友圈暂无内容", comment: ""))
        
        title.yy_font = UIFont.systemFont(ofSize: 18)
        title.yy_color = UIColor(hexString: "#8E8E8E")
        
        return title
        
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        let title = NSMutableAttributedString(string: NSLocalizedString("可以点击右上角“相机”图标发布内容", comment: ""))
        
        title.yy_font = UIFont.systemFont(ofSize: 14)
        title.yy_color = UIColor(hexString: "#8E8E8E")
        
        return title
        
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 15
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 100
    }

}
