//
//  XMPPManager.swift
//  COD
//
//  Created by XinHoo on 2019/3/4.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Foundation
import XMPPFramework
import SwiftyJSON
import AudioToolbox
import UIKit
import Foundation
import XMPPFramework
import KissXML
import AdSupport
import SVProgressHUD
import PopupKit
import Lottie
import RxSwift
import RxCocoa
import DoraemonKit
import MulticastDelegateSwift
import AppCenterAnalytics
//#if DEBUG
//let XMPPDomain = "codtest.xinhoo.com"
//let XMPPSuffix = "@codtest.xinhoo.com"
//let XMPPGroupSuffix = "@conference.codtest.xinhoo.com"
//let XMPPDomainTemp = "codtest.xinhoo.com"
//#else



#if MANGO
let XMPPDomain = "im.imangoim.com"
let XMPPSuffix = "@im.imangoim.com"
let XMPPGroupSuffix = "@conference.im.imangoim.com"
let XMPPDomainTemp = "im.imangoim.com"
#elseif PRO
let XMPPDomain = "im.flygram.im"
let XMPPSuffix = "@im.flygram.im"
let XMPPGroupSuffix = "@conference.im.flygram.im"
let XMPPDomainTemp = "im.flygram.im"
#else
let XMPPDomain = "cod.xinhoo.com"
let XMPPSuffix = "@cod.xinhoo.com"
let XMPPGroupSuffix = "@conference.cod.xinhoo.com"
let XMPPDomainTemp = "cod.xinhoo.com"
#endif

////李玄
//let XMPPDomain = "192.168.0.99"
//let XMPPSuffix = "@xcom0015"
//let XMPPGroupSuffix = "@conference.xcom0015"
//let XMPPDomainTemp = "192.168.0.99"

//#endif

var XMPPPort = 5222

extension DispatchQueue {
    public static let messageQueue = DispatchQueue(label: "XMPPManager.messageQueue")
    public static let groupMembersOnlineTimeQueue = DispatchQueue(label: "GroupMembersOnlineTime")
    static let realmWriteQueue = DispatchQueue(label: "realmWriteQueue")
    static let autoResendMessageQueue = DispatchQueue(label: "autoResendMessageQueue")
    public static let realmBackgroundQueue = DispatchQueue(label: "io.realm.realm.background")
    public static let tcpPing = DispatchQueue(label: "tcpPing", attributes: .concurrent)
}

extension XMPPMessage {
    
    var prettyDescription: String {
        
        get {
            return """
            ==============================================================
            Msg ID: \(self.elementID ?? ""), from: \(self.fromStr ?? ""), to: \(self.toStr ?? "")
            -----------------------------XML------------------------------
            \(self.prettyXMLString())
            ----------------------------Body------------------------------
            \(CustomUtil.stringWithDictionary(dict: self.body?.getDictionaryFromJSONString() ?? [:]))
            ==============================================================
            """
        }
        
    }
    
}


public enum MultiMessageType: Int, CustomStringConvertible {
    
    
    case Image //图片
    case MVoice //微语音
    case MVideo //微视频
    case Attachment  //文件
    
    public var description: String {
        switch self {
        case MultiMessageType.Image:
            return "image"
        case MultiMessageType.MVoice:
            return "mvoice"
        case MultiMessageType.MVideo:
            return "mvideo"
        case MultiMessageType.Attachment:
            return "attachment"
        }
    }
}

enum OnlineState: String {
    case online = "99"
    case offline_ban = "0"
    case offline_all = "1"
    case offline_onlyFriend = "2"
}


typealias SendMsgSuccess = (_ message: XMPPMessage) -> ()
typealias SendMsgFailure = (_ message: XMPPMessage, _ error: Error) -> ()

typealias ReceiveMsgSuccess = (_ message: CODMessageModel) -> ()
typealias ReceiveChatState = (_ state: XMPPMessage.ChatState) -> ()
typealias RemoveMsgBlock = (_ msgId: String) -> ()
typealias EditMsgBlock = (_ message: CODMessageModel) -> ()
typealias EditFailMsgBlock = (_ messageID: String, _ errorString: String) -> ()

typealias successBlock = ((_ data: CODResponseModel, _ nameStr: String) -> Void)
typealias failBlock = ((_ data: CODResponseModel) -> Void)



extension XMPPManagerDelegate {
    func beforeSetRead(message: XMPPMessage){}
    func afterSetRead(message: XMPPMessage){}
    func deleteMessage(message: CODMessageHJsonModel){}
}

protocol XMPPManagerDelegate {
    
    func beforeSetRead(message: XMPPMessage)
    func afterSetRead(message: XMPPMessage)
    func deleteMessage(message: CODMessageHJsonModel)
    
}


@objc class XMPPManager: NSObject {
    
    enum XMPPManagerError: Error {
        case iqError
        case iqSendError
        case disconnect
        case timeout
        case iqToModelError
        case iqReturnError(Int, String)
    }
    
    public enum Result<Value> {
        case success(Value)
        case failure(XMPPManagerError)
        
        /// Returns `true` if the result is a success, `false` otherwise.
        public var isSuccess: Bool {
            switch self {
            case .success:
                return true
            case .failure:
                return false
            }
        }
        
        /// Returns `true` if the result is a failure, `false` otherwise.
        public var isFailure: Bool {
            return !isSuccess
        }
        
        /// Returns the associated value if the result is a success, `nil` otherwise.
        public var value: Value? {
            switch self {
            case .success(let value):
                return value
            case .failure:
                return nil
            }
        }
        
        /// Returns the associated error value if the result is a failure, `nil` otherwise.
        public var error: XMPPManagerError? {
            switch self {
            case .success:
                return nil
            case .failure(let error):
                return error
            }
        }
    }
    
    typealias XMPPIQResponse = ((_ result: XMPPManager.Result<CODResponseModel>) -> Void)
    
    struct XMPPIQResponseBlock {
        let time: TimeInterval
        let response: XMPPIQResponse
    }
    
    
    //单例
    @objc static let shareXMPPManager = XMPPManager()
    
    let disposeBag = DisposeBag()
    
    //当前聊天对象，用于过滤接收的消息
    var currentChatFriend = ""
    var roomDict: Dictionary<String, XMPPRoom> = [:]
    
    @objc var xmppStream: XMPPStream!
    var xmppRoster: XMPPRoster!
    var xmppReconnect: XMPPReconnect!
    //    var xmppManagement : XMPPStreamManagement!
    //    var storage : XMPPStreamManagementMemoryStorage!
    
    var xmppAutoPing: XMPPAutoPing!
    
    var autoPingTimeoutCount = 0
    @objc dynamic var reconnectCount = 0
    //    var roomDict = Dictionary<String, Any>()
    
    var isGetRoomHistory = false
    //    var isActive         = false
    
    var customCertEvaluation = true
    
    var _password: String!
    var _username: String!
    
    var sendMsgSuccess: SendMsgSuccess!
    var sendMsgError: SendMsgFailure!
    
    var receiveMsg: ReceiveMsgSuccess!
    
    var receiveChatState: ReceiveChatState!
    
    
    var removeMsgBlock: RemoveMsgBlock!
    var editMsgBlock: EditMsgBlock!
    var editFailMsgBlock: EditFailMsgBlock!
    var successBlock: successBlock!
    var failBlock: failBlock!
    
    var iqRequsetQ: [String: XMPPIQResponseBlock] = [:]
    
    /// 修复数据标记
    @objc var isRepairData: Bool = false
    
    let timeoutValue: Double = 10
    
    var messageQueue: DispatchQueue {
        return .messageQueue
    }
    
    
    let multicastDelegate: MulticastDelegate<XMPPManagerDelegate> = MulticastDelegate<XMPPManagerDelegate>()
    
    func addDelegate(_ delegate: XMPPManagerDelegate) {
        multicastDelegate.addDelegate(delegate)
    }
    
    func removeDeleagte(_ delegate: XMPPManagerDelegate) {
        multicastDelegate.removeDelegate(delegate)
    }
    
    var topRankList: [String] = []
    
    override init() {
        super.init()
        
        //        DDLog.add(DDTTYLogger.sharedInstance)
        //        DDLog.setLevel(DDLogLevel(rawValue: DDLogLevel.RawValue(XMPP_LOG_FLAG_SEND_RECV))! , for: XMPPManager.self )
        
        self.xmppStream = XMPPStream()
//        self.xmppStream.supportsStartTLS
        
        self.xmppStream.hostName = XMPPHost
//        self.xmppStream.startTLSPolicy = .preferred
        
        self.xmppReconnect = XMPPReconnect()
        self.xmppReconnect.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.xmppReconnect.autoReconnect = false
        self.xmppReconnect.activate(self.xmppStream)
        
        
        
        //设置代理
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
//        SerialDispatchQueueScheduler(queue: messageQueue, internalSerialQueueName: "XMPPManager.messageQueue")
        
        
        Observable<Int>.interval(.seconds(1), scheduler: SerialDispatchQueueScheduler(queue: messageQueue, internalSerialQueueName: "XMPPManager.messageQueue"))
            .subscribe({ [weak self] (_) in
                
                guard let `self` = self else { return }
                
                var keys: [String] = []
                
                for (key, value) in self.iqRequsetQ {
                    
                    let seconds = Date().secondsSince(Date(timeIntervalSince1970: value.time))
                    
                    if seconds < self.timeoutValue {
                        continue
                    }
                    
                    dispatch_async_safely_to_main_queue {
                        value.response(.failure(.timeout))
                    }
                    keys.append(key)
                    
                }
                
                DispatchQueue.messageQueue.async {
                    self.iqRequsetQ.removeAll(keys: keys)
                }
                
                
                
            })
            .disposed(by: self.disposeBag)
        
        
    }
    
    
    @objc func MTConnectionXMPP() {
        self.xmppConnect(username: _username, password: _password)
    }
    
    
    func xmppConnect(username: String, password: String) {
        
        _username = username
        _password = password
        
        if (!xmppStream.isConnected && !xmppStream.isConnecting) && UserManager.sharedInstance.isLogin {
            //用户名
            let username = _username
            /// 初始化一个jid，resource可以为空
            let jid = XMPPJID(user: username, domain: XMPPDomain, resource: UserManager.sharedInstance.resource)
            xmppStream.myJID = jid
            xmppStream.hostPort = UInt16(XMPPPort)
            do {
                /// 连接服务器
                try xmppStream.connect(withTimeout: 10)
                
            } catch let error {
                print(error)
            }
        }
    }
    
    @objc func disconnect() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream.send(presence)
        ///断开连接
        xmppStream.disconnect()
        self.xmppDisconnetIQRequsetHandler()
    }
    
}


extension XMPPManager: XMPPStreamDelegate, XMPPStreamManagementDelegate {
    func xmppStreamWillConnect(_ sender: XMPPStream) {
        print("即将连接#################")
        XinhooTool.addLog(log:"xmpp开始连接")
        NotificationCenter.default.post(name: NSNotification.Name.init(kConnecting), object: nil, userInfo: nil)
        //        CFReadStreamSetProperty([socket getCFReadStream], kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
        //        CFWriteStreamSetProperty([socket getCFWriteStream], kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
        
        //当断线了的时候，不允许修改lastpushtime 防止获取历史不准确
    }
    
    
    /// 连接服务器的回调
    func xmppStream(_ sender: XMPPStream, socketDidConnect socket: GCDAsyncSocket) {
        print("连接成功#################")
        XinhooTool.addLog(log:"xmpp连接成功")
        self.reconnectCount = 0
        //        socket.perform {
        //            socket.enableBackgroundingOnSocket()
        //        }
    }
    
