//
//  CODChatTopView.swift
//  COD
//
//  Created by 1 on 2019/11/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

protocol CODChatTopViewDelegate:class {
    func topViewAction(model: CODMessageModel)

    func cancelTopMessage()
}
class CODChatTopView: UIView {

    weak var delegate: CODChatTopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
    }
    var model: CODMessageModel? {
        didSet{
            if let messageModel = model{
                self.setCellContent(messageModel)
            }
        }
    }
    func setCellContent(_ messageModel: CODMessageModel) {
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: messageModel.msgType) ?? .text
        
        var transString = ""
        
        switch modelType {
        case .text:
            
            transString = messageModel.text.replaceLineSpaceToSpace
            break
        case .image:
            
            transString = NSLocalizedString("图片", comment: "")
            break
            
        case .multipleImage:
            transString = NSLocalizedString("多图", comment: "")
            break
        case .audio:
            
            transString = NSLocalizedString("语音信息", comment: "")
            break
        case .video:
            
            transString = NSLocalizedString("视频", comment: "")
            break
        case .voiceCall, .videoCall:
            
            transString = CustomUtil.getVideoChatContentString(messageModel: messageModel)
            break
        case .location:
            
            transString = NSLocalizedString("位置", comment: "")
            break
        case .businessCard:
            
            transString = NSLocalizedString("联系人", comment: "")
            break
        case .file:
            
            transString = messageModel.fileModel?.filename ?? NSLocalizedString("文件", comment: "")
            break
        case .gifMessage:
            
            transString = CustomUtil.getEmojiName(emojiName: messageModel.text)
            break
        default:
            transString = ""
        }
        
        
        if  checkMsgImageType(messageModel) {
            dowloadImage(messageModel)
            self.displayImage.snp.remakeConstraints { (make) in
                make.left.equalTo(self.lineView.snp.right).offset(6)
                make.size.equalTo(CGSize(width: 35, height: 35))
                make.centerY.equalTo(self)
            }
        }else{
            self.displayImage.snp.remakeConstraints { (make) in
                make.left.equalTo(self.lineView.snp.right).offset(2)
                make.size.equalTo(CGSize(width: 0, height: 0))
                make.centerY.equalTo(self)
            }
        }
        self.nicknameLabel.text = NSLocalizedString("置顶消息", comment: "")
        if modelType == .text {
            self.desLabel.textColor = UIColor.black
        }else{
            self.desLabel.textColor = UIColor.init(hexString: "#8E8E92")
        }
        
        if messageModel.burn > 0{
            self.readDestroyImageView.isHidden = false
        }else{
            self.readDestroyImageView.isHidden = true
        }
        self.desLabel.text = transString
//        var textHeight = transString.getStringHeight(font: self.desLabel.font, lineSpacing: 0, fixedWidth: KScreenWidth - 84 - (self.displayImage.image?.size.width ?? 0))
//        if textHeight > 30 {
//            textHeight = 40
//        }
        
