//
//  CODNewFriendVC.swift
//  COD
//
//  Created by 1 on 2019/3/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Contacts
import RealmSwift

class CODNewFriendVC: BaseViewController {
    
    private let searchPlaceholder = "搜索联系人"
    private var searchDatas:[CODChatPersonModel] = [CODChatPersonModel]() ///搜索的数据
    private var isSearch:Bool = false
    
    private var updateModel: CODAddFriendModel?
    
    var addFriendModelNotification: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
        self.navigationItem.title = NSLocalizedString("新的朋友", comment: "")
        self.setRightButton()
        self.rightButton.setImage(UIImage(named: "add_friend_nav_btn"), for: UIControl.State.normal)
        
        self.setUpUI()
        self.getData()
        
        self.addNotification()
        self.definesPresentationContext = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let updateModel = self.updateModel {
            if let index = self.dataSource.firstIndex(of: updateModel) {
                self.tableView.reloadRows(at: [IndexPath.init(row: index, section: 1)], with: UITableView.RowAnimation.automatic)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)        

    }
    
    deinit {
        self.addFriendModelNotification?.invalidate()
    }
    
    var dataSource: Array = [CODAddFriendModel]()
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tabelV.estimatedRowHeight = 47
        tabelV.tag = 1000
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor.clear

        tabelV.delegate = self
        tabelV.dataSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    fileprivate lazy var searchCtl: UISearchController = {
        let searchCtl = UISearchController(searchResultsController: nil)
        searchCtl.searchBar.placeholder = searchPlaceholder
        searchCtl.delegate = self
        searchCtl.searchResultsUpdater = self
        searchCtl.dimsBackgroundDuringPresentation = false
        searchCtl.searchBar.backgroundImage = UIImage()
        searchCtl.searchBar.delegate = self
        searchCtl.view.backgroundColor = UIColor.init(hexString: kVCBgColorS)
        searchCtl.searchBar.barTintColor = UIColor.init(hexString: kVCBgColorS)
        searchCtl.searchBar.tintColor = UIColor.init(hexString: kBlueTitleColorS)
        searchCtl.searchBar.customTextField?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)

        let searchBarTF = searchCtl.searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 14)
        
        searchCtl.view.addSubview(self.searchTableView)
        self.searchTableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kSafeArea_Top+20+55)  //20:statusBar 55:SearchBar
            make.left.right.bottom.equalToSuperview()
        }
        return searchCtl
    }()
    
    //搜索的显示视图
    fileprivate lazy var searchTableView:UITableView = {
        let searchTableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        searchTableView.tag = 1001
        searchTableView.delegate = self
        searchTableView.separatorStyle = .none
        searchTableView.dataSource = self
        searchTableView.backgroundColor = UIColor.init(hexString: kVCBgColorS)
        searchTableView.estimatedRowHeight = 47
        searchTableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 11.0, *) {
            searchTableView.contentInsetAdjustmentBehavior = .never
        }
        searchTableView.register(CODChooseMobileContactCell.self, forCellReuseIdentifier: "CODChooseMobileContactCellID")
        return searchTableView
    }()
    
    override func navRightClick() {
        let ctl = AddFriendViewController()
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
}

extension CODNewFriendVC{
    
    func setUpUI() {
        tableView.tableHeaderView = searchCtl.searchBar
        self.view.addSubview(tableView)

        
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

    }
    
    func getData() {
        let dataArray = CODAddFriendRealmTool.getAddFriendList().sorted(byKeyPath: "sendTime", ascending: false)
        dataSource.removeAll()
        if dataArray.count > 0 {
            for addFriend in dataArray{
                dataSource.append(addFriend)
            }
        }
        self.tableView.reloadData()
    }
    
    func addNotification() {

        addFriendModelNotification = try! Realm.init().objects(CODAddFriendModel.self).observe({ [weak self] (changes: RealmCollectionChange) in
            guard let self = self else {
                return
            }
            switch changes{
                
            case .initial(_):
                break
            case .update(_, _, _, _):
                self.getData()
                break
            case .error(_):
                break
            @unknown default:
                break
            }
        })
    }
    
