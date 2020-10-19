//
//  CODGlobalHelper.swift
//  COD
//
//  Created by 1 on 2019/3/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift

let LOAD_MESSAGE  = "加载中..."

let grayBackColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 0.5)

///字体大小
let FONT24 = UIFont.systemFont(ofSize: 24)
let FONT20 = UIFont.systemFont(ofSize: 20)
let FONT19 = UIFont.systemFont(ofSize: 19)
let FONT18 = UIFont.systemFont(ofSize: 18)
let FONT17 = UIFont.boldSystemFont(ofSize: 17)
let FONT16 = UIFont.systemFont(ofSize: 16)
let FONT15 = UIFont.systemFont(ofSize: 15)
let FONT14 = UIFont.boldSystemFont(ofSize: 14)
let FONT13 = UIFont.systemFont(ofSize: 13)
let FONT12 = UIFont.systemFont(ofSize: 12)
let FONTTime = UIFont.systemFont(ofSize: 11)


///长度
var KScreenWidth = UIScreen.main.bounds.size.width
var KScreenHeight = UIScreen.main.bounds.size.height
let BORDER_WIDTH_1PX = UIScreen.main.scale > 0.0 ? 1.0/UIScreen.main.scale:1.0
let AVER_RADIUS:CGFloat = 4
let HEIGHT_CHATBAR_TEXTVIEW:CGFloat = 36
let HEIGHT_MAX_CHATBAR_TEXTVIEW:CGFloat = 111.5

let HEIGHT_PICCAP_TEXTVIEW:CGFloat = 33
let HEIGHT_MAX_PICCAP_TEXTVIEW:CGFloat = 118

let TABBAR_HEIGHT =  49.0
let HEIGHT_CHAT_KEYBOARD:CGFloat = 258.0 + kSafeArea_Bottom
let groupControlHeight:CGFloat = 44 + kSafeArea_Bottom

let KNAV_HEIGHT = (IS_IPHONEX() ? 88 : 64)
let KNAV_STATUSHEIGHT =  (IS_IPHONEX() ? 40 : 20)
let MAX_MESSAGE = 20 ///最大的消息数量

func dispatch_async_safely_to_main_queue(_ block: @escaping ()->()) {
    dispatch_async_safely_to_queue(DispatchQueue.main, block)
}
// This methd will dispatch the `block` to a specified `queue`.
// If the `queue` is the main queue, and current thread is main thread, the block
// will be invoked immediately instead of being dispatched.
func dispatch_async_safely_to_queue(_ queue: DispatchQueue, _ block: @escaping ()->()) {
    if queue == DispatchQueue.main && Thread.isMainThread {
        block()
    } else {
        queue.async {
            block()
        }
    }
}

func dispatch_sync_safely_to_main_queue(_ block: @escaping ()->()) {
    dispatch_sync_safely_to_queue(DispatchQueue.main, block)
}

func dispatch_sync_safely_to_queue(_ queue: DispatchQueue, _ block: @escaping ()->()) {    
    if queue == DispatchQueue.main && Thread.isMainThread {
        block()
    } else {
        queue.sync {
            block()
        }
    }
}


///颜色
func RGBA(r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

///缓存
let InformNoticeCache = "InformNoticeCache"

///朋友圈缓存路径
let DiscoverHomeCache = "discoverHome"

/// 页码的数值
let PAGE_NUM = 10

/// 我的云盘
///// 我的云盘RosterID
let CloudDiskRosterID = -1


///// 新的朋友RosterID
let NewFriendRosterID = -999

/// 后台新的好友标志
let NewFriendFlagBack = "newfriend"

let NewFriendJid = NewFriendFlagBack + XMPPSuffix
let RobotRosterID = 0  ///// 小助手
let CloudDiskIcon = "cloud_disk_icon"

///通知
let CREATE_GROUP_NOTICATION  = "CREATE_GROUP_NOTICATION"
//有新的好友通知
let HAVE_NEWFRIEND_NOTICATION  = "HAVE_NEWFRIEND_NOTICATION_"
//互相为好友通知
let BOTH_ROSTER_NOTICATION  = "BOTH_ROSTER_NOTICATION"
//上次手机登录
let LAST_PHONE_LOGIN  = "LAST_PHONE_LOGIN"
//上次密码登录
let LAST_PASSWORD_LOGIN  = "LAST_PASSWORD_LOGIN"
//账号与安全的小红点引导
let  AccountAndSecurity_Red_Point = "AccountAndSecurity_Red_Point"
//网页链接
let USER_Protocol_URL = "http://\(XMPPDomain):8080/xinhoo/userService.html"

/// 判断是否是X型号
///
/// - Returns: 是或者不是靠
func IS_IPHONEX() -> Bool{
    if UIScreen.main.bounds.size.height >= 812.0 {
        return true
    }else{
        return false
    }
}

/// 关闭编辑
func CLOSE_EDIT(){
    UIApplication.shared.keyWindow?.endEditing(true)
}

///全局打印函数
func CCLog<T>(_ message:T,file:String = #file,funcName:String = #function,lineNum:Int = #line){
    #if DEBUG
    let file = (file as NSString).lastPathComponent;
    print("\(file):(\(lineNum))--\(message)");
    #endif
}

func CODAlertView_show(_ title: String, message: String? = nil) {
    var theMessage = ""
    if message != nil {
        theMessage = message!
    }
    
//    let alertView = UIAlertView(title: title , message: theMessage, delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "好的")
    let alertView  = UIAlertController(title: title, message: theMessage, preferredStyle: UIAlertController.Style.alert)
    let action1 = UIAlertAction(title: "好的", style: UIAlertAction.Style.default) { (action) in
        
    }
    alertView.addAction(action1)    
    alertView.show()
}

func CODAlertViewToSetting_show(_ title: String, message: String? = nil, showVC:UIViewController? = nil) {
    var theMessage = ""
    if message != nil {
        theMessage = message!
    }

    let alertView  = UIAlertController(title: title, message: theMessage, preferredStyle: UIAlertController.Style.alert)
    let action1 = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { (action) in
        
    }
    alertView.addAction(action1)
    let action2 = UIAlertAction(title: "去设置", style: UIAlertAction.Style.default) { (action) in
        let url = URL.init(string: UIApplication.openSettingsURLString)
        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                
            }
        }
        
    }
    alertView.addAction(action2)
    
    if showVC != nil {
        showVC?.present(alertView, animated: true, completion: nil)
    }else{
    
        alertView.show()
    }
    
}

//    设置alterView 消息提示
func CODAlertVcPresent(confirmBtn:String?, message:String?, title:String?, cancelBtn:String?, handler:@escaping(UIAlertAction) ->Void, viewController:UIViewController) {
    let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if cancelBtn?.removeAllSapce.count ?? 0 > 0 {
        let cancelAction = UIAlertAction(title: cancelBtn, style: .cancel, handler:nil)
        alertVc.addAction(cancelAction)
    }
  
    if confirmBtn != nil{
        let okAction = UIAlertAction(title: confirmBtn, style: .default, handler: { (action)in
            handler(action)
        })
        alertVc.addAction(okAction)
    }
    viewController.present(alertVc, animated:true, completion:nil)
}

