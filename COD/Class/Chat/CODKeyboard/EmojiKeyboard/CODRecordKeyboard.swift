//
//  CODRecordKeyboard.swift
//  COD
//
//  Created by 1 on 2019/6/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

//录音模块
private let RecordView_width:CGFloat = 80
private let RecordImage_width:CGFloat = 100
let RedImage_width:CGFloat = 180

enum CODRecordBtnStatus:Int {
    case CODRecordInit = 0 ///初始化 取消完成或者录音完成
    case CODRecordRecording ///录音中..
    case CODRecordWillCancle ///正要取消状态
}
class CODRecordKeyboard: CODBaseKeyboard {
    
    weak var delegate:CODRecordKeyboardDelegate?
    var countdownTimer: Timer?
    fileprivate var time: TimeInterval = 0.0

    var remainingSeconds: Int = 0 {
        didSet{
            timerRemainingSeconds(seconds: remainingSeconds)
        }
    }
    // 倒计时
    var isCounting = false {
        didSet{
            timeIsCounting(isBegin: isCounting)
        }
    }
    ///当前的状态
    var recordStatus:CODRecordBtnStatus = CODRecordBtnStatus.CODRecordInit{
        didSet{
            self.updateRecordBtnStatus()
        }
    }
    var recordTime: Int = 0{
        didSet{
            self.updateRecordTime(recordTime: recordTime)
        }
    }
    var isRecording = false
    lazy var timeLabel:UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.text = "00:00"
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    lazy var redView:UIView = {
        let iconImageView = UIView(frame: CGRect.zero)
        iconImageView.isUserInteractionEnabled = true
        iconImageView.backgroundColor = UIColor.clear
        iconImageView.layer.cornerRadius = RedImage_width/2
        iconImageView.clipsToBounds = true
        iconImageView.layer.borderColor = UIColor.red.cgColor
        iconImageView.layer.borderWidth = 1
        return iconImageView
    }()
    
    lazy var timeImageView:UIImageView = {
        let iconImageView = UIImageView(frame: CGRect.zero)
        iconImageView.isUserInteractionEnabled = true
        iconImageView.image = UIImage(named: "recording_cancle")
        iconImageView.contentMode = UIView.ContentMode.scaleAspectFill
       
        return iconImageView
    }()
    var isTouch = false
    lazy var talkButton:CODTalkButton = {
        let talkButton = CODTalkButton(frame: .zero)
        
//        talkButton.layer.cornerRadius = RecordView_width/2
//        talkButton.clipsToBounds = true
        return talkButton
    }()
    

    
    lazy var backgroundImageView:UIImageView = {
        let backgroundImageView = UIImageView(frame: CGRect.zero)
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.backgroundColor = UIColor.init(hexString: kSubmitBtnBgColorS)
        backgroundImageView.layer.cornerRadius = RecordImage_width/2
        backgroundImageView.clipsToBounds = true
        return backgroundImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(self.redView)
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.talkButton)
        self.addSubview(self.timeImageView)
        self.addSubview(self.timeLabel)
        
        self.redView.isHidden = true
        self.timeImageView.isHidden = true
        self.timeLabel.isHidden = true
        
        self.redView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: RedImage_width, height: RedImage_width))
        }

        self.backgroundImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: RecordImage_width, height: RecordImage_width))
        }
        self.talkButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)

            make.size.equalTo(CGSize(width: RecordView_width, height: RecordView_width))
        }
        self.timeImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.backgroundImageView)
            make.bottom.equalTo(self.backgroundImageView.snp.top).offset(-9)
            make.width.equalTo(69)
            make.height.equalTo(38)
        }
        self.timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.timeImageView)
            make.top.equalTo(self.timeImageView).offset(8)
        }
        self.talkButton.setTouchAction(touchBegin: { [weak self] in
            //防止点击太快会崩溃的问题
            
            guard let `self` = self else { return }
            
            let currentTime: TimeInterval = Date.init().timeIntervalSince1970
            if currentTime - self.time < 1 {
                return
            }
            if !self.isRecording {
                self.recordStatus = .CODRecordRecording
                self.isCounting = true
                self.isRecording  = true
                if self.delegate  != nil{
                    self.delegate?.chatBarStartRecording(keyboard: self)
                    
                }
            }
            
        }, touchMove: { [weak self] (move) in
            
            guard let `self` = self else { return }
            
            if self.isRecording {
                if(move == true){
                    self.recordStatus = .CODRecordWillCancle
                }else{
                    self.recordStatus = .CODRecordRecording
                }
                if self.delegate  != nil{
                    self.delegate?.chatBarWillCancelRecording(keyboard: self,cancle:move)
                }
            }
            
        }, touchCancel: { [weak self] in
            
            guard let `self` = self else { return }
            
            if self.isRecording {
                self.recordStatus = .CODRecordInit
                if self.delegate  != nil{
                    self.delegate?.chatBarDidCancelRecording(keyboard: self)
                    self.isCounting = false
                }
            }
            
        }, touchEnd: { [weak self] in
            
            guard let `self` = self else { return }
            
            if self.isRecording {
                self.isRecording  = false
                if self.recordStatus == .CODRecordWillCancle {
                    if self.delegate  != nil{
                        self.delegate?.chatBarDidCancelRecording(keyboard: self)
                        self.isCounting = false
                    }
                }else{
                    if self.delegate != nil{
                        self.delegate?.chatBarFinishedRecoding(keyboard: self)
                        self.isCounting = false
                    }
                }
                self.recordStatus = .CODRecordInit
            }
        })
