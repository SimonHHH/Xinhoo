//
//  ChatViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework
import PopupKit


class ChatViewController: BaseViewController{
    
    enum ViewType {
        case normal
        case selectPerson
    }
    
    var type:ViewType = .normal
    weak var searchActionDelegate: ChatViewSearchActionDelegate?
    
    typealias ChoosePersonCompeleteBlock = (_ model:CODContactModel) -> Void ///选择联系人
    typealias ChooseGroupCompeleteBlock = (_ model:CODGroupChatModel) -> Void ///选择群
    typealias ChooseChatListCompeleteBlock = (_ model:CODChatListModel) -> Void ///选择聊天列表
    
    public var choosePersonBlock:ChoosePersonCompeleteBlock?
    public var chooseGroupBlock:ChooseGroupCompeleteBlock?
    public var chooseChatListBlock:ChooseChatListCompeleteBlock?
    
    var resultContactList :Array<CODContactModel> = Array()
    var resultGroupList :Array<CODGroupChatModel> = Array()
    
    var resultContactAndGroupList: Array<AnyObject> = Array()
    var resultMessageList: Array<CODSearchResultMessageModel> = Array()
    
    var currentTime:Double = 0
    
    var resultIndexPath : IndexPath = IndexPath.init(row: 0, section: 0)
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nullChatListView: UIView!
    
    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var tipLabHeightCos: NSLayoutConstraint!
    //    var notificationToken: NotificationToken? = nil
    
    var chatListArr :Array<CODChatListModel> = Array()
    
    var currentIndexPath : IndexPath?
    
    /// 置顶数量
    var stickyTopCount = 0
    
    var titleView:NavigationBarLoadingView?
    
    var searchCtl: UISearchController!
    
    var footViewLabel :UILabel?
//    var refreshHeader:YoukuRefreshHeader?
    
    lazy var chatResultVC: CODChatResultVC = {
        let chatResultVC = CODChatResultVC()
        chatResultVC.searchType = .contactAndGroupAndMessage
        chatResultVC.delegate = self
        return chatResultVC
    }()
    
    lazy var codeAlertView: CODCodeAlertView = {
        let codeview = Bundle.main.loadNibNamed("CODCodeAlertView", owner: self, options: nil)?.first as! CODCodeAlertView
        codeview.confirmBlock = { [weak self] (alertView, codeStr) in
            guard let `self` = self else { return }
            var searchStr = self.searchCtl.searchBar.text ?? ""
            if searchStr.starts(with: "@") {
                searchStr = searchStr.removingPrefix("@")
            }
            self.requestGlobalSearch(picCode: codeStr, searchStr: searchStr, resultVC: self.chatResultVC)
        }
        return codeview
    }()
    
    var currentLanguage: String {
        get {
            var languageStr = ""
            let lanStr = CODUserDefaults.string(forKey: kMyLanguage)
            if let tempLan = lanStr {
                if tempLan.contains("zh-Hant") {
                    languageStr = "_zh-Hant"
                }
                if tempLan.contains("en"){
                    languageStr = "_en"
                }
            }
            return languageStr
        }
    }
    
