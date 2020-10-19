//
//  MeViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class MeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var notificationSwitch = false
//    #if PRO
        var cellArr : Array = [[["img":"","title":"\(UserManager.sharedInstance.nickname!)","ctl":"UserInfoController"]],
    //                           [["img":"scan_icon_img","title":"扫一扫","ctl":"MeScanViewController"]],
    //                           [["img":"favorites_icon","title":"收藏","ctl":"FavoriteViewController"]],
                            [["img":"me_server_set","title":"连接设置","ctl":"CODChangeServersAddressViewController"]],
                            [["img":"cloud_disk","title":"我的云盘","ctl":"MessageViewController"],
                             ["img":"me_call","title":"最近呼叫","ctl":"CODRecentlyCallViewController"]],
                            [["img":"safe_icon","title":"账号与安全","ctl":"CODSecurityVC"],
                             ["img":"data_storage","title":"数据与存储","ctl":"CODCacheSetViewController"],
                             ["img":"security_icon","title":"隐私与权限","ctl":"CODPrivacyVC"],
                             ["img":"new_msg_icon","title":"通知与声音","ctl":"CODNewMessageNotificationVC"],
                             ["img":"general_icon","title":"通用","ctl":"CODCommonUseVC"],
                             ["img":"language","title":"语言","ctl":"CODLanguageSettingsVC"]],
                            [["img":"about_icon","title":CustomUtil.formatterStringWithAppName(str: "关于%@"),"ctl":"CODAboutViewController"]],] as [Array<NSDictionary>]
    
    let indexSection = 3
    
//    #else
//        var cellArr : Array = [[["img":"","title":"\(UserManager.sharedInstance.nickname!)","ctl":"UserInfoController"]],
//    //                           [["img":"scan_icon_img","title":"扫一扫","ctl":"MeScanViewController"]],
//    //                           [["img":"favorites_icon","title":"收藏","ctl":"FavoriteViewController"]],
//                            [["img":"cloud_disk","title":"我的云盘","ctl":"MessageViewController"],
//                             ["img":"me_call","title":"最近呼叫","ctl":"CODRecentlyCallViewController"]],
//                            [["img":"safe_icon","title":"账号与安全","ctl":"CODSecurityVC"],
//                             ["img":"data_storage","title":"数据与存储","ctl":"CODCacheSetViewController"],
//                             ["img":"security_icon","title":"隐私与权限","ctl":"CODPrivacyVC"],
//                             ["img":"new_msg_icon","title":"通知与声音","ctl":"CODNewMessageNotificationVC"],
//                             ["img":"general_icon","title":"通用","ctl":"CODCommonUseVC"],
//                             ["img":"language","title":"语言","ctl":"CODLanguageSettingsVC"]],
//                            [["img":"about_icon","title":CustomUtil.formatterStringWithAppName(str: "关于%@"),"ctl":"CODAboutViewController"]],] as [Array<NSDictionary>]
//
//    let indexSection = 2
//    #endif


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.cellArr.remove(at: 0)
        self.cellArr.insert([["img":"","title":"\(UserManager.sharedInstance.nickname!)","ctl":"UserInfoController"]], at: 0)
        self.reloadView()
        if let tab = UIApplication.shared.delegate?.window??.rootViewController as? CODCustomTabbarViewController,tab.tabBar.isHidden  {
            tab.tabBar.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("设置", comment: "")
        
        tableView.register(UINib(nibName: "MeHeaderCell", bundle: nil), forCellReuseIdentifier: "MeHeaderCell")
        tableView.register(UINib(nibName: "MeNormalFunctionCell", bundle: nil), forCellReuseIdentifier: "MeNormalFunctionCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfo), name: NSNotification.Name.init(kUpdateGKMeHeaderViewNoti), object: nil)

        
        #if DEBUG
        self.rightTextButton.setTitle("Debug", for: .normal)
        self.rightTextButton.setTitleColor(.red, for: .normal)
        self.rightTextButton.isUserInteractionEnabled = true
        self.setRightTextButton()
        #endif
        
    }
    
    override func navRightTextClick() {
        
        let alert = UIAlertController(title: "模拟修复", message: nil, preferredStyle: .alert)
        alert.addAction(title: "删除联系人", style: .default, isEnabled: true) { (action) in
        
            let result = try! Realm().objects(CODContactModel.self)
            result.setValue(\.isValid, value: false)
        }
        
        alert.addAction(title: "删除会话列表", style: .default, isEnabled: true) { (action) in
            let result = try! Realm().objects(CODChatListModel.self)
            result.setValue(\.isInValid, value: true)
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
        }
        
        alert.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func updateUserInfo()  {
        self.tableView.reloadData()
    }
    
    @objc func reloadView() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    self.notificationSwitch = false
                    self.tableView.reloadData()
                }
            }else if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    self.notificationSwitch = true
                    self.tableView.reloadData()
                }
            }
        }
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension MeViewController : UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
            return 12.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: kVCBgColorS)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = cellArr[indexPath.section][indexPath.row]
        
        if dic["ctl"] as! String == "CODRecentlyCallViewController" {
            let callStoryboard = UIStoryboard.init(name: "Call", bundle: Bundle.main)
            let vc = callStoryboard.instantiateViewController(withIdentifier: "CODRecentlyCallViewController") as! CODRecentlyCallViewController
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if dic["ctl"] as! String == "MessageViewController" {
            if let model = CODContactRealmTool.getContactById(by: CloudDiskRosterID) {
                let msgCtl = MessageViewController()
                msgCtl.chatType = .privateChat
                msgCtl.toJID = model.jid
                msgCtl.chatId = model.rosterID
                msgCtl.title = NSLocalizedString(model.getContactNick(), comment: "")
                self.navigationController?.pushViewController(msgCtl, animated: true)
            }
            return
        }
        
        if dic["ctl"] as! String == "CODChangeServersAddressViewController" {
            
            let vc = CODChangeServersAddressViewController(nibName: "CODChangeServersAddressViewController", bundle: Bundle.main)
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        //1:动态获取命名空间
        guard let spaceName = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
            print("获取命名空间失败")
            return
        }
        let vcClass: AnyClass? = NSClassFromString("\(spaceName).\(dic["ctl"] as! String)") //VCName:表示试图控制器的类名
        // Swift中如果想通过一个Class来创建一个对象, 必须告诉系统这个Class的确切类型
        
        guard let typeClass = vcClass as? UIViewController.Type else {
            print("vcClass不能当做UIViewController")
            return
        }
        let myVC = typeClass.init()
        //或者加载xib;   let myVC = typeClass.init(nibName: name, bundle: nil)
        
        self.navigationController?.pushViewController(myVC, completion: {
            if indexPath.section == self.indexSection && indexPath.row == 0 {
            
                if let rootVC = UIApplication.shared.keyWindow?.rootViewController as? CODCustomTabbarViewController {
                    rootVC.tabBar.items?.last?.badgeValue = nil
                    CODUserDefaults.set(false, forKey: AccountAndSecurity_Red_Point)
                    self.tableView.reloadData()
                }
            }
        })

    }
}

