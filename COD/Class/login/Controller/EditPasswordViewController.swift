//
//  EditPasswordViewController.swift
//  COD
//
//  Created by xinhooo on 2019/12/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class EditPasswordViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var newPasswordTF: CODLimitInputNumberTextField!
    @IBOutlet weak var confirmPasswordTF: CODLimitInputNumberTextField!
    @IBOutlet weak var switchBtn: UIButton!
    
    var limitInputNumber = 20
    var nextStepToSettingNickName = false {
        didSet {
            switchBtn.isHidden = nextStepToSettingNickName
        }
    }
    
    var isForceChangePwd: Bool = false
    
    override func navBackClick() {
        super.navBackClick()
        passwordTF.delegate = nil
        newPasswordTF.delegate = nil
        confirmPasswordTF.delegate = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let target = self.navigationController?.interactivePopGestureRecognizer?.delegate
        let pan = UIPanGestureRecognizer(target: target, action: nil)
        self.view.addGestureRecognizer(pan)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("设置登录密码", comment: "")
        self.setBackButton()
        self.backButton.isHidden = isForceChangePwd
        // Do any additional setup after loading the view.
        
        if UserManager.sharedInstance.phoneNum?.count ?? 0 > 0 {
            self.switchBtn.isHidden = false
        }
        
        newPasswordTF.setInputNumber(number: limitInputNumber)
        confirmPasswordTF.setInputNumber(number: limitInputNumber)
        
    }

    @IBAction func enterAction(_ sender: Any) {
        
        guard let password = self.passwordTF.text , let newPassword = self.newPasswordTF.text , let confirmPassword = self.confirmPasswordTF.text else {
            CODProgressHUD.showErrorWithStatus("请输入密码")
            return
        }
        
        if ((password.count) == 0 || newPassword.count == 0 || confirmPassword.count == 0){
            CODProgressHUD.showErrorWithStatus("请输入密码")
            return
        }
        
        //提交
        let requestUrl = HttpConfig.alterPasswordUrl

        if newPassword.count < 6 || newPassword.count > 20 {
            CODProgressHUD.showErrorWithStatus("密码限制6-20位，请重新输入")
            return
        }

        if (newPassword != confirmPassword){
            CODProgressHUD.showErrorWithStatus("密码输入不一致")
            return
        }




        let oldPwdMD5 = password.cod_saltMD5()
        let newPwdMD5 = newPassword.cod_saltMD5()
        CODProgressHUD.showWithStatus(nil)
        HttpManager().post(url: requestUrl, param: ["username":UserManager.sharedInstance.loginName as Any,"password":oldPwdMD5,"newpassword":newPwdMD5,"resource":UserManager.sharedInstance.resource as Any], successBlock: { [weak self] (result, json) in
            
            guard let `self` = self else { return }
            
            UserManager.sharedInstance.password = result["password"] as? String ?? ""
            CODProgressHUD.showSuccessWithStatus(result["msg"] as! String)
            
            
            if self.nextStepToSettingNickName {
                UIViewController.pushToCtl(CODSettingNickAndAvatarController(), animated: true)
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }) { (error) in
            //                    CODProgressHUD.showErrorWithStatus(error.message)
            switch error.code {
            case 10010:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("旧密码错误", comment: ""))
            case 10084:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("您的IP地址因频繁异常登录已被封禁，请联系管理员处理", comment: ""))
            default:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString(error.message, comment: ""))
            }
        }
        
    }
    
    
    @IBAction func switchVerifyTypeAction(_ sender: Any) {
        self.navigationController?.pushViewController(ForgetPwViewController(), animated: true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.count > 0 else {
            return true
        }
        guard text.count >= 6 && text.count <= 20 else {
            CODProgressHUD.showErrorWithStatus("密码限制6-20位，请重新输入")
            return false
        }
        guard text.isAlphaNumeric_Hx else {
            CODProgressHUD.showErrorWithStatus("密码必须包含字母和数字")
            return false
        }
        return true
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
