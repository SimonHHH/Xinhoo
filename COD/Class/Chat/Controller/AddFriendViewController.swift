//
//  AddFriendViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/21.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Contacts
import Lottie

class AddFriendViewController: BaseViewController {
    
    let iconDicArr = NSArray(array: [
        [["img":"scan_icon","title":"扫一扫"],["img":"invite_friends","title":"邀请朋友"]],
        [["img":"add_friend_qrcode","title":"我的二维码"]]])
        as! [Array<NSDictionary>]
    
    private var searchDatas:[CODChatPersonModel] = [CODChatPersonModel]() ///搜索的数据
    private var isSearch:Bool = false
    private let searchPlaceholder = "请输入手机号码或用户名"
    
    var searchStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.title = NSLocalizedString("添加联系人", comment: "")
//        self.setBackButton()
        self.definesPresentationContext = true
        
        self.tableView.register(CODChoosePersonCell.self, forCellReuseIdentifier: "CODChoosePersonCell")
        self.searchTableView.register(CODChooseMobileContactCell.self, forCellReuseIdentifier: "CODChooseMobileContactCellID")
        
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.searchTableView)
//        self.view.addSubview(self.view_back)
        
        self.addSnpkit()
//        self.searchBar.setPositionAdjustment(UIOffset.init(horizontal: (KScreenWidth - self.getSearchBarPlaceholderWidth())/2, vertical: 0), for: UISearchBar.Icon.search)
//        self.searchBarTextDidBeginEditing(self.searchBar)
        self.searchBar.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.searchBar.becomeFirstResponder()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
//        self.searchBarCancelButtonClicked(self.searchBar)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    fileprivate lazy var searchBar: CODSearchBar_BottomLine = {
        let searchBar = CODSearchBar_BottomLine(frame: CGRect.zero)
        searchBar.backgroundColor = UIColor(hexString: kVCBgColorS)
        searchBar.barTintColor = UIColor.init(hexString: kVCBgColorS)
        searchBar.tintColor = UIColor.init(hexString: kBlueTitleColorS)
        searchBar.placeholder = searchPlaceholder
        searchBar.customTextField?.font = UIFont.systemFont(ofSize: 14)
        searchBar.customTextField?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
        searchBar.delegate = self
        searchBar.customTextField?.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControl.Event.editingChanged)
        
        return searchBar
    }()
    
    fileprivate lazy var codeAlertView: CODCodeAlertView = {
        let codeview = Bundle.main.loadNibNamed("CODCodeAlertView", owner: self, options: nil)?.first as! CODCodeAlertView
        codeview.confirmBlock = { [weak self] (alertView, codeStr) in
            self?.searchFriend(picCode: codeStr)
        }
        return codeview
    }()
    
    //搜索的笼罩视图
//    fileprivate lazy var view_back: UIView = {
//        let view_back = UIView(frame: CGRect.zero)
//        view_back.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
//        view_back.alpha = 0;
//        return view_back
//    }()
    
    //搜索的显示视图
    fileprivate lazy var searchTableView:UITableView = {
        let searchTableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        searchTableView.isHidden = true
        searchTableView.tag = 1001
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.backgroundColor = UIColor.white
        searchTableView.estimatedRowHeight = 80
        searchTableView.rowHeight = UITableView.automaticDimension
        searchTableView.estimatedSectionHeaderHeight = 0
        searchTableView.estimatedSectionFooterHeight = 0
        searchTableView.emptyDataSetSource = self
        searchTableView.tableHeaderView =  UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        searchTableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            searchTableView.contentInsetAdjustmentBehavior = .never
        }
        return searchTableView
    }()
    
    ///当前的位置信息视图
    fileprivate lazy var tableView:UITableView = {
        let mainTableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        mainTableView.tag = 1000
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.backgroundColor = UIColor.white
        mainTableView.estimatedRowHeight = 80
        mainTableView.rowHeight = UITableView.automaticDimension
        mainTableView.estimatedSectionHeaderHeight = 0
        mainTableView.estimatedSectionFooterHeight = 0
        mainTableView.tableHeaderView =  UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        mainTableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            mainTableView.contentInsetAdjustmentBehavior = .never
        }
        
        return mainTableView
    }()
    
    fileprivate func addSnpkit(){
        searchBar.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view).offset(KNAV_STATUSHEIGHT)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        })
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo((self.searchBar.snp.bottom)).offset(0)
            make.bottom.equalToSuperview()
        }

        searchTableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.tableView)
        }
    }
}

