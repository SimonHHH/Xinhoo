//
//  Xinhoo_ImageLeftTableViewCell.swift
//  COD
//
//  Created by Xinhoo on 2019/12/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation

class Xinhoo_ImageLeftTableViewCell: CODBaseChatCell {

    @IBOutlet weak var nickNameView: UIView!
    @IBOutlet weak var nickNameLab: UILabel!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var burnImageView: UIImageView!
    @IBOutlet weak var rpView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bubblesImageView: UIImageView!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var timeView: XinhooTimeAndReadView!
    @IBOutlet weak var backViewLeadingCos: NSLayoutConstraint!
    @IBOutlet weak var headImageView: UIImageView!
    
    @IBOutlet weak var imgPic: CYCustomArcImageView!
    @IBOutlet weak var imgPicHeightCos: NSLayoutConstraint!
    @IBOutlet weak var imgPicWidthCos: NSLayoutConstraint!
    @IBOutlet weak var imgPicBottomCos: NSLayoutConstraint!
    @IBOutlet weak var viewEditTime: UIView!
    @IBOutlet weak var lblEditTime: UILabel!
    @IBOutlet weak var lblDesc: YYLabel!
    @IBOutlet weak var lblDescHeightCos: NSLayoutConstraint!
    @IBOutlet weak var lblDescWidthCos: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var blurImageView: UIImageView!
    
    @IBOutlet weak var lblStateDesc: UILabel!
    @IBOutlet weak var viewStateDesc: UIView!
    @IBOutlet weak var backViewBottomCos: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingCos: NSLayoutConstraint!
    @IBOutlet weak var timeViewBottomCos: NSLayoutConstraint!
    @IBOutlet var stickerLeadingCos: NSLayoutConstraint!
    @IBOutlet weak var adminLab: UILabel!
    @IBOutlet weak var fwdImageView: UIImageView!
    var viewModel: Xinhoo_ImageViewModel? = nil
    @IBOutlet weak var leftTimeViewCons: NSLayoutConstraint!
    @IBOutlet weak var cloudDiskJumpBtn: UIButton!
    
    lazy var videoImageView:CODVideoCancleView = {
        let imgView = CODVideoCancleView.init(frame:CGRect(x: 0, y: 0, width: 35, height: 35))
        imgView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(cancleTapMessageView(gestureRecognizer:)))
        imgView.addGestureRecognizer(tap)
        
        let longGR = UILongPressGestureRecognizer()
        longGR.addTarget(self, action: #selector(longPressgesView(gestureRecognizer:)))
        imgView.addGestureRecognizer(longGR)
        return imgView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgPic.sd_cancelCurrentImageLoad()
        cancelDownloadHeadImage()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
        self.imgPic.maxBufferSize = 1000 * 1000
        
        let taphead = UITapGestureRecognizer()
        taphead.addTarget(self, action: #selector(tapedAvatarImage))
        headImageView.addGestureRecognizer(taphead)
        
        let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longTapAvatarImage(gesture:)))
        headImageView.addGestureRecognizer(longTap)
       
        
        let longGR =  UILongPressGestureRecognizer()
        longGR.addTarget(self, action: #selector(longPressgesView(gestureRecognizer:)))
        longGR.delegate = self
        backView.addGestureRecognizer(longGR)
        self.nickNameView.fd_collapsed = true
        
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
        
        
        self.contentView.addSubview(self.videoImageView)
        self.videoImageView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.center.equalTo(self.imgPic)
            make.size.equalTo(CGSize.init(width: 35, height: 35))
        }
        
        let fwdTap = UITapGestureRecognizer()
        fwdTap.addTarget(self, action: #selector(tapedFwfImageView))
        fwdImageView.addGestureRecognizer(fwdTap)
    }
    
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    

