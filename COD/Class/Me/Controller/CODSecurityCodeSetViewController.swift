//
//  CODSecurityCodeSetViewController.swift
//  COD
//
//  Created by xinhooo on 2019/5/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit



class CODSecurityCodeSetViewController: BaseViewController {
    
    enum VCType {
        case set
        case reset
    }

    @IBOutlet weak var codeBackView: UIView!
    @IBOutlet weak var confirmCodeBackView: UIView!
    @IBOutlet weak var confirmTipLab: UILabel!
    @IBOutlet weak var tipLab: UILabel!
    
    var codeView:SecurityCodeView!
    var confirmCodeView:SecurityCodeView!
    
    var vcType: VCType = .set
    
    convenience init(vcType: VCType) {
        self.init()
        self.vcType = vcType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setBackButton()
        
        switch self.vcType {
        case .set:
            self.navigationItem.title = NSLocalizedString("设置锁定码", comment: "")
        default:
            self.navigationItem.title = NSLocalizedString("重置锁定码", comment: "")
        }
        
        
        
        self.codeView = (Bundle.main.loadNibNamed("SecurityCodeView", owner: self, options: nil)?.last as! SecurityCodeView)
        self.codeView.inputTextCompeleteBlock = { [weak self](text)  in
            print(text)
            self?.confirmCodeView.codeTF.becomeFirstResponder()
            self?.confirmCodeView.color = UIColor.black
            self?.confirmTipLab.textColor = UIColor.black
        }
        self.codeBackView.addSubview(self.codeView)
        
        self.confirmCodeView = (Bundle.main.loadNibNamed("SecurityCodeView", owner: self, options: nil)?.last as! SecurityCodeView)
        self.confirmCodeView.color = UIColor.init(hexString: "#888888")
        self.confirmTipLab.textColor = UIColor.init(hexString: "#888888")
        self.confirmCodeView.inputTextCompeleteBlock = { [weak self](text)  in
            
            self?.setSecurityCode()
        }
        self.confirmCodeView.deleteTextBlock = { [weak self] (text) in
            self?.codeView.codeTF.becomeFirstResponder()
            self?.confirmCodeView.color = UIColor.init(hexString: "#888888")
            self?.confirmTipLab.textColor = UIColor.init(hexString: "#888888")
        }
        self.confirmCodeBackView.addSubview(self.confirmCodeView)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.codeView.codeTF.becomeFirstResponder()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
    }
    
    func setSecurityCode() {
        
        if self.codeView.codeTF.text != self.confirmCodeView.codeTF.text {
            self.tipLab.isHidden = false
            let animation = POPSpringAnimation.init(propertyNamed: kPOPLayerPositionX)
            animation?.velocity = 1000
            animation?.springBounciness = 20
            animation?.springSpeed = 15
            self.tipLab.layer.pop_add(animation, forKey: "")
        }else{
            self.tipLab.isHidden = true
            UserDefaults.standard.set(self.confirmCodeView.codeTF.text, forKey: kSecurityCode + UserManager.sharedInstance.loginName!)
            
            switch self.vcType {
            case .set:
                UserDefaults.standard.set(SecurityCodeAutoLocking.LeaveTime.fiveMins.rawValue, forKey: kSecurityCodeAutoLockingTime + UserManager.sharedInstance.loginName!)
            default:
                break
            }
            
            if UserDefaults.standard.synchronize(){
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


struct SecurityCodeAutoLocking {
    enum LeaveTime: Int {
        case disable = 0
        case oneMin
        case fiveMins
        case thirtyMins
        case oneHour
    }
    
    static let timeValueStringArr: [String] = [NSLocalizedString("即刻", comment: ""), NSLocalizedString("离开1分钟后", comment: ""), NSLocalizedString("离开5分钟后", comment: ""), NSLocalizedString("离开30分钟后", comment: ""), NSLocalizedString("离开1小时后", comment: "")]
    
    static var timeValue: LeaveTime {
        get {
            return SecurityCodeAutoLocking.LeaveTime(rawValue: CODUserDefaults.integer(forKey: kSecurityCodeAutoLockingTime + UserManager.sharedInstance.loginName!)) ?? .disable
        }
    }
    
    static func setTimeValue(value: Int) {
        
        CODUserDefaults.set(value, forKey: kSecurityCodeAutoLockingTime + UserManager.sharedInstance.loginName!)
    }
    
    static var timeValueInt: Int {
        get {
            switch SecurityCodeAutoLocking.timeValue {
            case .disable:
                return 0
            case .oneMin:
                return 60
            case .fiveMins:
                return 300
            case .thirtyMins:
                return 1800
            default:
                return 3600
            }
        }
    }
    
    static var timeValueString: String {
        get {
            SecurityCodeAutoLocking.timeValueStringArr[SecurityCodeAutoLocking.timeValue.rawValue]
        }
    }
    
    static func setLeaveCurrentTimeInterval() {
        if SecurityCodeAutoLocking.timeValue == .disable || !isUnlock {
            return
        }
        CODUserDefaults.set(CustomUtil.getCurrentTime(), forKey: kSecurityCodeLeaveTime + UserManager.sharedInstance.loginName!)
    }
    
    static var isUnlock: Bool = false
    
    static var isLock: Bool {
        get {
            let leaveTime = CODUserDefaults.integer(forKey: kSecurityCodeLeaveTime + UserManager.sharedInstance.loginName!)
            let lockTime = SecurityCodeAutoLocking.timeValueInt * 1000
            let currentTime = CustomUtil.getCurrentTime()
            let isLock =  leaveTime + lockTime < currentTime || SecurityCodeAutoLocking.timeValue == .disable
            if !isLock { isUnlock = true }
            return isLock
        }
    }
    
}


