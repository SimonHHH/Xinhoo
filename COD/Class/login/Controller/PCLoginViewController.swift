//
//  PCLoginViewController.swift
//  COD
//
//  Created by Xinhoo on 2019/5/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

class PCLoginViewController: UIViewController {
    var qrCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
}

extension PCLoginViewController{
    
    func setUpUI() {
        let blurEffect = UIBlurEffect.init(style: .extraLight)
        let viewEffect = createBlurEffectView(blurEffect: blurEffect)
        self.view.addSubview(viewEffect)
        viewEffect.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }
        
        let btnClose = createCloseBtn()
        self.view.addSubview(btnClose)
        btnClose.snp.makeConstraints { (make) in
            make.width.equalTo(66)
            make.height.equalTo(24)
            make.left.equalTo(self.view).inset(0)
            make.top.equalTo(self.view).inset(kSafeArea_Top + 30)
        }
        
        let imgView = createPCImageView()
        self.view.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.width.equalTo(144)
            make.height.equalTo(144)
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).inset(kSafeArea_Top + 108)
        }
        
        let lblMsg = createMsgLable()
        self.view.addSubview(lblMsg)
        lblMsg.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(24)
            make.centerX.equalTo(self.view)
            make.top.equalTo(imgView.snp.bottom).offset(6)
        }
        
