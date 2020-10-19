//
//  CODBaseChatCell.swift
//  COD
//
//  Created by 1 on 2019/3/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import ActiveLabel
import RxSwift
import RxCocoa

public let IMChatTimeLabelMarginTop: CGFloat = 10   //顶部 10 px
public let IMChatTimeLabelPaddingTop: CGFloat = 3   //上下分别留出3像素的留白
public let IMChatTimeLabelMaxWdith : CGFloat = UIScreen.main.bounds.size.width - 30 * 2
public let IMChatTimeLabelPaddingLeft: CGFloat = 6   //左右分别留出6像素的留白

public let IMChatAvatarMarginLeft: CGFloat = 3             //头像的 margin left
public let IMChatAvatarMarginTopBottom: CGFloat = 0        //头像的 margin top
public let IMChatAvatarMarginBottom: CGFloat = 8       //头像的 margin Bottom

public let IMChatAvatarWidth: CGFloat = 38                  //头像的宽度和高度
public let IMChatReplyHeight: CGFloat = 34                  //回复文本的高度

class CODBaseChatCell: CODZZS_BaseTableViewCell {
    
    weak var pageVM: CODChatMessageDisplayPageVM?
    var indexPath: IndexPath?
    
    var downloadToken: SDWebImageDownloadToken?
    
    
    func setCellContent(_ model: CODMessageModel,isShowName:Bool,isCloudDisk: Bool = false) {
        self.messageModel = model
        self.isCloudDisk = isCloudDisk
        self.rpContentView.isCloudDisk = isCloudDisk
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: self.messageModel.msgType) ?? .text
        
        if modelType == .text || modelType == .businessCard || modelType == .file{
            self.isShowName = isShowName
        }else{
            self.isShowName = false
        }
      self.nicknameLabel.isHidden = !isShowName
        let fromWho = messageModel.fromWho
        let me = UserManager.sharedInstance.loginName
        if !fromWho.contains(me!) {
            self.fromMe = false
        }else{
            self.fromMe = true
        }
        if self.isCloudDisk {
            self.isShowName = true
            if !self.fromMe{
                self.showType = .HeadAndPart
            }
        }
        if model.isGroupChat && !self.fromMe {
            if let memberModelList = CODGroupMemberRealmTool.getMembersByJid(self.messageModel.fromJID) {
                self.nicknameLabel.textColor = UIColor.init(hexString: memberModelList.first!.color)
            }else if let contact = CODContactRealmTool.getContactByJID(by: self.messageModel.fromJID) {
                self.nicknameLabel.textColor = UIColor.init(hexString: contact.color)
            }else{
                self.nicknameLabel.textColor = UIColor.init(hexString: kEmptyTitleColorS)
            }
        }
        if self.showType == .HeadAndPart || self.showType == .Part {
            if self.showType == .HeadAndPart {
                self.bubbleGap = 1.5
            }else{
                self.bubbleGap = 3
            }
            if self.fromMe {
                self.bubbleImage = XinhooTool.telegram_right_normal_image
            }else{
                self.bubbleImage = XinhooTool.telegram_left_normal_image
            }
        }else{
            self.bubbleGap = 4.5
            if self.fromMe {
                self.bubbleImage = XinhooTool.telegram_right_normal_image
            }else{
                self.bubbleImage = XinhooTool.telegram_left_normal_image
            }
        }
        if modelType == .image || modelType == .video || modelType == .location {
           if self.fromMe {
                self.bubbleImage = XinhooTool.telegram_right_normal_image
            }else{
                self.bubbleImage = XinhooTool.telegram_left_normal_image
            }
        }
        if modelType == .image || modelType == .video {
            if self.fromMe {
                self.bubbleImage = XinhooTool.telegram_right_normal_image
            }else{
                self.bubbleImage = XinhooTool.telegram_left_normal_image
            }

        }
        if (self.messageModel.rp.count > 0 && self.messageModel.rp != "0") {
            self.rpContentView.isCloudDisk = self.isCloudDisk
            self.rpContentView.configModel(model: self.messageModel, indexPath: self.indexPath, pageVM: self.pageVM)
        }
        
