//
//  CODTextFieldBaseViewController.swift
//  COD
//
//  Created by XinHoo on 2019/4/10.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODTextFieldBaseViewController: BaseViewController {
    
    var chatID: Int? = nil
    var titleStr: String? = nil
    var tipsStr: String? = nil
    var fieldPlaceholder: String? = nil
    var defaultText :String? = nil
    weak var delegate: CODTextFieldVCDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = titleStr
        self.setBackButton()
        self.setRightTextButton()
        self.rightTextButton.setTitle("完成", for: UIControl.State.normal)
        
        
        self.addSubView()
        self.addSubViewContrains()
        if let defaultText = self.defaultText {
            self.textField.text = defaultText
        }
    }
    
    func addSubView() {
        self.view.addSubview(tipsLabel)
        self.view.addSubview(fieldBgView)
        fieldBgView.addSubview(textField)
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
        
        textField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
    }
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.text = tipsStr
        label.textColor = UIColor(hexString: kSubTitleColors)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var fieldBgView: UIView = {
        let bgv = UIView()
        bgv.backgroundColor = UIColor.white
        return bgv
    }()
    
    lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = fieldPlaceholder
        field.clearButtonMode = UITextField.ViewMode.always
        field.font = UIFont.systemFont(ofSize: 16)
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
    
}


