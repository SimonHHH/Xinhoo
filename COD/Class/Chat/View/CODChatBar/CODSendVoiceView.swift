//
//  CODSendVoiceView.swift
//  COD
//
//  Created by xinhooo on 2020/8/24.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import Lottie
import RxSwift
import MZTimerLabel

class CODSendVoiceView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var circleBeginCenter: CGPoint = .zero
    var cancelButtonBeginCenter: CGPoint = .zero
    
    var offsetX: CGFloat = 0.0
    var offsetY: CGFloat = 0.0
    
    var isUnresponsiveGesture: Bool = false
    
    var isPlaying: Bool = false
    
    var isRecording = false
    
    let disposed = DisposeBag()
    
    var isCustomHidden: Bool = false {
        
        didSet{
        
            self.backgroundColor = isCustomHidden ? .clear : UIColor(hexString: kNavBarBgColorS)
            self.circleLottieView.alpha = isCustomHidden ? 0.0 : 1.0
            self.lockLottieView.alpha = isCustomHidden ? 0.0 : 1.0
            self.timeLabel.alpha = isCustomHidden ? 0.0 : 1.0
            
            self.cancelButton.alpha = isCustomHidden ? 0.0 : 1.0
            
            self.progressBackView.alpha = 0
            self.progressView.persentage = 1.0
            self.deleteButton.alpha = 0
            self.stopSendButon.alpha = 0
        }
    }
    
    
    lazy var circleLottieView: AnimationView = {
        let circleLottieView = AnimationView.init()
        let animation = Animation.filepath(Bundle.main.path(forResource: "sendVoice", ofType: "json")!, animationCache: nil)
        circleLottieView.animation = animation
        circleLottieView.loopMode = .loop
        circleLottieView.play()
        return circleLottieView
    }()
    
    lazy var lockLottieView: AnimationView = {
        let lockLottieView = AnimationView.init()
        let animation = Animation.filepath(Bundle.main.path(forResource: "lock", ofType: "json")!, animationCache: nil)
        lockLottieView.animation = animation

        // 0.48刚好是json动画开始往上移动的时刻
        lockLottieView.play(fromProgress: 0.0, toProgress: 0.48, loopMode: .loop, completion: nil)
        return lockLottieView
    }()
    
    lazy var deleteLottiView: AnimationView = {
        let deleteLottiView = AnimationView.init()
        deleteLottiView.backgroundColor = UIColor.init(hexString: kNavBarBgColorS)
        let animation = Animation.filepath(Bundle.main.path(forResource: "delete", ofType: "json")!, animationCache: nil)
        deleteLottiView.animation = animation

        // 0.30刚好是json动画结束闪烁的时刻
        deleteLottiView.play(fromProgress: 0.0, toProgress: 0.30, loopMode: .loop, completion: nil)
        return deleteLottiView
    }()
    
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel(frame: .zero)
        timeLabel.text = "00:00"
        timeLabel.font = UIFont.systemFont(ofSize: 15)
        return timeLabel
    }()
    
    lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .custom)
        
        cancelButton.setImage(UIImage(named: "left_arrow"), for: .disabled)
        cancelButton.setImage(nil, for: .normal)
        
        cancelButton.setTitle(NSLocalizedString("左滑取消录制", comment: ""), for: .disabled)
        cancelButton.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
        
        cancelButton.setTitleColor(UIColor(hexString: "868D98"), for: .disabled)
        cancelButton.setTitleColor(UIColor(hexString: "007EE5"), for: .normal)
        
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        cancelButton.isEnabled = false
        
