//
//  CODVerificationApplicationVC.swift
//  COD
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework

enum SourceType: String {
    case searchType = "search"
    case groupType = "group"
    case qrcodeType = "qrcode"
    case cardType = "card"
}

class CODVerificationApplicationVC: BaseViewController {
    
    var type: SourceType?

    var model = CODChatPersonModel()
    var maxCount = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.rightTextButton.setTitle("发送", for: .normal)
        self.rightTextButton.setTitleColor(UIColor.white, for: .normal)
        self.rightTextButton.backgroundColor = UIColor.init(hexString: "4D9BF1")
        self.rightTextButton.layer.cornerRadius = 4
        self.rightTextButton.layer.masksToBounds = true
        
        self.navigationItem.title = NSLocalizedString("验证申请", comment: "")
        self.setBackButton()
        self.setSendButton()
        
        self.addSubView()
        self.addSubViewContrains()
        
        self.userNameField.text = String(format: "%@ %@", NSLocalizedString("我是", comment: ""),UserManager.sharedInstance.nickname ?? "")
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    func addSubView() {
        self.view.addSubview(tipsLabel)
        self.view.addSubview(fieldBgView)
        fieldBgView.addSubview(userNameField)
        fieldBgView.addSubview(topLine)
        fieldBgView.addSubview(bottomLine)
    }
    
    func addSubViewContrains() {
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(13)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(18)
        }
        
        fieldBgView.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.height.equalTo(45)
        }
        
        topLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(fieldBgView)
        }
        
        bottomLine.snp.makeConstraints { (make) in
             make.left.right.equalToSuperview()
             make.height.equalTo(0.5)
             make.bottom.equalTo(fieldBgView)
         }
        userNameField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
    }
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.text = "你需要发送验证申请，等对方通过"
        label.textColor = UIColor(hexString: kSubTitleColors)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var fieldBgView: UIView = {
        let bgv = UIView()
        bgv.backgroundColor = UIColor.white
        return bgv
    }()
    
    lazy var userNameField: UITextField = {
        let field = UITextField()
        field.placeholder = String(format: NSLocalizedString("验证申请,字数不要超过%ld个哦", comment: ""), maxCount)
        field.clearButtonMode = UITextField.ViewMode.always
        field.font = UIFont.systemFont(ofSize: 16)
        field.delegate = self
        field.addTarget(self, action: #selector(self.changedTextField(_:)), for: UIControl.Event.editingChanged)

        return field
    }()
    
    lazy var topLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return line
    }()
    
    lazy var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return line
    }()
    
    
    
    //点击发送按钮
    override func navRightTextClick() {
        
        let textString = self.userNameField.text?.removeHeadAndTailSpacePro ?? ""
        if textString.count == 0 {
            CODProgressHUD.showWarningWithStatus("验证申请不能为空哦")
            return
        }
        CODProgressHUD.showWithStatus("正在请求")
        var receiver = model.username ?? ""
        if receiver.contains(XMPPSuffix) {
            
        }else{
            receiver = "\(model.username ?? "")\(XMPPSuffix)"
        }
        let paramDic = ["name": COD_AddRoster,
                        "requester": "\(UserManager.sharedInstance.jid)",
            "receiver": receiver,
            "request": ["desc":textString,"addin":self.type?.rawValue]] as [String : Any]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_roster, actionDic: paramDic as NSDictionary)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        
//        XMPPManager.shareXMPPManager.requestAddRoster(tojid: model.username ?? "", desc: textString, success: { [weak self] (model, nameStr) in
//            if nameStr == COD_addRoster {
//                CODProgressHUD.showSuccessWithStatus("已成功")
//                self?.dismissVC()
//            }
//        }) { (model) in
//             CODProgressHUD.showErrorWithStatus("发送失败")
//        }

        
    }

}
extension CODVerificationApplicationVC:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        if let replaced = nsString?.replacingCharacters(in: range, with: string) {
            if textField == self.userNameField {
                if replaced.count <= maxCount {
                    return true
                }
                return false
            }
            return true
        }
        return true
    }
    
    func dismissVC() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
            self.navigationController?.popViewController()
           }
    }
    @objc func changedTextField(_ textField: UITextField) {
        
        if textField.text?.count ?? 0 > maxCount {
            textField.text = textField.text?.subStringToIndex(maxCount)
        }
    }
}

extension CODVerificationApplicationVC: XMPPStreamDelegate {
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) {[weak self] (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            if (actionDict["name"] as? String == COD_AddRoster){
                if let success = infoDict["success"] as? Bool {
                    if success {
                        CODProgressHUD.showSuccessWithStatus("已成功")
                        self?.dismissVC()
                    }else{
                       
                        if let code = infoDict["code"] as? Int {
                            var errorString = ""

                            switch code {
                            case 30016 :
                                //该用户关闭了通过群组添加好友
                                errorString = "对方已在隐私设置修改添加方式，你无法通过群组添加对方"
                            case 30017 :
                                //该用户关闭了通过二维码添加好友
                                errorString = "对方已在隐私设置修改添加方式，你无法通过二维码扫描添加对方"
                            case 30018 :
                                //该用户关闭了通过名片添加好友
                                errorString = "对方已在隐私设置修改添加方式，你无法通过名片添加对方"
                            case 30014 :
                                errorString = "您不能添加自己为好友"
                            case 30005 :
                                errorString = "对方已将你加入黑名单，无法添加好友"
                            case 30007 :
                                errorString = "同一个人每天只能发送三次请求"
                            default:
                                if let codeString = infoDict["msg"] as? String {
                                    errorString = codeString
                                }else{
                                    CODProgressHUD.dismiss()
                                }
                                break
                            }
                            if errorString.removeAllSapce.count > 0 {
                                CODProgressHUD.dismiss()
                                let alertController = UIAlertController(title: nil, message:errorString, preferredStyle: UIAlertController.Style.alert)
                     
                                let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                                let alertAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: nil)
                                alertController.addAction(cancelAction)
                                alertController.addAction(alertAction)
                                self?.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
        
        return true
    }
}
