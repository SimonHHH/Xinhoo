//
//  CODDiscoverDetailVC.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport
import IQKeyboardManagerSwift
import RxSwift
import RxRealm
import RxCocoa
import SVProgressHUD

class CODDiscoverDetailVC: BaseViewController, ASTableDataSourcesAdapterDelegate {
    
    enum PageType {
        case normal(momentsId: String)
        case fail(localMomentsId: String)
        
        var isFail: Bool {
            if case .fail = self {
                return true
            }
            
            return false
        }
        
        var momentsId: String {
            
            switch self {
            case .fail(localMomentsId: let momentsId):
                return momentsId
            case .normal(momentsId: let momentsId):
                return momentsId
            }
            
        }
        
    }
    
    typealias BackBlock = () -> Void
    var backBlock:BackBlock?
    
    let discoverDetailPageVM: CODDiscoverDetailPageVM
    let failType: CODDiscoverNotificationCellVM.Style.FailType?
    
    var pageVM: Any? {
        return self.discoverDetailPageVM
    }
    
    let tableNode = ASTableNode()
    
    var adapter: ASTableDataSourcesAdapter<DiscoverHomeSectionVM>!
    
    lazy var replyView: ReplyView = {
        
        let replyView = Bundle.main.loadNibNamed("ReplyView", owner: self, options: nil)?.last as! ReplyView
        replyView.config(momentsId: discoverDetailPageVM.momentsId, replyUser: "", responder: self, replyName: nil)
        return replyView
        
    }()
    
    
    
    init(pageType: PageType, failType: CODDiscoverNotificationCellVM.Style.FailType? = nil) {
        
        discoverDetailPageVM = CODDiscoverDetailPageVM(pageType: pageType)
        self.failType = failType
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        discoverDetailPageVM = CODDiscoverDetailPageVM(pageType: .normal(momentsId: ""))
        self.failType = nil
        super.init(coder: coder)
    }
    
    
    override var inputAccessoryView: UIView? {
        get{
            return replyView
        }
    }
    
    
    override var canBecomeFirstResponder: Bool {
        
        if self.discoverDetailPageVM.pageType.isFail {
            return false
        } else {
            
            if let model = CODDiscoverMessageModel.getModel(id: self.discoverDetailPageVM.pageType.momentsId) {
                
                if model.msgPrivacyTypeEnum == .Private {
                    return false
                }
                
                return model.allowReviewAndLike
            }
            
            return true
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("详情", comment: "")
        
        adapter = ASTableDataSourcesAdapter<DiscoverHomeSectionVM>(self)
        
        var tableNodeHeight = view.height - (view.cod_safeAreaInsets.top + 44 + UIApplication.shared.statusBarFrame.height)
        if self.canBecomeFirstResponder {
            tableNodeHeight -= self.replyView.height
        }
        
        tableNode.frame = CGRect(origin: .zero, size: CGSize(width: view.width, height: tableNodeHeight))
        
        if discoverDetailPageVM.pageType.isFail {
            let headerView = CODDiscoverSendFailView(frame: CGRect(origin: .zero, size: CGSize(width: kScreenWidth, height: 80)), pageType: discoverDetailPageVM.pageType, failType: self.failType)
            tableNode.view.tableHeaderView = headerView
        } else {
            tableNode.view.tableHeaderView = UIView()
        }
        
        if CODDiscoverMessageModel.getModel(id: self.discoverDetailPageVM.pageType.momentsId)?.msgPrivacyTypeEnum == .Private {
            tableNode.view.tableFooterView = CODDiscoverDetailPrivateFooterView(frame: CGRect(origin: .zero, size: CGSize(width: kScreenWidth, height: 70)))
            
        } else {
            tableNode.view.tableFooterView = UIView()
        }

        
        tableNode.view.separatorStyle = .none
        
        view.addSubnode(tableNode)
        
        self.discoverDetailPageVM
            .dataSource.bind(to: self.adapter.dataSources)
            .disposed(by: self.rx.disposeBag)
        
        self.discoverDetailPageVM.commentPR
            .bind(to: self.rx.actionKeyboradBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.discoverDetailPageVM.deleteMoments
            .bind(to: self.rx.deleteMomentsBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.discoverDetailPageVM.hiddenKeyboardPR
            .bind(to: self.rx.hiddenKeyboradBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.discoverDetailPageVM.fetchDataFormDB()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        if let model = CODDiscoverMessageModel.getModel(serverMsgId: self.discoverDetailPageVM.momentsId) {
            
            Observable.array(from: model.replyList)
                .distinctUntilChanged { (list1, list2) -> Bool in
                    return list1.count == list2.count
            }
            .skip(1)
            .bind { [weak self] (_) in
                guard let `self` = self else { return }
                //                self.discoverDetailPageVM.fetchDataFormServer()
                self.discoverDetailPageVM.fetchDataFormDB()
            }
            .disposed(by: self.rx.disposeBag)
            
            Observable.array(from: model.likerList)
                .distinctUntilChanged { (list1, list2) -> Bool in
                    return list1.count == list2.count
            }
            .skip(1)
            .bind { [weak self] (_) in
                guard let `self` = self else { return }
                //                self.discoverDetailPageVM.fetchDataFormServer()
                self.discoverDetailPageVM.fetchDataFormDB()
            }
            .disposed(by: self.rx.disposeBag)
            
            switch self.failType {
            case .like:
                CODDiscoverFailureAndSendingListModel.removeModelFromDeletedLikeFailList(model)
            case .comment:
                CODDiscoverFailureAndSendingListModel.removeModelFromDeletedCommentFailList(model)
            default:
                break
                
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enable = false
        SVProgressHUD.setContainerView(self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        if self.backBlock != nil {
            self.backBlock!()
        }
        SVProgressHUD.setContainerView(nil)
    }
    
    @objc func keyBoardDidHide(notification: Notification) {
        
        self.becomeFirstResponder()
        self.replyView.isHidden = false
        
    }
    
    
    
}