//        let bubbleImage = timeImageView.image?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10), resizingMode: .stretch)
//        timeImageView.image = bubbleImage;
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateRecordTime( recordTime: Int) {
    
     
    }
    
    //更新状态
    func updateRecordBtnStatus(){

        ///根据状态加载gif
        if recordStatus == .CODRecordInit {
            isRecording = false
            self.backgroundImageView.image = UIImage.init(named: "")
            self.backgroundImageView.backgroundColor = UIColor.init(hexString: kSubmitBtnBgColorS)
            self.backgroundImageView.layer.cornerRadius = RecordImage_width/2
            self.backgroundImageView.clipsToBounds = true
            self.talkButton.iconImageView.isHidden = false
            self.talkButton.titleLabel.isHidden = false
            self.timeImageView.isHidden = true
            self.timeLabel.isHidden = true
            self.redView.isHidden = true
            self.countdownTimer?.invalidate()
            if let gifVeiw = self.viewWithTag(100) {
                gifVeiw.removeFromSuperview()
            }
        }else if(recordStatus == .CODRecordWillCancle){
            
            if !isRecording {
                isRecording = true
                self.talkButton.titleLabel.isHidden = true
            }
            self.timeImageView.isHidden = false
            self.timeLabel.isHidden = false
            self.timeImageView.image = UIImage(named: "recording_time")
            self.timeLabel.textColor = UIColor.red
            self.redView.isHidden = false


        }else if(recordStatus == .CODRecordRecording){

            if !isRecording {
                isRecording = true

                let gifView = RippleAnimationView.init(frame: CGRect(x: 0, y: 0, width: RecordImage_width, height: RecordImage_width))
                gifView.center = self.backgroundImageView.center
                gifView.tag = 100
                self.insertSubview(gifView, belowSubview: self.backgroundImageView)
                self.talkButton.titleLabel.isHidden = true
            }
            self.timeImageView.isHidden = false
            self.timeLabel.isHidden = false
            self.timeImageView.image = UIImage(named: "recording_cancle")
            self.timeLabel.textColor = UIColor.white
            self.redView.isHidden = true

        }
        
        let bubbleImage = timeImageView.image?.resizableImage(withCapInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), resizingMode: .stretch)
        timeImageView.image = bubbleImage;
    }
    
//    func updateRecordTime() {
//        <#function body#>
//    }
}

protocol CODRecordKeyboardDelegate:NSObjectProtocol{
    // MARK: - 录音控制
    /// 开始录音
    ///
    /// - Parameter chatBar: ChatBar
    func chatBarStartRecording(keyboard:CODRecordKeyboard)
    ///结束录音
    ///
    /// - Parameter chatBar: ChatBar
    func chatBarDidCancelRecording(keyboard:CODRecordKeyboard)
    
    /// 取消
    ///
    /// - Parameters:
    ///   - chatBar: ChatBar
    ///   - cancle: 取消
    func chatBarWillCancelRecording(keyboard:CODRecordKeyboard,cancle:Bool)
    
    /// 结束
    ///
    /// - Parameter chatBar: ChatBar
    func chatBarFinishedRecoding(keyboard:CODRecordKeyboard)
    
    
}
//高度
extension CODRecordKeyboard{
    
    override func keyboardHeight() -> CGFloat {
        return HEIGHT_CHAT_KEYBOARD
    }
}
extension CODRecordKeyboard{
    // 倒计时
    func timerRemainingSeconds(seconds:Int) -> () {
        if seconds == 60 {
            isCounting = false
            self.recordStatus = .CODRecordInit
        }
    }
    
    // 创建/销毁定时器
    func timeIsCounting(isBegin:Bool) -> () {
        if isBegin {
            
            countdownTimer?.invalidate()
            countdownTimer = nil
            
            countdownTimer = Timer.scheduledTimer(timeInterval: 1,
                                                  target: self,
                                                  selector: #selector(self.updateTime),
                                                  userInfo: nil,
                                                  repeats: true)
            remainingSeconds = 0
            
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil
            self.timeLabel.text  = "00:00"
        }
    }
    
    @objc private func updateTime() {
        remainingSeconds += 1
        let timetString = CustomUtil.transToHourMinSec(time:Float(remainingSeconds))
        print("录音时间 \(timetString)")
        self.timeLabel.text = timetString
        self.talkButton.recordStatus = self.recordStatus
    }
}