    @IBAction func checkNetWorkAction(_ sender: Any) {
        
        let vc = CODChangeServersAddressViewController(nibName: "CODChangeServersAddressViewController", bundle: Bundle.main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tipLab.text = NSLocalizedString("长时间连接不上，可以尝试切换服务器", comment: "")
        
//        XMPPManager.shareXMPPManager.rx.observe(\.reconnectCount)
//            .filterNil()
//            .bind { [weak self] (count) in
//                guard let `self` = self else {
//                    return
//                }
//                if count == 0 {
//                    self.tipLabHeightCos.constant = 0
//                }
//
//                if count == 3{
//                    self.tipLabHeightCos.constant = 50
//                }
//        }
//        .disposed(by: self.rx.disposeBag)
        
        self.titleView = Bundle.main.loadNibNamed("NavigationBarLoadingView", owner: self, options: nil)?.last as? NavigationBarLoadingView
        self.titleView!.titleString = NSLocalizedString("聊天", comment: "")
        self.titleView!.loadingView.stopAnimating()
        self.titleView!.midCos.constant = 0;
        self.titleView!.frame = CGRect.init(x: 0, y: 0, width: 100, height: 40)
        self.navigationItem.titleView = self.titleView
        
        //防止UISearchBar跳动或偏移
        self.definesPresentationContext = true
        self.modalPresentationStyle = .fullScreen
//        self.edgesForExtendedLayout = UIRectEdge.left
        self.extendedLayoutIncludesOpaqueBars = true
        self.setRightButtons()
        self.rightButton.setImage(UIImage(named: "chat_more"), for: UIControl.State.normal)
        self.rightButton.setImage(UIImage(named: "chat_more_selected"), for: UIControl.State.selected)
        
        self.subRightButton.setImage(UIImage(named: "changeip_icon"), for: .normal)
        
        self.backButton.setTitle(NSLocalizedString("编辑", comment: ""), for: .normal)
        self.backButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
        self.backButton.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: .normal)
        self.backButton.setImage(nil, for: .normal)
        self.setBackButton()
        
        self.initUI()
        
        self.initData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteChatListData(notification:)), name: NSNotification.Name(kDeleteChatListNoti), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name.init(kChangeLanguageNoti), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadChatListData), name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.waitNetwork), name: NSNotification.Name.init(kWaitNetwork), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.connecting), name: NSNotification.Name.init(kConnecting), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.beginGetHistory), name: NSNotification.Name.init(kBeginGetHistory), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.endGetHistory), name: NSNotification.Name.init(kEndGetHistory), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop(noti:)), name: NSNotification.Name.init(kClickTabbarItemNoti), object: nil)
        if type != .selectPerson {
            self.tableView.mj_header = CODGifHeader.init(refreshingBlock: {[weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self?.tableView.mj_header.endRefreshing()
                })
            })
            self.tableView.mj_header.isAutomaticallyChangeAlpha = false
        }
        if !XMPPManager.shareXMPPManager.xmppStream.isAuthenticated {
            
            self.connecting()
        }
        
