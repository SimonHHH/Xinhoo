//
//  CreGroupChatViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/21.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Lottie

enum ControllerType :Int {
    case createGroup = 0
    case addMember
    case subtractMember
    case transferAdmin
    case createChannel
    case friendsCcRemindRead
    case friendsCcCanRead
    case multipleVoice
    case multipleVideo
    case requestmore_multipleVoice
    case requestmore_multipleVideo
}

class CreGroupChatViewController: BaseViewController {
    
    var selectedArray: Array<AnyObject>? {
        didSet{
            
            if ctlType == .createChannel || ctlType == .friendsCcRemindRead || ctlType == .friendsCcCanRead {
                return
            }
            let count = (selectedArray?.count ?? 0) + globalSearchSelectedArr.count
            
            if count > 0 {
                rightTextButton.isEnabled = true
            }else{
                rightTextButton.isEnabled = false
            }
        }
    }
    
    /// 被选择的全局搜索到的用户集合
    var globalSearchSelectedArr: Array = [CODSearchResultContact]() {
           didSet{
               
               if ctlType == .createChannel {
                   return
               }
               let count = (selectedArray?.count ?? 0) + globalSearchSelectedArr.count
               if count > 0 {
                   rightTextButton.isEnabled = true
               }else{
                   rightTextButton.isEnabled = false
               }

           }
       }
    
    // 创建时必传
    var ctlType: ControllerType? {
        didSet {
            switch ctlType {
            case .createGroup:
                titleStr = NSLocalizedString("新建群组", comment: "")
            case .addMember :
                titleStr = NSLocalizedString("添加成员", comment: "")
            case .createChannel :
                titleStr = NSLocalizedString("成员", comment: "")
            case .subtractMember :
                titleStr = NSLocalizedString("删除成员", comment: "")
            case .transferAdmin :
                titleStr = NSLocalizedString("选择新的群主", comment: "")
            case .friendsCcRemindRead:
                titleStr = NSLocalizedString("提醒谁看", comment: "")
            case .friendsCcCanRead:
                titleStr = NSLocalizedString("选择联系人", comment: "")
            case .multipleVideo, .multipleVoice, .requestmore_multipleVideo, .requestmore_multipleVoice:
                titleStr = NSLocalizedString("选择通话成员", comment: "")
            default:
                break
            }
        }
    }
    
    var titleStr: String?
    
    /// 已选的语音通话成员集合
    var selctMemberList: Array<String> = []
    
    //最多可选数量
    var maxSelectedCount = 0
    
    //如果是从单聊跳转创建群组时，必传
    var contactModel :CODContactModel?
    
    var isGroupOwner = false

    var channelModel: CODChannelModel?
    var groupChatModel: CODChatGroupType?
    
    var roomID: String? = "0"
    
    var room: String = ""
    
    typealias CreateGroupSuccessCloser = (_ groupChatModel : CODGroupChatModel) -> Void
    typealias CreateChannelSuccessCloser = (_ channelModel : CODChannelModel) -> Void
    typealias SubtractMemberSuccessCloser = () -> Void
    typealias SelectedRemindsSuccess = (_ contactList: [CODContactModel]) -> Void
    
    var createGroupSuccess: CreateGroupSuccessCloser!
    
    var createChannelSuccess: CreateChannelSuccessCloser!
    
    var subtractMemberSuccess: SubtractMemberSuccessCloser!
    
    var selectedRemindsSuccess: SelectedRemindsSuccess!
        
    var groupMemberSelectView: CODGroupMemberSelectView!
    
    lazy var codeAlertView: CODCodeAlertView = {
        let codeview = Bundle.main.loadNibNamed("CODCodeAlertView", owner: self, options: nil)?.first as! CODCodeAlertView
        codeview.confirmBlock = { [weak self] (alertView, codeStr) in
            guard let `self` = self else { return }
            self.requestGlobalSearch(picCode: codeStr, text: self.searchText)
        }
        return codeview
    }()
    
    private var footViewLabel :UILabel?
    
