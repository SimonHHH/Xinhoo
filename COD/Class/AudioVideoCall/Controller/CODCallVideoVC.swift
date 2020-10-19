//
//  CODCallVideoVC.swift
//  COD
//
//  Created by Xinhoo on 2019/8/13.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import MBProgressHUD

class CODCallVideoVC: CODCallBaseVC {
    
    var headImg:UIImage?
    
    var track: RTCVideoTrack?
    var localTrack: RTCVideoTrack?

    var switchViewSingleTap:UITapGestureRecognizer?
    var hideToolSingleTap:UITapGestureRecognizer?
    
    @IBOutlet weak var viewOppsoite: UIView!
    @IBOutlet weak var imgHead: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblStateDesc: UILabel!
    
    @IBOutlet weak var viewVoice: UIView!
    @IBOutlet weak var btnVoiceStopRecordAudio: UIButton!
    
    @IBOutlet weak var imgBgHead: UIImageView!
    @IBOutlet weak var btnScale: UIButton!
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var lblNetwork: UILabel!
    
    @IBOutlet weak var viewCallee: UIView!
    
    @IBOutlet weak var viewCaller: UIView!
    
    @IBOutlet weak var viewVisualEffect: UIVisualEffectView!
    
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var viewRemoteVideo: RTCMTLVideoView!
    @IBOutlet weak var viewRemoteVideoCover: UIView!
    @IBOutlet weak var btnRemoteVideoClosed: UIButton!
    @IBOutlet weak var viewLocalVideo: RTCMTLVideoView!
    @IBOutlet weak var viewLocalVideoCover: UIView!
    @IBOutlet weak var btnLocalVideoClosed: UIButton!
    @IBOutlet weak var viewBottomTool: UIView!
  
    @IBOutlet weak var constraintStopRecordAudio: NSLayoutConstraint!
    @IBOutlet weak var constraintStopRecordVideo: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space = (KScreenWidth - 4 * 65 - 2 * 20)/3;
        constraintStopRecordAudio.constant = -space/2 - 65/2
        constraintStopRecordVideo.constant = space/2 + 65/2
        
        self.callType = COD_call_type_video
        