//        self.tableView.mj_header.beginRefreshing()
    }

    override func navBackClick() {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        self.backButton.setTitle(self.tableView.isEditing ? NSLocalizedString("完成", comment: "") : NSLocalizedString("编辑", comment: ""), for: .normal)
        self.rightButton.isHidden = self.tableView.isEditing
    }
    
    @objc func scrollToTop(noti:NSNotification) {
        
        let index = noti.object as! NSNumber
        if UserDefaults.standard.string(forKey: kShowCallTab) == "true" {
            if index.intValue == 2 {
                self.scrollToUnRead()
            }
        }else{
            if index.intValue == 1 {
                self.scrollToUnRead()
            }
        }
        
    }
    
    
    /// 让最近的一条未读滚动至最顶部，如果没有则滚动至
    func scrollToUnRead() {
        if let visibleFirstIndex = self.tableView.indexPathsForVisibleRows?.first {
            
            var result = chatListArr.filter { (model) -> Bool in
                return model.count > 0 && ((!(model.contact?.mute ?? true) || !(model.groupChat?.mute ?? true) || !(model.channelChat?.mute ?? true)) || model.id == -999)
            }.map { (model) -> IndexPath in
                
                return IndexPath(row: chatListArr.firstIndex(of: model) ?? 0, section: 0)
            }.sorted(by: \.row)
            
            if result.count == 0 {
                
                result = chatListArr.filter { (model) -> Bool in
                    return model.count > 0 && (((model.contact?.mute ?? false) || (model.groupChat?.mute ?? false) || (model.channelChat?.mute ?? false)) || model.id == -999)
                }.map { (model) -> IndexPath in
                    
                    return IndexPath(row: chatListArr.firstIndex(of: model) ?? 0, section: 0)
                }.sorted(by: \.row)
                
                if result.count == 0 {
                    self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    return
                }
            }
            
            if visibleFirstIndex.row >= result.last!.row {
                self.tableView.scrollToRow(at: result.first!, at: .top, animated: true)
            }else{
                for indexPath in result {
                    if indexPath.row > visibleFirstIndex.row {
                      self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        return
                    }
                }
            }
            
            
        }
    }
    
    @objc func waitNetwork() {
        NSLog("@@@@@@@连接中")
        dispatch_async_safely_to_main_queue {
            self.titleView!.titleString = NSLocalizedString("等待网络连接", comment: "")
            self.titleView!.loadingView.startAnimating()
            self.titleView!.midCos.constant = 0;
        }
        
    }
    
    @objc func connecting() {
        NSLog("@@@@@@@连接中")
        dispatch_async_safely_to_main_queue {
            self.titleView!.titleString = NSLocalizedString("连接中...", comment: "")
            self.titleView!.loadingView.startAnimating()
            self.titleView!.midCos.constant = 20;
        }
        
    }
    
    @objc func beginGetHistory() {
        dispatch_async_safely_to_main_queue {
            NSLog("@@@@@@@开始获取历史消息")
            XMPPManager.shareXMPPManager.isGetRoomHistory = true
            self.titleView!.titleString = NSLocalizedString("收取中...", comment: "")
            self.titleView!.loadingView.startAnimating()
            self.titleView!.midCos.constant = 20;
        }
    }
    
    @objc func endGetHistory() {
        dispatch_async_safely_to_main_queue {
            
            XMPPManager.shareXMPPManager.isGetRoomHistory = false
            self.currentTime = 0
            self.reloadChatListData()
            self.titleView!.titleString = NSLocalizedString("聊天", comment: "")
            self.titleView!.loadingView.stopAnimating()
            self.titleView!.midCos.constant = 0;
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkTopLineIsHidden()
        self.tableView.reloadData()
        
        if self.searchCtl?.isActive ?? false || self.type == .selectPerson {
            self.tabBarController?.tabBar.isHidden = true
        }else{
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.currentIndexPath = nil
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabShadowImageView()?.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
    }
    
    @objc func reloadView() {
        self.titleView!.titleString = NSLocalizedString("聊天", comment: "")
        self.titleView!.loadingView.stopAnimating()
        self.titleView!.midCos.constant = 0;
        searchCtl.searchBar.placeholder = NSLocalizedString("搜索聊天", comment: "")
    }
    
    func initData() {
        
        if self.type == .normal {
            let chatSTList = CODChatListRealmTool.getStickyTopList()
            self.chatListArr.append(contentsOf: chatSTList)
            let chatNSTList = CODChatListRealmTool.getNoneStickyTopList()
            self.chatListArr.append(contentsOf: chatNSTList)
            self.stickyTopCount = chatSTList.count
        }else{
            
            var chatSTList = Array<CODChatListModel>()
            if CODChatListRealmTool.getStickyTopList(filterNewFriend: false).count > 0 {
                for model in CODChatListRealmTool.getStickyTopList(filterNewFriend: false) {
                    if let model = self.filterUnvalidChat(chatListModel: model) {
                        chatSTList.append(model)
                    }
                }
            }
            self.stickyTopCount = chatSTList.count
            self.chatListArr.append(contentsOf: chatSTList)
            
            var chatNSTList = Array<CODChatListModel>()
            if CODChatListRealmTool.getNoneStickyTopList(filterNewFriend: false).count > 0 {
                for model in CODChatListRealmTool.getNoneStickyTopList(filterNewFriend: false) {
                    if let model = self.filterUnvalidChat(chatListModel: model) {
                        chatNSTList.append(model)
                    }
                }
            }
            self.chatListArr.append(contentsOf: chatNSTList)
            
            // 我的云盘需要前置
            if let cloudDiskIndex = self.chatListArr.firstIndex(where: { (listModel) -> Bool in
                return listModel.id == CloudDiskRosterID
            }) {
                let cloudDiskModel = self.chatListArr[cloudDiskIndex]
                self.chatListArr.remove(at: cloudDiskIndex)
                self.chatListArr.insert(cloudDiskModel, at: 0)
                
                //置顶数加上我的云盘
                self.stickyTopCount += 1
            }
        }
        
        self.tableView.reloadData()
        self.updateFooter()
        
    }
    
    func filterUnvalidChat(chatListModel: CODChatListModel) -> CODChatListModel? {
        if let _ = chatListModel.contact {
            return chatListModel
        }
        if let groupChat = chatListModel.groupChat {
            if groupChat.isValid {
                return chatListModel
            }else{
                return nil
            }
        }
        if let _ = chatListModel.channelChat {
            return chatListModel
        }
        return nil
    }
    
    func updateFooter()  {
        
        if self.chatListArr.count <= 0 {
            self.footViewLabel?.text = ""
            nullChatListView.isHidden = false
        }else{
            nullChatListView.isHidden = true
            self.footViewLabel?.text = String(format: NSLocalizedString("%ld个会话", comment: ""), self.chatListArr.count)
        }
    }
    
    func initUI() {
        self.setUpSearchBar()
        if self.type == .normal {
            setSearchBarBottomLine()
        }
        
        tableView.register(UINib(nibName: "ChatListCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(CODChoosePersonCell.self, forCellReuseIdentifier: "CODChoosePersonCellID")

        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 56))
        bgView.backgroundColor = UIColor.clear
        bgView.addSubview(searchCtl.searchBar)
        
        if (type != .selectPerson) {
            
            self.tableView.tableHeaderView = bgView
        }
        
        
        
        self.tableView.tableFooterView = self.createFooterView()
        
    }
    
    
    func setUpSearchBar() {
        
        
        self.searchCtl = UISearchController.init(searchResultsController: self.chatResultVC)
        
        if self.type == .normal {
            searchCtl.searchBar.placeholder = NSLocalizedString("搜索消息或用户", comment: "")
        } else {
            searchCtl.searchBar.placeholder = NSLocalizedString("搜索", comment: "")
        }
        
        searchCtl.delegate = self
        searchCtl.searchResultsUpdater = self
        searchCtl.searchBar.delegate = self
        
        searchCtl.view.backgroundColor = UIColor.init(hexString: kVCBgColorS)
        searchCtl.searchBar.barTintColor = UIColor.init(hexString: kVCBgColorS)
        
//        searchCtl.searchBar.sizeToFit()
        
        searchCtl.hidesNavigationBarDuringPresentation = true
        searchCtl.dimsBackgroundDuringPresentation = false
        searchCtl.searchBar.backgroundImage = UIImage.imageFromColor(color: UIColor.clear, viewSize: CGSize.init(width: 1, height: 1))
        searchCtl.searchBar.tintColor = UIColor.init(hexString: kBlueTitleColorS)
        searchCtl.view.size.height -= 40
                
        let searchBarTF = searchCtl.searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 17)
        searchBarTF?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
        if let placeholderString = self.searchCtl.searchBar.placeholder  {
            self.searchCtl.searchBar.setPositionAdjustment(UIOffset.init(horizontal: (KScreenWidth -  placeholderString.getSearchBarPlaceholderWidth())/2, vertical: 0), for: UISearchBar.Icon.search)
        }
    }
    
    func createFooterView() -> UIView {
        
        let textFont = UIFont.systemFont(ofSize: 12)
        let sectionHeight: CGFloat = 50
        footViewLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
        footViewLabel?.textAlignment = NSTextAlignment.center
        footViewLabel?.font = textFont
        footViewLabel?.numberOfLines = 0
        footViewLabel?.textColor = UIColor(hexString: "#B2B2B2")
        
        return footViewLabel!
    }
    
    override func navSubRightClick() {
        let vc = CODChangeServersAddressViewController(nibName: "CODChangeServersAddressViewController", bundle: Bundle.main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func navRightClick() {
        // 显示更多（发起群组、添加好友、扫一扫、等）
        self.rightButton.isSelected = !self.rightButton.isSelected
        if !self.rightButton.isSelected {
            ChatMoreOptionsView.removeFrom(view: self.view)
            return
        }
        
        let moreOptionsView = ChatMoreOptionsView()
        weak var weakSelf = self
        moreOptionsView.disappearCloser = {
            weakSelf?.rightButton.isSelected = false
            moreOptionsView.removeAllFromSuperView()
        }
        moreOptionsView.selectRowCloser = {(row : NSInteger) in
            weakSelf?.rightButton.isSelected = false
            switch row {
            case 0:
                let ctl = CreGroupChatViewController()
                ctl.ctlType = .createGroup
                ctl.createGroupSuccess = {(_ groupChatModel: CODGroupChatModel) in
                    let msgCtl = MessageViewController()
                    msgCtl.chatType = .groupChat
                    msgCtl.roomId = "\(groupChatModel.roomID)"
                    msgCtl.title = groupChatModel.getGroupName()
                    msgCtl.toJID = String(groupChatModel.jid)
                    msgCtl.chatId = groupChatModel.roomID
                    msgCtl.isMute = groupChatModel.mute
                    self.navigationController?.pushViewController(msgCtl, animated: true)
                }
                weakSelf?.navigationController?.pushViewController(ctl, animated: true)
            case 1:
                let ctl = AddFriendViewController()
                weakSelf?.navigationController?.pushViewController(ctl, animated: true)
            case 2:
                let ctl = CODSetGroupNameAndAvatarVC()
                ctl.vcType = .createChannel
                weakSelf?.navigationController?.pushViewController(ctl, animated: true)
            default:
                let ctl = ScanViewController()
                weakSelf?.navigationController?.pushViewController(ctl, animated: true)
            }
            weakSelf?.rightButton.isSelected = false
        }
        moreOptionsView.show(with: self.view)
        moreOptionsView.snp.remakeConstraints { (make) in
            make.right.equalTo(self.view).offset(-7.5)
            make.width.equalTo(179)
//            make.width.equalTo(ChatMoreOptionsView.getWidth())
            make.height.equalTo(ChatMoreOptionsView.getHeight())
            make.top.equalTo(self.tableView.snp.top).offset(2)
        }
    }
    
    @objc func reloadChatListData() {
        dispatch_async_safely_to_main_queue {
            
            if XMPPManager.shareXMPPManager.isGetRoomHistory == false || Date.milliseconds - self.currentTime > 5000 {
                
                self.currentTime = Date.milliseconds
                self.chatListArr.removeAll()
                self.initData()
            }
        }
    }

    @objc func deleteChatListData(notification : NSNotification) {
        dispatch_async_safely_to_main_queue {
            let dic = notification.userInfo
            let id = dic!["id"] as! Int
            for chatList in self.chatListArr {
                if chatList.id == id {
                    self.chatListArr.removeAll(chatList)
                }
            }
            self.tableView.reloadData()
        }
        
//        if Thread.isMainThread {
//        }else{
//            DispatchQueue.main.sync {
//                let dic = notification.userInfo
//                let id = dic!["id"] as! Int
//                for chatList in chatListArr {
//                    if chatList.id == id {
//                        chatListArr.removeAll(chatList)
//                    }
//                }
//                tableView.reloadData()
//            }
//        }
    }
    
    func setSearchBarBottomLine() {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kSepLineColorS)
        searchCtl?.searchBar.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func checkTopLineIsHidden() {

        if self.type == .normal{
            if tableView.contentOffset.y >= self.searchCtl.searchBar.height {
                self.tabShadowImageView()?.isHidden = false
            }else{
                self.tabShadowImageView()?.isHidden = true
            }
        }
        
    }
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
    }
}

extension ChatViewController: XMPPStreamDelegate {
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { [weak self] (actionDic, infoDic) in
//            guard let infoDic = infoDic else {
//                return
//            }
//            guard let weakSelf = self else {
//                return
//            }
//            if let iqNameStr = actionDic["name"] as? String {
//            }
        }
        return true
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

}


