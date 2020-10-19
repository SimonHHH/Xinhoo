//
//  ContactsViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Contacts
import LGAlertView
import RxSwift
import RxCocoa

class ContactsViewController: BaseViewController {
    
    enum ViewType {
        case normal
        case selectPerson
        case newCall
    }
    
    var type:ViewType = .normal
    weak var searchActionDelegate: contactsViewSearchActionDelegate?
    
    typealias ChoosePersonCompeleteBlock = (_ model:CODContactModel) -> Void ///选择联系人
    typealias ChooseGroupCompeleteBlock = (_ model:CODGroupChatModel) -> Void ///选择群
    typealias ChooseChatListCompeleteBlock = (_ model:CODChatListModel) -> Void ///选择聊天列表
    
    public var choosePersonBlock:ChoosePersonCompeleteBlock?
    public var chooseGroupBlock:ChooseGroupCompeleteBlock?
    public var chooseChatListBlock:ChooseChatListCompeleteBlock?
    
    var resultContactList :Array<CODContactModel> = Array()
    var resultGroupList :Array<CODGroupChatModel> = Array()
    var resultIndexPath : IndexPath = IndexPath.init(row: 0, section: 0)
    var selectContactModel : CODContactModel?
    
    var listHeadArr: Array<Array<Dictionary<String, String>>> = []

    var footViewLabel :UILabel?
    
    
    var stringsToSort = Array<String>()
    var indexArray: Array = [String]()
    var contactListArr :Array = [CODContactModel]()
    var contactSortResultArr: Array = [Array<CODContactModel>]()
    
    var onlineContactList :Array<CODContactModel> = Array()
    var sortType: Int = UserManager.sharedInstance.contactSortType
    
    var isHaveNew: Bool = false

    
    @IBOutlet weak var tableView: UITableView!
    
    var searchCtl: UISearchController? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkTopLineIsHidden()
        if self.type == .normal{
            isHaveNew = true
            self.tableView.reloadRows(at: [IndexPath.init(row: 2, section: 0)], with: UITableView.RowAnimation.none)
        }
        if self.searchCtl?.isActive ?? false || self.type == .selectPerson {
            self.tabBarController?.tabBar.isHidden = true
        }else{
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabShadowImageView()?.isHidden = false
    }
    
