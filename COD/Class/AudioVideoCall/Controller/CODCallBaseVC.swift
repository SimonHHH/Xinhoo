//
//  CODCallBaseVC.swift
//  COD
//
//  Created by Xinhoo on 2019/8/21.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import MBProgressHUD
import AudioToolbox

public let connectedFaileTimeOut:TimeInterval = 20
public let iceDisconnectedTimeOut:TimeInterval = 30

class CODCallBaseVC: BaseViewController {
    
    enum Status:Int {
        case Unknow = 0
        case caller      //呼叫者
        case callee      //电话受话人
    }
    
    enum State:Int {
        case unconnected = 0
        case connecting
        case connected
        case disconnecting
        case disconnected
    }
    
    var prevStatusBarHidden:Bool = false
    var prevStatusBarStyle:UIStatusBarStyle = .lightContent
    
    var statusBarHidden:Bool = false
    var statusBarStyle:UIStatusBarStyle = .lightContent
    
    var isCancelOrRefuse:Bool = false
    
    var jid : String {
        
        switch self.status {
        case .caller:
            return self.model!.toJID
        case .callee:
            return isGroupCall ? self.model!.toJID : self.model!.fromJID
        case .Unknow:
            return ""
        }
    }
    var roomID = ""
    
    
    var groupRoomID: Int {
        return self.groupModel?.roomID ?? 0
    }
    
    
    var callType = COD_call_type_voice
    
    var status:Status = CODCallBaseVC.Status(rawValue: 2)!
    var state:State = CODCallBaseVC.State(rawValue: 0)!
    
    var model:CODMessageModel?
    
    var isGroupCall: Bool {
        return self.model?.isGroupChat ?? false
    }
    
    var contactModel:CODContactModel? {
        
        if let contact = CODContactRealmTool.getContactByJID(by: jid) {
            
            return contact
        }
        return nil
    }
    
    var groupModel:CODGroupChatModel? {
        
        if let model = CODGroupChatRealmTool.getGroupChatByJID(by: jid) {
            
            return model
        }
        
        return nil
    }
    
    /// 参与人数
    @objc dynamic var memberList: Array<String> = []
    
    /// 已经加入人数
    @objc dynamic var joinMemberList: Array<String> = []
    
    var timer:DispatchSourceTimer?
    var timeoutTimer:DispatchSourceTimer?
    var player:AVAudioPlayer?
    
    var seconds = 0
    var timeOutSeconds = 0
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        
        prevStatusBarHidden = UIApplication.shared.isStatusBarHidden
        prevStatusBarStyle = UIApplication.shared.statusBarStyle
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        
        self.statusBarHidden = self.prevStatusBarHidden
        self.statusBarStyle = self.prevStatusBarStyle
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.statusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.darkGray
        
        try? AVAudioSession.sharedInstance().setActive(true)
        