    func pushToDetailVC(model: CODChatPersonModel){
        if model.tojid == (kCloudJid + XMPPSuffix) || UserManager.sharedInstance.jid.contains(model.username ?? ""){
            let msgCtl = MessageViewController()
            msgCtl.chatType = .privateChat
            msgCtl.toJID = model.tojid!
            if UserManager.sharedInstance.jid.contains(model.username ?? ""){
              msgCtl.toJID = kCloudJid + XMPPSuffix
            }
            msgCtl.chatId = CloudDiskRosterID
            msgCtl.title = NSLocalizedString("我的云盘", comment: "")
            self.navigationController?.pushViewController(msgCtl, animated: true)
            return
        }
        if let contact = CODContactRealmTool.getContactByUsername(username: model.username?.subStringTo(string: "@") ?? "") {
            if contact.isValid {
                CustomUtil.pushToPersonVC(contactModel: contact)
            }else{
                CustomUtil.pushToStrangerVC(type: .searchType, contactModel: contact)
            }
            
        }else{
            let personVC = CODStrangerDetailVC()
            if let name = model.name {
                personVC.name = name
            }
            
            if let userdesc = model.userdesc {
                personVC.userDesc = userdesc
            }
            
            if let userpic = model.userpic {
                personVC.userPic = userpic
            }
            
            if let username = model.username {
                personVC.userName = username
                personVC.jid = username.subStringTo(string: "@") + XMPPSuffix
            }
            
            personVC.type = .searchType
            self.navigationController?.pushViewController(personVC)
        }
    }

    
}

extension CODNewFriendVC: UITableViewDelegate, UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.tag == 1000 {
            if indexPath.section == 0 {
                self.contacts()
            }else{
                let model = dataSource[indexPath.row]
                let jid = model.sender
                
                if let contactModel = CODContactRealmTool.getContactByJID(by: jid), contactModel.isValid == true {
                    CustomUtil.pushToPersonVC(contactModel: contactModel)
                }else{
                    let personVC = CODStrangerDetailVC()
                    guard let setting = model.setting else {
                        return
                    }
                    personVC.name = setting.name
                    personVC.userName = setting.username
                    personVC.userPic = setting.userpic
                    personVC.jid = jid
                    personVC.gender = setting.gender
                    personVC.userDesc = setting.userdesc
                    personVC.type = .groupType
                    self.navigationController?.pushViewController(personVC)
                }
                self.updateModel = model
            }
        }else{
            //搜索结果tableview
            let model = searchDatas[indexPath.row]
            self.pushToDetailVC(model: model)
        }
    }
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODNewFriendCell.self, forCellReuseIdentifier: "CODNewFriendCellID")
        tableView.register(CODChoosePersonCell.self, forCellReuseIdentifier: "CODChoosePersonCellID")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1000 {
            return 2
        }else{
            return 1
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 1000 {
            if section == 0 {
                return 1
            }else{
                return dataSource.count
            }
        }else{
            return self.searchDatas.count
        }

    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView.tag == 1000{
            if indexPath.section == 0 && indexPath.row == 0 {
                let cell:CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
                cell.iconImage = UIImage(named: "invite_friends")
                cell.title = NSLocalizedString("邀请朋友", comment: "")
                cell.titleFont = UIFont.systemFont(ofSize: 15.0)
                cell.titleColor = UIColor.init(hexString: kSubmitBtnBgColorS)!
                cell.imgView.contentMode = .center
                cell.isLast = true
                cell.placeholer = ""
                return cell
            } else {
                let cell: CODNewFriendCell = tableView.dequeueReusableCell(withIdentifier: "CODNewFriendCellID", for: indexPath) as! CODNewFriendCell
                let model = self.dataSource[indexPath.row]
                
                if indexPath.row == self.dataSource.count - 1 {
                    cell.isLast = true
                }else{
                    cell.isLast = false
                }
                cell.title = model.setting?.name
                cell.delegate = self
                cell.cellIndexPath = indexPath
                cell.placeholer = model.setting?.request?.desc
                cell.iconUrlString = model.setting?.userpic
                cell.type = CODNewFriendStatus(rawValue: model.isAddStatus)
                return cell
            }
        }else{
            let cell: CODChooseMobileContactCell = tableView.dequeueReusableCell(withIdentifier: "CODChooseMobileContactCellID", for: indexPath) as! CODChooseMobileContactCell
            let model = self.searchDatas[indexPath.row]
            
            if indexPath.row == self.searchDatas.count - 1 {
                cell.isLast = true
            }else{
                cell.isLast = false
            }
            cell.title = model.name
            cell.delegate = self
            cell.cellIndexPath = indexPath
            cell.placeholer = "@" + (searchCtl.searchBar.text ?? "")
            cell.iconUrlString = model.userpic
            cell.isAdd = model.isAdd

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 1000 {
            let line = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 14.0))
            line.backgroundColor = UIColor.clear
            return line
        }else{
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1000 {
            return 14.0
        }else{
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 1000 {
            return true
        }else{
            return false
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView.tag == 1000 {
            let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "删除") {[weak self] (action, indexPath) in
                self?.deleteContactPerson(row: indexPath.row)
            }
            deleteAction.backgroundColor = UIColor.red
            return [deleteAction]
        }else{
            return nil
        }
    }

}

