//
//  CODInputPasswordController.swift
//  COD
//
//  Created by XinHoo on 2019/3/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODInputPasswordController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("输入登录密码", comment: "")
        self.setBackButton()
        
        self.addSubView()
        self.addSubViewContrains()
        
    }
    
    @objc func nextStepClick(_ sender :UIButton) {
        guard let pw = self.pwField.text else {
            CODProgressHUD.showErrorWithStatus("请输入您的登录密码")
            return
        }
        let password = pw.cod_saltMD5()
        guard password == UserManager.sharedInstance.password else{
            CODProgressHUD.showErrorWithStatus("您输入的登录密码不正确，请重新输入")
            return
        }
        
        let ctl = CODInputNewPhoneController()
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
    func addSubView() {
        self.view.addSubview(fieldBgView)
        fieldBgView.addSubview(pwField)
        self.view.addSubview(submitBtn)
    }
    
    func addSubViewContrains() {
        fieldBgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(45)
        }
        
        pwField.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 20, bottom: 14, right: -20))
        }
        
        submitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(fieldBgView.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
        }
        
    }
    
    lazy var fieldBgView: UIView = {
        let bgv = UIView()
        bgv.backgroundColor = UIColor.white
        return bgv
    }()
    
    lazy var pwField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.placeholder = "请输入登录密码"
        field.font = UIFont.systemFont(ofSize: 16)
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
    
}
