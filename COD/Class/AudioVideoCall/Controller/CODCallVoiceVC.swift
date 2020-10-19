//
//  CODCallVoiceVC.swift
//  COD
//
//  Created by Xinhoo on 2019/8/13.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
class CODCallVoiceVC: CODCallBaseVC {
    
    var headImg:UIImage?
    
    @IBOutlet weak var viewOppsoite: UIView!
    @IBOutlet weak var imgHead: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblStateDesc: UILabel!
    
    @IBOutlet weak var viewVoice: UIView!
    
    @IBOutlet weak var imgBgHead: UIImageView!
    @IBOutlet weak var btnScale: UIButton!
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var lblNetwork: UILabel!
    
    /// 接听按钮
    @IBOutlet weak var acceptBtn: UIButton!
    /// 接收方的 接听，拒绝按钮view
    @IBOutlet weak var viewCallee: UIView!
    
    /// 发起方的 取消按钮
    @IBOutlet weak var cancelBtn: UIButton!
    
    /// 发起方的 取消按钮 view
    @IBOutlet weak var viewCaller: UIView!
    
    /// 查看参与人员按钮
    @IBOutlet weak var memberButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(sensorStateChange(noti:)), name:UIDevice.proximityStateDidChangeNotification , object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(becomeUnavailableLock), name: NSNotification.Name(rawValue: kApplicationBecomeUnavailableLock), object: nil)
        
        self.memberButton.isHidden = !isGroupCall
        
        if isGroupCall {
            
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: groupModel?.icon ?? "") { [weak self] (image) in
                
                guard let self = self else {
                    return
                }
                self.imgHead.image = image
                self.imgBgHead.image = image
                self.headImg = image
            }
            
            self.lblUserName.text = groupModel?.getGroupName()
            
        } else {
            
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: contactModel?.userpic ?? "") { [weak self] (image) in
                
                guard let self = self else {
                    return
                }
                self.imgHead.image = image
                self.imgBgHead.image = image
                self.headImg = image
            }
            
            self.lblUserName.text = contactModel?.getContactNick()
            
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    @objc func becomeUnavailableLock() {
        
        self.cancelBtnClicked(self.cancelBtn)
        
    }
    
    @objc func sensorStateChange(noti:NSNotification) {
        if UIDevice.current.proximityState {
            print("耳朵贴近了")
        } else {
            print("耳朵离开了")
        }
    }
    
    override func initUI() {
        
        CustomUtil.setRoomJid(roomID: jid)
        
        var sendName: String = ""
        if isGroupCall {
            
            if let member = groupModel?.getMember(jid: self.model?.fromJID) {
                
                sendName = member.getMemberNickName()
            }
        }
        
        self.lblNetwork.alpha = 0
        self.btnTime.alpha = 0
        self.viewVoice.alpha = 0
        switch self.status {
        case .caller:
            self.viewCallee.alpha = 0
            self.viewCaller.alpha = 1
            self.lblStateDesc.text =  isGroupCall ? NSLocalizedString("等待接听...", comment: "") : NSLocalizedString("正在等待对方接受邀请...", comment: "")
            self.playAudio(audioName: "voip_ringback")
        case .callee:
            self.viewCallee.alpha = 1
            self.viewCaller.alpha = 0
            self.lblStateDesc.text = isGroupCall ? "\(sendName) \(NSLocalizedString("邀请您加入多人语音通话", comment: ""))" : "邀请您语音通话..."
            self.playAudio(audioName: "calling")
        default:
            self.viewCallee.alpha = 0
            self.viewCaller.alpha = 0
        }
    }
    
    override func initSetup() {
        super.initSetup()
        
        CODWebRTCManager.shared().addRemoteStreamBlock = {(socketId, stream)->() in
            NSLog("socketId:%@, stream:%@", socketId, stream)
        }
        
        CODWebRTCManager.shared().createLocalStream()
    }
    
    override func connectedDone() {
        CODWebRTCManager.shared().switchAudioCategory(false, force: false)
        
        self.lblStateDesc.text = "已接通"
        
        self.timeoutTimer?.cancel()
        self.timeoutTimer = nil
        self.startTime()
        
        self.viewCaller.alpha = 0
        self.viewCallee.alpha = 0
        
        self.btnTime.alpha = 1
        self.viewVoice.alpha = 1
        
        UIDevice.current.isProximityMonitoringEnabled = true
    }
    
    override func showNetworkMsg(strMsg:String) {
        self.lblNetwork.alpha = 1
        self.lblNetwork.text = strMsg
        self.view.bringSubviewToFront(self.lblNetwork)
    }
    
    override func hideNetworkMsg() {
        self.lblNetwork.alpha = 0
        self.lblNetwork.text = ""
    }
    
    @IBAction func scaleBtnClicked(_ sender: UIButton) {
        self.statusBarHidden = self.prevStatusBarHidden
        self.statusBarStyle = self.prevStatusBarStyle
        self.setNeedsStatusBarAppearanceUpdate()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.floatVoiceWindow?.imgHead.image = self.headImg
        delegate.floatVoiceWindow?.show()
        delegate.floatVoiceWindow?.frame = CGRect.init(x: KScreenWidth - 65 - 5, y: kSafeArea_Top + kNavBarHeight + 5, width: 65, height: 65)
        
        self.navigationController?.dismiss(animated: false, completion: nil) 
        delegate.floatVoiceWindow?.floatViewTapBlock = {()->() in
            self.statusBarHidden = false
            self.statusBarStyle = .lightContent
            self.setNeedsStatusBarAppearanceUpdate()
            
            if self.state == .unconnected {
                self.btnScale.alpha = 1
            }
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.floatVoiceWindow?.hide()
            
            let nav = UINavigationController.init(rootViewController: self)
            nav.navigationBar.isHidden = true
            nav.modalPresentationStyle = .overFullScreen
            nav.modalPresentationCapturesStatusBarAppearance = true
            UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: false, completion: nil)
        }
        
    }

    
    /// 跳转多人语音，参与人列表
    /// - Parameter sender: sender
    @IBAction func pushMemberListAction(_ sender: Any) {
        
        let vc = CODCallMemberViewController(nibName: "CODCallMemberViewController", bundle: Bundle.main)
        
        self.rx.observeWeakly(Array<String>.self, "memberList")
            .subscribe(onNext: { [weak vc] (members) in
                
                guard let vc = vc else { return }
                
                if let m = members {
                    
                    vc.memberList = m
                }
                
            })
            .disposed(by: self.rx.disposeBag)
        
        self.rx.observeWeakly(Array<String>.self, "joinMemberList")
            .subscribe(onNext: { [weak vc] (members) in
                
                guard let vc = vc else { return }
                
                if let m = members {
                    
                    vc.joinMemberList = m
                }
                
            })
            .disposed(by: self.rx.disposeBag)
        
        vc.groupModel = groupModel
        
        if self.model?.videoCallModel?.videoCalltype == VideoCallType.accept {
            vc.presenterJid = self.model?.fromJID ?? ""
        }else{
            vc.presenterJid = self.model?.videoCallModel?.requester ?? ""
        }
        
        
        vc.room = self.roomID
        
        if self.status == .caller || self.state == .connected {
            vc.isCanRequest = true
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    //callee
    @IBAction func refuseBtnClicked(_ sender: UIButton) {
        
        if XMPPManager.shareXMPPManager.xmppStream.isConnected {
            
            self.isCancelOrRefuse = true
            self.sendIQ(iqName: COD_reject)
            self.dismissWithHudmsgAndAudio(strMsg: "已拒绝")
        }
    }
    
    @IBAction func acceptBtnClicked(_ sender: UIButton) {
        
        if XMPPManager.shareXMPPManager.xmppStream.isConnected {
            
            sender.isEnabled = false
            self.lblStateDesc.text = "连接中..."
            
            self.timeoutTimer?.cancel()
            self.sendIQ(iqName: COD_accept)
//            self.perform(#selector(self.connectedFailed), with: nil, afterDelay: connectedFaileTimeOut)
        }
        
    }
    
    //caller
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        self.isCancelOrRefuse = true
        self.sendIQ(iqName: COD_cancel)
        self.dismissWithHudmsgAndAudio(strMsg: "已取消")
    }

    //voice
    @IBAction func stopRecordAudioBtnClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        CODWebRTCManager.shared().closeOrOpenLocalAudio(sender.isSelected)
    }
    
    @IBAction func hangUpBtnClicked(_ sender: UIButton) {
        self.timer?.cancel()
        self.sendIQ(iqName: COD_close)
        self.lblStateDesc.text = "通话结束"
        
        self.dismissWithAudio()
    }
    
    @IBAction func handsFreeBtnClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        CODWebRTCManager.shared().switchAudioCategory(sender.isSelected, force: true)
    }
    
    override func acceptDone() {
        self.lblStateDesc.text = "连接中..."
        self.acceptBtn.isEnabled = false
    }
    
    override func closeDone(strMsg: String) {
        self.lblStateDesc.text = strMsg
        
        self.dismissWithAudio()
    }
    
    override func showTimeValue(strTime: String) {
        let strTitle = String.init(format: NSLocalizedString("%@ 语音 %@", comment: ""),kApp_Name, "\(strTime)")
        self.btnTime.setTitle(strTitle, for: .normal)
    }
    
    override func showSignalStrength(signal: Int32) {
        var signalImgName = "signal_strength_four"
        switch signal {
        case 0:
            signalImgName = "signal_strength_one"
        case 1:
            signalImgName = "signal_strength_one"
        case 2:
            signalImgName = "signal_strength_two"
        case 3:
            signalImgName = "signal_strength_three"
        case 4:
            signalImgName = "signal_strength_four"
        default:
            signalImgName = "signal_strength_four"
        }
        
        self.btnTime.setImage(UIImage.init(named: signalImgName), for: .normal)
    }
    
    
    override func closeWindow() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.floatVoiceWindow?.imgHead.image = nil
        delegate.floatVoiceWindow?.hide()
    }
}
