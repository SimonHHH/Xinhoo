//
//  CallRequestViewController.swift
//  COD
//
//  Created by xinhooo on 2019/5/10.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import JitsiMeet
import WebRTC
import SVProgressHUD
class CallRequestViewController: BaseViewController {

    enum State:Int {
        case Unknow = 0
        case offer      ///发起方
        case answer     ///接受方
    }
    
    var state:State = CallRequestViewController.State(rawValue: 2)!
    var roomID = ""
    var model:CODMessageModel?
    var contactModel:CODContactModel?
    var jid = ""
    var timer:DispatchSourceTimer?
    var timeoutTimer:DispatchSourceTimer?
    var player:AVAudioPlayer?
    
    var seconds = 0
    var timeOutSeconds = 0
    
    private var jitsiMeetView: JitsiMeetView?
    var customBuilder : JitsiMeetConferenceOptionsBuilder?
    
    
    @IBOutlet weak var silenceBtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var minimizeBtn: UIButton!
    @IBOutlet weak var backGroundImgView: UIImageView!
    @IBOutlet weak var headImgView: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var callView: UIView!
    @IBOutlet weak var stateLab: UILabel!
    @IBOutlet weak var waitLab: UILabel!
    @IBOutlet weak var cos: NSLayoutConstraint! //控制头像名称位置的约束
    @IBOutlet weak var timeLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveVideoCall), name: NSNotification.Name.init(kReceiveVideoCall), object: nil)
        
        UserDefaults.standard.set(true, forKey: kIsVideoCall)
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kAudioCallBegin), object: nil)
        CODAudioPlayerManager.sharedInstance.stop()
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.state = (self.model?.fromJID == UserManager.sharedInstance.jid) ? .offer : .answer
        
        switch state {
        case .offer:
            self.answerView.alpha = 0
            self.callView.alpha = 0
            self.timeLab.alpha = 0
            self.stateLab.text = NSLocalizedString("拨号中...", comment: "")
            self.waitLab.text = NSLocalizedString("正在等待对方接受邀请...", comment: "")
            self.cos.constant = 0
            jid = self.model!.toJID
            self.minimizeBtn.isHidden = true
            self.playAudio(audioName: "VideoCall_Offer")
            break
        case .answer:
            self.offerView.alpha = 0
            self.callView.alpha = 0
            self.timeLab.alpha = 0
            self.stateLab.text = NSLocalizedString("请求通话", comment: "")
            self.waitLab.text = " "
            self.cos.constant = 0
            jid = self.model!.fromJID
            self.minimizeBtn.isHidden = true
            self.playAudio(audioName: "VideoCall_Request")
            break
        default:
            self.offerView.alpha = 0
            self.answerView.alpha = 0
            self.callView.alpha = 0
            self.timeLab.alpha = 0
            self.stateLab.text = " "
            self.waitLab.text = " "
            self.cos.constant = 0
            break
        }
        
        if let model = CODContactRealmTool.getContactByJID(by: jid) {
            contactModel = model
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: contactModel!.userpic) { (image) in
                self.headImgView.image = image
                self.backGroundImgView.image = image
            }
        }
        self.nameLab.text = contactModel?.getContactNick()
        self.startTimeOut()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("..................")