    /// 联系人(群成员)昵称集合
    var stringsToSort = Array<String>()
    /// 索引集合
    var indexArray: Array = [String]()
    /// 联系人(群成员)集合
    var contactListArr :Array = [AnyObject]()
    /// 已排序的联系人(群成员)集合
    var contactSortResultArr: Array = [Array<AnyObject>]()
    
    /// 联系人(群成员)未经过筛选搜索的总集合
    var contactAllArr: Array = [AnyObject]()
    
    /// 被全局搜索到的用户集合
    var globalSearchArr: Array = [CODSearchResultContact]()
    
    var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        switch self.ctlType?.rawValue {
        case 0, 4, 5, 6:
            self.navigationItem.titleView = titleLabView
        default:
            self.navigationItem.title = NSLocalizedString(self.titleStr ?? "", comment: "")
        }
        
        switch self.ctlType {
        case .friendsCcCanRead, .friendsCcRemindRead:
            self.setCancelButton()
        default:
            self.setBackButton()
        }
        
        if self.ctlType == .requestmore_multipleVoice || self.ctlType == .requestmore_multipleVideo {
            self.backButton.setTitleColor(.white, for: .normal)
            self.backButton.setImage(UIImage(named: "button_nav_back_white"), for: .normal)
        }
        
        self.setRightTextButton()
        rightTextButton.isEnabled = false
        switch self.ctlType {
        case .createGroup:
            rightTextButton.setTitle(NSLocalizedString("下一步", comment: ""), for: UIControl.State.normal)
        case .createChannel:
            rightTextButton.setTitle(NSLocalizedString("下一步", comment: ""), for: UIControl.State.normal)
            rightTextButton.isEnabled = true
        case .friendsCcRemindRead, .friendsCcCanRead:
            rightTextButton.setTitle(NSLocalizedString("完成", comment: ""), for: UIControl.State.normal)
            rightTextButton.isEnabled = true
        default:
            rightTextButton.setTitle(NSLocalizedString("确定", comment: ""), for: UIControl.State.normal)
        }
        
        if self.ctlType == .requestmore_multipleVoice ||  self.ctlType == .requestmore_multipleVideo {
            
            self.navigationController?.navigationBar.setTitleFont(UIFont.systemFont(ofSize: 17, weight: .medium), color: .white)
            
            self.navigationController?.navigationBar.tintColor = .white
            
            self.navigationController?.navigationBar.barStyle = .black
            self.setNeedsStatusBarAppearanceUpdate()
            
            rightTextButton.setTitleColor(.white, for: .normal)
            
        }
        
        setUpUI()
        getData()
    }
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tabelV.estimatedRowHeight = 47
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor(hexString: kVCBgColorS)
        tabelV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.delegate = self
        tabelV.dataSource = self
        tabelV.emptyDataSetDelegate = self
        tabelV.emptyDataSetSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    fileprivate lazy var globalSearchTableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tabelV.estimatedRowHeight = 47
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor(hexString: kVCBgColorS)
        tabelV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.delegate = self
        tabelV.dataSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    lazy var titleLabView: UILabel = {
        let lab = UILabel.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth-140, height: 22))
        lab.textAlignment = .center
        lab.text = NSLocalizedString(self.titleStr!, comment: "")
        lab.textColor = UIColor(hexString: kNavTitleColorS)
        lab.font = UIFont(name: "PingFang-SC-Medium", size: 17.0)
        return lab
    }()
    
    override func navRightTextClick() {
        switch self.ctlType {
        case .createGroup:
            self.createGroupChat()
        case .addMember:
            self.addGroupMember()
        case .subtractMember:
            self.subtractMember()
        case .transferAdmin:
            self.addAdmins()
        case .createChannel:
            self.createChannelNextStep()
            break
        case .friendsCcRemindRead, .friendsCcCanRead:
            self.selectedRemindsList()
            break
        case .multipleVideo, .multipleVoice:
            self.sendMultipleCall()
            break
        case .requestmore_multipleVideo, .requestmore_multipleVoice:
            self.sendRequestMoreMultipleCall()
            break
        default:
            break
        }
        
    }

    override func navCancelClick() {
        self.navBackClick()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
}

extension CreGroupChatViewController{
    func isContactType() -> Bool {
        switch self.ctlType {
        case .createGroup, .createChannel, .addMember, .friendsCcRemindRead, .friendsCcCanRead:
            return true
        default:
            return false
        }
    }
    
