//
//  CODZZS_AudioLeftTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/6/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODZZS_AudioLeftTableViewCell: CODBaseChatCell {

    @IBOutlet weak var sendTimeLab: UIButton!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var bubblesImageView: UIImageView!
    @IBOutlet weak var progressView: AudioHistogramView!
    @IBOutlet weak var slidingView: CODZZS_SlidingView!
    @IBOutlet weak var secondsLab: UILabel!
    @IBOutlet weak var timeView: XinhooTimeAndReadView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nickNameLab: UILabel!
    @IBOutlet weak var burnImageView: UIImageView!
    
    @IBOutlet weak var playButton: CODAudioPlayButton!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var widthCos: NSLayoutConstraint!
    @IBOutlet weak var redPointView: UIView!
    @IBOutlet weak var backViewLeadingCos: NSLayoutConstraint!
    @IBOutlet weak var rpTapView: UIView!
    @IBOutlet weak var rpTopCos: NSLayoutConstraint!
    @IBOutlet weak var contentTopCos: NSLayoutConstraint!
    @IBOutlet weak var backViewBottomCos: NSLayoutConstraint!
    
    @IBOutlet weak var lblDesc: YYLabel!
    @IBOutlet weak var lblDescHeightCos: NSLayoutConstraint!
    @IBOutlet weak var fileImageViewBottomCos: NSLayoutConstraint!
    @IBOutlet weak var adminLab: UILabel!
