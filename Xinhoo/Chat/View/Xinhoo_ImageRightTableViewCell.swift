//
//  Xinhoo_ImageRightTableViewCell.swift
//  COD
//
//  Created by Xinhoo on 2019/12/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation

class Xinhoo_ImageRightTableViewCell: CODBaseChatCell {

    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var burnImageView: UIImageView!
    @IBOutlet weak var rpView: UIView!
    @IBOutlet weak var contentTopCos: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bubblesImageView: UIImageView!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var sendFailBtn_zzs: UIButton!
    @IBOutlet weak var timeView: XinhooTimeAndReadView!

    @IBOutlet weak var imgPic: CYCustomArcImageView!
    @IBOutlet weak var imgPicHeightCos: NSLayoutConstraint!
    @IBOutlet weak var imgPicWidthCos: NSLayoutConstraint!
    @IBOutlet weak var imgPicBottomCos: NSLayoutConstraint!
    @IBOutlet weak var lblDesc: YYLabel!
    @IBOutlet weak var lblDescHeightCos: NSLayoutConstraint!
    @IBOutlet weak var lblDescWidthCos: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var blurImageView: UIImageView!
    
    @IBOutlet weak var viewEditTime: UIView!
    @IBOutlet weak var lblEditTime: UILabel!
    @IBOutlet weak var imgEditStatu: UIImageView!
    
    @IBOutlet weak var lblStateDesc: UILabel!
    @IBOutlet weak var viewStateDesc: UIView!
    @IBOutlet weak var backViewBottomCos: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingCos: NSLayoutConstraint!
    @IBOutlet weak var timeViewBottomCos: NSLayoutConstraint!
    @IBOutlet weak var backViewTrailingCos: NSLayoutConstraint!
    @IBOutlet weak var viewerImageView: UIImageView!
    
    var viewModel: Xinhoo_ImageViewModel? = nil
    
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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let reSendTap = UITapGestureRecognizer()
        reSendTap.addTarget(self, action: #selector(sendMsgRetainAction))
        self.sendFailBtn_zzs.addGestureRecognizer(reSendTap)
        
        let longGR =  UILongPressGestureRecognizer()
        longGR.delegate = self
        longGR.addTarget(self, action: #selector(longPressgesView(gestureRecognizer:)))
        backView.addGestureRecognizer(longGR)
        
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
        
        fromMe = true
        
        self.contentView.addSubview(self.videoImageView)
        self.videoImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self.imgPic)
            make.size.equalTo(CGSize.init(width: 35, height: 35))
        }
        
        self.addOperation()
    }
    
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func configPicModel(lastModel:CODMessageModel?, model:CODMessageModel, nextModel:CODMessageModel?) {
        
        let messageModel = self.messageModel.editMessage ?? self.messageModel
//        self.imgPic.animatedImage = nil
        self.timeViewBottomCos.constant = -8
        self.timeView.backgroundColor = UIColor(hex: 0, transparency: 0.5)
        
        let messageStatus: CODMessageStatus = CODMessageStatus(rawValue: messageModel.status) ?? .Pending
        
        var imageSize = CGSize.zero
        if messageModel.imageHeight > 0 && messageModel.imageWidth > 0 {
            imageSize.width = messageModel.imageWidth.cgFloat
            imageSize.height = messageModel.imageHeight.cgFloat
        }
        
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue:  messageModel.msgType ) ?? .text
        if modelType == .video {
            imageSize = CODChatConfig.getThumbImageSize(CGSize(width: messageModel.videoModel?.w.cgFloat ?? 0, height: messageModel.videoModel?.h.cgFloat ?? 0))
        } else {
            imageSize = CODChatConfig.getThumbImageSize(CGSize(width: messageModel.photoModel?.w.cgFloat ?? 0, height: messageModel.photoModel?.h.cgFloat ?? 0))
        }
        
//        self.imgPicWidthCos.constant = imageSize.width
        self.imgPicHeightCos.constant = imageSize.height
        
        if messageModel.photoModel?.version == 0 || messageModel.videoModel?.version == 0 {
            self.setImgPic()
        } else {
            self.loadImagePic()
        }
        
        self.checkIsShowDesc(imageSize: imageSize)
        self.bubblesImageView.isHidden = false
        
