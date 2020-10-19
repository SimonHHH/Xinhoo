//
//  ChatListCell.swift
//  COD
//
//  Created by XinHoo on 2019/2/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwipeCellKit

extension Reactive where Base: ChatListCell {
    
    var onlinePointBinder: Binder<Void> {
        return Binder(self.base) { (cell, _) in
            cell.onlinePointImageView.isHidden = true
            if cell._model.isInvalidated == false, let contact = cell._model.contact {
                if contact.loginStatus.contains("ONLINE", caseSensitive: false) {
                    cell.onlinePointImageView.isHidden = false
                }else{
                    cell.onlinePointImageView.isHidden = true
                }
            }
        }
    }
    
}

class ChatListCell: SwipeTableViewCell {
    
    var _model:CODChatListModel!
    
    var _resultModel:CODSearchResultMessageModel!
    
    var downloadToken: SDWebImageDownloadToken?
    
    var stickyTop: Bool = false {
        didSet{
            if stickyTop {
                self.backgroundColor = UIColor.init(hexString: kVCBgColorS)
            }else{
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var onlinePointImageView: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var subTitleLab: UILabel!
    @IBOutlet weak var lastTimeLab: UILabel!
    @IBOutlet weak var burnImageView: UIImageView!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupImgCos: NSLayoutConstraint!
    
    @IBOutlet weak var msgCountBtn: UIButton!
    @IBOutlet weak var countTipCos: NSLayoutConstraint!
    @IBOutlet weak var isReadImageView: UIImageView!
    @IBOutlet weak var muteImageView: UIImageView!

    @IBOutlet weak var stickyTopImgV: UIImageView!
    @IBOutlet weak var atWidthCos: NSLayoutConstraint!
    @IBOutlet weak var atBtn: UIButton!
    
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var bottomLineLeftCos: NSLayoutConstraint!
    
    let lastMsg :CODMessageModel! = nil
    
    var _imgName :String?
    var _title :String?
    var _subTitle :String?
    var _time :String?
    
    var headerView: UIImage? {
        didSet{
            imgView.image = headerView
        }
    }
    
    var isLast: Bool = false {
        didSet{
            bottomLineLeftCos.constant = isLast ? 0.0 : 80.0
        }
    }
    
    
    var imgName: String {
        get {
            return _imgName!
        }
        set {
            _imgName = newValue
//            imgView.sd_setImage(with: URL.init(string: _imgName ?? ""), placeholderImage: UIImage.init(named: "default_header_110"))
//            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: _imgName!) { (image) in
//                self.imgView?.image = image
//            }
            
            
            downloadToken = self.imgView.cod_loadHeaderByCache(url: URL(string: _imgName?.getHeaderImageFullPath(imageType: 1) ?? ""))
            
        }
    }
    
//    override class func awakeFromNib() {
//        super.awakeFromNib()
//        self.robotIcon1.fd_collapsed = true
//        self.robotIcon2.fd_collapsed = true
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadToken?.cancel()
    }
    
    var title: String {
        get {
            return _title ?? ""
        } set {
            _title = newValue
            if _title == "\(kApp_Name)小助手", let title = _title {
                let attriStr = NSMutableAttributedString.init(string: CustomUtil.formatterStringWithAppName(str: "%@小助手"))
                let textAttachment = NSTextAttachment.init()
                let img = UIImage(named: "cod_helper_sign")
                textAttachment.image = img
                textAttachment.bounds = CGRect.init(x: 0, y: 0, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
                let attributedString = NSAttributedString.init(attachment: textAttachment)
                attriStr.append(attributedString)
                self.titleLab.attributedText = attriStr
            }else{
                self.titleLab.text = _title
            }
        }
    }
    
    var time: String {
        get {
            return _time!
        }
        set {
            _time = newValue
            
            if _time?.count ?? 0 > 0, let timeD =  Double(_time ?? "0") ,timeD > 0 {
                self.lastTimeLab.text = TimeTool.getTimeStringAutoShort2(Date.init(timeIntervalSince1970:(timeD)/1000), mustIncludeTime: false, theOffSetMS: UserManager.sharedInstance.timeStamp)
            }else{
                self.lastTimeLab.text = " "
            }
        }
    }
    
    var model: CODChatListModel? {
        get {
            return _model
        }
        set {
            _model = newValue
            
            guard let _model = _model else{
                return
            }
            
            if _model.referToMessageID.count > 0 {
                self.atWidthCos.constant = 20
            }else{
                self.atWidthCos.constant = 0
            }
            
            self.stickyTopImgV.isHidden = !_model.stickyTop
            
            if _model.groupRtc == 0 {
                
                self.stickyTopImgV.image = UIImage(named: "stickytop")
                
            } else if _model.groupRtc == 1 {
                
                self.stickyTopImgV.isHidden = false
                
                if  CustomUtil.getRoomJid() == _model.jid {
                    
                    self.stickyTopImgV.image = UIImage(named: "group_calling_icon_join")
                }else{
                    
                    self.stickyTopImgV.image = UIImage(named: "group_calling_icon")
                }
            }
            
            let count = _model.count
            
            if count > 0 {
                self.stickyTopImgV.isHidden = true
            }
            
            if count == 0 {
                self.countTipCos.constant = 0
            }
            
            if count > 0 && count < 10 {
                self.countTipCos.constant = 20
            }
            
            if count >= 10 && count < 100 {
                self.countTipCos.constant = 25
            }
            
            if count >= 100 && count < 1000 {
                self.countTipCos.constant = 30
            }
            
            self.msgCountBtn.titleLabel?.text = _model.count.string
            self.msgCountBtn.setTitle(_model.count.string, for: .normal)
            
            if count >= 1000 {
                self.countTipCos.constant = 30
                let k = count / 1000
                self.msgCountBtn.titleLabel?.text = "\(k)K"
                self.msgCountBtn.setTitle("\(k)K", for: .normal)
            }
            
            if _model.id == NewFriendRosterID {
                
                self.time = _model.lastDateTime
                var nameStr = NSAttributedString(string: _model.title)
                nameStr = nameStr.colored(with: UIColor(hexString: "222222")!)
                self.subTitleLab.attributedText =  nameStr + NSAttributedString(string:"\n" + _model.subTitle)
                self.groupImgCos.constant = 0
                self.burnImageView.image = nil
                self.muteImageView.isHidden = !UserManager.sharedInstance.xhnfmute
                self.stickyTopImgV.isHidden = !UserManager.sharedInstance.xhnfsticktop
                if count > 0 {
                    self.stickyTopImgV.isHidden = true
                }
                self.onlinePointImageView.isHidden = true
                
                if UserManager.sharedInstance.xhnfmute {
                    self.msgCountBtn.backgroundColor = UIColor.init(hexString: "#B6B6BB")
                }else{
                    self.msgCountBtn.backgroundColor = UIColor(red: 0, green: 147, blue: 234)
                }
//                self.msgCountBtn.backgroundColor = UIColor(red: 0, green: 147, blue: 234)
                return
            }
            
            var subTitleStr = NSAttributedString(string: "")
            var readedimgName: String?
            
            let lastMessageModel = _model.chatHistory?.messages.sorted(byKeyPath: "datetime", ascending: true).last
            let noDeleteLastMessageModel = _model.chatHistory?.messages.filter("isDelete == false").sorted(byKeyPath: "datetime", ascending: true).last
            if let noDeleteLastMessageModel = noDeleteLastMessageModel {
                self.time = noDeleteLastMessageModel.datetime
            }else{
                self.time = " "
            }
            
            
            
            self.onlinePointImageView.isHidden = true
            if let contact = _model.contact {
                if contact.loginStatus.contains("ONLINE", caseSensitive: false) {
                    self.onlinePointImageView.isHidden = false
                }else{
                    self.onlinePointImageView.isHidden = true
                }
            }
            
            NotificationCenter.default.rx.notification(NSNotification.Name.init(kXMPPPresenceNoti))
                .mapTo(Void())
                .bind(to: rx.onlinePointBinder)
                .disposed(by: self.rx.prepareForReuseBag)

            
            var isShowBurned = false

            if _model.subTitle.count > 0 && _model.editMessage == nil {
                var str = NSAttributedString(string: NSLocalizedString("[草稿]\n", comment: ""))
                str = str.colored(with: UIColor(hexString: kRedTextForLimitColorS)!)
                self.subTitleLab.attributedText = str + NSAttributedString(string: _model.subTitle)
                
            }else{

                
                if var messageModel = lastMessageModel {
                    
                    if messageModel.isDelete == true && messageModel.burn > 0 && messageModel.isReadedDestroy{
                        isShowBurned = true
                    }
                    
                    if isShowBurned || _model.isShowBurned {
                        let imgText = NSTextAttachment()
                        let img = UIImage(named: "chat_list_burn_icon")!
                        imgText.image = img
                        imgText.bounds = CGRect(x: 0.0, y: -2.0, width: img.size.width, height: img.size.height)
                        let imgAttri = NSAttributedString(attachment: imgText)
                        subTitleStr = subTitleStr + imgAttri
                        subTitleStr = subTitleStr + NSLocalizedString("消息已焚烧", comment: "")
                        
                        self.subTitleLab.attributedText = subTitleStr
                        
                    }else{
                        
                        if let nodeleteModel = noDeleteLastMessageModel {
                            messageModel = nodeleteModel
                            if messageModel.fromWho.contains(UserManager.sharedInstance.loginName ?? ""){
                                if messageModel.chatTypeEnum == .channel {
                                    
                                    switch messageModel.status {
                                    case CODMessageStatus.Failed.rawValue:
                                        readedimgName = "chat_list_failure"
                                    case CODMessageStatus.Pending.rawValue:
                                        readedimgName = "chat_list_pending"
                                    default:
                                        readedimgName = nil
                                    }
                                    
                                }else{
                                    switch messageModel.status {
                                    case CODMessageStatus.Succeed.rawValue:
                                        if messageModel.isReaded {
                                            readedimgName = "list_blue_Haveread"
                                        } else {
                                            readedimgName = "list_blue"
                                        }
                                        if _model.lastReadTime.int ?? 0 >= messageModel.datetime.int ?? 0 {
                                            readedimgName = "list_blue_Haveread"
                                        }
                                    case CODMessageStatus.Failed.rawValue:
                                        readedimgName = "chat_list_failure"
                                    case CODMessageStatus.Pending.rawValue:
                                        readedimgName = "chat_list_pending"
                                    default:
                                        readedimgName = nil
                                    }
                                }
                                
                            } else {
                                readedimgName = nil
                            }
                            
                            var messageTypeStr = ""
                            
                            switch messageModel.type {
                            case .image:
                                messageTypeStr = NSLocalizedString("图片", comment: "")
                                
                                if messageModel.photoModel?.descriptionImage != nil, messageModel.photoModel?.descriptionImage.count != 0 {
                                    messageTypeStr = "🖼️" + (messageModel.photoModel?.descriptionImage ?? "")
                                }
                                
                            case .multipleImage:
                                messageTypeStr = NSLocalizedString("多图", comment: "")

                            case .audio:
                                
                                messageTypeStr = NSLocalizedString("[语音消息]", comment: "")
                                
                                if messageModel.audioModel?.descriptionAudio != nil, messageModel.audioModel?.descriptionAudio.count != 0 {
                                    messageTypeStr = "🎤" + (messageModel.audioModel?.descriptionAudio ?? "")
                                }
                            case .video:
                                
                                messageTypeStr = NSLocalizedString("视频", comment: "")
                                
                                if messageModel.videoModel?.descriptionVideo != nil, messageModel.videoModel?.descriptionVideo.count != 0 {
                                    messageTypeStr = "📹" + (messageModel.videoModel?.descriptionVideo ?? "")
                                }
                            case .voiceCall:
                                
                                messageTypeStr = NSLocalizedString("[语音通话]", comment: "")
                            case .location:
                                messageTypeStr = NSLocalizedString("[位置]", comment: "")
                            case .file:
                                //                            messageTypeStr = NSLocalizedString("[文件]", comment: "")
                                messageTypeStr = messageModel.fileModel?.filename ?? ""
                                
                                if messageModel.fileModel?.descriptionFile != nil, messageModel.fileModel?.descriptionFile.count != 0 {
                                    messageTypeStr = "📎" + (messageModel.fileModel?.descriptionFile ?? "")
                                }
                            case .notification:
                                
                                messageTypeStr = NSLocalizedString(messageModel.text, comment: "")
                                readedimgName = nil
                            case .businessCard:
                                messageTypeStr = NSLocalizedString("[联系人]", comment: "")
                            case .videoCall:
                                messageTypeStr = NSLocalizedString("[视频通话]", comment: "")
                            case .gifMessage:
                                messageTypeStr = CustomUtil.getEmojiName(emojiName: messageModel.text)
                                
                            case .unknown:
                                messageTypeStr = NSLocalizedString("[不支持的消息类型]", comment: "")
                            default:
                                messageTypeStr = messageModel.text
                            }
                            
                            switch messageModel.type {
                            case .image, .audio, .video, .voiceCall, .location, .businessCard, .videoCall, .gifMessage:
                                let typeStrTemp = NSAttributedString(string: messageTypeStr).colored(with: UIColor(hexString: "8E8E92")!)
                                
                                subTitleStr = subTitleStr + typeStrTemp
                            default:
                                subTitleStr = subTitleStr + messageTypeStr
                            }
                            
                            if messageModel.type != .notification {  //通知类消息不显示“某某”：
                                if _model.chatTypeEnum == .groupChat {
                                    
                                    let memberId = CODGroupMemberModel.getMemberId(roomId: messageModel.roomId, userName:messageModel.fromWho)
                                    if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId){
                                        var nameStr:NSAttributedString = NSAttributedString(string:"")
                                        if !memberModel.jid.contains(UserManager.sharedInstance.loginName!){
                                            nameStr = NSAttributedString(string: "\(memberModel.getMemberNickName())\n")
                                        }else{
                                            nameStr = NSAttributedString(string: "\(NSLocalizedString("您", comment: ""))\n")
                                        }
                                        nameStr = nameStr.colored(with: UIColor(hexString: "222222")!)
                                        subTitleStr = nameStr + subTitleStr
                                        self.subTitleLab.attributedText = subTitleStr
                                    }
                                }
                            }
                            
                            self.subTitleLab.attributedText = subTitleStr
                            
                        }else{
                            self.subTitleLab.attributedText = NSAttributedString(string: " ")
                        }
                    }
                    
                }else{
                    if _model.isShowBurned || isShowBurned {
                        let imgText = NSTextAttachment()
                        let img = UIImage(named: "chat_list_burn_icon")!
                        imgText.image = img
                        imgText.bounds = CGRect(x: 0.0, y: -2.0, width: img.size.width, height: img.size.height)
                        let imgAttri = NSAttributedString(attachment: imgText)
                        subTitleStr = subTitleStr + imgAttri
                        subTitleStr = subTitleStr + NSLocalizedString("消息已焚烧", comment: "")
                        
                    }else{
                        self.subTitleLab.attributedText = NSAttributedString(string: " ")
                    }
                }
            }
            
            let pragraphStyle = NSMutableParagraphStyle()
            pragraphStyle.lineSpacing = 2
            let mutableAttStr = NSMutableAttributedString.init(attributedString: self.subTitleLab.attributedText!)
            mutableAttStr.addAttributes([NSAttributedString.Key.paragraphStyle : pragraphStyle], range: NSRange.init(location: 0, length: mutableAttStr.length))
            self.subTitleLab.attributedText = mutableAttStr
            self.subTitleLab.lineBreakMode = .byTruncatingTail
            
            if let readedimgName = readedimgName {
                
                let img = UIImage(named: readedimgName)
                self.isReadImageView.image = img
                self.isReadImageView.isHidden = false
            }else{
                
                self.isReadImageView.isHidden = true
            }
            
            var mute = false
            switch _model.chatTypeEnum {
            case .channel:
                //TODO: 频道对应处理
                self.groupImageView.image = UIImage.init(named: "chat_list_channel")
                self.groupImgCos.constant  = 16.5
                if let channelChat = _model.channelChat {
                    self.burnImageView.image = (channelChat.burn.int ?? 0 > 0) ? UIImage.init(named: "readed_del_icon") : UIImage.init(named: "")
                    mute = channelChat.mute
                }else{
                    self.burnImageView.image = UIImage.init(named: "")
                }
            case .groupChat:
                self.groupImageView.image = UIImage.init(named: "group_chat_logo_img")
                self.groupImgCos.constant  = 16.5
                if let groupModel = _model.groupChat {
                    self.burnImageView.image = (groupModel.burn.int ?? 0 > 0) ? UIImage.init(named: "readed_del_icon") : UIImage.init(named: "")
                    mute = groupModel.mute
                }else{
                    self.burnImageView.image = UIImage.init(named: "")
                }
            case .privateChat:
                
                
                if let contactModel = _model.contact {
                    
                    if contactModel.userTypeEnum == .bot {
                        groupImageView.image = UIImage(named: "chat_list_robot")
                        self.groupImgCos.constant = 16.5
                    } else {
                        self.groupImageView.image = UIImage.init(named: "")
                        self.groupImgCos.constant = 0.0
                    }
                    
                    self.burnImageView.image = (contactModel.burn == 0) ? UIImage.init(named: "") : UIImage.init(named: "readed_del_icon")
                    mute = contactModel.mute
                }else{
                    self.burnImageView.image = UIImage.init(named: "")
                    self.groupImageView.image = UIImage.init(named: "")
                    self.groupImgCos.constant = 0.0
                }

            }
            

            self.muteImageView.isHidden = !mute
            
            
            
            if mute {
                self.msgCountBtn.backgroundColor = UIColor.init(hexString: "#B6B6BB")
            }else{
                self.msgCountBtn.backgroundColor = UIColor(red: 0, green: 147, blue: 234)
            }
            
            
            
        }
    }
    
    var resultMessageModel: CODSearchResultMessageModel? {
        get {
            return _resultModel
        }
        set {
            _resultModel = newValue
            
            guard let _model = _resultModel else{
                return
            }
            var subTitleStr = NSAttributedString(string: "")
            var readedimgName: String?
            
            let messageModel = _model.message

            
            if let messageModel = messageModel {
                if messageModel.fromWho.contains(UserManager.sharedInstance.loginName ?? ""){
                    if messageModel.status == CODMessageStatus.Succeed.rawValue {
                        if messageModel.isReaded {
                            readedimgName = "list_blue_Haveread"
                        } else {
                            readedimgName = "list_blue"
                        }
                    } else {
                        readedimgName = nil
                    }
                    
                } else {
                    readedimgName = nil
                }
                
                if messageModel.type == .file {
                    let fileName = messageModel.fileModel?.filename ?? ""
                    subTitleStr = subTitleStr + fileName
                }else{
                    subTitleStr = subTitleStr + messageModel.text
                }
                
                
                if _model.chatType == .channel || _model.chatType == .groupChat {
                    let memberId = CODGroupMemberModel.getMemberId(roomId: messageModel.roomId, userName:messageModel.fromWho)
                    if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId){
                        if !memberModel.jid.contains(UserManager.sharedInstance.loginName!){
                            var nameStr = NSAttributedString(string: "\(memberModel.getMemberNickName())\n")
                            nameStr = nameStr.colored(with: UIColor(hexString: "222222")!)
                            subTitleStr = nameStr + subTitleStr
                            self.subTitleLab.attributedText = subTitleStr
                        }
                    }
                }
                self.subTitleLab.attributedText = subTitleStr
                self.time = messageModel.datetime
            }else{
                self.subTitleLab.attributedText = NSAttributedString(string: " ")
                self.time = _model.lastDateTime
            }
            
            
            if let readedimgName = readedimgName {
                
                let img = UIImage(named: readedimgName)
                self.isReadImageView.image = img
                self.isReadImageView.isHidden = false
            }else{
                
                self.isReadImageView.isHidden = true
            }
            
            var mute:Bool?
            switch _model.chatType {
            case .channel:
                self.groupImageView.image = UIImage.init(named: "chat_list_channel")
                self.groupImgCos.constant = 16.5
                self.burnImageView.image = UIImage.init(named: "")
                if let channel = _model.channelChat {
                    mute = channel.mute
                }
            case .privateChat:
                
                if let contactModel = _model.contact {
                    
                    if contactModel.userTypeEnum == .bot {
                        groupImageView.image = UIImage(named: "chat_list_robot")
                        self.groupImgCos.constant = 16.5
                    } else {
                        self.groupImageView.image = UIImage.init(named: "")
                        self.groupImgCos.constant = 0.0
                    }
                    
                    self.burnImageView.image = (contactModel.burn == 0) ? UIImage.init(named: "") : UIImage.init(named: "readed_del_icon")
                    mute = contactModel.mute
                }else{
                    self.burnImageView.image = UIImage.init(named: "")
                    self.groupImageView.image = UIImage.init(named: "")
                    self.groupImgCos.constant = 0.0
                }
            case .groupChat:
                self.groupImageView.image = UIImage.init(named: "group_chat_logo_img")
                self.groupImgCos.constant = 16.5
                if let groupModel = _model.groupChat {
                    self.burnImageView.image = (groupModel.burn.int ?? 0 > 0) ? UIImage.init(named: "readed_del_icon") : UIImage.init(named: "")
                    mute = groupModel.mute
                }else{
                    self.burnImageView.image = UIImage.init(named: "")
                }
            }
            
            self.muteImageView.isHidden = !(mute ?? false)
            
            self.stickyTopImgV.isHidden = true
            
            self.countTipCos.constant = 0
            
            if mute ?? false {
                self.msgCountBtn.backgroundColor = UIColor.init(hexString: "#B6B6BB")
            }else{
                self.msgCountBtn.backgroundColor = UIColor(red: 0, green: 147, blue: 234)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    

    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        var colors: [UIView:UIColor] = [:]
        for view in self.contentView.subviews {
            colors[view] = view.backgroundColor
        }
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            for view in self.contentView.subviews {
                view.backgroundColor = colors[view]
            }
        }
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        var colors: [UIView:UIColor] = [:]
//        for view in subviews {
//            colors[view] = view.backgroundColor
//        }
//        super.setSelected(selected, animated: animated)
//        if selected {
//            for view in subviews {
//                view.backgroundColor = colors[view]
//            }
//        }
//    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}


