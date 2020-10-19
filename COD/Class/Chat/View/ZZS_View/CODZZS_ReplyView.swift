//
//  CODZZS_ReplyView.swift
//  COD
//
//  Created by xinhooo on 2019/7/31.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODZZS_ReplyView: UIView {

    
    @IBOutlet weak var rpLineView: UIView!
    @IBOutlet weak var rpImageView: FLAnimatedImageView!
    @IBOutlet weak var rpNameLab: YYLabel!
    @IBOutlet weak var rpContentLab: YYLabel!
    @IBOutlet weak var rpLeadingCos: NSLayoutConstraint!
    @IBOutlet weak var rpContentBottomCos: NSLayoutConstraint!
    var isCloudDisk = false
    
    func configModel(model:CODMessageModel, indexPath: IndexPath?, pageVM: CODChatMessageDisplayPageVM?) {
        
        
        let nameColor = (model.fromWho.contains(UserManager.sharedInstance.loginName!) && model.chatTypeEnum != .channel) ? UIColor.init(hexString: "54A044") : UIColor.init(hexString: kBlueTitleColorS)
        
        let contentColor = (model.fromWho.contains(UserManager.sharedInstance.loginName!) && model.chatTypeEnum != .channel) ? UIColor.init(hexString: "54A044") : UIColor.init(hexString: "999999")
        
        let lineColor = (model.fromWho.contains(UserManager.sharedInstance.loginName!) && model.chatTypeEnum != .channel) ? UIColor.init(hexString: "63C93E") : UIColor.init(hexString: kBlueTitleColorS)
        
        self.rpContentLab.font = UIFont.systemFont(ofSize: 14)
        self.rpNameLab.font = UIFont.init(name: "PingFang-SC-Medium", size: 14)
        self.rpNameLab.lineBreakMode = .byClipping
        
        self.rpNameLab.textColor = nameColor
        self.rpLineView.backgroundColor = lineColor
        
        if model.rp.count > 0 && model.rp != "0" {
            
            if let message = try! Realm.init().object(ofType: CODMessageModel.self, forPrimaryKey: model.rp) {
                
                if message.isDelete {
                    
                    self.configDeleteTip(textColor: nameColor)
                    
                }else{
                    var text = ""
                    self.rpContentLab.textColor = contentColor
                    
                    self.rpLeadingCos.constant = 8
                    self.rpImageView.isHidden = true
                    let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: message.msgType) ?? .text
                    switch modelType {
                    case .gifMessage:
                        text = CustomUtil.getEmojiName(emojiName: message.text)
//                        self.rpContentLab.textColor = UIColor.init(hexString: "000000")
                        self.rpLeadingCos.constant = 48
                        self.rpImageView.isHidden = false
                        self.rpImageView.setGifImage(identifier: message.text)
                        break
                    case .text:
                        text = message.text
                        self.rpContentLab.textColor = UIColor.init(hexString: "000000")
                        break
                        
                    case .multipleImage:
                        text = "多图"
                        self.rpLeadingCos.constant = 48
                        self.rpImageView.isHidden = false
                        if let photoInfo = message.imageList.first, let image = CODImageCache.default.smallImageCache?.imageFromCache(forKey: photoInfo.photoLocalURL) {
                            self.rpImageView.image = image
                        } else {
                            CODDownLoadManager.sharedInstance.downloadImage(type: .smallImage(messageModel: message, isCloudDisk: self.isCloudDisk)) { [weak self] (image) in
                                self?.rpImageView.image = image ?? CustomUtil.getPictureLoadFailImage()
                            }
                        }
                        
                    case .image:
                        text = "图片"
                        self.rpLeadingCos.constant = 48
                        self.rpImageView.isHidden = false
                        if let imageData = message.photoModel?.photoImageData {
                            self.rpImageView.image = UIImage.init(data: imageData)
                        } else if let key = message.getFirstImageCacheKey(), key.isEmpty != false, let localImage = CODImageCache.default.smallImageCache?.imageFromCache(forKey: key) {
                            self.rpImageView.image = localImage
                        } else{
                            CODDownLoadManager.sharedInstance.downloadImage(type: .smallImage(messageModel: message, isCloudDisk: self.isCloudDisk)) { [weak self] (image) in
                                self?.rpImageView.image = image ?? CustomUtil.getPictureLoadFailImage()
                            }
                        }
                        break
                    case .video:
                        text = "视频"
                        self.rpLeadingCos.constant = 48
                        self.rpImageView.isHidden = false
                        
                        CustomUtil.loadSmallImage(from: message.videoModel, isCloudDisk: self.isCloudDisk) { [weak self] (image) in
                            guard let image = image else {
                                self?.rpImageView.image = CustomUtil.getPictureLoadFailImage()
                                return
                            }
                            
                            self?.rpImageView.image = image
                        }

                        break
                    case .audio:
                        text = "语音"
                        break
                    case .voiceCall:
                        text = "语音通话"
                        break
                    case .videoCall:
                        text = "视频通话"
                    case .location:
                        text = "位置"
                        break
                    case .file:
                        text = message.fileModel?.filename ?? ""
                        break
                    case .notification:
                        text = "通知"
                        break
                    case .haveRead:
                        break
                    case .businessCard:
                        text = "联系人"
                        break
                    case .newMessage:
                        break
                    case .unknown:
                        //TODO: 未知消息类型
                        break
                    }
                    self.rpContentLab.text = NSLocalizedString(text.removeAllNewLineSpace, comment: "")
                    
                    switch message.chatTypeEnum {
                    case .channel:
                        if let channel = CODChannelModel.getChannel(by: message.roomId) {
                            self.rpNameLab.text = channel.descriptions
                        }else{
                            self.rpNameLab.text = NSLocalizedString("频道", comment: "")
                        }
                        break
                    case .groupChat:
                        //是群消息就去获取消息对应的群成员
                        var jid = ""
                        if message.fromWho.contains(XMPPSuffix) {
                            jid = message.fromWho
                        }else{
                            jid = message.fromWho + XMPPSuffix
                        }
                        
                        if let member = CODGroupMemberRealmTool.getMemberById(CODGroupMemberRealmTool.getMemberId(roomId: model.roomId, jid: jid)) {
                            //如果成员存在，则去判断当前消息是不是来自于自己，是自己就去自己的昵称，不是自己就取群成员的昵称
                            self.rpNameLab.text = message.fromWho.contains(UserManager.sharedInstance.loginName!) ? UserManager.sharedInstance.nickname : member.getMemberNickName()
                        }else{
                            //如果成员不存在，则直接取自己的昵称
                            self.rpNameLab.text = UserManager.sharedInstance.nickname
                        }
                        break
                    case .privateChat:
                        //不是群消息就判断当前消息是不是来自于自己
                        if  message.fromWho.contains(UserManager.sharedInstance.loginName!) {
                            self.rpNameLab.text = UserManager.sharedInstance.nickname
                        }else{
                            //消息不是来自自己，就去获取联系人，取联系人的昵称
                            if let contact = CODContactRealmTool.getContactByJID(by: message.fromJID) {
                                self.rpNameLab.text = contact.getContactNick()
                            }
                        }
                        break

                    }
                    
                    self.rpContentBottomCos.constant = 2
                    self.rpNameLab.isHidden = false
                }
                
                
                
            }else{

                CODMessageRealmTool.getRemoteMessageByMsgId(msgId: model.rp) { [weak self] (model) in
                    guard let `self` = self else{
                        return
                    }
                    guard let model = model else {
                        self.configDeleteTip(textColor: nameColor)
                        return
                    }
                    
                    if let indexPath = indexPath {
                        pageVM?.editMessageBR.accept(indexPath)
                    }
                    
                    
                }
            }
            
        }else{
            self.rpContentLab.text = ""
            self.rpNameLab.text = ""
        }
        
        
    }
    
    func configDeleteTip(textColor: UIColor?) {
        self.rpContentLab.text = "该消息已被删除"
        self.rpContentLab.font = UIFont.init(name: "PingFangSC-Regular", size: 16)
        self.rpContentLab.textColor = textColor
        self.rpNameLab.text = ""
        self.rpContentBottomCos.constant = -5
        self.rpNameLab.isHidden = true
        self.rpLeadingCos.constant = 8
        self.rpImageView.isHidden = true
    }
    
    func clear() {
        self.rpContentLab.text = ""
        self.rpNameLab.text = ""
        self.rpLeadingCos.constant = 0
        self.rpContentBottomCos.constant = 0
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
