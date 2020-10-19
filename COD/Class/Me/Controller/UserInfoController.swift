//
//  UserInfoController.swift
//  COD
//
//  Created by XinHoo on 2019/3/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import AdSupport

class UserInfoController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var cellArr : [Array<NSDictionary>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setBackButton()
        self.navigationItem.title = NSLocalizedString("编辑资料", comment: "")
        
        tableView.register(UINib(nibName: "CODUserInfoHeaderCell", bundle: nil), forCellReuseIdentifier: "CODUserInfoHeaderCell")
        tableView.register(UINib(nibName: "CODUserInfoCell", bundle: nil), forCellReuseIdentifier: "CODUserInfoCell")
        tableView.register(UINib(nibName: "CODUserIntroCell", bundle: nil), forCellReuseIdentifier: "CODUserIntroCell")
        tableView.register(CODMessageDetailCell.self, forCellReuseIdentifier: "CODMessageDetailCellID")
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfo), name: NSNotification.Name.init(kUpdateGKMeHeaderViewNoti), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var intro = "设置简介"
        
        if UserManager.sharedInstance.intro?.count ?? 0 > 0 {
            intro = UserManager.sharedInstance.intro!
        }

        
        if UserManager.sharedInstance.phoneNum?.count ?? 0 > 0 {
            
            cellArr = [[["title":"头像","subTitle":UserManager.sharedInstance.avatar!,"ctl":"CODUserHeadController","enable":"1"]],
                       [["title":"手机号码","subTitle":UserManager.sharedInstance.phoneNum!,"ctl":"CODChangePhoneController","enable":"1"],
                        ["title":"昵称","subTitle":UserManager.sharedInstance.nickname!,"ctl":"CODSetNickNameController","enable":"1"],
                        ["title":"用户名","subTitle":UserManager.sharedInstance.userDesc!,"ctl":"CODSetUserNameController","enable":"1"],
                        ["title":"我的二维码","subTitle":"isQRcode","ctl":"CODMyQRcodeController","enable":"1"],
                        ["title":NSLocalizedString("个人简介", comment: ""),"subTitle": intro, "cellName": "CODUserIntroCell", "ctl": "CODUserIntroVC", "enable":"1"],
                ],
                       
                       [["title":"性别","subTitle":UserManager.sharedInstance.sex,"ctl":"CODSetUserSexController","enable":"1"],
                        //                    ["title":"邮箱","subTitle":UserManager.sharedInstance.email!,"ctl":"CODSetMailViewController","enable":"1"]
                ],
                       [["title":"退出登录","subTitle":"","ctl":""]]]
            
        } else {
            cellArr = [[["title":"头像","subTitle":UserManager.sharedInstance.avatar!,"ctl":"CODUserHeadController","enable":"1"]],
                       [["title":"昵称","subTitle":UserManager.sharedInstance.nickname!,"ctl":"CODSetNickNameController","enable":"1"],
                        ["title":"用户名","subTitle":UserManager.sharedInstance.userDesc!,"ctl":"CODSetUserNameController","enable":"1"],
                        ["title":"我的二维码","subTitle":"isQRcode","ctl":"CODMyQRcodeController","enable":"1"],
                        ["title":NSLocalizedString("个人简介", comment: ""),"subTitle": intro, "cellName": "CODUserIntroCell", "ctl": "CODUserIntroVC", "enable":"1"],
                ],
                       
                       [["title":"性别","subTitle":UserManager.sharedInstance.sex,"ctl":"CODSetUserSexController","enable":"1"],
                        //                    ["title":"邮箱","subTitle":UserManager.sharedInstance.email!,"ctl":"CODSetMailViewController","enable":"1"]
                ],
                       [["title":"退出登录","subTitle":"","ctl":""]]]
        }
        
        
        self.tableView.reloadData()
    }
    
    @objc func updateUserInfo()  {
        self.tableView.reloadData()
    }
    
}