//        let btnSyncMsg = createSyncMsgButton()
//        self.view.addSubview(btnSyncMsg)
//        btnSyncMsg.snp.makeConstraints { (make) in
//            make.width.equalTo(125)
//            make.height.equalTo(15)
//            make.centerX.equalTo(self.view)
//            make.top.equalTo(lblMsg.snp.bottom).offset(14)
//        }
        
        let btnLogin = createLoginButton()
        self.view.addSubview(btnLogin)
        btnLogin.snp.makeConstraints { (make) in
            make.width.equalTo(193)
            make.height.equalTo(43)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).inset(111+kSafeArea_Bottom)
        }
        
        let btnCancelLogin = createCancelLoginButton()
        self.view.addSubview(btnCancelLogin)
        btnCancelLogin.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(24)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).inset(48+kSafeArea_Bottom)
        }
    }
    
    func createBlurEffectView(blurEffect: UIBlurEffect) -> UIVisualEffectView {
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        
        return blurEffectView
    }
    
    func createCloseBtn() -> UIButton {
        let btnClose = UIButton(type: .custom)
//        btnClose.contentHorizontalAlignment = .left;
        btnClose.setTitle("关闭", for: UIControl.State.normal)
        btnClose.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btnClose.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: UIControl.State.normal)
        btnClose.addTarget(self, action: #selector(btnCloseClicked), for: UIControl.Event.touchUpInside)
        
        return btnClose;
    }
    
    func createPCImageView() -> UIImageView {
        let imgView = UIImageView.init(image: UIImage.init(named: "mac_icon"))
        return imgView
    }
    
    func createMsgLable() -> UILabel {
//        let lblMsg = UILabel.init(text: CustomUtil.formatterStringWithAppName(str: "%@登录确认"))
        let lblMsg = UILabel.init(text: "桌面版登录确认")
        lblMsg.textAlignment = .center
        lblMsg.font = UIFont.boldSystemFont(ofSize: 17)
        lblMsg.textColor = UIColor.init(hexString: "#000000")
        return lblMsg;
    }
    
    func createSyncMsgButton() -> UIButton {
        let btnSyncMsg = UIButton(type: .custom)
        btnSyncMsg.setImage(UIImage.init(named: "sync_msg_un_selected_icon"), for: UIControl.State.normal)
        btnSyncMsg.setImage(UIImage.init(named: "sync_msg_selected_icon"), for: UIControl.State.selected)
        btnSyncMsg.setTitle("自动同步消息", for: UIControl.State.normal)
        btnSyncMsg.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btnSyncMsg.setTitleColor(UIColor.init(hexString: kEmptyTitleColorS), for: UIControl.State.normal)
        btnSyncMsg.addTarget(self, action: #selector(btnSyncMsgClicked), for: UIControl.Event.touchUpInside)
        btnSyncMsg.centerTextAndImage(spacing: 15)
        
        return btnSyncMsg;
    }
    
    func createLoginButton() -> UIButton {
        let btnLogin = UIButton(type: .custom)
        btnLogin.clipsToBounds = true;
        btnLogin.layer.cornerRadius = 2;
        btnLogin.layer.borderColor = UIColor.clear.cgColor;
//        btnLogin.setBackgroundImage(UIImage.imageFromColor(color: UIColor(red: 0, green: 0.49, blue: 0.9, alpha: 1), viewSize: CGSize(width: 180, height: 41)), for: UIControl.State.normal)
        btnLogin.backgroundColor = UIColor(red: 0, green: 0.49, blue: 0.9, alpha: 1);
        btnLogin.setTitle("登录", for: UIControl.State.normal)
        btnLogin.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        btnLogin.setTitleColor(UIColor.init(hexString: "#FFFFFF"), for: UIControl.State.normal)
        btnLogin.addTarget(self, action: #selector(btnLoginClicked), for: UIControl.Event.touchUpInside)
        
        return btnLogin;
    }
    
    func createCancelLoginButton() -> UIButton {
        let btnCancelLogin = UIButton(type: .custom)
        btnCancelLogin.setTitle("取消登录", for: UIControl.State.normal)
        btnCancelLogin.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btnCancelLogin.setTitleColor(UIColor.init(hexString: "#999999"), for: UIControl.State.normal)
        btnCancelLogin.addTarget(self, action: #selector(btnCancelLoginClicked), for: UIControl.Event.touchUpInside)
        return btnCancelLogin;
    }
}

//ACTION
extension PCLoginViewController {
    
    @objc func btnCloseClicked() {
        self.dismiss(animated: true) {
            self.presentedViewController?.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    @objc func btnSyncMsgClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc func btnLoginClicked(sender: UIButton) {
        CODProgressHUD.showWithStatus("正在请求")
        HttpManager.share.postWithUserInfo(url: HttpConfig.COD_QRcode_ValidQRcodeUrl, param: ["qrCode":qrCode,"bindUser":true], successBlock: {[weak self] (success, json) in
            CODProgressHUD.showSuccessWithStatus("登录成功")
            self?.perform(#selector(self?.btnCloseClicked), with: nil, afterDelay: 1)
        }) { [weak self] (error) in
//            CODProgressHUD.showErrorWithStatus("\(error.message)")
//            CODProgressHUD.showErrorWithStatus("登录失败")
            CODProgressHUD.dismiss()
            var errorString = ""

            if error.code == 10013 {
                errorString = "二维码已失效，请刷新二维码重新扫描"
            }else{
                errorString = error.message
            }
            if errorString.removeAllSapce.count > 0 {
                
                let alertController = UIAlertController(title: nil, message:errorString, preferredStyle: UIAlertController.Style.alert)

                let alertAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) {[weak self] (alertAction) in
                    self?.btnCloseClicked()
                }
                alertController.addAction(alertAction)
                self?.present(alertController, animated: true, completion: nil)
            }
            
        }
     
    }
    
    func toRootViewController() {

        if let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            if self.presentingViewController != nil {
                
                self.presentingViewController?.view.alpha = 0
                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                    
                    if let vcArray = tabBarVC.selectedViewController?.children {
                        for vc in vcArray {
                            if let baseVC = vc as? BaseViewController {
                                baseVC.navBackClick()
                            }
                        }
                    }
                })

            }
            
        }
        
    }
    
    @objc func btnCancelLoginClicked() {
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            self.perform(#selector(self.btnCloseClicked), with: nil, afterDelay: 1)
            return
        }
        
        CODProgressHUD.showWithStatus("正在请求")
        HttpManager.share.postWithUserInfo(url: HttpConfig.COD_QRcode_ValidQRcodeUrl, param: ["qrCode":qrCode,"cancel":3], successBlock: {[weak self] (success, json) in
            
            CODProgressHUD.showSuccessWithStatus("取消登录成功")
            self?.perform(#selector(self?.btnCloseClicked), with: nil, afterDelay: 1)
            
        }) { [weak self] (error) in

            CODProgressHUD.dismiss()
            var errorString = ""

            if error.code == 10013 {
                errorString = "二维码已失效，请刷新二维码重新扫描"
            }else{
                errorString = error.message
            }
            if errorString.removeAllSapce.count == 0 {
                errorString = "取消登录失败"
            }

            let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: UIAlertController.Style.alert)

            let alertAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) {[weak self] (alertAction) in
                self?.btnCloseClicked()
            }
            alertController.addAction(alertAction)
            self?.present(alertController, animated: true, completion: nil)
        }

    }
    
}

