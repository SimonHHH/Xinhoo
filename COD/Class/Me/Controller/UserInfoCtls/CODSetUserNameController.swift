//
//  CODSetUserNameController.swift
//  COD
//
//  Created by XinHoo on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework

class CODSetUserNameController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("用户名", comment: "")
        IQKeyboardManager.shared.enable = false
        self.setBackButton()
        self.setRightTextButton()
        self.rightTextButton.setTitle("完成", for: UIControl.State.normal)
        self.setRightBtnIsEnable(enable: false)
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        if UserManager.sharedInstance.userDesc!.count > 0  {
            userNameField.text = UserManager.sharedInstance.userDesc
            countLabel.text = "\(20 - (userNameField.text?.count ?? 0))"
        }
        self.addSubView()
        self.addSubViewContrains()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        userNameField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    func addSubView() {
        self.view.addSubview(fieldBgView)
        fieldBgView.addSubview(tipsLabel)
        fieldBgView.addSubview(topLine)
        fieldBgView.addSubview(bottomLine)
        fieldBgView.addSubview(userNameField)
        fieldBgView.addSubview(countLabel)
        self.view.addSubview(tipsLabel3)
        self.view.addSubview(tipsLabel2)
    }
    
    func addSubViewContrains() {
        
        
        fieldBgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(32)
            make.left.right.equalToSuperview()
            make.height.equalTo(43)
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(55)
        }
        
        userNameField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(tipsLabel.snp.right).offset(8)
            make.right.equalToSuperview().offset(-42)
            make.height.equalTo(22)
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userNameField.snp.right).offset(6)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalTo(fieldBgView)
        }
        
        tipsLabel3.snp.makeConstraints { (make) in
            make.top.equalTo(fieldBgView.snp.bottom)
            make.height.equalTo(6)  //44 or 6
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        tipsLabel2.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel3.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    override func navRightTextClick() {
        
        if UserManager.sharedInstance.userDesc!.count > 0 && UserManager.sharedInstance.userDesc == userNameField.text?.removeHeadAndTailSpacePro {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        guard CODWebRTCManager.whetherConnectedNetwork() else {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
//        CODProgressHUD.showWithStatus(nil)
        guard var userName = userNameField.text else{
            CODProgressHUD.showWithStatus("请输入新的用户名")
            return
        }
        
        //去掉首尾空格换行
        userName = userName.removeHeadAndTailSpacePro
        if userName.count <= 0 {
            CODProgressHUD.showErrorWithStatus("请输入新的用户名")
            return
        }
        
        let pattern = "^[a-zA-Z][a-zA-Z0-9_]{4,20}$"
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
        let res = regex.matches(in: userName, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, userName.count))
        if res.count == 0 {
            CODProgressHUD.showErrorWithStatus("请输入正确格式的用户名")
            return
        }
        
        
        let paramDic = ["name":COD_changePerson,"requester":"\(UserManager.sharedInstance.jid)","setting":["userdesc": userName]] as [String : Any]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: paramDic as NSDictionary)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        
    }
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.text = "用户名"
        label.textColor = UIColor(hexString: kMainTitleColorS)
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    lazy var fieldBgView: UIView = {
        let bgv = UIView()
        bgv.backgroundColor = UIColor.white
        return bgv
    }()
    
    lazy var topLine: UIView = {
        let view = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: KScreenWidth, height: 0.5))
        view.backgroundColor = UIColor(hexString: kSepLineColorS)
        return view
    }()
    
    lazy var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return line
    }()
    
    lazy var userNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "设置用户名"
        field.clearButtonMode = UITextField.ViewMode.always
        field.keyboardType = .namePhonePad
        field.font = UIFont.systemFont(ofSize: 15)
        field.addTarget(self, action: #selector(myTextDidChange(textField:)), for: UIControl.Event.editingChanged)
        return field
    }()
    
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = "20"
        label.textColor = UIColor(hexString: kSubTitleColors)
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    lazy var tipsLabel3: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        label.textColor = UIColor.red
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var tipsLabel2: UILabel = {
        let label = UILabel()
        label.text = CustomUtil.formatterStringWithAppName(str: "您可以在 %@ 上设置一个用户名。设置后其他人就可以通过用户名(而不是手机号)找到您。\n\n您可以使用a-z/A-Z、0-9以及_,  必须以字母开头，并且至少使用5个字符。")
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: kSubTitleColors)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    
    @objc func myTextDidChange(textField: UITextField) {
        guard var text = textField.text else {
            return
        }
        
        if text.count > 20 {
            textField.text = textField.text?.subStringToIndex(20)
            text = textField.text ?? ""
        }
        
        countLabel.text = "\(20-textField.text!.count)"
        
        //去掉首尾空格换行
        if text.count <= 0 {
            self.setRightBtnIsEnable(enable: false)
            self.setTipsTextStr(str: nil)
            return
        }
        
        let pattern = "[A-Za-z]+"
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
        let res = regex.matches(in: text, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, text.count))
        if res.count == 0 {
            self.setRightBtnIsEnable(enable: false)
            self.setTipsTextStr(str: "用户名必须以字母开头")
            return
        }        
        
        if text.count < 5 {
            self.setRightBtnIsEnable(enable: false)
            self.setTipsTextStr(str: "用户名必须至少包含5个字符")
            return
        }
        
        do {

            let pattern = "^[a-zA-Z][a-zA-Z0-9_]{0,20}$"
            let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
            let res = regex.matches(in: text, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, text.count))
            if res.count == 0 {
                rightTextButton.isUserInteractionEnabled = false
                rightTextButton.isEnabled = false
                self.setTipsTextStr(str: "用户名只允许使用a-z,A-Z,0-9和下划线")
                return
            }
        }
        self.setTipsTextStr(str: nil)