extension CODNewFriendVC: CODNewFriendCellDelegate{
    
    //列表点击添加按钮
    func cellBtn(indexPath: IndexPath) {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.manager?.status == .notReachable {
            
            let alert = UIAlertController.init(title: "请求失败", message: "请检查您的互联网连接并重试。", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
                
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if self.dataSource.count > indexPath.row {
            let dataModel = self.dataSource[indexPath.row]
            

            CODProgressHUD.showWithStatus("正在请求...")
            
            XMPPManager.shareXMPPManager.requestAcceptRoster(tojid: dataModel.sender) { [weak self] result in
                
                switch result {
                    
                case .success(_):
                    self?.updateModel(dataModel: dataModel)
                    CODProgressHUD.showSuccessWithStatus("已接受")
                    
                case .failure(.iqReturnError(let code, let msg)):
                    switch code {
                    
                    case 30001:
                        CODProgressHUD.showErrorWithStatus("未知错误")
                        break
                    case 30008:
                        CODProgressHUD.showErrorWithStatus("此好友申请已失效")
                        break
                    default:
                        CODProgressHUD.showErrorWithStatus(msg)
                    }
                    
                default:
                    CODProgressHUD.showErrorWithStatus("请求失败，请重新请求")
                }
                
            }
            

        }
    }
  
}

//点击事件
extension CODNewFriendVC{
    
    //创建通讯录
    func contacts(){
        //创建通讯录
        let store = CNContactStore.init();
        //获取授权状态
        let AuthStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts);
        
        //没有授权
        if AuthStatus == CNAuthorizationStatus.notDetermined{
            //用户授权
            store.requestAccess(for: CNEntityType.contacts, completionHandler: { (isLgranted, error) in
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
    
    //删除
    func deleteContactPerson(row: Int) {
        let model = self.dataSource[row]
        CODAddFriendRealmTool.deleteAddFriend(by: model)
        self.getData()
    }
    
    //更新好友
    func updateModel(dataModel :CODAddFriendModel){

        if let contectS = CODAddFriendRealmTool.getContactBySender(requester: dataModel.sender){
            
            for addModel in contectS {
                let model = CODAddFriendModel()
                model.setting = addModel.setting
                model.sender = addModel.sender
                model.isAddStatus = 5
                model.sendTime = addModel.sendTime
                CODAddFriendRealmTool.insertAddFriend(by: model)
                if let contactModel = CODContactRealmTool.getContactByJID(by: model.sender) {
                    CODContactRealmTool.updateContactIsValid(by: contactModel, isValid: true)
                }
            }
            
        }
       
        self.getData()
    }
}


extension CODNewFriendVC: UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        ///取消
        self.searchDatas.removeAll()
        self.searchTableView.reloadData()
    }
    
    /* 点击了清空文字按钮 */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchDatas.removeAll()
        self.searchTableView.reloadData()
    }
    
    /*点击搜索*/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        ///关闭编辑
        searchBar.endEditing(true)
        
        ///搜索好友
        self.searchFriend(picCode: nil)
    }
    
    /*
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.count ?? 0 > 0 {
            searchBar.setPositionAdjustment(UIOffset.zero, for: UISearchBar.Icon.search)
        }else{
            searchBar.setPositionAdjustment(UIOffset.init(horizontal: (KScreenWidth - self.getSearchBarPlaceholderWidth())/2, vertical: 0), for: UISearchBar.Icon.search)
        }
    }
    
    func getSearchBarPlaceholderWidth() -> CGFloat {
        
        let textWidth = searchPlaceholder.getStringWidth(font: searchCtl.searchBar.customTextField?.font ?? UIFont.systemFont(ofSize: 17), lineSpacing: 0, fixedWidth: KScreenWidth)
        
        return 50 + textWidth
    }*/
}

extension CODNewFriendVC{
    
