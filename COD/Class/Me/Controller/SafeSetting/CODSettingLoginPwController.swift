//
//  CODSettingLoginPwController.swift
//  COD
//
//  Created by XinHoo on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSettingLoginPwController: BaseViewController {
    
    var password :String = ""
    var newPassword :String = ""
    var confirmPassword :String = ""
    
    let cellArr = [[["placeholder":"请输入原密码","tag":"0","type":"0"]],
                   [["placeholder":"请输入登录密码(6-20位)","tag":"1","type":"0"],["placeholder":"请再次输入登录密码(6-20位)","tag":"2","type":"0"]],
                   [["placeholder":"确定","tag":"3","type":"1"]]]
    
    let sectionTitleArr = ["原密码","新密码",""]
    
    var limitInputNumber = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = NSLocalizedString("设置登录密码", comment: "")
        self.setBackButton()
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = UIColor.clear
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        table.register(CODTextFieldCell.classForCoder(), forCellReuseIdentifier: "CODTextFieldCell")
        table.register(CODButtonCell.classForCoder(), forCellReuseIdentifier: "CODButtonCell")
        return table
    }()
    


}

extension CODSettingLoginPwController :UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionTitle = sectionTitleArr[section]
        
        let lab = UILabel(frame: CGRect(x: 0, y: 10, width: kScreenWidth, height: 25))
        lab.contentMode = UILabel.ContentMode.bottomLeft
        lab.backgroundColor = UIColor.clear
        lab.text = "      \(sectionTitle)"
        lab.textColor = UIColor(hexString: kSubTitleColors)
        lab.font = UIFont.systemFont(ofSize: 12)
        return lab
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.5))
        return footView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
}

extension CODSettingLoginPwController :UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic: [String : String] = cellArr[indexPath.section][indexPath.row]
        
        if dic["type"] == "0" {
            let cell: CODTextFieldCell = tableView.dequeueReusableCell(withIdentifier: "CODTextFieldCell") as! CODTextFieldCell
            
            cell.field.placeholder = dic["placeholder"]
            cell.field.tag = Int(dic["tag"]!)!
            cell.field.keyboardType = .namePhonePad
            cell.field.isSecureTextEntry = true
            cell.limitInputNumber = self.limitInputNumber
            cell.fieldShouldEndEditCloser = { [weak self] (textField :UITextField) in
                guard let `self` = self else { return true }
                guard let text = textField.text, text.count > 0 else {
                    return true
                }
                switch cell.field.tag {
                case 0:
                    self.password = text
                case 1:
                    
                    guard text.count >= 6 && text.count <= 20 else {
                        CODProgressHUD.showErrorWithStatus("密码限制6-20位，请重新输入")
                        return false
                    }
                    guard text.isAlphaNumeric else {
                        CODProgressHUD.showErrorWithStatus("密码必须包含字母和数字")
                        return false
                    }
                    self.newPassword = text
                case 2:
                    guard text.count >= 6 && text.count <= 20 else {
                        CODProgressHUD.showErrorWithStatus("密码限制6-20位，请重新输入")
                        return false
                    }
                    guard text.isAlphaNumeric else {
                        CODProgressHUD.showErrorWithStatus("密码必须包含字母和数字")
                        return false
                    }
                    self.confirmPassword = text
                default:
                    break
                }
                return true
            }
            return cell
        }else{
            let cell: CODButtonCell = tableView.dequeueReusableCell(withIdentifier: "CODButtonCell") as! CODButtonCell
            cell.button.setTitle(dic["placeholder"], for: UIControl.State.normal)
            cell.btnClickCloser = { (sender : UIButton) in
                //提交
                let requestUrl = HttpConfig.alterPasswordUrl
                
                guard self.newPassword.count >= 6 && self.newPassword.count <= 20 else {
                    CODProgressHUD.showErrorWithStatus("密码限制6-20位，请重新输入")
                    return
                }
                
                if (self.newPassword != self.confirmPassword){
                    CODProgressHUD.showErrorWithStatus("密码输入不一致")
                    return
                }
                
                if ((self.password.count) == 0 || self.newPassword.count == 0 || self.confirmPassword.count == 0){
                    
                    CODProgressHUD.showErrorWithStatus("请输入密码")
                    return
                }
                
                
                let oldPwdMD5 = self.password.cod_saltMD5()
                let newPwdMD5 = self.newPassword.cod_saltMD5()
                CODProgressHUD.showWithStatus(nil)
                HttpManager().post(url: requestUrl, param: ["username":UserManager.sharedInstance.loginName as Any,"password":oldPwdMD5,"newpassword":newPwdMD5], successBlock: { (result, json) in
                    UserManager.sharedInstance.password = newPwdMD5
                    
                    if json["code"].intValue == 10080 {
                        CODProgressHUD.showErrorWithStatus(NSLocalizedString("密码错误次数超过限制，请明天再试", comment: ""))
                    } else {
                        CODProgressHUD.showSuccessWithStatus(result["msg"] as! String)
                    }
                    
                    
                    self.navigationController?.popViewController(animated: true)
                }) { (error) in
                    CODProgressHUD.showErrorWithStatus(error.message)
                }
                
                
            }
            
            return cell
        }
        
        
    }
    
}


