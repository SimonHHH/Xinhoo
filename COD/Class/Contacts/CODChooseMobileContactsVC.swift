//
//  CODChooseMobileContactsVC.swift
//  COD
//
//  Created by 1 on 2019/3/14.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import MessageUI
import IQKeyboardManagerSwift
import Contacts
import Lottie
import MessageUI

class CODChooseMobileContactsVC: BaseViewController {
    
    /// 数据源
    private var dataArray = [[CODMobileContactModel]]()
    /// 每个 section 的标题
    private var sectionTitleArray = [String]()
    
    private var indexedCollation = UILocalizedIndexedCollation.current()
    

    let searchCtl = UISearchController(searchResultsController: nil)
    var mobileContactModelList:NSMutableArray = NSMutableArray.init()
    var phoneList:NSMutableArray = NSMutableArray.init()
    var contactDict:NSMutableDictionary = NSMutableDictionary.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
        self.navigationItem.title = NSLocalizedString("邀请朋友", comment: "")
        self.setUpUI()
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.getPhoneList()
    }
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tabelV.estimatedRowHeight = 47
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.sectionIndexBackgroundColor = .clear
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor(hexString: kVCBgColorS)
        tabelV.delegate = self
        tabelV.dataSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    fileprivate lazy var noTranslationView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor(hexString: kVCBgColorS)
        view.isHidden = true
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    override func navBackClick() {
        self.searchCtl.isActive = false
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
    }
    
}

extension CODChooseMobileContactsVC{

    
    func setUpUI() {
        
//        self.definesPresentationContext = true
        
        let bgView = UIView(frame: CGRect.zero)
        bgView.backgroundColor = UIColor.clear
        bgView.addSubview(searchCtl.searchBar)
        
        searchCtl.searchBar.placeholder = "搜索联系人"
        searchCtl.delegate = self
        searchCtl.searchResultsUpdater = self
        searchCtl.dimsBackgroundDuringPresentation = false
        searchCtl.hidesNavigationBarDuringPresentation = false
        searchCtl.searchBar.searchBarStyle = .default
        
        //取掉上下两条黑线
        searchCtl.searchBar.backgroundImage = UIImage()
        
        self.view.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56.0)
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        searchCtl.searchBar.barTintColor = UIColor.init(hexString: kVCBgColorS)
        searchCtl.searchBar.tintColor = UIColor.init(hexString: kBlueTitleColorS)
        searchCtl.searchBar.customTextField?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
        let searchBarTF = searchCtl.searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 17)
        
//        self.view.addSubview(self.noTranslationView)
//        self.noTranslationView.snp.makeConstraints { (make) in
//            make.top.left.right.equalToSuperview()
//            make.height.equalTo(kNavBarHeight+kSafeArea_Top)
//        }
        
    }
    
    //获取通讯录
    func getPhoneList(){
        //创建通讯录
        let store = CNContactStore.init();
        //获取授权状态
        let AuthStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts);
        
        if AuthStatus == CNAuthorizationStatus.authorized{
            CODProgressHUD.showWithStatus(nil)
            //获取所有的联系人
            let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
            let request = CNContactFetchRequest.init(keysToFetch: keys as [CNKeyDescriptor]);
            try? store.enumerateContacts(with: request, usingBlock: { (contact, iStop) in
                
                let phoneArr = contact.phoneNumbers;
                let name = contact.familyName + contact.givenName
                
                for labelValue in phoneArr{
                    
                    let cnlabelV = labelValue as CNLabeledValue;
                    let value = cnlabelV.value;
                    
                    var phoneValue:String = value.stringValue;
                    phoneValue = phoneValue.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "")
                    
                    if phoneValue.contains(UserManager.sharedInstance.phoneNum!) {
                        continue
                    }
                    let model = CODMobileContactModel.init()
                    model.tel = phoneValue
                    model.name = name
                    model.style = .unregistered
                    self.contactDict.setValue(model, forKey: phoneValue)
                    
                    let dict = ["tel":phoneValue]
                    self.phoneList.add(dict)
                    break
                }
            });

            var dict:NSDictionary? = [:]
            dict = ["name":COD_searchUser,
                    "requester":UserManager.sharedInstance.jid,
                    "search":self.phoneList]
            
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_contacts, actionDic: dict!)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
        }
        
    }
    
}

extension CODChooseMobileContactsVC:XMPPStreamDelegate{
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
    
