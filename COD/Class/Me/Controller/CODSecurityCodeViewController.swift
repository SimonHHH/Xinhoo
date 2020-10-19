//
//  CODSecurityCodeViewController.swift
//  COD
//
//  Created by xinhooo on 2019/5/24.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import AdSupport

class CODSecurityCodeViewController: UIViewController {

    @IBOutlet weak var codeBackView: UIView!
    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var topTipLab: UILabel!
    @IBOutlet weak var codeImageView: UIImageView!
    var codeView:SecurityCodeView!
    var errorCount:Int = 0
    
    typealias SuccessDismissBlock = () -> ()
    var dismissBlock: SuccessDismissBlock?
    
    var iqKeyboradEnable = false
    var iqKeyboradShouldResignOnTouchOutside = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.codeView = (Bundle.main.loadNibNamed("SecurityCodeView", owner: self, options: nil)?.last as! SecurityCodeView)
        self.codeView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(codeTFBecomeFirstResponder)))
        self.codeView.inputTextCompeleteBlock = { [weak self](text)  in
            self?.validateSecurityCode(text: text ?? "")
        }
        self.codeBackView.addSubview(self.codeView)
        self.topTipLab.text = CustomUtil.formatterStringWithAppName(str: "请输入%@锁定码")
        #if MANGO
        let img = UIImage(named: "Mango_security_code_logo")
        #elseif PRO
        let img = UIImage(named: "security_code_logo")
        #else
        let img = UIImage(named: "im_security_code_logo")
        #endif
        self.codeImageView.image = img
        
        // Do any additional setup after loading the view.
        
    }

    func validateSecurityCode(text:String) {
        
        let securityCode = UserDefaults.standard.string(forKey: kSecurityCode + UserManager.sharedInstance.loginName!)
        if securityCode == text {
            self.codeView.codeTF.resignFirstResponder()
            self.dismissBlock?()
            self.dismiss(animated: true) {
                
            }
        }else{
            errorCount += 1
            
            if errorCount == 5 {
                
                self.dismiss(animated: false) {
                    CODProgressHUD.showWithStatus(nil)
                    self.logout(clearData: UserDefaults.standard.bool(forKey: kSecurityCode_ClearData + UserManager.sharedInstance.loginName!))
                }
                
            }else{
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate)
                
                let tipText = UserDefaults.standard.bool(forKey: kSecurityCode_ClearData + UserManager.sharedInstance.loginName!) ? String.init(format: NSLocalizedString("密码输入错误%@次，输错5次后，将会清除所有数据！", comment: ""), "\(errorCount)"):String.init(format: NSLocalizedString("密码输入错误%@次", comment: ""), "\(errorCount)")
                
                self.tipLab.text = tipText
                self.tipLab.isHidden = false
                let animation = POPSpringAnimation.init(propertyNamed: kPOPLayerPositionX)
                animation?.velocity = 1000
                animation?.springBounciness = 20
                animation?.springSpeed = 15
                self.tipLab.layer.pop_add(animation, forKey: "")
                animation?.completionBlock = {(anima,finish) in
                    self.codeView.clearInputText()
                }
            }
        }
    }
    
    func logout(clearData:Bool) {
        
        if clearData {
            
            try! Realm.init().write {
                
                try! Realm.init().delete(Realm.init().objects(FileModelInfo.self))
                try! Realm.init().delete(Realm.init().objects(LocationInfo.self))
                try! Realm.init().delete(Realm.init().objects(PhotoModelInfo.self))
                try! Realm.init().delete(Realm.init().objects(VideoCallModelInfo.self))
                try! Realm.init().delete(Realm.init().objects(VideoModelInfo.self))
                try! Realm.init().delete(Realm.init().objects(AudioModelInfo.self))
                try! Realm.init().delete(Realm.init().objects(BusinessCardModelInfo.self))
                
                try! Realm.init().delete(Realm.init().objects(CODMessageModel.self))
                try! Realm.init().delete(Realm.init().objects(CODChatHistoryModel.self))
                try! Realm.init().delete(Realm.init().objects(CODChatListModel.self))
            }
        }
        
        let requestUrl = HttpConfig.logoutPushSession
        HttpManager().post(url: requestUrl, param: ["username":UserManager.sharedInstance.loginName ?? "",
                                                    "deviceID":DeviceInfo.uuidString,
                                                    "token":UserManager.sharedInstance.session ?? ""], successBlock: { (result, json) in
                                                        
                                                        print("======注销session成功")
                                                        UserManager.sharedInstance.userLogout()
        }) { (error) in
            UserManager.sharedInstance.userLogout()
//            CODProgressHUD.showErrorWithStatus(error.message)
        }
    }
    
    @objc func codeTFBecomeFirstResponder() {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        self.codeView.codeTF.becomeFirstResponder()
    }
    
    deinit {
        print("锁屏页面被销毁-----------")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = iqKeyboradEnable
        IQKeyboardManager.shared.shouldResignOnTouchOutside = iqKeyboradShouldResignOnTouchOutside
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        iqKeyboradEnable = IQKeyboardManager.shared.enable
        iqKeyboradShouldResignOnTouchOutside = IQKeyboardManager.shared.shouldResignOnTouchOutside
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        self.codeView.codeTF.becomeFirstResponder()
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
