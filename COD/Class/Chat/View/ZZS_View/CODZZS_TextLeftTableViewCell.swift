//
//  CODZZS_TextLeftTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/7/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa



class CODZZS_TextLeftTableViewCell: CODBaseChatCell {
    
    var seeker = CharacterLocationSeeker.init()
    var maxWidth = KScreenWidth - 68 - 26 //(显示头像=43，最大距离屏幕宽度-50，label跟backView间距25)
    var timeWidth:CGFloat = 10

    @IBOutlet weak var sendTimeLab: UIButton!
    @IBOutlet weak var bubblesImageView: UIImageView!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var rightCos: NSLayoutConstraint!
    @IBOutlet weak var bottomCos: NSLayoutConstraint!
    @IBOutlet weak var contentLab: CODChatContentLabel!
//    @IBOutlet weak var timeLab: YYLabel!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nicklab: YYLabel!
    @IBOutlet weak var backViewLeadingCos: NSLayoutConstraint!
    @IBOutlet weak var contentTopCos: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var burnImageView: UIImageView!
    @IBOutlet weak var rpTopCos: NSLayoutConstraint!
    @IBOutlet weak var rpTapView: UIView!
    @IBOutlet weak var backViewBottomCos: NSLayoutConstraint!
    @IBOutlet weak var backViewRightCos: NSLayoutConstraint!
    @IBOutlet weak var adminLab: UILabel!
    @IBOutlet weak var fwdImageView: UIImageView!
    @IBOutlet weak var cloudDiskJumpBtn: UIButton!
    
    var viewModel:Xinhoo_TextViewModel? = nil
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.headImageView.sd_cancelCurrentImageLoad()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapedAvatarImage))
        headImageView.addGestureRecognizer(tap)
        
        let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longTapAvatarImage(gesture:)))
        headImageView.addGestureRecognizer(longTap)
        
        headImageView.isUserInteractionEnabled = true
        

        let longGR = UILongPressGestureRecognizer()
        longGR.addTarget(self, action: #selector(longPressgesView(gestureRecognizer:)))
        longGR.delegate = self
        backView.addGestureRecognizer(longGR)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapView(gestureRecognizer:)))
        doubleTap.numberOfTapsRequired = 2
        backView.addGestureRecognizer(doubleTap)
        
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
        
        let fwdTap = UITapGestureRecognizer()
        fwdTap.addTarget(self, action: #selector(tapedFwfImageView))
        fwdImageView.addGestureRecognizer(fwdTap)
    }
    
    @objc override func more(noti:Notification) {
        super.more(noti: noti)
        if self.backViewRightCos.constant == 65 {
            self.backViewRightCos.constant = 25
//            self.contentView.isUserInteractionEnabled = false
//            self.traverseAllSubViews(view: self.contentView, enabled: self.contentView.isUserInteractionEnabled)
        }else{
            self.backViewRightCos.constant = 65
//            self.contentView.isUserInteractionEnabled = true
//            self.traverseAllSubViews(view: self.contentView, enabled: self.contentView.isUserInteractionEnabled)
        }
    }
    
    
    
    
    
    fileprivate func configContectLabel(_ model: CODMessageModel, showName: Bool) {
        maxWidth = (model.chatTypeEnum == .groupChat || self.isCloudDisk) ? (KScreenWidth - 108 - 25) : (KScreenWidth - 108 - 25 + 40)
        
        let attText = self.getAttributeText()

        if self.messageModel.type == .unknown {
            self.contentLab.text = NSLocalizedString("[不支持的消息类型]", comment: "[不支持的消息类型]")
            
            self.contentLab.font = UIFont.init(name: "PingFangSC-Regular", size: CGFloat(17+(UserDefaults.standard.integer(forKey: kFontSize_Change))))
            
        } else {
            let sendTime = NSMutableAttributedString(string: "  \(self.viewModel?.sendTime ?? "")")
            sendTime.yy_color = UIColor(hex: 0x979797)
            sendTime.yy_font = FONTTime
            
            var nikeName: NSMutableAttributedString? = nil
            if messageModel.n.count > 0 && self.messageModel.chatTypeEnum == .channel {
                nikeName = NSMutableAttributedString(string: "\(messageModel.n)")
                nikeName?.yy_color = UIColor(hex: 0x979797)
                nikeName?.yy_font = UIFont.systemFont(ofSize: 11)
            }
            
            
            var rpTapViewWidth: CGFloat = 0
            
            var nickNameWidth: CGFloat = 0
            if showName {
                nickNameWidth = nicklab.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)).width
            }
            
            if self.messageModel.isFw || self.messageModel.isRp {
                
                rpTapViewWidth = self.rpTapView.systemLayoutSizeFitting(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)).width
                
                rpTapViewWidth = rpTapViewWidth > maxWidth ? maxWidth : rpTapViewWidth
                
            }
            

            self.contentLab.config(content: attText, timeAtt: sendTime, nikeName:nikeName,  maxWidth: maxWidth, rpTapViewWidth: rpTapViewWidth, nickNameWidth: nickNameWidth)
        }
        