    deinit {
        CODRealmTools.default.contactNotificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("联系人", comment: "")
        self.setRightButton()
        self.rightButton.setImage(UIImage(named: "chat_more"), for: UIControl.State.normal)
        self.rightButton.setImage(UIImage(named: "chat_more_selected"), for: UIControl.State.selected)
        
        if self.type == .newCall {
            self.rightButton.isHidden = true
            self.navigationItem.title = NSLocalizedString("新呼叫", comment: "")
        }
        
        self.setupUI()
        self.initUI()
        
        if self.type == .normal {
            self.addNotifation()
        }
        
        self.loadData()
        self.bindData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop(noti:)), name: NSNotification.Name.init(kClickTabbarItemNoti), object: nil)
        
        let realm = try! Realm.init()
        
        CODRealmTools.default.contactNotificationToken = realm.objects(CODContactModel.self).observe({ [weak self](changes: RealmCollectionChange) in
            
            switch changes{
            case .initial(_): break
            case .update(_, let deletions, let insertions, _):
//                if deletions.count > 0 || insertions.count > 0 {
                    self?.loadData()
//                }
                
            case .error(_): break
            @unknown default: break
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func scrollToTop(noti:NSNotification) {
        
        let index = noti.object as! NSNumber
        if index.intValue == 0 {
            self.tableView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        }
    }
    
    
    func setupUI() {
    
        //防止UISearchBar跳动或偏移
//        self.definesPresentationContext = true
//        self.edgesForExtendedLayout = UIRectEdge.left
        self.tableView.register(CODChoosePersonCell.self, forCellReuseIdentifier: "CODChoosePersonCellID")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.clear
        
    }
    
    lazy var alertSubView: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 32))
        lab.text = "排列方式按："
        lab.textAlignment = .center
        lab.textColor = UIColor(hexString: kSubTitleColors)
        lab.font = UIFont.systemFont(ofSize: 13.0)
        return lab
    }()
    
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
    
    func addNotifation() {
        NotificationCenter.default.addObserver(self, selector: #selector(haveNewFriend(notify:)), name: NSNotification.Name(rawValue: HAVE_NEWFRIEND_NOTICATION), object: nil)
    }
    
    func loadData() {
        if UserManager.sharedInstance.contactSortType == 2 && self.type == .normal {
            self.getOnlineSortData()
        }else{
            self.getLocationDataContactData()
        }
        
    }
    
    func bindData() {
        UserManager.sharedInstance.rx.contactSortType
        .bind(to: self.rx.contactSortTypeBinder)
        .disposed(by: self.rx.disposeBag)
    }
    
    
    
    @objc func haveNewFriend(notify: Notification) {
        
        if UserManager.sharedInstance.isLogin != false {
            return
        }
        
        if UserManager.sharedInstance.haveNewFriend > 0 {
            isHaveNew = true
        } else {
            isHaveNew = false
        }
        
        self.tableView.reloadRows(at: [IndexPath.init(row: 2, section: 0)], with: UITableView.RowAnimation.none)
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
            moreOptionsView.removeAllFromSuperView()
            weakSelf?.rightButton.isSelected = false
        }
        
        moreOptionsView.selectRowCloser = {(row : NSInteger) in
            switch row {
            case 0:
                let ctl = CreGroupChatViewController()
                ctl.ctlType = .createGroup
                ctl.createGroupSuccess = { [weak self] (_ groupChatModel : CODGroupChatModel) in
                    guard let `self` = self else { return }
                    let msgCtl = MessageViewController()
                    msgCtl.chatType = .groupChat
                    msgCtl.roomId = "\(groupChatModel.roomID)"
                    msgCtl.title = NSLocalizedString("群组", comment: "")
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
            make.right.equalTo(self.view).offset(-10)
//            make.width.equalTo(ChatMoreOptionsView.getWidth())
            make.width.equalTo(179)
            make.height.equalTo(ChatMoreOptionsView.getHeight())
            make.top.equalTo(self.tableView.snp.top).offset(10.0)
        }
    }

    
    @objc func getLocationDataContactData() {
        
        listHeadArr = [[["img":"save_gpChat_icon","title":"群组"],
                        ["img":"save_channeles_icon","title":"频道"],
                        ["img":"new_friend_icon","title":"新的朋友"]],
                       [["img":"contact_sort","title":"按姓名排序"]]]
        
        var indexArrayTemp = [String]()
        if self.type == .normal {
            
            for _ in 0..<self.listHeadArr.count {
                indexArrayTemp.append(" ")
            }
            
        }
        
        let contacts = CODContactRealmTool.getContactsNotBlackList()
        if let contactList = contacts  {
            
            var stringsToSortTemp = [String]()
            var contactListArrTemp = [CODContactModel]()
            
            for contact in contactList {
                if contact.rosterID == RobotRosterID {
                    if self.type == .newCall {
                        continue
                    }
                }

                stringsToSortTemp.append(contact.getContactNick())
                contactListArrTemp.append(contact)
            }
            self.stringsToSort = stringsToSortTemp
            self.contactListArr = contactListArrTemp
        }
        
        if let indexStringS = ChineseString.indexArray(self.stringsToSort) as? [String]   {
            for string in indexStringS {
                indexArrayTemp.append(string)
            }
        }
        self.indexArray = indexArrayTemp
        
        if let contactResults = ChineseString.modelSortArray(self.contactListArr) as? [Array<CODContactModel>] {
            self.contactSortResultArr = contactResults
        }
        footViewLabel?.text = String(format: NSLocalizedString("%d位联系人", comment: ""), self.contactListArr.count)
        tableView.reloadData()
    }
    
    func getOnlineSortData() {
        listHeadArr = [[["img":"save_gpChat_icon","title":"群组"],
                        ["img":"save_channeles_icon","title":"频道"],
                        ["img":"new_friend_icon","title":"新的朋友"]],
                       [["img":"contact_sort","title":"按最后上线时间排序"]]]
        

        
        let contacts = CODContactRealmTool.getContactsNotBlackList()
        if let contactList = contacts , contactList.count > 0 {
            var contactSortResultArrTemp = [Array<CODContactModel>]()
            var contactListArrTemp = [CODContactModel]()
            var otherContactListArrTemp = [CODContactModel]()
            var onlineContactListTemp = [CODContactModel]()
            var unvisibleLoginTimeListTemp = [CODContactModel]()
            for contact in contactList {
                contactListArrTemp.append(contact)
                if contact.loginStatus.compareNoCaseForString("online") {  //获取在线好友
                    onlineContactListTemp.append(contact)
                }else{
                    if contact.lastLoginTimeVisible == true {
                        otherContactListArrTemp.append(contact)
                    }else{
                        unvisibleLoginTimeListTemp.append(contact)
                    }
                    
                }
            }
            
            contactSortResultArrTemp.append(onlineContactListTemp.sort(by: \.pinYin, ascending: true))
            contactSortResultArrTemp.append(otherContactListArrTemp.sort(by: \.lastlogintime, ascending: false))
            contactSortResultArrTemp.append(unvisibleLoginTimeListTemp.sort(by: \.pinYin, ascending: true))
            
            self.contactSortResultArr = contactSortResultArrTemp
            self.contactListArr = contactListArrTemp
        }
        
        
        footViewLabel?.text = String(format: NSLocalizedString("%d位联系人", comment: ""), self.contactListArr.count)
        tableView.reloadData()
        
    }
    
    func initUI() {
        let searchResultCtl = CODChatResultVC()
        searchResultCtl.searchType = .contactAndGroup
        if type == .newCall {
            searchResultCtl.searchType = .onlyContact
        }
        searchResultCtl.delegate = self
        searchCtl = UISearchController.init(searchResultsController: searchResultCtl)
        guard let searchCtl = searchCtl else {
            return
        }
        
        if type == .selectPerson {
            searchCtl.searchBar.placeholder = NSLocalizedString("搜索", comment: "")
        } else if type == .normal {
            searchCtl.searchBar.placeholder = NSLocalizedString("搜索联系人、群组或频道", comment: "")
        } else {
            searchCtl.searchBar.placeholder = NSLocalizedString("搜索联系人", comment: "")
        }
        
        searchCtl.searchBar.isTranslucent = false
        searchCtl.delegate = self
        searchCtl.searchResultsUpdater = self
        searchCtl.searchBar.delegate = self
        searchCtl.hidesNavigationBarDuringPresentation = true
        searchCtl.dimsBackgroundDuringPresentation = false
        //searchCtl.extendedLayoutIncludesOpaqueBars = false
        //searchCtl.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        //searchCtl.searchBar.sizeToFit()
        searchCtl.searchBar.backgroundImage = UIImage.imageFromColor(color: UIColor.clear, viewSize: CGSize.init(width: 1, height: 1))
        searchCtl.searchBar.customTextField?.backgroundColor = UIColor.init(hexString: kSearchBarTextFieldBackGdColorS)
        searchCtl.searchBar.barTintColor = UIColor.init(hexString: kVCBgColorS)
        searchCtl.searchBar.tintColor = UIColor.init(hexString: kBlueTitleColorS)
        if self.type == .normal {
            setSearchBarBottomLine()
        }
        
        self.definesPresentationContext = true
        //self.extendedLayoutIncludesOpaqueBars = true
        //self.modalPresentationStyle = UIModalPresentationStyle.currentContext
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        let searchBarTF = searchCtl.searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 17)
        
        if let placeholderString = searchCtl.searchBar.placeholder  {
            searchCtl.searchBar.setPositionAdjustment(UIOffset.init(horizontal: (KScreenWidth -  placeholderString.getSearchBarPlaceholderWidth())/2, vertical: 0), for: UISearchBar.Icon.search)
        }
        
//        if self.type == .normal || self.type == .newCall {
        let headView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 56))
        headView.backgroundColor = UIColor.clear
        headView.addSubview(searchCtl.searchBar)
        if (type != .selectPerson) {
            
            self.tableView.tableHeaderView = headView
        }
            
