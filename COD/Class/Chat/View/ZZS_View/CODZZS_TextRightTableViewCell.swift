//
//  CODZZS_TextRightTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/7/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import YYText
class CODZZS_TextRightTableViewCell: CODBaseChatCell {

    var seeker = CharacterLocationSeeker.init()
    var maxWidth = KScreenWidth - 68 - 25
    var timeWidth:CGFloat = 0

    @IBOutlet weak var sendTimeLab: UIButton!
    @IBOutlet weak var bubblesImageView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var sendFailBtn_zzs: UIButton!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var contentLab: CODChatContentLabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var burnImageView: UIImageView!
    @IBOutlet weak var contentTopCos: NSLayoutConstraint!
    @IBOutlet weak var rpTapView: UIView!
    @IBOutlet weak var backViewBottomCos: NSLayoutConstraint!
    @IBOutlet weak var backViewLeftCos: NSLayoutConstraint!
    @IBOutlet weak var backViewTrailingCos: NSLayoutConstraint!
    @IBOutlet weak var viewerImageView: UIImageView!
    
    var viewModel:Xinhoo_TextViewModel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

        let reSendTap = UITapGestureRecognizer()
        reSendTap.addTarget(self, action: #selector(sendMsgRetainAction))
        self.sendFailBtn_zzs.addGestureRecognizer(reSendTap)
        
        let longGR =  UILongPressGestureRecognizer()
        longGR.addTarget(self, action: #selector(longPressgesView(gestureRecognizer:)))
        longGR.delegate = self
        backView.addGestureRecognizer(longGR)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapView(gestureRecognizer:)))
        doubleTap.numberOfTapsRequired = 2
        backView.addGestureRecognizer(doubleTap)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapRpView))
        rpContentView.addGestureRecognizer(tap)
        
        self.rpTapView.addSubview(self.rpContentView)
        self.rpTapView.addSubview(self.fwContentView)
        
        self.rpContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.fwContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        fromMe = true
        
        self.addOperation()
    }
    
    

    @objc override func more(noti:Notification) {
        super.more(noti: noti)
        if self.backViewLeftCos.constant == 65 {
            self.backViewLeftCos.constant = 15
//            self.contentView.isUserInteractionEnabled = false
//            self.traverseAllSubViews(view: self.contentView, enabled: self.contentView.isUserInteractionEnabled)
        }else{
            self.backViewLeftCos.constant = 65
//            self.contentView.isUserInteractionEnabled = true
//            self.traverseAllSubViews(view: self.contentView, enabled: self.contentView.isUserInteractionEnabled)
        }
    }
    
    fileprivate func configContentLabel(_ model: CODMessageModel) {

        let attText = self.getAttributeText()

        var rpTapViewWidth: CGFloat = 0
        
        if self.messageModel.type == .unknown {
            self.contentLab.text = NSLocalizedString("[不支持的消息类型]", comment: "[不支持的消息类型]")
            self.contentLab.font = UIFont.init(name: "PingFangSC-Regular", size: CGFloat(17+(UserDefaults.standard.integer(forKey: kFontSize_Change))))
        } else {
            
            let messageStatus: CODMessageStatus =  CODMessageStatus(rawValue: messageModel.status) ?? .Succeed
            
            let sendTime = NSMutableAttributedString(string: "  \(self.viewModel?.sendTime ?? "")")
            sendTime.yy_color = UIColor(hex: 0x54A044)
            sendTime.yy_font = FONTTime
            
            
            if self.messageModel.isFw || self.messageModel.isRp {
                
                rpTapViewWidth = self.rpTapView.systemLayoutSizeFitting(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)).width
                
                rpTapViewWidth = rpTapViewWidth > maxWidth ? maxWidth : rpTapViewWidth
                
            }
            
            if messageStatus == .Succeed && self.messageModel.isReaded {
                self.contentLab.config(content: attText, timeAtt: sendTime, maxWidth: maxWidth, rpTapViewWidth: rpTapViewWidth, status: .haveRead)
            }else if messageStatus == .Succeed && !self.messageModel.isReaded{
                self.contentLab.config(content: attText, timeAtt: sendTime, maxWidth: maxWidth, rpTapViewWidth: rpTapViewWidth, status: .sendSuccessful)
            } else if messageStatus == .Pending {
                self.contentLab.config(content: attText, timeAtt: sendTime, maxWidth: maxWidth, rpTapViewWidth: rpTapViewWidth, status: .sending)
            }else{
                self.contentLab.config(content: attText, timeAtt: sendTime, maxWidth: maxWidth, rpTapViewWidth: rpTapViewWidth, status: .unknown)
            }
            
        }
        
        //        let newMaxWidth = rpTapViewWidth > maxWidth ? rpTapViewWidth : maxWidth
        
        //        let contentSize = contentLab.sizeThatFits(CGSize.init(width:newMaxWidth, height: CGFloat(MAXFLOAT)))
        
        self.configText()
    }
    
    override func configModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?) {
        super.configModel(lastModel: lastModel, model: model, nextModel: nextModel)
        self.messageModel = model
        self.nextModel = nextModel
        
        maxWidth = KScreenWidth - 68 - 25
        
//        self.viewModel = Xinhoo_TextViewModel(last: lastModel, model: model, next: nextModel)
        
        if self.isEditing {
            self.backViewLeftCos.constant = 15
        }else{
            self.backViewLeftCos.constant = 65
        }
        
        self.backViewBottomCos.constant = (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .mid) ? 1 : 6
        
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
        self.contentTopCos.constant = ((self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))) ? 47 : 5
        
        //气泡图片
        self.bubblesAction()
        
        self.sendTimeLab.setTitle(self.viewModel?.dateTime, for: .normal)

        self.timeWidth = (self.messageModel.edited == 0) ? (XinhooTool.is12Hour ? 90 : 70) : (XinhooTool.is12Hour ? 125 : 105)


//        if contentSize.width + timeWidth <= maxWidth {
//        }else{
//
//            let rect = self.seeker.lastCharacterRect(for: contentLab.attributedText, drawing: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: contentSize))
//
//        }
        
        if self.isFirst {
            self.sendTimeLab.isHidden = false
            self.topCos.constant = 40
        }else{
            self.sendTimeLab.isHidden = true
            self.topCos.constant = 0
        }
        

        self.messageStatus()

        self.burnImageView.isHidden = self.viewModel?.isBurn ?? true
        
        self.configContentLabel(model)
    }
    
    private func configText(){
        
        self.contentLab.preferredMaxLayoutWidth = maxWidth
//        self.contentLab.displaysAsynchronously = true
        self.contentLab.numberOfLines = 0
//        self.contentLab.textAlignment = .left
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        self.bubblesImageView.image = self.viewModel?.telegram_right_FlashingBubblesImage
        self.perform(#selector(bubblesAction), with: nil, afterDelay: 1.0)
    }
    
    @objc override func bubblesAction() {
        self.bubblesImageView.image = self.viewModel?.telegram_rightBubblesImage
    }
    
    
    
}