        if (CustomUtil.getIsShowFwView(messageModel: self.messageModel)) {
            self.fwContentView.configModel(model: self.messageModel)
        }

    }
    var fromMe:Bool = false ///是否是自己
    var isFirst:Bool = false ///是否是第一条信息,用来作为时间的显示
    var isShowName:Bool = false ///是否显示名字
    var isCloudDisk:Bool = false ///是否是云盘
    var lastMessage:CODMessageModel? //上一个条消息
    var showType:CODMessageShowStatus = .Nono ///头像显示的样式
    var bubbleImage = UIImage.init(named: "SenderImage_bubbles") ///背景图片
    var bubbleGap: CGFloat = 0 ///背景图片的间隔

    weak var chatDelegate:CODIMChatCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(more(noti:)), name: NSNotification.Name.init("kCellMoreAction"), object: nil)
                
        
    }

    @objc func tapRpView() {
        if let message = try! Realm.init().object(ofType: CODMessageModel.self, forPrimaryKey: self.messageModel.rp) {
            if self.tapRpViewBlock != nil {
                self.tapRpViewBlock!(message)
            }
        }
    }
    

    
   //内容区_阅后即焚
    lazy var readDestroyImageView:UIImageView = {
        var readDestroyImageView = UIImageView(frame: CGRect.zero)
        readDestroyImageView.image = UIImage(named: "readDestroy")
        readDestroyImageView.contentMode =  .scaleToFill
        readDestroyImageView.backgroundColor = UIColor.clear
        return readDestroyImageView
    }()
    //内容区已阅读
    lazy var readImageView:UIImageView = {
        var readImageView = UIImageView(frame: CGRect.zero)
        readImageView.contentMode =  .left
        readImageView.backgroundColor = UIColor.clear
        return readImageView
    }()
    //气泡
    public lazy var bubbleImageView:UIImageView = {
        let bubbleImageView = UIImageView(frame: CGRect.zero)
        bubbleImageView.contentMode =  .scaleToFill
        bubbleImageView.backgroundColor = UIColor.clear
        //添加手势
        //点击手势 查看大图
        var tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapMessageView(gestureRecognizer:)))
        bubbleImageView.addGestureRecognizer(tap)
        bubbleImageView.isUserInteractionEnabled = true
        
      
        return bubbleImageView
    }()
    
    public lazy var avatarImageView:UIImageView = {
        let avatarImageView = UIImageView(frame: CGRect.zero)
        avatarImageView.contentMode =   .scaleAspectFill
        avatarImageView.backgroundColor = UIColor.clear
        return avatarImageView;
    }()
    
    public lazy var newAvatarImageView:UIImageView = {
        let avatarImageView = UIImageView(frame: CGRect.zero)
        avatarImageView.contentMode = .scaleToFill
        avatarImageView.backgroundColor = UIColor.clear
        avatarImageView.cornerRadius = IMChatAvatarWidth/2
        avatarImageView.clipsToBounds = true
        //        avatarImageView.image = UIImage(named: "default_header_80")
        ///添加avatarImageView手势
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapedAvatarImage))
        avatarImageView.addGestureRecognizer(tap)
        
        let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longTapAvatarImage(gesture:)))
        avatarImageView.addGestureRecognizer(longTap)
        
        avatarImageView.isUserInteractionEnabled = true
        return avatarImageView;
    }()
    
    public lazy var nicknameLabel:UILabel = {
        let nicknameLabel = UILabel(frame: CGRect.zero)
//        nicknameLabel.font = UIFont.systemFont(ofSize: 14)
//        nicknameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nicknameLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 14)
        nicknameLabel.textColor = UIColor.init(hexString: kNavTitleColorS)
        return nicknameLabel;
    }()
    
    public lazy var timeLabel:CustomLabel = {
        let timeLabel = CustomLabel(frame: CGRect.zero)
        timeLabel.font = UIFont.boldSystemFont(ofSize: 13)
        timeLabel.layer.cornerRadius = 10
        timeLabel.layer.masksToBounds = true
        timeLabel.insets = UIEdgeInsets(top: 2, left: 10, bottom: 4, right: 12)
        timeLabel.textColor = UIColor.white
        timeLabel.text = ""
        timeLabel.backgroundColor = UIColor.init(hexString: "#879EAE")?.withAlphaComponent(0.5)
        return timeLabel
    }()
    
    public lazy var hourLabel:ActiveLabel = {
        let timeLabel = ActiveLabel(frame: CGRect.zero)
        timeLabel.font = FONTTime
        timeLabel.layer.cornerRadius = 7.5
        timeLabel.layer.masksToBounds = true
        timeLabel.textColor = UIColor.white
        timeLabel.text = ""
        timeLabel.backgroundColor = UIColor.clear
        return timeLabel
    }()
    ///菊花动画
    public lazy var indicatorView:UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicatorView.backgroundColor = UIColor.clear
        indicatorView.color = grayBackColor
        indicatorView.stopAnimating()
        return indicatorView
    }()
    ///发送失败的按钮
    public lazy var sendFailBtn:UIButton = {
        let sendFailBtn = UIButton(type: UIButton.ButtonType.custom)
        sendFailBtn.setImage(UIImage(named:"msg_send_fail"), for: .normal)
        sendFailBtn.addTarget(self, action: #selector(sendMsgRetainAction), for: .touchUpInside)
        return sendFailBtn
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.contentView.isUserInteractionEnabled = true
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        ///添加视图
        self.contentView.addSubview(self.nicknameLabel)
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.newAvatarImageView)
        self.contentView.addSubview(self.timeLabel)
        self.contentView.addSubview(self.indicatorView)
        self.contentView.addSubview(self.sendFailBtn)
        ///隐藏菊花动画
        self.indicatorView.isHidden = true
        self.sendFailBtn.isHidden = true
    }

    ///点击头像
    @objc func tapedAvatarImage() {
        if (self.chatDelegate != nil) {
            self.chatDelegate?.cellDidTapedAvatarImage(self,model: self.messageModel)
        }
    }
    
    ///频道点击转发
    @objc func tapedFwfImageView() {
        if (self.chatDelegate != nil) {
            self.chatDelegate?.cellDidTapedFwdImageView(self,model: self.messageModel)
        }
    }
    
    ///长按头像
    @objc func longTapAvatarImage(gesture:UILongPressGestureRecognizer){
        
        if gesture.state == .began {
            
            if self.chatDelegate != nil {
                self.chatDelegate?.cellDidLongTapedAvatarImage(self, model: self.messageModel)
            }
        }
    }
    
    @objc func sendMsgRetainAction(){
        if (self.chatDelegate != nil) {
           self.chatDelegate?.cellSendMsgReation(message: self.messageModel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
 
    //强提醒方式，自己去决定怎么提醒
    override func flashingCell() {
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: self.messageModel.msgType) ?? .text

        if self.fromMe {
            if self.showType == .Nono || modelType == .image || modelType == .video || modelType == .location{
                self.bubbleImageView.image = UIImage.init(named: "remind_bubbles_right_round")!.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left:20, bottom: 20, right: 20), resizingMode: .stretch)
            }else{
                self.bubbleImageView.image = UIImage.init(named: "remind_bubbles_right")!.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left:20, bottom: 20, right: 20), resizingMode: .stretch)
            }
        }else{
            if self.showType == .Nono || modelType == .image || modelType == .video || modelType == .location {
                self.bubbleImageView.image = UIImage.init(named: "remind_bubbles_left_round")!.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left:20, bottom: 20, right: 20), resizingMode: .stretch)
            }else{
                self.bubbleImageView.image = UIImage.init(named: "remind_bubbles_left")!.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left:20, bottom: 20, right: 20), resizingMode: .stretch)
            }
        }

        self.perform(#selector(bubblesAction), with: nil, afterDelay: 1.0)
        
    }
    
    @objc func bubblesAction() {
        
        self.bubbleImageView.image = self.bubbleImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left:20, bottom: 20, right: 20), resizingMode: .stretch)
    }
    
    fileprivate func downloadAvatar() {
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: messageModel.userPic) { [weak self] (image) in
            
            guard let `self` = self else { return }
            self.newAvatarImageView.image = image
            //                self.setNeedsDisplay()
        }
    }
    
    ///布局父类约束
    public func updateBaseSnapkt() {
        ///暂时不显示时间
        ///self.formMe = true
        self.readImageView.isHidden = !self.fromMe
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: self.messageModel.msgType) ?? .text
     
        if self.messageModel.datetimeInt > 0 {
            
            self.hourLabel.text = TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double((self.messageModel.datetime.int == nil ? "\(Date.milliseconds)":self.messageModel.datetime)))!/1000), format: XinhooTool.is12Hour ? "h:mm a" : "h:mm")
            if (modelType == .image || modelType == .video) && self.messageModel.edited > 0{
                    self.hourLabel.text = "\(NSLocalizedString("已编辑", comment: ""))  " +  TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double((self.messageModel.datetime.int == nil ? "\(Date.milliseconds)":self.messageModel.datetime)))!/1000), format: XinhooTool.is12Hour ? "h:mm a" : "h:mm")
            }
        }
        
        if  self.isFirst == false {
            self.timeLabel.text = ""
            ///重新设置约束
            self.timeLabel.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(IMChatAvatarMarginTopBottom)
                make.centerX.equalToSuperview().offset(0)
                make.size.equalTo(CGSize(width: 0, height: 0))
            }
        }else{
            let timeStr = TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double(self.messageModel.datetime))!/1000), format: NSLocalizedString("MM 月 dd 日", comment: ""))
            self.timeLabel.text = timeStr
            let textW: CGFloat = (self.timeLabel.text?.getStringWidth(font: self.timeLabel.font, lineSpacing: 0, fixedWidth: KScreenWidth) ?? 0) + 22

            self.timeLabel.snp.remakeConstraints { (make:ConstraintMaker) in
                make.top.equalToSuperview().offset(CODNoticeLabelMarginTopBottom)
                make.centerX.equalToSuperview()
                make.width.equalTo(textW)
                make.height.equalTo(20)
            }
        }
        _ = UIImage(named: "default_header_80")

        if self.fromMe == true{
            self.nicknameLabel.isHidden = true
            
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: UserManager.sharedInstance.avatar!) { [weak self] (image) in
                
                guard let `self` = self else { return }
                self.newAvatarImageView.image = image
//                self.setNeedsDisplay()
            }
            var topGap: CGFloat = 0
            if messageModel.burn > 0 {
                topGap = 3
            }
            self.avatarImageView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-IMChatAvatarMarginLeft)
                if  self.isFirst  {
                    make.top.equalTo(self.timeLabel.snp.bottom).offset(6+topGap)
                }else{
                    make.top.equalToSuperview().offset(IMChatAvatarMarginTopBottom+topGap)
                }
                if showType == .HeadAndPart{
                    make.size.equalTo(CGSize(width: IMChatAvatarWidth, height: IMChatAvatarWidth))
                }else{
                    make.size.equalTo(CGSize.zero)
                }
            }
            if showType == .HeadAndPart{
                self.newAvatarImageView.isHidden = false
                self.newAvatarImageView.snp.remakeConstraints { (make) in
                    make.right.equalToSuperview().offset(-IMChatAvatarMarginLeft)
                    make.bottom.equalToSuperview().offset(-6)
                    make.size.equalTo(CGSize(width: IMChatAvatarWidth, height: IMChatAvatarWidth))
                }
            }else{
                self.newAvatarImageView.isHidden = true
            }

       
        }else{

            downloadAvatar()
            var topGap: CGFloat = 0
            if messageModel.burn > 0 {
                topGap = 3
            }
            self.avatarImageView.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(IMChatAvatarMarginLeft)
                if self.isFirst{
                    make.top.equalTo(self.timeLabel.snp.bottom).offset(6+topGap)
                }else{
                    if messageModel.isGroupChat && isShowName {
                        make.top.equalToSuperview().offset(IMChatAvatarMarginTopBottom+topGap)
                    }else{
                        make.top.equalToSuperview().offset(IMChatAvatarMarginTopBottom+topGap)
                    }
                }
                if showType == .HeadAndPart{
                    make.size.equalTo(CGSize(width: IMChatAvatarWidth, height: IMChatAvatarWidth))
                }else{
                    make.size.equalTo(CGSize.zero)
                }
            }
            if showType == .HeadAndPart{
                self.newAvatarImageView.isHidden = false
                self.newAvatarImageView.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(IMChatAvatarMarginLeft)
                    make.bottom.equalToSuperview().offset(-4)
                    make.size.equalTo(CGSize(width: IMChatAvatarWidth, height: IMChatAvatarWidth))
                }
            }else{
                self.newAvatarImageView.isHidden = true
            }
            var contentWidth: CGFloat = 0
            
            if self.messageModel.edited == 1 {
                contentWidth = 40
            }
            if messageModel.isGroupChat && isShowName{
                if self.messageModel.nick.count == 0{
                    var jid = ""
                    if self.messageModel.fromWho.contains(XMPPSuffix) {
                        jid = self.messageModel.fromWho
                    }else{
                        jid = self.messageModel.fromWho + XMPPSuffix
                    }
                    
                    if let member = CODGroupMemberRealmTool.getMemberById(CODGroupMemberModel.getMemberId(roomId: self.messageModel.roomId, userName: jid)) {
                        self.nicknameLabel.text = member.getMemberNickName()
                    }else{
                        if let member = CODGroupMemberRealmTool.getMembersByJid(jid)?.first {
                            self.nicknameLabel.text = member.getMemberNickName()
                        }else if let contact = CODContactRealmTool.getContactByJID(by: jid) {
                            self.nicknameLabel.text = contact.getContactNick()
                        }else if let personInfo = CODPersonInfoModel.getPersonInfoModel(jid: jid){
                            self.nicknameLabel.text = personInfo.name
                        }else{
                            self.nicknameLabel.text = " "
                        }
                    }
                }else{
                    self.nicknameLabel.text = self.messageModel.nick
                }
                self.nicknameLabel.snp.remakeConstraints { (make) in
                    if modelType == .text || modelType == .businessCard || modelType == .file{
                        make.top.equalTo(self.avatarImageView.snp.top).offset(10)
                    }else{
                        make.top.equalTo(self.avatarImageView.snp.top).offset(0)
                    }
//                    make.top.equalTo(self.avatarImageView.snp.top).offset(10)
                    make.left.equalTo(self.avatarImageView.snp.right).offset(IMChatToTextMarginLeft)
//                    make.height.equalTo(20)
                    make.width.lessThanOrEqualTo(KScreenWidth - 2 * (IMChatMeTextMarginRight+IMChatBubbleMaginLeft+IMChatAvatarWidth)  )
                }
            }
          
        }

        
        let messageStatus: CODMessageStatus =  CODMessageStatus(rawValue: messageModel.status) ?? .Succeed
        
        
        if messageStatus == .Pending {
            self.indicatorView.isHidden = false
            self.indicatorView.startAnimating()
            self.sendFailBtn.isHidden = true
        }else{
            ///是成功还是失败
            if messageStatus == .Succeed {///发送成功
                self.indicatorView.isHidden = true
                self.indicatorView.stopAnimating()
                self.sendFailBtn.isHidden = true
            }else if(messageStatus == .Failed){///发送失败
                self.indicatorView.isHidden = true
                self.indicatorView.stopAnimating()
                self.sendFailBtn.isHidden = false
            }else{
                self.indicatorView.isHidden = false
                self.sendFailBtn.isHidden = true
                self.indicatorView.startAnimating()
            }
        }
        
        
        var  readImageName = ""
        if !self.fromMe {
            self.hourLabel.textColor = UIColor.init(hexString: "#979797")
        }else if modelType == .image && messageStatus == .Succeed && self.messageModel.isReaded {
            self.hourLabel.textColor = UIColor.white
            readImageName = "readInfo_white_isread"
        }else if modelType == .image && messageStatus == .Succeed{
            self.hourLabel.textColor = UIColor.white
            readImageName = "readInfo_white"
        }else if modelType == .video && messageStatus == .Succeed && self.messageModel.isReaded {
            self.hourLabel.textColor = UIColor.white
            readImageName = "readInfo_white_isread"
        }else if modelType == .video && messageStatus == .Succeed{
            self.hourLabel.textColor = UIColor.white
            readImageName = "readInfo_white"
        }else if modelType == .location && messageStatus == .Succeed && self.messageModel.isReaded {
            self.hourLabel.textColor = UIColor.white
            readImageName = "readInfo_white_isread"
        }else if modelType == .location && messageStatus == .Succeed{
            self.hourLabel.textColor = UIColor.white
            readImageName = "readInfo_white"
        }else if messageStatus == .Succeed && self.messageModel.isReaded{
            self.hourLabel.textColor = UIColor.init(hexString: "#54A044")
            readImageName = "readInfo_blue_Haveread"
        }else if messageStatus == .Succeed  {
            self.hourLabel.textColor = UIColor.init(hexString: "#54A044")
            readImageName = "readInfo_blue"
        }
        
     
        self.readImageView.image = UIImage.init(named: readImageName)
    }
    ///点击事件
    @objc public func tapMessageView(gestureRecognizer:UITapGestureRecognizer){
        if self.chatDelegate != nil {
        }
    }
    //长按事件
    @objc public func longPressgesView(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            if self.chatDelegate != nil {
                self.pageVM?.cellLongPressMessage(cellVM: nil, self, self.bubbleImageView)
//                self.chatDelegate?.cellLongPressMessage(message: self.messageModel,self, self.bubbleImageView)
            }
           
        }
    }
    
    //点击了 消息已读/未读 按钮
    @objc public func tapViewerImageView(gestureRecognizer:UITapGestureRecognizer){
        if self.chatDelegate != nil {
            self.pageVM?.cellTapViewer(cell: self, message: messageModel)
        }
    }
    

    //双击事件
    @objc public func doubleTapView(gestureRecognizer:UITapGestureRecognizer){
        if self.chatDelegate != nil {
            self.pageVM?.cellLongPressMessage(cellVM: nil, self, self.bubbleImageView)
        }
    }
    
    func configModel(lastModel:CODMessageModel?,model:CODMessageModel,nextModel:CODMessageModel?){
        
        if XinhooTool.isEdit_MessageView {
            self.selectionStyle = .default
        }else{
            self.selectionStyle = .none
        }
        
        self.traverseAllSubViews(view: self.contentView, enabled: !XinhooTool.isEdit_MessageView)

    }
    
    func showName(showName:Bool) {
    }
    
    func traverseAllSubViews(view:UIView,enabled:Bool) {
        for subView in view.subviews {
            subView.isUserInteractionEnabled = enabled
            if subView.subviews.count > 0 {
                self.traverseAllSubViews(view: subView,enabled: enabled)
            }
        }
    }
    @objc func more(noti:Notification) {
        
        self.traverseAllSubViews(view: self.contentView, enabled: !XinhooTool.isEdit_MessageView)
    }
    
    override func layoutSubviews() {
        for control in self.subviews {
            
            guard let editClass = NSClassFromString("UITableViewCellEditControl") else {
                return
            }
            if control.isMember(of: editClass) {
                control.frame = CGRect.init(x: 10, y: self.bounds.height/2 - 12, width: 24, height: 24)
                for view in control.subviews {
                    if view.isKind(of: UIImageView.classForCoder()) {
                        let img = view as! UIImageView
                        img.frame = CGRect.init(x: img.frame.origin.x, y: img.frame.origin.y, width: 24, height: 24)
                        if self.isSelected {
                            img.image = UIImage(named: "multi_select")
                        }else{
                            img.image = UIImage(named: "multi_normal")
                        }
                    }
                }
            }
        }
        super.layoutSubviews()
    }
    

