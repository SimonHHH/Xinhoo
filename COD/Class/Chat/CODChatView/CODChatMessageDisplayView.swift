//
//  CODChatMessageDisplayView.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import SVProgressHUD
import SafariServices
import RxSwift
import RxCocoa
import LGAlertView
import RxDataSources
import RxSwiftExt
import MJRefresh
import SwiftyJSON
import NSObject_Rx
import SwifterSwift

private let CODShowNewMessageCell_identity = "CODShowNewMessageCell_identity"


private let kChatLoadMoreOffset: CGFloat = 30

extension CODChatMessageDisplayView: TableViewDataSourcesAdapterDelegate {
    
    
}

class CODChatMessageDisplayView: UIView {
    
    let saveToCanmeraRollSemaphore = DispatchSemaphore(value: 1)
    
    let offsetBeginTime = 10 * 60 * 1000
    
    var dataSources: [Any] = []
    
    var pageVM: Any? {
        return self.messageDisplayViewVM
    }
    
    
    enum CellDirection {
        case left
        case right
    }
    
    public var toJID: String = ""
    
    var messageModel : CODMessageModel? {
        return self.cellVM?.messageModel
    }
    var cellVM: ChatCellVM?
    //    var selectCell : CODBaseChatCell?
    var currentContentOffset : CGPoint?
    //是不是云盘
    public var isCloudDisk: Bool = false {
        didSet {
            self.messageDisplayViewVM.isCloudDisk = self.isCloudDisk
        }
    }
    
    var rpIndexPath:IndexPath?
    
    var currentMiny:CGFloat = 0.0
    var currentFileID = ""
    
    var isAutoScrollToBottom = false
    
    var isPushDetail = false
    
    var chatListModel: CODChatListModel? = nil
    
    let maxLoadCount = 100
    
    lazy var tabelViewAdapter: ChatViewDataSourcesAdapter = {
        return ChatViewDataSourcesAdapter<ChatSectionVM>(self)
    }()
    
    var isShowOperationView = "dismiss" {
        didSet {
            
            if self.isShowOperationView != oldValue {
                self.gotoBottomView.isHidden = (self.isShowOperationView == "dismiss")
                if self.gotoBottomView.isHidden {
                    self.gotoBottomView.setCount(count: 0)
                }
                
            }
        }
    }
    
    var atList = NSMutableArray()
    var flashingPath: IndexPath?
    
