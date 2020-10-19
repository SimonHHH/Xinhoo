//
//  CODValidCurrentPhoneViewController.swift
//  COD
//
//  Created by XinHoo on 2019/9/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODValidCurrentPhoneViewController: BaseViewController {
    
    var phoneNum: String! = UserManager.sharedInstance.phoneNum
    var areaCode :String! = UserManager.sharedInstance.areaNum
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("手机验证码", comment: "")
        self.setBackButton()
        
        self.setRightTextButton()
        self.rightTextButton.setTitle(NSLocalizedString("下一步", comment: ""), for: UIControl.State.normal)
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.addSubView()
        self.addSubViewContrains()
    }
    
    func addSubView() {
        self.view.addSubview(tipsLab)
        self.view.addSubview(fieldBgView)
        fieldBgView.addSubview(codeField)
        fieldBgView.addSubview(lineView)
        fieldBgView.addSubview(getCodeBtn)
        fieldBgView.addSubview(topLine)
        fieldBgView.addSubview(bottomLine)
    }
    
    func addSubViewContrains() {
        tipsLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
//            make.height.equalTo(14)
        }
        
        fieldBgView.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLab.snp.bottom).offset(23)
            make.left.right.equalToSuperview()
            make.height.equalTo(45)
        }
        
        codeField.snp.makeConstraints { (make) in
            make.centerY.equalTo(fieldBgView)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-135)
            make.height.equalTo(20)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.centerY.equalTo(fieldBgView)
            make.left.equalTo(codeField.snp.right).offset(2)
            make.width.equalTo(1)
            make.height.equalTo(18)
        }
        
        getCodeBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(fieldBgView)
            make.left.equalTo(lineView.snp.right).offset(2)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    override func navRightTextClick() {
        CODProgressHUD.showWithStatus(nil)

        let codeStr = codeField.text

        guard let code = codeStr else {
            CODProgressHUD.showErrorWithStatus(NSLocalizedString("请输入您的验证码", comment: ""))
            return
        }

        let param = ["areaCode":areaCode,"tel":phoneNum,"code":code]

        HttpManager.share.post(url: HttpConfig.checkCodeUrl, param: param, successBlock: { [weak self] (result, jsonResult) in
            guard let self = self else {
                return
            }

            let ctl = CODInputNewPhoneController()
            self.navigationController?.pushViewController(ctl, animated: true)

        }) { (error) in
            if error.code == 10031 {

                CODProgressHUD.showErrorWithStatus("因涉嫌违规或被用户投诉，您的账号已被冻结")
            } else {

                CODProgressHUD.showErrorWithStatus(error.message)
            }
        }
    }

    
    @objc func getCode(_ sender :UIButton) {
        
        CODProgressHUD.showWithStatus(nil)
        sender.isEnabled = false
        guard let areaCode = areaCode else {
            CODProgressHUD.showErrorWithStatus("请选择国家地区")
            return
        }
        guard areaCode.count > 0 else {
            CODProgressHUD.showErrorWithStatus("请选择国家地区")
            return
        }
        
        guard let phoneNum = phoneNum else {
            CODProgressHUD.showErrorWithStatus("请输入手机号码")
            return
        }
        guard phoneNum.count > 0 else {
            CODProgressHUD.showErrorWithStatus("请输入手机号码")
            return
        }
        
        let requestUrl = HttpConfig.getSMSCodeUrl
        weak var weakSelf = self
        HttpManager().post(url: requestUrl, param: ["areaCode":areaCode,"tel":phoneNum], successBlock: { (result, json) in
            sender.isEnabled = true
            weakSelf?.startTimeDown(sender: sender)
            CODProgressHUD.showSuccessWithStatus("成功获取验证码")
            weakSelf?.codeField.becomeFirstResponder()
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
            default:
                if error.message.count > 0 {
                    CODProgressHUD.showErrorWithStatus(error.message)
                } else {
                    CODProgressHUD.showErrorWithStatus("网络异常")
                }
            }
        }
    }
    
//    func requestIQForChangePhone() {
//        let paramDic = ["name":COD_changePerson,"requester":"\(UserManager.sharedInstance.jid)","setting":["tel": phoneNum, "areacode": areaCode]] as [String : Any]
//        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: paramDic as NSDictionary)
//        XMPPManager.shareXMPPManager.xmppStream.send(iq)
//    }
    
    
    lazy var tipsLab: UILabel = {
        let lab = UILabel()
        if let phoneStr = self.phoneNum {
            let midCount = phoneStr.count/2
            if midCount > 2 {
                let subStrPhone1 = (phoneStr as NSString).substring(to: midCount-2)
                let subStrPhone2 = (phoneStr as NSString).substring(from: midCount+2)
                lab.text = String(format: NSLocalizedString("请输入手机+%@ %@****%@收到的验证码", comment: ""), self.areaCode ?? "86",subStrPhone1,subStrPhone2)
            }else{
                lab.text = String(format: NSLocalizedString("请输入手机+%@ %@收到的验证码", comment: ""), self.areaCode ?? "86",phoneStr)
            }
        }
        
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var fieldBgView: UIView = {
        let bgv = UIView()
        bgv.backgroundColor = UIColor.white
        return bgv
    }()
    
    lazy var codeField: UITextField = {
        let field = UITextField()
        field.placeholder = "验证码"
        field.font = UIFont.systemFont(ofSize: 15)
        return field
    }()
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kSepLineColorS)
        return line
    }()
    
    lazy var topLine: UIView = {
        let line = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 0.5))
        line.backgroundColor = UIColor(hexString: kSepLineColorS)
        return line
    }()
    
    lazy var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kSepLineColorS)
        return line
    }()
    
    lazy var getCodeBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle("获取验证码", for: UIControl.State.normal)
        btn.setTitleColor(UIColor(hexString: kSubmitBtnBgColorS), for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(self.getCode(_:)), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
//    lazy var submitBtn: UIButton = {
//        let btn = UIButton(type: UIButton.ButtonType.custom)
//        btn.setTitle("确定更换", for: UIControl.State.normal)
//        btn.backgroundColor = UIColor(hexString: kSubmitBtnBgColorS)
//        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
//        btn.layer.cornerRadius = kCornerRadius
//        btn.clipsToBounds = true
//        btn.addTarget(self, action: #selector(self.nextStepClick(_:)), for: UIControl.Event.touchUpInside)
//        return btn
//    }()
}

extension CODValidCurrentPhoneViewController: XMPPStreamDelegate {
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        CustomUtil.analyticxXML(iq: iq) { (actionDic, infoDic) in
            guard let infoDic = infoDic else {
                return
            }
            
            if (actionDic["name"] as? String == COD_changePerson){
                
                if !(infoDic["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus(infoDic["msg"] as? String ?? "设置失败！")
                }else{
                    let dict = actionDic["setting"] as! NSDictionary
                    if (dict["tel"] as? String) != nil && dict["areacode"] as? String != nil {
                        CODProgressHUD.dismiss()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
            
        }
        return true
    }
}
