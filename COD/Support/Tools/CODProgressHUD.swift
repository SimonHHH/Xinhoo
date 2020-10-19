//
//  CODProgressHUD.swift
//  COD
//
//  Created by XinHoo on 2019/3/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//
/// 对 HUD 层进行一次封装

import UIKit
import SVProgressHUD

//延迟消失时间
private let dismissDelaySec :TimeInterval = 2.0

class CODProgressHUD: NSObject {

    class func initHUD() {
//        SVProgressHUD.setBackgroundColor(UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7 ))
        SVProgressHUD.setBackgroundColor(UIColor.black.withAlphaComponent(0.7))
        
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setFont(UIFont.systemFont(ofSize: 14))
//        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.none)
        SVProgressHUD.setCornerRadius(5.0)
        SVProgressHUD.setMinimumSize(CGSize(width: 80, height: 80))
        SVProgressHUD.setImageViewSize(CGSize(width: 33, height: 33))
        SVProgressHUD.setSuccessImage(UIImage(named: "success_icon")!)
        SVProgressHUD.setErrorImage(UIImage(named: "error_icon")!)
        SVProgressHUD.setDefaultMaskType(.clear)
    }
    
    //成功
    class func showSuccessWithStatus(_ string: String) {
        self.dismiss()
        self.CODProgressHUDShow(.success, status: NSLocalizedString(string, comment: ""))
    }
    
    //失败 ，NSError
    class func showErrorWithObject(_ error: NSError) {
        self.dismiss()
        self.CODProgressHUDShow(.errorObject, status: nil, error: error)
    }
    
    //失败，String
    class func showErrorWithStatus(_ string: String) {
        self.CODProgressHUDShow(.errorString, status: NSLocalizedString(string, comment: ""))
    }
    
    //转菊花
    class func showWithStatus(_ string: String?) {
        self.CODProgressHUDShow(.loading, status: NSLocalizedString(string ?? "", comment: ""))
    }
    
    //警告
    class func showWarningWithStatus(_ string: String) {
        self.CODProgressHUDShow(.info, status: NSLocalizedString(string, comment: ""))
    }
    
    //dismiss消失
    class func dismiss() {
        SVProgressHUD.dismiss()
    }
    
    //私有方法
    fileprivate class func CODProgressHUDShow(_ type: HUDType, status: String? = nil, error: NSError? = nil) {
        switch type {
        case .success:
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString(status ?? "", comment: ""))
            SVProgressHUD.dismiss(withDelay: dismissDelaySec)
            break
        case .errorObject:
            guard let newError = error else {
                SVProgressHUD.showError(withStatus: "Error:出错拉")
                SVProgressHUD.dismiss(withDelay: dismissDelaySec)
                return
            }
            
            if newError.localizedFailureReason == nil {
                SVProgressHUD.showError(withStatus: "Error:出错拉")
            } else {
                SVProgressHUD.showError(withStatus: error!.localizedFailureReason)
            }
            SVProgressHUD.dismiss(withDelay: dismissDelaySec)
            break
        case .errorString:
            SVProgressHUD.showError(withStatus: status)
            SVProgressHUD.dismiss(withDelay: dismissDelaySec)
            break
        case .info:
            SVProgressHUD.showInfo(withStatus: status)
            SVProgressHUD.dismiss(withDelay: dismissDelaySec)
            break
        case .loading:
            if status == nil{
                SVProgressHUD.show()
            }else{
                SVProgressHUD.show(withStatus: status)
            }
            break
        }
    }
    
    fileprivate enum HUDType: Int {
        case success, errorObject, errorString, info, loading
    }
}