//        try! AVAudioSession.sharedInstance().setCategory(.playback)
        
    }
    
    @objc func receiveVideoCall(noti:NSNotification) {
        
        let model = noti.object as! CODMessageModel
        let type = model.videoCallModel?.videoCalltype ?? .request
        
        switch type {
        case .accept:
            
            self.player?.stop()
            self.joinRoom()
            self.timeoutTimer?.cancel()
            break
            
        case .close:
            
            self.cleanUp()
            self.closeWindow()
            self.timer?.cancel()
            self.playAudio(audioName: "VideoCall_HangUp")
            self.dismissVC{
                SVProgressHUD.showMessage("通话结束")
            }
            break
            
        case .reject,.anyreject:
            
            self.cleanUp()
            self.playAudio(audioName: "VideoCall_HangUp")
            self.dismissVC {
                if type == .anyreject {
                    SVProgressHUD.showMessage("对方已拒绝")
                }else{
                    SVProgressHUD.showMessage("已拒绝")
                }
            }
            break
            
        case .cancle,.anycancle:
            
            self.cleanUp()
            self.closeWindow()
            self.playAudio(audioName: "VideoCall_HangUp")
            self.dismissVC{
                if type == .anycancle {
                    SVProgressHUD.showMessage("对方已取消")
                }else{
                    SVProgressHUD.showMessage("已取消")
                }
            }
            break
            
        case .timeout,.anytimeout:
            
            if self.roomID == model.videoCallModel?.room{
                self.cleanUp()
                self.timeoutTimer?.cancel()
                self.playAudio(audioName: "VideoCall_HangUp")
                self.dismissVC{
                    if type == .anytimeout {
                        SVProgressHUD.showMessage("对方无应答")
                    }else{
                        SVProgressHUD.showMessage("通话未接听")
                    }
                }
            }
            break
            
        case .anybusy:
            
            self.cleanUp()
            self.playAudio(audioName: "VideoCall_HangUp")
            self.dismissVC {
                SVProgressHUD.showMessage("对方忙线中")
            }
            
            break
        default:
            break
        }
        
    }
    
    //MARK: 窗口化
    @IBAction func minimizeAction(_ sender: Any) {
        weak var weakSelf = self
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.floatWindow?.isCannotTouch = false
        delegate.floatWindow?.floatDelegate = weakSelf
        delegate.floatWindow?.start(withTime: self.seconds, presentview: self.view, in: CGRect.init(x: 100, y: 100, width: 60, height: 80))
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
    
    //MARK: 通话状态
    //静音
    @IBAction func silenceAction(_ sender: UIButton) {
        
        self.silenceBtn.isEnabled = false
        self.speakerBtn.isEnabled = false
        self.speakerBtn.isSelected = false
        do{
            //                try RTCAudioSession.sharedInstance().session.overrideOutputAudioPort(.none)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
        }catch{
            print(error)
        }
        
        sender.isSelected = !sender.isSelected
        self.cleanUp()
        self.jitsiMeetView = JitsiMeetView()
        self.jitsiMeetView?.delegate = self
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL.init(string: "\(HttpMeetURL)")
            builder.room = self.roomID
            builder.audioOnly = true
            if sender.isSelected {
                builder.audioMuted = true
            }else{
                builder.audioMuted = false
            }
        }
        self.jitsiMeetView?.join(options)
        
    }
    //免提
    @IBAction func speakerAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            do{
//                try RTCAudioSession.sharedInstance().session.overrideOutputAudioPort(.speaker)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            }catch{
                print(error)
                sender.isSelected = !sender.isSelected
            }
            
        }else{
            
            do{
//                try RTCAudioSession.sharedInstance().session.overrideOutputAudioPort(.none)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            }catch{
                 print(error)
                sender.isSelected = !sender.isSelected
            }
        }
    }
    //挂断
    @IBAction func hangUpAction(_ sender: Any) {
        
        self.sendIQ(iqName: COD_close)
    }
    
    //MARK:接收状态
    //接听
    @IBAction func acceptAction(_ sender: Any) {

        let button = sender as! UIButton
        button.isEnabled = false
        
        self.timeoutTimer?.cancel()
        self.sendIQ(iqName: COD_accept)
    }
    
    //拒绝
    @IBAction func rejectAction(_ sender: Any) {
        
        self.sendIQ(iqName: COD_reject)
    }
    
    //MARK:取消状态
    //取消
    @IBAction func cancleAction(_ sender: Any) {
        
        
        self.sendIQ(iqName: COD_close)
    }
    
    func sendIQ(iqName:String) {
        let  dict:NSDictionary = ["name":iqName,
                                  "requester":UserManager.sharedInstance.jid,
                                  "receiver":self.jid,
                                  "room":self.roomID]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    fileprivate func cleanUp() {
        jitsiMeetView?.leave()
        jitsiMeetView = nil
    }
    
    //MARK: 进入房间
    func joinRoom() {
        self.jitsiMeetView = JitsiMeetView()
        self.jitsiMeetView?.delegate = self
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL.init(string: "\(HttpMeetURL)")
            builder.room = self.roomID
            builder.audioOnly = true
        }
        self.jitsiMeetView?.join(options)
    }
    
    //MARK:播放音效
    func playAudio(audioName:String){

        let audio = Bundle.main.path(forResource: audioName, ofType: ".mp3")
        let audioURL = NSURL.fileURL(withPath: audio!)
        self.player = try! AVAudioPlayer.init(contentsOf: audioURL)
        
        if audioName == "VideoCall_Request" || audioName == "VideoCall_Offer" {
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
                if weakSelf != nil{
                    weakSelf!.timeLab.text = weakSelf!.timeFromSeconds(seconds: weakSelf!.seconds)
                }
            }
        }
        self.timer!.resume()
        
    }
    
    //MARK: 通话页面启动-开始30s计时，如果30s后没有任何动作，将会调用超时IQ
    func startTimeOut() {
        weak var weakSelf = self
        let queue = DispatchQueue.global()
        self.timeoutTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.init(rawValue: 0), queue: queue)
        self.timeoutTimer!.schedule(deadline: DispatchTime.now(), repeating: 1.0, leeway: DispatchTimeInterval.microseconds(10))
        self.timeoutTimer!.setEventHandler {
            if weakSelf != nil {
                weakSelf!.timeOutSeconds += 1
            }
            
            if weakSelf?.timeOutSeconds == 30 {
                DispatchQueue.main.sync {
                    if weakSelf != nil {
                        weakSelf?.timeoutTimer?.cancel()
                        weakSelf?.sendIQ(iqName: COD_calltimeout)
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
        }else{
            let minute = String(format: "%02ld", seconds/60)
            let seconds = String(format: "%02ld", seconds%60)
            return "\(minute):\(seconds)"
        }
    }
    
    func timeFromChinaSeconds(seconds:Int) -> String {
        
        if seconds > 3600 {
            let hour = String(format: "%ld", seconds/3600)
            let minute = String(format: "%ld", (seconds%3600)/60)
            return "\(hour)时\(minute)分"
        }else if seconds > 60 {
            let minute = String(format: "%ld", seconds/60)
            let seconds = String(format: "%ld", seconds%60)
            return "\(minute)分\(seconds)秒"
        }else{
            let seconds = String(format: "%ld", seconds%60)
            return "\(seconds)秒"
        }
    }
    
    func closeWindow() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.floatWindow?.isCannotTouch = true
        delegate.floatWindow?.close()
    }
    
    deinit {
        
        self.player?.stop()
        self.player = nil
        print("视频页面被销毁")
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

extension CallRequestViewController:JitsiMeetViewDelegate{
    
//    func conferenceWillJoin(_ data: [AnyHashable : Any]!) {
//        print("将要加入会议")
//    }
    
    func conferenceJoined(_ data: [AnyHashable : Any]!) {
        print("已经加入会议")
        self.silenceBtn.isEnabled = true
        self.speakerBtn.isEnabled = true
        
        self.startTime()
        UIView.animate(withDuration: 0.5) {
            
            self.offerView.alpha = 0
            self.answerView.alpha = 0
            self.callView.alpha = 1
            self.timeLab.alpha = 1
            self.stateLab.text = " "
            self.waitLab.text = " "
            self.cos.constant = 20
            self.minimizeBtn.isHidden = false
        }
    }

    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        self.silenceBtn.isEnabled = false
        self.speakerBtn.isEnabled = false
//       UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }
    
    func dismissVC(completion: (() -> Void)? = nil) {
        UserDefaults.standard.set(false, forKey: kIsVideoCall)
//        self.dismiss(animated: true) {
//        }
        self.dismiss(animated: false, completion: completion)
    }
}

extension CallRequestViewController:XMPPStreamDelegate{
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            if (actionDict["name"] as? String == COD_accept){
                if (infoDict["success"] as! Bool) {
                    
                    print("点击了同意")
                }else{
                    self.dismissVC()
                }
            }
            
            if (actionDict["name"] as? String == COD_reject){
                if (infoDict["success"] as! Bool) {
                    
                    print("点击了拒绝")
                }else{
                    self.dismissVC()
                }
            }
            
            if (actionDict["name"] as? String == COD_close){
                if (infoDict["success"] as! Bool) {
                    
                    print("点击了挂断or取消")
                }else{
                    self.dismissVC()
                }
            }
            
            if (actionDict["name"] as? String == COD_calltimeout){
                if (infoDict["success"] as! Bool) {
                    
                    print("超时自动挂断")
                }else{
                    self.dismissVC()
                }
            }
            
        }
        
        return true
    }
    
}

extension CallRequestViewController:FloatingWindowTouchDelegate{
    
    func assistiveTocuhs() {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.floatWindow?.isCannotTouch = true
        let nav = UINavigationController.init(rootViewController: self)
        nav.navigationBar.isHidden = true
        UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: false, completion: nil)
        delegate.floatWindow?.close()
    }
    
}