        if let model = CODContactRealmTool.getContactByJID(by: jid) {
            contactModel = model
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: contactModel!.userpic) { (image) in
                self.imgHead.image = image
                self.imgBgHead.image = image
                self.headImg = image
            }
        }
        self.lblUserName.text = contactModel?.getContactNick()
    }
    
    override func initSetup() {
        super.initSetup()
        
        CODWebRTCManager.shared().addRemoteStreamBlock = {(socketId, stream)->() in
            NSLog("socketId:%@, stream:%@", socketId, stream)
            
            //self.track?.remove(self.remoteView)
            //self.track = nil;
            self.viewRemoteVideo.renderFrame(nil)
            self.track = stream.videoTracks.last!
            self.track!.add(self.viewRemoteVideo)
        }
        
        CODWebRTCManager.shared().capturerSessionBlock = {(captureSession, localVideoTrack)->() in
            NSLog("captureSession:%@", captureSession)
//            self.viewLocalVideo.captureSession = captureSession
//
//            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            self.previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
//            self.previewLayer!.frame = UIScreen.main.bounds
//            self.viewLocalVideo.layer.addSublayer(self.previewLayer!)
            
            self.viewLocalVideo.renderFrame(nil)
            self.localTrack = localVideoTrack
            self.localTrack!.add(self.viewLocalVideo)
        }
        
        CODWebRTCManager.shared().didReciveMessageByDataChannelBlock = {(socketId, type)->() in
            let remoteViewRec = self.viewRemoteVideo.frame
            if type == DataChannelMessageTypeOpenVideo {
                self.viewRemoteVideo.isEnabled = true
                self.btnRemoteVideoClosed.isHidden = true
                self.viewRemoteVideoCover.isHidden = true
            } else if(type == DataChannelMessageTypeCloseVideo) {
                self.viewRemoteVideo.isEnabled = false
                self.btnRemoteVideoClosed.isHidden = false
                self.viewRemoteVideoCover.isHidden = false
                self.viewRemoteVideo.bringSubviewToFront(self.viewRemoteVideoCover)
                self.viewRemoteVideo.bringSubviewToFront(self.btnRemoteVideoClosed)
                
                var title = remoteViewRec.width == KScreenWidth ? "对方已关闭摄像头" : ""
                self.btnRemoteVideoClosed.setTitle(title, for: UIControl.State.normal)
                
                title = remoteViewRec.width == KScreenWidth ? "" : "您已关闭摄像头"
                self.btnLocalVideoClosed.setTitle(title, for: UIControl.State.normal)
            } else if(type == DataChannelMessageTypeSwitchVoice) {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideBottomTool), object: nil)
                
                self.viewVideo.alpha = 0
                self.viewCallee.alpha = 0
                self.viewCaller.alpha = 0
                self.lblStateDesc.alpha = 0
                self.viewVoice.alpha = 1
                self.btnScale.alpha = 1
                self.btnTime.alpha = 1
                self.showMessageWithHud(message: "对方已切换到语音模式，请使用听筒接听", completion: {})
                CODWebRTCManager.shared().switchAudioCategory(false, force: false)
            }
        }
        
        CODWebRTCManager.shared().createLocalStream()
    }
    
    override func connectedDone() {
        CODWebRTCManager.shared().switchAudioCategory(true, force: false)
        
        self.timeoutTimer?.cancel()
        self.timeoutTimer = nil
        self.startTime()
        
        self.btnTime.alpha = 1
        self.viewBottomTool.alpha = 1
        self.viewCaller.alpha = 0
        self.viewCallee.alpha = 0
        self.view.bringSubviewToFront(self.viewVideo)
        self.view.bringSubviewToFront(self.btnScale)
        self.view.bringSubviewToFront(self.btnTime)
        
        self.viewLocalVideo.snp.remakeConstraints { (make) in
            make.size.equalTo(CGSize.init(width: kLocalVideoWidth, height: kLocalVideoHeigth))
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.trailing.equalTo(self.viewVideo).inset(8)
        }
        self.viewVideo.needsUpdateConstraints()
        
        self.perform(#selector(self.hideBottomTool), with: nil, afterDelay: 5)
        
        self.showMessageWithHud(message: "已接通")
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
    
    override func initUI() {
        self.viewRemoteVideo.layer.cornerRadius = 5
        self.viewRemoteVideo.layer.masksToBounds = false
        self.viewRemoteVideo.videoContentMode = UIView.ContentMode.scaleAspectFill
        
        self.viewLocalVideo.layer.masksToBounds = true
        self.viewLocalVideo.layer.cornerRadius = 5
        self.viewLocalVideo.videoContentMode = UIView.ContentMode.scaleAspectFill
        
        self.viewLocalVideo.snp.makeConstraints { (make) in
            make.edges.equalTo(self.viewVideo)
        }
        self.viewLocalVideoCover.snp.makeConstraints { (make) in
            make.edges.equalTo(self.viewLocalVideo)
        }
        self.btnLocalVideoClosed.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.viewLocalVideo)
            make.center.equalTo(self.viewLocalVideo)
            make.height.equalTo(30)
        }
        
        self.viewRemoteVideo.snp.makeConstraints { (make) in
            make.edges.equalTo(self.viewVideo)
        }
        self.viewRemoteVideoCover.snp.makeConstraints { (make) in
            make.edges.equalTo(self.viewRemoteVideo)
        }
        self.btnRemoteVideoClosed.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.viewRemoteVideo)
            make.center.equalTo(self.viewRemoteVideo)
            make.height.equalTo(30)
        }
        
        self.lblNetwork.alpha = 0
        self.viewBottomTool.alpha = 0
        self.btnTime.alpha = 0
        self.viewVoice.alpha = 0
        switch self.status {
        case .caller:
            self.viewCallee.alpha = 0
            self.viewCaller.alpha = 1
            self.lblStateDesc.text = NSLocalizedString("正在等待对方接受邀请...", comment: "")
            jid = self.model!.toJID
            self.playAudio(audioName: "voip_ringback")
        case .callee:
            self.viewCallee.alpha = 1
            self.viewCaller.alpha = 0
            self.lblStateDesc.text = "邀请您视频通话..."
            jid = self.model!.fromJID
            self.playAudio(audioName: "calling")
        default:
            self.viewCallee.alpha = 0
            self.viewCaller.alpha = 0
        }
        
        self.switchViewSingleTap = UITapGestureRecognizer(target: self, action: #selector(switchViewSingleTapGesture(gesture:)))
        self.viewLocalVideo.addGestureRecognizer(self.switchViewSingleTap!)
        
        self.hideToolSingleTap = UITapGestureRecognizer(target: self, action: #selector(hideToolSingleTapGesture(gesture:)))
        self.viewRemoteVideo.addGestureRecognizer(self.hideToolSingleTap!)
    }
    
    @objc func hideBottomTool() {
        UIView.animate(withDuration: 0.5) {
            self.statusBarHidden = true
            self.setNeedsStatusBarAppearanceUpdate()
            self.btnScale.alpha = 0
            self.btnTime.alpha = 0
            self.viewBottomTool.alpha = 0
        }
    }
    
    @objc private func hideToolSingleTapGesture(gesture:UITapGestureRecognizer) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideBottomTool), object: nil)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.statusBarHidden = self.viewBottomTool.alpha == 0 ? false : true
            self.setNeedsStatusBarAppearanceUpdate()
            self.btnScale.alpha = self.viewBottomTool.alpha == 0 ? 1 : 0
            self.btnTime.alpha = self.viewBottomTool.alpha == 0 ? 1 : 0
            self.viewBottomTool.alpha = self.viewBottomTool.alpha == 0 ? 1 : 0
        }) { (true) in
            if self.viewBottomTool.alpha == 1 {
                self.perform(#selector(self.hideBottomTool), with: nil, afterDelay: 5)
            }
        }
    }
    
    @objc private func switchViewSingleTapGesture(gesture:UITapGestureRecognizer) {
        let remoteViewRec = self.viewRemoteVideo.frame

        self.viewLocalVideo.removeGestureRecognizers()
        self.viewRemoteVideo.removeGestureRecognizers()
        
        if remoteViewRec.width == KScreenWidth {
            self.btnRemoteVideoClosed.setTitle("", for: UIControl.State.normal)
            self.btnLocalVideoClosed.setTitle("您已关闭摄像头", for: UIControl.State.normal)
            UIView.animate(withDuration: 0.5, animations: {
                self.viewLocalVideo.snp.remakeConstraints { (make) in
                    make.top.leading.trailing.bottom.equalTo(self.viewVideo)
                }
                self.viewRemoteVideo.snp.remakeConstraints { (make) in
                    make.size.equalTo(CGSize.init(width: kLocalVideoWidth, height: kLocalVideoHeigth))
                    make.top.equalTo(self.topLayoutGuide.snp.bottom)
                    make.trailing.equalTo(self.viewVideo).inset(8)
                }
                self.viewVideo.needsUpdateConstraints()
            }) { (Bool) in
                self.viewVideo.bringSubviewToFront(self.viewRemoteVideo)
                self.viewVideo.bringSubviewToFront(self.viewBottomTool)
                
                self.viewRemoteVideo.layer.masksToBounds = true
                self.viewLocalVideo.layer.masksToBounds = false
                
                self.viewRemoteVideo.addGestureRecognizer(self.switchViewSingleTap!)
                self.viewLocalVideo.addGestureRecognizer(self.hideToolSingleTap!)
            }
        } else {
            self.btnRemoteVideoClosed.setTitle("对方已关闭摄像头", for: UIControl.State.normal)
            self.btnLocalVideoClosed.setTitle("", for: UIControl.State.normal)
            UIView.animate(withDuration: 0.5, animations: {
                self.viewRemoteVideo.snp.remakeConstraints { (make) in
                    make.top.leading.trailing.bottom.equalTo(self.viewVideo)
                }
                self.viewLocalVideo.snp.remakeConstraints { (make) in
                    make.size.equalTo(CGSize.init(width: kLocalVideoWidth, height: kLocalVideoHeigth))
                    make.top.equalTo(self.topLayoutGuide.snp.bottom)
                    make.trailing.equalTo(self.viewVideo).inset(8)
                }
                self.viewVideo.needsUpdateConstraints()
            }) { (Bool) in
                self.viewVideo.bringSubviewToFront(self.viewLocalVideo)
                self.viewVideo.bringSubviewToFront(self.viewBottomTool)
                
                self.viewRemoteVideo.layer.masksToBounds = false
                self.viewLocalVideo.layer.masksToBounds = true
                
                self.viewRemoteVideo.addGestureRecognizer(self.hideToolSingleTap!)
                self.viewLocalVideo.addGestureRecognizer(self.switchViewSingleTap!)
            }
        }
    }

    @IBAction func scaleBtnClicked(_ sender: UIButton) {
        self.statusBarHidden = self.prevStatusBarHidden
        self.statusBarStyle = self.prevStatusBarStyle
        self.setNeedsStatusBarAppearanceUpdate()
        
        if self.viewVoice.alpha == 0 {
            //weak var weakSelf = self
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.floatVideoWindow?.refreshPosition()
            delegate.floatVideoWindow?.isHidden = false
            delegate.floatVideoWindow?.frame = CGRect.init(x: KScreenWidth - kLocalVideoWidth - 5, y: kSafeArea_Top + kNavBarHeight + 5, width: kLocalVideoWidth, height: kLocalVideoHeigth)
            
            let size = delegate.floatVideoWindow?.frame
            self.view.transform = CGAffineTransform.init(scaleX: size!.width/kScreenWidth, y: size!.height/kScreenHeight)
            self.view.frame = CGRect.init(x: 0, y: 0, width: size!.width, height: size!.height)
            delegate.floatVideoWindow?.addSubview(self.view)
            delegate.floatVideoWindow?.bringSubviewToFront(delegate.floatVideoWindow!.viewCover)
            delegate.floatVideoWindow?.clipsToBounds = true
            
            self.btnScale.alpha = 0
            self.btnTime.alpha = 0
            self.viewBottomTool.alpha = 0
            
            self.navigationController?.dismiss(animated: false, completion: nil)
            delegate.floatVideoWindow?.floatViewTapBlock = {()->() in
                if self.state == .unconnected {
                    self.btnScale.alpha = 1
                    self.statusBarHidden = false
                } else {
                    self.statusBarHidden = true
                }
                self.statusBarStyle = .lightContent
                self.setNeedsStatusBarAppearanceUpdate()
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.floatVideoWindow?.isHidden = true
                
                let nav = UINavigationController.init(rootViewController: self)
                nav.navigationBar.isHidden = true
                nav.modalPresentationStyle = .overFullScreen
                nav.modalPresentationCapturesStatusBarAppearance = true
                UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: false, completion: nil)
                
                self.view.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        } else {
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
    }

    //callee
    @IBAction func refuseBtnClicked(_ sender: UIButton) {
        self.isCancelOrRefuse = true
        self.sendIQ(iqName: COD_reject)
        self.dismissWithHudmsgAndAudio(strMsg: "已拒绝")
    }
    
    @IBAction func acceptBtnClicked(_ sender: UIButton) {
        sender.isEnabled = false
        self.showMessageWithHud(message: "连接中...")
        
        self.timeoutTimer?.cancel()
        self.sendIQ(iqName: COD_accept)
        self.perform(#selector(self.connectedFailed), with: nil, afterDelay: connectedFaileTimeOut)
    }
    
    //caller
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        self.isCancelOrRefuse = true
        self.sendIQ(iqName: COD_cancel)
        self.dismissWithHudmsgAndAudio(strMsg: "已取消")
        
//        var dismissMessage = ""
//        if self.state != .connecting {
//            self.sendIQ(iqName: COD_cancel)
//            dismissMessage = "已取消"
//        } else {
//            self.sendIQ(iqName: COD_close)
//            dismissMessage = "通话结束"
//        }
//        self.dismissWithHudmsgAndAudio(strMsg: dismissMessage)
    }
    
    //video
    @IBAction func switchVoiceBtnClicked(_ sender: UIButton) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideBottomTool), object: nil)
        
        self.viewVideo.alpha = 0
        self.viewRemoteVideo.alpha = 0
        self.viewLocalVideo.alpha = 0
        self.viewCallee.alpha = 0
        self.viewCaller.alpha = 0
        self.lblStateDesc.alpha = 0
        self.viewVoice.alpha = 1
        self.btnTime.alpha = 1
        self.btnScale.alpha = 1
        self.showMessageWithHud(message: "已切换到语音模式，请使用听筒接听", completion: {})
        CODWebRTCManager.shared().switchToVoice()
    }
    
    @IBAction func stopRecordAudioBtnClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender != self.btnVoiceStopRecordAudio {
            self.btnVoiceStopRecordAudio.isSelected = sender.isSelected
        }
        
        CODWebRTCManager.shared().closeOrOpenLocalAudio(sender.isSelected)
    }
    
    @IBAction func stopRecordVideoBtnClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        self.viewLocalVideoCover.isHidden = sender.isSelected ? false : true
        self.btnLocalVideoClosed.isHidden = sender.isSelected ? false : true
        self.viewLocalVideo.bringSubviewToFront(self.viewLocalVideoCover)
        self.viewLocalVideo.bringSubviewToFront(self.btnLocalVideoClosed)
        
        let remoteViewRec = self.viewRemoteVideo.frame
        title = remoteViewRec.width == KScreenWidth ? "" : "您已关闭摄像头"
        self.btnLocalVideoClosed.setTitle(title, for: UIControl.State.normal)
        
        CODWebRTCManager.shared().closeOrOpenLocalVideo(sender.isSelected)
    }
    
    @IBAction func switchCameraBtnClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        CODWebRTCManager.shared().switchCamera()
    }
    
    @IBAction func hangUpBtnClicked(_ sender: UIButton) {
        self.sendIQ(iqName: COD_close)
        
        self.dismissWithHudmsgAndAudio(strMsg: "通话结束")
    }
    
    //voice
    @IBAction func handsFreeBtnClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        CODWebRTCManager.shared().switchAudioCategory(sender.isSelected, force: true)
    }
    
    override func acceptDone() {
        self.showMessageWithHud(message: "连接中...")
    }
    
    override func showTimeValue(strTime: String) {
        self.btnTime.setTitle(String.init(format: "%@ %@ %@",kApp_Name, "\(self.viewVoice.alpha == 1 ? NSLocalizedString("语音", comment: "") : NSLocalizedString("视频", comment: ""))", "\(strTime)"), for: .normal)
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
        delegate.floatVideoWindow?.isHidden = true
    }
}
