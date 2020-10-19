//
//  CODSetMailViewController.swift
//  COD
//
//  Created by XinHoo on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework

class CODSetMailViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("邮箱", comment: "")
        self.setBackButton()
        
        self.setRightTextButton()
        self.rightTextButton.setTitle("完成", for: UIControl.State.normal)
        
        self.addSubView()
        self.addSubViewContrains()
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    func addSubView() {
        self.view.addSubview(fieldBgView)
        fieldBgView.addSubview(mailField)
    }
    
    func addSubViewContrains() {
        
        fieldBgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(45)
        }
        
        mailField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
    }
    
    override func navRightTextClick() {
        guard CODWebRTCManager.whetherConnectedNetwork() else {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        
        guard var mail = mailField.text else{
            CODProgressHUD.showErrorWithStatus("请输入新的邮箱地址")
            return
        }
        
        if mail == UserManager.sharedInstance.email { //没改变原内容，不需要发送iq
            self.navigationController?.popViewController(animated: true)
            return
        }
        
//        CODProgressHUD.showWithStatus(nil)
        

        mail = mail.removeHeadAndTailSpacePro
        if mail.count <= 0 {
            CODProgressHUD.showErrorWithStatus("请输入新的邮箱地址")
            return
        }
        
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
        let res = regex.matches(in: mail, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, mail.count))
        if res.count == 0 {
            CODProgressHUD.showErrorWithStatus("请输入正确的邮箱地址")
            return
        }
        
        let paramDic = ["name":COD_changePerson,"requester":"\(UserManager.sharedInstance.jid)","setting":["email": mail]] as [String : Any]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: paramDic as NSDictionary)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    lazy var fieldBgView: UIView = {
        let bgv = UIView()
        bgv.backgroundColor = UIColor.white
        return bgv
    }()
    
    lazy var mailField: UITextField = {
        let field = UITextField()
        field.delegate = self
        field.placeholder = "邮箱"
        field.clearButtonMode = UITextField.ViewMode.always
        field.font = UIFont.systemFont(ofSize: 16)
        field.keyboardType = .numbersAndPunctuation
        field.addTarget(self, action: #selector(self.changedTextField(_:)), for: UIControl.Event.editingChanged)
        if let mail = UserManager.sharedInstance.email , mail != "未设置"{
            field.text = mail
        }
        return field
    }()

}

extension CODSetMailViewController:UITextFieldDelegate{
    
    @objc func changedTextField(_ textField: UITextField) {
       
        if textField.text?.count ?? 0 > 32 {
            textField.text = textField.text?.subStringToIndex(32)
        }
    }
  
}

extension CODSetMailViewController: XMPPStreamDelegate {
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            if (actionDict["name"] as? String == COD_changePerson){
                if let success = infoDict["success"] as? Bool {
                    if success {
                        
                        if let userinfo = actionDict["setting"] as? Dictionary<String,Any> {
                            UserManager.sharedInstance.userInfoSetting = CODUserInfoAndSetting.deserialize(from: userinfo)!
                        }
//                        CODProgressHUD.showSuccessWithStatus("设置成功")
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        if let code = infoDict["code"] as? Int {
                            switch code {
                                
                            default: break
                            }
                        }
                    }
                }
            }
        }
        
        return true
    }
}