    typealias HiddenShareBtnBlock = (_ isHidden: Bool) -> Void
    var hiddenShareBtnBlock: HiddenShareBtnBlock?
    var selectedCallTypeMsgCount = 0 {
        didSet {
            if self.hiddenShareBtnBlock != nil {
                if self.selectedCallTypeMsgCount > 0 {
                    self.hiddenShareBtnBlock!(true)
                }else{
                    self.hiddenShareBtnBlock!(false)
                }
            }
            
        }
    }
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style:UIActivityIndicatorView.Style.gray)
        activityIndicator.center = self.refreshView.center
        return activityIndicator
    }()
    
    lazy var refreshView : UIView = {
        let lb = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 25))
        lb.backgroundColor = UIColor.clear
        return lb
    }()
    
    lazy var messageDisplayViewVM: CODChatMessageDisplayPageVM = {
        return CODChatMessageDisplayPageVM(chatId: self.chatId, chatType: self.chatType)
    }()
    
    lazy var gotoBottomView : CODGotoBottomView = {
        
        let view = Bundle.main.loadNibNamed("CODGotoBottomView", owner: self, options: nil)?.last as! CODGotoBottomView
        view.setBtnImage(image: UIImage.init(named: "icon_gotoBottom_icon")!)
        view.setCount(count: 0)
        view.click = {[weak self] in
            self?.scrollToLastMessage(animated: true)
            DispatchQueue.main.async {
                self?.showTimeView.hide()
            }
        }
        view.isHidden = true
        return view
    }()
    
    var newMessageCount = 0 {
        didSet {
            self.gotoNewView.setCount(count: self.newMessageCount)
            self.gotoNewView.isHidden = (self.newMessageCount == 0)
        }
    }
    
    lazy var gotoNewView : CODGotoBottomView = {
        
        let view = Bundle.main.loadNibNamed("CODGotoBottomView", owner: self, options: nil)?.last as! CODGotoBottomView
        view.setBtnImage(image: UIImage.init(named: "backgrond_showCounts")!)
        view.setCount(count: 0)
        view.click = {[weak self] in
            
            guard let `self` = self, let count = self.chatListModel?.count else { return }
            
            DispatchQueue.main.async {
                
                if self.newMessageCount <= 20 && (self.messageDisplayViewVM.dataSources.last?.items.count ?? 0 > self.newMessageCount) {
                    self.scrollToMessage(index: self.messageDisplayViewVM.originalNewMessageCount - 1)
                    self.messageDisplayViewVM.updateNewMessageCount()
                    return
                }
                
                
                if self.newMessageCount > self.maxLoadCount {
                    
                    CODProgressHUD.showWithStatus(nil)
                    self.messageDisplayViewVM.getHistoryList(lastMessageId: self.messageDisplayViewVM.lastMessageID, count: self.maxLoadCount) { [weak self] (VMs) in
                        
                        CODProgressHUD.dismiss()
                        
                        guard let `self` = self else { return }
                        
                        self.messageDisplayViewVM.appendChatCellVMs(cellVms: VMs)
                        self.scrollToTopMessage()
                        
                        
                    }
                    
                } else {
                    
                    CODProgressHUD.showWithStatus(nil)
                    self.messageDisplayViewVM.getHistoryList(lastMessageId: self.messageDisplayViewVM.lastMessageID, count: self.newMessageCount + 20) { [weak self] (VMs) in
                        
                        CODProgressHUD.dismiss()
                        
                        guard let `self` = self else { return }
                        
                        self.messageDisplayViewVM.appendChatCellVMs(cellVms: VMs)
                        
                        let count = self.tableView.lastIndexPath?.row ?? 0
                        
                        self.scrollToMessage(index: self.messageDisplayViewVM.originalNewMessageCount - 1, animated: true)
                        
                        
                        
                    }
                    
                }
                
                
            }
        }
        
        view.isHidden = true
        return view
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        Xinhoo_FileViewModel.downloadProgressDic.removeAll()
    }
    
    func flashingCell(indexPath: IndexPath) {
        
        if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
            
            if let cell = tableView.cellForRow(at: indexPath) as? CODBaseChatCell {
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                cell.flashingCell()
            }
            
        } else {
            
            self.flashingPath = indexPath
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            
        }
        
    }
    
    lazy var gotoAtView : CODGotoBottomView = {
        
        let view = Bundle.main.loadNibNamed("CODGotoBottomView", owner: self, options: nil)?.last as! CODGotoBottomView
        view.setBtnImage(image: UIImage.init(named: "icon_gotoAt_icon")!)
        view.setCount(count: 0)
        view.click = {[weak self] in
            
            guard let `self` = self else { return }
            
            let messageInfo = self.messageDisplayViewVM.referToMessageID.removeLast()
            
            self.messageDisplayViewVM.referToMessageIDRemove.accept(messageInfo)
            
            let index = self.tableView.visibleCells.firstIndex { (cell) -> Bool in
                
                if let cell = cell as? CODBaseChatCell {
                    return cell.messageModel.msgID == messageInfo.msgId
                }
                
                return false
            }
            
            if let indexValue = index {
                
                if let baseChatCell = self.tableView.visibleCells[indexValue] as? CODBaseChatCell {
                    baseChatCell.flashingCell()
                }
                
            } else {
                
                if let indexPath = self.messageDisplayViewVM.findIndexPath(messageId: messageInfo.msgId) {
                    self.flashingPath = indexPath
                    self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                } else {
                    
                    if let beginTime = messageInfo.sendTime.int, let endTime = self.messageDisplayViewVM.dataSources.first?.items.last?.model.datetimeInt {
                        
                        CODProgressHUD.showWithStatus(nil)
                        self.messageDisplayViewVM.getHistoryList(beginTime: "\(beginTime - self.offsetBeginTime)", endTime:"\(endTime - 1)") { (cellVms) in
                            self.messageDisplayViewVM.appendChatCellVMs(cellVms: cellVms)
                            CODProgressHUD.dismiss()
                            
                            if let indexPath = self.messageDisplayViewVM.findIndexPath(messageId: messageInfo.msgId) {
                                self.flashingPath = indexPath
                                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }
        view.isHidden = true
        return view
    }()
    
    
    var showName : Bool = false {
        didSet{
            //          self.tableView.reloadData()
            if currentContentOffset != nil {
                self.currentContentOffset = self.tableView.contentOffset
                self.tableView.reloadData {
                    self.tableView.contentOffset = self.currentContentOffset ?? CGPoint(x: 0, y: 0)
                }
            }
        }
    }
    
    public var chatId: Int = 0
    public var chatType: CODMessageChatType = .privateChat
    var messageList :NSMutableArray = NSMutableArray(){
        didSet{
            
        }
    }
    
    var updateMeassage = CODMessageModel() {
        
        didSet{
            //            dispatch_async_safely_to_main_queue{
            let predicate = NSPredicate.init(format: "msgID == %@", self.updateMeassage.msgID)
            let resultArray = self.messageList.filtered(using: predicate)
            if resultArray.count > 0,let messageModel = resultArray[0] as? CODMessageModel {
                let modelIndex = self.messageList.index(of: messageModel)
                if modelIndex < self.messageList.count{
                    if let  newMessageModel = CODMessageRealmTool.getMessageByMsgId(self.updateMeassage.msgID) {
                        //                            let referToArr = List<String>()
                        //                            for referToString in newMessageModel.referTo {
                        //                                referToArr.append(referToString)
                        //                            }
                        
                        //如果数据源中的model 是被选中状态，则要同步修改数据库中的model的选中状态，然后再做替换
                        //                        newMessageModel.isSelect = messageModel.isSelect
                        
                        if newMessageModel.isInvalidated {
                            return
                        }
                        
                        UIView.setAnimationsEnabled(false)
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        self.tableView.beginUpdates()
                        self.messageList.replaceObject(at: modelIndex, with: newMessageModel)
                        self.tableView.reloadRows(at: [IndexPath.init(item: modelIndex, section: 0)], with: .none)
                        self.tableView.endUpdates()
                        CATransaction.commit()
                        UIView.setAnimationsEnabled(true)
                        
                    }
                }
            }
            //            }
        }
    }
    
    var updateMeassageUploadProgress = CODMessageModel() {
        didSet {
            for cell in tableView.visibleCells {
                if cell.isKind(of: Xinhoo_ImageRightTableViewCell.classForCoder()) {
                    let tempCell = (cell as! Xinhoo_ImageRightTableViewCell)
                    if tempCell.messageModel.msgID == self.updateMeassageUploadProgress.msgID {
                        
                        //NSLog("**************** msgID:%@, progress:%.2f *****************", tempCell.messageModel.msgID, updateMeassageUploadProgress.uploadProgress)
                        
                        tempCell.videoImageView.showVideoLoadingView(progress: updateMeassageUploadProgress.uploadProgress)
                        tempCell.activityView.isHidden = false
                        tempCell.activityView.startAnimating()
                        tempCell.sendFailBtn_zzs.isHidden = true
                        break
                    }
                }
            }
        }
    }
    
    private var isScrollToBottom: Bool = true
    
    lazy var headerView:CODMessageHeaderView = {
        let headerV = CODMessageHeaderView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 40))
        headerV.backgroundColor = UIColor.clear
        headerV.isHidden = true
        //        headerV.transform = CGAffineTransform(scaleX: 1, y: -1)
        return headerV
    }()
    
    weak var delegate:CODChatMessageDisplayViewDelegate?
    
    lazy var tableView:UITableView = {
        let tabelView = CODMessageTabelView(frame: CGRect.zero, style: UITableView.Style.plain)
        tabelView.rowHeight = UITableView.automaticDimension
        //        tabelView.estimatedRowHeight = 200
        tabelView.separatorStyle = .none
        tabelView.backgroundColor = UIColor.clear
        let footerView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        headerView.transform = CGAffineTransform(scaleX: 1, y: -1)
//        tabelView.tableFooterView = headerView
        //        tabelView.tableHeaderView = self.refreshView
        tabelView.estimatedSectionHeaderHeight = 0;
        //        tabelView.delegate = self
        //        tabelView.dataSource = self
        //        tabelView.scrollsToTop = false
        tabelView.isEditing = false
        tabelView.allowsMultipleSelectionDuringEditing = true
        //        tabelView.addSubview(refreshAction)
        ///添加添加事件
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(didTouchTableView))
        //        tabelView.addGestureRecognizer(tap)
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelView)
        tabelView.backgroundColor = UIColor.clear
        tabelView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        
        
        let getHistoryListHandle: (([ChatCellVM]) -> Void) = { [weak self] (cellVMs) in
            guard let `self` = self else { return }
            
            if self.tableView.mj_footer != nil {
                self.tableView.mj_footer.endRefreshing()
            }
            
            
            var cellVMs = cellVMs
            
            
            if cellVMs.count == 0 {
                
//                self.tableView.beginUpdates()
//                self.headerView.isHidden = false
//                self.tableView.tableFooterView = self.headerView
//                self.tableView.endUpdates()
                if self.tableView.contentSize.height < self.tableView.height {
                    self.headerView.height = self.tableView.height - self.tableView.contentSize.height
                }
                
                if self.tableView.mj_footer != nil {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                
                self.tableView.mj_footer = nil
            } else {
                let indexs: [IndexPath]? = self.tableView.indexPathsForSelectedRows
                self.messageDisplayViewVM.appendChatCellVMs(cellVms: cellVMs)
                
                if indexs != nil {
                    
                    for index in indexs! {
                        self.tableView.selectRow(at: index, animated: false, scrollPosition: .none)
                    }
                }
                
            }
            
        }
        
        
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            
            guard let `self` = self, let chatListModel = self.chatListModel else { return }
            
            self.showTimeView.hide()
            
            if let remoteLastMessageID = self.messageDisplayViewVM.remoteLastMessageID {
                self.messageDisplayViewVM.getHistoryList(lastMessageId: remoteLastMessageID, count: 50, complete: getHistoryListHandle)
            } else {
                self.tableView.mj_footer.endRefreshing()
            }
            
            
            
        })
        
        footer?.transform = CGAffineTransform(scaleX: 1, y: -1)
        footer?.setTitle("", for: .idle)
        footer?.setTitle("", for: .pulling)
        footer?.setTitle("", for: .willRefresh)
        footer?.setTitle("", for: .refreshing)
        footer?.setTitle("", for: .noMoreData)
        footer?.labelLeftInset = -5
        footer?.activityIndicatorViewStyle = .white
        
        footer?.triggerAutomaticallyRefreshPercent = 0.01
        
        
        
        tabelView.mj_footer = footer
        
        
        
        return tabelView
    }()
    
    lazy var showTimeView:Xinhoo_ShowDateTimeView = {
        let showTimeView = Xinhoo_ShowDateTimeView(frame: .zero)
        return showTimeView
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheMessage(notification:)), name: NSNotification.Name.init(rawValue: kUpdateTheMessageNoti), object: nil)
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.refreshView.addSubview(self.indicatorView)
        self.addSubview(self.tableView)
        //        self.tableView.delegate = self
        //        self.tableView.dataSource = self
        self.tableView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        self.insertSubview(self.showTimeView, aboveSubview: self.tableView)
        self.showTimeView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalTo(KScreenWidth)
            make.height.equalTo(40)
        }
        
        self.addSubview(self.gotoBottomView)
        gotoBottomView.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
            make.size.equalTo(CGSize.init(width: 44, height: 55))
        }
        
        self.addSubview(self.gotoAtView)
        gotoAtView.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.bottom.equalTo(self.gotoBottomView.snp.top).offset(0)
            make.size.equalTo(CGSize.init(width: 44, height: 55))
        }
        
        self.addSubview(gotoNewView)
        
        gotoNewView.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(CGSize.init(width: 44, height: 55))
        }
        
        if (UIViewController.current()?.navigationController?.interactivePopGestureRecognizer) != nil {
            
            self.tableView.panGestureRecognizer.require(toFail: (UIViewController.current()?.navigationController?.interactivePopGestureRecognizer)!)
        }
        
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayViewAudioPlayEnd), name: NSNotification.Name.init("kDisplayViewAudioPlayEnd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarNotification), name: NSNotification.Name.init("statusBarNotification"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name.init(kAudioCallBegin), object: nil)
    }
    
    var chatModel: CODChatObjectType {
        switch self.chatType {
        case .channel:
            return self.chatListModel!.channelChat!
        case .groupChat:
            return self.chatListModel!.groupChat!
        case .privateChat:
            return self.chatListModel!.contact!
        }
    }
    
    func fetchData() {
        
        guard let chatListModel = CODChatListRealmTool.getChatList(id: self.chatId) else {
            return
        }
        
        self.chatListModel = chatListModel
        
        self.newMessageCount = chatListModel.count
        
    }
    
    func bindData() {
        
        self.messageDisplayViewVM.rpIndexPath
            .bind(to: self.rx.rpIndexPath)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.dataSouecesBR
            .bind(to: self.tabelViewAdapter.dataSources)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.newMessage
            .merge(with: self.messageDisplayViewVM.sendMessageBR.asObservable())
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: self.rx.newMessageScrollToBottom)
            .disposed(by: self.rx.disposeBag)
        
        
        self.messageDisplayViewVM.newMessage
            .filter { $0.type != .notification }
            .filter { !$0.isMeSend }
            .bind(to: self.rx.newMessageCounter)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.editMessageBR
            .bind(to: self.rx.editMessageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.resendMessageReloadCellBR
        .bind(to: self.rx.resendMessageReloadCellBinder)
        .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.cellDidTapedAvatarImageBR
            .bind(to: self.rx.cellDidTapedAvatarImageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.cellDidTapedFwdImageViewBR
            .bind(to: self.rx.cellDidTapedFwdImageViewBinder)
            .disposed(by: self.rx.disposeBag)
        
        
        self.messageDisplayViewVM.cellDidLongTapedAvatarImageBR
            .bind(to: self.rx.cellDidLongTapedAvatarImageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.cellDidTapedLinkBR
            .bind(to: self.rx.cellDidTapedLinkBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.cellDidTapedPhoneBR
            .bind(to: self.rx.cellDidTapedPhoneBinder)
            .disposed(by: self.rx.disposeBag)
        

        self.messageDisplayViewVM.cellCardActionBR
            .bind(to: self.rx.cellCardActionBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.cellTapMessageBR
            .bind(to: self.rx.cellTapMessageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.cellLongPressMessageBR
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .bind(to: self.rx.cellLongPressMessageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.cellTapViewerBR
            .bind(to: self.rx.cellTapViewerBinder)
            .disposed(by: self.rx.disposeBag)
        
        
        self.messageDisplayViewVM.cellTapAtAllBR
            .bind(to: self.rx.cellTapAtAllBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.referToMessageIDObservable
            .bind(to: self.rx.referToMessageIDBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.referToMessageIDRemove
            .bind(to: self.rx.referToMessageRemoveBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.referToMessageIDAdd
            .bind(to: self.rx.referToMessageAddBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.removeAllMessage
            .bind(to: self.rx.removeAllMessageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.updateNewMessageBR
            .bind(to: self.rx.updateNewMessageCountBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.playNextAudioPR
            .bind(to: self.rx.playNextAudioBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.reloadTableViewBR
            .bind(to: self.rx.reloadTableViewBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageDisplayViewVM.realoadEndBR.bind { [weak self] () in
            
            guard let `self` = self else { return }
            if self.tableView.mj_footer != nil {
                self.tableView.mj_footer.endRefreshing()
                self.tableView.mj_footer = nil
            }
            
            
            
        }
        .disposed(by: self.rx.disposeBag)
        

        
    }
    
    func scrollToLastMessage(animated: Bool = false) {
        self.tableView.safeScrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: animated)
    }
    
    func scrollToTopMessage(at scrollPosition: UITableView.ScrollPosition = .bottom, animated: Bool = false) {
        
        guard let lastIndexPath = self.tableView.lastIndexPath else {
            return
        }
        
        self.tableView.safeScrollToRow(at: lastIndexPath, at: scrollPosition, animated: animated)
    }
    
    func scrollToMessage(index: Int, at: UITableView.ScrollPosition = .middle, animated: Bool = false) {
        self.tableView.safeScrollToRow(at: IndexPath(row: index, section: 0), at: at, animated: animated)
    }
    
    @objc func displayViewAudioPlayEnd() {
        
        CODAudioPlayerManager.sharedInstance.playModel?.isPlay = false
    }
    
    @objc func reload() {
        self.tableView.reloadData()
    }
    
    //滚动到底部
    public func scrollToBottomWithAnimation(animation:Bool){
        self.scrollToLastMessage(animated: animation)
    }
    ///刷新
    public func reloadTableView(){
        self.tableView.reloadData()
        self.tableView.scrollBottomWithoutFlashing()
        
    }
    
    @objc func updateTheMessage(notification: Notification) {
        if let dic = notification.userInfo {
            if let id = dic["id"] as? String {
                let model = CODMessageModel()
                model.msgID = id
                self.updateMeassage = model
            }
        }
    }
    
    @objc fileprivate func didTouchTableView(){
        if self.delegate != nil {
            self.delegate?.chatMessageDisplayViewDidTouched(chatTVC: self)
        }
    }
    @objc fileprivate func loadMoreMessage(){
        if self.delegate != nil {
            self.delegate?.loadMoreMessage()
        }
    }
    
}

extension CODChatMessageDisplayView: MGSwipeTableCellDelegate{
    ///注册单元格
    func registerCellClassForTableView(tableView:UITableView) {
        
        
        tableView.register(nibWithCellClass: CODZZS_TextLeftTableViewCell.self)
        tableView.register(nibWithCellClass: CODZZS_TextRightTableViewCell.self)
        tableView.register(nibWithCellClass: CODZZS_AudioLeftTableViewCell.self)
        tableView.register(nibWithCellClass: CODZZS_AudioRightTableViewCell.self)
        tableView.register(nibWithCellClass: Xinhoo_ImageRightTableViewCell.self)
        tableView.register(nibWithCellClass: Xinhoo_ImageLeftTableViewCell.self)
        tableView.register(nibWithCellClass: Xinhoo_CardRightTableViewCell.self)
        tableView.register(nibWithCellClass: Xinhoo_CardLeftTableViewCell.self)
        tableView.register(nibWithCellClass: Xinhoo_LocationLeftTableViewCell.self)
        tableView.register(nibWithCellClass: Xinhoo_LocationRightTableViewCell.self)
        tableView.register(nibWithCellClass: Xinhoo_CallLeftTableViewCell.self)
        tableView.register(nibWithCellClass: Xinhoo_CallRightTableViewCell.self)
        tableView.register(cellWithClass: CODNoticeChatCell.self)
        tableView.register(cellWithClass: CODShowNewMessageCell.self)
        tableView.register(cellWithClass: CODChatTextureCell.self)
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.tableView.isEditing{
            let message = self.messageList[indexPath.row] as! CODMessageModel
            let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: message.msgType) ?? .text
            if modelType == .haveRead || modelType == .newMessage || modelType == .notification {
                return
            }
            if modelType == .voiceCall || modelType == .videoCall {
                self.selectedCallTypeMsgCount += 1
            }
            print(self.tableView.indexPathsForSelectedRows as Any)
            //            message.isSelect = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if self.tableView.isEditing {
            let message = self.messageList[indexPath.row] as! CODMessageModel
            let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: message.msgType) ?? .text
            if modelType == .haveRead || modelType == .newMessage || modelType == .notification {
                return
            }
            if modelType == .voiceCall || modelType == .videoCall {
                self.selectedCallTypeMsgCount -= 1
            }
            print(self.tableView.indexPathsForSelectedRows as Any)
            //            message.isSelect = false
        }
    }
    
    
    func configCellHeight(messagemodel:CODMessageModel, cell:UITableViewCell) {
        
        if messagemodel.cellHeight == "" {
            
            DispatchQueue.main.async {
                let cellHeight = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                CODMessageRealmTool.updateMessageCellHeight(messagemodel.msgID, cellHeight: String(format: "%.2f", cellHeight))
            }
        }
    }
    
    func playAudio(cellVM: ChatCellVM) {
        
        let model = cellVM.model
        
        if CODAudioPlayerManager.sharedInstance.playModel != nil {
            try! Realm.init().write {
                CODAudioPlayerManager.sharedInstance.playModel!.isPlay = false
            }
        }
        
        try! Realm.init().write {
            model.isPlay = true
            model.isPlayRead = true
        }
        
        CODAudioPlayerManager.sharedInstance.playModel = model
        
        var jid = ""
        var audioID = ""
        audioID = (model.audioModel!.audioURL)
        
        if model.isGroupChat {
            
            jid = model.toWho
            if (model.fromJID.contains(UserManager.sharedInstance.loginName!)) || model.fromJID == "" {
                if (model.audioModel?.audioLocalURL.count)! > 0{
                    audioID = ((model.audioModel?.audioLocalURL.components(separatedBy: "/").last)?.components(separatedBy: ".").first)!
                }
            }
            
        }else{
            if (model.fromJID.contains(UserManager.sharedInstance.loginName!)) || model.fromJID == "" {
                jid = model.toWho
                if (model.audioModel?.audioLocalURL.count)! > 0{
                    audioID = ((model.audioModel?.audioLocalURL.components(separatedBy: "/").last)?.components(separatedBy: ".").first)!
                }
                
            }else{
                jid = model.fromJID
            }
        }
        
        CODAudioPlayerManager.sharedInstance.playAudio(jid: jid, audioID: audioID) { [weak self] in
            guard let `self` = self else { return }
            self.messageDisplayViewVM.playNextAudio(cellVm: cellVM)
        }
        
    }
    
    //    @available(iOS 11.0, *)
    /// 苹果iOS11，滑动删除新特性
    ///
    /// - Parameters:
    ///   - tableView: tableview
    ///   - indexPath: indexpath
    /// - Returns: 删除按钮配置
    //    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //
    //        let message = self.messageList[indexPath.row] as! CODMessageModel
    //        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: message.msgType) ?? .text
    //        if modelType == .haveRead || modelType == .inviteGroup || modelType == .newMessage || modelType == .notification {
    //            return nil
    //        }
    //
    //        let replyAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
    //
    //            self.messageModel = message
    //            self.replyMessage()
    //            completionHandler(true)
    //        }
    //        replyAction.image = UIImage.init(named: "reply_icon")
    //        replyAction.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0)
    //
    //        let action = UISwipeActionsConfiguration(actions: [replyAction])
    //        return action
    //    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        guard let message = self.messageList[indexPath.row] as? CODMessageModel else {
            return false
        }
        
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: message.msgType) ?? .text
        if modelType == .haveRead || modelType == .newMessage || modelType == .notification {
            return false
        }else{
            return true
        }
    }
    
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01));
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    //    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    //        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
    //        return footerView
    //    }
    //    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //        return 0.01
    //    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        //        NSLog("%@执行了多少次？----%ld",#function,indexPath.row)
        let model :CODMessageModel = messageList[indexPath.row] as! CODMessageModel
        if model.isInvalidated {
            return UITableView.automaticDimension
        }
        if model.cellHeight == "" {
            return UITableView.automaticDimension
        }else{
            return model.cellHeight.cgFloat()!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        NSLog("%@执行了多少次？",#function)
        let baseCell = cell as? CODZZS_BaseTableViewCell
        if baseCell != nil {
            if self.atList.count > 0 {
                
                let targetIndexPath = self.atList.firstObject as! IndexPath
                if targetIndexPath.row == indexPath.row{
                    baseCell!.flashingCell()
                    self.atList.removeObject(at: 0)
                    self.gotoAtView.setCount(count:self.atList.count)
                    if self.atList.count == 0{
                        self.gotoAtView.isHidden = true
                    }
                }
            }
            
            if self.rpIndexPath?.row == indexPath.row {
                self.rpIndexPath = nil
                baseCell!.flashingCell()
            }
        }
        
        //        baseCell?.isSelected = true
        let message = self.messageList[indexPath.row] as! CODMessageModel
        
        //        baseCell?.isSelected = message.isSelect
        //        if message.isSelect {
        //            let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: message.msgType) ?? .text
        //            if modelType == .voiceCall || modelType == .videoCall {
        //                self.selectedCallTypeMsgCount += 1
        //            }
        //            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        //        }else{
        //            tableView.deselectRow(at: indexPath, animated: true)
        //        }
        
        
        print(self.tableView.indexPathsForSelectedRows as Any)
        
        let model: CODMessageModel? = CODUploadTool.default.uploadingModel
        if model != nil && model?.uploadState != CODMessageFileUploadState.UploadFailed.rawValue && model?.uploadState != CODMessageFileUploadState.UploadSucceed.rawValue {
            let predicate = NSPredicate.init(format: "msgID == %@", model!.msgID)
            let resultArray = self.messageList.filtered(using: predicate)
            if resultArray.count > 0, let tmpModel:CODMessageModel? = resultArray.last as! CODMessageModel  {
                tmpModel?.uploadProgress = model!.uploadProgress
            }
            
        }
    }
}



extension CODChatMessageDisplayView {
    
    
    func openURL(url:String) {
        var strUrl : NSString = url as NSString
        if strUrl.lowercased.hasPrefix("http://") == false && strUrl.lowercased.hasPrefix("https://") == false{
            strUrl = NSString.init(string: "http://").appending(strUrl as String) as NSString
        }
        let safariVC = SFSafariViewController.init(url: URL.init(string: strUrl as String)!)
        UIViewController.current()!.present(safariVC, animated: true, completion: nil)
    }
    
    func cellTapAtAll(message: CODMessageModel?, cell: CODBaseChatCell) {
        if self.delegate != nil {
            self.delegate?.tapAtAll()
        }
    }
    
    
    func cellDidTapedPhone(_ cell: CODBaseChatCell, phoneString: String) {
        let phone = "telprompt://" + phoneString
        if let url = URL(string: phone) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(URL(string: phone)!)
            }
        }
        
    }
    
    func cellDeleteMessage(message: CODMessageModel?) {
        if self.delegate != nil {
            //            self.dismissMenu()
            //           LPActionSheet.show(withTitle: String.init(format: "是否删除该条消息？"), cancelButtonTitle: "取消", destructiveButtonTitle: "确定", otherButtonTitles: []) { (actionSheet, index) in
            //                if index == -1 {
            self.delegate?.deleteMessage(message: message ?? CODMessageModel())
            //                }
            //            }
        }
    }
    
    func cellCardAction(_ cell: CODBaseChatCell, message: CODMessageModel?) {
        if let contectModel: CODContactModel = CODContactRealmTool.getContactByJID(by: message?.businessCardModel?.jid ?? "") ,contectModel.isValid == true {
            //点击查看详情
            self.pushToMessageVC(contactModel: contectModel)
        }else if message?.businessCardModel?.jid.contains(UserManager.sharedInstance.loginName ?? "") ?? false{
            if let model = CODContactRealmTool.getContactById(by: CloudDiskRosterID) {
                let vc = self.viewForController(view:self)
                let msgCtl = MessageViewController()
                msgCtl.chatType = .privateChat
                msgCtl.toJID = model.jid
                msgCtl.chatId = model.rosterID
                msgCtl.title = model.getContactNick()
                vc?.navigationController?.popViewController(animated: true)
                vc?.navigationController?.pushViewController(msgCtl, animated: true)
                //                vc?.navigationController?.setViewControllers([(vc?.navigationController?.viewControllers.first!)!,msgCtl], animated: true)
            }
        }else{
            //添加好友
            self.addFriend(model: message ?? CODMessageModel())
        }
        
    }
    
    /**
     点击了 cell 本身
     */
    func cellDidTaped(_ cell: CODBaseChatCell){
        
    }
    /**
     点击了 cell 的头像
     */
    func cellDidTapedAvatarImage(_ cell: CODBaseChatCell, model: CODMessageModel) {
        if self.isCloudDisk{
            if model.fw.contains(UserManager.sharedInstance.jid) {
                return
            }else if let channelModel = CODChannelModel.getChannel(jid: model.fw), channelModel != nil{
                CustomUtil.pushChannel(messageModel: model)
            }else{
                self.cloudPushPersonDetailVC(model: model, isFromMe: false)
            }
            
        }else{

            self.pushPersonDetailVC(model: model,isFromMe: cell.fromMe)
        }
    }
    
    /**
     点击了 cell 的转发
     */
    func cellDidTapedFwdImageView(_ cell: CODBaseChatCell, model: CODMessageModel) {
        
        let messageStatus: CODMessageStatus = CODMessageStatus(rawValue: model.status) ?? .Pending
        if messageStatus == .Failed {
            self.messageDisplayViewVM.cellSendMsgReation(message: model)
        }else{
            if self.delegate != nil {
                self.delegate?.transMessage(message: model)
            }
        }
    }
    
    /**
     长按了 cell 的头像
     */
    func cellDidLongTapedAvatarImage(_ cell: CODBaseChatCell, model: CODMessageModel) {
        
        if cell.fromMe {
            return
        }
        
        if self.delegate != nil {
            let memberId = CODGroupMemberModel.getMemberId(roomId: model.roomId, userName:model.fromWho)
            if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId){
                self.delegate?.longTapHeadImageView(model:memberModel)
            }
            
        }
    }
    /**
     点击了 cell 中文字的 URL 标签 等等
     */
    func cellDidTapedLink(_ cell: CODBaseChatCell, linkString: URL){
        
        //        let vc = self.viewForController(view:self)
        //        let webVC = CODGenericWebVC.init()
        //        webVC.urlString = linkString.absoluteString
        //        vc?.navigationController?.pushViewController(webVC)
        
        var strUrl = linkString.absoluteString.removeHeadAndTailSpace
        
        if strUrl.lowercased().hasPrefix("http://") == false && strUrl.lowercased().hasPrefix("https://") == false{
            strUrl = "http://" + strUrl
        }
        
        let url = URL.init(string: strUrl)!
        
        ///判断当前连接是否已频道协议连接开头
        if strUrl.hasPrefix(CODAppInfo.channelSharePublicLink) {
            
            let dict:[String:Any] = ["name": COD_MemberJoin,
                                     "requester": UserManager.sharedInstance.jid,
                                     "inviter": UserManager.sharedInstance.jid,
                                     "userid": url.lastPathComponent.removeHeadAndTailSpace,
                                     "add": false]
            
            CODProgressHUD.showWithStatus(nil)
            
            XMPPManager.shareXMPPManager.getRequest(param: dict, xmlns: COD_com_xinhoo_groupchannel) { [weak self] (response) in
                
                guard let `self` = self else { return }
                
                CODProgressHUD.dismiss()
                switch response {
                case .success(let model):
                    if model.dataJson?["roomID"].int == self.chatId { //cell.messageModel.roomId
                        //已在当前聊天的群
                        guard let vc = self.viewContainingController() as? MessageViewController else {
                            return
                        }
                        vc.pustToMessageDetail()
                        
                    }else{
                        if model.dataJson?["type"].stringValue != CODGroupType.MPRI.rawValue {
                            CustomUtil.joinChannlHandle(model: model)
                        } else {
                            CustomUtil.joinGroupHandle(model: model, linkString: strUrl, currentVC: self.viewForController(view: self))
                        }
                    }
                    
                    
                    
                    break
                default:
                    LGAlertView(title: nil, message: NSLocalizedString("此邀请链接无效或已过期", comment: ""), style: .alert, buttonTitles: nil, cancelButtonTitle: "知道了", destructiveButtonTitle: nil, actionHandler: nil, cancelHandler: nil, destructiveHandler: nil).show()
                    
                    
                    break
                }
            }
            
        }else{
            
            let alert = UIAlertController.init(title: linkString.absoluteString, message: nil, preferredStyle: .actionSheet)
            let subview = alert.view.subviews.first! as UIView
            let alertContentView = subview.subviews.first! as UIView
            alertContentView.backgroundColor = UIColor.white
            alertContentView.layer.cornerRadius = 15
            
            let openAction = UIAlertAction.init(title: NSLocalizedString("打开", comment: ""), style: .default) { (action) in
                self.openURL(url: linkString.absoluteString)
            }
            
            let copyAction = UIAlertAction.init(title: NSLocalizedString("拷贝", comment: ""), style: .default) { (action) in
                let pastboard = UIPasteboard.general
                pastboard.string = linkString.absoluteString
            }
            
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .cancel) { (action) in
                
            }
            
            alert.addAction(openAction)
            alert.addAction(copyAction)
            alert.addAction(cancelAction)
            
            UIViewController.current()?.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    /// 单按事件
    ///
    /// - Parameters:
    ///   - message: 当前的消息体
    ///   - cell: 当前的单元格
    func cellTapMessage(message:CODMessageModel?,_ cell: CODBaseChatCell)
    {
        
        if self.delegate != nil {
            self.delegate?.chatMessageDisplayViewDidTouched(chatTVC: self)
            let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: message?.msgType ?? 1) ?? .text
            
            if modelType == .image {
                self.pushToPictrueVC(message: message ?? CODMessageModel(), imageView: UIImageView.init())
            }else if modelType == .video{
                self.pushToVoideVC(message: message ?? CODMessageModel(), imageView: UIImageView.init())
            }else if modelType == .audio{
                let showCell = cell as! CODAudioChatCell
                self.playAudio(message: message, showCell: showCell)
            }else if modelType == .businessCard {
                self.pushToBussnissPersonDetailVC(model: message ?? CODMessageModel())
            }else if modelType == .location {
                self.pushLocationDetail(message: message)
            }else if modelType == .notification {
                self.addFriend(model: message ?? CODMessageModel())
            }else if modelType == .voiceCall || modelType == .videoCall {
                self.pushToVideocallVC(message: message ?? CODMessageModel(), fromMe: cell.fromMe)
            }else if modelType == .file{
                
                guard let message = message else {
                    CODProgressHUD.showErrorWithStatus("此消息已被删除")
                    return
                }

                if message.isInvalidated {
                    CODProgressHUD.showErrorWithStatus("此消息已被删除")
                    return
                }

                guard let fileModel = message.fileModel else {
                    CODProgressHUD.showErrorWithStatus("文件无效")
                    return
                }
                
                //文件后缀名
                let suffix = message.fileModel?.filename.pathExtension ?? ""

                if fileModel.fileExists {
                    
                    if fileModel.isImageOrVideo {
                        
                        self.delegate?.fileMessage(message: message,imageView: UIImageView())
                        
                    } else {
                        
                        let previewVC = CODPreviewViewController()
                        previewVC.filePath = CODFileManager.shareInstanceManger().filePathWithName(fileName: "\(fileModel.fileID).\(suffix)")
                        previewVC.fileName = fileModel.filename.count > 0 ? fileModel.filename : "文件预览"
                        let ctl = UIViewController.current()/* as? CODCustomTabbarViewController*/
                        if let nav = ctl?.navigationController {
                            nav.pushViewController(previewVC, animated: true)
                        }
                        
                    }
                                        
                }

   
            }
            
        }
        
    }  
    /// 长按事件
    ///
    /// - Parameters:
    ///   - message: 当前的消息体
    ///   - cell: 当前的单元格 
    func cellLongPressMessage(cellVM: ChatCellVM?, _ cell: UIView,_ view : UIView)
    {
        
        if UIViewController.current()?.isKind(of: BalloonActionViewController.self) ?? false {
            return
        }
        
        if !(UIViewController.current()?.isKind(of: MessageViewController.self) ?? false) {
            return
        }
        
        
        self.cellVM = cellVM
        
        if self.delegate != nil {
            self.delegate?.chatMessageDisplayViewDidTouched(chatTVC: self)
        }
        let controller = BalloonActionViewController(model:cellVM!,image: CustomUtil.conversionImageWithView(view: cell)!, fromBalloonCoordinateSpace: cell,view: view)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        controller.delegate = self
        DispatchQueue.main.async {
            
            UIViewController.current()!.present(controller, animated: true, completion: nil)
        }
        
    }
    
    /// 点击 消息已读/未读 按钮
    /// - Parameters:
    ///   - cell: 按钮所在的cell
    ///   - message: 消息模型
    func cellTapViewer(cell:CODBaseChatCell,message:CODMessageModel) {
        print(cell,message)
        let ctl = CODViewersViewController()
        ctl.message = message
        UIViewController.current()!.cyl_push(ctl, animated: true)
        
    }
}

extension CODChatMessageDisplayView:XMPPStreamDelegate{
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            
            guard let name = actionDict["name"] as? String else {
                return
            }
            
            if name == COD_createFavorite {
                if !(infoDict["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus("收藏失败")
                }else{
                    CODProgressHUD.showSuccessWithStatus("收藏成功")
                }
            }
            
            if name == COD_removeChatMsg || name == COD_removeGroupMsg || name == COD_removeLocalChatMsg || name == COD_removeLocalGroupMsg  || name == COD_removeclouddiskmsg{
                if !(infoDict["success"] as! Bool){
                    
                    if let code = infoDict["code"] as? Int {
                        switch code {
                        case 30040 :
                            
                            CODProgressHUD.showErrorWithStatus(NSLocalizedString("已过可双删时间", comment: ""))

                            break
                            
                        default:
                            if let msg = infoDict["msg"] as? String {
                                CODProgressHUD.showErrorWithStatus(msg)
                            }
                            break
                        }
                    }
                }
            }
            
//            if (actionDict["name"] as? String == COD_searchUserBID && self.isPushDetail){
//                self.isPushDetail = false
//                if (infoDict["success"] as! Bool) {
//                    guard let usersDic = infoDict["users"] else {
//                        return
//                    }
//                    CustomUtil.pushToStrangerVCWith(json: JSON(usersDic), sourceType: .groupType)
//                    
//                }
//            }
            
        }
        
        
        
        return true
    }
    
}
// MARK: - @protocol UIScrollViewDelegate
extension CODChatMessageDisplayView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < kChatLoadMoreOffset) {
            if self.delegate != nil{
                self.delegate?.loadMoreMessage()
            }
        }
        if scrollView.contentOffset.y > 300 {
            self.isShowOperationView = "show"
        }else{
            self.isShowOperationView = "dismiss"
        }
        
        if scrollView.contentOffset.y <= 5 {
            self.isAutoScrollToBottom = true
        }else{
            self.isAutoScrollToBottom = false
        }
        
        guard let index = self.tableView.indexPathsForVisibleRows?.last else {
            return
        }
        
        guard let model = self.messageDisplayViewVM.getMessageModel(indexPath: index) else {
            return
        }
        
        if model.isInvalidated {
            return
        }
        
        if self.tableView.contentSize.height > KScreenHeight && model.datetime != ""{
            self.showTimeView.setTime(time: model.datetime)
            self.showTimeView.show()
        }
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToScrollStop {
            self.showTimeView.hide()
        }
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        ///关闭编辑
        if self.delegate != nil {
            self.delegate?.chatMessageDisplayViewDidTouched(chatTVC: self)
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y - scrollView.contentInset.top < kChatLoadMoreOffset) {
            if self.delegate != nil {
                self.delegate?.loadMoreMessage()
            }
        }
        
        if !decelerate {
            let dragToDragStop = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
            if dragToDragStop {
                self.showTimeView.hide()
            }
        }
    }
    
    @objc func statusBarNotification() {
        
        self.scrollViewShouldScrollToTop(self.tableView)
        
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        if self.tableView.contentOffset.y + self.tableView.frame.size.height >= self.tableView.contentSize.height && self.tableView.mj_footer != nil {
            self.tableView.mj_footer.beginRefreshing()
        } else {
            self.tableView.scrollBottomToLastRow(at: .bottom, animated: true)
        }
        
        
        return false
    }
    
}
extension CODChatMessageDisplayView{
    
