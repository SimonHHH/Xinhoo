//
//  CODInputNewPhoneController.swift
//  COD
//
//  Created by XinHoo on 2019/3/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODInputNewPhoneController: BaseViewController {
    
    var areaStr:String = UserManager.sharedInstance.areaNum!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("更改号码", comment: "")
        self.setBackButton()
        
        self.addSubView()
        self.addSubViewContrains()
        
    }
    
    @objc func showAreaList() {
        //选择国家和地区
        let vc = CODCountryCodeViewController.init(nibName: "CODCountryCodeViewController", bundle: Bundle.main)
        vc.selectBlock = { (model) in
            
            self.areaLab.text = "\(model.name)(+\(model.phonecode))"
            self.areaStr = model.phonecode
        }
        self.navigationController?.pushViewController(vc)
    }
    
    @objc func nextStepClick(_ sender :UIButton) {
        guard let num = phoneField.text else {
            CODProgressHUD.showErrorWithStatus("请输入新的手机号码")
            return
        }
        guard num != UserManager.sharedInstance.phoneNum || self.areaStr != UserManager.sharedInstance.areaNum else {
            CODProgressHUD.showErrorWithStatus("请输入与本账号不同的手机号码")
            return
        }
        
        let ctl = CODValidCodeController()
        ctl.areaCode = self.areaStr
        ctl.phoneNum = num
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
    func addSubView() {
        self.view.addSubview(tipsLabel1)
        self.view.addSubview(tipsLabel2)
        
        self.view.addSubview(fieldBgView)
        
        fieldBgView.addSubview(areaBgView)
        areaBgView.addSubview(areaLab)
        areaBgView.addSubview(arrowView)
        areaBgView.addSubview(lineView)
        
        fieldBgView.addSubview(phoneField)
        
        fieldBgView.addSubview(topLine)
        fieldBgView.addSubview(bottomLine)
        
        self.view.addSubview(submitBtn)
    }
    
    func addSubViewContrains() {
        tipsLabel1.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(13)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(15)
        }
        
        tipsLabel2.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel1.snp.bottom).offset(9)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(15)
        }
        
        fieldBgView.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel2.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.height.equalTo(87)
        }
        
        areaBgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(41.5)
        }
        
        areaLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-60)
            make.height.equalTo(14)
        }
        
        arrowView.snp.makeConstraints { (make) in
            make.centerY.equalTo(areaLab)
            make.right.equalToSuperview().offset(-18)
            make.width.equalTo(13)
            make.height.equalTo(13)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        phoneField.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(14)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        submitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(fieldBgView.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
        }
        
    }
    
    lazy var tipsLabel1: UILabel = {
        let label = UILabel()
        label.text = "更换手机号码后，下次可使用新手机号码登录"
        label.textColor = UIColor(hexString: kSubTitleColors)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var tipsLabel2: UILabel = {
        let label = UILabel()
        label.text = String.init(format: NSLocalizedString("当前手机号码：+%@ %@", comment: ""), UserManager.sharedInstance.areaNum!,UserManager.sharedInstance.phoneNum!)
        label.textColor = UIColor(hexString: kSubTitleColors)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var fieldBgView: UIView = {
        let bgv = UIView()
        bgv.backgroundColor = UIColor.white
        return bgv
    }()
    
    lazy var areaBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showAreaList))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var areaLab: UILabel = {
        let lab = UILabel()
        lab.text = "中国(China)(+86)"
        lab.font = UIFont.systemFont(ofSize: 14)
        return lab
    }()
    
    lazy var arrowView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "next_step_icon")
        return imgView
    }()
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return line
    }()
    
    lazy var phoneField: UITextField = {
        let field = UITextField()
        field.placeholder = "输入新手机号码"
        field.font = UIFont.systemFont(ofSize: 14)
        return field
    }()
    
    lazy var submitBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle("下一步", for: UIControl.State.normal)
        btn.backgroundColor = UIColor(hexString: kSubmitBtnBgColorS)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.layer.cornerRadius = kCornerRadius
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(self.nextStepClick(_:)), for: UIControl.Event.touchUpInside)
        return btn
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
    
}