//        cancelButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        cancelButton.addTap { [weak self] in
            
            guard let `self` = self else { return }
            self.cancel()
        }
        
        return cancelButton
    }()
    
    
    lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .custom)
        
        sendButton.setImage(UIImage(named: "mic_logo"), for: .disabled)
        sendButton.setImage(UIImage.sendVoiceIcon(), for: .normal)
        
        
        sendButton.isEnabled = false
        
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        
        return sendButton
    }()
    
    lazy var stopSendButon: UIButton = {
        let stopSendButon = UIButton(type: .custom)
        
        stopSendButon.setImage(UIImage.sendIcon(), for: .normal)
        stopSendButon.addTarget(self, action: #selector(stopSendAction), for: .touchUpInside)
        
        stopSendButon.alpha = 0
        
        return stopSendButon
    }()
    
    lazy var deleteButton: UIButton = {
        let deleteButton = UIButton(type: .custom)
        
        deleteButton.backgroundColor = UIColor(hexString: kNavBarBgColorS)
        
        deleteButton.setImage(UIImage(named: "send_voice_delete"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        deleteButton.alpha = 0
        
        return deleteButton
    }()
    
    lazy var progressView: AudioHistogramView = {
        
        let progressView = AudioHistogramView(frame: .zero)
        progressView.layer.masksToBounds = true
        return progressView
    }()
    
    lazy var progressBackView: UIView = {
        
        let progressBackView = UIView(frame: .zero)
        
        progressBackView.backgroundColor = UIColor(hexString: "007EE5")
        progressBackView.alpha = 0
        progressBackView.cornerRadius = 17
        
        return progressBackView
    }()
    
    lazy var playImageView: PlayImageView = {
       
        let playImageView = PlayImageView(image: UIImage(named: "send_voice_play"))
        return playImageView
        
    }()
    
    lazy var stopTimeLabel: MZTimerLabel = {
        
        let stopTimeLabel = MZTimerLabel(frame: .zero)
        stopTimeLabel.timeFormat = "mm:ss"
        stopTimeLabel.textColor = .white
        stopTimeLabel.font = UIFont.systemFont(ofSize: 13)
        stopTimeLabel.timerType = MZTimerLabelTypeTimer
        stopTimeLabel.delegate = self
        return stopTimeLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(circleLottieView)
        circleLottieView.snp.makeConstraints { (make) in
            
            make.size.equalTo(CGSize(width: 100, height: 100))
            make.right.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(stop))
        lockLottieView.addGestureRecognizer(tap)
        
        self.addSubview(lockLottieView)
        lockLottieView.snp.makeConstraints { (make) in
            make.bottom.equalTo(circleLottieView.snp.top).offset(-10)
            make.right.equalToSuperview().offset(-4)
        }
        
        let backView = UIView(frame: .zero)
        backView.backgroundColor = UIColor(hexString: kNavBarBgColorS)
        self.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.size.equalTo(CGSize(width: 36, height: 36))
            make.centerY.equalToSuperview()
        }
        
        backView.addSubview(deleteLottiView)
        deleteLottiView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        backView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(35)
            make.width.greaterThanOrEqualTo(50)
        }
        
        timeLabel.frame = CGRect(x: 47, y: 8, width: 60, height: 40)
        self.addSubview(timeLabel)
        
        circleLottieView.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.center.equalTo(circleLottieView)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        self.addSubview(stopSendButon)
        stopSendButon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        self.addSubview(progressBackView)
        progressBackView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(deleteButton.snp.right).offset(8)
            make.right.equalTo(stopSendButon.snp.left).offset(-8)
            make.height.equalTo(34)
        }
        
        progressBackView.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.right.equalTo(-58)
            make.height.equalTo(10)
            make.centerY.equalToSuperview()
        }
        
        progressBackView.addSubview(playImageView)
        playImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        
        progressBackView.addSubview(stopTimeLabel)
        stopTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
        }
        
        progressBackView.addTap { [weak self] in
            
            guard let `self` = self else{ return }
            
            self.isPlaying = true
            
            CustomUtil.stopAudioPlay()
            
            

            CODAudioPlayerManager.sharedInstance.playAudio(jid: XMPPManager.shareXMPPManager.currentChatFriend, audioID: "audioFileSavePath", playerSuccess: { [weak self] (player) in
                
                guard let `self` = self else{ return }
                if self.playImageView.state == .play {
                    
                    self.playImageView.state = .pause
                    self.progressView.persentage = CGFloat(player.currentTime / player.duration)
                    self.progressView.stopAnimationPersentage()
                    self.stopTimeLabel.pause()
                }else{
                    
                    self.playImageView.state = .play
                    self.progressView.persentage = CGFloat(player.currentTime  / player.duration)
                    self.progressView.setAnimationPersentage(persentage: 1, duration: player.duration - player.currentTime)
                    self.stopTimeLabel.start()
                }
                
                
            }) {
                
                self.stopPlayAudio()
            }
            
        }
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: kSendVoiceMoveTouch))
            .bind(onNext: { [weak self] (noti) in
                
                guard let `self` = self else { return }
                
                guard let point = noti.userInfo?["point"] as? CGPoint else {
                    return
                }
                
                guard let state = noti.userInfo?["state"] as? UIGestureRecognizer.State else {
                    return
                }
                
                
                if self.isUnresponsiveGesture {
                    //如果当前是不响应手势状态，则直接return掉
                    return
                }
                
                
                
                if self.circleBeginCenter == .zero {
                    self.circleBeginCenter = self.circleLottieView.center
                }

                if self.cancelButtonBeginCenter == .zero {
                    self.cancelButtonBeginCenter = self.cancelButton.center
                }
                
                
                self.offsetX = self.circleBeginCenter.x - point.x
                self.offsetY = self.circleBeginCenter.y - point.y
                
//                print("***offsetX = \(self.offsetX)")
//                print("***offsetY = \(self.offsetY)")
                
                
                if state == .ended || state == .cancelled {
    
                    
                    if self.isRecording {
                        
                        self.send()
                    }
                    return
                    
                } else if state == .began {
                    
                    self.begin()
                    return
                }
                
                
                // x的偏移量 如果小于0 或者 大于 80 则直接将偏移量改为 0
                if self.offsetX < 0 || self.offsetX > 80{
                    
                    // x 的偏移量大于80，认为已经达到取消录音的条件，直接调用cancel()方法
                    if self.offsetX > 80 {
                        if self.isRecording {
                            
                            self.cancel()
                        }
                        
                        return
                    }
                    
                    self.offsetX = 0
                    
                }
                
                // y 的偏移量 如果小于0 或者 大于 60 则直接将偏移量改为 0
                if self.offsetY < 0 || self.offsetY > 60 {
                    
                    
                    // y 的偏移量大于60，认为已经达到不用长按也能录音的条件，直接调用recording()方法
                    if self.offsetY > 60 {
                        self.recording()
                        
                        return
                    }
                    
                    self.offsetY = 0
                }
                
                self.circleLottieView.center = point
                
                if self.offsetX > 5 || self.offsetY > 5 {
                    self.cancelButton.layer.removeAllAnimations()
                    self.lockLottieView.currentProgress = self.offsetY / 2 / 100.0 + 0.5
                }
                self.cancelButton.center = CGPoint(x: self.cancelButtonBeginCenter.x - self.offsetX, y: self.cancelButtonBeginCenter.y)
                self.cancelButton.alpha = (50 - self.offsetX)/50
                
            })
            .disposed(by: self.rx.disposeBag)
        
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: kSendVoiceRecord))
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] (noti) in
                
                guard let `self` = self else { return }
                
                guard let decibel = noti.userInfo?["decibel"] as? Float else {
                    return
                }
                
                guard let recordTime = noti.userInfo?["recordTime"] as? Int else {
                    return
                }
                
                if recordTime > 60 {
                    self.cancel(isDelete: false)
                    return
                }
                
                print("*******\(decibel)")
                
                if decibel < 3 {
                    
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowUserInteraction, animations: { [weak self] in
                        
                        guard let `self` = self else{ return }
                        
                        self.circleLottieView.transform = CGAffineTransform(scaleX: (CGFloat(decibel * 33.33) + 100 - self.offsetX) / 100, y: (CGFloat(decibel * 33.33) + 100 - self.offsetX) / 100)
                        
                    }, completion: nil)
                    
                }
                
                let timetString = CustomUtil.transToHourMinSec(time:Float(recordTime))
                self.timeLabel.text = timetString
