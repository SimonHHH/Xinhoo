//
//  CODChangePhoneController.swift
//  COD
//
//  Created by XinHoo on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

private let phoneImgName = "change_phone"


class CODChangePhoneController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("更换手机号码", comment: "")
        self.setBackButton()
        
        self.addSubView()
        self.addSubViewContrains()
    }
    
    @objc func nextStepClick(_ sender :UIButton) {
        //更改手机号码，先判断是否有设置过密码，没有则引导去设置页面。
        
        let nextCtl = CODValidCurrentPhoneViewController()
        self.navigationController?.pushViewController(nextCtl, animated: true)
    }
    
    func addSubView() {
        self.view.addSubview(phoneView)
        self.view.addSubview(phoneNumLab)
        self.view.addSubview(submitBtn)
        self.view.addSubview(tipsLab)
    }
    
    func addSubViewContrains() {
        phoneView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(59)
            make.centerX.equalToSuperview()
            make.width.equalTo(62)
            make.height.equalTo(111)
        }
        
        phoneNumLab.snp.makeConstraints { (make) in
            make.top.equalTo(phoneView.snp.bottom).offset(36)
            make.left.right.equalToSuperview()
            make.height.equalTo(17)
        }
        
        submitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumLab.snp.bottom).offset(34)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
        }
        
        tipsLab.snp.makeConstraints { (make) in
            make.top.equalTo(submitBtn.snp.bottom).offset(13)
//            make.left.right.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
//            make.height.equalTo(14)
        }
        
    }
    
    lazy var phoneView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: phoneImgName))
        return imgView
    }()
    
    lazy var phoneNumLab: UILabel = {
        let label = UILabel()
        let text = String.init(format: NSLocalizedString("手机号码:+%@ %@", comment: ""), UserManager.sharedInstance.areaNum!,UserManager.sharedInstance.phoneNum!)
        label.text = text
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 18.0)
        return label
    }()
    
    lazy var submitBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle("更换手机号码", for: UIControl.State.normal)
        btn.backgroundColor = UIColor(hexString: kSubmitBtnBgColorS)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.layer.cornerRadius = kCornerRadius
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(self.nextStepClick(_:)), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var tipsLab: UILabel = {
        let label = UILabel()
        let text = "更换手机号码后，登录手机号码将改变"
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textColor = UIColor(hexString: kSubTitleColors)
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        return label
    }()
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
