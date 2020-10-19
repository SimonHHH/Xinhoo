//
//  CODAboutViewController.swift
//  COD
//
//  Created by XinHoo on 2019/5/14.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import DoraemonKit

class CODAboutViewController: BaseViewController {

    @IBOutlet weak var versionStrLab: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoImgView: UIButton!
    
    var dataSource: Array<CODCellModel> = Array.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("关于", comment: "") + " \(kApp_Name)"
        self.setBackButton()
        if let infoDictionary = Bundle.main.infoDictionary {
            if let majorVersion = infoDictionary["CFBundleShortVersionString"] as? String{
                versionStrLab.text = "\(kApp_Name) \(majorVersion)"
            }
        }
        
        self.setRightButton()
        self.rightButton.setImage(UIImage(named: "repair_icon"), for: UIControl.State.normal)
        
        registerCellClassForTableView(tableView: self.tableView)
        createCommonDataSource()
        
        #if MANGO
        let img = UIImage(named: "Mango_security_code_logo")
        #elseif PRO
        let img = UIImage(named: "security_code_logo")
        #else
        let img = UIImage(named: "im_security_code_logo")
        #endif
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(showLogView))
        doubleTap.numberOfTapsRequired = 2
        self.logoImgView.addGestureRecognizer(doubleTap)
        
        self.logoImgView.setImage(img, for: .normal)
    }

    override func navRightClick() {
        
        let vc =  CODRepairViewController(nibName: "CODRepairViewController", bundle: Bundle.main)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func showLogView() {
        
        
        DoraemonHomeWindow.shareInstance()?.show()

    }
    
    func createCommonDataSource() {
//        if dataSource.count > 0 {
//            dataSource.removeAll()
//        }
        let model1 = self.createModel(title: "帮助", subTitle: "", placeholder: "", image: "", type: .baseType)
//        let model2 = self.createModel(title: "检查更新", subTitle: "", placeholder: "", image: "", type: .baseType)
        let model3 = self.createModel(title: "意见反馈", subTitle: "", placeholder: "", image: "", type: .baseType)
        let model4 = self.createModel(title: "隐私协议", subTitle: "", placeholder: "", image: "", type: .baseType)
        dataSource.append(model1)
//        dataSource.append(model2)
        dataSource.append(model3)
        dataSource.append(model4)
        self.tableView.reloadData()
    }
    
    func createModel(title: String = "",
                     subTitle: String = "",
                     placeholder: String = "",
                     image: String = "",
                     type: CODCellType) -> (CODCellModel) {
        var model = CODCellModel()
        model.title = title
        model.subTitle = subTitle
        model.placeholderString = placeholder
        model.type = type
        model.iconName = image
        return model
    }
/*
    //MARK: 更新app
    func checkApp(versionDict:Dictionary<String, Any>) {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        let alert = UIAlertController.init(title: versionDict["title"] as? String, message: versionDict["content"] as? String, preferredStyle: .alert)
        
        let actionCancle = UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .default) { (action) in
            
            let forcedUpdate = versionDict["forcedUpdate"] as! Bool
            if forcedUpdate {
                UIView.animate(withDuration: 1.0, animations: {
                    
                    delegate.window?.alpha = 0
                }, completion: { (completion) in
                    exit(0)
                })
            }
        }
        
        let actionConfirm = UIAlertAction.init(title: NSLocalizedString("更新", comment: ""), style: .default) { (action) in
            
            if versionDict["outsiteUpdate"] as! Int == 0 {
                UIApplication.shared.open(NSURL.init(string: "itms-services://?action=download-manifest&url=\(versionDict["plistUrl"] as! String)")! as URL, options: [:]) { (b) in
                    print("itms-services://?action=download-manifest&url=\(versionDict["plistUrl"] as! String)")
                    UIView.animate(withDuration: 1.0, animations: {
                        delegate.window?.alpha = 0
                    }, completion: { (completion) in
                        exit(0)
                    })
                }
            }else{
                UIApplication.shared.open(URL.init(string: versionDict["appUrl"] as! String)!, options: [:], completionHandler: { (b) in
                    UIView.animate(withDuration: 1.0, animations: {
                        delegate.window?.alpha = 0
                    }, completion: { (completion) in
                        exit(0)
                    })
                })
            }
        }
        
        alert.addAction(actionCancle)
        alert.addAction(actionConfirm)
        
        alert.show()
        
    }
   */
}

