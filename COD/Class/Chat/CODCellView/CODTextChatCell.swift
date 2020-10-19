//
//  CODTextChatCell.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import ActiveLabel
let IMChatTextFont:UIFont = UIFont.systemFont(ofSize: CGFloat(16+(UserDefaults.standard.integer(forKey: kFontSize_Change))))
public let IMChatbubbleMarginTop: CGFloat = 10                                    //气泡顶部的内间距11像素
public let IMChatBubbleMaginLeft: CGFloat = 6                                   //气泡左或者右间距

public let IMChatTextMarginTop: CGFloat = 10                                    //文字的顶部和气泡顶部相差 13 像素
public let IMChatTextMarginBottom: CGFloat = 10                                 //文字的底部和气泡底部相差 13 像素
//self.fromMe = true
public let IMChatMeTextMarginLeft: CGFloat = 10                                 //文字的左边和气泡左边相差 10 像素
public let IMChatMeTextMarginRight: CGFloat = 38                                 //文字的右边和气泡右边相差 41 像素
//self.fromMe = false
public let IMChatToTextMarginLeft: CGFloat = 17                                 //文字的左边和气泡左边相差 10 像素
public let IMChatToTextMarginRight: CGFloat = 17                                 //文字的右边和气泡右边相差 41 像素

public let IMChatReadImageMarginRight:CGFloat = 15                              //已阅视图右边和气泡右边相差 11 像素
public let IMChatReadImageMarginBottom:CGFloat = 11                              //已阅视图下边和气泡下边相差 11 像素
public let IMChatReadImageSize:CGSize = CGSize(width: 20, height: 11)            //已阅视图大小
public let IMChatHaveReadImageSize:CGSize = CGSize(width: 10, height: 6)            //已发送的标识符

public let IMChatReadDestroyImageSize:CGSize = CGSize(width: 16, height: 16)            //阅后销毁视图大小

class CODTextChatCell: CODBaseChatCell {
    
    var seeker = CharacterLocationSeeker.init()
    var contentMaxWidth: CGFloat = 0
    
    fileprivate lazy var sendTimeView:UIView = {
        let sendTimeView = UIView.init(frame: .zero)
        sendTimeView.addSubview(self.statuImageView)
        sendTimeView.addSubview(self.sendTimeLab)
        return sendTimeView
    }()
    
    fileprivate lazy var sendTimeLab:UILabel = {
        let sendTimeLab = UILabel.init(frame: .zero)
        sendTimeLab.textColor = UIColor.init(hexString: "#979797")
        sendTimeLab.font = FONTTime
        sendTimeLab.textAlignment = NSTextAlignment.right
        return sendTimeLab
    }()
    