        UserDefaults.standard.set(true, forKey: kIsVideoCall)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginOut), name: NSNotification.Name.init(kLoginoutNoti), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.noNetWork), name: NSNotification.Name.init(kWaitNetwork), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveVideoCall), name: NSNotification.Name.init(kReceiveVideoCall), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kAudioCallBegin), object: nil)
        CODAudioPlayerManager.sharedInstance.stop()
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.status = (self.model?.fromJID == UserManager.sharedInstance.jid) ? .caller : .callee
        self.initSetup();
        self.initUI();
        
        self.startTimeOut()
    }
    
    func initUI() {}
    
    func initSetup() {
        CODWebRTCManager.shared().iceConnectionStateBlock = {[weak self](socketId, state)->() in
            guard let `self` = self else {
                return
            }
            
            switch state {
            case RTCIceConnectionState.checking:
                break;
            case RTCIceConnectionState.connected:
                if !self.joinMemberList.contains(socketId) {
                    self.joinMemberList.append(socketId)
                }
                if socketId == UserManager.sharedInstance.jid || !self.isGroupCall {
                    
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.dismissByICEDisconnected), object: nil)
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.connectedFailed), object: nil)
                }
                self.hideNetworkMsg()
                if self.state != .connected {
                    self.state = .connected
                    if !self.isCancelOrRefuse {
                        self.connectedDone()
                    }
                }
                break
            case RTCIceConnectionState.completed:
                break
            case RTCIceConnectionState.failed:
                break
            case RTCIceConnectionState.disconnected:
                self.joinMemberList = Array(self.joinMemberList)
                if self.state == .connected {
                    if !self.isGroupCall {
                        if CODWebRTCManager.whetherConnectedNetwork() {
                            self.showNetworkMsg(strMsg: "当前通话对方的网络不佳")
                        } else {
                            self.showNetworkMsg(strMsg: "当前通话您的网络不佳")
                        }
                        self.perform(#selector(self.dismissByICEDisconnected), with: nil, afterDelay: iceDisconnectedTimeOut)
                    }
                }
                break
            case RTCIceConnectionState.closed:
                break
            default:
                break
            }
        }
    }
    
    func connectedDone() {}
    func showNetworkMsg(strMsg:String) {}
    func hideNetworkMsg() {}
    
    func sendIQ(iqName:String) {
        let dict:NSDictionary = ["name":iqName,
                                 "requester":UserManager.sharedInstance.jid,
                                 "receiver":self.jid,
                                 "room":self.roomID,
                                 "chatType":self.isGroupCall ? "2" : "1",
                                 "roomID":self.groupRoomID,
                                 "msgType":self.callType]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func sendHeartBeatsIQ() {
        
        let dict:NSDictionary = ["name":COD_heartbeats,
                                 "requester":UserManager.sharedInstance.jid,
                                 "receiver":self.jid,
                                 "setting":["room":self.roomID]]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        
    }
    
    @objc func noNetWork(noti:NSNotification) {
        self.showMessageWithHud(message: "当前网络异常,请检查网络连接") {
            //self.dismissVC()
        }
    }
    
    @objc func loginOut(noti:NSNotification) {
        if self.state == .unconnected {
            if self.model?.fromJID == UserManager.sharedInstance.jid {
                self.sendIQ(iqName: COD_cancel)
            }
        } else {
            self.sendIQ(iqName: COD_close)
        }
        self.dismissVC()
    }
    
    @objc func connectedFailed() {
        self.sendIQ(iqName: COD_connectfailed)
        self.dismissWithHudmsgAndAudio(strMsg: "网络异常，连接中断")
    }
    
    @objc func loginOnElseWhere(noti:NSNotification) {
        self.dismissWithAudio()
    }
    
    @objc func appDidEnterBackground() {
        if self.state == .unconnected && self.model?.fromJID != UserManager.sharedInstance.jid {
            self.player?.stop()
        }
    }
    
    @objc func receiveVideoCall(noti:NSNotification) {
        let bodyDic:Dictionary = noti.userInfo ?? Dictionary.init()
        let model = noti.object as! CODMessageModel
        let type = model.videoCallModel?.videoCalltype ?? .request
        
        if self.roomID != model.videoCallModel?.room {  //收到request后，避免上次异常退出后收到上次'close'而退出
            return
        }
        
        var dismissMessage: String?
        
        switch type {
        case .accept:
            self.player?.stop()
            
            
            self.timeoutTimer?.cancel()
            self.timeoutTimer = nil
            
            if (model.videoCallModel?.requester == UserManager.sharedInstance.jid) && (model.videoCallModel?.resource != UserManager.sharedInstance.resource) {
                
                
                
                UserDefaults.standard.set(false, forKey: kIsVideoCall)
                self.dismissWithHudmsgAndAudio(strMsg: "已在别的端接听")
                return
                
            }
                
               
            CODWebRTCManager.shared().handleMessage(bodyDic)
            self.state = .connecting
            
            self.acceptDone()
//            if model.videoCallModel?.requester != UserManager.sharedInstance.jid {
//                self.perform(#selector(self.connectedFailed), with: nil, afterDelay: connectedFaileTimeOut)
//            }
            break
        case .close:
            
            if canDeleteMember(model: model) {
                
                self.deleteMember(jid: model.videoCallModel?.requester)
                
            } else {
                
                self.timer?.cancel()
                self.timer = nil
                
                if model.videoCallModel?.isKillerWithServer() ?? false {
                
                    dismissMessage = "通话已断开"
                } else {
                    dismissMessage = "通话结束"
                }
                
                
                
                CODWebRTCManager.shared().handleMessage(bodyDic)
                self.state = .disconnected
                
//                if model.videoCallModel?.requester != UserManager.sharedInstance.jid {
//                    if callType == COD_call_type_voice {
//                        self.closeDone(strMsg: dismissMessage!)
//                        dismissMessage = nil
//                    }
//                } else {
//                    dismissMessage = nil
//                }
                
            }
            
            
            break
        case .reject:
            
            if canDeleteMember(model: model) {
                
                self.deleteMember(jid: model.videoCallModel?.requester)
                
            } else {
                
                if model.videoCallModel?.requester != UserManager.sharedInstance.jid {
                    dismissMessage = "对方已拒绝"
                } else if (model.videoCallModel?.requester == UserManager.sharedInstance.jid) && (model.videoCallModel?.resource != UserManager.sharedInstance.resource){
                    dismissMessage = "已在别的端拒绝"
                }
                
            }
            
            
            break
        case .cancle:
            if model.videoCallModel?.requester != UserManager.sharedInstance.jid {
                dismissMessage = "对方已取消"
            }
            break
        case .timeout:
            
            if canDeleteMember(model: model) {
                
                self.deleteMember(jid: model.videoCallModel?.requester)
                
            } else {
                
                if self.roomID == model.videoCallModel?.room {
                    dismissMessage = self.status == .caller ? "对方无应答" : "通话未接听"
                }
            }
            
            break
        case .busy:
            
            if canDeleteMember(model: model) {
                
                self.deleteMember(jid: model.videoCallModel?.requester)
                
            } else {
                
                let strCallType = self.callType == COD_call_type_voice ? "语音" : "视频"
                if self.status == .caller {
                    dismissMessage = NSLocalizedString(String.init(format: "对方忙，请稍后再发起%@通话", "\(strCallType)"), comment: "");
                }
            }
            
            break
        case .connectfailed:
            
            if canDeleteMember(model: model) {
                
                self.deleteMember(jid: model.videoCallModel?.requester)
                
            } else {
                
                if model.videoCallModel?.requester != UserManager.sharedInstance.jid {
                    dismissMessage = "网络异常，连接中断"
                }
            }
            
            break
        case .oneaccept:  //群组，新加入成员给群里成员所发消息
            CODWebRTCManager.shared().handleMessage(bodyDic)
            
            if let settingDic = bodyDic["setting"] as? Dictionary<String,Any> {
                if let memberJoin = settingDic["jid"] as? String {
                    if !self.memberList.contains(memberJoin) {
                        self.memberList.append(memberJoin)
                    }
                }
            }
            
            break
        case .offer:
            CODWebRTCManager.shared().handleMessage(bodyDic)
            break
        case .answer:
            CODWebRTCManager.shared().handleMessage(bodyDic)
            break
        case .candidate:
            CODWebRTCManager.shared().handleMessage(bodyDic)
            break
        case .requestmore:
            
            if let settingDic = bodyDic["setting"] as? Dictionary<String,Any> {
                if let memberList = settingDic["memberList"] as? Array<String> {
                    self.memberList.append(contentsOf: memberList)
                }
            }
            
            break
            
        default:
            break
        }
        
        if dismissMessage == nil {
            return
        }

        if self.timeoutTimer != nil {
            self.timeoutTimer?.cancel()
            self.timeoutTimer = nil
        }
        UserDefaults.standard.set(false, forKey: kIsVideoCall)
        self.dismissWithHudmsgAndAudio(strMsg: dismissMessage!)
    }
    
    func acceptDone() {}
    func closeDone(strMsg:String) {}
    
    func showMessageWithHud(message:String, completion: (() -> Void)? = nil) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.text
        hud.label.text = message
        hud.label.textColor = UIColor.black
        hud.margin = 6
        hud.bezelView.layer.cornerRadius = 4
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 2.0)
        DispatchQueue.main.asyncAfter(deadline: .now()+2.2, execute: {
            if completion != nil {
                completion!()
            }
        })
    }
    
    //MARK:播放音效
    func playAudio(audioName:String) {
        try! AVAudioSession.sharedInstance().setCategory(audioName == "voip_ringback" ? .playAndRecord : .playback)
        
        let audio = Bundle.main.path(forResource: audioName, ofType: ".caf")
        let audioURL = NSURL.fileURL(withPath: audio!)
        self.player = try! AVAudioPlayer.init(contentsOf: audioURL)
        //self.player?.volume = 1
        
        if audioName == "calling" || audioName == "voip_ringback" {
            self.player?.numberOfLoops = -1
        }
        
        self.player?.prepareToPlay()
        self.player?.play()
    }
    
    func startTime() {
        weak var weakSelf = self
        let queue = DispatchQueue.global()
        self.timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.init(rawValue: 0), queue: queue)
        self.timer!.schedule(deadline: DispatchTime.now(), repeating: 1.0, leeway: DispatchTimeInterval.microseconds(10))
        self.timer!.setEventHandler {
            if weakSelf != nil {
                weakSelf!.seconds += 1
            }
            
            DispatchQueue.main.sync {
                if weakSelf != nil {
                    
                    if (weakSelf?.seconds ?? 0) % 10 == 0 || weakSelf?.seconds == 1 {
                        weakSelf?.sendHeartBeatsIQ()
                    }
                    
                    let strTime = weakSelf!.timeFromSeconds(seconds: weakSelf!.seconds)
                    weakSelf?.showTimeValue(strTime: strTime)
                    
                    let signalStrength = CODWebRTCManager.shared().getSignalStrength()
                    weakSelf?.showSignalStrength(signal: signalStrength)
                }
            }
        }
        self.timer!.resume()
    }
    
    func showTimeValue(strTime:String) {}
    
    func showSignalStrength(signal:Int32) {}
    
    //MARK: 通话页面启动-开始60s计时，如果60s后没有任何动作，将会调用超时IQ
    func startTimeOut() {
        weak var weakSelf = self
        let queue = DispatchQueue.global()
        self.timeoutTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.init(rawValue: 0), queue: queue)
        self.timeoutTimer!.schedule(deadline: DispatchTime.now(), repeating: 1.0, leeway: DispatchTimeInterval.microseconds(10))
        self.timeoutTimer!.setEventHandler {
            if (weakSelf?.timeOutSeconds ?? 0) % 2 == 0 && self.model?.fromJID != UserManager.sharedInstance.jid {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            
            if weakSelf != nil {
                weakSelf?.timeOutSeconds += 1
            }
            
            if weakSelf?.timeOutSeconds == 40 && self.state == .unconnected && self.status == .caller {
                DispatchQueue.main.sync {
                    weakSelf?.showMessageWithHud(message: "对方设备可能不在身边，建议稍后尝试")
                }
            }
            
            if weakSelf?.timeOutSeconds == 60 {
                DispatchQueue.main.sync {
                    if weakSelf != nil {
                        weakSelf?.timeoutTimer?.cancel()
                        
//                        if CODWebRTCManager.whetherConnectedNetwork() {
                            weakSelf?.sendIQ(iqName: COD_calltimeout)
//                        } else {
//                            weakSelf?.sendIQ(iqName: COD_connectfailed)
//                            weakSelf?.dismissWithHudmsgAndAudio(strMsg: "网络异常，连接中断")
//                        }
                    }
                }
            }
        }
        self.timeoutTimer!.resume()
    }
    
    func timeFromSeconds(seconds:Int) -> String {
        if seconds > 3600 {
            let hour = String(format: "%02ld", seconds/3600)
            let minute = String(format: "%02ld", (seconds%3600)/60)
            let seconds = String(format: "%02ld", seconds%60)
            return "\(hour):\(minute):\(seconds)"
        } else {
            let minute = String(format: "%02ld", seconds/60)
            let seconds = String(format: "%02ld", seconds%60)
            return "\(minute):\(seconds)"
        }
    }
    
    func closeWindow() {}
    
    deinit {
        CODWebRTCManager.shared().exitRoom()
        self.player?.stop()
        self.player = nil
        print("视频页面被销毁")
    }
    
    @objc func dismissVC(completion: (() -> Void)? = nil) {
        self.closeWindow()
        self.player?.stop()
        
        if self.timeoutTimer != nil {
            self.timeoutTimer?.cancel()
            self.timeoutTimer = nil
        }
        
        if self.timer != nil {
            self.timer?.cancel()
            self.timer = nil
        }
        
        CODWebRTCManager.shared().exitRoom();
        NotificationCenter.default.removeObserver(self)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        CODWebRTCManager.shared().iceConnectionStateBlock = {(socketId, state)->() in}
        
        UIDevice.current.isProximityMonitoringEnabled = false
        
        UserDefaults.standard.set(false, forKey: kIsVideoCall)
        CustomUtil.removeRoomJid()
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func dismissWithAudio() {
        self.playAudio(audioName: "voip_end")
        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: .now()+2.2, execute: {
            weakSelf?.dismissVC()
        })
    }
    
    @objc func dismissWithHudmsgAndAudio(strMsg:String) {
        self.playAudio(audioName: "voip_end")
        
        self.showMessageWithHud(message: strMsg) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.dismissVC()
        }
    }
    
    @objc func dismissByICEDisconnected() {
        self.sendIQ(iqName: COD_close)
        self.dismissWithHudmsgAndAudio(strMsg: "连接中断，通话结束")
    }
    
    /// 是否移除成员
    /// - Parameter model: 消息model
    /// - Returns: true false
    func canDeleteMember(model:CODMessageModel) -> Bool{
        // (是群聊，并且成员列表大于2，并且IQ的发起者不是我自己) 或者 (IQ发起者不在成员列表里面，因为多端登录的账号有可能发多次timeout busy connectfailure)
        return (isGroupCall && self.memberList.count > 2 && model.videoCallModel?.requester != UserManager.sharedInstance.jid) || !self.memberList.contains(model.videoCallModel?.requester ?? "")
        
    }
    
    func deleteMember(jid:String?) {
        
        if let index = memberList.firstIndex(of: jid ?? "") {
        
            memberList.remove(at: index)
        }
        
        if let index = joinMemberList.firstIndex(of: jid ?? "") {
            
            joinMemberList.remove(at: index)
        }
        
        CODWebRTCManager.shared().closePeerConnection(jid ?? "")
    }
}