    func needToUpdateNavTitle() -> Bool {
        switch self.ctlType {
        case .createGroup, .createChannel, .friendsCcRemindRead, .friendsCcCanRead, .multipleVoice, .multipleVideo, .requestmore_multipleVoice, .requestmore_multipleVideo:
            return true
        default:
            return false
        }
    }
    
    func getData() {
        // 创建群组和添加群成员都是拿自己的联系人列表
        if self.isContactType() {
            if let model = self.contactModel {
                model.isUnableClick = true
                self.selectedArray = [model]
                self.updateNavtitle(self.titleStr!)
                self.groupMemberSelectView.addDataSource(obj: model)
            }
            
            if let selectArr = self.selectedArray, selectArr.count > 0 {
                self.groupMemberSelectView.setDataSource(objs: selectArr)
            }
            
            if let contactList = self.getContactData() {
                guard contactList.count > 0 else {
                    return
                }
                
                /// 如果是添加成员，取出成员列表遍历其中的成员的username 与 contactmodel的jid 比较，
                /// 如果一样，该contactModel.isUnableClick = true,使该Contact在tableview中无法选择。因该contact已在成员列表中
                if self.ctlType == .addMember {
                    
                    if let model = self.groupChatModel {
                        let memberList = model.member
                        guard memberList.count > 0 else {
                            return
                        }
                        
                        for contact in contactList {
                            if contact.jid.contains("cod_60000000") || contact.jid.contains(UserManager.sharedInstance.loginName!) {
                                continue
                            }
                            
                            
                            if model.isMember(by: contact.username) {
                                contact.isUnableClick = true
                            }
                            
//                            for member in memberList {
//                                if contact.jid == member.jid {
//                                    contact.isUnableClick = true
//                                }
//                            }
                            self.stringsToSort.append(contact.getContactNick())
                            self.contactListArr.append(contact)
                        }
                        self.contactAllArr = self.contactListArr
                    }
                    
                }else{
                    
                    for contact in contactList {
                        if contact.jid.contains("cod_60000000") || contact.jid.contains(UserManager.sharedInstance.loginName!) {
                            continue
                        }
                        if contact.name.count <= 0 {
                            continue
                        }
                        if self.contactModel?.jid == contact.jid {
                            contact.isUnableClick = true
                        }
                        self.stringsToSort.append(contact.getContactNick())
                        self.contactListArr.append(contact)
                    }
                    self.contactAllArr = self.contactListArr
                }
                
                
                
                if let indexStringS = ChineseString.indexArray(self.stringsToSort) as? [String]   {
                    self.indexArray = indexStringS
                }
                
                if let contactResults = ChineseString.modelSortArray(self.contactListArr) as? [Array<CODContactModel>] {
                    self.contactSortResultArr = contactResults
                }
                
            }
        }else{

            //否则取该群的群成员列表
            if let model = self.groupChatModel {
                var memberList = model.member.toArray()
                guard memberList.count > 0 else {
                    return
                }
                
                if self.ctlType == .transferAdmin {
                    memberList = memberList.filter { $0.userTypeEnum != .bot }
                }
                
                let memberId = CODGroupMemberModel.getMemberId(roomId: model.chatId, userName: UserManager.sharedInstance.loginName!)
                guard let meMember = CODGroupMemberRealmTool.getMemberById(memberId) else {
                    return
                }
                var isGroupOwner = false
                if meMember.userpower == 10 {
                    isGroupOwner = true
                }
                
                for member in memberList {
                    if member.jid == UserManager.sharedInstance.jid && self.ctlType != .multipleVoice && self.ctlType != .multipleVideo && self.ctlType != .requestmore_multipleVoice && self.ctlType != .requestmore_multipleVideo {
                        continue
                    }
                    if !isGroupOwner && self.ctlType != .multipleVoice && self.ctlType != .multipleVideo && self.ctlType != .requestmore_multipleVoice && self.ctlType != .requestmore_multipleVideo {
                        if member.userpower <= 20 {
                            continue
                        }
                    }
                    
//                    if self.ctlType == .requestmore_multipleVoice || self.ctlType == .requestmore_multipleVideo {
//
//                        print(member.username)
//                        if selctMemberList.contains(member.jid) {
//                            continue
//                        }
//                    }
                    
                    
                    self.stringsToSort.append(member.getMemberNickName())
                    self.contactListArr.append(member)
                }
                self.contactAllArr = self.contactListArr
                
                if let indexStringS = ChineseString.indexArray(self.stringsToSort) as? [String]   {
                    self.indexArray = indexStringS
                }
                
                if let contactResults = ChineseString.modelSortArray(self.contactListArr) as? [Array<CODGroupMemberModel>] {
                    self.contactSortResultArr = contactResults
                }
            }
        }
        if self.contactAllArr.count > 0{
            tableView.tableFooterView = self.createFooterView()
            self.footViewLabel?.text = String(format: NSLocalizedString("%d位联系人", comment: ""), self.contactAllArr.count)
        }
    }
    
