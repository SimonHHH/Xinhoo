//
//  CODAudioChatCell.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

public let CODChatAudioImageSize:CGSize = CGSize(width: 13, height: 16)  ///语音播放显示图片

//fromMe = true
public let CODChatMeAudioImageMarginLeft:CGFloat = 14  ///语音播放显示图片左边距离气泡左边的距离
public let CODChatMeAudioImageMarginRight:CGFloat = 45  ///语音播放显示图片左边距离气泡左边的距离
public let CODChatMeAudioImageMarginTop:CGFloat = 13  ///语音播放显示图片左边距离气泡左边的距离
public let CODChatMeAudioImageMarginbottom:CGFloat = 9  ///语音播放显示图片左边距离气泡左边的距离
public let CODChatMeAudioTimeMarginleft:CGFloat = 4  ///语音播放显示图片和语音时间显示间距

//fromMe = false
public let CODChatToAudioImageMarginLeft:CGFloat = 16  ///语音播放显示图片左边距离气泡左边的距离
public let CODChatToAudioImageMarginRight:CGFloat = 45 ///语音播放显示图片左边距离气泡左边的距离
public let CODChatToAudioImageMarginTop:CGFloat = 14  ///语音播放显示图片左边距离气泡左边的距离
public let CODChatToAudioImageMarginbottom:CGFloat = 9  ///语音播放显示图片左边距离气泡左边的距离
public let CODChatToAudioTimeMarginleft:CGFloat = 4  ///语音播放显示图片和语音时间显示间距

class CODAudioChatCell: CODBaseChatCell {
    lazy var voiceImageView: CODVoiceImageView = {
        let voiceImageView = CODVoiceImageView(frame: CGRect.zero)
        voiceImageView.contentMode = .right
        return voiceImageView
    }()
    fileprivate lazy var voiceTimeLabel: UILabel = {
        let voiceTimeLabel = UILabel(frame: CGRect.zero)
        voiceTimeLabel.textColor = UIColor.black
        voiceTimeLabel.font = UIFont.systemFont(ofSize: 15)
        voiceTimeLabel.text = "1\"";
        return voiceTimeLabel
    }()
    lazy var unPlayVeiw: UIView = {
        let playView = UIView(frame: CGRect.zero)
        playView.backgroundColor = UIColor.red
        playView.clipsToBounds = true
        playView.layer.cornerRadius = 7/2
        return playView
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.bubbleImageView)
        self.contentView.addSubview(self.voiceImageView)
        self.contentView.addSubview(self.voiceTimeLabel)
        self.bubbleImageView.addSubview(self.readImageView)
        self.bubbleImageView.addSubview(self.hourLabel)
        self.bubbleImageView.addSubview(self.readDestroyImageView)
        self.contentView.addSubview(unPlayVeiw)