//                self.stopTimeLabel.text = timetString
                if recordTime >= 0 {
                    self.stopTimeLabel.setCountDownTime(TimeInterval(recordTime))
                }
                
                
            })
            .disposed(by: self.rx.disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: kSendVoiceStopPlay))
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] (noti) in
                
                guard let `self` = self else { return }
                
                if self.isPlaying {
                    
                    self.stopPlayAudio()
                }
                
                if self.isRecording {
                    
                    self.stop()
                }
                
            })
            .disposed(by: self.rx.disposeBag)
        
        if let ctl = UIViewController.current() {
            
            ctl.rx.deallocating.bind { [weak self] in
                guard let `self` = self else { return }
                
                self.lockLottieView.stop()
                self.lockLottieView.removeFromSuperview()
                self.circleLottieView.stop()
                self.circleLottieView.removeFromSuperview()
                self.deleteLottiView.stop()
                self.deleteLottiView.removeFromSuperview()
                
                
                self.stopTimeLabel.timeLabel.removeFromSuperview()
                self.stopTimeLabel.timeLabel = nil
                self.stopTimeLabel.removeFromSuperview()
                
            }.disposed(by: disposed)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 开始录音
    func begin() {
        
        AudioRecordInstance.startRecord()
        
        if AudioRecordInstance.recorder != nil {
            
            CustomUtil.stopAudioPlay()
            
            self.isRecording = true
            
            let x = cancelButton.layer.position.x
            
            let animation = CAKeyframeAnimation(keyPath: "position.x")

            animation.values = [x,x+5,x+10,x+5,x,x-5,x-10,x-5,x]
            animation.duration = 2.0
            animation.repeatCount = 100
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            cancelButton.layer.add(animation, forKey: animation.keyPath)
            
            self.cancelButton.isEnabled = false
            self.sendButton.isEnabled = false
            
            self.isHidden = false
            self.lockLottieView.animationSpeed = 1.0
            lockLottieView.play(fromProgress: 0.0, toProgress: 0.48, loopMode: .loop, completion: nil)
            
            self.deleteLottiView.animationSpeed = 1.0
            deleteLottiView.play(fromProgress: 0.0, toProgress: 0.30, loopMode: .loop, completion: nil)
            
        }
    }
    
    /// 取消录音
    @objc func cancel(isDelete: Bool = true) {
        
        self.isRecording = false
        
        if isDelete {
            AudioRecordInstance.cancelRrcord()
        }
        
        self.stopPlayAudio()
        
        self.offsetX = 0
        self.offsetY = 0
        
        self.sendButton.isEnabled = false
        
        self.isUnresponsiveGesture = true
        
        self.timeLabel.text = "00:00"
        
        self.lockLottieView.currentProgress = 0.0
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            
            guard let `self` = self else { return }
            
            self.circleLottieView.center = self.circleBeginCenter
            self.cancelButton.center = self.cancelButtonBeginCenter
            
            self.isCustomHidden = true
            
        }) { [weak self] (finish) in

            guard let `self` = self else { return }
            if finish {
                
                if isDelete {
                    self.deleteLottiView.animationSpeed = 3.0
                    self.deleteLottiView.play(fromProgress: 0.30, toProgress: 1.0, loopMode: .playOnce) { [weak self] (lottiFinish) in
                    
                        guard let `self` = self else{ return }
                        self.isHidden = true
                        
                        self.isCustomHidden = false
                        
                        self.isUnresponsiveGesture = false
                    }
                } else {
                    
                    self.isHidden = true
                    
                    self.isCustomHidden = false
                    
                    self.isUnresponsiveGesture = false
                }
                
            }
            
        }
        
    }
    
    /// 自动录音（不用长按）
    func recording() {
        
        self.offsetX = 0
        self.offsetY = 0
        
        self.isUnresponsiveGesture = true
        
        self.isRecording = true
        
        self.cancelButton.isEnabled = true
        self.cancelButton.alpha = 1.0
        self.sendButton.isEnabled = true
        
        self.lockLottieView.animationSpeed = 3.0
        self.lockLottieView.play(fromProgress: nil, toProgress: 1.0, loopMode: .playOnce) { [weak self] (finish) in
            
            guard let `self` = self else { return }
            
            let spring = CASpringAnimation(keyPath: "position.y")
            spring.damping = 5
            spring.stiffness = 100
            spring.mass = 1
            spring.initialVelocity = 0
            spring.fromValue = self.lockLottieView.layer.position.y + 10
            spring.toValue = self.lockLottieView.layer.position.y
            spring.duration = spring.settlingDuration
            self.lockLottieView.layer.add(spring, forKey: spring.keyPath)
        }
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            
            guard let `self` = self else { return }
            
            self.circleLottieView.center = self.circleBeginCenter
            self.cancelButton.center = self.cancelButtonBeginCenter
        }) { (finish) in
            
        }
    }
    
    /// 发送
    @objc func send() {
        AudioRecordInstance.stopRecord()
        self.cancel(isDelete: false)
    }
    
    
    
    
    /// 停止
    @objc func stop() {
    
        self.isRecording = false
        
        self.isUnresponsiveGesture = true
        
        AudioRecordInstance.cancelRrcord()
        
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            
            guard let `self` = self else { return }
            
            self.circleLottieView.alpha = 0.0
            self.lockLottieView.alpha = 0.0
            self.timeLabel.alpha = 0.0
            
            self.cancelButton.alpha = 0.0
            
            self.stopSendButon.alpha = 1
            
            self.deleteButton.alpha = 1
            
            self.progressBackView.alpha = 1
            
            self.progressView.configShape(shapeColor: UIColor.init(hexString: "66B1EF")!, backColor: UIColor.init(hexString: "FFFFFF")!)
            self.progressView.initLayers(maxWidth: self.progressView.width)
            
            
        }) { (finish) in
//            self.progressView.persentage = 0.0
//            self.progressView.setAnimationPersentage(persentage: 1, duration: 10)

        }
        
    }
    
    /// 停止后点击发送
    @objc func stopSendAction() {
        AudioRecordInstance.audioRecorderSuccess()
        self.cancel(isDelete: false)
    }
    
    /// 停止后删除
    @objc func deleteAction() {
        self.cancel()
    }
    
    
    @objc func stopPlayAudio() {
        isPlaying = false
        CODAudioPlayerManager.sharedInstance.stop()
        self.playImageView.state = .pause
        self.progressView.persentage = 1
        self.progressView.stopAnimationPersentage()
        self.stopTimeLabel.pause()
        self.stopTimeLabel.reset()
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        
        let newP = self.convert(point, to: lockLottieView)
        
        if lockLottieView.point(inside: newP, with: event) && lockLottieView.alpha > 0.5 {
            
            let canTouchRect = CGRect(x: 0, y: lockLottieView.bounds.height / 3 * 2, width: lockLottieView.bounds.width, height: lockLottieView.bounds.height / 3)
            if canTouchRect.contains(newP) {
                return lockLottieView
            }else{
                return nil
            }
        }
        
        return super.hitTest(point, with: event)
        
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) {
            return true
            
        }
        for subview in subviews {
            let subviewPoint = subview.convert(point, from: self)
            if subview.point(inside: subviewPoint, with: event) {
                
                return subview.alpha > 0.2 && !subview.isHidden && subview.isUserInteractionEnabled
                
            }
        }
        return false
    }
    
}

extension CODSendVoiceView: MZTimerLabelDelegate {
    
    func timerLabel(_ timerLabel: MZTimerLabel!, customTextToDisplayAtTime time: TimeInterval) -> String! {
        
        if time.isNaN {
            return CustomUtil.transToHourMinSec(time:Float(timerLabel.getCountDownTime()))
        }else{
            return CustomUtil.transToHourMinSec(time:Float(timerLabel.getCountDownTime() - time))
        }
        
    }
}

class PlayImageView: UIImageView {
    
    enum PlayState: String {
        case pause
        case play
    }
    
    var state: PlayState = .pause {
        didSet {
            
            if state == .pause {
            
                self.image = UIImage(named: "send_voice_play")
            }
            
            if state == .play {
                self.image = UIImage(named: "send_voice_pause")
            }
        }
    }
}