    func getContactData() -> Results<CODContactModel>? {
        if self.ctlType == .friendsCcCanRead || self.ctlType == .friendsCcRemindRead {
            return CODContactRealmTool.getContactsNotBlackList()
        }else{
            return CODContactRealmTool.getContactsNotBlackListContainTempFriends()
        }
    }
    
    func setUpUI() {

        if self.needToUpdateNavTitle() {
            updateNavtitle(self.titleStr!)
            if let model = self.contactModel {
                self.selectedArray = [model]
            }
        }
        
        groupMemberSelectView = CODGroupMemberSelectView(frame: CGRect.zero)
        groupMemberSelectView.backgroundColor = .clear
        groupMemberSelectView.delegate = self
        groupMemberSelectView.searchDelegate = self
        self.view.addSubview(groupMemberSelectView)
        groupMemberSelectView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
//            make.right.equalToSuperview().offset(-80)
            make.height.equalTo(44)
        }
                
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(groupMemberSelectView.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
        
        if self.ctlType == .createGroup || self.ctlType == .createChannel || self.ctlType == .addMember  {
            self.view.addSubview(globalSearchTableView)
            globalSearchTableView.snp.makeConstraints { (make) in
                make.top.equalTo(groupMemberSelectView.snp.bottom)
                make.left.right.equalTo(self.view)
                make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
            }
            self.view.bringSubviewToFront(tableView)
        }
        
    }
    