extension AddFriendViewController :UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.tag == 1000{
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    let ctl = MeScanViewController()
                    self.navigationController?.pushViewController(ctl, animated: true)
                }else if indexPath.row == 1 {
                    self.contacts()
                }
            }
            if indexPath.section == 1{
                if indexPath.row == 0{
                    let ctl = CODMyQRcodeController()
                    self.navigationController?.pushViewController(ctl, animated: true)
                }
            }
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        }else{
            let model = searchDatas[indexPath.row]
            self.pushToDetailVC(model: model)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.sectionHeaderHeight(tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.sectionHeaderView(tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func sectionHeaderHeight(_ tableView: UITableView) -> CGFloat {
        if tableView.tag == 1000 {
            return 14.0
        }else{
            if searchDatas.count > 0 {
                return 20.0
            }else{
                return 0.01
            }
        }
    }
    
    func sectionHeaderView(_ tableView: UITableView) -> UIView {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: kScreenWidth, height: self.sectionHeaderHeight(tableView)))
        view.backgroundColor = UIColor(hexString: kVCBgColorS)
        if tableView.tag != 1000, searchDatas.count > 0 {
            let lab = UILabel(text: NSLocalizedString("添加联系人", comment: ""))
            lab.font = UIFont.boldSystemFont(ofSize: 12.0)
            lab.textColor = UIColor(hexString: kWeakTitleColorS)
            view.addSubview(lab)
            lab.snp.makeConstraints { (make) in
                make.leading.equalTo(15.0)
                make.centerY.equalToSuperview()
            }
        }
        return view
    }
}

extension AddFriendViewController :UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1000{
            return iconDicArr.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 1000{
            return iconDicArr[section].count
        }else{
            return self.searchDatas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 1000{
            let arr = iconDicArr[indexPath.section]
            let dic :Dictionary = arr[indexPath.row] as! Dictionary<String ,String>
            let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCell") as! CODChoosePersonCell
            cell.iconImage = UIImage(named: dic["img"]!)
            cell.title = dic["title"]
            cell.titleFont = UIFont.systemFont(ofSize: 15.0)
            cell.imgView.contentMode = .center
            if indexPath.row == arr.count-1 && arr != iconDicArr.last {
                cell.isLast = true
            }else{
                cell.isLast = false
            }

            cell.placeholer = ""
            cell.titleColor = UIColor.init(hexString: "367CDE")!
            return cell
        }else{
            let cell: CODChooseMobileContactCell = tableView.dequeueReusableCell(withIdentifier: "CODChooseMobileContactCellID", for: indexPath) as! CODChooseMobileContactCell
            let model = self.searchDatas[indexPath.row]

            cell.isLast = false
            cell.title = model.name
            cell.delegate = self
            cell.cellIndexPath = indexPath
//            let pre = NSPredicate.init(format: "SELF MATCHES %@", "^[A-Za-z]+$")  //判断是否字母开头
            if searchStr.caseInsensitiveCompare((model.userdesc ?? "") as String) == ComparisonResult.orderedSame  {
                if let userdesc = model.userdesc, userdesc.count > 0 {
                    cell.placeholer = String(format: "@%@", userdesc)
                }else{
                    cell.placeholer = String(format: "@%@", searchStr)
                }
            }else{
                if let tel = model.tel, tel.count > 0 {
                    cell.placeholer = String(format: "%@", tel)
                }else{
                    cell.placeholer = searchStr
                }
            }
            
            if model.tojid == (kCloudJid + XMPPSuffix) {
                cell.iconImage = UIImage(named: model.userpic ?? "")
                cell.isAdd = model.isAdd
            }else if UserManager.sharedInstance.loginName?.contains(model.username ?? "") ?? false {
                cell.iconImage = UIImage(named: "cloud_disk_icon")
                cell.title = "我的云盘"

                cell.isAdd  = nil
            }else{
                cell.iconUrlString = model.userpic
                cell.isAdd = model.isAdd
            }
            

            return cell
            
        }
        
    }
        
}

extension AddFriendViewController: EmptyDataSetSource {
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 100+(KScreenHeight-self.tableView.height)))
        
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
        
        let lab = UILabel.init(frame: .zero)
        lab.text = NSLocalizedString("没有找到您要的联系人", comment: "")
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textColor = UIColor.init(hexString: kEmptyTitleColorS)
        view.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.top.equalTo(lottieView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        return view
    }
}

extension AddFriendViewController:UISearchBarDelegate{
    ///开始编辑
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //开始
        self.isSearch = true
//        self.view_back.alpha = 1
//        self.searchTableView.alpha = 1
//        searchBar.setPositionAdjustment(UIOffset.zero, for: UISearchBar.Icon.search)