//        self.checkUserName(str: text)
        self.setRightBtnIsEnable(enable: true)
    }
    
    func checkUserName(str: String) {
        self.setTipsTextStr(str: "")
        if UserManager.sharedInstance.userDesc!.count > 0 && UserManager.sharedInstance.userDesc == str {
            return
        }
        if str.count > 0 {
            self.tipsLabel3.textColor = UIColor(hexString: "#047EF5")
            let paramDic = ["name":COD_CheckUserdesc,"requester":"\(UserManager.sharedInstance.jid)","setting":["userdesc": str]] as [String : Any]
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: paramDic as NSDictionary)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
        }
    }
    
    func setTipsTextStr(str: String?,textColor: UIColor = UIColor.red) {
        self.tipsLabel3.textColor = textColor

        if let str = str ,str.count > 0 {
            
            self.tipsLabel3.text = str
            self.tipsLabel3.snp.updateConstraints { (make) in
                make.height.equalTo(44)
            }
        }else{
            self.tipsLabel3.text = ""
            self.tipsLabel3.snp.updateConstraints { (make) in
                make.height.equalTo(6)
            }
        }
    }
    
    func setRightBtnIsEnable(enable:Bool) {
        if enable {
            self.rightTextButton.setTitleColor(UIColor(hexString: kSubmitBtnBgColorS), for: .normal)
        }else{
            self.rightTextButton.setTitleColor(UIColor(hexString: kSubTitleColors), for: .normal)

        }
        self.rightTextButton.isUserInteractionEnabled = enable
        self.rightTextButton.isEnabled = enable
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


extension CODSetUserNameController: XMPPStreamDelegate {
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
                            case 30002:
                                CODProgressHUD.showErrorWithStatus("用户名已存在，请重新输入")
                            case 30009:
                                CODProgressHUD.showErrorWithStatus("用户名不允许以数字开头，请重新输入")
                            case 30063:
                                CODProgressHUD.showErrorWithStatus("修改次数已超过限制")
                            case 30003:
                                CODProgressHUD.showErrorWithStatus("抱歉，系统设定不能修改用户名")
                            default:
                                CODProgressHUD.showErrorWithStatus(infoDict["msg"] as! String)
                                break
                            }
                        }
                    }
                }
            }else if (actionDict["name"] as? String == COD_CheckUserdesc){
                if let success = infoDict["success"] as? Bool {
                    if success {
                        self.setTipsTextStr(str: "此用户名可用",textColor: UIColor(hexString: "#047EF5") ?? UIColor.red)
                    }else{
                        if let code = infoDict["code"] as? Int {
                            switch code {
                            case 30055:
                                self.setTipsTextStr(str: "用户名中不可使用空格")
                            case 30056:
                                self.setTipsTextStr(str: "用户名中不可使用汉字")
                            case 30002:
                                self.setTipsTextStr(str: "此用户名已被占用")
                            default:
                                CODProgressHUD.showErrorWithStatus(infoDict["msg"] as! String)
                                break
                            }
                        }
                    }
                }
            }
        }
        
        return true
    }
}