    func replaceMessageListSomeOneMessage(message: CODMessageModel) {
        let predicate = NSPredicate.init(format: "msgID == %@", message.msgID)
        let resultArray = self.messageList.filtered(using: predicate)
        if resultArray.count > 0,let messageModel = resultArray[0] as? CODMessageModel {
            let modelIndex = self.messageList.index(of: messageModel)
            if modelIndex < self.messageList.count{
                if let  newMessageModel = CODMessageRealmTool.getMessageByMsgId(message.msgID) {
                    self.messageList.replaceObject(at: modelIndex, with: newMessageModel)
                }
            }
        }
    }
    
    func compareTwoTimeIsShowTime(messageModel: CODMessageModel,modelRow: Int) -> Bool{
        
        var isNeedShowTime = false
        
        if modelRow > 0 {
            //拿到上一条消息
            if self.messageList.count > modelRow {
                if let lastModel = self.messageList[modelRow - 1] as? CODMessageModel {
                    if lastModel.msgType == EMMessageBodyType.newMessage.rawValue && modelRow - 1 == 0{
                        
                        isNeedShowTime = true
                    }else if lastModel.msgType == EMMessageBodyType.newMessage.rawValue && modelRow - 1 > 0 {
                        
                        if let lastNewModel = self.messageList[modelRow - 2] as? CODMessageModel {
                            //判断俩个model是不是需要显示时间
                            isNeedShowTime = !CustomUtil.getTimeTampIsSameDay(time1: messageModel.datetimeInt, time2: lastNewModel.datetimeInt)
                        }
                    }else{
                        isNeedShowTime = !CustomUtil.getTimeTampIsSameDay(time1: messageModel.datetimeInt, time2: lastModel.datetimeInt)
                    }
                }
            }
        }else{
            if messageModel.msgType == EMMessageBodyType.newMessage.rawValue {
                isNeedShowTime = false
            }else{
                isNeedShowTime = true
            }
        }
        if modelRow == 0 {
            isNeedShowTime = true
        }
        return isNeedShowTime
        
    }
    
    
    func isShowType(messageModel: CODMessageModel,modelRow: Int) -> CODMessageShowStatus {
        
        var showType: CODMessageShowStatus = CODMessageShowStatus(rawValue: messageModel.showType) ?? .Initial
        let fromMe: Bool = self.isFromMe(messageModel: messageModel)
        
        let nextRow: Int = modelRow + 1
        
        guard self.messageList.count > nextRow,let nextModel = self.messageList[nextRow] as? CODMessageModel,nextModel.msgType != EMMessageBodyType.newMessage.rawValue else {
            
            if messageModel.isGroupChat{
                if fromMe {
                    showType = .Part
                }else{
                    showType = .HeadAndPart
                }
            }else{
                showType = .Part
            }
            
            if showType.rawValue != messageModel.showType {
                CODMessageRealmTool.updateMessageShowTypeByMsgId(messageModel.msgID, showType: showType.rawValue)
            }
            return showType
        }
        
        //        if showType == .Initial {
        
        if messageModel.isGroupChat{
            if fromMe {
                showType = .Part
                if self.isFromMe(messageModel: nextModel) {
                    showType = .Nono
                }
            }else{
                showType = .HeadAndPart
            }
            
        }else{
            showType = .Part
            
            if fromMe {
                if self.isFromMe(messageModel: nextModel) {
                    showType = .Nono
                }
            }else{
                if !self.isFromMe(messageModel: nextModel) {
                    showType = .Nono
                }
            }
            
        }
        //更新数据库的状态
        if showType.rawValue != messageModel.showType {
            CODMessageRealmTool.updateMessageShowTypeByMsgId(messageModel.msgID, showType: showType.rawValue)
        }
        //        }
        
        return showType
    }
    
    
    func isFromMe(messageModel: CODMessageModel) -> Bool {
        var fromMe: Bool = false
        let fromWho = messageModel.fromWho
        let me = UserManager.sharedInstance.loginName
        if !fromWho.contains(me!) {
            fromMe = false
        }else{
            fromMe = true
        }
        
        return fromMe
    }
    
}

extension CODChatMessageDisplayView : BalloonActionViewControllerDelegate{
    
    func viewControllerDidRequestToDismiss(_ viewController: BalloonActionViewController) {
        viewController.dismiss(animated: true, completion: nil)
        //        self.tableView.setContentOffset(CGPoint.init(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y + self.currentMiny), animated: true)
        
    }
    
    func viewController(_ viewController: BalloonActionViewController,
                        willDisplayBalloon balloon: UICoordinateSpace,
                        coordinator: UIViewControllerTransitionCoordinator?) {
        //        let minY = viewController.fromBalloonCoordinateSpace.convert(balloon.bounds, from: balloon).minY
        //        self.tableView.contentOffset.y -= minY
        //        self.currentMiny = minY
    }
}
