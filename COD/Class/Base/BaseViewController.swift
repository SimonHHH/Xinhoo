//
//  BaseViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

var curViewController: UIViewController? = nil

var statusBarHidden  = false

@objc class BaseViewController: UIViewController {
    
    var dispatchTimer: DispatchSourceTimer?
    
    var isCanUseSideBack = false
    
    weak var backDelegate:UIGestureRecognizerDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .default
//    }
    
    @objc class func setStatusBarHidden(_ hidden: Bool) {
        statusBarHidden = hidden
        UIViewController.current()?.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
//    override var shouldAutorotate: Bool{
//        return false
//    }
//    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        return .portrait
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        if (self.navigationController?.viewControllers.count) ?? 0  > 1 {
//            self.setTabBarHidden(true, animated: false)
//        }else{
//            self.setTabBarHidden(false, animated: false)
//
//        }
        
        self.backDelegate = self.navigationController?.interactivePopGestureRecognizer?.delegate
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CODProgressHUD.dismiss()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self.backDelegate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("=========\(self.classForCoder)=========")
        self.isCanUseSideBack = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isCanUseSideBack = false
        
        if curViewController == self {
            curViewController = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.blockRotation = false
//        DeviceTool.interfaceOrientation(.all)
//        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        self.view.backgroundColor = UIColor(hexString: kVCBgColorS)
        
        curViewController = self

//        self.openFullScreenGes()
    }
    
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
//         self.rdv_tabBarController?.setTabBarHidden(hidden, animated: animated)
//        self.rdv_tabBarController?.tabBar.setHeight(IsiPhoneX ? 84:49)
    }
    
    func setBackButton() {
        //设置返回按钮
        let backBarButton = UIBarButtonItem.init(customView: self.backButton)
        
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: self, action: #selector(navBackClick))
        negativeSpacer.width = 0
        
        self.navigationItem.leftBarButtonItems = [negativeSpacer,backBarButton]
    }
    
    func setCancelButton() {
        //设置取消按钮
        let cancelBarButton = UIBarButtonItem.init(customView: self.navCancelBtn)
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: self, action: #selector(navCancelClick))
        negativeSpacer.width = 0
        self.navigationItem.leftBarButtonItems = [negativeSpacer,cancelBarButton]
    }
    
    func setRightButton_ZZS() {
        //设置返回按钮
        
        let control = UIControl.init(frame: CGRect.init(x: 0, y: 0, width: 55, height: 44))
        control.addTarget(self, action: #selector(navRightClick), for: .touchUpInside)
        
        control.addSubview(self.rightButton)
        self.rightButton.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(1)
            make.width.height.equalTo(38)
        }
        self.rightButton.cornerRadius = 19
        
        let backBarButton = UIBarButtonItem.init(customView: control)
        
        control.widthAnchor.constraint(equalToConstant: 55).isActive = true
        control.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
//        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: self, action: #selector(navRightClick))
//        negativeSpacer.width = 5
        
//        let negativeSpacer = UIBarButtonItem.init(title: " ", style: .plain, target: self, action: #selector(navRightClick))
        
//        self.navigationItem.rightBarButtonItems = [negativeSpacer,backBarButton]
        self.navigationItem.rightBarButtonItem = backBarButton
    }
    