    fileprivate lazy var statuImageView:UIImageView = {
        let statuImageView = UIImageView.init(frame: .zero)
        statuImageView.contentMode = .scaleAspectFit
//        statuImageView.backgroundColor = UIColor.red
        return statuImageView
    }()
    
    
    fileprivate lazy var contentLabel:ActiveLabel = {
        
        let type = ActiveType.custom(pattern: kRegexURL)
        let phoneType = ActiveType.custom(pattern: "^1(3[0-9]|4[579]|5[0-35-9]|7[1-35-8]|8[0-9]|70)\\d{8}$")

        let contentLabel = ActiveLabel(frame: CGRect.zero)
        contentLabel.font = IMChatTextFont
        contentLabel.numberOfLines = 0
        contentLabel.enabledTypes = [type,phoneType]
        contentLabel.customColor[type] = UIColor.init(hexString: "#1D49A7") ?? UIColor.blue
        contentLabel.customColor[phoneType] = UIColor.init(hexString: "#1D49A7") ?? UIColor.blue
        contentLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        contentLabel.handleCustomTap(for: type, handler: { (string) in
            if self.chatDelegate != nil{
                let str:String = string
                self.chatDelegate?.cellDidTapedLink(self, linkString: URL.init(string: str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
            }
        })
        contentLabel.handleCustomTap(for: phoneType, handler: { (string) in
            if self.chatDelegate != nil{
                self.chatDelegate?.cellDidTapedPhone(self, phoneString: string)
            }
        })
        contentLabel.textAlignment = .left
        contentLabel.backgroundColor = UIColor.clear
        
        var longGR =  UILongPressGestureRecognizer()
        longGR.addTarget(self, action: #selector(longPressgesView(gestureRecognizer:)))
        contentLabel.addGestureRecognizer(longGR)
        
        return contentLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(self.bubbleImageView)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.sendTimeView)
        self.contentView.bringSubviewToFront(self.nicknameLabel)
        self.statuImageView.snp.makeConstraints({ (make) in
            make.right.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 10.5, height: 8))
            make.centerY.equalToSuperview()
        })
        
        self.sendTimeLab.snp.makeConstraints { (make) in
            make.right.equalTo(self.statuImageView.snp.left).offset(-3)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.bubbleImageView.addSubview(self.readImageView)
        self.bubbleImageView.addSubview(self.readDestroyImageView)
//        self.addSnapkt()
        
    }
    
    var indexRow = 0
    

    override func setCellContent(_ model: CODMessageModel,isShowName:Bool,isCloudDisk: Bool = false) {
                super.setCellContent(model, isShowName: isShowName,isCloudDisk: isCloudDisk)

        if self.showType == .Nono{
            contentMaxWidth = KScreenWidth - 80
        }else if self.showType == .Part {
            contentMaxWidth = KScreenWidth - 80
        }else {
            contentMaxWidth = KScreenWidth - 80 - IMChatAvatarWidth
        }
     
//        model.attrText
        if model.attrText.length == 0 {
         
//            dispatch_async_safely_to_main_queue({[weak self] in
//              guard let strongSelf = self else { return }
//                let attrText:NSAttributedString =  String.messageTextTranscode(text: self.messageModel.text)
                self.contentLabel.text = self.messageModel.text
//            CODEmojiHelper.messageTextTranscode(text: self.messageModel.text) { (attrText) in
//                self.contentLabel.attributedText = attrText
//            }
//            self.contentLabel.text = ""
//            })
//
//            CODMessageRealmTool.updateMessageAttrTextByMsgId(model.msgID, attrText: attrText)
        }else{
            self.contentLabel.attributedText = model.attrText
        }

        if messageModel.burn > 0 {
            self.readDestroyImageView.isHidden = false
        }else{
            self.readDestroyImageView.isHidden = true
        }
        
        if let fontSize = UserDefaults.cod_stringForKey(kFontSize_Change)?.int {
//            contentLabel.font = UIFont.systemFont(ofSize: CGFloat(17 + fontSize))
            contentLabel.font = UIFont.init(name: "PingFangSC-Regular", size: CGFloat(17 + fontSize))
        }
        
        let timeString = TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double((self.messageModel.datetime.int == nil ? "\(Date.milliseconds)":self.messageModel.datetime)))!/1000), format: "H:mm")
        if self.messageModel.edited == 0{
                self.sendTimeLab.text = timeString
        }else{
            self.sendTimeLab.text = "\(NSLocalizedString("已编辑", comment: ""))  " + timeString

        }
    
        
        let messageStatus: CODMessageStatus =  CODMessageStatus(rawValue: messageModel.status) ?? .Succeed
       
        
        if !self.fromMe {
            statuImageView.isHidden = true
            self.sendTimeLab.textColor = UIColor.init(hexString: "#979797")
        }else{
            if messageStatus == .Succeed && self.messageModel.isReaded {
                statuImageView.image = UIImage.init(named: "readInfo_blue_Haveread")
            }else if messageStatus == .Succeed && !self.messageModel.isReaded{
                statuImageView.image = UIImage.init(named: "readInfo_blue")
            }else{
                statuImageView.image = UIImage.init(named: "")
            }
            statuImageView.isHidden = false
            self.sendTimeLab.textColor = UIColor.init(hexString: "#54A044")
        }
        
        self.updateSnapkt()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func updateSnapkt(){
        self.updateBaseSnapkt()
        self.readImageView.isHidden = true
        self.bubbleImageView.image = self.bubbleImage
        var contentWidth: CGFloat = 50
        
        if self.messageModel.edited == 1 {
            contentWidth = 90
        }
        let imageSize:CGSize = self.statuImageView.image?.size ?? CGSize.zero
        if self.fromMe {
//            let messageStatus: CODMessageStatus =  CODMessageStatus(rawValue: messageModel.status) ?? .Succeed
//            if self.messageModel.isReaded && messageStatus == .Succeed{
//                imageSize = IMChatReadImageSize
//            }else if messageStatus == .Succeed  && messageModel.isGroupChat{
//                imageSize = IMChatReadImageSize
//            }else if messageStatus == .Succeed {
//                imageSize = IMChatHaveReadImageSize
//            }
            let readImgWidth = 44 + imageSize.width

            self.readImageView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-IMChatReadImageMarginRight)
                make.bottom.equalToSuperview().offset(-IMChatReadImageMarginBottom)
                make.size.equalTo(CGSize(width: readImgWidth, height: imageSize.height))
            }

            
            self.statuImageView.snp.remakeConstraints({ (make) in
                make.right.equalToSuperview()
                make.size.equalTo(imageSize)
                make.centerY.equalToSuperview()
            })
            
            self.sendTimeLab.snp.remakeConstraints { (make) in
                make.right.equalTo(self.statuImageView.snp.left).offset(-3)
                make.left.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }

            
            let contentSize = contentLabel.sizeThatFits(CGSize.init(width:contentMaxWidth, height: CGFloat(MAXFLOAT)))
            
            if contentSize.width + contentWidth < (contentMaxWidth) {
                self.contentLabel.snp.remakeConstraints { (make) in
                    make.right.equalTo(self.avatarImageView.snp.left).offset(-(contentWidth + imageSize.width + 5))
                    make.top.equalTo(self.avatarImageView.snp.top).offset(IMChatTextMarginTop)
                    ///设置最大的宽度
                    make.width.equalTo(contentSize.width)
                }
                
                self.sendTimeView.snp.remakeConstraints { (make) in
                    make.right.equalTo(self.avatarImageView.snp.left).offset(-15)
                    make.bottom.equalTo(self.contentLabel.snp.bottom).offset(-2)
                    make.size.equalTo(CGSize.init(width: contentWidth+10, height: 12))
                }
                
            }else{
                self.contentLabel.snp.remakeConstraints { (make) in
                    make.right.equalTo(self.avatarImageView.snp.left).offset(-(18 + (imageSize.width + 5)))
                    make.top.equalTo(self.avatarImageView.snp.top).offset(IMChatTextMarginTop)
                    ///设置最大的宽度
                    make.width.equalTo(contentMaxWidth)
                }

                let rect = self.configLab(contentSize: contentSize)
                
                if rect.maxX + contentWidth + 5 > (contentMaxWidth){
                    self.sendTimeView.snp.remakeConstraints { (make) in
                        make.right.equalTo(self.avatarImageView.snp.left).offset(-15)
                        make.top.equalTo(self.contentLabel.snp.bottom).offset(3)
                        make.size.equalTo(CGSize.init(width: contentWidth-5, height: 12))
                    }
                }else{
                    self.sendTimeView.snp.remakeConstraints { (make) in
                        make.right.equalTo(self.avatarImageView.snp.left).offset(-15)
                        make.bottom.equalTo(self.contentLabel.snp.bottom).offset(-2)
                        make.size.equalTo(CGSize.init(width: contentWidth+10, height: 12))
                    }
                }
            }
            
            
            self.bubbleImageView.snp.remakeConstraints { (make) in
                make.right.equalTo(self.avatarImageView.snp.left).offset((-bubbleGap))
                make.top.equalTo(self.contentLabel.snp.top).offset(-IMChatTextMarginTop)
                make.left.equalTo(self.contentLabel.snp.left).offset(-IMChatMeTextMarginLeft)
                make.bottom.equalTo(self.sendTimeView.snp.bottom).offset(IMChatTextMarginBottom)
                make.top.lessThanOrEqualTo(self.timeLabel.snp.bottom).offset(IMChatbubbleMarginTop)
                make.bottom.lessThanOrEqualToSuperview().offset(-IMChatAvatarMarginBottom)
            }
            
            self.indicatorView.snp.remakeConstraints { (make) in
                make.right.equalTo(self.bubbleImageView.snp.left).offset(-10)
                make.centerY.equalTo(self.bubbleImageView).offset(0)
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
            self.sendFailBtn.snp.remakeConstraints { (make) in
                make.right.equalTo(self.bubbleImageView.snp.left).offset(-10)
                make.centerY.equalTo(self.bubbleImageView).offset(0)
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
         
            if self.messageModel.burn > 0 {
                self.readDestroyImageView.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.bubbleImageView.snp.left)
                    make.top.equalTo(self.bubbleImageView.snp.top).offset(-3)
                    make.size.equalTo(IMChatReadDestroyImageSize)
                }
                
            }else{
                self.readDestroyImageView.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.bubbleImageView.snp.left)
                    make.top.equalTo(self.bubbleImageView.snp.top).offset(0)
                    make.size.equalTo(CGSize.zero)
                }
            }
          
        }else{
//            self.contentLabel.snp.remakeConstraints { (make) in
//                make.left.equalTo(self.avatarImageView.snp.right).offset(IMChatToTextMarginLeft+IMChatBubbleMaginLeft)
//                if messageModel.isGroupChat && isShowName{
//                    make.top.equalTo(self.nicknameLabel.snp.bottom).offset(IMChatTextMarginTop + IMChatTimeLabelPaddingLeft)
//                }else{
//                    make.top.equalTo(self.avatarImageView.snp.top).offset(IMChatTextMarginTop)
//                }
//                ///设置最大的宽度
//                make.width.lessThanOrEqualTo(contentMaxWidth)
//            }
            
            self.statuImageView.snp.remakeConstraints({ (make) in
                make.right.equalToSuperview()
                make.size.equalTo(imageSize)
                make.centerY.equalToSuperview()
            })
            
            self.sendTimeLab.snp.remakeConstraints { (make) in
                make.right.equalTo(self.statuImageView.snp.right).offset(0)
                make.left.equalToSuperview()
//                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            let contentSize = contentLabel.sizeThatFits(CGSize.init(width:contentMaxWidth, height: CGFloat(MAXFLOAT)))
            let nickNameSize = nicknameLabel.sizeThatFits(CGSize.init(width:contentMaxWidth, height: CGFloat(MAXFLOAT)))
            var nickNameWidth = nickNameSize.width + 10
            if nickNameSize.width > contentMaxWidth {
                nickNameWidth =  contentMaxWidth
            }
            
            if contentSize.width + contentWidth - 15 < (contentMaxWidth) {
                self.contentLabel.snp.remakeConstraints { (make) in
                    
                    make.left.equalTo(self.bubbleImageView.snp.left).offset(IMChatToTextMarginLeft)

                    if messageModel.isGroupChat && isShowName{
                        make.top.equalTo(self.nicknameLabel.snp.bottom).offset(7)
                        if nickNameWidth  - contentWidth - 15 >= contentSize.width {
                            make.width.equalTo(nickNameWidth - contentWidth - 15)
                        }else{
                            make.width.lessThanOrEqualTo(contentSize.width)
                        }
                    }else{
                        make.top.equalTo(self.avatarImageView.snp.top).offset(IMChatTextMarginTop)
                        make.width.equalTo(contentSize.width)
                    }
                                   
                }
                
                self.sendTimeView.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.contentLabel.snp.right).offset(5)
                    make.bottom.equalTo(self.contentLabel.snp.bottom).offset(-2)
                    make.size.equalTo(CGSize.init(width: contentWidth - 5, height: 12))
                }
                
            }else{

                self.contentLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.bubbleImageView.snp.left).offset(IMChatToTextMarginLeft)
                    ///设置最大的宽度
                    make.width.equalTo(contentMaxWidth)
                    if messageModel.isGroupChat && isShowName{
                        make.top.equalTo(self.nicknameLabel.snp.bottom).offset(7)
//                        make.width.greaterThanOrEqualTo(self.nicknameLabel.snp.width)
                    }else{
                        make.top.equalTo(self.avatarImageView.snp.top).offset(IMChatTextMarginTop)
                    }
                
                }
                
                let rect = self.configLab(contentSize: contentSize)
                
                if rect.maxX + contentWidth - 5 > (contentMaxWidth){
                    self.sendTimeView.snp.remakeConstraints { (make) in
                        make.right.equalTo(self.contentLabel.snp.right).offset(0)
                        make.top.equalTo(self.contentLabel.snp.bottom).offset(3)
                        make.size.equalTo(CGSize.init(width: contentWidth - 5, height: 12))
                    }
                }else{
                    self.sendTimeView.snp.remakeConstraints { (make) in

                        make.right.equalTo(self.contentLabel.snp.right).offset(0)
                        make.bottom.equalTo(self.contentLabel.snp.bottom).offset(-2)
                        make.size.equalTo(CGSize.init(width: contentWidth - 5, height: 12))
                    }
                }
            }

            self.bubbleImageView.snp.remakeConstraints { (make) in
                make.left.equalTo(self.avatarImageView.snp.right).offset((bubbleGap))
                make.bottom.equalTo(self.sendTimeView.snp.bottom).offset(IMChatTextMarginBottom)
                if messageModel.isGroupChat && isShowName{
                    make.top.lessThanOrEqualTo(self.nicknameLabel.snp.top).offset(-IMChatbubbleMarginTop)
                }else{
                    make.top.lessThanOrEqualTo(self.avatarImageView.snp.top)

                }
                make.right.equalTo(self.sendTimeView.snp.right).offset(9.5)
                make.bottom.lessThanOrEqualToSuperview().offset(-IMChatAvatarMarginBottom)
            }
            
            self.readDestroyImageView.snp.remakeConstraints { (make) in
                make.right.equalTo(self.bubbleImageView.snp.right)
                make.top.equalTo(self.bubbleImageView.snp.top).offset(-3)
                make.size.equalTo(IMChatReadDestroyImageSize)
            }
        }
        let bubbleImage = bubbleImageView.image?.resizableImage(withCapInsets: UIEdgeInsets(top: (bubbleImageView.image?.size.height ?? 0)/2, left: 20, bottom: (bubbleImageView.image?.size.height ?? 0)/2, right: 20), resizingMode: .stretch)
        self.bubbleImageView.image = bubbleImage;
        self.setNeedsLayout()
    }

    
    func configLab(contentSize:CGSize) -> CGRect {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        lab.text = messageModel.text
        lab.font = IMChatTextFont
        lab.numberOfLines = 0
        lab.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        lab.textAlignment = .left
        lab.backgroundColor = UIColor.clear
        
        if let fontSize = UserDefaults.cod_stringForKey(kFontSize_Change)?.int {
            lab.font = UIFont.init(name: "PingFangSC-Regular", size: CGFloat(17 + fontSize))
        }
        
        self.seeker.config(with: lab)
        let string = lab.text! as NSString
        return self.seeker.characterRect(at: UInt((string.length)-1))
    }
    
}