        self.voiceImageView.forMe = self.fromMe
    }
    
    override func setCellContent(_ model: CODMessageModel,isShowName:Bool,isCloudDisk: Bool = false) {
                super.setCellContent(model, isShowName: isShowName,isCloudDisk: isCloudDisk)

        let fromWho = messageModel.fromWho
        let me = UserManager.sharedInstance.loginName
        if fromWho.contains(me!)  {
            self.fromMe = true
        }else{
            self.fromMe = false
        }
        self.voiceImageView.forMe = self.fromMe
        self.voiceTimeLabel.text = String(format: "%ld\"", Int(messageModel.audioModel?.audioDuration ?? 0))
        if messageModel.burn > 0 {
            self.readDestroyImageView.isHidden = false
        }else{
            self.readDestroyImageView.isHidden = true
        }
        
        self.updateSnapkt()
    }
  
    private func updateSnapkt(){
        self.updateBaseSnapkt()
        let imageW:CGFloat = 15
        if self.fromMe {
            self.unPlayVeiw.isHidden = true
            self.voiceImageView.contentMode = .right
            let imageSize:CGSize = self.readImageView.image?.size ?? CGSize.zero
            let readImgWidth = 44 + imageSize.width

            self.readImageView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-IMChatReadImageMarginRight)
                make.bottom.equalToSuperview().offset(-IMChatReadImageMarginBottom)
                make.size.equalTo(CGSize(width: readImgWidth, height: imageSize.height))
            }
            self.bubbleImageView.image = UIImage(named: "SenderImageNodeBorder")
            self.voiceImageView.snp.remakeConstraints { (make) in
                make.right.equalTo(self.voiceTimeLabel.snp.left).offset(-(IMChatBubbleMaginLeft))
                make.top.equalTo(self.avatarImageView.snp.top).offset(IMChatTextMarginTop)
                make.size.equalTo(CGSize(width: self.getVoiceImageWidth()-imageW, height: 16))
            }
            self.voiceTimeLabel.snp.remakeConstraints { (make) in
                make.right.equalTo(self.avatarImageView.snp.left).offset(-(CODChatMeAudioImageMarginRight - 6 + 42))
                make.bottom.equalTo(self.voiceImageView.snp.bottom).offset(0)
            }
            self.bubbleImageView.snp.remakeConstraints { (make) in
                make.right.equalTo(self.voiceTimeLabel.snp.right).offset(CODChatMeAudioImageMarginRight - IMChatBubbleMaginLeft*2 + 42)
                make.top.equalTo(self.voiceImageView.snp.top).offset(-CODChatMeAudioImageMarginTop)
                make.left.equalTo(self.voiceImageView.snp.left).offset(-CODChatMeAudioImageMarginLeft)
                make.bottom.equalTo(self.voiceImageView.snp.bottom).offset(CODChatMeAudioImageMarginbottom)
                make.top.lessThanOrEqualTo(self.timeLabel.snp.bottom).offset(IMChatbubbleMarginTop)
                make.bottom.lessThanOrEqualToSuperview()
            }
            self.hourLabel.snp.remakeConstraints { (make) in
                make.centerY.equalTo(self.readImageView)
                make.right.equalTo(self.readImageView.snp.left).offset(-2)
            }
            
            self.readImageView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-IMChatReadImageMarginRight)
                make.bottom.equalToSuperview().offset(-IMChatReadImageMarginBottom)
                make.size.equalTo(IMChatReadImageSize)
            }
            self.readDestroyImageView.snp.remakeConstraints { (make) in
                make.left.equalTo(self.bubbleImageView.snp.left).offset(-IMChatReadDestroyImageSize.width/2)
                make.top.equalTo(self.bubbleImageView.snp.top).offset(0)
                make.size.equalTo(IMChatReadDestroyImageSize)
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
          
        }else{
            self.voiceImageView.contentMode = .left
            self.unPlayVeiw.isHidden = messageModel.audioModel?.isPlayed ?? true
            self.bubbleImageView.image = UIImage(named: "ReceiverImageNodeBorder")
            self.voiceImageView.snp.remakeConstraints { (make) in
                make.left.equalTo(self.avatarImageView.snp.right).offset(CODChatMeAudioImageMarginRight - IMChatBubbleMaginLeft*4)
//                make.top.equalTo(self.avatarImageView.snp.top).offset(IMChatTextMarginTop)
               if messageModel.isGroupChat && isShowName{
                    make.top.equalTo(self.nicknameLabel.snp.bottom).offset(IMChatTextMarginTop + IMChatTimeLabelPaddingLeft)
                }else{
                    make.top.equalTo(self.avatarImageView.snp.top).offset(IMChatTextMarginTop)
                }
                make.size.equalTo(CGSize(width: self.getVoiceImageWidth(), height: 16))
            }
            self.voiceTimeLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(self.voiceImageView.snp.left).offset((IMChatBubbleMaginLeft + imageW))
                make.bottom.equalTo(self.voiceImageView.snp.bottom).offset(0)
            }
            self.bubbleImageView.snp.remakeConstraints { (make) in
                make.right.equalTo(self.voiceImageView.snp.right).offset(CODChatToAudioImageMarginRight  + 38)
                make.top.equalTo(self.voiceImageView.snp.top).offset(-CODChatToAudioImageMarginTop)
                make.left.equalTo(self.voiceImageView.snp.left).offset(-CODChatToAudioImageMarginLeft)
                make.bottom.equalTo(self.voiceImageView.snp.bottom).offset(CODChatToAudioImageMarginbottom)
                
                if messageModel.isGroupChat && isShowName{
                    make.top.lessThanOrEqualTo(self.nicknameLabel.snp.bottom).offset(IMChatbubbleMarginTop)
                }else{
                    make.top.lessThanOrEqualTo(self.timeLabel.snp.bottom).offset(IMChatbubbleMarginTop)
                }
                make.bottom.lessThanOrEqualToSuperview()
            }
            self.hourLabel.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-IMChatReadImageMarginRight)
                make.bottom.equalToSuperview().offset(-IMChatReadImageMarginBottom)
                //                make.size.equalTo(imgSize)
            }
            self.readDestroyImageView.snp.remakeConstraints { (make) in
                make.right.equalTo(self.bubbleImageView.snp.right).offset(IMChatReadDestroyImageSize.width/2)
                make.top.equalTo(self.bubbleImageView.snp.top).offset(0)
                make.size.equalTo(IMChatReadDestroyImageSize)
            }
            self.unPlayVeiw.snp.remakeConstraints { (make) in
                make.left.equalTo(self.bubbleImageView.snp.right).offset(6)
                make.centerY.equalTo(self.bubbleImageView).offset(0)
                make.size.equalTo(CGSize(width: 7, height: 7))
            }
        }
        //拉伸图片区域
        let bubbleImage = bubbleImageView.image?.resizableImage(withCapInsets: UIEdgeInsets(top: (bubbleImageView.image?.size.height ?? 0)/2, left: 20, bottom: (bubbleImageView.image?.size.height ?? 0)/2, right: 20), resizingMode: .stretch)
        self.bubbleImageView.image = bubbleImage;
        self.setNeedsLayout()
    }
    //    计算语音图形宽度
    private func getVoiceImageWidth() -> CGFloat{
        let MAX_HEIGHT = KScreenWidth * 0.45 - 42
        var duration: CGFloat = CGFloat(messageModel.audioModel?.audioDuration ?? 0)
        if duration > 60 {
            duration = 60
        }
        let voiceLength = 20 + MAX_HEIGHT * (duration/60)
        return voiceLength
    }

    
    ///点击事件
    @objc public override func tapMessageView(gestureRecognizer:UITapGestureRecognizer){
        if self.chatDelegate != nil {
            self.chatDelegate?.cellTapMessage(message: self.messageModel, self)
        }
    }
    //长按事件
    @objc public override func longPressgesView(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            if self.chatDelegate != nil {
//                self.chatDelegate?.cellLongPressMessage(cellVM: nil,self, self.bubbleImageView)
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
