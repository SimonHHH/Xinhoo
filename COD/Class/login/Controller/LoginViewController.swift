//
//  LoginViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: BaseViewController {
    
    var areaCode = "86"
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var getCodeBtn: UIButton!
    @IBOutlet weak var errorLab: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var passwordLoginBtn: UIButton!
    @IBOutlet weak var userProtocolBtn: UIButton!
    @IBOutlet weak var countryInfoLab: UILabel!
    @IBOutlet weak var welcomeLab: UILabel!
    @IBOutlet weak var voiceCodeLabel: YYLabel!
    var timer:DispatchSourceTimer?

    
    @IBAction func selectCountry(_ sender: UIButton) {
        let vc = CODCountryCodeViewController.init(nibName: "CODCountryCodeViewController", bundle: Bundle.main)
        vc.selectBlock = { (model) in
            
            self.countryInfoLab.text = "\(model.name)(+\(model.phonecode))"
            self.areaCode = model.phonecode
            UserManager.sharedInstance.countryName = model.name
            UserManager.sharedInstance.areaNum = model.phonecode
        }
        self.navigationController?.pushViewController(vc)
    }
    
    @IBAction func getCode(_ sender: UIButton) {

        CODProgressHUD.showWithStatus(nil)
        sender.isEnabled = false
        
        guard CODWebRTCManager.whetherConnectedNetwork() else {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            sender.isEnabled = true
            return
        }
        
        guard areaCode.count > 0 else {
            CODProgressHUD.showErrorWithStatus("请选择国家地区")
            sender.isEnabled = true
            return
        }
        
        let phoneStr = phoneField.text?.removeAllSapce ?? ""
        guard phoneStr.count > 0 else {
            CODProgressHUD.showErrorWithStatus("请输入手机号码")
            sender.isEnabled = true
            return
        }
        let requestUrl = HttpConfig.getSMSCodeUrl
        
        weak var weakSelf = self
        if phoneStr.removeAllSapce.count <= 0 {
            CODProgressHUD.showErrorWithStatus("请输入手机号码")
            sender.isEnabled = true
            return
        }
        HttpManager().post(url: requestUrl, param: ["areaCode":areaCode,"tel":phoneStr,"type":"1"], successBlock: { [weak self] (result, json) in
            weakSelf?.codeField.becomeFirstResponder()
            sender.isEnabled = true
            weakSelf?.timer = weakSelf?.startTimeDown(sender: sender)
            CODProgressHUD.showSuccessWithStatus("成功获取验证码")
            weakSelf?.configYYLabelText(text: String(format: NSLocalizedString("长时间接收不到验证码,可尝试 %@", comment: ""), NSLocalizedString("语音接听验证码", comment: "")))
        }) { (error) in
            sender.isEnabled = true
            switch error.code {
            case 10044:
                CODProgressHUD.showErrorWithStatus("短信服务器异常")
            case 10004:
                CODProgressHUD.showErrorWithStatus("请输入正确的手机号码")
            case 10043:
                CODProgressHUD.showErrorWithStatus("非法手机号码")
            case 10045:
                CODProgressHUD.showErrorWithStatus("该手机号码发送短信太频繁")
            case 10065:
                CODProgressHUD.showErrorWithStatus("发送已超过限制。请明天再试一次")
            default:
                if error.message.count > 0 {
                    CODProgressHUD.showErrorWithStatus(error.message)
                } else {
                    CODProgressHUD.showErrorWithStatus("网络异常")
                }
            }
        }
    }
    
    func sendVoiceCode() {
        CODProgressHUD.showWithStatus(nil)

        guard CODWebRTCManager.whetherConnectedNetwork() else {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        
        guard areaCode.count > 0 else {
            CODProgressHUD.showErrorWithStatus("请选择国家地区")
            return
        }
        
        let phoneStr = phoneField.text?.removeAllSapce ?? ""
        guard phoneStr.count > 0 else {
            CODProgressHUD.showErrorWithStatus("请输入手机号码")
            return
        }
        let requestUrl = HttpConfig.getSMSCodeUrl
        
        weak var weakSelf = self
        if phoneStr.removeAllSapce.count <= 0 {
            CODProgressHUD.showErrorWithStatus("请输入手机号码")
            return
        }
        HttpManager().post(url: requestUrl, param: ["areaCode":areaCode,"tel":phoneStr,"type":"2"], successBlock: { [weak self] (result, json) in
            weakSelf?.codeField.becomeFirstResponder()
            CODProgressHUD.showSuccessWithStatus("成功获取验证码")
            weakSelf?.configYYLabelText(text: NSLocalizedString("我们正在拨打您的电话，请注意接听...", comment: ""))
        }) { (error) in
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
    
    @IBAction func submit(_ sender: UIButton) {
        CODProgressHUD.showWithStatus(nil)

        let requestUrl = HttpConfig.SMSloginUrl
        let phoneStr = phoneField.text?.removeAllSapce ?? ""
        let codeStr = codeField.text?.removeAllSapce ?? ""
        if phoneStr.count > 11 || phoneStr.removeAllSapce.count == 0 {
            CODProgressHUD.showErrorWithStatus("请输入正确的手机号码")
            return
        }
        if codeStr.count < 4 {
            if codeStr.count <= 0 {
                CODProgressHUD.showErrorWithStatus("请输入验证码")
                return
            }
            CODProgressHUD.showErrorWithStatus("验证码输入错误")
            return
        }

        HttpManager().post(url: requestUrl, param: ["areaCode":areaCode,"tel":phoneStr,"code":codeStr], successBlock: {[weak self] (result, json) in
//            CODProgressHUD.showSuccessWithStatus("login success")
            CODUserDefaults.set(self?.phoneField.text, forKey: LAST_PHONE_LOGIN)
            UserManager.sharedInstance.getUserSuccess(json)
            UserManager.sharedInstance.phoneNum = phoneStr
            NotificationCenter.default.post(name: NSNotification.Name.init(kGetUserSuccessNoti), object: nil, userInfo: nil)
            
        }) {[weak self] (error) in
            if error.code == 10031 {
            
                CODProgressHUD.showErrorWithStatus("因涉嫌违规或被用户投诉，您的账号已被冻结")
            }else if (error.code == 10056) {
                
                self?.stopTimeDown()
                CODProgressHUD.showErrorWithStatus(error.message)
            }else if (error.code == 10066) {
                
                CODProgressHUD.showErrorWithStatus("帐号不存在，如需开通请联系管理员")
            }else{
                
                CODProgressHUD.showErrorWithStatus(error.message)
            }
        }
    }
    
    func stopTimeDown() {
        self.timer?.cancel()
        self.codeField.text = ""
        self.getCodeBtn.setTitle("重新获取验证码", for: UIControl.State.normal)
        self.getCodeBtn.isUserInteractionEnabled = true
        self.getCodeBtn.isEnabled = true
    }
    
    @IBAction func passwordLogin(_ sender: UIButton) {
        
        self.navigationController?.pushViewController(PasswordLoginViewController(), animated: true)
    }
    
    @IBAction func showUserProtocol(_ sender: UIButton) {

//        userVC.urlString = COD_Agreement_URL
        let langString = CustomUtil.getLangString()
        let userVC = CODGenericWebVC()
        userVC.urlString = COD_Agreement_URL + "?lang=\(langString)"
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    func configYYLabelText(text:String) {
        
        if self.voiceCodeLabel.attributedText?.string == NSLocalizedString("我们正在拨打您的电话，请注意接听...", comment: "") {
            return
        }
        
        let attText = NSMutableAttributedString.init(string: text)
        let string = text as NSString
        attText.yy_setTextHighlight(string.range(of: NSLocalizedString("语音接听验证码", comment: "")), color: UIColor.init(hexString: "#047EF5"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3)) { [weak self] (containerView, text, range, rect) in

            guard let `self` = self else { return }
            self.sendVoiceCode()
            
        }
        self.voiceCodeLabel.attributedText = attText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        
        
        self.setRightButton()
        self.rightButton.setImage(UIImage(named: "changeip_icon"), for: .normal)
        
        
        self.welcomeLab.text = CustomUtil.formatterStringWithAppName(str: "欢迎来到%@")
        
        if let phoneString = CODUserDefaults.value(forKey: LAST_PHONE_LOGIN) as? String{
            self.phoneField.text = phoneString
            self.codeField.becomeFirstResponder()
        }
        
        if UserManager.sharedInstance.countryName != ""{
            self.countryInfoLab.text = "\(UserManager.sharedInstance.countryName ?? "")(+\(UserManager.sharedInstance.areaNum ?? ""))"
            self.areaCode = UserManager.sharedInstance.areaNum ?? "86"
        }
        
        voiceCodeLabel.text = ""
        voiceCodeLabel.preferredMaxLayoutWidth = KScreenWidth - 44
    }
    
    override func navRightClick() {
        self.view.endEditing(true)
        let selectServersView = Bundle.main.loadNibNamed("SelectServersView", owner: self, options: nil)?.first as! SelectServersView
        selectServersView.show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CODFileManager.shareInstanceManger().documentPath = nil
    }

    override var shouldAutorotate: Bool{
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
}
