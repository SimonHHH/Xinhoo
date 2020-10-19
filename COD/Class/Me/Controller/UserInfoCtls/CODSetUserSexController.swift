//
//  CODSetUserSexController.swift
//  COD
//
//  Created by XinHoo on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework

class CODSetUserSexController: BaseViewController {
    
    var gender = UserManager.sharedInstance.sex
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("性别", comment: "")
        self.setBackButton()
        
        self.addSubView()
        self.addSubViewContrains()
        
        if gender.count > 0 {
            if gender == "男" {
                self.isMale(true)
            }else{
                self.isMale(false)
            }
        }
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    @objc func tickMale() {
        self.isMale(true)
        self.submitData(true)
    }
    
    @objc func tickFemale() {
        self.isMale(false)
        self.submitData(false)
    }
    
    func isMale(_ bool :Bool) {
        maleTick.isHidden = !bool
        femaleTick.isHidden = bool
    }
    
    func submitData(_ isMale :Bool) {
        guard CODWebRTCManager.whetherConnectedNetwork() else {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        var genderStr: String = ""
        
        if (isMale == true && self.gender == "男") || (isMale == false && self.gender == "女") {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
//        CODProgressHUD.showWithStatus(nil)
        
        if isMale {
            genderStr = "MALE"
        }else{
            genderStr = "FEMALE"
        }
        
        let paramDic = ["name":COD_changePerson,"requester":"\(UserManager.sharedInstance.jid)","setting":["gender": genderStr]] as [String : Any]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: paramDic as NSDictionary)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func addSubView() {
        self.view.addSubview(backgroundView)
        maleView.addSubview(topLine)
        backgroundView.addSubview(maleView)
        maleView.addSubview(maleLab)
        maleView.addSubview(maleTick)
        maleView.addSubview(lineView)
        backgroundView.addSubview(femaleView)
        backgroundView.addSubview(bottomLine)

        femaleView.addSubview(femaleLab)
        femaleView.addSubview(femaleTick)
    }
    
    func addSubViewContrains() {
        backgroundView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(21)
            make.left.right.equalToSuperview()
            make.height.equalTo(87)
        }
        topLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(backgroundView)
        }
        
        maleView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(43.5)
        }
        
        maleLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.size.equalTo(50)
        }
        
        maleTick.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(13)
            make.height.equalTo(11)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalTo(backgroundView)
        }
        
        femaleView.snp.makeConstraints { (make) in
            make.top.equalTo(maleView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        femaleLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.size.equalTo(50)
        }
        
        femaleTick.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(13)
            make.height.equalTo(11)
        }
    }
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var maleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tickMale))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var maleLab: UILabel = {
        let lab = UILabel()
        lab.text = "男"
        lab.font = UIFont.systemFont(ofSize: 16)
        return lab
    }()
    
    lazy var maleTick: UIImageView = {
        let tick = UIImageView()
        tick.image = UIImage(named: "tick_icon")
        return tick
    }()
    
    lazy var femaleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tickFemale))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var femaleLab: UILabel = {
        let lab = UILabel()
        lab.text = "女"
        lab.font = UIFont.systemFont(ofSize: 16)
        return lab
    }()
    
    lazy var femaleTick: UIImageView = {
        let tick = UIImageView()
        tick.image = UIImage(named: "tick_icon")
        tick.isHidden = true
        return tick
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
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return line
    }()
    

}

extension CODSetUserSexController: XMPPStreamDelegate {
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            if (actionDict["name"] as? String == COD_changePerson){
                if let success = infoDict["success"] as? Bool {
                    if success {
                        
//                        if let userinfo = actionDict["setting"] as? Dictionary<String,Any> {
//                            UserManager.sharedInstance.userInfoSetting = CODUserInfoAndSetting.deserialize(from: userinfo)!
//                        }
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


