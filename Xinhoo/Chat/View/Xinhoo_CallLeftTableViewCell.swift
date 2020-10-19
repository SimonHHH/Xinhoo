//
//  Xinhoo_CallLeftTableViewCell.swift
//  COD
//
//  Created by Xinhoo on 2019/12/9.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation


class Xinhoo_CallLeftTableViewCell: CODBaseChatCell {

    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var burnImageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bubblesImageView: UIImageView!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var backViewLeadingCos: NSLayoutConstraint!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var backViewBottomCos: NSLayoutConstraint!
    
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnStateAndTime: UIButton!
    @IBOutlet weak var imgIcon: UIImageView!
    
    var viewModel:Xinhoo_CallViewModel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapedAvatarImage))
        headImageView.addGestureRecognizer(tap)
        
        let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longTapAvatarImage(gesture:)))
        headImageView.addGestureRecognizer(longTap)
        
        let longGR =  UILongPressGestureRecognizer()
        longGR.addTarget(self, action: #selector(longPressgesView(gestureRecognizer:)))
        backView.addGestureRecognizer(longGR)
        
        let locationTap = UITapGestureRecognizer()
        locationTap.addTarget(self, action: #selector(tapMessageView(gestureRecognizer:)))
        backView.addGestureRecognizer(locationTap)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelDownloadHeadImage()
    }
    
    override func configModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?) {
        super.configModel(lastModel: lastModel, model: model, nextModel: nextModel)
        self.messageModel = model
        self.nextModel = nextModel
//        self.viewModel = Xinhoo_CallViewModel(last: lastModel, model: model, next: nextModel)
        self.backViewBottomCos.constant = (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .mid) ? 1 : 6
        
        self.timeBtn.setTitle(self.viewModel?.dateTime, for: .normal)
        
        self.backViewLeadingCos.constant = model.isGroupChat ? 43 : 3
        if CustomUtil.getIsCloudMessage(messageModel: model) {
            self.backViewLeadingCos.constant = 43
        }
        if self.isFirst {
            self.timeBtn.isHidden = false
            self.topCos.constant = 40
        }else{
            self.timeBtn.isHidden = true
            self.topCos.constant = (self.messageModel.burn > 0) ? 3 : 0
        }
        
        self.bubblesAction()

        self.burnImageView.isHidden = self.viewModel?.isBurn ?? true
        
        self.headImageView.isHidden = self.viewModel?.headViewIsHidden ?? true
        if !self.headImageView.isHidden {
            downloadHeadImage()
        }else{
            self.headImageView.image = nil
        }
        
        if let fontSize = UserDefaults.cod_stringForKey(kFontSize_Change)?.int {
            self.lblDesc.font = UIFont.init(name: "PingFangSC-Medium", size: CGFloat(17 + fontSize))
        }
        let videoType = CustomUtil.getVideoChatType(videoString: model.videoCallModel?.videoString ?? "")
        self.lblDesc.text = CustomUtil.getVideoChatContentString(messageModel: model)

        self.imgIcon.image = UIImage.init(named:model.msgType == EMMessageBodyType.voiceCall.rawValue ? "voice_call_icon" : "video_call_icon")
        
        self.btnStateAndTime.setTitle(self.viewModel?.sendTime, for: .normal)
        self.btnStateAndTime.titleLabel!.font = FONTTime
        self.btnStateAndTime.setTitleColor(UIColor.init(hexString: "979797"), for: .normal)
        if videoType == .close || videoType == .reject{
            self.btnStateAndTime.setImage(UIImage.init(named: "call_msg_successfully_left"), for: .normal)
        }else{
            self.btnStateAndTime.setImage(UIImage.init(named: "call_msg_failed_left"), for: .normal)
        }
    }
    
    @objc public override func longPressgesView(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            if self.chatDelegate != nil {
                self.pageVM?.cellLongPressMessage(cellVM: self.viewModel, self, self.backView)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //强提醒方式，自己去决定怎么提醒
    override func flashingCell() {
        self.bubblesImageView.image = self.viewModel?.telegram_left_FlashingBubblesImage
        self.perform(#selector(bubblesAction), with: nil, afterDelay: 1.0)
    }
    
    @objc override func bubblesAction() {
        self.bubblesImageView.image = self.viewModel?.telegram_leftBubblesImage
    }
    
    ///点击事件
    @objc public override func tapMessageView(gestureRecognizer:UITapGestureRecognizer){
        if self.chatDelegate != nil {
            self.chatDelegate?.cellTapMessage(message: self.messageModel, self)
        }
    }
    
}