extension CODAboutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODBaseDetailCell.self, forCellReuseIdentifier: "CODBaseDetailCellID")
        tableView.register(CODDetailImageCell.self, forCellReuseIdentifier: "CODDetailImageCellID")
        tableView.register(CODDetailSwitchCell.self, forCellReuseIdentifier: "CODDetailSwitchCellID")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        if case .switchType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODDetailSwitchCellID", for: indexPath) as? CODDetailSwitchCell
            if cell == nil{
                cell = CODDetailSwitchCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODDetailSwitchCellID")
            }
            if indexPath.row == 0 {
                cell?.isTop = true
            }else{
                cell?.isTop = false
            }
            if indexPath.row == dataSource.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.switchIsOn = model.isOn
            cell?.imageStr = model.iconName
            return cell!
        }else if case .imageType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODDetailImageCellID", for: indexPath) as? CODDetailImageCell
            if cell == nil{
                cell = CODDetailImageCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODDetailImageCellID")
            }
            if indexPath.row == dataSource.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.cellType = .arrow
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.imageV = UIImage.init(named: model.iconName ?? "")
            return cell!
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODBaseDetailCellID", for: indexPath) as? CODBaseDetailCell
            if cell == nil{
                cell = CODBaseDetailCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODBaseDetailCellID")
            }
            if case .deleteType = model.type {
                cell?.isDelete = true
            }else{
                cell?.isDelete = false
            }
            if indexPath.row == 0 {
                cell?.isTop = true
            }else{
                cell?.isTop = false
            }
            if indexPath.row == dataSource.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.subTitle = model.subTitle
            cell?.imageStr = model.iconName
            cell?.titleFont = UIFont.systemFont(ofSize: 15)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            self.clickHelp()
            break
        case 1:
            self.clickFeedback()
            /*
            let infoDictionary = Bundle.main.infoDictionary
            let majorVersion :AnyObject? = infoDictionary!["CFBundleShortVersionString"] as AnyObject?//主程序版本号
            let requestUrl = checkVersion
            HttpManager().post(url: requestUrl, param: ["resource":"IOS",
                                                        "appVersion":majorVersion as Any], successBlock: { (result, json) in

                                                            let isUpdate = result["isSuccess"] as! Bool
                                                            if isUpdate {
                                                                self.checkApp(versionDict: result as! Dictionary<String, Any>)
                                                            }
            }) { (error) in
                print(error)
                if error.code == 10015 {
                    let alert = UIAlertController.init(title: "检查更新", message: "当前已是最新版本", preferredStyle: .alert)
                    let actionCancle = UIAlertAction.init(title: NSLocalizedString("好的", comment: ""), style: .default) { (action) in
                    }
                    alert.addAction(actionCancle)
                    self.present(alert, animated: true, completion: nil)
                }
            }
 */
        case 2:
            let langString = CustomUtil.getLangString()
            let userVC = CODGenericWebVC()
            userVC.urlString = COD_Privacy_URL + "?lang=\(langString)"
            self.navigationController?.pushViewController(userVC, animated: true)
            break
                        
        default:
            break
        }
    }
    
    
}
extension CODAboutViewController{
    
    func clickHelp() {
        let langString = CustomUtil.getLangString()
        let userVC = CODGenericWebVC()
        userVC.urlString = COD_Help_URL + "?lang=\(langString)"
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    func clickFeedback() {

        
        HttpManager.share.post(url: HttpConfig.COD_GetFeedBackToken, param: nil, successBlock: { (dic, json) in
            
            if let token = json["data"]["token"].string {
                
                let langString = CustomUtil.getLangString()
                
                let userVC = CODGenericWebVC()
                let areaString: String = UserManager.sharedInstance.areaNum ?? ""
                let phoneString: String = UserManager.sharedInstance.phoneNum ?? ""

                userVC.urlString = COD_feedback_URL + "?lang=\(langString)&os=IOS&area=\(areaString)&phone=\(phoneString)&token=\(token)"
                self.navigationController?.pushViewController(userVC, animated: true)
                
            }
            
        }) { (error) in
            
        }
        
        
    }
}