extension UserInfoController : UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 9
        }
        if section == 1{
            return 13.5
        }
        return 14
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var height:CGFloat = 14
        if section == 1{
            height = 13.5
        }
        if section == 0 {
            height = 9
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: height))
        view.backgroundColor = UIColor(hexString: kVCBgColorS)
        
        let topLine = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.5))
        topLine.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        
        let bottomLine = UIView.init(frame: CGRect(x: 0, y: height - 0.5, width: KScreenWidth, height: 0.5))
        bottomLine.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        if section == 0 {
            view.addSubviews([bottomLine])
        }else if section == 1 {
            view.addSubviews([bottomLine])
        }else{
            view.addSubviews([topLine,bottomLine])
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == self.cellArr.count - 1{
            self.loginOut()
            tableView.reloadRows(at: [indexPath], with: .none)
            return
        }
        
        let dic = cellArr[indexPath.section][indexPath.row]
        
        //1:动态获取命名空间
        guard   let spaceName = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
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
        
        if let enable = dic["enable"] as? String {
            if enable == "1" {
                self.navigationController?.pushViewController(myVC, animated: true)
            }else{
                
            }
        }
    }
    
    //退出登录
    func loginOut() {
        
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: kApp_Name, message: String.init(format: NSLocalizedString("确定要注销并退出吗？\n\n提示：你可以通过你所有的移动设备无缝使用%@\n\n注意：注销后，在本设备将无法收到新的%@消息", comment: ""), kApp_Name,kApp_Name), preferredStyle: .alert)
            let confirmAction = UIAlertAction.init(title: "确定", style: .default) { (confirmAction) in
                self.logoutSession()
            }
            
            let cancleAction = UIAlertAction.init(title: "取消", style: .default) { (cancleAction) in
                
            }
            alert.addAction(cancleAction)
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: 注销session
    func logoutSession() {
        
        CODProgressHUD.showWithStatus("注销账号中...")
        
        let requestUrl = HttpConfig.logoutPushSession
        HttpManager().post(url: requestUrl, param: ["username":UserManager.sharedInstance.loginName ?? "",
                                                    "deviceID":DeviceInfo.uuidString,
                                                    "token":UserManager.sharedInstance.session ?? ""], successBlock: { (result, json) in
                                                        
                                                        print("======注销session成功")
                                                        CODProgressHUD.dismiss()
                                                        UserManager.sharedInstance.userLogout()
        }) { (error) in
            CODProgressHUD.dismiss()
            UserManager.sharedInstance.userLogout()
            CODProgressHUD.showErrorWithStatus(error.message)
        }
    }
}

extension UserInfoController :UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArr[section].count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func dequeueReusableCell(dic :[String : String], indexPath: IndexPath) -> UITableViewCell? {
        
        if let cellName = dic["cellName"] {
            
            switch cellName {
            case "CODUserIntroCell":
                let cell = tableView.dequeueReusableCell(withClass: CODUserIntroCell.self, for: indexPath)
                cell.subTitleLab.text = dic["subTitle"]
                cell.titleLab.text = dic["title"]
                
                cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                return cell
                
            default:
                break
            }

        }
        
        return nil

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dic :[String : String] = cellArr[indexPath.section][indexPath.row] as! [String : String]
        
        if let cell = self.dequeueReusableCell(dic: dic, indexPath: indexPath) {
            return cell
        }

        if indexPath.section == 0 && indexPath.row == 0 {
            let cell : CODUserInfoHeaderCell = tableView.dequeueReusableCell(withIdentifier: "CODUserInfoHeaderCell") as! CODUserInfoHeaderCell
            //            cell.topLine.isHidden = true
            cell.titleLab.text = dic["title"]
            cell.headerUrlStr = dic["subTitle"]
            return cell
        }else if indexPath.section == self.cellArr.count - 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailCellID", for: indexPath) as? CODMessageDetailCell
            if cell == nil{
                cell = CODMessageDetailCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailCellID")
            }
            cell?.isLast = true
            cell?.isDelete = true
            cell?.titleC = UIColor.red
            cell?.title = "退出登录"
            return cell!
        }else{
            let cell : CODUserInfoCell = tableView.dequeueReusableCell(withIdentifier: "CODUserInfoCell") as! CODUserInfoCell
            cell.titleLab.text = dic["title"]
            cell.subTitleLab.text = dic["subTitle"]
            let isQRcode :NSString = dic["subTitle"]! as NSString
            cell.isQRcode = isQRcode.isEqual(to: "isQRcode")
            if cellArr[indexPath.section].count - 1 == indexPath.row {
                cell.bottomLine.isHidden = true
            }else{
                cell.bottomLine.isHidden = false
            }
            if let enable = dic["enable"] {
                if enable == "1" {
                    cell.arrowBtn.isHidden = false
                    cell.selectionStyle = .default
                }else{
                    cell.arrowBtn.isHidden = true
                    cell.selectionStyle = .none
                }
            }
            
            return cell
        }
    }
    
    
}
