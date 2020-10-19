//
//  ForgetPwThirdViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class ForgetPwThirdViewController: BaseViewController {
    
    var phoneStr :String?
    var areaCode :String?
    

    @IBOutlet weak var subTitleLab: UILabel!
    
    @IBOutlet weak var codeField: UITextField!
    
    @IBOutlet weak var getCodeBtn: UIButton!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var requestCompleted = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.requestCompleted {
            CODProgressHUD.showWithStatus(nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("设置登录密码", comment: "")
        self.setBackButton()
        guard phoneStr != nil else {
            return
        }
//        let subStrPhone1 = (phoneStr! as NSString).substring(to: 3)
//        let subStrPhone2 = (phoneStr! as NSString).substring(from: 7)
//        subTitleLab.text = "请输入手机 \(phoneStr ?? <#default value#>) 收到的验证码"
        subTitleLab.text = String(format: NSLocalizedString("请输入手机 %@ 收到的验证码", comment: ""), phoneStr ?? "")
        
        self.getCode(getCodeBtn)
        
    }
//
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func getCode(_ sender: UIButton) {
        CODProgressHUD.showWithStatus(nil)
        let requestUrl = HttpConfig.resetSMSCodeUrl
        HttpManager().post(url: requestUrl, param: ["areaCode":areaCode!,"tel":phoneStr!], successBlock: { [weak self] (result, json) in
            guard let self = self else { return }
            self.requestCompleted = true
            self.startTimeDown(sender: sender)
            CODProgressHUD.showSuccessWithStatus("成功获取验证码")
            self.codeField.becomeFirstResponder()
        }) { [weak self] (error) in
            guard let self = self else { return }
            self.requestCompleted = true
            sender.isUserInteractionEnabled = true
            switch error.code {
            case 10007:
                CODProgressHUD.showErrorWithStatus("手机号码未注册")
            case 10043:
                CODProgressHUD.showErrorWithStatus("非法手机号码")
            case 10044:
                CODProgressHUD.showErrorWithStatus("短信服务器异常")
            case 10045:
                CODProgressHUD.showErrorWithStatus("该手机号码发送短信太频繁")
            default:
                CODProgressHUD.showErrorWithStatus(error.message)
            }
            
            
        }
    }
    
    @IBAction func nextStep(_ sender: Any) {
        CODProgressHUD.showWithStatus(nil)
        
        let codeStr = codeField.text
        let param = ["areaCode":areaCode,"tel":phoneStr,"code":codeStr] as! [String : String]
        
        HttpManager.share.post(url: HttpConfig.checkCodeUrl, param: param, successBlock: { [weak self] (result, jsonResult) in
            CODProgressHUD.dismiss()
            guard let self = self else { return }
            let ctl = SettingPwViewController()
            ctl.phoneStr = self.phoneStr
            ctl.areaCode = self.areaCode
            
            if let password = result["password"] {
                ctl.originalPW = password as? String
            }
            self.navigationController?.pushViewController(ctl, animated: true)
            
        }) { (error) in
            if error.code == 10031 {
            
                CODProgressHUD.showErrorWithStatus("因涉嫌违规或被用户投诉，您的账号已被冻结")
            }else{
                
                CODProgressHUD.showErrorWithStatus(error.message)
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