extension MeViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic = cellArr[indexPath.section][indexPath.row]
        switch indexPath.section {
        case 0:
            let cell : MeHeaderCell = tableView.dequeueReusableCell(withIdentifier: "MeHeaderCell") as! MeHeaderCell
            if let title = dic["title"] as? String {
                cell.userNameLab.text = title
            }
            cell.sex = UserManager.sharedInstance.sex
//            let url = URL(string: UserManager.sharedInstance.avatar!)
//            cell.headView.sd_setImage(with: url, placeholderImage: UIImage(named: "default_header_94"), options: [], completed: nil)
            cell.headView.contentMode = .scaleAspectFill
            
            
            cell.headView.cod_loadHeader(url: URL(string: UserManager.sharedInstance.avatar!.getHeaderImageFullPath(imageType: 0)))
//            CODDownLoadManager.sharedInstance.updateAvatar(userPicID: UserManager.sharedInstance.avatar!) { [weak self] (image) in
//                guard self != nil else {
//                    return
//                }
//                cell.headView.image = image
//            }
//
            return cell
        default:
            let cell : MeNormalFunctionCell = tableView.dequeueReusableCell(withIdentifier: "MeNormalFunctionCell") as! MeNormalFunctionCell
            cell.titleLab.text = dic["title"] as? String
            cell.imgView.image = UIImage(named: dic["img"] as! String)
            if indexPath.row == 0 && indexPath.section == indexSection{
                if CODUserDefaults.bool(forKey: AccountAndSecurity_Red_Point) == true{
                    let text:String = cell.titleLab.text ?? ""
                    let attText = NSAttributedString.init(string: text)
                    let redPoint = NSAttributedString.init(string: "     ●").applying(attributes: [.foregroundColor: UIColor.red, .font: UIFont.systemFont(ofSize: 10)], toRangesMatching: "●")
                    cell.titleLab.attributedText = attText + redPoint
                }
            }
            let sectionArr = cellArr[indexPath.section]
            if indexPath.row == 0 {
                cell.isTop = true
            }else{
                cell.isTop = false
            }
            if indexPath.row == sectionArr.count - 1 {
                cell.isBottom = true
            }else {
                cell.isBottom = false
            }
            
            
            let ctl = dic["ctl"] as! String
            
            cell.subTitleAttri = nil
            if ctl == "CODLanguageSettingsVC" {
                
                if let languageWithApp = UserDefaults.standard.object(forKey: kMyLanguage) as? String,languageWithApp.count > 0 {
                    
                
                    if languageWithApp == "zh-Hans"{
                        cell.subTitle = "中文（简体）"
                    }else if languageWithApp == "zh-Hant"{
                        cell.subTitle = "中文（繁体）"
                    }else{
                        cell.subTitle = "英文"
                    }
                } else {
                    
                    let arr = UserDefaults.standard.object(forKey: "AppleLanguages") as? NSArray
                    let languageStr = arr?.firstObject as? String
                    if (languageStr?.contains("zh-Hans"))! {
                        cell.subTitle = "中文（简体）"
                    }else if (languageStr?.contains("en"))! {
                        cell.subTitle = "英文"
                        
                    }else if (languageStr?.contains("zh-Hant"))! {
                        cell.subTitle = "中文（繁体）"
                        
                    }else{
                        cell.subTitle = "中文（简体）"
                    }
                    
                }
                
            }else if ctl == "CODNewMessageNotificationVC"{
                
                if notificationSwitch {
                    cell.subTitleAttri = nil
                }else{
                    let imgText = NSTextAttachment()
                    let img = UIImage(named: "notification_error_icon")!
                    imgText.image = img
                    imgText.bounds = CGRect(x: 0.0, y: -3, width: img.size.width, height: img.size.height)
                    let imgAttri = NSAttributedString(attachment: imgText)
                    cell.subTitleAttri = imgAttri
                }
                
            }else{
                cell.subTitle = nil
            }
            
            return cell
        }
    }
    
    
    
}