        CustomUtil.analyticxXML(iq: iq) { (actionDic, infoDic) in
            guard let infoDic = infoDic else {
                return
            }
            if (actionDic["name"] as? String == COD_searchUser){
                
                let results = infoDic["users"] as? NSArray
                if results != nil {
                    for objDict in results!{
                        
                        let dict = objDict as! NSDictionary
                        let contacts = CODContactRealmTool.getContacts()
                        
                        let model = CODMobileContactModel.init()
                        model.username = dict["username"] as? String ?? ""
                        model.tel = dict["tel"] as? String ?? ""
                        if model.tel == UserManager.sharedInstance.phoneNum {
                            continue
                        }
                        model.name = (dict["name"] as? String ?? "").aes128DecryptECB(key: .nickName)
                        model.userdesc = dict["userdesc"] as? String ?? ""
                        model.userpic = dict["userpic"] as? String ?? ""
                        model.jid = dict["jid"] as? String ?? ""
                        model.gender = dict["gender"] as? String ?? ""
//                        model.name = self.contactDict.object(forKey: model.tel) as? String ?? ""
                        self.contactDict[model.tel] = model
                        
                        model.style = .notFriend
                        for obj in contacts!{
                            let jidTemp = obj.jid
                            if jidTemp == model.jid {
                                model.style = .isFriend
                            }
//                            for tel in telsTemp {
//                                if tel == model.tel{
//                                    model.style = .isFriend
//                                }
//                            }
                        }
                        self.mobileContactModelList = NSMutableArray.init(array: self.contactDict.allValues)
                    }
                    self.sortSource(arr: self.mobileContactModelList)
                    CODProgressHUD.dismiss()
                    self.tableView.emptyDataSetSource = self
                }
            }
        }
        return true
    }
    
    
    /// 对数据源进行排序
    func sortSource(arr:NSMutableArray) {
        // 获得索引数, 这里是27个（26个字母和1个#）
        let indexCount = self.indexedCollation.sectionTitles.count
        
        self.dataArray.removeAll()
        self.sectionTitleArray.removeAll()
        
        // 每一个一维数组可能有多个数据要添加，所以只能先创建一维数组，到时直接取来用
        for _ in 0..<indexCount {
            let array = [CODMobileContactModel]()
            self.dataArray.append(array)
        }
        
        // 将数据进行分类，存储到对应数组中
        for person in arr {
            
            // 根据 person 的 name 判断应该放入哪个数组里
            // 返回值就是在 indexedCollation.sectionTitles 里对应的下标
            let sectionNumber = self.indexedCollation.section(for: person, collationStringSelector: #selector(getter: CODMobileContactModel.name))
            
            // 添加到对应一维数组中
            self.dataArray[sectionNumber].append(person as! CODMobileContactModel)
        }
        
        // 对每个已经分类的一维数组里的数据进行排序，如果仅仅只是分类可以不用这步
        for i in 0..<indexCount {
            
            // 排序结果数组
            let sortedPersonArray = self.indexedCollation.sortedArray(from: self.dataArray[i], collationStringSelector: #selector(getter: CODMobileContactModel.name))
            // 替换原来数组
            self.dataArray[i] = sortedPersonArray as! [CODMobileContactModel]
        }
        
        // 用来保存没有数据的一维数组的下标
        var tempArray = [Int]()
        for (i, array) in self.dataArray.enumerated() {
            
            if array.count == 0 {
                tempArray.append(i)
            } else {
                // 给标题数组添加数据
                self.sectionTitleArray.append(self.indexedCollation.sectionTitles[i])
            }
        }
        
        // 删除没有数据的数组
        for i in tempArray.reversed() {
            self.dataArray.remove(at: i)
        }
        
        self.tableView.reloadData()
    }
    
}


extension CODChooseMobileContactsVC:UITableViewDelegate,UITableViewDataSource {
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODChooseMobileContactCell.self, forCellReuseIdentifier: "CODChooseMobileContactCellID")
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sectionTitleArray.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.dataArray[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataArray[indexPath.section][indexPath.row]
        let jid = model.jid
        if jid.count > 0 {
            if let contactModel = CODContactRealmTool.getContactByJID(by: jid), contactModel.isValid == true {
                CustomUtil.pushToPersonVC(contactModel: contactModel)
            }else{
                let personVC = CODStrangerDetailVC()
                personVC.name = model.name
                personVC.userName = model.username
                personVC.userPic = model.userpic
                personVC.jid = jid
                personVC.gender = model.gender
                personVC.userDesc = model.userdesc
                personVC.type = .searchType
                self.navigationController?.pushViewController(personVC)
            }
        }else{
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell: CODChooseMobileContactCell = tableView.dequeueReusableCell(withIdentifier: "CODChooseMobileContactCellID", for: indexPath) as! CODChooseMobileContactCell
        if indexPath.row == dataArray[indexPath.section].count - 1 {
            cell.isLast = true
        }else{
            cell.isLast = false
        }
        cell.delegate = self
        cell.cellIndexPath = indexPath
        cell.title = dataArray[indexPath.section][indexPath.row].name
        cell.placeholer = "\(NSLocalizedString("手机", comment: "")) \(dataArray[indexPath.section][indexPath.row].tel)"
        cell.iconImage = UIImage.init(named: "default_header_110")
        cell.iconUrlString = dataArray[indexPath.section][indexPath.row].userpic
        cell.style = dataArray[indexPath.section][indexPath.row].style
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28.0
    }
    
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let textString = self.sectionTitleArray[section]
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
        
    /// 这是右侧可以点击跳转的控件 title
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitleArray
    }
    
}

