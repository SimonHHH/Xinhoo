//
//  CODUserIntroVC.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/4.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class CODUserIntroVC: BaseViewController {
    
    @IBOutlet weak var textField: CODLimitInputNumberTextField!
    @IBOutlet weak var countLab: UILabel!
    
    let maxInputNumber = 30
    
    let disposeBag = DisposeBag()
    
    var rightButtonEnable: Observable<Bool> {
        return textFieldCount.map {
            return $0 > 0
        }
    }
    
    var textFieldCount: Observable<Int> {
        return textField.rx.text.map {
            return $0?.count ?? 0
        }
    }
    
    var countLabelTitle: Observable<String> {
        return textFieldCount.map { [weak self] in
            guard let `self` = self else { return "" }
            let count = self.maxInputNumber - $0
            return "\(count > 0 ? count : 0)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.navigationItem.title = NSLocalizedString("个人简介", comment: "")
        
        self.textField.text = UserManager.sharedInstance.intro
        
        self.setRightTextButton()
        self.setBackButton()
        self.rightTextButton.setTitle("完成", for: UIControl.State.normal)
        
        self.textField.setInputNumber(number: 30)

        dataBind()

    }
    
    func dataBind() {
        
        self.rightButtonEnable
            .bind(to: self.rightButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        self.countLabelTitle
            .bind(to: self.countLab.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    
    override func setBackButton() {
        //设置返回按钮
        let backBarButton = UIBarButtonItem.init(customView: self.backButton)
        
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: self, action: #selector(navBackClick))
        negativeSpacer.width = 0
        
        self.navigationItem.leftBarButtonItems = [negativeSpacer,backBarButton]
    }
    
    override func setRightButton() {
        //设置返回按钮
        
        self.rightButton.setTitle(NSLocalizedString("完成", comment: ""), for: .normal)
        self.rightButton.setTitleColor(UIColor(hexString: "#D4D4D4"), for: .disabled)
        self.rightButton.setTitleColor(UIColor(hexString: kSubmitBtnBgColorS), for: .normal)

        let control = UIControl.init(frame: CGRect(origin: .zero, size: rightButton.size))
        control.addTarget(self, action: #selector(navRightClick), for: .touchUpInside)
        
        control.addSubview(self.rightButton)
        self.rightButton.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(1)
            make.width.height.equalTo(38)
        }

        let backBarButton = UIBarButtonItem.init(customView: control)
        
        self.navigationItem.rightBarButtonItem = backBarButton
    }
    
    override func navRightTextClick() {
        
        if UserManager.sharedInstance.intro == self.textField.text {
            self.navigationController?.popViewController()
            return
        }
        
        if self.textField.text?.count ?? 0 > maxInputNumber {
            self.textField.text = self.textField.text?.subStringToIndex(maxInputNumber - 1)
        }
        
        let paramDic = ["name":COD_changePerson,"requester":"\(UserManager.sharedInstance.jid)","setting":["xhabout": self.textField.text ?? ""]] as [String : Any]
        
        
        XMPPManager.shareXMPPManager.setRequest(param: paramDic, xmlns: COD_com_xinhoo_setting_V2) { [weak self] (result) in
            
            guard let `self` = self else { return }
            
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
            
            self.navigationController?.popViewController()
            
        }
        
        
    }
    
}