//        }
        
        self.tableView.tableFooterView = self.createFooterView()

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
            if tableView.contentOffset.y >= self.searchCtl?.searchBar.height ?? 0.0 {
                self.tabShadowImageView()?.isHidden = false
            }else{
                self.tabShadowImageView()?.isHidden = true
            }
        }
        
    }
    
}

extension ContactsViewController :UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if self.type == .normal {
            if indexPath.section == 0 {
                switch indexPath.row {
                case 0:
                    self.pushSaveChatVC()
                case 1:
                    self.pushSaveChatVC(ctlType: .saveChannelType)
                default:
                    self.pushNewFriendVC()
                }
            }else if indexPath.section == 1 {
                // 排序方式
                self.changeSortType()
            }else{
                let model: CODContactModel = self.contactSortResultArr[indexPath.section-self.listHeadArr.count][indexPath.row]
                let msgCtl = MessageViewController()
                msgCtl.toJID = model.jid
                msgCtl.chatId = model.rosterID
                
                if model.rosterID == RobotRosterID {
                    msgCtl.title = NSLocalizedString(model.getContactNick(), comment: "")
                }else{
                    msgCtl.title = model.getContactNick()
                }

                msgCtl.isMute = model.mute
                self.navigationController?.pushViewController(msgCtl, animated: true)
                
            }
        }else if (self.type == .selectPerson){
            let model: CODContactModel = self.contactSortResultArr[indexPath.section][indexPath.row]
            if self.choosePersonBlock != nil {
                self.choosePersonBlock!(model)
            }
        }else if (self.type == .newCall){
            
            if UserDefaults.standard.bool(forKey: kIsVideoCall) {
                CODProgressHUD.showWarningWithStatus("当前无法发起语音通话")
                return
            }
            
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(title: "语音通话", style: .default, isEnabled: true) { (action) in
                let model: CODContactModel = self.contactSortResultArr[indexPath.section][indexPath.row]
                
                if UserDefaults.standard.bool(forKey: kIsVideoCall) {
                    CODProgressHUD.showWarningWithStatus("当前无法发起语音通话")
                    return
                }
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                if delegate.callObserver.calls.first != nil {
                    let alert = UIAlertController.init(title: "正在通话", message: String.init(format: NSLocalizedString("您不能在电话通话时同时使用 %@ 通话。", comment: ""), kApp_Name), preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                                
                if delegate.manager?.status == .notReachable {
                    
                    let alert = UIAlertController.init(title: "无法呼叫", message: "请检查您的互联网连接并重试。", preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
                        
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                let  dict:NSDictionary = ["name":COD_request,
                                          "requester":UserManager.sharedInstance.jid,
                                          "memberList":[model.jid],
                                          "chatType":"1",
                                          "roomID":"0",
                                          "msgType":COD_call_type_voice]
                
                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
                XMPPManager.shareXMPPManager.xmppStream.send(iq)
            }
//            alert.addAction(title: "视频通话", style: .default, isEnabled: true) { (action) in
//                let model: CODContactModel = self.contactSortResultArr[indexPath.section][indexPath.row]
//                
//                if UserDefaults.standard.bool(forKey: kIsVideoCall) {
//                    CODProgressHUD.showWarningWithStatus("当前无法发起视频通话")
//                    return
//                }
//                
//                let delegate = UIApplication.shared.delegate as! AppDelegate
//                if delegate.manager?.networkReachabilityStatus == .notReachable {
//                    
//                    let alert = UIAlertController.init(title: "无法呼叫", message: "请检查您的互联网连接并重试。", preferredStyle: .alert)
//                    let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
//                        
//                    }
//                    alert.addAction(okAction)
//                    self.present(alert, animated: true, completion: nil)
//                    return
//                }
//                
//                let  dict:NSDictionary = ["name":COD_request,
//                                          "requester":UserManager.sharedInstance.jid,
//                                          "memberList":[model.jid],
//                                          "chatType":"1",
//                                          "roomID":"0",
//                                          "msgType":COD_call_type_video]
//                
//                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
//                XMPPManager.shareXMPPManager.xmppStream.send(iq)
//            }
            alert.addAction(title: "取消", style: .cancel, isEnabled: true) { (action) in
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if self.type == .normal && UserManager.sharedInstance.contactSortType == 2 {
            return nil
        }else{
            return self.indexArray
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {

        if self.type == .normal {
            if UserManager.sharedInstance.contactSortType == 2 {
                return self.listHeadArr.count + self.contactSortResultArr.count
            }
            return self.indexArray.count
        }else{
            return self.contactSortResultArr.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.type == .normal {
            if section == 0 {
                return 0.01
            }
            if section == 1 {
                return 16.0
            }
            if UserManager.sharedInstance.contactSortType == 2 {
                if section == 2 {
                    return 16.0
                }else{
                    return 0.01
                }
            }
        }
        return 28.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.type == .normal && UserManager.sharedInstance.contactSortType == 2 {
            return UIView()
        }
        let textString = self.indexArray[section]
        let textFont = UIFont.systemFont(ofSize: 12)
        let sectionHeight: CGFloat = 28
        let textLabel = UILabel.init(frame: CGRect(x: 14, y: 0, width: KScreenWidth-28, height: sectionHeight))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.font = textFont
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(hexString: kSectionHeaderTextColorS)
        textLabel.text = textString
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
        bgView.backgroundColor = UIColor.init(hexString: kVCBgColorS)
        bgView.addSubview(textLabel)
        return bgView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.checkTopLineIsHidden()
    }
    
}

extension ContactsViewController :UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.type == .normal {
            if section < listHeadArr.count {
                return listHeadArr[section].count
            }else{
                
                let index = section-listHeadArr.count
                
                if index >= 0 && index < self.contactSortResultArr.count {
                    return self.contactSortResultArr[index].count
                }
                
                return 0
            }
        }else if (self.type == .selectPerson){
            return self.contactSortResultArr[section].count
        }else if (self.type == .newCall){
            return self.contactSortResultArr[section].count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.type == .normal {
            let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
            
            
            if indexPath.row == 2 && indexPath.section == 0 {
                cell.isHiddenRedView = UserManager.sharedInstance.haveNewFriend
            }else{
                cell.isHiddenRedView = 0
            }
            if indexPath.section < listHeadArr.count {
                let arr = listHeadArr[indexPath.section]
                let dic = arr[indexPath.row]
                
                
                cell.titleFont = UIFont.systemFont(ofSize: 15)
                cell.titleColor = UIColor.init(hexString: kTabItemSelectedColorS)!
                cell.imgView.contentMode = .center
                cell.selectionStyle = .gray
                if indexPath.row == arr.count-1 {
                    cell.isLast = true
                }else{
                    cell.isLast = false
                }
                if indexPath.section == 1 {
                    cell.attributedTitle = self.setAttributeTitle(title: dic["title"]!, imgName: dic["img"]!)
                    cell.titleTextAlignment = .center
                    cell.iconImage = nil
                }else{
                    cell.title = dic["title"]
                    cell.titleTextAlignment = .left
                    cell.iconImage = UIImage(named: dic["img"]!)
                }
                cell.placeholer = ""
            } else {
                let datas = self.contactSortResultArr[indexPath.section-listHeadArr.count]
                let model: CODContactModel = datas[indexPath.row]
                if (model.name == "\(kApp_Name)小助手") {
                    //网络图片需要处理一下
                    cell.iconImage = UIImage.helpIcon()
                }else{
                    cell.urlStr = model.userpic.getHeaderImageFullPath(imageType: 1)
                }
                cell.titleTextAlignment = .left
                cell.title = model.getContactNick()
                cell.titleColor = UIColor.black
                cell.imgView.contentMode = .scaleAspectFit
                
                if UserManager.sharedInstance.contactSortType == 1 {
                    if indexPath.row == datas.count-1 {
                        cell.isLast = true
                    }else{
                        cell.isLast = false
                    }
                }else{
                    if indexPath.section-listHeadArr.count == self.contactSortResultArr.count-1 && indexPath.row == datas.count-1 { //最后的section且最后的row
                        cell.isLast = true
                    }else{
                        cell.isLast = false
                    }
                }
                
                let result = CustomUtil.getOnlineTimeStringAndStrColor(with: model)
                cell.placeholer = result.timeStr
                cell.placeholerColor = result.strColor
                cell.titleFont = UIFont.systemFont(ofSize: 17)
            }
            
            return cell
        }else if (self.type == .selectPerson || self.type == .newCall){
            let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
           
            let datas = self.contactSortResultArr[indexPath.section]
            let model: CODContactModel = self.contactSortResultArr[indexPath.section][indexPath.row]
            if (model.name == "\(kApp_Name)小助手") {
                //网络图片需要处理一下
                cell.iconImage = UIImage.helpIcon()
            }else{
//                if let _ = URL.init(string: model.userpic.getHeaderImageFullPath(imageType: 0)) {
//                    CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.userpic) { (image) in
//                        cell.imgView.image = image
//                    }
//                }else{
//                    cell.imgView.image = UIImage(named: "default_header_80")
//                }
                let _ = cell.imgView.cod_loadHeaderByCache(url: URL.init(string: model.userpic.getHeaderImageFullPath(imageType: 1)))
            }
            cell.title = model.getContactNick()
            cell.titleFont = UIFont.systemFont(ofSize: 17)
            cell.imgView.contentMode = .scaleAspectFit
            
            if indexPath.row == datas.count - 1 {
                cell.isLast = true
            }else{
                cell.isLast = false
            }
            
            let result = CustomUtil.getOnlineTimeStringAndStrColor(with: model)
            cell.placeholer = result.timeStr
            cell.placeholerColor = result.strColor
            
            return cell
        }
        
        return UITableViewCell.init()        
    }
    
    func setAttributeTitle(title: String, imgName: String) -> NSAttributedString {
        let attriStr = NSMutableAttributedString.init(string: NSLocalizedString(title, comment: ""))
        let textAttachment = NSTextAttachment.init()
        let img = UIImage(named: imgName)
        textAttachment.image = img
        textAttachment.bounds = CGRect.init(x: 5, y: -2, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
        let attributedString = NSAttributedString.init(attachment: textAttachment)
        attriStr.append(attributedString)
        return attriStr
    }
}

private extension ContactsViewController {
    
    //创建通讯录
    func contacts(){
        //创建通讯录
        let store = CNContactStore.init();
        //获取授权状态
        let AuthStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts);
        
        //没有授权
        if AuthStatus == CNAuthorizationStatus.notDetermined{
            //用户授权
            store.requestAccess(for: CNEntityType.contacts, completionHandler: { [weak self] (isLgranted, error) in
                guard let `self` = self else { return }
                if isLgranted == true{
                    print("授权成功");
                    DispatchQueue.main.sync {
                        self.navigationController?.pushViewController(CODChooseMobileContactsVC())
                    }
                }else{
                    print("授权失败");
                }
            });
            
        }else if (AuthStatus == .authorized){
            self.navigationController?.pushViewController(CODChooseMobileContactsVC())
        }else{
            let alert = UIAlertController.init(title: CustomUtil.formatterStringWithAppName(str: "您没有授权%@访问通讯录的权限"), message: CustomUtil.formatterStringWithAppName(str: "如果您想使用此功能，需要您在设置中允许%@访问通讯录！"), preferredStyle: .alert)
            let confirmAction = UIAlertAction.init(title: "知道了", style: .default) { (action) in
                
            }
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //新的好友
    func pushNewFriendVC() {
        
        let listModel = CODChatListRealmTool.getChatList(id: NewFriendRosterID)
        
        let ctl = Xinhoo_RosterRequestListViewController(nibName: "Xinhoo_RosterRequestListViewController", bundle: Bundle.main)
        ctl.unRead = listModel?.count ?? 0
        ctl.chatListModel = listModel
        self.navigationController?.pushViewController(ctl, animated: true)
        
    }
    
    //已保存的群组\频道
    func pushSaveChatVC(ctlType: CtlType = .saveGroupType) {
        let ctl = CODSavedGroupChatVC()
        ctl.type = ctlType
        self.navigationController?.pushViewController(ctl)
    }
    
    
    
    func changeSortType() {
        let alert = LGAlertView(viewAndTitle: nil, message: nil, style: .actionSheet, view: self.alertSubView,
                    buttonTitles: [NSLocalizedString("姓名", comment: ""), NSLocalizedString("最后上线时间", comment: "")],
                    cancelButtonTitle: NSLocalizedString("取消", comment: ""),
                    destructiveButtonTitle: nil,
                    actionHandler: { (alertView, index, buttonTitle) in
                        if index == 0 {
                            //按姓名
                            UserManager.sharedInstance.contactSortType = 1
                        }else{
                            //最后上线时间
                            UserManager.sharedInstance.contactSortType = 2
                        }

        }, cancelHandler: nil, destructiveHandler: nil)
        alert.buttonsTitleColorHighlighted = alert.buttonsTitleColor
        alert.cancelButtonTitleColorHighlighted = alert.cancelButtonTitleColor
        alert.cancelButtonBackgroundColorHighlighted = UIColor(hexString: "000000", transparency: 0.1)
        alert.buttonsBackgroundColorHighlighted = UIColor(hexString: "000000", transparency: 0.1)
        alert.showAnimated()

    }
    
    //MARK: -------------------- 接收IQ
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        return true
    }
    
    @objc func selectCtl(){
        perform(#selector(selectCtlTemp), with: nil, afterDelay: 0.05)
    }
    
    @objc func selectCtlTemp(){
        let ctl = UIViewController.current() as? CODCustomTabbarViewController
        ctl?.selectedIndex = 0
    }
}

extension Reactive where Base: ContactsViewController {
    
    var contactSortTypeBinder: Binder<Int> {
        return Binder(base) { (vc, typeValue) in
            guard vc.type == .normal else { return }
            vc.loadData()
        }
    }
    
}