//    var isFirst = false
    @IBOutlet weak var fwdImageView: UIImageView!
    @IBOutlet weak var cloudDiskJumpBtn: UIButton!
    
    typealias NextPlayBlock = (_ model:CODMessageModel) -> Void
    var nextPlay:NextPlayBlock?
    var tapAvatarBlock:NextPlayBlock?
    var longTapAvatarBlock:NextPlayBlock?
    var longDelTapBlock:NextPlayBlock?
    
    var viewModel: Xinhoo_AudioViewModel? = nil
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelDownloadHeadImage()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let playTap = UITapGestureRecognizer()
        playTap.addTarget(self, action: #selector(onClickPlay))
        self.playButton.addGestureRecognizer(playTap)
        
        let headtap = UITapGestureRecognizer()
        headtap.addTarget(self, action: #selector(didTapAvatarAction))
        self.headImageView.addGestureRecognizer(headtap)
        
        let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longTapAction(gesture:)))
        self.headImageView.addGestureRecognizer(longTap)
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(playAudio))
//        self.backView.addGestureRecognizer(tap)
        
        let longDelTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longDelTapAction(gesture:)))
        self.backView.addGestureRecognizer(longDelTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioPlayEnd), name: NSNotification.Name.init(kAudioPlayEnd), object: nil)
        
        let rpTap = UITapGestureRecognizer.init(target: self, action: #selector(tapRpView))
        rpContentView.addGestureRecognizer(rpTap)
        
        self.rpTapView.addSubview(self.rpContentView)
        self.rpTapView.addSubview(self.fwContentView)
        
        self.rpContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.fwContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let fwdTap = UITapGestureRecognizer()
        fwdTap.addTarget(self, action: #selector(tapedFwfImageView))
        fwdImageView.addGestureRecognizer(fwdTap)
    }
    
    @objc func onClickPlay() {
        onClickAudioPlayButton(self.playButton, self.messageModel)
    }
    
    

    @objc func audioPlayEnd() {
        self.reset()
        try! Realm.init().write {
            CODAudioPlayerManager.sharedInstance.playModel!.isPlay = false
        }

        if self.nextPlay != nil {
            self.nextPlay!(self.messageModel)
        }
        
        if let vm = self.viewModel {
            self.pageVM?.playNextAudio(cellVm: vm)
        }
        
        
        
    }
    
    @objc func longTapAction(gesture:UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            self.pageVM?.cellDidLongTapedAvatarImage(self, model: self.messageModel)
        }
    }
    
    @objc func longDelTapAction(gesture:UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            
            self.pageVM?.cellLongPressMessage(cellVM: self.viewModel, self, self.backView)

        }
    }
    
    override func showName(showName:Bool) {
        
        self.nickNameLab.isHidden = !(showName && (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .only))
        self.rpTopCos.constant = (showName && (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .only)) ? 33 : 10
        
        self.rpContentView.isHidden = !(self.messageModel.rp.count > 0 && self.messageModel.rp != "0")
        if (self.messageModel.rp.count > 0 && self.messageModel.rp != "0") {
            self.rpContentView.configModel(model: self.messageModel, indexPath: self.indexPath, pageVM: self.pageVM)
        }
        
        self.fwContentView.isHidden = !(CustomUtil.getIsShowFwView(messageModel: self.messageModel))
        if (CustomUtil.getIsShowFwView(messageModel: self.messageModel)) {
            self.fwContentView.configModel(model: self.messageModel)
        }
        
        if showName && (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .only) {
            self.adminLab.text = self.viewModel?.adminStr
            self.nickNameLab.text = CustomUtil.getMessageModelNickName(messageModel: self.messageModel)
            self.nickNameLab.textColor = CustomUtil.getMessageModelTextColor(messageModel: self.messageModel)
            self.contentTopCos.constant = ((self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))) ? 41 + 36 : 36
        }else{
            self.nickNameLab.text = ""
            self.adminLab.text = ""
        }
    }
    
    override func configModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?) {
        super.configModel(lastModel: lastModel, model: model, nextModel: nextModel)
        self.messageModel = model
        self.nextModel = nextModel
        
        downloadHeadImage()
        
        configCloudDiskJumpUI()
        
        
//        self.viewModel = Xinhoo_AudioViewModel(last: lastModel, model: model, next: nextModel)
        
        self.sendTimeLab.setTitle(self.viewModel?.dateTime, for: .normal)
        
        self.bubblesAction()
        
        self.backViewLeadingCos.constant = model.chatTypeEnum == .groupChat ? 43 : 3
        if CustomUtil.getIsCloudMessage(messageModel: model) {
            self.backViewLeadingCos.constant = 43
        }
        
        self.headImageView.isHidden = self.viewModel?.headViewIsHidden ?? true
        
        self.backViewBottomCos.constant = (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .mid) ? 1 : 6
        
        if CODAudioPlayerManager.sharedInstance.player != nil && CODAudioPlayerManager.sharedInstance.isAudioPlaying {
            
            if CODAudioPlayerManager.sharedInstance.playModel?.msgID == self.messageModel.msgID {
                 self.messageModel.isPlay = true
            }else{
                 self.messageModel.isPlay = false
            }
            

        }else{
            self.messageModel.isPlay = false
        }
        
        if self.messageModel.isMeSend {
            self.redPointView.isHidden = true
        }else{
            
            self.redPointView.isHidden = self.messageModel.isPlayRead
        }
        
        
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
            self?.slidingView.setAnimationImgView(duration: Double((self?.messageModel.audioModel!.audioDuration.cgFloat)!*((1-p)/1)), totalDuration: (self?.messageModel.audioModel!.audioDuration.cgFloat)!)
            
            CODAudioPlayerManager.sharedInstance.player?.currentTime = TimeInterval((self?.messageModel.audioModel?.audioDuration.cgFloat)!*p)
            
            
        }
        
        self.slidingView.clickBlock = { [weak self] (progress) in
            
            if CODAudioPlayerManager.sharedInstance.isPlaying() {
                CODAudioPlayerManager.sharedInstance.pause()
                self?.progressView.stopAnimationPersentage()
                self?.slidingView.stopAnimationImgView()
                self?.progressView.persentage = CGFloat(CODAudioPlayerManager.sharedInstance.player!.currentTime/Double((self?.messageModel.audioModel!.audioDuration)!))
                self?.playButton.payButtonState = .pause
            }else{
                CODAudioPlayerManager.sharedInstance.play()
                self?.playButton.payButtonState = .play
                self?.progressView.setAnimationPersentage(persentage: 1, duration: Double((self?.messageModel.audioModel!.audioDuration.cgFloat)! - CGFloat(CODAudioPlayerManager.sharedInstance.player!.currentTime)))
                self?.slidingView.setAnimationImgView(duration: Double((self?.messageModel.audioModel!.audioDuration.cgFloat)! - CGFloat(CODAudioPlayerManager.sharedInstance.player!.currentTime) ), totalDuration: (self?.messageModel.audioModel!.audioDuration.cgFloat)!)
                
            }
        }
        
        if self.isFirst {
            self.sendTimeLab.isHidden = false
            self.topCos.constant = 40
        }else{
            self.sendTimeLab.isHidden = true
            self.topCos.constant = 0
        }
        
        let seconds = messageModel.audioModel?.audioDuration ?? 0
        self.secondsLab.text = String(format: "%ld\"", Int(seconds))
        
        let intSeconds = Int(seconds)

        
        //起始显示27条柱形，每2s新增一根柱形
        self.widthCos.constant = CGFloat(80 + (intSeconds / 2) * 3)
        
        self.progressView.configShape(shapeColor: UIColor.init(hexString: "CACACA")!, backColor: UIColor.init(hexString: kBlueTitleColorS)!)
        self.progressView.initLayers(maxWidth: self.widthCos.constant, message: self.messageModel)
        
        self.slidingView.configImageView(image: UIImage.init(named: "audio_play_progress")!)
        
        if self.messageModel.isPlay {
            
            self.progressView.persentage = CGFloat((CODAudioPlayerManager.sharedInstance.player?.currentTime)!/Double((self.messageModel.audioModel!.audioDuration)))
            
            if CODAudioPlayerManager.sharedInstance.isPlaying() {
                
                let duration = Double((self.messageModel.audioModel!.audioDuration.cgFloat)*((1-self.progressView.persentage)/1))
                self.progressView.setAnimationPersentage(persentage: 1, duration: CFTimeInterval(duration))
                self.slidingView.setAnimationImgViewMaxWidth(duration: CFTimeInterval(duration), totalDuration: (self.messageModel.audioModel!.audioDuration.cgFloat), maxWidth: self.widthCos.constant)

            }
            
            CODAudioPlayerManager.sharedInstance.playCell = self
            self.slidingView.isHidden = false
            
        }else{
            self.slidingView.isHidden = true
            self.progressView.stopAnimationPersentage()
            self.slidingView.stopAnimationImgView()
            self.progressView.persentage = 1
            self.playButton.payButtonState = .pause
        }
        
        self.autoDownloadAudio(self.playButton, self.messageModel)
        self.initPlayButtonState(self.playButton)
        
        
        self.burnImageView.isHidden = self.viewModel?.isBurn ?? true
        
        

        
        //只要存在转发ID，或者回复ID，约束就需要做调整，如果都不存在约束高度则为5
        self.contentTopCos.constant = ((self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))) ? 56 : 15
        self.checkIsShowDesc()
        self.configSignMessageUI(textColor: UIColor(hexString: "#979797"))
        
        self.fwdImageStatus()
        
        if let _ = CODAudioPlayerManager.sharedInstance.finishBlock ,let model = CODAudioPlayerManager.sharedInstance.playModel, model.msgID == self.messageModel.msgID {
         
            CODAudioPlayerManager.sharedInstance.finishBlock = {
                
                self.audioPlayEnd()
            }
            
        }
        
    }
    
    private func checkIsShowDesc() {
        //let strDesc = ""
        let strDesc = self.messageModel.audioModel?.descriptionAudio ?? ""
//        let strDesc = "封疆大吏就感觉管理费科技感科技高科技防控大姐夫肯德基开关机进口国佳都科技反馈"
        let isShowTextView = strDesc.removeAllSapce.count > 0
        
        if isShowTextView {
            let textViewIsSame = self.setContentText(textString: strDesc, maxWidth: self.widthCos.constant + 37 + 7)
            self.lblDesc.isHidden = false
            self.lblDescHeightCos.constant = textViewIsSame.labelSize.height
            self.fileImageViewBottomCos.constant = 10 + textViewIsSame.labelSize.height + (textViewIsSame.isSame ? -15 : 0)
        } else {
            self.lblDesc.isHidden = true
            self.lblDescHeightCos.constant = 0
            self.fileImageViewBottomCos.constant = -3
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
        let timeWidth:CGFloat = (self.messageModel.edited == 0) ? (XinhooTool.is12Hour ? 70 : 50) : (XinhooTool.is12Hour ? 110 : 85)
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        
        if let localURL = self.messageModel.audioModel?.audioLocalURL,localURL.count > 0 {
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
            self.slidingView.setAnimationImgView(duration: duration,totalDuration:(self.messageModel.audioModel!.audioDuration.cgFloat))
            
            self.playButton.payButtonState = .play
        }
        
        CODAudioPlayerManager.sharedInstance.playCell = self
        CODAudioPlayerManager.sharedInstance.playModel = self.messageModel
        
        try! Realm.init().write {
            self.messageModel.isPlay = true
            self.messageModel.isPlayRead = true
            self.redPointView.isHidden = self.messageModel.isPlayRead
        }
        
        CODAudioPlayerManager.sharedInstance.playAudio(jid: jid, audioID: audioID) { [weak self] in
            
            guard let `self` = self else { return }
            
            self.audioPlayEnd()

        }
        
    }
        
    @objc func didTapAvatarAction() {
        self.pageVM?.cellDidTapedAvatarImage(self, model: self.messageModel)
    }
    
    
    //强提醒方式，自己去决定怎么提醒
    override func flashingCell() {
        
        self.bubblesImageView.image = self.viewModel?.telegram_left_FlashingBubblesImage
        self.perform(#selector(bubblesAction), with: nil, afterDelay: 1.0)
        
    }
    
    @objc override func bubblesAction() {
        self.bubblesImageView.image = self.viewModel?.telegram_leftBubblesImage
    }
}