    func searchFriend(picCode: String?) {
        
        let textString = searchCtl.searchBar.text?.removeAllSapce ?? ""
        if textString.count == 0 {
            CODProgressHUD.showWarningWithStatus("搜索内容不能为空哦")
            return
        }
        CODProgressHUD.showWithStatus("正在搜索")
        XMPPManager.shareXMPPManager.requestSearchContact(tel: textString, picCode: picCode, success: { (model, nameStr) in
            if nameStr == "searchUserBTN" {
                CODProgressHUD.dismiss()
                self.searchDatas.removeAll()

                if let dataDic = model.data as? Dictionary<String, Any> {
                    if let userArray = dataDic["users"] as?  Array<Dictionary<String, Any>>{
                        for userDic in userArray{
                            let personModel = CODChatPersonModel.deserialize(from: userDic)
                            personModel?.name = personModel?.name?.aes128DecryptECB(key: .nickName)
                            
                            if userArray.count == 1 && personModel?.username == UserManager.sharedInstance.loginName {
                                if let cloudDiskContact = CODContactRealmTool.getContactById(by: CloudDiskRosterID) {
                                    let cloudDisk = CODChatPersonModel()
                                    cloudDisk.username = cloudDiskContact.username
                                    cloudDisk.name = cloudDiskContact.name
                                    cloudDisk.userdesc = UserManager.sharedInstance.userDesc
                                    cloudDisk.tel = UserManager.sharedInstance.phoneNum
                                    cloudDisk.userpic = CloudDiskIcon
                                    cloudDisk.tojid = cloudDiskContact.jid
                                    cloudDisk.isAdd = nil
                                    self.searchDatas.append(cloudDisk)
                                }
                            }else{
                                if let myModel = CODContactRealmTool.getContactByUsername(username: personModel?.username?.subStringTo(string: "@") ?? "") {
                                    if myModel.isValid {  //已经为好友了，就跳转到详情页面
                                        personModel?.isAdd = true
//                                        self.pushToDetailVC(model: myModel)
                                    }else{
                                        personModel?.isAdd = false
                                    }
                                }else{
                                    personModel?.isAdd = false
                                }
                                self.searchDatas.append(personModel ?? CODChatPersonModel())
                            }
                        }
                    }
                }
                if self.searchDatas.count == 0{
                    CODProgressHUD.showWarningWithStatus("暂未查询到此用户")
                }
                self.searchTableView.reloadData()
            }
            
        }) { (model) in
            
            CODProgressHUD.showErrorWithStatus("搜索失败")
        }
        
    }
}

extension CODNewFriendVC: CODChooseMobileContactCellDelegate{
    
    //列表点击添加按钮
    func contactCellBtn(indexPath: IndexPath) {
        
        if indexPath.row < self.searchDatas.count {
            let model = self.searchDatas[indexPath.row]
            self.addFriend(model: model)
        }
    }

    func addFriend(model: CODChatPersonModel) {
        let verificationVC = CODVerificationApplicationVC()
        verificationVC.type = .searchType
        verificationVC.model =  model
        self.navigationController?.pushViewController(verificationVC)
    }
    
}

extension CODNewFriendVC: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }

}



