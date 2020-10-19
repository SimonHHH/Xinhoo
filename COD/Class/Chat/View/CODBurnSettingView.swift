//
//  CODBurnSettingView.swift
//  COD
//
//  Created by XinHoo on 2019/5/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODBurnSettingView: UIView {
    
    weak var delegate: BurnSettingDelegate?
    
    var burnDelayDic: Dictionary<String, Any>?
    
    var defaultSelectRow = 0
    
    let dataSource: Array<Dictionary<String, Any>> = [["title":"关闭","burn":0],["title":"即刻焚烧","burn":1],
                                               ["title":"10秒","burn":10],["title":"5分钟","burn":5*60],
                                               ["title":"1小时","burn":60*60],["title":"24小时","burn":24*60*60]]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.backgroundColor = UIColor.black
        self.alpha = 0.2
    }
    
    
    
    lazy var contentView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        return v
    }()
    
    lazy var actionView: UIView = {
        let v = UIView.init()
        v.backgroundColor = UIColor.init(hexString: kDividingLineColorS)
        return v
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.setTitle("取消", for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        btn.setTitleColor(UIColor.init(hexString: kBlueBtnColorS), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(cancel), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var submitBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.setTitle("确定", for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        btn.setTitleColor(UIColor.init(hexString: kBlueBtnColorS), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(submit), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var pickerView: UIPickerView = {
        let view = UIPickerView.init()
        view.delegate = self
        view.dataSource = self
        view.showsSelectionIndicator = true
        view.selectRow(self.defaultSelectRow, inComponent: 0, animated: true)
        return view
    }()
    
    @objc func cancel() {
        self.dismissAlert()
    }
    
    @objc func submit() {
        self.dismissAlert()
        if let delegate = self.delegate, let dic = self.burnDelayDic {
            delegate.didSelectRow(burnDelayDic: dic)
        }
    }

}

extension CODBurnSettingView {
    func showAlert(){
        guard let window = UIApplication.shared.keyWindow else{
            return
        }
        window.addSubview(self)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlert)))
        
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.5
        }
        window.addSubview(contentView)
        contentView.addSubview(actionView)
        actionView.addSubview(cancelBtn)
        actionView.addSubview(submitBtn)
        contentView.addSubview(pickerView)
        
        self.contentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(280)
        }
        
        self.actionView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(44)
        }
        
        self.cancelBtn.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        self.submitBtn.snp.makeConstraints { (make) in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        self.pickerView.snp.makeConstraints { (make) in
            make.top.equalTo(actionView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        
        self.contentView.transform = CGAffineTransform.init(translationX: 0.01, y: KScreenWidth)
        
        UIView.animate(withDuration: 0.1) {
            self.contentView.transform = CGAffineTransform.init(translationX: 0.01, y: 0.01)
        }
        
    }
    
    @objc func dismissAlert() {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.contentView.transform = CGAffineTransform.init(translationX: 0.01, y: KScreenWidth)
            self.contentView.alpha = 0.2
            self.alpha = 0
        }) { (finished:Bool) in
            self.removeFromSuperview()
            self.contentView.removeFromSuperview()
        }
        
    }
}

extension CODBurnSettingView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]["title"] as? String
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 40))
//        view.backgroundColor = UIColor.clear
//        let view1 = self.pickerView.subviews[1]
//        view1.isHidden = true
//        let view2 = self.pickerView.subviews[2]
//        view2.isHidden = true
//        return view
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        burnDelayDic = self.dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60.0
    }
    
}

protocol BurnSettingDelegate: NSObjectProtocol {
    func didSelectRow(burnDelayDic: Dictionary<String, Any>) -> Void
}
