//
//  CODMessageEditView.swift
//  COD
//
//  Created by 1 on 2019/7/23.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

protocol CODMessageEditViewDelegate:class {
    
    func cancelMessageEidt()
    func reloadImageMessageEidt()
    func clickEditView()

}
class CODMessageEditView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
        self.addTap {[weak self] in

            guard let `self` = self else {
                return
            }
            self.clickEditView()
        }
    }
    weak var delegate: CODMessageEditViewDelegate?
    var isCloudDisk: Bool = false
    
    
    func setCellContent(_ messageModel: CODMessageModel,isEdit: Bool = false,isTrans: Bool = false,isReply: Bool = false) {
        self.pictureEditBtn.isHidden = true
        self.videoImageView.isHidden  = true
        
        if isEdit {
            self.editMessage(messageModel)
            self.displayImage.isHidden = false
        }
        
        if messageModel.type == .multipleImage {
            pictureEditBtn.isHidden = true
        }
        
        if isTrans {
            self.transMessage(messageModel)
            self.displayImage.isHidden = true
            self.pictureEditBtn.isHidden = true
        }
        
        if isReply {
            self.replyMessage(messageModel)
            self.displayImage.isHidden = false
            self.pictureEditBtn.isHidden = true
            
        }
        
    }
    
    func checkMsgType(_ messageModel: CODMessageModel) -> Bool {
        
        let modelType = messageModel.type
        
        if  modelType == .image || modelType == .video || modelType == .gifMessage || modelType == .multipleImage {
            return true
        }
        
        return false

    }
    
    func setEidtImageView (_ messageModel: CODMessageModel) {

        if self.checkMsgType(messageModel) == false {
            return
        }
        
        self.dowloadImage(messageModel)
    }
    
    func dowloadImage(_ messageModel: CODMessageModel) {
        
        let modelType = messageModel.type
        self.displayImage.image = UIImage.init(named: "reply_loading_place")
        if modelType == .gifMessage {
            self.displayImage.image = UIImage.getGifImage(imageName: messageModel.text)
        } else {
            CODDownLoadManager.sharedInstance.downloadImage(type: .smallImage(messageModel: messageModel, isCloudDisk: self.isCloudDisk)) { [weak self] image in
                guard let `self` = self else { return }
                self.displayImage.image = image
                if image == nil {
                    self.displayImage.image = UIImage.init(named: "reply_fail_place")

                }
            }
        }
        
        if modelType == .video {
            self.videoImageView.isHidden  = false
        }
        
    }
    
    func setCellTransMessageContent(_ messageModels: [CODMessageModel]){
        self.pictureEditBtn.isHidden = true
        if messageModels.count == 1{
            let messageModel = messageModels[0]
            self.transMessage(messageModel)
            self.displayImage.isHidden = true
        }else{
            let messageModel = messageModels[0]
            
            //先判断是不是群组消息
            if messageModel.isGroupChat {
                
                //是群消息就去获取消息对应的群成员
                let memberId = CODGroupMemberModel.getMemberId(roomId: messageModel.roomId, userName: messageModel.fromWho)
                if let member = CODGroupMemberRealmTool.getMemberById(memberId) {
                    //如果成员存在，则去判断当前消息是不是来自于自己，是自己就去自己的昵称，不是自己就取群成员的昵称
                    self.nicknameLabel.text = messageModel.fromWho.contains(UserManager.sharedInstance.loginName!) ? UserManager.sharedInstance.nickname : member.getMemberNickName()
                }else{
                    //如果成员不存在，则直接取自己的昵称
                    self.nicknameLabel.text = UserManager.sharedInstance.nickname
                }
                
            }else{
                
                //不是群消息就判断当前消息是不是来自于自己
                if  messageModel.fromWho.contains(UserManager.sharedInstance.loginName!) {
                    self.nicknameLabel.text = UserManager.sharedInstance.nickname
                }else{
                    //消息不是来自自己，就去获取联系人，取联系人的昵称
                    if let contact = CODContactRealmTool.getContactByJID(by: messageModel.fromJID) {
                        self.nicknameLabel.text = contact.getContactNick()
                    }
                }
                
            }
            self.displayImage.snp.remakeConstraints { (make) in
                make.left.equalTo(self.lineView.snp.right).offset(2)
                make.size.equalTo(CGSize(width: 0, height: 0))
                make.centerY.equalTo(self)
            }
            
            self.desLabel.text = String(format: NSLocalizedString("%ld 条转发的消息", comment: ""), messageModels.count)
        }
        
    }
    
    //编辑
    func editMessage(_ messageModel: CODMessageModel) {
        self.displayImage.snp.remakeConstraints { (make) in
            make.left.equalTo(self.lineView.snp.right).offset(2)
            make.size.equalTo(CGSize(width: 0, height: 0))
            make.centerY.equalTo(self)
        }
        self.nicknameLabel.text = NSLocalizedString("已编辑的消息", comment: "")
        self.desLabel.text = messageModel.text
        var transString = ""
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: messageModel.msgType) ?? .text
        switch modelType {
        case .text:
            transString = messageModel.text.removeAllNewLineSpace
            break
        case .image:
            transString = "图片"
            break
        case .multipleImage:
            transString = "多图"
            break
        case .video:
            transString = "视频"
            break
        case .audio:
            transString = "语音"
            break
        case .file:
            transString = "文件"
            break
        case .gifMessage:
            
            transString = CustomUtil.getEmojiName(emojiName: messageModel.text)
            break
        default:
            transString = ""
        }
        self.desLabel.text = NSLocalizedString(transString, comment: "")
        
        if  self.checkMsgType(messageModel) {
            
            self.dowloadImage(messageModel)
            self.pictureEditBtn.isHidden = false
            
            self.displayImage.snp.remakeConstraints { (make) in
                make.left.equalTo(self.lineView.snp.right).offset(6)
                make.size.equalTo(CGSize(width: 35, height: 35))
                make.centerY.equalTo(self)
            }
        }else{
            self.pictureEditBtn.isHidden = true
            
            self.displayImage.snp.remakeConstraints { (make) in
                make.left.equalTo(self.lineView.snp.right).offset(2)
                make.size.equalTo(CGSize(width: 0, height: 0))
                make.centerY.equalTo(self)
            }
        }
        
    }
    //转发
    func transMessage(_ messageModel: CODMessageModel) {
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: messageModel.msgType) ?? .text
        
        var transString = ""
        
        switch modelType {
        case .text:
            
            transString = messageModel.text.removeAllNewLineSpace
            break
        case .image:
            transString = "1 张转发的图片"
            break
            
        case .multipleImage:
            transString = "1 组转发的图片"
            break
            
        case .audio:
            
            transString = "1 条转发的语音"
            break
        case .video:
            
            transString = "1 个转发的视频"
            break
        case .voiceCall:
            transString = "语音通话"
            //            transString = CustomUtil.getVideoChatContentString(messageModel: messageModel)
            break
        case .videoCall:
            transString = "视频通话"
            //            transString = CustomUtil.getVideoChatContentString(messageModel: messageModel)
            break
        case .location:
            
            transString = "1 个转发的位置"
            break
        case .businessCard:
            
            transString = "1 个转发的联系人"
            break
        case .file:
            transString = messageModel.fileModel?.filename ?? "1 个转发的文件"
            break
        case .gifMessage:
            
            transString = "1 个转发的表情"
            break
        default:
            transString = ""
        }
        
        //不是群消息就判断当前消息是不是来自于自己
        if  messageModel.fw.contains(UserManager.sharedInstance.loginName!) {
            self.nicknameLabel.text = UserManager.sharedInstance.nickname
        }else{
            //消息不是来自自己，就去获取联系人，取联系人的昵称
            if let contact = CODContactRealmTool.getContactByJID(by: messageModel.fw) {
                self.nicknameLabel.text = contact.getContactNick()
            }else{
                self.nicknameLabel.text = messageModel.fwn
            }
        }
        
        self.displayImage.snp.remakeConstraints { (make) in
            make.left.equalTo(self.lineView.snp.right).offset(2)
            make.size.equalTo(CGSize(width: 0, height: 0))
            make.centerY.equalTo(self)
        }
        
        //        self.nicknameLabel.text = messageModel.fwn
        self.desLabel.text = NSLocalizedString(transString, comment: "")
        
    }
    //回复
    func replyMessage(_ messageModel: CODMessageModel) {
        
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: messageModel.msgType) ?? .text
        
        var transString = ""
        
        switch modelType {
        case .text:
            
            transString = messageModel.text.removeAllNewLineSpace
            break
        case .image:
            
            transString = NSLocalizedString("图片", comment: "")
            break
            
        case .multipleImage:
            transString = NSLocalizedString("多图", comment: "")
            break
            
        case .audio:
            
            transString = NSLocalizedString("语音消息", comment: "")
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
        if  checkMsgType(messageModel) {
            self.dowloadImage(messageModel)
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
        //先判断是不是群组消息
        if messageModel.isGroupChat {
            
            //是群消息就去获取消息对应的群成员
            let memberId = CODGroupMemberModel.getMemberId(roomId: messageModel.roomId, userName: messageModel.fromWho)
            if let member = CODGroupMemberRealmTool.getMemberById(memberId) {
                //如果成员存在，则去判断当前消息是不是来自于自己，是自己就去自己的昵称，不是自己就取群成员的昵称
                self.nicknameLabel.text = messageModel.fromWho.contains(UserManager.sharedInstance.loginName!) ? UserManager.sharedInstance.nickname : member.getMemberNickName()
            }else{
                //如果成员不存在，则直接取自己的昵称
                self.nicknameLabel.text = UserManager.sharedInstance.nickname
            }
            
        }else{
            
            //不是群消息就判断当前消息是不是来自于自己
            if  messageModel.fromWho.contains(UserManager.sharedInstance.loginName!) {
                self.nicknameLabel.text = UserManager.sharedInstance.nickname
            }else{
                //消息不是来自自己，就去获取联系人，取联系人的昵称
                if let contact = CODContactRealmTool.getContactByJID(by: messageModel.fromJID) {
                    self.nicknameLabel.text = contact.getContactNick()
                }
            }
            
        }
        if modelType == .text || modelType == .gifMessage {
            
            self.desLabel.text = transString
        }else{
            
            self.desLabel.text = "[" + NSLocalizedString(transString, comment: "") + "]"
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
    public lazy var videoImageView:UIImageView = {
        let videoImg = UIImageView.init()
        videoImg.contentMode = .scaleAspectFill
        videoImg.image = UIImage.init(named: "eidt_video")
        videoImg.isHidden = true
        return videoImg;
    }()
    public lazy var desLabel:UILabel = {
        let desLb = UILabel(frame: CGRect.zero)
        desLb.font = UIFont.init(name: "PingFangSC-Regular", size: 14)
        desLb.textColor = UIColor.init(hexString: "#000000")
        desLb.numberOfLines = 1
        return desLb;
    }()
    
    public lazy var deleteBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "Input_field_delete"), for: .normal)
        btn.contentMode = .left
        btn.addTarget(self, action: #selector(cancelMessageEidt), for: .touchUpInside)
        return btn;
    }()
    
    public lazy var pictureEditBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "replace_eidt"), for: .normal)
        btn.contentMode = .left
        btn.addTarget(self, action: #selector(reloadImageMessageEidt), for: .touchUpInside)
        return btn;
    }()
    
}

