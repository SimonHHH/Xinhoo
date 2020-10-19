//
//  CustomBannerView.swift
//  COD
//
//  Created by xinhooo on 2020/3/9.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import PopupKit

class CustomBannerView: UIView, CODPopupViewType {

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    @IBOutlet weak var topCons: NSLayoutConstraint!
    
    var message: CODMessageModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headImageView.layer.cornerRadius = 30
        headImageView.clipsToBounds = true
        
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 12
 
        self.size = CGSize(width: kScreenWidth, height: 95 + self.cod_safeAreaInsets.top + UIApplication.shared.statusBarFrame.height)
        
        topCons.constant = 5 + self.cod_safeAreaInsets.top + UIApplication.shared.statusBarFrame.height
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeUpGestureRecognizer))
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClick))
        addGestureRecognizer(tap)
        
        self.popView.willStartDismissingCompletion = {
            PopupView.dismissAllPopups()
        }
        
    }
    
    @objc func onClick() {
        
        guard let message = message else {
            return
        }
        
        pushViewController(message: message)

    }
    
    func pushViewController(message: CODMessageModel) {
        
        var jid = ""
        if message.chatTypeEnum == .privateChat {
            jid = message.fromJID
        }else{
            jid = message.toJID
        }
        
        if let listModel = CODChatListRealmTool.getChatList(jid: jid) {
            
            let msgCtl = MessageViewController()
            msgCtl.newMessageCount = listModel.count
            
            switch listModel.chatTypeEnum {
            case .privateChat:
                msgCtl.chatType = .privateChat
                msgCtl.title = NSLocalizedString(listModel.title, comment: "")
                if let jid = listModel.contact?.jid {
                    msgCtl.toJID = jid
                }
                msgCtl.chatId = listModel.id
                msgCtl.isMute = listModel.contact!.mute
                
            case .groupChat:
                
                msgCtl.chatType = .groupChat
                msgCtl.roomId = String(format: "%d", (listModel.groupChat?.roomID) ?? 0)
                
                if (listModel.groupChat?.descriptions) != nil {
                    let groupName = listModel.groupChat?.descriptions
                    if let groupName = groupName, groupName.count > 0 {
                        msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
                    }else{
                        msgCtl.title = NSLocalizedString("群组", comment: "")
                    }
                }else{
                    msgCtl.title = NSLocalizedString("群组", comment: "")
                }
                
                if let groupChatTemp = listModel.groupChat {
                    msgCtl.toJID = String(groupChatTemp.jid)
                }
                msgCtl.chatId = listModel.id
                msgCtl.isMute = listModel.groupChat!.mute
                
            case .channel:
                
                msgCtl.chatType = .channel
                msgCtl.roomId = String(format: "%d", (listModel.channelChat?.roomID) ?? 0)
                msgCtl.channelModel = listModel.channelChat
                
                if (listModel.channelChat?.descriptions) != nil {
                    let groupName = listModel.channelChat?.descriptions
                    if let groupName = groupName, groupName.count > 0 {
                        msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
                    }else{
                        msgCtl.title = NSLocalizedString("频道", comment: "")
                    }
                }else{
                    msgCtl.title = NSLocalizedString("频道", comment: "")
                }
                
                if let channelChatTemp = listModel.channelChat {
                    msgCtl.toJID = String(channelChatTemp.jid)
                }
                msgCtl.chatId = listModel.id
                msgCtl.isMute = listModel.channelChat?.mute ?? false
            }
            
            if let nav = UIViewController.current()?.navigationController, UserManager.sharedInstance.isLogin == true {
                self.dismiss(animated: true)
                
                if nav.viewControllers.last?.isKind(of: MessageViewController.self) ?? false == true {
                    nav.navigationBar.isHidden = false
                    nav.setViewControllers([nav.viewControllers[0],msgCtl], animated: true)
                } else {
                    nav.pushViewController(msgCtl)
                }
                
            }
        }
    }

    
    @objc func onSwipeUpGestureRecognizer() {
        self.dismiss(animated: true)
        
    }
    
    func configMessage(message:CODMessageModel) {
        
        self.message = message
        
        switch message.chatTypeEnum {
        case .privateChat:
            
            if let contact = CODContactRealmTool.getContactByJID(by: message.fromJID) {
                titleLab.text = contact.getContactNick()
                if contact.rosterID == RobotRosterID {
                    self.headImageView.image = UIImage.helpIcon()
                }else{
                    let _ = self.headImageView.cod_loadHeaderByCache(url: URL(string: contact.icon.getHeaderImageFullPath(imageType: 1) ))
//                    CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: contact.icon) { (image) in
//                        self.headImageView.image = image
//                    }
                }
                
            }
            
            break
        case .channel:
            
            if let channel = CODChannelModel.getChannel(jid: message.toJID) {
                
                let imgText = NSTextAttachment()
                let img = UIImage(named: "chat_list_channel")!
                imgText.image = img
                imgText.bounds = CGRect(x: 0.0, y: -2.0, width: img.size.width, height: img.size.height)
                let imgAttri = NSAttributedString(attachment: imgText)
                
                titleLab.attributedText = imgAttri + " " + NSAttributedString(string: channel.getGroupName())
                
                let _ = self.headImageView.cod_loadHeaderByCache(url: URL(string: channel.icon.getHeaderImageFullPath(imageType: 1) ))
                
//                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: channel.icon) { (image) in
//                    self.headImageView.image = image
//                }
            }
            
            break
        case .groupChat:
            
            if let group = CODGroupChatRealmTool.getGroupChatByJID(by: message.toJID) {
                
                let imgText = NSTextAttachment()
                let img = UIImage(named: "group_chat_logo_img")!
                imgText.image = img
                imgText.bounds = CGRect(x: 0.0, y: -2.0, width: img.size.width, height: img.size.height)
                let imgAttri = NSAttributedString(attachment: imgText)
                
                titleLab.attributedText = imgAttri + " " + NSAttributedString(string: group.getGroupName())
                
                let _ = self.headImageView.cod_loadHeaderByCache(url: URL(string: group.icon.getHeaderImageFullPath(imageType: 1) ))
                
//                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: group.icon) { (image) in
//                    self.headImageView.image = image
//                }
            }
            
            break
        }
        
        contentLab.attributedText = configContentText(message: message)
        
    }
    
    func configContentText(message:CODMessageModel) -> NSAttributedString{
        
        var subTitleStr = NSAttributedString(string: "")
        var messageTypeStr = ""
                                                    
        switch message.type {
        case .image:
            messageTypeStr = NSLocalizedString("图片", comment: "")
            
            if message.photoModel?.descriptionImage != nil, message.photoModel?.descriptionImage.count != 0 {
                messageTypeStr = "🖼️" + (message.photoModel?.descriptionImage ?? "")
            }
            
        case .multipleImage:
            messageTypeStr = NSLocalizedString("多图", comment: "")
            
        case .audio:
            
            messageTypeStr = NSLocalizedString("[语音消息]", comment: "")
            
            if message.audioModel?.descriptionAudio != nil, message.audioModel?.descriptionAudio.count != 0 {
                messageTypeStr = "🎤" + (message.audioModel?.descriptionAudio ?? "")
            }
        case .video:
            
            messageTypeStr = NSLocalizedString("视频", comment: "")
            
            if message.videoModel?.descriptionVideo != nil, message.videoModel?.descriptionVideo.count != 0 {
                messageTypeStr = "📹" + (message.videoModel?.descriptionVideo ?? "")
            }
        case .voiceCall:
            
            messageTypeStr = NSLocalizedString("[语音通话]", comment: "")
        case .location:
            messageTypeStr = NSLocalizedString("[位置]", comment: "")
        case .file:
            
            messageTypeStr = message.fileModel?.filename ?? ""
            
            if message.fileModel?.descriptionFile != nil, message.fileModel?.descriptionFile.count != 0 {
                messageTypeStr = "📎" + (message.fileModel?.descriptionFile ?? "")
            }
        case .notification:
            messageTypeStr = message.text
        case .businessCard:
            messageTypeStr = NSLocalizedString("[联系人]", comment: "")
        case .videoCall:
            messageTypeStr = NSLocalizedString("[视频通话]", comment: "")
        case .gifMessage:
            messageTypeStr = CustomUtil.getEmojiName(emojiName: message.text)
            
        case .unknown:
            messageTypeStr = NSLocalizedString("[不支持的消息类型]", comment: "")
        default:
            messageTypeStr = message.text
        }
        
        switch message.type {
        case .image, .audio, .video, .voiceCall, .location, .businessCard, .videoCall, .gifMessage:
            let typeStrTemp = NSAttributedString(string: messageTypeStr).colored(with: UIColor(hexString: "8E8E92")!)
            
            subTitleStr = subTitleStr + typeStrTemp
        default:
            subTitleStr = subTitleStr + messageTypeStr
        }
        
        if message.type != .notification && message.chatTypeEnum == .groupChat{
            
            let memberId = CODGroupMemberModel.getMemberId(roomId: message.roomId, userName:message.fromWho)
            if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId){
                   
                let nameStr = NSAttributedString(string: "\(memberModel.getMemberNickName())\n")
                subTitleStr = nameStr + subTitleStr
            }
        }
        
        return subTitleStr
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