    func updateNavtitle(_ title: String) {
        let count = self.selectedArray?.count ?? 0 + self.globalSearchSelectedArr.count
        self.navigationItem.title = NSLocalizedString(title, comment: "") + " " + "\(count)"
        let attriStr = NSAttributedString(string: NSLocalizedString(title, comment: ""), attributes: [NSAttributedString.Key.font : UIFont(name: "PingFang-SC-Medium", size: 17.0)!, NSAttributedString.Key.foregroundColor : UIColor(hexString: kNavTitleColorS)!])
        
        let attriCountStr = NSAttributedString(string: " \(count)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0), NSAttributedString.Key.foregroundColor : UIColor(hexString: kSubTitleColors)!])
        self.titleLabView.attributedText = attriStr + attriCountStr
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
    
    func hiddenFooterView(hidden: Bool)  {
        tableView.tableFooterView?.isHidden = hidden
    }
    
//    @objc func letSearchFieldStartEdit() {
//        self.groupMemberSearchView.textField.becomeFirstResponder()
//    }
}

extension CreGroupChatViewController: UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let model = self.contactSortResultArr[indexPath.section][indexPath.row]
            
            if self.selectedArray == nil {
                self.selectedArray = Array<AnyObject>()
            }
            
            if self.isContactType() {
                if let contactModel = model as? CODContactModel {
                    if var array = self.selectedArray as? [CODContactModel] {
                        for i in 0..<array.count {
                            let model = array[i]
                            if model.jid == contactModel.jid {
                                array.remove(at: i)
                                self.groupMemberSelectView.deleteDataSource(object: model)
                                self.selectedArray = array
                                tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                                if self.needToUpdateNavTitle() {
                                    updateNavtitle(self.titleStr!)
                                }
                                return
                            }
                        }
                        
                    }
                }
            }else{
                if let groupMemberModel = model as? CODGroupMemberModel {
                    if ctlType == .transferAdmin {
                        
                        guard let groupChatModel = self.groupChatModel else {
                            return
                        }
                        
                        let alert = UIAlertController(title: String(format: NSLocalizedString("确定选择“%@”为新的群主，你将自动放弃群主身份", comment: ""), groupMemberModel.name), message: nil, preferredStyle: UIAlertController.Style.alert)
                        let action1 = UIAlertAction(title: "取消", style: UIAlertAction.Style.default, handler: nil)
                        let action2 = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
                            XMPPManager.shareXMPPManager.transferGroupAdmin(roomId: groupChatModel.chatId, newAdminName: groupMemberModel.jid, success: { (successModel, nameStr) in
                                if nameStr == "transferOwner" {
                                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                                    if let ctls = self.navigationController?.viewControllers {
                                        for ctl in ctls {
                                            let className = String(describing: ctl.self)
                                            if className.contains("MessageViewController") {
                                                self.navigationController?.popToViewController(ctl, animated: true)
                                            }
                                        }
                                    }
                                }
                                
                            }, fail: { (errorModel) in
                                CODProgressHUD.showErrorWithStatus(errorModel.msg)
                            })
                        })
                        alert.addAction(action1);alert.addAction(action2)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    if var array = self.selectedArray as? [CODGroupMemberModel] {
                        for i in 0..<array.count {
                            let model = array[i]
                            if model == groupMemberModel {
                                array.remove(at: i)
                                self.groupMemberSelectView.deleteDataSource(index: i)
                                self.selectedArray = array
                                tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                                if self.needToUpdateNavTitle() {
                                    updateNavtitle(self.titleStr!)
                                }
                                return
                            }
                        }
                        
                    }
                }
            }
            if self.checkSelectedMaxCountLimited() {
                return
            }
            self.groupMemberSelectView.addDataSource(obj: model)
            self.selectedArray?.append(model)
            