private extension CODMessageEditView{
    
    func setUpView() {
        self.backgroundColor = UIColor.colorGrayForChatBar
        self.addSubviews([self.pictureEditBtn, self.lineView,self.displayImage,self.videoImageView,self.nicknameLabel,self.desLabel,self.deleteBtn])
        self.pictureEditBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.left.equalTo(self).offset(3)
            make.centerY.equalToSuperview()
        }
        
        self.lineView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(30)
            make.size.equalTo(CGSize(width: 2, height: 35))
            make.centerY.equalTo(self)
        }
        
        self.displayImage.snp.makeConstraints { (make) in
            make.left.equalTo(self.lineView.snp.right).offset(2)
            make.size.equalTo(CGSize(width: 0, height: 0))
            make.centerY.equalTo(self)
        }
        self.videoImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self.displayImage)
            make.height.width.equalTo(14)
        }
        
        self.deleteBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-35)
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.top.equalTo(self)
        }
        
        self.nicknameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.displayImage.snp.right).offset(8)
            make.right.equalTo(self.deleteBtn.snp.left).offset(-10)
            make.top.equalTo(self.lineView)
        }
        
        self.desLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.nicknameLabel)
            make.bottom.equalTo(self.lineView)
        }
    }
    
    //取消转发点击事件
    @objc func cancelMessageEidt() {
        if self.delegate != nil {
            self.delegate?.cancelMessageEidt()
        }
    }
    
    //取消转发点击事件
    @objc func reloadImageMessageEidt() {
        if self.delegate != nil {
            self.delegate?.reloadImageMessageEidt()
        }
    }
    
    //取消转发点击事件
    @objc func clickEditView() {
        if self.delegate != nil {
            self.delegate?.clickEditView()
        }
    }
    
}