    fileprivate func configPicModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?) {
        
//        self.imgPic.animatedImage = nil
        
        let messageModel = self.messageModel.editMessage ?? self.messageModel
        
        self.timeViewBottomCos.constant = -8
        self.timeView.backgroundColor = UIColor(hex: 0, transparency: 0.5)
        
        self.lblEditTime.text = self.viewModel?.sendTime
        self.lblEditTime.textColor = UIColor.init(hexString: "#979797")
        self.lblEditTime.font = FONTTime
        
        var imageSize = CGSize.zero
        if messageModel.imageHeight > 0 && messageModel.imageWidth > 0 {
            imageSize.width = messageModel.imageWidth.cgFloat
            imageSize.height = messageModel.imageHeight.cgFloat
        }
        
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue:  messageModel.msgType ) ?? .text
        if modelType == .video {
            imageSize = CODChatConfig.getThumbImageSize(CGSize(width: messageModel.videoModel?.w.cgFloat ?? 0, height: messageModel.videoModel?.h.cgFloat ?? 0))
        } else {
            imageSize = CODChatConfig.getThumbImageSize(CGSize(width: messageModel.photoModel?.w.cgFloat  ?? 0, height: messageModel.photoModel?.h.cgFloat  ?? 0))
        }
        
//        self.imgPicWidthCos.constant = imageSize.width
        if imageSize.height != CGFloat.nan {
            self.imgPicHeightCos.constant = imageSize.height
        }
        
        
        if messageModel.photoModel?.version == 0 || messageModel.videoModel?.version == 0 {
            self.setImgPic()
        } else {
            self.loadImagePic()
        }
        
        if messageModel.type == .gifMessage {
            leftTimeViewCons.constant = 0
        } else {
            leftTimeViewCons.constant = 7
        }
        
        
        self.checkIsShowDesc(imageSize: imageSize)
        self.bubblesImageView.isHidden = false
        
        configPicCornerRaidus(imageSize: imageSize)
        
       
    }
    
    override func showName(showName: Bool) {
        self.isShowName = showName
        self.configShowName(showName: showName)
    }
    
    override func configModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?) {
        super.configModel(lastModel: lastModel, model: model, nextModel: nextModel)
        self.messageModel = model
        self.nextModel = nextModel
        
        configCloudDiskJumpUI()
//        self.viewModel = Xinhoo_ImageViewModel(last: lastModel, model: model, next: nextModel)
        self.backViewBottomCos.constant = (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .mid) ? 1 : 6
        self.backViewLeadingCos.constant = model.chatTypeEnum == .groupChat ? 43 : 3
        if CustomUtil.getIsCloudMessage(messageModel: model) {
            self.backViewLeadingCos.constant = 43
        }
        
        self.headImageView.isHidden = self.viewModel?.headViewIsHidden ?? true
        if !self.headImageView.isHidden {
            downloadHeadImage()
        }else{
            self.headImageView.image = nil
        }
        
        self.timeBtn.setTitle(self.viewModel?.dateTime, for: .normal)
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
        self.rpView.fd_collapsed = !self.isRpOrFw()
            
        self.bubblesAction()
        
        if self.isFirst {
            self.timeBtn.isHidden = false
            self.topCos.constant = 40
        } else {
            self.timeBtn.isHidden = true
            self.topCos.constant = 0
        }
        
        self.burnImageView.isHidden = self.viewModel?.isBurn ?? true

        let timeString = TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double((self.messageModel.datetime.int == nil ? "\(Date.milliseconds)":self.messageModel.datetime)))!/1000), format: XinhooTool.is12Hour ? "h:mm a" : "h:mm")


        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue:  messageModel.msgType ) ?? .text
        
        
        // self.imgPic.backgroundColor = UIColor.white
        if modelType == .gifMessage {
            // self.imgPic.backgroundColor = UIColor.clear

            self.configGifModel(lastModel: lastModel, model: model, nextModel: nextModel)
            self.nickNameView.isHidden = true
            self.nickNameView.fd_collapsed = true
            self.imageViewLeadingCos.constant = 7
            
            self.blurView.isHidden = true
            
            if messageModel.chatTypeEnum == .channel {
                self.configSignMessageUI()
            } else if messageModel.chatTypeEnum == .groupChat && self.isShowName {
                self.setSignMessage(name: self.getMessageSenderNickName())
                self.timeView.isHidden = false
            }else{
                self.setSignMessage(name: "")
            }

            NSLayoutConstraint.activate([stickerLeadingCos])
            
        } else {
            
            if viewModel?.messageModel.chatTypeEnum == .groupChat {
                if (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .only) && self.isShowName {
                    self.nickNameView.isHidden = false
                    self.nickNameView.fd_collapsed = false
                } else {
                    self.nickNameView.isHidden = true
                    self.nickNameView.fd_collapsed = true
                }
            }
            
            self.configPicModel(lastModel: lastModel, model: model, nextModel: nextModel)
            
            self.blurView.isHidden = false
            
            if messageModel.chatTypeEnum == .channel {
                self.configSignMessageUI()
            }else{
                self.setSignMessage(name: "")
            }
            NSLayoutConstraint.deactivate([stickerLeadingCos])
        }
        
        if modelType == .video {
            let strTime = CustomUtil.transToHourMinSec(time:Float(round(self.messageModel.videoModel?.videoDuration ?? 0)))
//            self.viewStateDesc.isHidden = false
            self.lblStateDesc.text = "\(strTime)"
            
            self.videoImageView.showPlayVideoIconView()
            if viewModel?.messageModel.chatTypeEnum == .channel {
                let messageStatus: CODMessageStatus = CODMessageStatus(rawValue: messageModel.status) ?? .Pending
                if messageStatus == .Succeed || messageStatus == .Failed {
                    let strTime = CustomUtil.transToHourMinSec(time:Float(round(self.messageModel.videoModel?.videoDuration ?? 0)))
//                    self.viewStateDesc.isHidden = false
                    self.lblStateDesc.text = "\(strTime)"
                } else {
                    if modelType == .video && messageModel.videoModel!.uploadStateType == .Handling {
                        self.lblStateDesc.text = NSLocalizedString("正在处理...", comment: "")
                        self.videoImageView.showVideoLoadingView(progress: self.messageModel.uploadProgress)
                    } else {
                        self.lblStateDesc.text = NSLocalizedString("正在上传", comment: "")
                        self.videoImageView.showVideoLoadingView(progress: self.messageModel.uploadProgress)
                    }
                }
            }
        } else {
            if self.messageModel.photoModel?.isGIF ?? false {
//                self.viewStateDesc.isHidden = false
                self.lblStateDesc.text = "GIF"
            } else {
//                self.viewStateDesc.isHidden = true
                self.lblStateDesc.text = ""
            }
            
            self.videoImageView.hide()
        }
        
        self.imgPic.isUserInteractionEnabled = !self.isEditing
        
        if model.type == .video {
            videoImageView.isUserInteractionEnabled = false
        } else {
            videoImageView.isUserInteractionEnabled = true
        }
        
        self.fwdImageStatus()
    }

    
    private func setImgPic() {
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue:  messageModel.msgType ) ?? .text
        self.imgPic.contentMode = .center

        let failClosure = { [weak self] (image: UIImage?, error: Error?, type: SDImageCacheType, url: URL?) -> Void in

            guard let `self` = self else { return }
            // self.imgPic.backgroundColor = UIColor.white
            self.imgPic.contentMode = .scaleAspectFit

            if self.messageModel.type == .gifMessage {
                // self.imgPic.backgroundColor = UIColor.clear
                return
            }
            
            guard let photoModel = self.messageModel.photoModel else {
                return
            }
            
            if url != URL(string: photoModel.serverImageId.getImageFullPath(imageType: 1, isCloudDisk: self.isCloudDisk)) {
                return
            }
            
            if error != nil{
                self.imgPic.contentMode = .center
                self.imgPic.image = CustomUtil.getPictureLoadFailImage()
            }
        }
        
        if modelType == .video {
            
            CustomUtil.loadSmallImage(from: self.messageModel.videoModel, isCloudDisk: self.isCloudDisk) { [weak self] (image) in
                
                guard let `self` = self else { return }
                
                if let image = image {
                    self.imgPic.image = image
                    self.imgPic.contentMode = .scaleAspectFit
                } else {
                    self.imgPic.contentMode = .center
                    self.imgPic.image = CustomUtil.getPictureLoadFailImage()
                }
            }

        } else {
            
            var type = 1
            var autoPlay = false
            if self.messageModel.photoModel?.isGIF ?? false && self.messageModel.photoModel?.size ?? 0 < 1000 * 1000 {
                type = 2
                autoPlay = true
            }
            
            if self.messageModel.photoModel?.photoImageData?.count ?? 0 > 0 {
                self.imgPic.image = UIImage.init(data: self.messageModel.photoModel?.photoImageData ?? Data())
                self.imgPic.contentMode = .scaleAspectFit
            } else if self.messageModel.photoModel?.photoLocalURL.count ?? 0 > 0 {
                let smallPhotoURL: URL = URL.init(fileURLWithPath: CustomUtil.getImageURL(message: self.messageModel))
                do {
                    let imageData = try Data.init(contentsOf: smallPhotoURL)
                    if imageData.count > 0 {
                        if autoPlay {
                            self.imgPic.image = SDAnimatedImage(data: imageData)
                        }else{
                            self.imgPic.image = UIImage.init(data: imageData)
                        }
                        self.imgPic.contentMode = .scaleAspectFit
                    } else {
                        guard let photoModel = self.messageModel.photoModel, var url = URL.init(string: photoModel.serverImageId.getImageFullPath(imageType: type)) else {
                            return
                        }
                        if self.isCloudDisk {
                            url = URL.init(string: photoModel.serverImageId.getImageFullPath(imageType: type,isCloudDisk: self.isCloudDisk))!
                        }
                        CustomUtil.imageVeiwDownLoad(picUrl: url, imageView: self.imgPic, placeholderImage: CustomUtil.getPlaceholderImage(), filePath: "",autoPlay: autoPlay, completedBlock: failClosure)
                    }
                } catch {
                    guard let photoModel = self.messageModel.photoModel, var url = URL.init(string: photoModel.serverImageId.getImageFullPath(imageType: type)) else {
                        return
                    }
                    if self.isCloudDisk {
                        url = URL.init(string: photoModel.serverImageId.getImageFullPath(imageType: 1,isCloudDisk: self.isCloudDisk))!
                    }
                    CustomUtil.imageVeiwDownLoad(picUrl: url, imageView: self.imgPic, placeholderImage: CustomUtil.getPlaceholderImage(), filePath: "",autoPlay: autoPlay, completedBlock: failClosure)
                }
            } else if let imageData = self.messageModel.photoModel?.photoImageData {
                self.imgPic.image = CustomUtil.getPlaceholderImage()
                if autoPlay {
                    self.imgPic.image = SDAnimatedImage(data: imageData)
                }else{
                    self.imgPic.image = UIImage.init(data: imageData)
                }
                self.imgPic.contentMode = .scaleAspectFit
            } else {
                
                guard let photoModel = self.messageModel.photoModel, var url = URL.init(string: photoModel.serverImageId.getImageFullPath(imageType: type)) else {
                    return
                }
                if self.isCloudDisk {
                    url = URL.init(string: photoModel.serverImageId.getImageFullPath(imageType: type,isCloudDisk: self.isCloudDisk))!
                }
                CustomUtil.imageVeiwDownLoad(picUrl: url, imageView: self.imgPic, placeholderImage: CustomUtil.getPlaceholderImage(), filePath: "",autoPlay: autoPlay, completedBlock: failClosure)
            }
        }
    }
    
    
    private func checkIsShowDesc(imageSize:CGSize) {
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue:  messageModel.msgType ) ?? .text
        
        let messageModel = self.messageModel.editMessage ?? self.messageModel
        
        let strDesc = modelType == .video ? messageModel.videoModel?.descriptionVideo : messageModel.photoModel?.descriptionImage
        let isShowTextView = strDesc?.removeAllSapce.count ?? 0 > 0
        self.timeView.isHidden = isShowTextView
        
        self.lblDescWidthCos.constant = imageSize.width - 16
        
        if isShowTextView {
            self.viewEditTime.isHidden = false
            
            let textViewIsSame = self.setContentText(attributedString: self.getAttributeText(), maxWidth: kChatImageMaxWidth)
            self.lblDesc.isHidden = false
            self.lblDescHeightCos.constant = textViewIsSame.labelSize.height
            self.imgPicBottomCos.constant = textViewIsSame.labelSize.height + 3 + 5 + (textViewIsSame.isSame ? 0 : 15)

            if textViewIsSame.labelSize.width > (imageSize.width - 16) {
                self.lblDescWidthCos.constant = textViewIsSame.labelSize.width
            }
            
        } else {
            self.viewEditTime.isHidden = true
            self.lblDesc.isHidden = true
            self.lblDescHeightCos.constant = 19
            self.imgPicBottomCos.constant = 1
        }
    }
    
    private func setContentText(attributedString: NSAttributedString, maxWidth: CGFloat) -> (isSame: Bool,labelSize: CGSize) {
        self.lblDesc.attributedText = attributedString
        self.lblDesc.preferredMaxLayoutWidth = maxWidth
        self.lblDesc.numberOfLines = 0
        self.lblDesc.lineBreakMode = .byCharWrapping
        
        let yyLabel = YYLabel.init()
        yyLabel.attributedText = self.lblDesc.attributedText
        yyLabel.preferredMaxLayoutWidth = self.lblDesc.preferredMaxLayoutWidth
        yyLabel.font = self.lblDesc.font
        yyLabel.numberOfLines = self.lblDesc.numberOfLines
        yyLabel.lineBreakMode = self.lblDesc.lineBreakMode
        
        yyLabel.attributedText = self.lblDesc.attributedText

        self.lblDesc.attributedText = attributedString
        
        
        var contentSize = yyLabel.sizeThatFits(CGSize.init(width:maxWidth, height: CGFloat(MAXFLOAT)))
        
        if contentSize.width >= maxWidth {
            contentSize.width = maxWidth
        }
        //let timeWidth:CGFloat = CustomUtil.is12Hour() ? 65 : 45
        let timeWidth:CGFloat = (self.messageModel.edited == 0) ? (XinhooTool.is12Hour ? 70 : 50) : (XinhooTool.is12Hour ? 110 : 85)
        if contentSize.width + timeWidth <= maxWidth {
            contentSize.width = contentSize.width + timeWidth
            return (isSame: true, labelSize: contentSize)
        } else {
            let seeker = CharacterLocationSeeker.init()
            let rect = seeker.lastCharacterRect(for: self.lblDesc.attributedText, drawing: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: contentSize))
            
            if rect.maxX + timeWidth > maxWidth {
                return (isSame: false, labelSize: contentSize)
            } else {
                if rect.maxX + timeWidth > contentSize.width {
                    contentSize.width = rect.maxX + timeWidth
                }
                return (isSame: true, labelSize: contentSize)
            }
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
        
        self.imgPic.alpha = 0
        UIView.animate(withDuration: 1.0) {[weak self] in
            guard let `self` = self else { return }
            self.imgPic.alpha = 1
        }
        
        bubblesImageView.image = self.viewModel?.telegram_left_FlashingBubblesImage
        self.perform(#selector(bubblesAction), with: nil, afterDelay: 1.0)
    }
    
    @objc override func bubblesAction() {
        bubblesImageView.image = self.viewModel?.telegram_leftBubblesImage
    }
    
    ///点击事件
//    @objc public override func tapMessageView(gestureRecognizer:UITapGestureRecognizer){
//        if self.chatDelegate != nil {
//            self.chatDelegate?.cellTapMessage(message: self.messageModel, self)
//        }
//    }
    
    
    @IBAction func tapMessageView(_ sender: Any) {
        if self.chatDelegate != nil {
            self.chatDelegate?.cellTapMessage(message: self.messageModel, self)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.videoImageView.frame.contains(point) && !self.videoImageView.isHidden {
            return self.videoImageView
        }
        return super.hitTest(point, with: event)
    }
    
    @objc public func cancleTapMessageView(gestureRecognizer:UITapGestureRecognizer){
        let messageStatus: CODMessageStatus =  CODMessageStatus(rawValue: messageModel.status) ?? .Succeed
    
        if messageStatus != .Succeed && messageStatus != .Failed && messageStatus != .Delivering {

            self.pageVM?.cancelEditMessage(message: self.messageModel)
        } else {
            
            if self.chatDelegate != nil {
                self.chatDelegate?.cellTapMessage(message: self.messageModel, self)
            }
        }
    }
    
}

