//
//  CODBrowseCommentsVC.swift
//  COD
//
//  Created by 1 on 2020/5/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODBrowseCommentsVC: UIViewController {
    var messageModel = CODDiscoverMessageModel()
    typealias BackBlock = () -> Void
    var backBlock:BackBlock?
    fileprivate lazy var backButton: UIButton = {
        var backbtn = UIButton.init(type: UIButton.ButtonType.custom)
        backbtn.frame  = CGRect(x: 0, y: 0, width: 70, height: 40)
        backbtn.setImage(UIImage(named: "button_nav_back"), for: UIControl.State.normal)
        backbtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backbtn.setTitle(NSLocalizedString("  ", comment: ""), for: UIControl.State.normal)
        backbtn.setTitleColor(UIColor(hexString: kTabItemSelectedColorS), for: UIControl.State.normal)
        backbtn.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        backbtn.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 13.0, bottom: 0.0, right: 0.0)
//        backbtn.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 0.0)
        backbtn.addTarget(self, action: #selector(backClick), for: UIControl.Event.touchUpInside)
        backbtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        return backbtn
    }()

    fileprivate lazy var rightTextButton: UIButton = {
        var rightTextBtn = UIButton.init(type: UIButton.ButtonType.custom)
        rightTextBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        rightTextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        rightTextBtn.setTitleColor(UIColor(hexString: kSubmitBtnBgColorS), for: UIControl.State.normal)
        rightTextBtn.setTitle("发送", for: .normal)
        rightTextBtn.titleColorForDisabled = UIColor(hexString: kBtnDisenableColors)
        rightTextBtn.addTarget(self, action: #selector(rightTextClick), for: UIControl.Event.touchUpInside)
        rightTextBtn.isEnabled = false
        return rightTextBtn
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        titleLabel.text = "评论"
        return titleLabel
    }()
    
    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.delegate = self
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
        self.setUpUIKeyboardNotifation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    func setUpView() {
        self.view.backgroundColor = UIColor.white
        self.view.addSubviews([self.backButton, self.titleLabel, self.rightTextButton,self.textView])
        
        self.backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(68)
            make.height.equalTo(40)
            make.top.equalTo(self.view).offset(kSafeArea_Top + 22)
        }

        self.titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.backButton)
            make.width.equalTo(KScreenWidth/2)
            make.height.equalTo(24)
            make.centerX.equalToSuperview()
        }

        self.rightTextButton.snp.makeConstraints { (make) in
            make.width.equalTo(68)
            make.bottom.equalTo(self.backButton)
            make.height.equalTo(24)
            make.right.equalToSuperview()
        }

        self.textView.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.left.equalTo(self.view).offset(14)
            make.right.equalTo(self.view).offset(-14)
            make.bottom.equalTo(self.view).offset(-(kSafeArea_Bottom+20))
        }
                
    }
    
    @objc func backClick() {
        if self.backBlock != nil {
            self.backBlock!()
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func rightTextClick() {
        if self.textView.text.removeAllSapce.count > 0 {
            CODProgressHUD.showWithStatus(nil)
            CirclePublishTool.share.publishComment(momentsId: self.messageModel.serverMsgId, comments: self.textView.text) {[weak self] (isSuccess) in
                CODProgressHUD.dismiss()
                if isSuccess {
                    CODProgressHUD.showSuccessWithStatus("评论成功")
                }else{
                    CODProgressHUD.showErrorWithStatus("评论失败")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.backClick()
                }
            }
        }
    
    }

    ///添加键盘的通知
    func setUpUIKeyboardNotifation() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(_ :)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_ :)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_ :)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(_ :)),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameWillChange(_ :)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

}

extension CODBrowseCommentsVC:UITextViewDelegate{
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            self.rightTextButton.isEnabled = true
        }else{
            self.rightTextButton.isEnabled = false
        }
    }
    
    @objc func keyBoardWillShow(_ notification:NSNotification){

    }
       
   @objc func keyboardDidShow(_ notification:NSNotification){
 
   }
   @objc func keyboardWillHide(_ notification:NSNotification){
      
       
   }
   @objc func keyboardDidHide(_ notification:NSNotification){
       
   }
       
   @objc func keyboardFrameWillChange(_ notification:NSNotification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        self.textView.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().offset(-keyboardFrame.size.height)
        }
        self.view.layoutIfNeeded()

       
   }
}
