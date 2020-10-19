//
//  PasswordLoginViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class PasswordLoginViewController: BaseViewController {
    
    enum LoginPageType {
        case phoneSms
        case phoneAndPwd
        case userName
    }

    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var getCodeBtn: UIButton!
    
    @IBOutlet weak var errorLab: UILabel!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var otherLoginwayBtn: UIButton!
    
    @IBOutlet weak var forgotPwBtn: UIButton!
    @IBOutlet weak var beforePhoneNumberView: UIView!
    @IBOutlet weak var beforePhoneNumberViewHeight: NSLayoutConstraint!
    @IBOutlet weak var inputViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonTopCons: NSLayoutConstraint!
    
    @IBOutlet weak var inputViewTopCons: NSLayoutConstraint!
    var isPasswordLogin = true
    
    var loginPageType: LoginPageType = .phoneAndPwd
    
    var areaCode = "86"
    
    @IBOutlet weak var countryLab: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.setBackButton()
//        self.setRightTextButton()
//        self.rightTextButton.setTitle("注册", for: UIControl.State.normal)
//        self.rightTextButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        if let phoneString = CODUserDefaults.value(forKey: LAST_PHONE_LOGIN) as? String{
            self.phoneField.text = phoneString
//            self.codeField.becomeFirstResponder()
        }
        
        if UserManager.sharedInstance.countryName != ""{
            self.countryLab.text = "\(UserManager.sharedInstance.countryName ?? "")(+\(UserManager.sharedInstance.areaNum ?? ""))"
            self.areaCode = UserManager.sharedInstance.areaNum ?? "86"
        }
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    override func navRightTextClick() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func selectCountry(_ sender: Any) {
        let vc = CODCountryCodeViewController.init(nibName: "CODCountryCodeViewController", bundle: Bundle.main)
        vc.selectBlock = { (model) in
            
            self.countryLab.text = "\(model.name)(+\(model.phonecode))"
            self.areaCode = model.phonecode
            UserManager.sharedInstance.countryName = model.name
            UserManager.sharedInstance.areaNum = model.phonecode
        }
        self.navigationController?.pushViewController(vc)
    }
    
    @IBAction func login(_ sender: Any) {
        CODProgressHUD.showWithStatus(nil)
        let username = phoneField.text?.removeAllSapce
        let password = passwordField.text
        let md5Password = password?.cod_saltMD5()
        let code = codeField.text?.removeAllSapce ?? ""
        
        var dic : Dictionary<String, String>?
        var url : String?
        
        switch loginPageType {
        case .phoneAndPwd:
            if username?.count ?? 0 <= 0 {
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("请输入正确的手机号码", comment: ""))
                return
            }
            if password?.count ?? 0 < 6 || password?.count ?? 0 > 20  {
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("请输入正确的密码", comment: ""))
                return
            }
            
            dic = ["areaCode":areaCode,"tel":username,"password":md5Password] as? Dictionary<String, String>
            url = HttpConfig.PWLoginUrl
        case .phoneSms:
            if username?.count ?? 0 > 11 {
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("请输入正确的手机号码", comment: ""))
                return
            }
            if code.count < 4 {
                if code.count <= 0 {
                    CODProgressHUD.showErrorWithStatus("请输入验证码")
                    return
                }
                CODProgressHUD.showErrorWithStatus("验证码输入错误")
                return
            }
            
            dic = ["areaCode":areaCode,"tel":username,"code":code] as? Dictionary<String, String>
            url = HttpConfig.SMSloginUrl
            
        case .userName:
            dic = ["username":username,"password":md5Password] as? Dictionary<String, String>
            url = HttpConfig.UsernameLoginUrl
            
            if username?.count ?? 0 >= 32 || username?.count ?? 0 == 0 {
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("请输入正确的用户名", comment: ""))
                return
            }
            
            if password?.count ?? 0 < 6 || password?.count ?? 0 > 20  {
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("请输入正确的密码", comment: ""))
                return
            }

        }
        
        
        weak var weakSelf = self
        HttpManager.share.post(url: url!, param: dic, successBlock: { (result, jsonResult) in
//            CODProgressHUD.showSuccessWithStatus("login success")
            CODUserDefaults.set(username, forKey: LAST_PASSWORD_LOGIN)
            
            UserManager.sharedInstance.getUserSuccess(jsonResult)
            if weakSelf!.isPasswordLogin {
                UserManager.sharedInstance.password = result["password"] as? String ?? ""
            }
            UserManager.sharedInstance.phoneNum = username
            
            if self.loginPageType != .userName {
                CODUserDefaults.set(username, forKey: LAST_PHONE_LOGIN)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.init(kGetUserSuccessNoti), object: nil, userInfo: nil)
            
        }) { (error) in
            switch error.code {
            case 10009, 10023:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("手机号或密码错误", comment: ""))
            case 1010, 10060:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("用户名或密码错误", comment: ""))
            case 10048:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("您输入的密码错误次数过多，请于半小时后再试", comment: ""))
            case 10031:
                CODProgressHUD.showErrorWithStatus("因涉嫌违规或被用户投诉，您的账号已被冻结")
            case 10080:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("密码错误次数超过限制，请明天再试", comment: ""))
            case 10084:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("您的IP地址因频繁异常登录已被封禁，请联系管理员处理", comment: ""))
            default:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString(error.message, comment: ""))
            }
            
        }
    }
    
    fileprivate func hiddenBeforePhoneNumberView() {
        self.beforePhoneNumberView.isHidden = false
        self.beforePhoneNumberViewHeight.constant = 55
        self.inputViewHeight.constant += 55
        self.buttonTopCons.constant -= 27.5
        self.inputViewTopCons.constant -= 27.5
    }
    
    fileprivate func showBeforePhoneNumberView() {
        self.beforePhoneNumberView.isHidden = true
        self.beforePhoneNumberViewHeight.constant = 0
        self.inputViewHeight.constant -= 55
        self.buttonTopCons.constant += 27.5
        self.inputViewTopCons.constant += 27.5
    }
    
    @IBAction func changeLoginWay(_ sender: Any) {
        self.phoneField.resignFirstResponder()
        
        if loginPageType == .phoneAndPwd {
            
            loginPageType = .userName
            
            self.titleLab.text = NSLocalizedString("使用密码登录", comment: "")
            self.otherLoginwayBtn.setTitle(NSLocalizedString("切换为手机号码", comment: ""), for: UIControl.State.normal)
            self.codeView.isHidden = true
            
            self.forgotPwBtn.isHidden = true
            self.phoneField.placeholder = NSLocalizedString("用户名", comment: "")
            self.phoneField.clear()
            self.codeField.clear()
            self.passwordField.clear()
            
            showBeforePhoneNumberView()
            self.phoneField.keyboardType = .numbersAndPunctuation
            self.phoneField.becomeFirstResponder()
            
        } else if loginPageType == .userName {
            
            loginPageType = .phoneAndPwd
            self.phoneField.placeholder = NSLocalizedString("手机号码", comment: "")
            self.titleLab.text = NSLocalizedString("使用密码登录", comment: "")
            self.otherLoginwayBtn.setTitle(NSLocalizedString("切换为用户名", comment: ""), for: UIControl.State.normal)
            self.codeView.isHidden = true
            
            self.forgotPwBtn.isHidden = false
            self.codeField.clear()
            self.passwordField.clear()
            
            hiddenBeforePhoneNumberView()
            
            self.phoneField.keyboardType = .phonePad
            self.phoneField.text = CODUserDefaults.value(forKey: LAST_PHONE_LOGIN) as? String ?? ""
            self.phoneField.becomeFirstResponder()
            
        }
        
    }
    
    @IBAction func showForgotPw(_ sender: Any) {
        self.navigationController?.pushViewController(ForgetPwViewController(), animated: true)
    }
    
    @IBAction func getCode(_ sender: UIButton) {
        CODProgressHUD.showWithStatus(nil)

        guard areaCode.count > 0 else {
            CODProgressHUD.showErrorWithStatus("请选择国家地区")
            return
        }
        
        let phoneStr = phoneField.text ?? ""
        guard phoneStr.count > 0 else {
            CODProgressHUD.showErrorWithStatus("请输入手机号码")
            return
        }
        let requestUrl = HttpConfig.getSMSCodeUrl
        
        weak var weakSelf = self
        HttpManager().post(url: requestUrl, param: ["areaCode":areaCode,"tel":phoneStr], successBlock: { (result, json) in
            weakSelf?.startTimeDown(sender: sender)
            CODProgressHUD.showSuccessWithStatus(NSLocalizedString("成功获取验证码", comment: ""))
        }) { (error) in
            sender.isUserInteractionEnabled = true
            switch error.code {
            case 10044:
                CODProgressHUD.showErrorWithStatus("短信服务器异常")
            case 10004:
                CODProgressHUD.showErrorWithStatus("请输入正确的手机号码")
            case 10043:
                CODProgressHUD.showErrorWithStatus("非法手机号码")
            case 10045:
                CODProgressHUD.showErrorWithStatus("该手机号码发送短信太频繁")
            default:
                if error.message.count > 0 {
                    CODProgressHUD.showErrorWithStatus(error.message)
                } else {
                    CODProgressHUD.showErrorWithStatus("网络异常")
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
