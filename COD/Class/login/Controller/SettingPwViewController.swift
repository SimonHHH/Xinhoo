//
//  SettingPwViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class SettingPwViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneLab: UILabel!
    
    @IBOutlet weak var passwordField: CODLimitInputNumberTextField!
    
    @IBOutlet weak var confrimPwField: CODLimitInputNumberTextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var avatarView: UIImageView!
    
    var originalPW :String?
    
    
    var areaCode :String?
    var password :String?
    var phoneStr :String?
    var confrimPwStr :String?
    
    var limitInputNumber = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("设置登录密码", comment: "")
        self.setBackButton()
        
        self.phoneLab.text = "+\(areaCode!) \(phoneStr!)"
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: UserManager.sharedInstance.avatar!) { [weak self] (image) in
            guard let self = self else {
                return
            }
            self.avatarView.image = image
        }
        
        passwordField.setInputNumber(number: limitInputNumber)
        confrimPwField.setInputNumber(number: limitInputNumber)
    }
    
    override func navBackClick() {
        super.navBackClick()
        passwordField.delegate = nil
        confrimPwField.delegate = nil
    }

//    "areaCode":”86”,
//    "tel":" 18888888888",
//    "newpassword":" b69aab27f6e034319a06d222113d5deb",
//    "password":" b69aab27f6e034319a06d222113d5deb"

    @IBAction func submit(_ sender: Any) {
        guard let pw = passwordField.text, let conPw = confrimPwField.text else {
            CODProgressHUD.showErrorWithStatus("请输入密码")
            return
        }
        
        if pw.count <= 0 || conPw.count <= 0 {
            CODProgressHUD.showErrorWithStatus("密码不可为空")
            return
        }
        
        guard pw.count >= 6 && pw.count <= 20 else {
            CODProgressHUD.showErrorWithStatus("密码限制6-20位，请重新输入")
            return
        }
        
        guard pw == conPw else {
            CODProgressHUD.showErrorWithStatus("密码输入不一致")
            return
        }
        
        CODProgressHUD.showWithStatus(nil)
        
        let md5Pw = (pw as String).cod_saltMD5()
        
        var originalPassW = ""
        if let pw = originalPW {  //如果有值，就是忘记密码，否则是设置密码
            originalPassW = pw
        }else{
            originalPassW = UserManager.sharedInstance.password!
        }
        
        
        let param = ["areaCode":areaCode,"tel":phoneStr,"password":originalPassW,"newpassword":md5Pw,"type":"1"] as! [String : String]
        
        weak var weakSelf = self
        HttpManager.share.post(url: HttpConfig.resetPasswordUrl, param: param, successBlock: { (result, jsonResult) in
            UserManager.sharedInstance.password = result["password"] as? String ?? ""
            CODProgressHUD.showSuccessWithStatus(result["msg"] as! String)
            weakSelf?.navigationController?.popToRootViewController(animated: true)

        }) { (error) in
//            CODProgressHUD.showErrorWithStatus(error.message)
        }
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
        switch textField.tag {
        case 700:
            password = text
        default:
            confrimPwStr = text
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