        UIView.animate(withDuration: 0.25, animations: {
//            self.navigationController?.navigationBar.isHidden = true
//            var view_frame = self.view.frame
//            view_frame.origin.y = CGFloat(KNAV_STATUSHEIGHT)
//            view_frame.size.height = KScreenHeight - CGFloat(KNAV_STATUSHEIGHT)
//            self.view.frame = view_frame
//            self.view.setNeedsLayout()
//            self.view.setNeedsUpdateConstraints()
        }) { (finished) in
            
        }
        searchBar.showsCancelButton = true
        searchBar.setCancelButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        ///取消
        self.navigationController?.popViewController(animated: true)
        
//        searchBar.endEditing(true)
//        searchBar.setShowsCancelButton(false, animated: true)
//        searchBar.text = ""
//
//        self.isSearch = false
////        self.view_back.alpha = 0
////        self.searchTableView.alpha = 0
//        self.searchTableView.isHidden = true
//        self.searchDatas.removeAll()
//        self.searchTableView.reloadData()
//
//        UIView.animate(withDuration: 0.25, animations: {
////            self.navigationController?.navigationBar.isHidden = true
////            var view_frame = self.view.frame
////            view_frame.origin.y = CGFloat(KNAV_HEIGHT)
////            view_frame.size.height = KScreenHeight - CGFloat(KNAV_HEIGHT)
////            self.view.frame = view_frame
//        }) { (finished) in
////            self.navigationController?.navigationBar.isHidden = false
//            searchBar.setShowsCancelButton(false, animated: true)
//        }
    }
    
    /* 点击了清空文字按钮 */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if (searchBar.text?.count)! > 0 {
//            self.searchTableView.alpha = 1
//        }else{
//            self.searchTableView.alpha = 0
//        }
        self.searchTableView.isHidden = true
        self.searchDatas.removeAll()
        self.searchTableView.reloadData()
    }
    /*点击搜索*/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 {
//            self.searchTableView.alpha = 0
            searchTableView.isHidden = true
            return
        }
        searchTableView.isHidden = false
//        self.searchTableView.alpha = 1
        ///搜索模式
        self.isSearch = true
        ///关闭编辑
        searchBar.endEditing(true)
        
        ///搜索好友
        self.searchFriend(picCode: nil)
    }
    ///内容变化
    @objc func textFieldChanged(textField:UITextField) {
        if textField.text?.count == 0 {
            return
        }
        ///搜索模式
        self.isSearch = true
        ///搜索好友
//        self.searchFriend()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        if searchBar.text?.count ?? 0 > 0 {
//            searchBar.setPositionAdjustment(UIOffset.zero, for: UISearchBar.Icon.search)
//        }else{
//            searchBar.setPositionAdjustment(UIOffset.init(horizontal: (KScreenWidth - self.getSearchBarPlaceholderWidth())/2, vertical: 0), for: UISearchBar.Icon.search)
//        }
    }
    
    func getSearchBarPlaceholderWidth() -> CGFloat {
    
        let textWidth = searchPlaceholder.getStringWidth(font: self.searchBar.customTextField?.font ?? UIFont.systemFont(ofSize: 17), lineSpacing: 0, fixedWidth: KScreenWidth)
        
        return 50 + textWidth
    }
}

extension AddFriendViewController{
    
    func searchFriend(picCode: String?) {
        
        let textString = self.searchBar.text?.removeAllSapce ?? ""
        if textString.count == 0 {
            CODProgressHUD.showWarningWithStatus("搜索内容不能为空哦")
            return
        }
//        if textString == UserManager.sharedInstance.userDesc || textString == UserManager.sharedInstance.phoneNum {
//            CODProgressHUD.showWarningWithStatus("请勿搜索自己")
//            return
//        }
        CODProgressHUD.showWithStatus("正在搜索")
        XMPPManager.shareXMPPManager.requestSearchContact(tel: textString, picCode: picCode, success: { (model, nameStr) in
            if nameStr == "searchUserBTN" {
                CODProgressHUD.dismiss()
                self.codeAlertView.vDismiss()
                self.searchDatas.removeAll()
                self.searchStr = textString
//                self.searchBar.text = nil
                if let dataDic = model.data as? Dictionary<String, Any> {
                    if let userArray = dataDic["users"] as?  Array<Dictionary<String, Any>>{
                        for userDic in userArray {
                            let personModel = CODChatPersonModel.deserialize(from: userDic)
                            personModel?.name = personModel?.name?.aes128DecryptECB(key: .nickName)
                            
                            if personModel?.name?.count ?? 0 <= 0 {
                                continue
                            }
                            
                            if personModel?.username == UserManager.sharedInstance.loginName {
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
//                                        self.pushToFriendDetailVC(model: myModel)
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
//                    CODProgressHUD.showWarningWithStatus("暂未查询到此用户")
                }
                self.searchTableView.reloadData()
            }

        }) { [weak self] (model) in
            CODProgressHUD.dismiss()
            switch model.code {
            case 10091:
                self?.codeAlertView.errorStr = "*验证码已失效，请重试"
            case 10090:
                self?.codeAlertView.errorStr = "*输入错误，请重试"
            case 10093:
                self?.codeAlertView.vShow()
            case 40001:
                CODProgressHUD.showWarningWithStatus("搜索已达上限")
            default:
                CODProgressHUD.showErrorWithStatus("搜索失败")
            }
            
        }
        
    }
}

extension AddFriendViewController:CODChooseMobileContactCellDelegate{
    
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
    
    
    func pushToDetailVC(model: CODChatPersonModel){
        if model.tojid == (kCloudJid + XMPPSuffix) || UserManager.sharedInstance.jid.contains(model.username ?? "") {
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
}