    func setSendButton() {
        //设置添加好友时的发送请求按钮
        
        let control = UIControl.init(frame: CGRect.init(x: 0, y: 0, width: 69, height: 32))
        control.addTarget(self, action: #selector(navRightClick), for: .touchUpInside)
        
        control.addSubview(self.rightTextButton)
        self.rightTextButton.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(56)
            make.bottom.equalToSuperview()
        }
        
        let sendBarButton = UIBarButtonItem.init(customView: control)
        control.widthAnchor.constraint(equalToConstant: 69).isActive = true
        control.heightAnchor.constraint(equalToConstant: 32).isActive = true
        self.navigationItem.rightBarButtonItem = sendBarButton
    }
    
    
    func setRightButton() {
        let rightBarButton = UIBarButtonItem.init(customView: self.rightButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setRightTextButton() {
        let rightBarButton = UIBarButtonItem.init(customView: self.rightTextButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setRightButtons() {
        let rightBarButton = UIBarButtonItem.init(customView: self.rightButton)
        let subRightButton = UIBarButtonItem.init(customView: self.subRightButton)
        self.navigationItem.rightBarButtonItems = [rightBarButton, subRightButton]
    }
    
    lazy var window: UIWindow = {
        let win = UIApplication.shared.keyWindow
        return win!
    }()
    
    lazy var backButton: UIButton = {
        var backbtn = UIButton.init(type: UIButton.ButtonType.custom)
        backbtn.frame  = CGRect(x: 0, y: 0, width: 70, height: 40)
        backbtn.setImage(UIImage(named: "button_nav_back"), for: UIControl.State.normal)
        backbtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backbtn.setTitle(NSLocalizedString("返回", comment: ""), for: UIControl.State.normal)
        backbtn.setTitleColor(UIColor(hexString: kTabItemSelectedColorS), for: UIControl.State.normal)
        backbtn.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        backbtn.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 13.0, bottom: 0.0, right: 0.0)
//        backbtn.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 0.0)
        backbtn.addTarget(self, action: #selector(navBackClick), for: UIControl.Event.touchUpInside)
        backbtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        return backbtn
    }()
    
    lazy var navCancelBtn: UIButton = {
        var backbtn = UIButton.init(type: UIButton.ButtonType.custom)
        backbtn.frame  = CGRect(x: 0, y: 0, width: 70, height: 40)
        backbtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backbtn.titleLabel?.textAlignment = .left
        backbtn.setTitle(NSLocalizedString("取消", comment: ""), for: UIControl.State.normal)
        backbtn.setTitleColor(UIColor(hexString: kTabItemSelectedColorS), for: UIControl.State.normal)
        backbtn.addTarget(self, action: #selector(navCancelClick), for: UIControl.Event.touchUpInside)
        return backbtn
    }()
    
    lazy var rightButton: UIButton = {
        var rightBtn = UIButton.init(type: UIButton.ButtonType.custom)
        rightBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightBtn.addTarget(self, action: #selector(navRightClick), for: UIControl.Event.touchUpInside)
        rightBtn.contentMode = .scaleToFill
//        rightBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        rightBtn.adjustsImageWhenHighlighted = false
        return rightBtn
    }()
    
    lazy var subRightButton: UIButton = {
        var rightBtn = UIButton.init(type: UIButton.ButtonType.custom)
        rightBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        rightBtn.addTarget(self, action: #selector(navSubRightClick), for: UIControl.Event.touchUpInside)
        return rightBtn
    }()
    
    
    lazy var rightTextButton: UIButton = {
        var rightTextBtn = UIButton.init(type: UIButton.ButtonType.custom)
        rightTextBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        rightTextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        rightTextBtn.setTitleColor(UIColor(hexString: kSubmitBtnBgColorS), for: UIControl.State.normal)
        rightTextBtn.titleColorForDisabled = UIColor(hexString: kBtnDisenableColors)
        rightTextBtn.addTarget(self, action: #selector(navRightTextClick), for: UIControl.Event.touchUpInside)
        return rightTextBtn
    }()
    
    @objc func navBackClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func navCancelClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func navRightClick() {
        
    }
    
    @objc func navSubRightClick() {
        
    }
    
    @objc func navRightTextClick() {
//        onClick()
    }
    
    func onClick() {
        
    }
    
    func tabShadowImageView() -> UIView? {
        let subview = self.navigationController?.navigationBar.cyl_tabBackground()
        guard let subviewT = subview else {
            return nil
        }
        let backgroundSubviews = subviewT.subviews
        if backgroundSubviews.count > 0 {
            for subview in backgroundSubviews {
                if subview.bounds.height <= 1.0 {
                    return subview as UIView
                }
            }
        }
        return nil
    }
    
    deinit {
        if let dispatchTimer = self.dispatchTimer {
            dispatchTimer.cancel()
        }
        NotificationCenter.default.removeObserver(self)
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    
    //验证码倒计时
    func startTimeDown(sender : UIButton) -> DispatchSourceTimer?{
        var timeout = 60
        let queue = DispatchQueue.global()
        dispatchTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.init(rawValue: 0), queue: queue)
        dispatchTimer!.schedule(deadline: DispatchTime.now(), repeating: 1.0, leeway: DispatchTimeInterval.microseconds(10))
        dispatchTimer!.setEventHandler { [weak self] in
            guard let `self` = self else { return }
            if timeout > 0 {
                let strTime = String.init(format: NSLocalizedString("%@s后重新获取", comment: ""), "\(timeout)")
                DispatchQueue.main.sync {
                    sender.setTitle(strTime, for: UIControl.State.normal)
                    sender.isUserInteractionEnabled = false
                    sender.isEnabled = false
                }
                timeout -= 1
            }else{
                self.dispatchTimer!.cancel()
                DispatchQueue.main.sync {
                    sender.setTitle("重新获取验证码", for: UIControl.State.normal)
                    sender.isUserInteractionEnabled = true
                    sender.isEnabled = true
                }
            }
        }
        dispatchTimer!.resume()
        return dispatchTimer
    }
    
    /*
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
 
    func openFullScreenGes() -> Void {
        
        /* 系统侧滑返回 */
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        /* 全屏返回 */
        let target = self.navigationController?.interactivePopGestureRecognizer?.delegate
        let handler = NSSelectorFromString("handleNavigationTransition:")
        
        let targetView = self.navigationController?.interactivePopGestureRecognizer?.view
        
        let fullScreenGes = UIPanGestureRecognizer.init(target: target, action: handler)
        fullScreenGes.delegate = self
        targetView?.addGestureRecognizer(fullScreenGes)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if self.navigationController?.children.count != 1 && isCanUseSideBack{
            return true
        }else {
            return false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController?.children.count != 1 && isCanUseSideBack{
            return true
        }else {
            return false
        }
    }
}

extension BaseViewController:UIGestureRecognizerDelegate{
    
}