//        contentLab.sizeToFit()
        self.configText()
    }
    
    override func configModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?) {
        

        super.configModel(lastModel: lastModel, model: model, nextModel: nextModel)
        self.messageModel = model
        self.nextModel = nextModel
        
        configCloudDiskJumpUI()
        
        self.backViewBottomCos.constant = (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .mid) ? 1 : 6
        
        self.bubblesAction()
        
        self.backViewLeadingCos.constant = model.chatTypeEnum == .groupChat ? 43 : 3
        if CustomUtil.getIsCloudMessage(messageModel: model) {
            self.backViewLeadingCos.constant = 43
        }
        if self.isEditing {
            self.backViewRightCos.constant = 25
        }else{
            self.backViewRightCos.constant = 65
        }
        
        self.sendTimeLab.setTitle(self.viewModel?.dateTime, for: .normal)
        

        if self.isFirst {
            self.sendTimeLab.isHidden = false
            self.topCos.constant = 40
        }else{
            self.sendTimeLab.isHidden = true
            self.topCos.constant = 0
        }

        self.burnImageView.isHidden = self.viewModel?.isBurn ?? true
        
        self.headImageView.isHidden = self.viewModel?.headViewIsHidden ?? true
        if !self.headImageView.isHidden {
            downloadHeadImage()
        }else{
            self.headImageView.image = nil
        }
        
        
        self.fwdImageStatus()
    }
    
    private func configText(){
        
        self.contentLab.preferredMaxLayoutWidth = maxWidth
//        self.contentLab.displaysAsynchronously = true
        self.contentLab.numberOfLines = 0
//        self.contentLab.textAlignment = .left
    }
    
    override func showName(showName:Bool) {
        
        self.isShowName = showName
        
        self.rpContentView.isHidden = !(self.messageModel.rp.count > 0 && self.messageModel.rp != "0")
        self.fwContentView.isHidden = !(CustomUtil.getIsShowFwView(messageModel: self.messageModel))
        
        if (showName && (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .only)) || CustomUtil.getIsCloudMessage(messageModel: self.messageModel) {
            
            self.adminLab.text = self.viewModel?.adminStr
            self.contentTopCos.constant = 25
            self.nicklab.text = CustomUtil.getMessageModelNickName(messageModel: self.messageModel)
            self.nicklab.textColor = CustomUtil.getMessageModelTextColor(messageModel: self.messageModel)
            
            self.contentTopCos.constant = ((self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))) ? 67 : 25
            self.rpTopCos.constant = 30
            
        }else{
            self.adminLab.text = ""
            self.contentTopCos.constant = ((self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))) ? 47 : 7
            self.rpTopCos.constant = 10
            self.nicklab.text = ""
        }
        
        if (self.messageModel.rp.count > 0 && self.messageModel.rp != "0") {
            self.rpContentView.isCloudDisk = self.isCloudDisk
            self.rpContentView.configModel(model: self.messageModel, indexPath: self.indexPath, pageVM: self.pageVM)
        }else{
            self.rpContentView.clear()
        }
        
        if (CustomUtil.getIsShowFwView(messageModel: self.messageModel)) {
            self.fwContentView.configModel(model: self.messageModel)
        }else{
            self.fwContentView.clear()
        }
        
        let cellShowName = showName && (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .only)
        
        configContectLabel(self.messageModel, showName: cellShowName)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configLab(contentSize:CGSize) -> CGRect {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        lab.text = messageModel.text
        lab.font = IMChatTextFont
        lab.numberOfLines = 0
        lab.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        lab.textAlignment = .left
        
        if let fontSize = UserDefaults.cod_stringForKey(kFontSize_Change)?.int {
            lab.font = UIFont.init(name: "PingFangSC-Regular", size: CGFloat(17 + fontSize))
        }
        
        self.seeker.config(with: lab)
        let string = lab.text! as NSString
        return self.seeker.characterRect(at: UInt((string.length)-1))
    }
    
    @objc public override func longPressgesView(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            if self.chatDelegate != nil {
                self.pageVM?.cellLongPressMessage(cellVM: self.viewModel, self, self.backView)
            }
        }
    }
    
    @objc override func doubleTapView(gestureRecognizer: UITapGestureRecognizer) {
        if self.chatDelegate != nil {
            self.pageVM?.cellLongPressMessage(cellVM: self.viewModel, self, self.backView)
        }
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