            self.groupMemberSelectView.clearTextField()
            self.searchFieldText(text: "")
            if self.needToUpdateNavTitle() {
                self.updateNavtitle(self.titleStr!)
            }
        }else{
            let contact = self.globalSearchArr[indexPath.row]
            for model in self.globalSearchSelectedArr {
                if model.userid == contact.userid {
                    self.globalSearchSelectedArr.removeAll { (contact) -> Bool in
                        return contact.userid == model.userid
                    }
                    self.groupMemberSelectView.deleteDataSource(object: contact)
                    tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    if self.ctlType == .createGroup || self.ctlType == .createChannel {
                        updateNavtitle(self.titleStr!)
                    }
                    return
                }
            }
            if self.checkSelectedMaxCountLimited() {
                return
            }
            self.globalSearchSelectedArr.append(contact)
            self.groupMemberSelectView.addDataSource(obj: contact)
            self.groupMemberSelectView.clearTextField()
            self.searchFieldText(text: "")
            if self.ctlType == .createGroup || self.ctlType == .createChannel {
                self.updateNavtitle(self.titleStr!)
            }
        }
        
    }
    
    func checkSelectedMaxCountLimited() -> Bool {
        guard maxSelectedCount > 0 && (self.selectedArray?.count ?? 0) + self.globalSearchSelectedArr.count + selctMemberList.count < maxSelectedCount
            || maxSelectedCount == 0 else {
                let alert = UIAlertController.init(title: nil, message: String(format: "最多选择%d 人", self.maxSelectedCount), preferredStyle: .alert)
                let confirmAction = UIAlertAction.init(title: "知道了", style: .default, handler: nil)
                alert.addAction(confirmAction)
                self.present(alert, animated: true, completion: nil)
                return true
        }
        return false
    }
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODGroupMemberCell.self, forCellReuseIdentifier: "CODGroupMemberCell")
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView == self.tableView {
            return self.indexArray
        }else{
            return nil
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return self.indexArray.count
        }else{
            return 1
        }
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView == self.tableView {
            
            return self.contactSortResultArr[section].count
        }else{
            return self.globalSearchArr.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell: CODGroupMemberCell = tableView.dequeueReusableCell(withIdentifier: "CODGroupMemberCell", for: indexPath) as! CODGroupMemberCell
        var datas = [AnyObject]()
        if tableView == self.tableView {
            datas = self.contactSortResultArr[indexPath.section]
        }else{
            datas = self.globalSearchArr
        }
        
        if indexPath.row == datas.count - 1 {
            cell.isLast = true
        }else{
            cell.isLast = false
        }
        
        if tableView == self.globalSearchTableView {
            //全局搜索模式
            let model :CODSearchResultContact = self.globalSearchArr[indexPath.row]
            cell.selectType = .unselected
            
            if self.globalSearchArr.count > 0 {
                for contactModel in self.globalSearchSelectedArr {
                    if model.userid == contactModel.userid {
                        cell.selectType = .selected
                    }
                }
            }
            if model.type == "B" {
                cell.attribuTitle = CustomUtil.getBotAttriString(botName: model.name)
            }else{
                cell.title = model.name
            }
            cell.placeholder = "@\(model.userid)"
            cell.cellIndexPath = indexPath
            cell.urlStr = model.pic
            if (model.isUnableClick) {
                cell.isUserInteractionEnabled = false
                cell.selectType = .unableSelected
            }else{
                cell.isUserInteractionEnabled = true
            }
            return cell
        }
        
        //类型转换成功，就是创建群或者是添加成员
        if let model :CODContactModel = self.contactSortResultArr[indexPath.section][indexPath.row] as? CODContactModel {
            cell.selectType = .unselected
            
            if self.selectedArray != nil && (self.selectedArray?.count)! > 0 {
                if let array = self.selectedArray as? [CODContactModel] {
                    for contactModel in array {
                        if model.jid == contactModel.jid {
                            cell.selectType = .selected
                        }
                    }
                }
            }
            
            cell.title = model.getContactNick()
            let result = CustomUtil.getOnlineTimeStringAndStrColor(with: model)
            cell.placeholder = result.timeStr
            cell.placeholerColor = result.strColor
            cell.cellIndexPath = indexPath
            cell.urlStr = model.userpic
            
            if (model.isUnableClick) {
                cell.isUserInteractionEnabled = false
                cell.selectType = .unableSelected
            }else{
                cell.isUserInteractionEnabled = true
            }
            
            return cell
        }
        
        // 类型转换成功，就是删除成员
        if let model :CODGroupMemberModel = self.contactSortResultArr[indexPath.section][indexPath.row] as? CODGroupMemberModel {
            
            // 如果是转让群主，cell的selectType为none
            if ctlType == .transferAdmin {
                cell.selectType = .none
            }else{
                cell.selectType = .unselected
                if self.selectedArray != nil && (self.selectedArray?.count)! > 0 {
                    if let array = self.selectedArray as? [CODGroupMemberModel] {
                        for member in array {
                            if model.jid == member.jid {
                                cell.selectType = .selected
                            }
                        }
                    }
                }
            }
            
            cell.title = model.getMemberNickName()
            let result = CustomUtil.getOnlineTimeStringAndStrColor(with: model)
            cell.placeholder = result.timeStr
            cell.placeholerColor = result.strColor
            cell.cellIndexPath = indexPath
            cell.urlStr = model.userpic
            
            switch self.ctlType {
            case .multipleVideo, .multipleVoice, .requestmore_multipleVideo, .requestmore_multipleVoice:
                
                if selctMemberList.contains(model.jid) {
                    cell.isUserInteractionEnabled = false
                    cell.selectType = .unableSelected
                }else{
                    cell.isUserInteractionEnabled = true
                }
                
                break
            default:
                break
            }
            
            return cell
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var textString = ""
        if tableView == self.tableView {
            textString = self.indexArray[section]
        }else{
            textString = "全局搜索"
        }
        let textFont = UIFont.systemFont(ofSize: 12)
        let sectionHeight: CGFloat = 28
        let textLabel = UILabel.init(frame: CGRect(x: 14, y: 0, width: KScreenWidth-28, height: sectionHeight))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.font = textFont
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(hexString: kSectionHeaderTextColorS)
        textLabel.text = textString

        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
        bgView.backgroundColor = UIColor(hexString: kVCBgColorS)
        bgView.addSubview(textLabel)
        return bgView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let sectionHeight: CGFloat = 0.01
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
        bgView.backgroundColor = UIColor.clear

        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 28.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 100))
        
        let lottieView = AnimationView.init()
        let animation = Animation.filepath(Bundle.main.path(forResource: "404", ofType: "json")!, animationCache: nil)
        lottieView.animation = animation
        lottieView.loopMode = .loop
        lottieView.play()
        view.addSubview(lottieView)
        lottieView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 55, height: 65))
            make.centerX.equalToSuperview()
        }
        var notes = ""
        if self.ctlType == .transferAdmin {
            notes = NSLocalizedString("当前群聊无其他成员，暂时无法\n进行管理权限转让", comment: "")
        }else{
            notes = CustomUtil.formatterStringWithAppName(str:"您暂时还没有加入%@的朋友\n推荐朋友下载一起畅聊吧")
        }
        let lab = UILabel.init(frame: .zero)
        lab.text = notes
        lab.numberOfLines = 0
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textAlignment = .center
        lab.textColor = UIColor.init(hexString: kWeakTitleColorS)
        view.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.top.equalTo(lottieView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        return view
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        if contactAllArr.count > 0 {
            return false
        }
        scrollView.emptyDataSetView { [weak self] (emptyDataSetView) in
            guard let self = self else { return }
            // 计算y轴全屏居中
            emptyDataSetView.y = KScreenHeight/2-(kSafeArea_Top+kNavBarHeight+self.groupMemberSelectView.height)-emptyDataSetView.height/2
        }
        return true
    }
}