extension CODCallBaseVC:XMPPStreamDelegate {
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            
            if (actionDict["name"] as? String == COD_accept) {
                
                if let success = infoDict["success"] as? Bool, let code = infoDict["code"] as? Int{
                    if !success {
                        
                        switch code {
                        case 30060:
                            CODAlertView_show(NSLocalizedString("加入人数已达上限", comment: ""))
                        default:
                            break
                        }
                        return
                    }
                }
            }
            
            if (actionDict["name"] as? String == COD_accept){
                if (infoDict["success"] as! Bool) {
                    print("点击了同意")
                } else {
                    self.dismissVC()
                }
            } else if (actionDict["name"] as? String == COD_cancel){
                if (infoDict["success"] as! Bool) {
                    print("点击了取消")
                } else {
                    self.dismissVC()
                }
            } else if (actionDict["name"] as? String == COD_reject){
                if (infoDict["success"] as! Bool) {
                    print("点击了拒绝")
                } else {
                    self.dismissVC()
                }
            } else if (actionDict["name"] as? String == COD_close){
                if (infoDict["success"] as! Bool) {
                    print("点击了挂断or取消")
                } else {
                    self.dismissVC()
                }
            } else if (actionDict["name"] as? String == COD_calltimeout){
                if (infoDict["success"] as! Bool) {
                    print("超时自动挂断")
                } else {
                    self.dismissVC()
                }
            } else if (actionDict["name"] as? String == COD_busy){
                if (infoDict["success"] as! Bool) {
                    print("忙线")
                } else {
                    self.dismissVC()
                }
            } else if (actionDict["name"] as? String == COD_connectfailed){
                if (infoDict["success"] as! Bool) {
                    print("连接失败")
                } else {
                    self.dismissVC()
                }
            } else if (actionDict["name"] as? String == COD_offer){
                if (infoDict["success"] as! Bool) {
                    print("接收到offer")
                } else {
                    self.dismissVC()
                }
            } else if (actionDict["name"] as? String == COD_answer){
                if (infoDict["success"] as! Bool) {
                    print("接收到answer")
                } else {
                    self.dismissVC()
                }
            } else if (actionDict["name"] as? String == COD_ice){
                if (infoDict["success"] as! Bool) {
                    print("接收到ice")
                } else {
                    self.dismissVC()
                }
            }
        }
        return true
    }
}