extension CODChooseMobileContactsVC: EmptyDataSetSource {
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        if self.searchCtl.isActive {
            let view = UIView()
            view.isHidden = false
            view.backgroundColor = UIColor.init(hexString: kVCBgColorS)
            let label = UILabel()
            label.text = NSLocalizedString("无结果", comment: "")
            label.font = UIFont.systemFont(ofSize: 17)
            label.textAlignment = .center
            label.textColor = UIColor.init(hexString: kSubTitleColors)
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-150)
            }
            return view
        }
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
        
        let lab = UILabel.init(frame: .zero)
        lab.text = CustomUtil.formatterStringWithAppName(str:"您还没有通讯录联系人")
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
    
}

extension CODChooseMobileContactsVC:CODChooseMobileContactCellDelegate{
    
    //列表点击添加按钮
    func contactCellBtn(indexPath: IndexPath) {
        let contactModel = self.dataArray[indexPath.section][indexPath.row]
        if contactModel.style == .unregistered {
            // 去邀请
            if MFMessageComposeViewController.canSendText() {
                let controller = MFMessageComposeViewController()
                controller.recipients = [contactModel.tel]
                controller.navigationBar.tintColor = UIColor.red
                controller.body = String.init(format: NSLocalizedString("【%@】%@邀请你在%@成为好友，点击查看>%@", comment: ""), kApp_Name, UserManager.sharedInstance.nickname!, kApp_Name, GeneralURL)
                controller.messageComposeDelegate = self//设置委托
                self.searchCtl.isActive = false
//                self.present(controller, animated: true, completion: nil)
                self.present(controller, animated: true) {
                    HttpManager.share.post(url: HttpConfig.COD_inviterRegisterBySms,
                                           param: ["username":UserManager.sharedInstance.loginName as Any,
                                                   "invitertel":contactModel.tel],
                                           successBlock: { (diction, json) in
                                            
                                            print(diction)
                                            
                                            
                    }) { (error) in
                        
                    }
                }
            } else{
                print("该设备部支持短信功能, 并作出相应的提醒")
            }

        }else{ // 去添加
            let model = CODChatPersonModel.init()
            model.username = contactModel.username
            self.addFriend(model: model)
        }
        
    }
    
    func addFriend(model: CODChatPersonModel) {
        let verificationVC = CODVerificationApplicationVC()
        verificationVC.model =  model
        verificationVC.type = .searchType
        self.navigationController?.pushViewController(verificationVC)
    }
}

extension CODChooseMobileContactsVC:UISearchControllerDelegate,UISearchResultsUpdating{
    
//    func willDismissSearchController(_ searchController: UISearchController) {
//        self.sortSource(arr:self.mobileContactModelList)
//    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let preicate:NSPredicate = NSPredicate.init(format: "name CONTAINS %@ || tel CONTAINS %@", self.searchCtl.searchBar.text!,self.searchCtl.searchBar.text!)
        
        let result = self.mobileContactModelList.filtered(using: preicate)
        let stringNSArray:NSMutableArray = NSMutableArray.init()
        for model in result {
            stringNSArray.add(model)
        }
        if self.searchCtl.searchBar.text?.count != 0 {
            
            self.sortSource(arr:stringNSArray)
        }else{
            self.sortSource(arr: self.mobileContactModelList)
        }
    }
    
//    func willPresentSearchController(_ searchController: UISearchController) {
//        self.noTranslationView.isHidden = false
//
//    }
//
//    func willDismissSearchController(_ searchController: UISearchController) {
//        self.noTranslationView.isHidden = true
//
//    }
}

extension CODChooseMobileContactsVC: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        switch result {
        case MessageComposeResult.sent:
            //信息传送成功
            break
        case MessageComposeResult.failed:
            //信息传送失败
            break
        case MessageComposeResult.cancelled:
            //信息被用户取消传送
            break
        @unknown default:
            break
        }
    }
    
    
}