var selectViewContentSizeWidth: CGFloat = 0.0

var selectViewContentSizeHeight: CGFloat = 0.0
extension CreGroupChatViewController : CODGroupMemberSelectDelegate{
    
    func didSelectDeleteMember(modelArr: Array<AnyObject>) {
        selectedArray = modelArr as? Array<CODContactModel>
        self.tableView.reloadData()
        if self.needToUpdateNavTitle() {
            updateNavtitle(self.titleStr!)
        }
    }
    
    func didSelectDeleteSearchContact(searchUser: CODSearchResultContact) {
        self.globalSearchSelectedArr.removeAll { (searchUserModel) -> Bool in
            return searchUserModel.userid == searchUser.userid
        }
        if self.needToUpdateNavTitle() {
            updateNavtitle(self.titleStr!)
        }
        
    }
    
    func collectionViewsContentSizeDidChange(height: CGFloat) {
        
        print("self.groupMemberSelectView.contentHeight :\(height)")
    }
}
extension CreGroupChatViewController : CODGroupMemberSearchCellDelegate{
    func selectViewDeleteMember() {
        if (selectedArray?.count ?? 0) > 0 {
            selectedArray?.removeLast()
            tableView.reloadData()
            if self.needToUpdateNavTitle() {
                updateNavtitle(self.titleStr!)
            }
        }
    }
    
    func selectViewSearchTextDidEditChange(field: UITextField) {
        print("搜索内容：\(field.text ?? "nil")")
        
        guard let text = field.text else {
            return
        }
        self.searchText = text
        self.searchFieldText(text: text)
    }
    