    /// 连接成功后使用密码登录
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        
        if xmppStream.isAuthenticated {
            return
        }
        XinhooTool.addLog(log:"xmpp密码登录")
        self.authenticate()
        
    }
    
    @objc func checkIPLock() {
        
        if xmppStream.isAuthenticated {
            return
        }
        
        let param = ["username": UserManager.sharedInstance.loginName ?? "",
                     "deviceID": DeviceInfo.uuidString,
                     "loginResource": UserManager.sharedInstance.resource ?? ""]
        
        HttpManager().post(url: HttpConfig.updateClientIpAddressByResource, param: param, successBlock: { (_, json) in
            
            if UIViewController.current()?.isKind(of: IPLockViewController.classForCoder()) ?? false {
                UIViewController.current()?.dismiss(animated: true, completion: nil)
            }
            
        }) { (error) in
            
            if error.code  == 10053 && self.xmppStream.isConnected {
                
                if !(UIViewController.current()?.isKind(of: IPLockViewController.classForCoder()))! {
                    XMPPManager.shareXMPPManager.xmppReconnect.stop()
                    XMPPManager.shareXMPPManager.disconnect()
                    XinhooTool.addLog(log:"【主动断开连接】IP 受限")
                    let ipLockVC = IPLockViewController.init(nibName: "IPLockViewController", bundle: Bundle.main)
                    ipLockVC.modalPresentationStyle = .overFullScreen
                    UIViewController.current()?.present(ipLockVC, animated: true, completion: {
                    })
                }
                
            } else {
                
                self.perform(#selector(self.checkIPLock), with: nil, afterDelay: 1)
                
            }
            
        }
        
    }
    
    func authenticate() {
        
        self.checkIPLock()
        
        let infoDictionary = Bundle.main.infoDictionary
        let majorVersion: AnyObject? = infoDictionary!["CFBundleShortVersionString"] as AnyObject?//主程序版本号
        
        let param = ["username": UserManager.sharedInstance.loginName ?? "",
                     "password": UserManager.sharedInstance.password ?? "",
                     "deviceID": DeviceInfo.uuidString,
                     "token": UserManager.sharedInstance.session ?? "",
                     "voipToken": UserManager.sharedInstance.voipToken ?? "",
                     "pushToken": UserManager.sharedInstance.token ?? "",
                     "loginResource": UserManager.sharedInstance.resource ?? "",
                     "description": UIDevice.current.name,
                     "clientVersion": majorVersion as Any,
                     "lang": CustomUtil.getLangString()]
        
        
        do {
            
            if let jsonStr = param.jsonString() {
                
                let auth = XMPPPlainAuthentication(stream: xmppStream, password: jsonStr)
                try xmppStream.authenticate(auth)
                
            }
            
            
            //            try xmppStream.authenticate(withPassword: _password)
        } catch let error {
            print(error)
        }
    }
    
    /// 连接超时
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        print("-----------------------------连接超时")
        XinhooTool.addLog(log:"xmpp链接超时")
        //改自动加群
        self.xmppReconnect.manualStart()
    }
    
    func xmppStream(_ sender: XMPPStream, didReceiveError error: DDXMLElement) {
        print("error: \(error)")
        XinhooTool.addLog(log:"xmpp链接报错--错误信息:\(error)")
        if error.element(forName: "conflict") != nil {
            
            
            XinhooTool.addLog(log: "【主动断开连接】收到 conflict 主动断开重连")
            
            self.disconnect()
            self.xmppReconnect.manualStart()
            
//            UserManager.sharedInstance.userLogout()
//            let alert = UIAlertController.init(title: nil, message: "您的账号已在别处登录，如果这不是您的操作，请及时设置或修改您的密码", preferredStyle: UIAlertController.Style.alert)
//            let action = UIAlertAction.init(title: "知道了", style: UIAlertAction.Style.default) { (action) in
//
//            }
//            alert.addAction(action)
//            let ctl = UIViewController.current()
//            ctl?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: ------------- 登录成功 -------------
    /// 用户登录成功
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        
        
        XinhooTool.addLog(log:"xmpp登录成功")
        NotificationCenter.default.post(name: NSNotification.Name.init(kEndGetHistory), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kBeginGetHistory), object: nil, userInfo: nil)
        //        self.xmppManagement.enable(withResumption: true, maxTimeout: 10)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        //用IQ拉取个人信息及设置
        
        CustomUtil.getAll_IP_List()
        
        self.requestUserInfo { (result) in
            CODProgressHUD.dismiss()
            
            switch result{
            case .success(let model):
                
                if let userInfo = CODUserInfoAndSetting.deserialize(from: model.dataJson?["setting"].dictionaryObject) {
                    
                    userInfo.name = userInfo.name?.aes128DecryptECB(key: .nickName)
                    userInfo.tel = userInfo.tel?.aes128DecryptECB(key: .phoneNum)
                    
                    UserManager.sharedInstance.userInfoSetting = userInfo
                }
                
                // 是否已修改密码
                let changedPwd = UserManager.sharedInstance.changePwd ?? true
                let nickName = UserManager.sharedInstance.nickname
                let isNickNameNULL = nickName == nil || (nickName?.count)! <= 0
                if !changedPwd {
                    let vc = EditPasswordViewController(nibName: "EditPasswordViewController", bundle: Bundle.main)
                    vc.isForceChangePwd = true
                    if isNickNameNULL {
                        vc.nextStepToSettingNickName = true
                    }
                    
                    UIViewController.pushToCtl(vc, animated: true)
                    return
                }
                
                if isNickNameNULL {
                    UIViewController.pushToCtl(CODSettingNickAndAvatarController(), animated: true)
                }
                
                break
                
            case .failure(_):
                break
            }
            
            
        }
        
        //        self.requestUserInfo(success: { (successModel, nameStr) in
        //            if nameStr == "personSetting" {
        //                CODProgressHUD.dismiss()
        //
        //
        //            }
        //
        //        }) { (error) in
        //            //            CODProgressHUD.showErrorWithStatus("获取个人信息失败")
        //        }
        //
        
        /// 如果本地数据库没有任何联系人，判定为第一次登录，就发送IQ去取联系人列表
        //        if let contactList = CODContactRealmTool.getContacts() {
        //            if contactList.count > 0 {
        //                CODGroupChatModel.getLocalGroupChatList()
        //            }else{
        //                self.requestContacts()
        //            }
        //        }else{
        //            self.requestContacts()
        //        }
        
        
        //MARK: 判断APP是否是第一次启动，如果是第一次启动就需要去获取通讯录
        if !UserDefaults.standard.bool(forKey: kIsFirst + UserManager.sharedInstance.loginName!) {
            //登录成功，去获取联系人列表
            self.requestContacts()
        } else {
            
            //MARK: APP不是第一次启动就获取通讯录增量更新接口
            //发送通讯录增量更新IQ
            
            HttpManager().post(url: HttpConfig.COD_GetContactOnlineState, param: ["username": UserManager.sharedInstance.loginName as Any], successBlock: { (result, json) in
                
                DispatchQueue.global().async {
                    let isUpdate = result["success"] as! Bool
                    if isUpdate {
                        
                        if let dataDic = (result["data"] as? NSDictionary) {
                            let allJid = dataDic.allKeys
                            
                            for jid in allJid {
                                guard let jid = jid as? String else {
                                    return
                                }
                                if let contactStateDic = dataDic.object(forKey: jid) as? NSDictionary {
                                    if let contact = CODContactRealmTool.getContactByJID(by: jid) {
                                        do {
                                            try Realm.init().write {
                                                contact.lastlogintime = contactStateDic.object(forKey: "lastlogintime") as! Int
                                                contact.loginStatus = contactStateDic.object(forKey: "loginStatus") as! String
                                                contact.lastLoginTimeVisible = contactStateDic.object(forKey: "lastLoginTimeVisible") as! Bool
                                            }
                                        } catch {
                                            
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
                
                
            }) { (error) in
                
            }
            
            CustomUtil.contactUpdate()
        }
        
    }
    
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        
        DDLogError("didNotAuthenticate error")

        guard let children = error.children else {
            self.xmppReconnect.manualStart()
            return
        }
        
        var json: JSON?
        for child in children {
            if child.name == "text", let jsonString = child.stringValue {
                json = JSON(parseJSON: jsonString)
            }
        }
        
        guard let code = json?["code"].int else {
            
            
            #if DEBUG
            #else
            MSAnalytics.trackEvent("密码错误-没有code - \(UserManager.sharedInstance.jid)", withProperties: ["phone":UserManager.sharedInstance.phoneNum ?? "",
                                                                                                                   "error":(json == nil) ? "登录错误返回xml没有text节点" : (json?.dictionaryObject?.jsonString() ?? "")])
            #endif
//            UserManager.sharedInstance.userLogout()
//            CODAlertView_show("密码错误")
            self.xmppReconnect.manualStart()
            DDLogError("didNotAuthenticate error code is \(error)")
            
            return
        }
        
        
        DDLogError("didNotAuthenticate error code \(code)")
        switch code {
        case 10011:
            XinhooTool.addLog(log:"您的账号已在别处登录，如果这不是您的操作，请及时设置或修改您的密码--error = \(code)")
            UserManager.sharedInstance.userLogout()
            let alert = UIAlertController.init(title: nil, message: "您的账号已在别处登录，如果这不是您的操作，请及时设置或修改您的密码", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction.init(title: "知道了", style: UIAlertAction.Style.default) { (action) in
                
            }
            alert.addAction(action)
            let ctl = UIViewController.current()
            ctl?.present(alert, animated: true, completion: nil)
        case 10012:
            UserManager.sharedInstance.userLogout()
            CODAlertView_show("无效的token")
        case 10023:
            
            #if DEBUG
            #else
            MSAnalytics.trackEvent("密码错误-10023 - \(UserManager.sharedInstance.jid)", withProperties: ["phone":UserManager.sharedInstance.phoneNum ?? "","error":(json?.dictionaryObject?.jsonString() ?? "")])
            #endif
            
            UserManager.sharedInstance.userLogout()
            CODAlertView_show("密码错误")
        case 10031:
            UserManager.sharedInstance.userLogout()
            CODAlertView_show("因涉嫌违规或被用户投诉，您的账号已被冻结")
        case 10053:
            if !(UIViewController.current()?.isKind(of: IPLockViewController.classForCoder()))! {
                XMPPManager.shareXMPPManager.xmppReconnect.stop()
                XMPPManager.shareXMPPManager.disconnect()
                XinhooTool.addLog(log:"【主动断开连接】IP 受限")
                let ipLockVC = IPLockViewController.init(nibName: "IPLockViewController", bundle: Bundle.main)
                ipLockVC.modalPresentationStyle = .overFullScreen
                UIViewController.current()?.present(ipLockVC, animated: true, completion: {
                })
            }
            
        default:
            self.xmppReconnect.manualStart()
            break
        }
        
        XinhooTool.addLog(log:"xmpp登录失败--错误信息:\(error.description)")
        //        self.xmppReconnect.manualStart()
    }
    
    
    /// 退出登录的回调
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kConnectFail), object: nil, userInfo: nil)
        XinhooTool.addLog(log:"xmpp链接断开--错误信息:\(String(describing: error))")
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if UserManager.sharedInstance.isLogin {
            
            //改自动加群
            //            let delegate = UIApplication.shared.delegate as! AppDelegate
            //            if delegate.isNetwork {
            //                self.MTConnectionXMPP()
            //            }
            if !(UIViewController.current()?.isKind(of: IPLockViewController.classForCoder()))! {
                self.xmppReconnect.manualStart()
            }
            
        }
        
        print("连接断开,error:\(String(describing: error ?? nil))")
    }
    
    // MARK: -------------  接收Message -------------
    /// 成功接收消息
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("\(message.prettyDescription)")
        
        self.updateUnReadPointTime(message: message)
        
        if message.hasChatState {
            self.analysisChatState(message: message)
        }
        
        self.analysisMessage(message: message)
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo: nil)
    }
    
    /// 发送消息时，更新当前聊天用来计算未读数量的时间
    /// - Parameter message: message
    func updateUnReadPointTime(message: XMPPMessage) {
        guard let messageBodyDic = message.body?.getDictionaryFromJSONString() as? [String: Any] else {
            return
        }
        
        guard let messageBodyModel = CODMessageHJsonModel.deserialize(from: messageBodyDic) else {
            return
        }
        
        if messageBodyModel.receiver == currentChatFriend {
            guard let chatList = CODChatListRealmTool.getChatList(jid: currentChatFriend) else {
                return
            }
            try! Realm().write {
                if chatList.lastReadTimeOfMe < messageBodyModel.sendTime {
                    chatList.lastReadTimeOfMe = messageBodyModel.sendTime
                }
            }
        }
    }
    
    func analysisChatState(message: XMPPMessage) {
        guard let fromJID = message.fromStr?.subStringTo(string: "/") else {
            return
        }
        if self.currentChatFriend == fromJID {
            if message.hasComposingChatState {
                if self.receiveChatState != nil {
                    self.receiveChatState(.composing)
                }
                return
            }
            if message.hasPausedChatState {
                if self.receiveChatState != nil {
                    self.receiveChatState(.paused)
                }
                return
            }
        }
    }
    
    func deleteMessage(msgIDs: [String]) {
        //        var msgIDString = msgIDs.map { (id) in
        //            return "\(id)"
        //        }
        CODMessageRealmTool.deleteMessages(by: msgIDs)
    }
    
    func analysisMessage(message: XMPPMessage) {
        
        let text = message.body
        if text != nil {
            //做处理
            
            guard let messageBodyModel = CODMessageHJsonModel.deserialize(from: message.body?.getDictionaryFromJSONString()) else {
                print("解析Message错误")
                return
            }
            
            if let type = message.type {
                if type.compareNoCaseForString("error") {   //消息来自系统 且 message.type == error，就是被拒收
                    self.messageDidSentBack(message: message, messageModel: messageBodyModel)
                    return
                }
            }
            
            if let messageIDStr = message.elementID {
                
                let messageTemp = CODMessageRealmTool.getMessageByMsgId(messageIDStr)
                if messageTemp != nil || messageBodyModel.received == 1 {
                    //                    guard messageBodyModel.msgTypeEnum != .haveRead else {
                    
                    if message.wasDelayed {
                        return
                    }
                    if messageBodyModel.sender == UserManager.sharedInstance.jid {
                        if let chatListModel = CODChatListRealmTool.getChatList(jid: messageBodyModel.receiver) {
                            try! Realm.init().write {
                                chatListModel.count = 0
                                chatListModel.referToMessageID.removeAll()
                            }
                        }
                    }
                    //                        return
                    //                    }
                    //                    guard let messageTemp = messageTemp else {
                    //                        return
                    //                    }
                    //                    if messageTemp.status != CODMessageStatus.Succeed.rawValue {
                    if messageBodyModel.edited >= 1 {  //这是编辑消息
                        self.editMsg(message: message)
                        return
                    }
                    //
                    //                        return
                    //                    }
                    
                    var fromJID = ""
                    if messageBodyModel.chatType == .groupChat || messageBodyModel.chatType == .channel  {//是群组的话，设置fromJID为群JID
                        if !fromJID.contains("@conference") {
                            fromJID = messageBodyModel.receiver
                        }
                    } else {
                        
                        fromJID = messageBodyModel.sender
                        if !fromJID.contains(XMPPSuffix) {
                            fromJID = fromJID + XMPPSuffix
                        }
                    }
                    if currentChatFriend == fromJID || (fromJID == UserManager.sharedInstance.jid && currentChatFriend == messageBodyModel.receiver) {
                        if self.sendMsgSuccess != nil {
                            self.sendMsgSuccess(message)
                        }
                    } else {
                        //刷新本地数据库
                    }
                    self.updateMessageSendStatus(message: message)
                    if (messageBodyModel.receiver.contains(kCloudJid)) {
                        NotificationCenter.default.post(name: NSNotification.Name.init(kCollectionMessageSuccess), object: nil, userInfo: ["msgID": messageIDStr])
                    }
                    return
                }
            } else {
                print("第一次消息ID解析不成功")
            }
            
            guard var fromJID = message.fromStr?.subStringTo(string: "/") else { //例：test01@cod.xinhoo.com/QXmpp
                print("！！！！返回的消息不存在JID！！！！！")
                return
            }
            
            
            if messageBodyModel.chatType == .groupChat || messageBodyModel.chatType == .channel  {//是群组的话，设置fromJID为群JID
                if !fromJID.contains("@conference") {
                    fromJID = messageBodyModel.receiver
                }
            }
            
            if let messageDic = message.body?.getDictionaryFromJSONString() as? Dictionary<String, Any> {
                var messageModel = CODMessageModel()
                for memberJid in messageDic["referTo"] as? Array<String> ?? [] {
                    messageModel.referTo.append(memberJid)
                }
                messageModel.datetime = String(format: "%ld", messageBodyModel.sendTime)
                messageModel.datetimeInt = messageBodyModel.sendTime
                messageModel.burn = messageBodyModel.burn
                if messageBodyModel.msgTypeEnum != .haveRead && !message.wasDelayed {
                    if let lastPushTime = CODUserDefaults.object(forKey: kLastMessageTime + UserManager.sharedInstance.loginName!) {
                        
                        if (lastPushTime as! String) < messageModel.datetime {
                            CODUserDefaults.set(messageModel.datetime, forKey: kLastMessageTime + UserManager.sharedInstance.loginName!)
                            CODUserDefaults.synchronize()
                        }
                    } else {
                        
                        CODUserDefaults.set(messageModel.datetime, forKey: kLastMessageTime + UserManager.sharedInstance.loginName!)
                        CODUserDefaults.synchronize()
                    }
                }
                
                if let messageIDStr = message.elementID {
                    messageModel.msgID = messageIDStr
                }
                
                messageModel.edited = messageBodyModel.edited
                messageModel.reply = messageBodyModel.reply
                messageModel.rp = messageBodyModel.rp
                messageModel.fw = messageBodyModel.fw
                messageModel.fwn = messageBodyModel.fwn
                messageModel.fwf = messageBodyModel.fwf
                messageModel.n = messageBodyModel.n
                messageModel.l = messageBodyModel.l
                messageModel.msgType = messageBodyModel.msgType
                messageModel.chatTypeEnum = messageBodyModel.chatType
                messageModel.itemID = messageBodyModel.itemID
                messageModel.smsgID = messageBodyModel.smsgID
                messageModel.roomId = messageBodyModel.roomID
                for attributeDic in messageBodyModel.entities {
                    if let attributeModel = CODAttributeTextModel.deserialize(from: attributeDic) {
                        messageModel.entities.append(attributeModel)
                    }
                }
                
                messageModel.userPic = CustomUtil.getUserPic(messageBodyModel: messageBodyModel)
                messageModel.fromWho = messageBodyModel.sender
                messageModel.fromJID = messageBodyModel.sender
                fromJID = messageModel.fromJID
                
                if messageBodyModel.chatType == .groupChat || messageBodyModel.chatType == .channel  {//是群组的话，设置fromJID为群JID
                    if !fromJID.contains("@conference") {
                        fromJID = messageBodyModel.receiver
                    }
                } else {
                    if fromJID == (XMPPDomainTemp) {
                        fromJID = messageBodyModel.sender
                    }
                }
                
                if let toJID = message.toStr {
                    messageModel.toJID = toJID.subStringTo(string: "/")
                }
                
                messageModel.toWho = messageBodyModel.receiver
                messageModel.toJID = messageBodyModel.receiver
                
                if messageModel.type == .location {
                    messageModel.location = LocationInfo()
                }
                
                if let messageString = messageDic["body"] as? String {
                    if messageModel.type == .location {
                        messageModel.location?.locationImageString = messageString.getImageFullPath(imageType: 0)
                    } else if messageModel.type == .image {
                        if let settingDic = messageDic["setting"] as? Dictionary<String, Any> {
                            messageModel.photoModel = PhotoModelInfo.deserialize(from: settingDic)
                            if let description = settingDic["description"] as? String {
                                
                                //AES解密
                                messageModel.photoModel?.descriptionImage = AES128.aes128DecryptECB(description)
                                //                                if AES128.aes128DecryptECB(description) != "" {
                                //                                    messageModel.photoModel?.descriptionImage = AES128.aes128DecryptECB(description)
                                //                                } else {
                                //                                    messageModel.photoModel?.descriptionImage = description
                                //                                }
                            }
                            if let filename = settingDic["filename"] as? String {
                                messageModel.photoModel?.filename = filename
                                if filename.hasSuffix(".gif") || filename.hasSuffix(".GIF") {
                                    messageModel.photoModel?.isGIF = true
                                } else {
                                    messageModel.photoModel?.isGIF = false
                                }
                            }
                        } else {
                            messageModel.photoModel = PhotoModelInfo()
                        }
                        //                        messageModel.photoModel?.photoImageURL = messageString.getImageFullPath(imageType: 0)
                        messageModel.photoModel?.serverImageId = messageString
                        //下载缩略图
                        CustomUtil.downLoadImageThumbNailPic(fromJID, messageModel)
                        
                    } else if messageModel.type == .notification {
                        messageModel.text = message.subject ?? ""
                    } else if messageModel.type == .gifMessage {
                        messageModel.text = messageBodyModel.body
                    } else {
                        messageModel.text = messageString
                    }
                    
                } else {
                    messageModel.text = " "
                }
                
                
                if let settingDic = messageDic["setting"] as? Dictionary<String, Any> {
                    
                    if messageModel.type == .unknown {
                        messageModel.setting = try? JSON(settingDic).rawData(options: .fragmentsAllowed)
                    }
                    
                    //位置
                    if messageModel.type == .location {
                        if let subtitle = settingDic["subtitle"] as? String,
                            let title = settingDic["title"] as? String,
                            let lng = settingDic["lng"] as? String,
                            let lat = settingDic["lat"] as? String {
                            messageModel.location?.name = title
                            messageModel.location?.address = subtitle
                            messageModel.location?.latitude = Double(lat) ?? 0
                            messageModel.location?.longitude = Double(lng) ?? 0
                        }
                    }
                    //文件
                    if messageModel.type == .file {
                        messageModel.fileModel = FileModelInfo.deserialize(from: settingDic)
                        messageModel.fileModel?.fileID = messageModel.text
                        var imageName = ""
                        let type = CODFileHelper.getFileType(fileName: messageModel.fileModel?.filename ?? "")
                        switch type {
                        case .PdfType:
                            imageName = "pdf_flie"
                            break
                        case .WordType:
                            imageName = "doc_file"
                            break
                        case .ZipType:
                            imageName = "compressed_file"
                            break
                        case .ExcelType:
                            imageName = "xlsx_flie"
                            break
                        default:
                            imageName = "unknow_file"
                            break
                        }
                        
                        messageModel.fileModel?.fileImageName = imageName
                        messageModel.fileModel?.fileSizeString = CODFileHelper.getFileSize(fileSize: CGFloat(messageModel.fileModel?.size ?? 0))
                        
                        //AES解密
                        if let description = settingDic["description"] as? String {
                            if AES128.aes128DecryptECB(description) != "" {
                                messageModel.fileModel?.descriptionFile = AES128.aes128DecryptECB(description)
                            } else {
                                messageModel.fileModel?.descriptionFile = description
                            }
                        }
                        
                        if let fileModel = CODMessageRealmTool.getMessageByMsgId(messageModel.msgID)?.fileModel {
                            messageModel.fileModel?.localFileID = fileModel.localFileID
                        }
                        
                    }
                    //名片
                    if messageModel.type == .businessCard {
                        messageModel.businessCardModel = BusinessCardModelInfo.deserialize(from: settingDic)
                    }
                    
                    //微语音
                    if messageModel.type == .audio {
                        messageModel.audioModel = AudioModelInfo()
                        if let duration = settingDic["duration"] as? CGFloat {
                            messageModel.audioModel?.audioDuration = duration.float
                        }
                        if let setting = messageDic["setting"] as? Dictionary<String, Any> {
                            if let duration = setting["duration"] as? CGFloat {
                                messageModel.audioModel?.audioDuration = duration.float
                            }
                        }
                        if let audioURL = messageDic["body"] as? String {
                            messageModel.audioModel?.audioURL = audioURL
                        }
                        //AES解密
                        if let description = settingDic["description"] as? String {
                            if AES128.aes128DecryptECB(description) != "" {
                                messageModel.audioModel?.descriptionAudio = AES128.aes128DecryptECB(description)
                            } else {
                                messageModel.audioModel?.descriptionAudio = description
                            }
                            
                        }
                        
                        
                        self.downloadAudio(messageModel, fromJID: fromJID, messageBodyModel: messageBodyModel)
                        
                        return
                    }
                    
                    //微视频
                    if messageModel.type == .video {
                        messageModel.videoModel = VideoModelInfo.deserialize(from: settingDic)
                        if let description = settingDic["description"] as? String {
                            
                            //AES解密
                            messageModel.videoModel?.descriptionVideo = AES128.aes128DecryptECB(description)
                        }
                        
                        if let duration = settingDic["duration"] as? CGFloat {
                            messageModel.videoModel?.videoDuration = duration.float
                        }
                        if let serverVideoId = messageDic["body"] as? String {
                            messageModel.videoModel?.serverVideoId = serverVideoId
                        }
                        if let firstpicId = settingDic["firstpic"] as? String {
                            messageModel.videoModel?.firstpicId = firstpicId
                        }
                        if let description = settingDic["description"] as? String {
                            //AES解密
                            messageModel.videoModel?.descriptionVideo = AES128.aes128DecryptECB(description)
                            
                        }
                        
                    }
                    
                    //语音视频聊天
                    if messageModel.type == .voiceCall || messageModel.type == .videoCall {
                        
                        messageModel.videoCallModel = VideoCallModelInfo.deserialize(from: settingDic)
                        if let roomString = settingDic["room"] as? String {
                            
                            
                            
                            messageModel.videoCallModel!.videoString = messageDic["body"] as! String
                            if message.wasDelayed && messageModel.videoCallModel?.videoCalltype == VideoCallType.request {
                                return
                            }
                            
                            if messageModel.videoCallModel?.videoCalltype == VideoCallType.request {
                                
                                if messageModel.isMeSend && (messageModel.videoCallModel?.resource != UserManager.sharedInstance.resource) {
                                    return
                                }
                            }
                            
                            //                          if Thread.isMainThread {
                            if messageModel.videoCallModel?.videoCalltype == VideoCallType.request {
                                
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSendVoiceStopPlay), object: nil)
                                
                                let delegate = UIApplication.shared.delegate as! AppDelegate
                                if UserDefaults.standard.bool(forKey: kIsVideoCall) || delegate.callObserver.calls.first != nil {
                                    if CODContactRealmTool.getContactByJID(by: messageModel.fromJID) != nil && CustomUtil.getRoomID() != roomString {
                                        let dict: NSDictionary = ["name": COD_busy,
                                                                  "requester": UserManager.sharedInstance.jid,
                                                                  "receiver": messageModel.fromJID,
                                                                  "room": roomString,
                                                                  "chatType": "1",
                                                                  "roomID": "0",
                                                                  "msgType": messageModel.type == .voiceCall ? COD_call_type_voice : COD_call_type_video]
                                        
                                        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
                                        XMPPManager.shareXMPPManager.xmppStream.send(iq)
                                    }
                                    
                                } else {
                                    //                                    UserDefaults.standard.set(true, forKey: kIsVideoCall)
                                    
                                    CustomUtil.setRoomID(roomID: roomString)
                                    
                                    let callRequestVC = CODCallVoiceVC()
                                    callRequestVC.roomID = roomString
                                    callRequestVC.model = messageModel
                                    
                                    if let memberList = settingDic["memberList"] as? Array<String> {
                                        callRequestVC.memberList = memberList
                                    }
                                    
                                    let nav = UINavigationController.init(rootViewController: callRequestVC)
                                    nav.modalPresentationStyle = .overFullScreen
//                                    nav.navigationBar.isHidden = true
                                    nav.modalPresentationCapturesStatusBarAppearance = true
                                    
                                    if UIViewController.current()?.isKind(of: CODCallVoiceVC.classForCoder()) ?? false {
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            
                                            UIViewController.current()?.present(nav, animated: true, completion: nil)
                                        }
                                        
                                    }else{
                                        
                                        UIViewController.current()?.present(nav, animated: true, completion: nil)
                                    }
                                    
                                    
                                    if UserDefaults.standard.bool(forKey: kIsVideoCall) && !message.wasDelayed {
                                        NotificationCenter.default.post(name: NSNotification.Name.init(kReceiveVideoCall), object: messageModel)
                                    }
                                    if messageModel.videoCallModel?.videoCalltype == VideoCallType.accept {
                                        return
                                    }
                                }
                                
                                return
                                
                            } else {
                                
                                if messageModel.videoCallModel?.videoCalltype == VideoCallType.accept && !UserDefaults.standard.bool(forKey: kIsVideoCall) {
                                    
                                    CustomUtil.setRoomID(roomID: roomString)
                                    
                                    let callRequestVC = CODCallVoiceVC()
                                    callRequestVC.roomID = roomString
                                    callRequestVC.model = messageModel
                                    if let memberList = settingDic["memberList"] as? Array<String> {
                                        callRequestVC.memberList = memberList
                                    }
                                    
                                    let nav = UINavigationController.init(rootViewController: callRequestVC)
                                    nav.modalPresentationStyle = .overFullScreen
                                    //                                    nav.navigationBar.isHidden = true
                                    nav.modalPresentationCapturesStatusBarAppearance = true
                                    
                                    if UIViewController.current()?.isKind(of: CODCallVoiceVC.classForCoder()) ?? false {
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            
                                            UIViewController.current()?.present(nav, animated: true, completion: {
                                                
                                                if UserDefaults.standard.bool(forKey: kIsVideoCall) && !message.wasDelayed {
                                                    let bodyDic: NSDictionary = (message.body?.getDictionaryFromJSONString())!
                                                    NotificationCenter.default.post(name: NSNotification.Name.init(kReceiveVideoCall), object: messageModel, userInfo: bodyDic as! [String: Any])
                                                }
                                                
                                            })
                                        }
                                        
                                    }else{
                                        
                                        UIViewController.current()?.present(nav, animated: true, completion: {
                                            
                                            if UserDefaults.standard.bool(forKey: kIsVideoCall) && !message.wasDelayed {
                                                let bodyDic: NSDictionary = (message.body?.getDictionaryFromJSONString())!
                                                NotificationCenter.default.post(name: NSNotification.Name.init(kReceiveVideoCall), object: messageModel, userInfo: bodyDic as! [String: Any])
                                            }
                                            
                                        })
                                    }
                                    
                                    return
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                    
                                    if UserDefaults.standard.bool(forKey: kIsVideoCall) && !message.wasDelayed {
                                        let bodyDic: NSDictionary = (message.body?.getDictionaryFromJSONString())!
                                        NotificationCenter.default.post(name: NSNotification.Name.init(kReceiveVideoCall), object: messageModel, userInfo: bodyDic as! [String: Any])
                                    }
                                    
                                }
                                
                                
                                if messageModel.videoCallModel?.videoCalltype == VideoCallType.accept || messageModel.videoCallModel?.videoCalltype == VideoCallType.oneaccept || messageModel.videoCallModel?.videoCalltype == VideoCallType.offer || messageModel.videoCallModel?.videoCalltype == VideoCallType.answer || messageModel.videoCallModel?.videoCalltype == VideoCallType.candidate || messageModel.isGroupChat{
                                    return
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
                if messageBodyModel.msgTypeEnum == .multipleImage {
                    
                    if let model = self.xmppMessageToRealmMessage(message: message) {
                        messageModel = model
                    }
                    
                }
                
                // MARK: -------------  消息通知处理  -------------
                // 消息通知
                if messageModel.type == .notification {
                    NotificationAction.default.execAction(message: message)
                    messageModel.text = NotificationDeserialize.default.notifcationToPrompt(message: message) ?? ""
                    if messageBodyModel.body == COD_Topmsg {
                        //用来判断是不是置顶消息  置顶的系统消息只显示俩行
                        messageModel.messageBody = COD_Topmsg
                    }
                    NotificationDeserialize.default.configNotifcationModel(message: message, model: messageModel)
                }
                
                
                if messageModel.fromJID == UserManager.sharedInstance.jid {
                    
                    if let chatListModel = CODChatListRealmTool.getChatList(jid: messageModel.toWho) {
                        try! Realm.init().write {
                            if messageModel.type != .notification {
                                
                                chatListModel.count = 0
                                chatListModel.referToMessageID.removeAll()
                            }
                        }
                    }
                }
                
                if messageModel.type == .haveRead {
                    
                    self.multicastDelegate |> { delegate in
                        delegate.beforeSetRead(message: message)
                    }
                    
                    //消息已读
                    switch messageModel.chatTypeEnum {
                    case .groupChat:
                        //群组判断是不是自己的。如果是自己的话,就屏蔽，不是自己的就更新
                        CODChatListRealmTool.updateLastMessageReadTime(id: messageModel.roomId, lastReadTime: messageModel.text)
                    case .privateChat:
                        //单聊的时候是不是需要更新
                        if let contactModel = CODContactRealmTool.getContactByJID(by: messageModel.fromJID) {
                            CODChatListRealmTool.updateLastMessageReadTime(id: contactModel.rosterID, lastReadTime: messageBodyModel.body)
                        }
                    case .channel:
                        //TODO: 频道对应处理
                        break
                        
                    }
                    
                    //如果是当前聊天对象，直接回调到MessageViewController
                    if currentChatFriend == fromJID || (fromJID == UserManager.sharedInstance.jid && currentChatFriend == messageBodyModel.receiver) {
                        if (receiveMsg != nil) {
                            receiveMsg(messageModel)
                        }
                    } else {
                        
                        //消息已读
                        switch messageModel.chatTypeEnum {
                        case .groupChat:
                            if let chatModel = CODChatListRealmTool.getChatList(id: messageModel.roomId) {
                                if let chatMessageModel = chatModel.chatHistory?.messages.sorted(byKeyPath: "datetime", ascending: true).last {
                                    
                                    if messageBodyModel.sender == UserManager.sharedInstance.jid {
                                        return
                                    }
                                    CODMessageRealmTool.updateMessageHaveReadedByMsgId(chatMessageModel.msgID, isReaded: true)
                                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                                    
                                }
                            }
                        case .privateChat:
                            if let contactModel = CODContactRealmTool.getContactByJID(by: messageModel.fromJID) {
                                if let chatModel = CODChatListRealmTool.getChatList(id: contactModel.rosterID) {
                                    if let chatMessageModel = chatModel.chatHistory?.messages.sorted(byKeyPath: "datetime", ascending: true).last {
                                        
                                        if messageBodyModel.sender == UserManager.sharedInstance.jid {
                                            return
                                        }
                                        CODMessageRealmTool.updateMessageHaveReadedByMsgId(chatMessageModel.msgID, isReaded: true)
                                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                                    }
                                }
                            }
                            
                        case .channel:
                            //TODO: 频道对应处理
                            break
                            
                        }
                        
                    }
                    
                    self.multicastDelegate |> { delegate in
                        delegate.afterSetRead(message: message)
                    }
                    
                    return
                }
                
                if messageModel.msgID == "0" {
                    print("------------------------------------------   messageModel.msgID == 0")
                }
                
                if messageModel.type == .text {
                    
                    //AES解密
                    if AES128.aes128DecryptECB(messageModel.text) != "" {
                        messageModel.text = AES128.aes128DecryptECB(messageModel.text)
                    }
                }
                
                var unreadCount = 1
                if messageBodyModel.sender == UserManager.sharedInstance.jid {
                    unreadCount = 0
                }
                
                if messageBodyModel.msgTypeEnum == .notification {
                    unreadCount = 0
                }
                
                if messageBodyModel.msgTypeEnum == .notification && messageModel.text == "" {
                    return
                }
                
                if messageModel.isCloudDiskMessage {
                    messageModel.isReaded = true
                }
                
//                return
                
                switch messageModel.chatTypeEnum {
                case .groupChat:
                    guard let GroupChat = CODGroupChatRealmTool.getGroupChat(id: messageModel.roomId) else {
                        //                        CODChatHistoryRealmTool.insertMessageWithoutChatModel(by: messageModel.roomId, messageModel: messageModel)
                        //找不到群，先创建historyModel，后绑定
                        return
                    }
                    
                    if messageModel.type != .notification {
                        
                        try! Realm().safeWrite {
                            GroupChat.isValid = true
                        }
                    }
                    
                    self.insertChatContactHistory(messages: [messageModel], chatObject: GroupChat, unreadCount: unreadCount)
                    
                case .privateChat:
                    
                    if fromJID == UserManager.sharedInstance.jid {
                        
                        guard let contact = CODContactRealmTool.getContactByJID(by: messageModel.toWho) else {
                            return
                        }
                        self.insertChatContactHistory(messages: [messageModel], chatObject: contact, unreadCount: unreadCount)
                    } else {
                        
                        if let contact = CODContactRealmTool.getContactByJID(by: fromJID) {
                            self.insertChatContactHistory(messages: [messageModel], chatObject: contact, unreadCount: unreadCount)
                        } else {
                            
                            guard let setting = messageBodyModel.setting, let userpic = setting.userpic else {
                                return
                            }
                            
                            let contact = CODContactModel()
                            contact.userpic = userpic
                            contact.rosterID = setting.rosterID ?? 0
                            contact.name = setting.name
                            self.insertChatContactHistory(messages: [messageModel], chatObject: contact, unreadCount: unreadCount)
                        }
                    }
                    
                case .channel:
                    guard let channel = CODChannelModel.getChannel(by: messageModel.roomId) else {
                        //                        CODChatHistoryRealmTool.insertMessageWithoutChatModel(by: messageModel.roomId, messageModel: messageModel)
                        return
                    }
                    
                    self.insertChatContactHistory(messages: [messageModel], chatObject: channel, unreadCount: unreadCount)
                    break
                    
                }
                
                dispatch_async_safely_to_main_queue {
                    
                    
                    //如果是当前聊天对象，直接回调到MessageViewController
                    if self.currentChatFriend == fromJID || (fromJID == UserManager.sharedInstance.jid && self.currentChatFriend == messageBodyModel.receiver) {
                        if (self.receiveMsg != nil) {
                            self.receiveMsg(messageModel)
                        }
                    }
                }
                
                
            }
            
        }
    }
    
    
    func createMessageModel(_ messageIDStr: String, _ messageBodyModel: CODMessageHJsonModel, _ from: String, _ message: XMPPMessage) -> CODMessageModel {
        
        let messageModel = CODMessageModel()
        
        var fromJID = from.subStringTo(string: "/")
        
        messageModel.msgID = messageIDStr
        for memberJid in messageBodyModel.referTo {
            messageModel.referTo.append(memberJid)
        }
        for attributeDic in messageBodyModel.entities {
            if let attributeModel = CODAttributeTextModel.deserialize(from: attributeDic) {
                messageModel.entities.append(attributeModel)
            }
        }
        messageModel.datetime = String(format: "%ld", messageBodyModel.sendTime)
        messageModel.datetimeInt = messageBodyModel.sendTime
        messageModel.burn = messageBodyModel.burn
        messageModel.msgType = messageBodyModel.msgType
        messageModel.edited = messageBodyModel.edited
        messageModel.reply = messageBodyModel.reply
        messageModel.rp = messageBodyModel.rp
        messageModel.fw = messageBodyModel.fw
        messageModel.fwn = messageBodyModel.fwn
        messageModel.fwf = messageBodyModel.fwf
        messageModel.n = messageBodyModel.n
        messageModel.l = messageBodyModel.l
        messageModel.text = messageBodyModel.body
        messageModel.chatTypeEnum = messageBodyModel.chatType
        messageModel.itemID = messageBodyModel.itemID
        messageModel.smsgID = messageBodyModel.smsgID
        messageModel.userPic = CustomUtil.getUserPic(messageBodyModel: messageBodyModel)
        messageModel.fromWho = messageBodyModel.sender
        messageModel.fromJID = messageBodyModel.sender
        messageModel.roomId = messageBodyModel.roomID
        fromJID = messageModel.fromJID
        
        if messageBodyModel.chatType == .groupChat || messageBodyModel.chatType == .channel {//是群组 或者 频道的话，设置fromJID为群JID
            if !fromJID.contains("@conference") {
                fromJID = messageBodyModel.receiver
            }
        } else {
            if fromJID == (XMPPDomainTemp) {
                fromJID = messageBodyModel.sender
            }
        }
        
        if let toJID = message.toStr {
            messageModel.toJID = toJID.subStringTo(string: "/")
        }
        
        messageModel.toWho = messageBodyModel.receiver
        messageModel.toJID = messageBodyModel.receiver
        
        return messageModel
    }
    
    func xmppMessageToJsonMessageModel(message: XMPPMessage)  -> CODMessageHJsonModel? {
        
        guard message.body != nil else {
            return nil
        }
        
        guard let messageBodyDic = message.body?.getDictionaryFromJSONString() as? [String: Any] else {
            return nil
        }
        
        guard let messageBodyModel = CODMessageHJsonModel.deserialize(from: messageBodyDic) else {
            return nil
        }
        
        messageBodyModel.settingJson = JSON(messageBodyDic)["setting"]
        messageBodyModel.dataJson = JSON(messageBodyDic)
        
        return messageBodyModel
        
    }
    
    
    func xmppMessageToRealmMessage(message: XMPPMessage) -> CODMessageModel? {
        
        guard message.body != nil else {
            return nil
        }
        
        guard let messageBodyDic = message.body?.getDictionaryFromJSONString() as? [String: Any] else {
            return nil
        }
        
        guard let messageBodyModel = self.xmppMessageToJsonMessageModel(message: message) else {
            return nil
        }
        
        var fromStr = message.fromStr
        if fromStr == nil {
            fromStr = messageBodyModel.sender
        }
        
        guard let type = message.type, let from = fromStr else {
            return nil
        }
        
        if type.compareNoCaseForString("error") == true { //消息来自系统 且 message.type == error，就是被拒收
            return nil
        }
        
        guard let messageIDStr = message.elementID  else {
            return nil
        }
        
        let fromJID = from.subStringTo(string: "/")
        
        var messageModel = createMessageModel(messageIDStr, messageBodyModel, from, message)
        
        if messageModel.isCloudDiskMessage {
            messageModel.isReaded = true
        }
        
        switch messageModel.type {
            
        case .text:
            configTextModel(messageModel: messageModel, messageBodyModel: messageBodyModel)
            
        case .image:
            messageModel = configImageModel(messageModel: messageModel, messageBodyModel: messageBodyModel)
        case .location:
            messageModel = configLocationModel(messageBodyModel:messageBodyModel, messageModel: messageModel)
        case .file:
            messageModel = configFileModel(messageModel: messageModel, messageBodyDic: messageBodyDic)
        case .businessCard:
            messageModel = configBusinessCardModel(messageBodyDic: messageBodyDic, messageModel: messageModel)
            
        case .haveRead:
            configHaveRead(messageModel: messageModel, messageBodyModel: messageBodyModel, fromJID: fromJID)
            
        case .audio:
            messageModel = configAudioModel(messageModel: messageModel,
                                            fromJID: fromJID, messageBodyModel: messageBodyModel, downloadAudio: false)
            
        case .video:
            messageModel = configVideoModel(messageModel: messageModel, messageBodyDic: messageBodyDic, messageJsonModel: messageBodyModel)
            
        case .voiceCall, .videoCall:
            messageModel = configVideoCallModel(messageModel: messageModel, messageBodyDic: messageBodyDic, messageBodyModel: messageBodyModel)
        case .notification:
            NotificationDeserialize.default.configNotifcationModel(message: message, model: messageModel)
            messageModel.text = NotificationDeserialize.default.notifcationToPrompt(message: message) ?? ""
            if message.body == COD_Topmsg {
                //用来判断是不是置顶消息  置顶的系统消息只显示俩行
                messageModel.messageBody = COD_Topmsg
            }
        case .gifMessage:
            messageModel.text = messageBodyModel.body
            
        case .multipleImage:
            messageModel = configMultipleImage(messageModel: messageModel, messageBodyDic: messageBodyDic)
            
            
            
        case .unknown:
            messageModel.text = messageBodyModel.body
            if let settingValue = messageBodyDic["setting"] {
                messageModel.setting = try? JSON(settingValue).rawData(options: .fragmentsAllowed)
            }
            break
            
        default:
            return nil
            //            messageModel.text = messageBodyModel.body
        }
        
        return messageModel
        
        
    }
    
    func configMultipleImage(messageModel: CODMessageModel, messageBodyDic: [String: Any]) -> CODMessageModel {
        
        messageModel.text = ""
        let json = JSON(messageBodyDic)
        let photos = json["mphoto"]["photos"]
            .map { PhotoModelInfo.createModel(json: $0.1) }
            .compactMap { $0 }
        
        messageModel.imageList.append(objectsIn: photos)
        
        if photos.count == 1 {
            messageModel.toImageModel()
        }
        
        let text = AES128.aes128DecryptECB(json["setting"]["description"].stringValue)
        if text != "" {
            messageModel.text = text
        }
        
        return messageModel
        
    }
    
    private func configHaveRead(messageModel: CODMessageModel, messageBodyModel: CODMessageHJsonModel, fromJID: String) {
        
        //消息已读
        switch messageModel.chatTypeEnum {
        case .groupChat:
            //群组判断是不是自己的。如果是自己的话,就屏蔽，不是自己的就更新
            CODChatListRealmTool.updateLastMessageReadTime(id: messageModel.roomId, lastReadTime: messageModel.text)
        case .privateChat:
            //单聊的时候是不是需要更新
            if let contactModel = CODContactRealmTool.getContactByJID(by: messageModel.fromJID) {
                CODChatListRealmTool.updateLastMessageReadTime(id: contactModel.rosterID, lastReadTime: messageBodyModel.body)
            }
            
        case .channel:
            //TODO: 频道对应处理
            break
        }
        
        
        //如果是当前聊天对象，直接回调到MessageViewController
        if currentChatFriend == fromJID || (fromJID == UserManager.sharedInstance.jid && currentChatFriend == messageBodyModel.receiver) {
        } else {
            
            //消息已读
            
            switch messageModel.chatTypeEnum {
            case .groupChat:
                if let chatModel = CODChatListRealmTool.getChatList(id: messageModel.roomId) {
                    if let chatMessageModel = chatModel.chatHistory?.messages.sorted(byKeyPath: "datetime", ascending: true).last {
                        
                        if messageBodyModel.sender == UserManager.sharedInstance.jid {
                            return
                        }
                        CODMessageRealmTool.updateMessageHaveReadedByMsgId(chatMessageModel.msgID, isReaded: true)
                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                        
                    }
                }
                
            case .privateChat:
                if let contactModel = CODContactRealmTool.getContactByJID(by: messageModel.fromJID) {
                    if let chatModel = CODChatListRealmTool.getChatList(id: contactModel.rosterID) {
                        if let chatMessageModel = chatModel.chatHistory?.messages.sorted(byKeyPath: "datetime", ascending: true).last {
                            
                            if messageBodyModel.sender == UserManager.sharedInstance.jid {
                                return
                            }
                            CODMessageRealmTool.updateMessageHaveReadedByMsgId(chatMessageModel.msgID, isReaded: true)
                            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                        }
                    }
                }
                
            case .channel:
                //TODO: 频道对应处理
                break
                
            }
            
        }
        
    }
    
    private func configTextModel(messageModel: CODMessageModel, messageBodyModel: CODMessageHJsonModel) { //AES解密
        let text = AES128.aes128DecryptECB(messageBodyModel.body)
        if text != "" {
            messageModel.text = text
        }
    }
    
    private func configBusinessCardModel(messageBodyDic: [String: Any], messageModel: CODMessageModel) -> CODMessageModel {
        
        guard let settingDic = messageBodyDic["setting"] as? [String: Any] else {
            return messageModel
        }
        
        messageModel.businessCardModel = BusinessCardModelInfo.deserialize(from: settingDic)
        return messageModel
    }
    
    private func configImageModel(messageModel: CODMessageModel, messageBodyModel: CODMessageHJsonModel) -> CODMessageModel {
        
        var photoModel: PhotoModelInfo!
        
        if let dbMessageModel = CODMessageRealmTool.getMessageByMsgId(messageModel.msgID),
            let dbPhotoModel = dbMessageModel.photoModel {
            dbPhotoModel.setValue(\.serverImageId, value: messageBodyModel.body)
            photoModel = PhotoModelInfo(value: dbPhotoModel)
        } else {
            photoModel = PhotoModelInfo.deserialize(from: messageBodyModel.setting?.toJSON()) ?? PhotoModelInfo()
        }
        
        messageModel.photoModel = photoModel
        messageModel.photoModel?.w = messageBodyModel.setting?.w.float ?? 0.0
        messageModel.photoModel?.h = messageBodyModel.setting?.h.float ?? 0.0
        messageModel.photoModel?.serverImageId = messageBodyModel.body
        
        var picDesc = AES128.aes128DecryptECB(messageBodyModel.setting?.description ?? "")
        if picDesc == "" {
            picDesc = messageBodyModel.setting?.description ?? ""
        }
        messageModel.photoModel?.descriptionImage = picDesc
        
        return messageModel
    }
    
    private func configVideoCallModel(messageModel: CODMessageModel, messageBodyDic: [String: Any], messageBodyModel: CODMessageHJsonModel) -> CODMessageModel {
        
        guard let settingDic = messageBodyDic["setting"] as? [String: Any] else {
            return messageModel
        }
        
        messageModel.videoCallModel = VideoCallModelInfo.deserialize(from: settingDic)
        messageModel.videoCallModel?.videoString = JSON(messageBodyDic)["body"].stringValue
        
        
        return messageModel
    }
    
    
    private func configVideoModel(messageModel: CODMessageModel, messageBodyDic: [String: Any], messageJsonModel: CODMessageHJsonModel) -> CODMessageModel {
        
        guard let settingDic = messageBodyDic["setting"] as? [String: Any], let setting = messageJsonModel.setting else {
            return messageModel
        }
        
        var videoModelInfo = VideoModelInfo.deserialize(from: settingDic)
        
        if let dbVideoModel = CODMessageRealmTool.getMessageByMsgId(messageModel.msgID)?.videoModel {
            _ = dbVideoModel.setValue(messageJsonModel.body, forKey: \.serverVideoId)
                .setValue(setting.firstpic, forKey: \.firstpicId)
            videoModelInfo = VideoModelInfo(value: dbVideoModel)
        }
        
        messageModel.videoModel = videoModelInfo
        
        var descriptionVideo = AES128.aes128DecryptECB(setting.description)
        if descriptionVideo == "" {
            descriptionVideo = setting.description
        }
        
        messageModel.videoModel?.descriptionVideo = descriptionVideo
        
        messageModel.videoModel?.videoDuration = setting.duration.float
        messageModel.videoModel?.serverVideoId = messageJsonModel.body
        messageModel.videoModel?.firstpicId = setting.firstpic
        
        messageModel.videoModel?.w = setting.w.float
        messageModel.videoModel?.h = setting.h.float
        var descriptionImage = AES128.aes128DecryptECB(messageJsonModel.setting?.description ?? "")
        if descriptionImage == "" {
            descriptionImage = messageJsonModel.setting?.description ?? ""
        }
        messageModel.videoModel?.descriptionVideo = descriptionImage
        
        return messageModel
    }
    
    private func configAudioModel(messageModel: CODMessageModel, fromJID: String, messageBodyModel: CODMessageHJsonModel, downloadAudio: Bool = true) -> CODMessageModel {
        messageModel.audioModel = AudioModelInfo()
        messageModel.audioModel?.audioDuration = messageBodyModel.setting?.duration.float ?? 0.0
        messageModel.audioModel?.audioURL = messageBodyModel.body
        
        if downloadAudio {
            self.downloadAudio(messageModel, fromJID: fromJID, messageBodyModel: messageBodyModel)
        }
        var descriptionImage = AES128.aes128DecryptECB(messageBodyModel.setting?.description ?? "")
        if descriptionImage == "" {
            descriptionImage = messageBodyModel.setting?.description ?? ""
        }
        messageModel.audioModel?.descriptionAudio = descriptionImage
        return messageModel;
    }
    
    private func configFileModel(messageModel: CODMessageModel, messageBodyDic: [String: Any]) -> CODMessageModel {
        
        guard let settingDic = messageBodyDic["setting"] as? [String: Any] else {
            return messageModel
        }
        
        
        
        messageModel.fileModel = FileModelInfo.deserialize(from: settingDic)
        messageModel.fileModel?.fileID = messageBodyDic["body"] as? String ?? ""
        var imageName = ""
        let type = CODFileHelper.getFileType(fileName: messageModel.fileModel?.filename ?? "")
        switch type {
        case .PdfType:
            imageName = "pdf_flie"
            break
        case .WordType:
            imageName = "doc_file"
            break
        case .ZipType:
            imageName = "compressed_file"
            break
        case .ExcelType:
            imageName = "xlsx_flie"
            break
        default:
            imageName = "unknow_file"
            break
        }
        messageModel.fileModel?.fileImageName = imageName
        messageModel.fileModel?.fileSizeString = CODFileHelper.getFileSize(fileSize: CGFloat(messageModel.fileModel?.size ?? 0))
        let descriptionImage = AES128.aes128DecryptECB( settingDic["description"] as? String ?? "")
        messageModel.fileModel?.descriptionFile = descriptionImage
        
        if let fileModel = CODMessageRealmTool.getMessageByMsgId(messageModel.msgID)?.fileModel {
            messageModel.fileModel?.localFileID = fileModel.localFileID
        }
        
        return messageModel
    }
    
    private func configLocationModel(messageBodyModel: CODMessageHJsonModel, messageModel: CODMessageModel) -> CODMessageModel {
        
        guard let setting = messageBodyModel.setting else {
            return messageModel
        }
        
        messageModel.location = LocationInfo()
        messageModel.location?.name = setting.title
        messageModel.location?.address = setting.subtitle
        messageModel.location?.latitude = setting.lat
        messageModel.location?.longitude = setting.lat
        messageModel.location?.locationImageString = messageBodyModel.body.getImageFullPath(imageType: 0)
        
        return messageModel
    }
    
    
    func insertChatContactHistory(messages: [CODMessageModel], chatObject: CODChatObjectType, unreadCount: Int) {
        
        //新增消息到数据库
        let chatHistoryModel = CODChatHistoryModel()
        // chatId
        chatHistoryModel.id = chatObject.chatId
        
        if var messageHistoryModelTemp = CODChatListRealmTool.getChatList(id: chatObject.chatId) {
            
            let messageHistoryList = messageHistoryModelTemp.chatHistory?.messages ?? List<CODMessageModel>()
            
            try! Realm().safeWrite {
                
                let editMessages = messages.filter {
                    if let msg = try! Realm().object(ofType: CODMessageModel.self, forPrimaryKey: $0.msgID) {
                        return msg.edited < $0.edited
                    } else {
                        return false
                    }
                }
                
                try! Realm().add(editMessages, update: .modified)
                
                let newMessages = messages.filter {
                    return try! Realm().object(ofType: CODMessageModel.self, forPrimaryKey: $0.msgID) == nil
                }
                
                if chatObject.chatTypeEnum == .groupChat {
                    messageHistoryModelTemp = setAtState(chatListModel: messageHistoryModelTemp, messages: messages)
                }
                
                messageHistoryList.append(objectsIn: newMessages)
                messageHistoryModelTemp.isShowBurned = false
                
                if let lastMsg = messages.last {
                    if lastMsg.datetime > messageHistoryModelTemp.lastDateTime {
                        messageHistoryModelTemp.lastDateTime = lastMsg.datetime
                    }
                }
                
                if chatObject.chatTypeEnum == .groupChat {
                    messageHistoryModelTemp.groupChat = chatObject as? CODGroupChatModel
                    messageHistoryModelTemp.title = chatObject.title
                }
                
                CODChatListRealmTool.setIsInValid(id: chatObject.chatId, isInValid: false)
                
                if self.currentChatFriend == chatObject.jid || messages.first?.fromJID == UserManager.sharedInstance.jid {
                    messageHistoryModelTemp.count = 0
                } else {
                    messageHistoryModelTemp.count += unreadCount
                }
                
                
                
                if let message = messages.first ?? nil {
                    if !chatObject.mute {
                        self.receiveMessageRemind(isCurrentChat: (currentChatFriend == chatObject.jid), message: message)
                    }
                }
            }
            
        } else {
            
            chatHistoryModel.messages.append(objectsIn: messages)
            
            var chatListModel = CODChatListModel()
            
            switch chatObject.chatTypeEnum {
            case .groupChat:
                chatListModel.groupChat = chatObject as? CODGroupChatModel
                chatListModel = setAtState(chatListModel: chatListModel, messages: messages)
            case .privateChat:
                chatListModel.contact = chatObject as? CODContactModel
            case .channel:
                chatListModel.channelChat = chatObject as? CODChannelModel
                break
            }
            
            
            chatListModel.id = chatObject.chatId
            chatListModel.icon = chatObject.icon
            chatListModel.chatTypeEnum = chatObject.chatTypeEnum
            chatListModel.lastDateTime = messages.last?.datetime ?? ""
            chatListModel.jid = chatObject.jid
            chatListModel.chatHistory = chatHistoryModel
            chatListModel.title = chatObject.title
            chatListModel.stickyTop = chatObject.stickytop
            chatListModel.count = unreadCount
            CODChatListRealmTool.insertChatList_ZZS(by: chatListModel)
            
            if let message = messages.first ?? nil {
                if let contact = chatListModel.contact {
                    if !contact.mute {
                        self.receiveMessageRemind(isCurrentChat: (currentChatFriend == contact.jid), message: message)
                    }
                }
                
                if let group = chatListModel.groupChat {
                    if !group.mute {
                        self.receiveMessageRemind(isCurrentChat: (currentChatFriend == group.jid), message: message)
                    }
                }
            }
            
        }
        
        
        
        //通知去聊天列表中更新数据
        let voiceCallMsgs = messages.filter { (model: CODMessageModel) -> Bool in
            return model.msgType == EMMessageBodyType.voiceCall.rawValue || model.msgType == EMMessageBodyType.videoCall.rawValue
        }
        
        DispatchQueue.main.async {
            
            if voiceCallMsgs.count > 0 {
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadCallVC), object: nil, userInfo: nil)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo: nil)
            
        }
        
        
    }
    
    private func setAtState(chatListModel: CODChatListModel, messages: [CODMessageModel]) -> CODChatListModel {
        
        let newChatListModel = chatListModel
        
        for message in messages.reversed() {
            
            if UserManager.sharedInstance.jid == message.fromJID {
                break
            }
            
            if (message.referTo.contains(UserManager.sharedInstance.jid) || message.referTo.contains(kAtAll)) && currentChatFriend != chatListModel.groupChat?.jid {
                if let refertoString = CustomUtil.getRefertoString(message: message) {
                    if !newChatListModel.referToMessageID.contains(refertoString) {
                        newChatListModel.referToMessageID.append(refertoString)
                    }
                }
                break
            }
            
        }
        
        return newChatListModel
        
    }

    func receiveMessageRemind(isCurrentChat: Bool, message: CODMessageModel) {
        
        //        if DoraemonHomeWindow.shareInstance()?.isHidden ?? true != true {
        //            return
        //        }
        
        if !Thread.current.isMainThread {
            return
        }
        
        if message.type == .notification {
            return
        }
        
        if let loginName = UserManager.sharedInstance.loginName {
            if message.fromJID.contains(loginName){
                return
            }
        }
        
        if UIApplication.shared.applicationState == .background {
            return
        }
        
        if CODUserDefaults.object(forKey: kLastSound_Message) != nil {
            
        } else {
            
            CODUserDefaults.set("\(Date.milliseconds)" as NSString, forKey: kLastSound_Message)
            CODUserDefaults.synchronize()
        }
        
        let preview = UserManager.sharedInstance.preview
        
        if !isCurrentChat {
            
            let isSecurityCodeVC = UIViewController.current()?.isKind(of: CODSecurityCodeViewController.classForCoder()) ?? false
            
            if preview && !UserDefaults.standard.bool(forKey: kIsVideoCall) && !isSecurityCodeVC{
                //                NotificationBannerQueue.default.dismissAllForced()
                PopupView.dismissAllPopups()
                let customView = Bundle.main.loadNibNamed("CustomBannerView", owner: self, options: nil)?.last as! CustomBannerView
                
                customView.configMessage(message: message)
                customView.show(showType: .slideInFromTop,
                                dismissType: .slideOutToTop,
                                maskType: PopupView.MaskType(rawValue: 0),
                                layout: .init(horizontal: .left, vertical: .top),
                                duration: 3)
                
            }
        }
        
        if (CustomUtil.getTimeDiff(starTime: CODUserDefaults.object(forKey: kLastSound_Message) as! NSString, endTime: "\(Date.milliseconds)" as NSString) < 1) {
            return
        } else {
            CODUserDefaults.set("\(Date.milliseconds)" as NSString, forKey: kLastSound_Message)
            CODUserDefaults.synchronize()
        }
        
        if message.type == .voiceCall || message.type == .videoCall {
            return
        }
        
        let sound = UserManager.sharedInstance.sound
        let vibrate = UserManager.sharedInstance.vibrate
        
        
//        if isCurrentChat {
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//            AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate)
//        } else {
            
            if sound && vibrate {
                
                let audio = Bundle.main.path(forResource: "notification", ofType: "caf")
                let audioURL = NSURL.fileURL(withPath: audio!)
                var soundID: SystemSoundID = 0
                AudioServicesCreateSystemSoundID((audioURL as CFURL), &soundID)
                
                AudioServicesPlaySystemSoundWithCompletion(soundID, {
                    
                    AudioServicesDisposeSystemSoundID(soundID)
                })
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate)
                
            } else if sound {
                let audio = Bundle.main.path(forResource: "notification", ofType: "caf")
                let audioURL = NSURL.fileURL(withPath: audio!)
                var soundID: SystemSoundID = 0
                AudioServicesCreateSystemSoundID((audioURL as CFURL), &soundID)
                
                AudioServicesPlaySystemSoundWithCompletion(soundID, {
                    
                    AudioServicesDisposeSystemSoundID(soundID)
                })
            } else if vibrate {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate)
            }
