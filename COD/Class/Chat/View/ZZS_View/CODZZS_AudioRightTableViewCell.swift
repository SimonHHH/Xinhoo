//
//  CODZZS_AudioRightTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/6/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODZZS_AudioRightTableViewCell: CODBaseChatCell {

    @IBOutlet weak var sendTimeLab: UIButton!
    @IBOutlet weak var bubblesImageView: UIImageView!
    @IBOutlet weak var progressView: AudioHistogramView!
    @IBOutlet weak var slidingView: CODZZS_SlidingView!
    @IBOutlet weak var secondsLab: UILabel!
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var statuImgaeView: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var playButton: CODAudioPlayButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var sendFailBtn_zzs: UIButton!
    @IBOutlet weak var burnImageView: UIImageView!
    
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var widthCos: NSLayoutConstraint!
    @IBOutlet weak var rpTapView: UIView!
    @IBOutlet weak var contentTopCos: NSLayoutConstraint!
    @IBOutlet weak var backViewBottomCos: NSLayoutConstraint!
    
    @IBOutlet weak var lblDesc: YYLabel!
    @IBOutlet weak var lblDescHeightCos: NSLayoutConstraint!
    @IBOutlet weak var playButtonBottomCos: NSLayoutConstraint!
    @IBOutlet weak var backViewTrailingCos: NSLayoutConstraint!
    @IBOutlet weak var viewerImageView: UIImageView!
    
    var viewModel: Xinhoo_AudioViewModel? = nil

    typealias SendMsgBlock = (_ model:CODMessageModel) -> Void
    var sendMsgBlock:SendMsgBlock?
    var longDelTapBlock:SendMsgBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let reSendTap = UITapGestureRecognizer()
        reSendTap.addTarget(self, action: #selector(sendMsgRetainAction))
        self.sendFailBtn_zzs.addGestureRecognizer(reSendTap)
        
        let playTap = UITapGestureRecognizer()
        playTap.addTarget(self, action: #selector(onClickPlay))
        self.playButton.addGestureRecognizer(playTap)
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(playAudio))
//        self.backView.addGestureRecognizer(tap)
        
        let longDelTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longDelTapAction(gesture:)))
        self.backView.addGestureRecognizer(longDelTap)
        
        let rpTap = UITapGestureRecognizer.init(target: self, action: #selector(tapRpView))
        rpContentView.addGestureRecognizer(rpTap)
        
        self.rpTapView.addSubview(self.rpContentView)
        self.rpContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.rpTapView.addSubview(self.fwContentView)
        self.fwContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addOperation()
    }

    @objc func onClickPlay() {
        onClickAudioPlayButton(self.playButton, self.messageModel)
    }
    
    
    
    @objc func longDelTapAction(gesture:UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            self.pageVM?.cellLongPressMessage(cellVM: self.viewModel, self, self.backView)
        }
    }


    override func configModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?) {
        super.configModel(lastModel: lastModel, model: model, nextModel: nextModel)
        self.messageModel = model
        self.nextModel = nextModel
        
//        self.viewModel = Xinhoo_AudioViewModel(last: lastModel, model: model, next: nextModel)
        
        self.rpContentView.isHidden = !(self.messageModel.rp.count > 0 && self.messageModel.rp != "0")
        if (self.messageModel.rp.count > 0 && self.messageModel.rp != "0") {
            self.rpContentView.configModel(model: self.messageModel, indexPath: self.indexPath, pageVM: self.pageVM)
        }
        
        self.fwContentView.isHidden = !(CustomUtil.getIsShowFwView(messageModel: self.messageModel))
        if (CustomUtil.getIsShowFwView(messageModel: self.messageModel)) {
            self.fwContentView.configModel(model: self.messageModel)
        }
        
        self.backViewBottomCos.constant = (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .mid) ? 1 : 6
        
        self.bubblesAction()
        
        if self.isFirst {
            self.sendTimeLab.isHidden = false
            self.topCos.constant = 40
        }else{
            self.sendTimeLab.isHidden = true

            self.topCos.constant = 0
        }
        
//        self.timeLab.text = TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double((self.messageModel.datetime.int == nil ? "\(Date.milliseconds)":self.messageModel.datetime)))!/1000), format: "H:mm")
        self.timeLab.text = self.viewModel?.sendTime
//        self.sendTimeLab.setTitle(TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double(self.messageModel.datetime))!/1000), format: NSLocalizedString("MM 月 dd 日", comment: "")), for: .normal)
        
        self.sendTimeLab.setTitle(self.viewModel?.dateTime, for: .normal)
        
        let seconds = messageModel.audioModel?.audioDuration ?? 0
        self.secondsLab.text = String(format: "%ld\"", Int(seconds))
        
        let intSeconds = Int(seconds)

        //起始显示27条柱形，每2s新增一根柱形
        self.widthCos.constant = CGFloat(80 + (intSeconds / 2) * 3)
        
        self.progressView.configShape(shapeColor: UIColor.init(hexString: "A2D78F")!, backColor: UIColor.init(hexString: "68C050")!)
        self.progressView.initLayers(maxWidth: self.widthCos.constant,message: self.messageModel)
        
        self.slidingView.configImageView(image: UIImage.init(named: "audio_play_progress_green")!)
        self.slidingView.moveblock = { [weak self](progress) in
            
            var p = progress
            if progress < 0 {
                p = 0
            }
            
            if progress > 1 {
                p = 1
            }
            
            self?.progressView.stopAnimationPersentage()
            self?.slidingView.stopAnimationImgView()
            self?.progressView.persentage = p
            self?.playButton.payButtonState = .pause
            
            self?.slidingView.imgView.frame = CGRect.init(x: (self?.slidingView.width)! * p, y: 0, width: 1, height: 56.5)
            
        }
        
        self.slidingView.cancelBlock = { [weak self] (progress) in
            
            var p = progress
            if progress < 0 {
                p = 0
            }
            
            if progress > 1 {
                p = 1
            }
            
            CODAudioPlayerManager.sharedInstance.play()
            self?.playButton.payButtonState = .play
            self?.progressView.setAnimationPersentage(persentage: 1, duration:Double((self?.messageModel.audioModel!.audioDuration.cgFloat)!*((1-p)/1)) )
            self?.slidingView.setAnimationImgView(duration: Double((self?.messageModel.audioModel!.audioDuration.cgFloat)!*((1-p)/1)),totalDuration: (self?.messageModel.audioModel!.audioDuration.cgFloat)!)
            
            CODAudioPlayerManager.sharedInstance.player?.currentTime = TimeInterval((self?.messageModel.audioModel?.audioDuration.cgFloat)! * p)
        }
        
        self.slidingView.clickBlock = { [weak self] (progress) in
            
            if CODAudioPlayerManager.sharedInstance.isPlaying() {
                CODAudioPlayerManager.sharedInstance.pause()
                self?.progressView.stopAnimationPersentage()
                self?.slidingView.stopAnimationImgView()
                self?.progressView.persentage = CGFloat(CODAudioPlayerManager.sharedInstance.player!.currentTime/Double((self?.messageModel.audioModel!.audioDuration)!))
                self?.playButton.payButtonState = .pause
            } else {
                CODAudioPlayerManager.sharedInstance.play()
                self?.playButton.payButtonState = .play
                self?.progressView.setAnimationPersentage(persentage: 1, duration:Double((self?.messageModel.audioModel!.audioDuration.cgFloat)! - CGFloat(CODAudioPlayerManager.sharedInstance.player!.currentTime.cgFloat) ))
                
                self?.slidingView.setAnimationImgView(duration: Double((self?.messageModel.audioModel!.audioDuration.cgFloat)! - CGFloat(CODAudioPlayerManager.sharedInstance.player!.currentTime.cgFloat) ), totalDuration: (self?.messageModel.audioModel?.audioDuration.cgFloat)!)

            }
        }
        
        if CODAudioPlayerManager.sharedInstance.player != nil && CODAudioPlayerManager.sharedInstance.isAudioPlaying {

            if CODAudioPlayerManager.sharedInstance.playModel?.msgID == self.messageModel.msgID {
                self.messageModel.isPlay = true
            }else{
                self.messageModel.isPlay = false
            }
            
        }else{
            self.messageModel.isPlay = false
        }
        
        if self.isNoFile {
            self.playButton.payButtonState = .noFile
            self.downloadAudio(self.playButton, self.messageModel)
        } else {
            if self.messageModel.isPlay {
                
                self.progressView.persentage = CGFloat((CODAudioPlayerManager.sharedInstance.player?.currentTime)!/Double((self.messageModel.audioModel!.audioDuration)))
                
                let duration = Double((self.messageModel.audioModel!.audioDuration.cgFloat)*((1-self.progressView.persentage)/1))
                self.progressView.setAnimationPersentage(persentage: 1, duration: CFTimeInterval(duration))
                self.slidingView.setAnimationImgViewMaxWidth(duration: CFTimeInterval(duration), totalDuration: (self.messageModel.audioModel!.audioDuration.cgFloat), maxWidth: self.widthCos.constant)
                
                self.playButton.payButtonState = .play
                
                self.slidingView.isHidden = false
                
            }else{
                self.slidingView.isHidden = true
                self.progressView.stopAnimationPersentage()
                self.slidingView.stopAnimationImgView()
                self.playButton.payButtonState = .pause
            }
        }
        
        autoDownloadAudio(self.playButton, self.messageModel)
        
        initPlayButtonState(self.playButton)
        
        
        let messageStatus: CODMessageStatus =  CODMessageStatus(rawValue: messageModel.status) ?? .Succeed
        
        if messageStatus == .Succeed && self.messageModel.isReaded {
            statuImgaeView.image = UIImage.init(named: "readInfo_blue_Haveread")
        }else if messageStatus == .Succeed && !self.messageModel.isReaded{
            statuImgaeView.image = UIImage.init(named: "readInfo_blue")
        }else{
            statuImgaeView.image = UIImage.init(named: "")
        }
        
        self.messageStatus()
        self.burnImageView.isHidden = self.viewModel?.isBurn ?? true
        
        //只要存在转发ID，或者回复ID，约束就需要做调整
        self.contentTopCos.constant = ((self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))) ? 56 : 15
        self.checkIsShowDesc()
    }
    
    private func checkIsShowDesc() {
        let strDesc = self.messageModel.audioModel?.descriptionAudio ?? ""
//        let strDesc = "封疆大吏就感觉管理费科技感科技高科技防控大姐夫肯德基开关机进口国佳都科技反馈"
        let isShowTextView = strDesc.removeAllSapce.count > 0
        
        if isShowTextView {
            let textViewIsSame = self.setContentText(textString: strDesc, maxWidth: self.widthCos.constant + 37 + 7)
            self.lblDesc.isHidden = false
            self.lblDescHeightCos.constant = textViewIsSame.labelSize.height
            self.playButtonBottomCos.constant = 10 + textViewIsSame.labelSize.height + (textViewIsSame.isSame ? -15 : 0)
        } else {
            self.lblDesc.isHidden = true
            self.lblDescHeightCos.constant = 0
            self.playButtonBottomCos.constant = -3
        }
    }
    
    private func setContentText(textString: String, maxWidth: CGFloat) -> (isSame: Bool,labelSize: CGSize) {
        self.lblDesc.attributedText = NSMutableAttributedString.init(string: textString)
        self.lblDesc.preferredMaxLayoutWidth = maxWidth
        self.lblDesc.font = UIFont.init(name: "PingFangSC-Regular", size: CGFloat(17+(UserDefaults.standard.integer(forKey: kFontSize_Change))))
        self.lblDesc.numberOfLines = 0
        self.lblDesc.textColor = UIColor.black
        self.lblDesc.lineBreakMode = .byCharWrapping
        
        let yyLabel = YYLabel.init()
        yyLabel.attributedText = self.lblDesc.attributedText
        yyLabel.preferredMaxLayoutWidth = self.lblDesc.preferredMaxLayoutWidth
        yyLabel.font = self.lblDesc.font
        yyLabel.numberOfLines = self.lblDesc.numberOfLines
        yyLabel.lineBreakMode = self.lblDesc.lineBreakMode
        
        let attText = self.getAttributeText()
        
        self.lblDesc.font = UIFont.init(name: "PingFangSC-Regular", size: CGFloat(17+(UserDefaults.standard.integer(forKey: kFontSize_Change))))
        

        yyLabel.attributedText = self.lblDesc.attributedText
        yyLabel.font = self.lblDesc.font
        
        self.lblDesc.attributedText = attText
        
        var contentSize = yyLabel.sizeThatFits(CGSize.init(width:maxWidth, height: CGFloat(MAXFLOAT)))
        
        if contentSize.width >= maxWidth {
            contentSize.width = maxWidth
        }
        //let timeWidth:CGFloat = CustomUtil.is12Hour() ? 65 : 45
        
        let timeWidth:CGFloat = (self.messageModel.edited == 0) ? (XinhooTool.is12Hour ? 90 : 70) : (XinhooTool.is12Hour ? 125 : 105)
        if contentSize.width + timeWidth <= maxWidth {
            return (isSame: true, labelSize: contentSize)
        } else {
            let seeker = CharacterLocationSeeker.init()
            let rect = seeker.lastCharacterRect(for: self.lblDesc.attributedText, drawing: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: contentSize))
            
            if rect.maxX + timeWidth > maxWidth {
                return (isSame: false, labelSize: contentSize)
            } else {
                return (isSame: true, labelSize: contentSize)
            }
        }
    }
    
    func reset() {
        
        CODAudioPlayerManager.sharedInstance.stop()
        self.slidingView.isHidden = true
        self.progressView.stopAnimationPersentage()
        self.slidingView.stopAnimationImgView()
        self.progressView.persentage = 1
        self.slidingView.imgView.frame = CGRect.init(x: 0, y: 0, width: 1, height: 56.5)
        self.playButton.payButtonState = .pause
        try! Realm.init().write {
            
            self.messageModel.isPlay = false
        }
    }
    
    @objc func playAudio() {

        if CODAudioPlayerManager.sharedInstance.playCell != nil && CODAudioPlayerManager.sharedInstance.playCell != self {
            let cell = CODAudioPlayerManager.sharedInstance.playCell
            if (cell?.isKind(of: CODZZS_AudioRightTableViewCell.classForCoder()))! {
                let cell = CODAudioPlayerManager.sharedInstance.playCell as! CODZZS_AudioRightTableViewCell
                try! Realm.init().write {
                    CODAudioPlayerManager.sharedInstance.playModel!.isPlay = false
                }
                cell.reset()
            }else{
                let cell = CODAudioPlayerManager.sharedInstance.playCell as! CODZZS_AudioLeftTableViewCell
                try! Realm.init().write {
                    CODAudioPlayerManager.sharedInstance.playModel!.isPlay = false
                }
                cell.reset()
            }
        }else{
            
            if CODAudioPlayerManager.sharedInstance.playCell != self {
            
                CODAudioPlayerManager.sharedInstance.player = nil
            }
            
            
        }
        
        if CODAudioPlayerManager.sharedInstance.playModel != nil {
            try! Realm.init().write {
                CODAudioPlayerManager.sharedInstance.playModel!.isPlay = false
            }
        }
        

        var jid = ""
        var audioID = ""
        
        audioID = (self.messageModel.audioModel!.audioURL)
        if let localURL = self.messageModel.audioModel?.audioLocalURL, localURL.count > 0 {
            audioID = localURL
        }
        
        if self.messageModel.isGroupChat {
            jid = self.messageModel.toWho.count > 0 ? self.messageModel.toWho : self.messageModel.toJID
            if (self.messageModel.fromJID.contains(UserManager.sharedInstance.loginName!)) || self.messageModel.fromJID == "" {
                if (self.messageModel.audioModel?.audioLocalURL.count)! > 0 && audioID.count == 0{
                    audioID = ((self.messageModel.audioModel?.audioLocalURL.components(separatedBy: "/").last)?.components(separatedBy: ".").first)!
                }
            }
        }else{
            if (self.messageModel.fromJID.contains(UserManager.sharedInstance.loginName!)) || self.messageModel.fromJID == "" {
                jid = self.messageModel.toWho.count > 0 ? self.messageModel.toWho : self.messageModel.toJID
                if (self.messageModel.audioModel?.audioLocalURL.count)! > 0 && audioID.count == 0{
                    audioID = ((self.messageModel.audioModel?.audioLocalURL.components(separatedBy: "/").last)?.components(separatedBy: ".").first)!
                }
                
            }else{
                jid = self.messageModel.fromJID
            }
        }
        self.slidingView.isHidden = false
        
        if CODAudioPlayerManager.sharedInstance.isPlaying() {
         
            self.progressView.persentage = CGFloat((CODAudioPlayerManager.sharedInstance.player?.currentTime)!/Double((self.messageModel.audioModel!.audioDuration)))
            self.progressView.stopAnimationPersentage()
            self.slidingView.stopAnimationImgView()
            self.playButton.payButtonState = .pause
            
        }else{
            
            if self.progressView.persentage == 1 {
                self.progressView.persentage = 0
            }
            
            let duration = Double((self.messageModel.audioModel!.audioDuration.cgFloat)*((1-self.progressView.persentage)/1))
            
            self.progressView.setAnimationPersentage(persentage: 1, duration: duration)
            self.slidingView.setAnimationImgView(duration: duration, totalDuration: (self.messageModel.audioModel!.audioDuration.cgFloat))
            
            self.playButton.payButtonState = .play
        }
        
        CODAudioPlayerManager.sharedInstance.playCell = self
        CODAudioPlayerManager.sharedInstance.playModel = self.messageModel
        
        try! Realm.init().write {
            self.messageModel.isPlay = true
        }
        if audioID.contains("imgtype="){
            audioID = self.messageModel.text
        }
        if jid.contains(UserManager.sharedInstance.jid) {
            jid = messageModel.toJID
        }
        CODAudioPlayerManager.sharedInstance.playAudio(jid: jid, audioID: audioID) {[weak self] in
            guard let `self` = self else{
                return
            }
            self.reset()
            try! Realm.init().write {
                CODAudioPlayerManager.sharedInstance.playModel!.isPlay = false
            }
        }
        
    }
    
    @IBAction func sendAgainAction(_ sender: Any) {
        if self.sendMsgBlock != nil {
            self.sendMsgBlock!(self.messageModel)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //强提醒方式，自己去决定怎么提醒
    override func flashingCell() {
        
        self.bubblesImageView.image = self.viewModel?.telegram_right_FlashingBubblesImage
        self.perform(#selector(bubblesAction), with: nil, afterDelay: 1.0)
        
    }
    
    @objc override func bubblesAction() {
        self.bubblesImageView.image = self.viewModel?.telegram_rightBubblesImage
    }
    
}


class CODZZS_SlidingView : UIView {
    
    var isMove = false
    var imgView = UIImageView.init()

    typealias SlidingBlock = (_ progress:CGFloat) -> Void
    var moveblock:SlidingBlock?
    var cancelBlock:SlidingBlock?
    var clickBlock:SlidingBlock?
    
    let lineY: CGFloat = -10
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.imgView.frame = CGRect.init(x: 0, y: lineY, width: 1, height: 53)
        self.addSubview(self.imgView)
    }

    func configImageView(image:UIImage) {
        self.imgView.image = image
    }
    
    
    
    func setAnimationImgView(duration:CFTimeInterval,totalDuration:CGFloat) {
        
        self.stopAnimationImgView()
        
        self.imgView.frame = CGRect.init(x: 0, y: lineY, width: 1, height: 53)
        
        var scale = CGFloat(totalDuration - CGFloat(duration)) / CGFloat(totalDuration)
        
        if scale == 1 {
            scale = 0
        }
        
        let pop = POPBasicAnimation.init(propertyNamed: kPOPViewFrame)
        pop?.fromValue = NSValue.init(cgRect: CGRect.init(x: self.frame.width * CGFloat(scale), y: self.imgView.frame.minY, width: self.imgView.frame.width, height: self.imgView.frame.height))
        pop?.toValue = NSValue.init(cgRect: CGRect.init(x: self.frame.width, y: lineY, width: self.imgView.frame.width, height: self.imgView.frame.height))
        pop?.duration = duration
        pop?.timingFunction = CAMediaTimingFunction.init(name: .linear)
        self.imgView.pop_add(pop, forKey: "imgPOP")
    }
    
    func setAnimationImgViewMaxWidth(duration:CFTimeInterval,totalDuration:CGFloat,maxWidth:CGFloat) {
        
        self.stopAnimationImgView()
        
        var scale = CGFloat(totalDuration - CGFloat(duration)) / CGFloat(totalDuration)
        
        if scale == 1 {
            scale = 0
        }
        
        let pop = POPBasicAnimation.init(propertyNamed: kPOPViewFrame)
        pop?.fromValue = NSValue.init(cgRect: CGRect.init(x: maxWidth * CGFloat(scale), y: self.imgView.frame.minY, width: self.imgView.frame.width, height: self.imgView.frame.height))
        pop?.toValue = NSValue.init(cgRect: CGRect.init(x: maxWidth, y: lineY, width: self.imgView.frame.width, height: self.imgView.frame.height))
        pop?.duration = duration
        pop?.timingFunction = CAMediaTimingFunction.init(name: .linear)
        self.imgView.pop_add(pop, forKey: "imgPOP")
    }
    
    func stopAnimationImgView() {
        self.imgView.pop_removeAnimation(forKey: "imgPOP")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isMove = false
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        CODAudioPlayerManager.sharedInstance.pause()
        self.isMove = true
        if self.moveblock != nil {
            let touch = touches.first
            if let p = touch?.location(in: self) {
                self.moveblock!(p.x/self.frame.size.width)
            }
        }
        super.touchesMoved(touches, with: event)
    }

    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isMove {
            
            if self.cancelBlock != nil {
                let touch = touches.first
                if let p = touch?.location(in: self) {
                    self.cancelBlock!(p.x/self.frame.size.width)
                }
            }
            
        }else{
            
            if self.clickBlock != nil {
                
                let touch = touches.first
                if let p = touch?.location(in: self) {
                    self.clickBlock!(p.x/self.frame.size.width)
                }
            }
        }
        super.touchesCancelled(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.isMove {
            if self.cancelBlock != nil {
                let touch = touches.first
                if let p = touch?.location(in: self) {
                    self.cancelBlock!(p.x/self.frame.size.width)
                }
            }
        }else{
            
            if self.clickBlock != nil {
                let touch = touches.first
                if let p = touch?.location(in: self) {
                    self.clickBlock!(p.x/self.frame.size.width)
                }
            }
        }
        super.touchesEnded(touches, with: event)
    }

    
}