//        self.desLabel.snp.updateConstraints { (make) in
//            make.height.equalTo(textHeight)
//        }
//
//        self.snp.updateConstraints { (make) in
//            make.height.equalTo(30 + textHeight)
//        }
//
//        self.layoutSubviews()
//        self.updateConstraintsIfNeeded()
        
    }
    
    func checkMsgImageType(_ messageModel: CODMessageModel) -> Bool {
        
        let modelType = messageModel.type
        
        if  modelType == .image || modelType == .video || modelType == .gifMessage || modelType == .multipleImage {
            return true
        }
        
        return false

    }
    
    func dowloadImage(_ messageModel: CODMessageModel) {
        
        if checkMsgImageType(messageModel) == false {
            return
        }
        
        
        let modelType = messageModel.type

        if modelType == .gifMessage {
            self.displayImage.image = UIImage.getGifImage(imageName: messageModel.text)
        } else {
            CODDownLoadManager.sharedInstance.downloadImage(type: .smallImage(messageModel: messageModel, isCloudDisk: false)) { [weak self] image in
                guard let `self` = self else { return }
                self.displayImage.image = image
            }
        }

    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public lazy var lineView:UIView = {
        let lineV = UIView(frame: CGRect.zero)
      lineV.backgroundColor = UIColor.init(hexString: kBlueTitleColorS)
        return lineV;
    }()
    
    public lazy var nicknameLabel:UILabel = {
        let nicknameLabel = UILabel(frame: CGRect.zero)
        nicknameLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 14)
        nicknameLabel.textColor = UIColor.init(hexString: kBlueTitleColorS)
        nicknameLabel.numberOfLines = 1
        return nicknameLabel;
    }()
    public lazy var displayImage:UIImageView = {
        let desImg = UIImageView.init()
        desImg.contentMode = .scaleAspectFill
        desImg.layer.cornerRadius = 4
        desImg.clipsToBounds = true
        return desImg;
    }()
    public lazy var desLabel:UILabel = {
        let desLb = UILabel(frame: CGRect.zero)
        desLb.font = UIFont.init(name: "PingFangSC-Regular", size: 14)
        desLb.textColor = UIColor.init(hexString: "#000000")
        desLb.numberOfLines = 1
        return desLb;
    }()
    lazy var bottomLineView:UIView = {
        let lineView = UIView(frame: CGRect.zero)
        lineView.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        return lineView
    }()
    public lazy var deleteBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "chatTop_close"), for: .normal)
        btn.contentMode = .left
        btn.addTarget(self, action: #selector(cancelMessageEidt), for: .touchUpInside)
        return btn;
    }()
    
    //内容区_阅后即焚
    public lazy var readDestroyImageView:UIImageView = {
         var readDestroyImageView = UIImageView(frame: CGRect.zero)
         readDestroyImageView.image = UIImage(named: "readDestroy")
         readDestroyImageView.contentMode =  .scaleToFill
         readDestroyImageView.backgroundColor = UIColor.clear
         return readDestroyImageView
     }()
    
    func setUpView(){
        self.backgroundColor = UIColor.colorGrayForChatBar
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.init(hexString: "#B2B2B2")
        self.addSubviews([self.lineView,self.displayImage,self.nicknameLabel,self.readDestroyImageView,self.desLabel,self.deleteBtn,bottomView,self.bottomLineView])
        
        self.lineView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(30)
            make.top.equalTo(self).offset(8)
            make.bottom.equalTo(self).offset(-10)
            make.width.equalTo(2)
        }
        
        self.displayImage.snp.makeConstraints { (make) in
            make.left.equalTo(self.lineView.snp.right).offset(2)
            make.size.equalTo(CGSize(width: 0, height: 0))
            make.centerY.equalTo(self)
        }
        
        self.deleteBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(0)
            make.size.equalTo(CGSize(width: 42, height: 42))
            make.centerY.equalTo(self)
        }
        
        self.nicknameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.displayImage.snp.right).offset(8)
//            make.right.equalTo(self.deleteBtn.snp.left).offset(-10)
            make.top.equalTo(self).offset(5)
            make.height.equalTo(20)
        }
        
        self.readDestroyImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.nicknameLabel.snp.right).offset(2)
            make.centerY.equalTo(self.nicknameLabel)
            make.width.height.equalTo(14.5)
        }
        
        self.desLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.displayImage.snp.right).offset(8)
            make.right.equalTo(self.deleteBtn.snp.left).offset(-10)
            make.top.equalTo(self.nicknameLabel.snp.bottom)
//            make.height.equalTo(20)
        }
        self.bottomLineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.height.equalTo(0.5)
            make.bottom.equalTo(self)
        }
    }
    //取消转发点击事件
    @objc func cancelMessageEidt() {
        if self.delegate != nil {
            self.delegate?.cancelTopMessage()
        }
    }
    @objc func tapAction() {
        if self.delegate != nil {
            self.delegate?.topViewAction(model: self.model ?? CODMessageModel())
        }
    }
}