    func searchFieldText(text: String) {
        let searchStr = text.removeAllSapce
        var searchStrNoAt: String? = nil
        var strCount = searchStr.count
        if searchStr.starts(with: "@") {
            searchStrNoAt = searchStr.removingPrefix("@")
            strCount = searchStrNoAt!.count
        }
        
        self.view.bringSubviewToFront(self.tableView)
        self.stringsToSort.removeAll()
        self.indexArray.removeAll()
        self.contactListArr.removeAll()
        self.contactSortResultArr.removeAll()
        
        if strCount > 0 {
            let arr = self.contactAllArr.filter { (object) -> Bool in
                if self.isContactType() {
                    if let model :CODContactModel = object as? CODContactModel {
                        return model.getContactNick().contains((searchStrNoAt != nil) ? searchStrNoAt! : searchStr, caseSensitive: false)
                    }
                } else {
                    if let model :CODGroupMemberModel = object as? CODGroupMemberModel {
                        return model.getMemberNickName().contains((searchStrNoAt != nil) ? searchStrNoAt! : searchStr, caseSensitive: false)
                    }
                }
                return false
            }
            
            if arr.count > 0 {
                if self.isContactType() {
                    if let objects = arr as? Array<CODContactModel> {
                        for model in objects {
                            self.contactListArr.append(model)
                            self.stringsToSort.append(model.getContactNick())
                        }
                    }
                } else {
                    if let objects = arr as? Array<CODGroupMemberModel> {
                        for model in objects {
                            self.contactListArr.append(model)
                            self.stringsToSort.append(model.getMemberNickName())
                        }
                    }
                }
            }else{
                //搜索不到内容不显示，预留做其他处理
            }
            self.hiddenFooterView(hidden: true)
        }else{
            if self.isContactType() {
                if let objects = self.contactAllArr as? Array<CODContactModel> {
                    for model in objects {
                        self.contactListArr.append(model)
                        self.stringsToSort.append(model.getContactNick())
                    }
                }
            } else {
                if let objects = self.contactAllArr as? Array<CODGroupMemberModel> {
                    for model in objects {
                        self.contactListArr.append(model)
                        self.stringsToSort.append(model.getMemberNickName())
                    }
                }
            }
            self.hiddenFooterView(hidden: false)
        }
        
        
        if let indexStringS = ChineseString.indexArray(self.stringsToSort) as? [String]   {
            self.indexArray = indexStringS
        }
        
        if let contactResults = ChineseString.modelSortArray(self.contactListArr) as? [Array<AnyObject>] {
            self.contactSortResultArr = contactResults
        }
        
        self.tableView.reloadData()
        
        if searchStrNoAt != nil && strCount > 4 {
            self.requestGlobalSearch(text: text)
        }
        
    }
    
    func requestGlobalSearch(picCode: String? = nil, text: String) {
        var searchStr = text.removeAllSapce
        if searchStr.starts(with: "@") {
            searchStr = searchStr.removingPrefix("@")    //有问题
        }
        if searchStr.count < 5 {
            return
        }
        self.view.bringSubviewToFront(self.globalSearchTableView)
        self.globalSearchArr.removeAll()
        XMPPManager.shareXMPPManager.globalSearch(search: searchStr, picCode: picCode, success: { [weak self] (model, nameStr) in
            if nameStr == COD_globalSearch {
                
                guard model.success == true else {
                    switch model.code {
                    case 0:
                        self?.codeAlertView.vDismiss()
                    case 10091:
                        self?.codeAlertView.errorStr = "*验证码已失效，请重试"
                    case 10090:
                        self?.codeAlertView.errorStr = "*输入错误，请重试"
                    case 10093:
                        self?.codeAlertView.vShow()
                    case 40001:
                        CODProgressHUD.showWarningWithStatus("搜索已达上限")
                    default:
                        break
                    }
                    self?.globalSearchTableView.reloadData()
                    return
                }
                self?.codeAlertView.vDismiss()
                
                let contactArr = JSON(model.data as Any).arrayObject
                if contactArr?.count ?? 0 <= 0 {
                    return
                }
                var contactArrTemp: Array<CODSearchResultContact> = []
                for dic in contactArr! {
                    guard let dicTemp = JSON(dic).dictionaryObject else {
                        continue
                    }
                    if let contactModel = CODSearchResultContact.deserialize(from: dicTemp) {
                        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: contactModel.pic, complete: nil)
                        if contactModel.username == UserManager.sharedInstance.loginName {
                            continue
                        }
                        if contactModel.type != "U" && contactModel.type != "B" {
                            continue
                        }
                        if let model = self?.groupChatModel {
                            let memberList = model.member
                            for member in memberList {
                                if contactModel.username == member.username {
                                    contactModel.isUnableClick = true
                                }
                            }
                        }
                        contactArrTemp.append(contactModel)
                    }else{
                        print("解析出错")
                    }
                }
                self?.globalSearchArr = contactArrTemp
                self?.globalSearchTableView.reloadData()
            }
        }) { (error) in
            CODProgressHUD.showErrorWithStatus("全局搜索失败")
        }
        
        
        
        
    }
}

extension CreGroupChatViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}
