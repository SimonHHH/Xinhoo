//
//  Xinhoo_LocationLeftTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/11/29.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit


class Xinhoo_LocationLeftTableViewCell: CODBaseChatCell {
    

    @IBOutlet weak var timeView: XinhooTimeAndReadView!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var burnImageView: UIImageView!
    @IBOutlet weak var rpView: UIView!
    @IBOutlet weak var locationTitleLab: YYLabel!
    @IBOutlet weak var locationContentLab: YYLabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var contentTopCos: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bubblesImageView: UIImageView!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var backViewLeadingCos: NSLayoutConstraint!
    @IBOutlet weak var backViewBottomCos: NSLayoutConstraint!
    @IBOutlet weak var signMessageLab: UILabel!
    @IBOutlet weak var fwdImageView: UIImageView!
    var viewModel:Xinhoo_LocationViewModel? = nil
    @IBOutlet weak var cloudDiskJumpBtn: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelDownloadHeadImage()
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
    

    
    
    override func configModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?) {
        super.configModel(lastModel: lastModel, model: model, nextModel: nextModel)
        self.messageModel = model
        self.nextModel = nextModel
        
        configCloudDiskJumpUI()
        
        self.backViewBottomCos.constant = (self.viewModel?.cellLocation == .top || self.viewModel?.cellLocation == .mid) ? 1 : 6
        self.timeBtn.setTitle(self.viewModel?.dateTime, for: .normal)
        
        self.backViewLeadingCos.constant = model.chatTypeEnum == .groupChat ? 47 : 8
        if self.isCloudDisk {
           self.backViewLeadingCos.constant = 47
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
        self.contentTopCos.constant = ((self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))) ? 51 : 12
        
        self.bubblesAction()
        
        if self.isFirst {
            self.timeBtn.isHidden = false
            self.topCos.constant = 40
        }else{
            self.timeBtn.isHidden = true
            self.topCos.constant = 0
        }

        self.timeLab.text = self.viewModel?.sendTime
        //Arial-ItalicMT
//        self.timeLab.font = UIFont.init(name: CustomUtil.getFontName(), size: 11)
        self.timeLab.font = FONTTime

        self.burnImageView.isHidden = self.viewModel?.isBurn ?? true

        self.locationTitleLab.text = self.viewModel?.locationTitle
        self.locationContentLab.text = self.viewModel?.locationContent

//        self.timeView.configMessageModel(model)

        DispatchQueue.main.async {
            self.locationImageView.contentMode = .center
            if let image = CODImageCache.default.originalImageCache?.imageFromCache(forKey: self.messageModel.location?.locationImageId) {
                self.locationImageView.image = image
                self.locationImageView.contentMode = .scaleAspectFill
            } else if let imageData = self.messageModel.location?.loactionImageData {
                self.locationImageView.image = UIImage.init(data: imageData)
                self.locationImageView.contentMode = .scaleAspectFill

            }else{
    
                CustomUtil.imageVeiwDownLoad(picUrl: URL.init(string:self.messageModel.location?.locationImageString.getImageFullPath(imageType: 3,isCloudDisk: self.isCloudDisk) ?? "")!, imageView: self.locationImageView ?? UIImageView.init(), placeholderImage: CustomUtil.getPlaceholderImage(), filePath: "") { [weak self](image, error, type, url) in
                    if error != nil{
                        self?.locationImageView.image = CustomUtil.getPictureLoadFailImage()
                        self?.locationImageView.contentMode = .center
                    }else{
                        self?.locationImageView.image = image
                        self?.locationImageView.contentMode = .scaleAspectFill

                    }
                }
            }
 
        }
        
        self.headImageView.isHidden = self.viewModel?.headViewIsHidden ?? true
        if !self.headImageView.isHidden {
            downloadHeadImage()
        }else{
            self.headImageView.image = nil
        }
        
        if messageModel.chatTypeEnum == .channel {
            self.configSignMessageUI()
        }else{
            self.setSignMessage(name: "")
        }
        self.signMessageLab.text = ""
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
    
    //强提醒方式，自己去决定怎么提醒
    override func flashingCell() {
        self.bubblesImageView.image = self.viewModel?.telegram_left_FlashingBubblesImage
        self.perform(#selector(bubblesAction), with: nil, afterDelay: 1.0)
    }
    
    @objc override func bubblesAction() {
        self.bubblesImageView.image = self.viewModel?.telegram_leftBubblesImage
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    ///点击事件
    @objc public override func tapMessageView(gestureRecognizer:UITapGestureRecognizer){
        if self.chatDelegate != nil {
            self.chatDelegate?.cellTapMessage(message: self.messageModel, self)
        }
    }
    
}
