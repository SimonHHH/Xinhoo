//
//  Xinhoo_CardLeftTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/12/2.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class Xinhoo_CardLeftTableViewCell: CODBaseChatCell {

    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var burnImageView: UIImageView!
    @IBOutlet weak var rpView: UIView!
    @IBOutlet weak var nameLab: YYLabel!
    @IBOutlet weak var userNameLab: YYLabel!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var contentTopCos: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bubblesImageView: UIImageView!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var timeLab: XinhooTimeAndReadView!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var backViewLeadingCos: NSLayoutConstraint!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var backViewBottomCos: NSLayoutConstraint!
    @IBOutlet weak var descLab: YYLabel!
    @IBOutlet weak var signMessageLab: UILabel!
    @IBOutlet weak var fwdImageView: UIImageView!
    @IBOutlet weak var cloudDiskJumpBtn: UIButton!
    
    var viewModel:Xinhoo_CardViewModel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.descLab.text = NSLocalizedString("点击查看个人信息", comment: "")
        
        let cardTap = UITapGestureRecognizer()
        cardTap.addTarget(self, action: #selector(cardAction))
        self.actionBtn.addGestureRecognizer(cardTap)
        
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
        
        let rpTap = UITapGestureRecognizer.init(target: self, action: #selector(tapRpView))
        rpContentView.addGestureRecognizer(rpTap)
        
        self.rpView.addSubview(self.rpContentView)
        self.rpView.addSubview(self.fwContentView)
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelDownloadHeadImage()
    }
    
    
    override func configModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?) {
        super.configModel(lastModel: lastModel, model: model, nextModel: nextModel)
        self.messageModel = model
        self.nextModel = nextModel
        
        configCloudDiskJumpUI()
//        self.viewModel = Xinhoo_CardViewModel(last: lastModel, model: model, next: nextModel)
        self.backViewBottomCos.constant = (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .mid) ? 1 : 6
        self.timeBtn.setTitle(self.viewModel?.dateTime, for: .normal)
        
        self.backViewLeadingCos.constant = model.chatTypeEnum == .groupChat ? 43 : 3
        if CustomUtil.getIsCloudMessage(messageModel: model) {
            self.backViewLeadingCos.constant = 43
        }
        
        //转发跟回复永远不可能同时存在，所以不用做else判断 只做同层级的if判断
        self.rpContentView.isHidden = !(self.messageModel.rp.count > 0 && self.messageModel.rp != "0")
        if (self.messageModel.rp.count > 0 && self.messageModel.rp != "0") {
            self.rpContentView.isCloudDisk = self.isCloudDisk
            self.rpContentView.configModel(model: self.messageModel, indexPath: self.indexPath, pageVM: self.pageVM)
        }else{
            self.rpContentView.clear()
        }
        
        self.fwContentView.isHidden = !(CustomUtil.getIsShowFwView(messageModel: self.messageModel))
        if (CustomUtil.getIsShowFwView(messageModel: self.messageModel)) {
            self.fwContentView.configModel(model: self.messageModel)
        }else{
            self.fwContentView.clear()
        }
        
        //只要存在转发ID，或者回复ID，约束就需要做调整，如果都不存在约束高度则为5
        self.contentTopCos.constant = ((self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))) ? 52 : 10
        
        self.bubblesAction()
        
        if self.isFirst {
            self.timeBtn.isHidden = false
            self.topCos.constant = 40
        }else{
            self.timeBtn.isHidden = true
            self.topCos.constant = 0
        }

        //Arial-ItalicMT
//        self.timeLab.font = UIFont.init(name: CustomUtil.getFontName(), size: 11)

        self.burnImageView.isHidden = self.viewModel?.isBurn ?? true
        self.actionBtn.setImage(self.viewModel?.cardActionImage, for: .normal)
        self.nameLab.text = self.viewModel?.cardName
        self.userNameLab.text = self.viewModel?.cardUserName
        
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: self.messageModel.businessCardModel?.userpic ?? "") { (image) in
            self.cardImageView.image = image
        }
        self.headImageView.isHidden = self.viewModel?.headViewIsHidden ?? true
        if !self.headImageView.isHidden {
            downloadHeadImage()
        }else{
            self.headImageView.image = nil
        }
        self.configSignMessageUI(textColor: UIColor(hexString: "#979797"))
        
        self.fwdImageStatus()
    }
    
    @IBAction func sendMessageAction(_ sender: Any) {
        self.sendMsgRetainAction()
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
    
    @objc func cardAction(_ sender: Any) {
        if (self.chatDelegate != nil) {
            self.chatDelegate?.cellCardAction(self, message: self.messageModel)
        }
    }
    
}