//        }
    }
    
    func xmppStream(_ sender: XMPPStream, didFailToSend presence: XMPPPresence, error: Error) {
        print("error:\(error)")
        
    }
    
    
    // MARK: -------------  接收IQ -------------
    
    func xmppDidReceive(iq: XMPPIQ) {
        
        self.messageQueue.async {
            
            guard let elementID = iq.elementID else {
                return
            }
            
            guard let responseBlock = self.iqRequsetQ[elementID] else {
                return
            }
            
            if iq.isErrorIQ {
                dispatch_async_safely_to_main_queue {
                    responseBlock.response(.failure(XMPPManagerError.iqError))
                }
                
                self.iqRequsetQ.removeValue(forKey: elementID)
                return
            }
            
            
            guard let model = self.deserializeToResponseModel(iq: iq) else {
                
                dispatch_async_safely_to_main_queue {
                    responseBlock.response(.failure(XMPPManagerError.iqToModelError))
                }
                
                
                self.iqRequsetQ.removeValue(forKey: elementID)
                return
            }
            
            dispatch_async_safely_to_main_queue {
                if model.success {
                    responseBlock.response(.success(model))
                } else {
                    responseBlock.response(.failure(.iqReturnError(model.errorCode, model.msg)))
                }
            }
            
            self.iqRequsetQ.removeValue(forKey: elementID)
        
        }
        
        
        
    }
    
    func xmppIQSendFail(iq: XMPPIQ) {
        
        guard let elementID = iq.elementID else {
            return
        }
        
        if self.iqRequsetQ.keys.contains(elementID) == false {
            return
        }
        
        guard let responseBlock = self.iqRequsetQ[elementID] else {
            return
        }
        
        dispatch_async_safely_to_main_queue {
            responseBlock.response(.failure(.iqSendError))
        }
        
        self.messageQueue.async {
            self.iqRequsetQ.removeValue(forKey: elementID)
        }
        
        
        
    }
    
    func xmppDisconnetIQRequsetHandler() {
        
        dispatch_async_safely_to_main_queue {
            
            for (_, value) in self.iqRequsetQ {
                value.response(.failure(.disconnect))
            }
            
        }
        
        self.messageQueue.async {
            self.iqRequsetQ.removeAll()
        }
        
        
        
        
    }
    
    func deserializeToResponseModel(iq: XMPPIQ) -> CODResponseModel? {
        
        var model: CODResponseModel?
        
        guard let childElement = iq.childElement else {
            return nil
        }
        
        let jsonData: JSON? = childElement.getChildrenJSON(name: "result")
        let actionJson: JSON? = childElement.getChildrenJSON(name: "action")
        
        //        if let children = childElement.children {
        //            for child in children {
        //                if child.name == "action" {
        //                    actionJson = JSON(parseJSON: child.stringValue ?? "")
        //                }
        //
        //                if child.name == "result" {
        //                    jsonData = JSON(parseJSON: child.stringValue ?? "")
        //                }
        //
        //            }
        //
        //        }
        
        model = CODResponseModel.deserialize(from: jsonData?.dictionaryObject) ?? CODResponseModel()
        
        model?.actionJson = actionJson
        model?.name = actionJson?["name"].stringValue
        
        if let jsonData = jsonData {
            model?.errorCode = jsonData["code"].intValue
        }
        
        if model?.data == nil {
            model?.data = jsonData?.dictionaryObject
        }
        
        if let data = model?.data {
            model?.dataJson = JSON(data)
        }
        
        return model
        
    }
    
    
    /// 成功接收IQ
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        print("IQ回调：\(iq)")
        
        
        xmppDidReceive(iq: iq)
        if iq.isErrorIQ {
            return true
        }
        
        let member = iq.childElement
        
        if member?.name == "ping" {
            
            let pingIQ = XMLElement.init(name: "ping", xmlns: "jabber:client")
            let IQ = XMLElement.init(name: "iq")
            IQ.addAttribute(withName: "from", objectValue: self.xmppStream.myJID as Any)
            IQ.addAttribute(withName: "to", objectValue: self.xmppStream.myJID?.domain as Any)
            IQ.addAttribute(withName: "type", objectValue: "get")
            IQ.addChild(pingIQ)
            self.xmppStream.send(IQ)
        }
        
        //                    if let loginName = UserManager.sharedInstance.loginName {
        //                        if let lastPushTime = CODUserDefaults.object(forKey: kLastMessageTime + loginName) as? String{
        //                            CustomUtil.getHistoryMessage(lastMessageTime: lastPushTime, roomID: "")
        //                        } else {
        //                            CustomUtil.getHistoryMessage(lastMessageTime: "0", roomID: "")
        //                        }
        //                    }
        //
        //                    if let lastPushTime = CODUserDefaults.object(forKey: kLastMessageTime + loginName) as? String{
        //                        CustomUtil.getSessionItemList(lastPushTime: lastPushTime, isFull: false)
        //                    }else{
        //                        CustomUtil.getSessionItemList(lastPushTime: "0", isFull: true)
        //                    }
        //                }
        //                return true
        //            }
        //        }
        
        //        if member?.name == "notify" {
        //            let xmls = member?.xmlns()
        //            if xmls == xinhoo_notify_session {
        //                XinhooTool.addLog(log:"服务器返回会话列表")
        //                XinhooTool.addLog(log:"-------------------------")
        //                 CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
        //
        //                    UserDefaults.standard.set(infoDict, forKey: "sessionItemVoList")
        //                    if UserDefaults.standard.synchronize() {
        //
        //                        let dic = UserDefaults.standard.object(forKey: "sessionItemVoList") as! NSDictionary
        //                        CustomUtil.parsingSessionItemList(dic: dic)
        //                    }
        //                }
        //                return true
        //            }
        //        }
        
        guard let item = member?.child(at: 0) else {
            return true
        }
        
        let xmlStr = item.stringValue
        let jsonData = JSON(parseJSON: xmlStr!)
        guard let dic = jsonData.dictionaryObject else {
            return true
        }
        guard let name = dic["name"] as? String else {
            return true
        }
        
        
        let model: CODResponseModel? = self.deserializeToResponseModel(iq: iq)
        
        CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
            if (actionDict["name"] as? String == COD_request) {
                if (infoDict!["success"] as! Bool) {
                    
                } else {
                    if let code = infoDict!["code"] as? Int {
                        switch (code) {
                            
                        case 30021, 30005, 30006:
                            let alert = UIAlertController.init(title: "无法呼叫", message: "根据对方隐私设置，您不能跟对方进行通话", preferredStyle: .alert)
                            let confirmAction = UIAlertAction.init(title: "好", style: .default, handler: nil)
                            alert.addAction(confirmAction)
                            UIViewController.current()!.present(alert, animated: true, completion: nil)
                            break
                        default:
                            break
                        }
                    }
                    
                }
            }
        }
        
        
        if jsonData["name"].stringValue == COD_GetContacts { //获取联系人列表
            
            DispatchQueue.global().async {
                print("获取到联系人*******************")
                self.getContactList(node: (member?.child(at: 1))!, nameStr: name)
                //                if !self.isRepairData {
                
                CustomUtil.getSessionList()
                //                } else {
                //                    NotificationCenter.default.post(name: NSNotification.Name.init(kRepairSuccess), object: nil)
                //                }
            }
        } else if jsonData["name"] == "searchUserBTN" { //搜索好友
            
            self.getSearchData(node: (member?.child(at: 1))!, nameStr: name)
        } else if (jsonData["name"] == "createRoom" ||
            jsonData["name"] == "inviteMember" ||
            jsonData["name"] == "kickOutMember" ||
            jsonData["name"] == "destroyRoom" ||
            jsonData["name"] == "editRoomName" ||
            jsonData["name"].stringValue == COD_groupSetting ||
            jsonData["name"] == "transferOwner" ||
            jsonData["name"].stringValue == COD_Getchannelsetting ||
            jsonData["name"] == "setNotice") {
            
            self.resultModelWithMessageNode(node: (member?.child(at: 1))!, nameStr: name)
        } else {
            
            
            if self.successBlock != nil && (jsonData["name"] != "changeChat") && (jsonData["name"] != "getRoomMsgHistory") && (jsonData["name"] != "getMsgHistoryCDMessage") && (jsonData["name"] != "request") {
                if let model = model {
                    self.successBlock(model, name)
                } else {
                    self.successBlock(CODResponseModel(), name)
                }
                
                self.failBlock = nil
                self.successBlock = nil
                
            }
        }
        
        //MARK: 获取会话列表
        if jsonData["name"] == "getsessionitemlist" {
            
            
            CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
                guard let infoDict = infoDict else {
                    return
                }
                
                if let data = infoDict["data"] as? NSDictionary {
                    
                    let json = JSON(actionDict).dictionaryValue
                    let isUpdate = (json["lastPushTime"]?.string != "0")
                    
                    
                    CustomUtil.parsingSessionItemList(dic: data,isUpdate: isUpdate, topRankList: self.topRankList)
                    
                    
                    if let tipsMessageList = JSON(data)["tipsMessageList"].arrayObject as? [String] {
                        
                        self.deleteMessage(msgIDs: tipsMessageList)
                        
                        
                    }
                    
                    
                    
                } else {
                    CustomUtil.sendPresence()
                }
                
                
                
            }
            
            
            
        }
        
        //MARK: 通讯录增量更新
        if jsonData["name"] == "getContactsUpdate" {
            CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
                
                guard let infoDict = infoDict else {
                    return
                }
                
                let ver = (NSString.init(format: "%@", infoDict["ver"] as? NSNumber ?? NSNumber.init(value: 0))) as String
                if let lastUpdateTime = CODUserDefaults.object(forKey: kLastUpdateContactTime + UserManager.sharedInstance.loginName!) {
                    
                    if ((lastUpdateTime as! String) < ver) {
                        CODUserDefaults.set(ver, forKey: kLastUpdateContactTime + UserManager.sharedInstance.loginName!)
                        CODUserDefaults.synchronize()
                    }
                    
                } else {
                    
                    CODUserDefaults.set(ver, forKey: kLastUpdateContactTime + UserManager.sharedInstance.loginName!)
                    CODUserDefaults.synchronize()
                }
                
                if let topRankList = infoDict["topRankList"] as? [String] {
                    self.topRankList = topRankList
                }
                
                DispatchQueue.global().async {
                    if let list: Array = infoDict["roster"] as? [Dictionary<String, Any>] {
                        for contact in list {
                            let contactModel = CODContactModel()
                            contactModel.jsonModel = CODContactHJsonModel.deserialize(from: contact)
                            
                            //根据后台数据status判断该联系人改变，REMOVE 是被删除，ACTIVE 是改变或新增
                            if (contact["status"] as! String) == "REMOVE" {
                                contactModel.isValid = false
                            } else {
                                contactModel.isValid = true
                            }
                            
                            if let model = CODContactRealmTool.getContactById(by: contactModel.rosterID) {
                                if model.timestamp > 0 {
                                    contactModel.timestamp = model.timestamp
                                }
                            }
                            CODContactRealmTool.insertContact(by: contactModel)
                            if let listModel = CODChatListRealmTool.getChatList(id: contactModel.rosterID) {
                                try! Realm.init().write {
                                    listModel.title = contactModel.getContactNick()
                                    listModel.stickyTop = contactModel.stickytop
                                    listModel.jid = contactModel.jid
                                }
                            }
                        }
                    }
                    
                    if let channellist: Array = infoDict["channel"] as? [Dictionary<String, Any>] {
                        
                        for channel in channellist {
                            
                            guard let jsonModel = CODChannelHJsonModel.deserialize(from: channel) else {
                                continue
                            }
                            
                            
                            let channelModel = CODChannelModel(jsonModel: jsonModel)
                            
                            if (channel["status"] as? String) == "REMOVE" {
                                channelModel.isValid = false
                            } else {
                                channelModel.isValid = true
                                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: channelModel.grouppic, complete: nil)
                                if let memberArr = channel["channelMemberVoList"] as! [Dictionary<String, Any>]? {
                                    var members: [CODGroupMemberModel] = []
                                    for member in memberArr {
                                        let memberTemp = CODGroupMemberModel()
                                        memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                                        memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                                        members.append(memberTemp)
                                    }
                                    
                                    channelModel.updateMembersWithContactsList(members, roomId: channelModel.roomID)
                                    //                                channelModel.updateMembers(members)
                                }
                                if let noticeContent = channel["noticecontent"] as? Dictionary<String, Any> {
                                    if let notice = noticeContent["notice"] as? String {
                                        channelModel.notice = notice
                                    }
                                }
                                channelModel.customName = CODGroupChatModel.getCustomGroupName(memberList: channelModel.member)
                            }
                            
                            channelModel.addChannelChat()
                            if let listModel = CODChatListRealmTool.getChatList(id: channelModel.roomID) {
                                try! Realm.init().write {
                                    listModel.stickyTop = channelModel.stickytop
                                    listModel.jid = channelModel.jid
                                    listModel.title = channelModel.descriptions
                                    listModel.isInValid = !channelModel.isValid
                                }
                            }
                        }
                    }
                    
                    
                    
                    if let grouplist: Array = infoDict["group"] as? [Dictionary<String, Any>] {
                        
                        for group in grouplist {
                            
                            guard let _ = CODGroupChatHJsonModel.deserialize(from: group) else {
                                continue
                            }
                            
                            
                            let groupChatModel = CODGroupChatModel()
                            groupChatModel.jsonModel = CODGroupChatHJsonModel.deserialize(from: group)
                            
                            if (group["status"] as! String) == "REMOVE" {
                                groupChatModel.isValid = false
                            } else {
                                groupChatModel.isValid = true
                                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: groupChatModel.grouppic, complete: nil)
                                if let memberArr = group["member"] as! [Dictionary<String, Any>]? {
                                    for member in memberArr {
                                        let memberTemp = CODGroupMemberModel()
                                        memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                                        memberTemp.memberId = String(format: "%d%@", groupChatModel.roomID, memberTemp.username)
                                        groupChatModel.member.append(memberTemp)
                                    }
                                }
                                if let noticeContent = group["noticecontent"] as? Dictionary<String, Any> {
                                    if let notice = noticeContent["notice"] as? String {
                                        groupChatModel.notice = notice
                                    }
                                }
                                groupChatModel.customName = CODGroupChatModel.getCustomGroupName(memberList: groupChatModel.member)
                            }
                            
                            CODGroupChatRealmTool.insertGroupChat(by: groupChatModel)
                            if let listModel = CODChatListRealmTool.getChatList(id: groupChatModel.roomID) {
                                try! Realm.init().write {
                                    listModel.stickyTop = groupChatModel.stickytop
                                    listModel.jid = groupChatModel.jid
                                }
                            }
                        }
                    }
                    
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                        //通讯录更新成功，获取会话列表
                        CustomUtil.getSessionList()
                    }
                    
                }
                
                
                
                
            }
        }
        
        if jsonData["name"] == "editedmsg" || jsonData["name"] == "clouddiskeditedmsg" {
            CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
                if let success: Bool = infoDict?["success"] as? Bool ,success == false{
                    
                    if let errorMessage: String = infoDict?["msg"] as? String,let msgID: String = actionDict["msgID"] as? String {
                        
                        if self.editFailMsgBlock != nil {
                            
                            self.editFailMsgBlock(msgID,errorMessage)
                        }
                    }
                }
                
            }
        }
        
        
        return true
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        
        DispatchQueue.global().async {
            if presence.isErrorPresence {
                return
            }
            
            guard let fromStr = presence.fromStr, let presenceType = presence.type else {
                return
            }
            let jid = fromStr.subStringTo(string: "/")
            guard let contact = CODContactRealmTool.getContactByJID(by: jid) else {
                return
            }
            
            if let presenceType = presence.show {
                
                CODContactRealmTool.updateLoginStatus(jid: jid, presence: presence)
                if !(presence.fromStr?.contains("conference"))! {
                    print("收到用户当前状态消息--------\n来自:\(presence.fromStr ?? "***未知好友***")\n状态:\(presenceType )")
                }
            }else{
                
                CODContactRealmTool.updateLoginStatus(jid: jid, presence: presence)
                if !(presence.fromStr?.contains("conference"))! {
                    print("收到用户当前状态消息--------\n来自:\(presence.fromStr ?? "***未知好友***")\n状态:\(presenceType )")
                }
            }
            
            if let _ = CODChatListRealmTool.getChatList(id: contact.rosterID) {
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.init(kXMPPPresenceNoti), object: nil, userInfo:nil)
                }
                
                
            }
        }
        
        
        
    }
    

    
    //发送失败
    func xmppStream(_ sender: XMPPStream, didFailToSend iq: XMPPIQ, error: Error) {
        
        self.xmppIQSendFail(iq: iq)
        
        let model = CODResponseModel()
        model.msg = error.localizedDescription
        model.success = false
        if (self.failBlock != nil) {
            
            self.failBlock(model)
            self.failBlock = nil
            self.successBlock = nil
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didSend iq: XMPPIQ) {
        print("成功发送IQ \(iq)")
    }
    
//    func xmppStream(_ sender: XMPPStream, willSend iq: XMPPIQ) -> XMPPIQ? {
//        
//        if var json = iq.getJSON(name: "action") {
//            json["version"] = JSON(CustomUtil.getVersionForHeader())
//            iq.setJSON(to: "action", json: json)
//        }
//        
//        return iq
//    }
    
    //    func xmppStream(_ sender: XMPPStream, willSend message: XMPPMessage) -> XMPPMessage? {
    //
    //        CODMessageRealmTool.updateMessageStyleByMsgId(message.elementID ?? "0", status: CODMessageStatus.Delivering.rawValue)
    //
    //        return message
    //
    //    }
    //
    
    /// 成功发送消息
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        print("成功发送消息 \(message.description)")
        
    }
    
    /// 发送消息失败
    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        print("失败发送消息: \(error)")
    }
    
    func xmppStreamWasTold(toDisconnect sender: XMPPStream) {
        print(sender)
    }
    
    func xmppStreamManagement(_ sender: XMPPStreamManagement, didReceiveAckForStanzaIds stanzaIds: [Any]) {
        
        print("receive000000000000000\(stanzaIds)")
    }
    
    func xmppStreamManagementDidRequestAck(_ sender: XMPPStreamManagement) {
        print("request000000000000000")
    }
    
    func xmppStream(_ sender: XMPPStream, didReceiveCustomElement element: DDXMLElement) {
        //        print("接收自定义element\(element)")
    }
    
    func xmppStream(_ sender: XMPPStream, didSendCustomElement element: DDXMLElement) {
        //        print("发送自定义element\(element)")
    }
    
    fileprivate func downloadAudio(_ audioModel: CODMessageModel, fromJID: String, messageBodyModel: CODMessageHJsonModel) {
        
        var jid = ""
        if fromJID.contains(UserManager.sharedInstance.loginName!) {
            
            jid = audioModel.toJID
        } else {
            jid = fromJID
        }
        
        let filePath = CODAudioPlayerManager.sharedInstance.pathUserPathWithAudio(jid: jid).appendingPathComponent(audioModel.audioModel!.audioURL).appendingPathExtension("mp3")
        var urlString = URLRequest(url: URL(string: audioModel.audioModel!.audioURL.getImageFullPath(imageType: 0, isCloudDisk: jid.contains(kCloudJid)))!)
        let nameStr = String(format: "%@:%@", UserManager.sharedInstance.loginName ?? "", UserManager.sharedInstance.password ?? "")
        let utf8Data = nameStr.data(using: String.Encoding.utf8)
        let base64String = utf8Data?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        let authValue = String(format: "Basic %@", base64String ?? "")
        urlString.setValue("*/*", forHTTPHeaderField: "Accept")
        urlString.setValue(authValue, forHTTPHeaderField: "Authorization")
        
        let destination: DownloadRequest.Destination = { url, response in
            let fileURL = URL.init(fileURLWithPath: filePath!)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        HttpManager.share.manager.download(urlString, interceptor: afHttpAdapter, to: destination).authenticate(with: ClientTrust.sendClientCer()).downloadProgress { (progress) in
        }.response { (response) in
            if let _ = response.error {
                print("\(String(describing: response.error.debugDescription))")
            } else {
                ///下载好的文件移动文件到新的文件夹

                guard let downURL = response.fileURL else {
                    return
                }
                
                if FileManager.default.fileExists(atPath: downURL.path) {
                    do {
                        try FileManager.default.moveItem(at: downURL, to: URL(string: filePath!)!)
                    } catch {
                        
                    }
                    
                    dispatch_async_safely_to_main_queue {
                        
                        switch audioModel.chatTypeEnum {
                        case .groupChat:
                            guard let GroupChat = CODGroupChatRealmTool.getGroupChat(id: audioModel.roomId) else {
                                print("查询不到群")
                                return
                            }
                            self.insertChatContactHistory(messages: [audioModel], chatObject: GroupChat, unreadCount: 1)
                            
                        case .privateChat:
                            if fromJID == UserManager.sharedInstance.jid {
                                guard let contact = CODContactRealmTool.getContactByJID(by: audioModel.toWho) else {
                                    return
                                }
                                self.insertChatContactHistory(messages: [audioModel], chatObject: contact, unreadCount: 1)
                                
                            } else {
                                guard let contact = CODContactRealmTool.getContactByJID(by: fromJID) else {
                                    return
                                }
                                self.insertChatContactHistory(messages: [audioModel], chatObject: contact, unreadCount: 1)
                            }
                            
                        case .channel:
                            guard let channel = CODChannelModel.getChannel(by: audioModel.roomId) else {
                                return
                            }
                            self.insertChatContactHistory(messages: [audioModel], chatObject: channel, unreadCount: 1)
                            break
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                        //如果是当前聊天对象，直接回调到MessageViewController
                        if self.currentChatFriend == fromJID || (fromJID == UserManager.sharedInstance.jid && self.currentChatFriend == messageBodyModel.receiver) {
                            if (self.receiveMsg != nil) {
                                self.receiveMsg(audioModel)
                            }
                        }
                    }
                    
                }
                
            }
        }
    }
    
    func xmppStream(_ sender: XMPPStream, willSecureWithSettings settings: NSMutableDictionary) {
        settings.setObject(self.xmppStream.myJID?.domain as Any, forKey: kCFStreamSSLPeerName as! NSCopying)
        if customCertEvaluation {
            settings.setObject(true, forKey: GCDAsyncSocketManuallyEvaluateTrust as NSCopying)
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
}

extension XMPPManager: XMPPAutoPingDelegate {
    func xmppAutoPingDidReceivePong(_ sender: XMPPAutoPing!) {
        autoPingTimeoutCount = 0
    }
    
    func xmppAutoPingDidTimeout(_ sender: XMPPAutoPing!) {
        print("autoPing 超时")
        autoPingTimeoutCount += 1
        if autoPingTimeoutCount >= 2 {
            print("超时3次重连")
            autoPingTimeoutCount = 0
            XinhooTool.addLog(log:"【主动断开连接】Ping 超时")
            self.xmppStream.disconnect()
            self.xmppDisconnetIQRequsetHandler()
            self.xmppReconnect.manualStart()
        }
    }
    

}

extension XMPPManager: XMPPReconnectDelegate {
    
    func xmppReconnect(_ sender: XMPPReconnect, didDetectAccidentalDisconnect connectionFlags: SCNetworkConnectionFlags) {
        //        self.isActive = false
    }
    
    func xmppReconnect(_ sender: XMPPReconnect, shouldAttemptAutoReconnect connectionFlags: SCNetworkConnectionFlags) -> Bool {
        
        reconnectCount += 1
        print("重连第 \(reconnectCount) 次 #################")
        
        if reconnectCount == 3 {
            
            AutoSwitchIPManager.share.setBestIP()
            
        }
        
        return true
    }
}
