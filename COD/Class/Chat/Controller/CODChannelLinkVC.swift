//
//  CODChannelLinkVC.swift
//  COD
//
//  Created by 1 on 2019/11/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODChannelLinkVC: BaseViewController {

    let preString: String = "noone.ltd/"
    
    fileprivate lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect.zero)
        textField.textColor = UIColor.black
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.backgroundColor = UIColor.white
        textField.placeholder = "链接"
        return textField
    }()
    
    fileprivate lazy var testLabel: UILabel = {
        let testLb = UILabel(frame: CGRect.zero)
        testLb.textColor = UIColor.init(hexString: "#BE3E38")
        testLb.font = UIFont.systemFont(ofSize: 11)
        testLb.text = ""
        testLb.isHidden = true
        return testLb
    }()
    
    fileprivate lazy var tipLabel: UILabel = {
        let tipLb = UILabel(frame: CGRect.zero)
        tipLb.textColor = UIColor.init(hexString: kSectionFooterTextColorS)
        tipLb.font = UIFont.systemFont(ofSize: 11)
        tipLb.text = CustomUtil.formatterStringWithAppName(str: "您可以在%@ 上为频道设置一个n名称，他人能通过该名称找到您的频道。")
        return tipLb
    }()
    
    fileprivate lazy var ruleLabel: UILabel = {
        let ruleLb = UILabel(frame: CGRect.zero)
        ruleLb.textColor = UIColor.init(hexString: kSectionFooterTextColorS)
        ruleLb.font = UIFont.systemFont(ofSize: 11)
        ruleLb.text = NSLocalizedString("您可以使用字母、数字及下划线，最小长度为 5 个字符。", comment: "")
        return ruleLb
    }()
    
    fileprivate lazy var openLinkLabel: UILabel = {
        let openLink = UILabel(frame: CGRect.zero)
        openLink.textColor = UIColor.init(hexString: kSectionFooterTextColorS)
        openLink.font = UIFont.systemFont(ofSize: 11)
        openLink.textAlignment = .center
        openLink.text = CustomUtil.formatterStringWithAppName(str: "此链接可以打开%@ 频道：")
        return openLink
    }()
    
    fileprivate lazy var linkLabel: UILabel = {
        let linkLb = UILabel(frame: CGRect.zero)
        linkLb.textColor = UIColor.init(hexString: kSubmitBtnBgColorS)
        linkLb.font = UIFont.systemFont(ofSize: 11)
        linkLb.textAlignment = .center
        linkLb.text = ""
        return linkLb
    }()
    
    fileprivate lazy var bgView: UIView = {
         let bgView = UIView.init()
         bgView.backgroundColor = UIColor.white
         return bgView
     }()
    
    fileprivate lazy var checkView: UIView = {
         let bgView = UIView.init()
         bgView.backgroundColor = UIColor.clear
        bgView.isHidden = true
         return bgView
     }()
    
    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
         let activeVeiw = UIActivityIndicatorView.init(style: .gray)
         activeVeiw.backgroundColor = UIColor.clear
         activeVeiw.hidesWhenStopped = false
         return activeVeiw
     }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("链接", comment: "")
        self.rightTextButton.setTitle(NSLocalizedString("完成", comment: ""), for: .normal)
        self.setRightTextButton()
        self.setBackButton()
        self.textField.delegate = self
        self.textField.addTarget(self, action: #selector(changedTextField(textField:)), for:.editingChanged)
        self.setupUI()
    }
    
    func setupUI() {
        
        let topLineViwe = UIView.init()
        topLineViwe.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        
        let preLabel = UILabel(frame: CGRect.zero)
        preLabel.textColor = UIColor.black
        preLabel.font = UIFont.systemFont(ofSize: 17)
        preLabel.text = preString;
        
        let bottomLineView = UIView.init()
        bottomLineView.backgroundColor = UIColor.init(hexString: kSepLineColorS)

        self.bgView.addSubviews([topLineViwe,preLabel,bottomLineView,self.textField])
        
        let checkLabel = UILabel(frame: CGRect.zero)
        checkLabel.textColor = UIColor.init(hexString: kSectionFooterTextColorS)
        checkLabel.font = UIFont.systemFont(ofSize: 11)
        checkLabel.text = NSLocalizedString("正在检查名称...", comment: "")
        
        self.checkView.addSubviews([self.activityIndicatorView,checkLabel])
        self.view.addSubview(self.testLabel)
        self.view.addSubviews([bgView,self.checkView,self.testLabel,self.tipLabel,self.ruleLabel,self.openLinkLabel,self.linkLabel])
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(32)
            make.height.equalTo(43.5)
        }
        
        topLineViwe.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(bgView)
            make.height.equalTo(0.5)
        }
        
        bottomLineView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(bgView)
            make.height.equalTo(0.5)
        }
        
        preLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(15)
            make.width.equalTo(81)
            make.centerY.equalTo(bgView)
        }
        
        self.textField.snp.makeConstraints { (make) in
            make.left.equalTo(preLabel.snp.right)
            make.right.equalTo(bgView).offset(-30)
            make.centerY.equalTo(bgView)
        }
        
        self.testLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp.bottom).offset(16)
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-30)
        }
        
        self.checkView.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp.bottom).offset(16)
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-30)
        }
        
        self.activityIndicatorView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.width.equalTo(24)
        }
        
        checkLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.activityIndicatorView.snp.right)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-30)
            make.top.equalTo(bgView.snp.bottom).offset(10)
        }
        
        self.ruleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.tipLabel)
            make.top.equalTo(self.tipLabel.snp.bottom).offset(12)
        }
        
        self.openLinkLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.tipLabel)
            make.top.equalTo(self.ruleLabel.snp.bottom).offset(22)
        }
        
        self.linkLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.tipLabel)
            make.top.equalTo(self.openLinkLabel.snp.bottom).offset(1)
        }
        self.textField.becomeFirstResponder()

    }
    
    @objc func changedTextField(textField: UITextField) {
        if textField.text?.removeAllSapce.count ?? 0 > 0{
            self.testLabel.isHidden = false
            if textField.text?.removeAllSapce.count ?? 0 > 32 {
                self.testLabel.text  = "频道名称字符长度超过最大限制"
                self.testLabel.textColor = UIColor.init(hexString: "#BE3E38")
            }else{
                self.testLabel.text  = (textField.text ?? "") + "可用"
                self.testLabel.textColor = UIColor.init(hexString: "#4B953C")
            }
            self.tipLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(self.view).offset(15)
                make.right.equalTo(self.view).offset(-30)
                make.top.equalTo(self.testLabel.snp.bottom).offset(12)
            }
            self.linkLabel.text = "https:" + preString + textField.text!
        }else{
            self.testLabel.isHidden = true
            self.linkLabel.text = ""
            self.tipLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(self.view).offset(15)
                make.right.equalTo(self.view).offset(-30)
                make.top.equalTo(self.bgView.snp.bottom).offset(9)
            }
        }
        
    }

}

extension CODChannelLinkVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
        
        return true
    }
}