//    func checkRegexStr(textString:String) -> NSMutableAttributedString {
//        let pattern_url = kRegexURL
//        let regex_url = try! NSRegularExpression(pattern: pattern_url, options: NSRegularExpression.Options(rawValue:0))
//        let res_url = regex_url.matches(in: textString, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, (textString.utf16.count)))
//        
//        let pattern_phone = "(1[3-9])\\d{9}"
//        let regex_phone = try! NSRegularExpression(pattern: pattern_phone, options: NSRegularExpression.Options(rawValue:0))
//        let res_phone = regex_phone.matches(in: textString, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, (textString.utf16.count)))
//        
//        let attText = NSMutableAttributedString.init(string: textString)
//        //        attText.addAttributes([NSAttributedString.Key.kern : NSNumber.init(value: 0.5)], range: NSRange.init(location: 0, length: attText.length))
//        
//        for range in res_url {
//            
//            
//            attText.yy_setTextHighlight(range.range, color: UIColor.init(hexString: "#1D49A7"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3), tapAction: { [weak self] (containerView, text, range, rect) in
//                guard let `self` = self else { return }
//                
//                if self.chatDelegate != nil{
//                    let str:NSString = text.string as NSString
//                    let targetStr = str.substring(with: range) as String
//                    self.chatDelegate?.cellDidTapedLink(self, linkString: URL.init(string: targetStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
//                }
//            })
//            
//        }
//        
//        for range in res_phone {
//            
//            for urlRange in res_url {
//                if range.range.intersection(urlRange.range) == nil{
//                    attText.yy_setTextHighlight(range.range, color: UIColor.init(hexString: "#1D49A7"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3)) { [weak self] (containerView, text, range, rect) in
//                        
//                        guard let `self` = self else { return }
//                        
//                        if self.chatDelegate != nil{
//                            let str:NSString = text.string as NSString
//                            let targetStr = str.substring(with: range) as String
//                            self.chatDelegate?.cellDidTapedPhone(self, phoneString: targetStr)
//                        }
//                    }
//                }
//            }
//        }
//        
//        if self.messageModel.isGroupChat {
//            for jid in self.messageModel.referTo {
//                
//                let memberId = CODGroupMemberModel.getMemberId(roomId: self.messageModel.roomId, userName: jid)
//                let groupMemberModel = CODGroupMemberRealmTool.getMemberById(memberId)
//                let str = NSString.init(string: textString)
//                let nameStr = groupMemberModel?.zzs_getMemberNickName() ?? ""
//                attText.yy_setTextHighlight(str.range(of: nameStr + " "), color: UIColor.init(hexString: "#1D49A7"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3)) { [weak self] (containerView, text, range, rect) in
//                    
//                    guard let `self` = self else { return }
//                    
//                    if let contactModel = CODContactRealmTool.getContactByJID(by: jid) {
//                        
//                        if contactModel.isValid == true {
//                            let personVC = CODPersonDetailVC()
//                            personVC.rosterId = contactModel.rosterID
//                            if XMPPManager.shareXMPPManager.currentChatFriend.contains(XMPPGroupSuffix) {
//                                personVC.showType = .group
//                                let memberId = CODGroupMemberModel.getMemberId(roomId: self.messageModel.roomId, userName:jid)
//                                if let member = CODGroupMemberRealmTool.getMemberById(memberId){
//                                    if member.nickname.count > 0 {
//                                        personVC.groupNick = member.nickname
//                                    }
//                                }
//                            }
//                            UIViewController.current()?.navigationController?.pushViewController(personVC)
//                        }else{
//                            
//                            if CODChatListRealmTool.getChatList(id: self.messageModel.roomId)?.groupChat?.isICanCheckUserInfo() ?? true == false  {
//                                CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
//                                return
//                            }
//                            
//
//                            if let member = CODGroupMemberRealmTool.getMemberById(memberId){
//                                let personVC = CODStrangerDetailVC()
//                                personVC.name = member.name
//                                personVC.userName = member.username
//                                personVC.userPic = member.userpic
//                                personVC.gender = member.gender
//                                personVC.jid = member.jid
//                                personVC.userDesc = member.userdesc
//                                personVC.type = .groupType
//                                
//                                personVC.showType = .group
//                                if member.nickname.count > 0 {
//                                    personVC.groupNick = member.nickname
//                                }
//                                
//                                UIViewController.current()?.navigationController?.pushViewController(personVC)
//                            }else{
//                                let personVC = CODStrangerDetailVC()
//                                personVC.name = contactModel.getContactNick()
//                                personVC.userName = contactModel.username
//                                personVC.userPic = contactModel.userpic
//                                personVC.gender = contactModel.gender
//                                personVC.jid = contactModel.jid
//                                personVC.userDesc = contactModel.userdesc
//                                personVC.type = .cardType
//                                UIViewController.current()?.navigationController?.pushViewController(personVC)
//                            }
//                        }
//                    }else{
//                        
//                        if CODChatListRealmTool.getChatList(id: self.messageModel.roomId)?.groupChat?.isICanCheckUserInfo() ?? true == false  {
//                            CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
//                            return
//                        }
//                        
//                        if let member = CODGroupMemberRealmTool.getMemberById(memberId) {
//                            let personVC = CODStrangerDetailVC()
//                            personVC.name = member.name
//                            personVC.userName = member.username
//                            personVC.userPic = member.userpic
//                            personVC.gender = member.gender
//                            personVC.jid = member.jid.count == 0 ? member.username:member.jid
//                            personVC.userDesc = member.userdesc
//                            personVC.type = .groupType
//                            
//                            personVC.showType = .group
//                            if member.nickname.count > 0 {
//                                personVC.groupNick = member.nickname
//                            }
//                            
//                            UIViewController.current()?.navigationController?.pushViewController(personVC)
//                        }
//                    }
//                }
//            }
//        }
//        
//        return attText
//    }
}