//        if messageStatus != .Pending {
//            modelType == .video ? self.videoImageView.showPlayVideoIconView() : self.videoImageView.hide()
//        } else {
//
//            if modelType == .video && messageModel.videoModel!.uploadStateType == .Handling {
//                self.lblStateDesc.text = NSLocalizedString("正在处理...", comment: "")
//                self.videoImageView.showVideoLoadingView(progress: self.messageModel.uploadProgress)
//            } else {
//                self.lblStateDesc.text = NSLocalizedString("正在上传", comment: "")
//                self.videoImageView.showVideoLoadingView(progress: self.messageModel.uploadProgress)
//            }
//        }
    }

    override func configModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?) {
        super.configModel(lastModel: lastModel, model: model, nextModel: nextModel)
        self.messageModel = model
        self.nextModel = nextModel
//        self.viewModel = Xinhoo_ImageViewModel(last: lastModel, model: model, next: nextModel)
        self.backViewBottomCos.constant = (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .mid) ? 1 : 6
        self.timeBtn.setTitle(self.viewModel?.dateTime, for: .normal)
        
        //转发跟回复永远不可能同时存在，所以不用做else判断 只做同层级的if判断
        self.rpContentView.isHidden = !(self.messageModel.rp.count > 0 && self.messageModel.rp != "0")
        if (self.messageModel.rp.count > 0 && self.messageModel.rp != "0") {
            self.rpContentView.isCloudDisk = self.isCloudDisk
            self.rpContentView.configModel(model: self.messageModel, indexPath: self.indexPath, pageVM: self.pageVM)
        } else {
            self.rpContentView.clear()
        }
        
        self.fwContentView.isHidden = !(CustomUtil.getIsShowFwView(messageModel: self.messageModel))
        if (CustomUtil.getIsShowFwView(messageModel: self.messageModel)) {
            self.fwContentView.configModel(model: self.messageModel)
        } else {
            self.fwContentView.clear()
        }
        
        //只要存在转发ID，或者回复ID，约束就需要做调整，如果都不存在约束高度则为5
        self.contentTopCos.constant = ((self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))) ? 52 : 1
        
        self.bubblesAction()
        
        if self.isFirst {
            self.timeBtn.isHidden = false
            self.topCos.constant = 40
        } else {
            self.timeBtn.isHidden = true
            self.topCos.constant = 0
        }
        
        self.burnImageView.isHidden = messageModel.burn == 0
        self.burnImageView.isHidden = self.viewModel?.isBurn ?? true
        
        self.timeView.configMessageModel(messageModel)
        
        self.lblEditTime.text = self.viewModel?.sendTime
        self.lblEditTime.font = UIFont.systemFont(ofSize: 11)
        self.lblEditTime.textColor = UIColor.init(hexString: "#54A044")
        
        let messageStatus: CODMessageStatus = CODMessageStatus(rawValue: messageModel.status) ?? .Pending
        if messageStatus == .Succeed && self.messageModel.isReaded {
            imgEditStatu.image = UIImage.init(named: "readInfo_blue_Haveread")
        } else if messageStatus == .Succeed && !self.messageModel.isReaded {
            imgEditStatu.image = UIImage.init(named: "readInfo_blue")
        } else {
            imgEditStatu.image = UIImage.init(named: "")
        }

        self.messageStatus()
        
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue:  messageModel.msgType ) ?? .text
        if (modelType == .gifMessage) {
            self.imgPic.backgroundColor = UIColor.clear

            self.configGifModel(lastModel: lastModel, model: model, nextModel: nextModel)
            self.imageViewTrailingCos.constant = 7
            self.blurView.isHidden = true
            if messageModel.chatTypeEnum == .groupChat && self.isShowName {
            }
        } else {
            self.configPicModel(lastModel: lastModel, model: model, nextModel: nextModel)
            self.blurView.isHidden = false
        }
        
        if modelType == .video {
            
            let strTime = CustomUtil.transToHourMinSec(time:Float(round(self.messageModel.videoModel?.videoDuration ?? 0)))
            self.lblStateDesc.text = "\(strTime)"

        } else {

            if self.messageModel.photoModel?.isGIF ?? false {
                self.lblStateDesc.text = "GIF"
            } else {
                self.lblStateDesc.text = ""
            }
            
            
        }
  
        
        if model.type == .video {
            videoImageView.isUserInteractionEnabled = false
        } else {
            videoImageView.isUserInteractionEnabled = true
        }
        
        self.imgPic.isUserInteractionEnabled = !self.isEditing

    }
    
    private func setImgPic() {
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue:  messageModel.msgType ) ?? .text
        self.imgPic.contentMode = .center
        let failClosure = { [weak self] (image: UIImage?, error: Error?, type: SDImageCacheType, url: URL?) -> Void in

            guard let `self` = self else { return }
            self.imgPic.contentMode = .scaleAspectFit

            if self.messageModel.type == .gifMessage {
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
        
        var type = 1
        var autoPlay = false
        if self.messageModel.photoModel?.isGIF ?? false && self.messageModel.photoModel?.size ?? 0 < 1000 * 1000 {
            type = 2
            autoPlay = true
        }
        
        if let size = self.messageModel.photoModel?.size, size > 2 * 1024 * 1024,
            let string = self.messageModel.photoModel?.serverImageId.getImageFullPath(imageType: 1,isCloudDisk: self.isCloudDisk),
        let url = URL(string: string) {
            self.imgPic.sd_setImage(with: url, placeholderImage: CustomUtil.getPlaceholderImage(), options: [], context: nil)
            return
        }
        
        if modelType == .video {
            if let image = CODImageCache.default.smallImageCache?.imageFromCache(forKey: self.messageModel.videoModel?.videoId ?? "") {
                self.imgPic.image = image
                self.imgPic.contentMode = .scaleAspectFit
            } else {
                var imageUrl = URL.init(string:self.messageModel.videoModel?.firstpicId.getImageFullPath(imageType: 1) ?? "")
                if self.isCloudDisk {
                    imageUrl = URL.init(string:self.messageModel.videoModel?.firstpicId.getImageFullPath(imageType: 1,isCloudDisk: self.isCloudDisk) ?? "")
                }
                
                if let url = imageUrl {
                    CustomUtil.imageVeiwDownLoad(picUrl: url, imageView: self.imgPic, placeholderImage: CustomUtil.getPlaceholderImage(), filePath: "", completedBlock: failClosure)
                }
            }
        } else {
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
                    guard let photoModel = self.messageModel.photoModel, var url = URL.init(string: photoModel.serverImageId.getImageFullPath(imageType: 1)) else {
                        return
                    }
                    if self.isCloudDisk {
                        url = URL.init(string: photoModel.serverImageId.getImageFullPath(imageType: type,isCloudDisk: self.isCloudDisk))!
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
                guard let photoModel = self.messageModel.photoModel, let url = URL(string: photoModel.serverImageId.getImageFullPath(imageType: type, isCloudDisk: self.isCloudDisk)) else {
                    return
                }
                CustomUtil.imageVeiwDownLoad(picUrl: url, imageView: self.imgPic, placeholderImage: CustomUtil.getPlaceholderImage(), filePath: "",autoPlay: autoPlay, completedBlock: failClosure)
            }
        }
    }
    
    private func checkIsShowDesc(imageSize:CGSize) {
        
        let messageModel = self.messageModel.editMessage ?? self.messageModel
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue:  messageModel.msgType ) ?? .text
        
        let strDesc = modelType == .video ? messageModel.videoModel?.descriptionVideo : messageModel.photoModel?.descriptionImage
        let isShowTextView = strDesc?.removeAllSapce.count ?? 0 > 0
        let isRpOrFw = (self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))
        
        let bigRadius:CGFloat = 16
        let smallRadius:CGFloat = 5
        var cornerRadius:CornerRadius = CornerRadiusMake(0, 0, 0, 0)
        let topRadius = isRpOrFw ? smallRadius : bigRadius
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
            
            switch self.viewModel?.cellLocation {
            case .top:
                cornerRadius = CornerRadiusMake(topRadius, topRadius, smallRadius, smallRadius)
                break
            case .bottom:
                cornerRadius = CornerRadiusMake(topRadius, smallRadius, smallRadius, smallRadius)
                break
            case .mid:
                cornerRadius = CornerRadiusMake(topRadius, smallRadius, smallRadius, smallRadius)
                break
            case .only:
                cornerRadius = CornerRadiusMake(topRadius, topRadius, smallRadius, smallRadius)
                break
            default:
                break
            }
            self.imageViewTrailingCos.constant = 7
            self.imgPic.layer.masksToBounds = true
            self.imgPic.setCustomCornerRaidus(cornerRadius, size: CGSize(width: self.lblDescWidthCos.constant + 16, height: imageSize.height))
            
            self.blurView.layer.masksToBounds = true
            self.blurView.setCustomCornerRaidus(cornerRadius, size: CGSize(width: self.lblDescWidthCos.constant + 16, height: imageSize.height))
        } else {
            self.viewEditTime.isHidden = true
            
            self.lblDesc.isHidden = true
            self.lblDescHeightCos.constant = 19
            self.imgPicBottomCos.constant = 1
            
            if self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .mid {
                cornerRadius = CornerRadiusMake(topRadius, self.viewModel?.cellLocation == .mid ? smallRadius : topRadius, bigRadius, smallRadius)
                self.imageViewTrailingCos.constant = 7
                self.imgPic.layer.masksToBounds = true
                self.imgPic.setCustomCornerRaidus(cornerRadius, size: imageSize)
                
                self.blurView.layer.masksToBounds = true
                self.blurView.setCustomCornerRaidus(cornerRadius, size: imageSize)
                
            } else {
                self.imageViewTrailingCos.constant = 1
                self.imgPic.layer.mask = self.viewModel?.createRightImageLayer(imageSize: imageSize)
                self.imgPic.layer.masksToBounds = true
                
                self.blurView.layer.masksToBounds = true
                self.blurView.layer.mask = self.viewModel?.createRightImageLayer(imageSize: imageSize)
            }
        }
    }
    
    private func setContentText(attributedString: NSAttributedString, maxWidth: CGFloat) -> (isSame: Bool,labelSize: CGSize) {
        
        let attText = attributedString
        self.lblDesc.attributedText = attributedString
        self.lblDesc.preferredMaxLayoutWidth = maxWidth
        self.lblDesc.numberOfLines = 0
        self.lblDesc.lineBreakMode = .byCharWrapping
        
        let yyLabel = YYLabel.init()
        yyLabel.attributedText = self.lblDesc.attributedText
        yyLabel.preferredMaxLayoutWidth = self.lblDesc.preferredMaxLayoutWidth
        yyLabel.numberOfLines = self.lblDesc.numberOfLines
        yyLabel.lineBreakMode = self.lblDesc.lineBreakMode
        

        
        self.lblDesc.attributedText = attText
        
        
        var contentSize = yyLabel.sizeThatFits(CGSize.init(width:maxWidth, height: CGFloat(MAXFLOAT)))
        
        if contentSize.width >= maxWidth {
            contentSize.width = maxWidth
        }
        //let timeWidth:CGFloat = CustomUtil.is12Hour() ? 65 : 45
        let timeWidth:CGFloat = (self.messageModel.edited == 0) ? (XinhooTool.is12Hour ? 90 : 70) : (XinhooTool.is12Hour ? 125 : 105)
        if contentSize.width + timeWidth <= maxWidth + 5 {
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
        UIView.animate(withDuration: 1.0) {
            self.imgPic.alpha = 1
        }
        bubblesImageView.image = self.viewModel?.telegram_right_FlashingBubblesImage
        self.perform(#selector(bubblesAction), with: nil, afterDelay: 1.0)
    }
    
    @objc override func bubblesAction() {
        bubblesImageView.image = self.viewModel?.telegram_rightBubblesImage
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.videoImageView.frame.contains(point) && !self.videoImageView.isHidden {
            return self.videoImageView
        }
        return super.hitTest(point, with: event)
    }
    ///点击事件
    @IBAction func tapMessageView(_ sender: Any) {
        
        if self.chatDelegate != nil {
            self.chatDelegate?.cellTapMessage(message: self.messageModel, self)
        }
        
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
