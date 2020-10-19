//
//  PCLoginoutViewController.swift
//  COD
//
//  Created by Xinhoo on 2019/5/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation

class PCLoginoutViewController: UIViewController {
    
    private var btnPCICON : UIButton!
    private var lblMsg : UILabel!
    private var btnIphoneMute : UIButton!
    private var btnFileTransfer : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
}

extension PCLoginoutViewController{
    
    func setUpUI() {
        let blurEffect = UIBlurEffect.init(style: .extraLight)
        let viewEffect = createBlurEffectView(blurEffect: blurEffect)
        self.view.addSubview(viewEffect)
        viewEffect.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }
        
        let btnClose = createCloseButton()
        self.view.addSubview(btnClose)
        btnClose.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(21)
            make.leading.equalTo(self.view).inset(17)
            make.top.equalTo(self.view).inset(kSafeArea_Top + 22 + 20)
        }
        
        btnPCICON = createPCICONButton()
        self.view.addSubview(btnPCICON)
        btnPCICON.snp.makeConstraints { (make) in
            make.width.equalTo(106)
            make.height.equalTo(84)
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).inset(kSafeArea_Top + 137 + 20)
        }
        
        lblMsg = createMsgLable()
        self.view.addSubview(lblMsg)
        lblMsg.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(14)
            make.centerX.equalTo(self.view)
            make.top.equalTo(btnPCICON.snp.bottom).offset(21)
        }
        
        btnIphoneMute = createIphoneMuteButton()
        self.view.addSubview(btnIphoneMute)
        btnIphoneMute.snp.makeConstraints { (make) in
            make.width.equalTo(53)
            make.height.equalTo(53)
            make.top.equalTo(lblMsg.snp.bottom).offset(46)
            make.centerX.equalTo(self.view.snp.centerX).offset(-53)
        }
        
        btnFileTransfer = createFileTransferButton()
        self.view.addSubview(btnFileTransfer)
        btnFileTransfer.snp.makeConstraints { (make) in
            make.width.equalTo(53)
            make.height.equalTo(53)
            make.top.equalTo(lblMsg!.snp.bottom).offset(46)
            make.centerX.equalTo(self.view.snp.centerX).offset(53)
        }
        
        let btnLoginOut = createLoginoutButton()
        self.view.addSubview(btnLoginOut)
        btnLoginOut.snp.makeConstraints { (make) in
            make.width.equalTo(180)
            make.height.equalTo(41)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).inset(104)
        }
        
    }
    
    func createBlurEffectView(blurEffect: UIBlurEffect) -> UIVisualEffectView {
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        
        return blurEffectView
    }
    
    func createCloseButton() -> UIButton {
        let btnClose = UIButton(type: .custom)
        btnClose.contentHorizontalAlignment = .left;
        btnClose.setTitle("关闭", for: UIControl.State.normal)
        btnClose.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btnClose.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: UIControl.State.normal)
        btnClose.addTarget(self, action: #selector(btnCloseClicked), for: UIControl.Event.touchUpInside)
        
        return btnClose;
    }
    
    func createPCICONButton() -> UIButton {
        let btnPCICON = UIButton(type: .custom)
        btnPCICON.setImage(UIImage.init(named: "win_icon"), for: UIControl.State.normal)
        btnPCICON.setImage(UIImage.init(named: "win_mute_icon"), for: UIControl.State.selected)
        btnPCICON.addTarget(self, action: #selector(btnIphoneMuteClicked), for: UIControl.Event.touchUpInside)
        btnPCICON.isSelected = true
        
        return btnPCICON;
    }
    
    func createMsgLable() -> UILabel {
        let lblMsg = UILabel.init(text: CustomUtil.formatterStringWithAppName(str: "%@已登录"))
        lblMsg.textAlignment = .center
        lblMsg.font = UIFont.boldSystemFont(ofSize: 15)
        lblMsg.textColor = UIColor.init(hexString: "#070707")
        
        return lblMsg;
    }
    
    func createIphoneMuteButton() -> UIButton {
        let btnIphoneMute = UIButton(type: .custom)
        btnIphoneMute.setImage(UIImage.init(named: "iphone_mute_icon"), for: UIControl.State.normal)
        btnIphoneMute.setImage(UIImage.init(named: "iphone_mute_selected_icon"), for: UIControl.State.selected)
        btnIphoneMute.addTarget(self, action: #selector(btnIphoneMuteClicked), for: UIControl.Event.touchUpInside)
        btnIphoneMute.isSelected = true
        
        return btnIphoneMute;
    }
    
    func createFileTransferButton() -> UIButton {
        let btnFileTransfer = UIButton(type: .custom)
        btnFileTransfer.setImage(UIImage.init(named: "file_transfer_icon"), for: UIControl.State.normal)
        btnFileTransfer.setImage(UIImage.init(named: "file_transfer_selected_icon"), for: UIControl.State.selected)
        btnFileTransfer.addTarget(self, action: #selector(btnFileTransferClicked), for: UIControl.Event.touchUpInside)
        
        return btnFileTransfer;
    }
    
    func createLoginoutButton() -> UIButton {
        let btnLoginout = UIButton(type: .custom)
        btnLoginout.clipsToBounds = true;
        btnLoginout.layer.cornerRadius = 5;
        btnLoginout.layer.borderColor = UIColor.clear.cgColor;
        btnLoginout.setBackgroundImage(UIImage.imageFromColor(color: UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1), viewSize: CGSize(width: 180, height: 41)), for: UIControl.State.normal)
        btnLoginout.setTitle(CustomUtil.formatterStringWithAppName(str: "退出 Windows %@"), for: UIControl.State.normal)
        btnLoginout.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        btnLoginout.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: UIControl.State.normal)
        btnLoginout.addTarget(self, action: #selector(btnLoginoutClicked), for: UIControl.Event.touchUpInside)
        
        return btnLoginout;
    }
    
}

//ACTION
extension PCLoginoutViewController {
    
    @objc func btnCloseClicked() {
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func btnIphoneMuteClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.btnPCICON?.isSelected = sender.isSelected
    } 
    
    @objc func btnFileTransferClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc func btnLoginoutClicked() {
        let vc = PCLoginoutConfirmViewController()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        vc.confirmLoginout={
            self.dismiss(animated: true, completion: {
                
            })
        }
        self.present(vc, animated: true) {
        }
    }
    
    
    
}


extension PCLoginoutViewController: BonsaiControllerDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        //return BonsaiController(fromView:UIView.init(), blurEffectStyle: .dark,  presentedViewController: presented, delegate: self)
        let controller:BonsaiController = BonsaiController(fromDirection: .bottom, blurEffectStyle: .extraLight, presentedViewController: presented, delegate: self)
        controller.isShowAlphaBg = true
        controller.isShowCornerRadius = false

        return controller
    }

    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: 0, y: containerViewFrame.height - 162 - kSafeArea_Bottom), size: CGSize(width: containerViewFrame.width, height: 162 + kSafeArea_Bottom))
    }

    func didDismiss() {
        print("didDismiss")
    }
}


