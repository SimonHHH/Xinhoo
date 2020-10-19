//
//  CODNoticeChatCell.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import ActiveLabel
import SwiftyJSON
//类似xx加入群组

public let CODNoticeLabelMarginTopBottom:CGFloat = 6
public let CODNoticeLabelHeight:CGFloat = 20
class CODNoticeChatCell: CODBaseChatCell {
    
//    weak var delegate:CODIMChatCellDelegate?
    
    var viewModel: ChatNotificationCellVM?
    
    var notificationMessageModel : CODMessageModel? {
        didSet{
            if let messageString = notificationMessageModel?.text,messageString.removeAllSapce.count > 0{
                
                let attText = NSMutableAttributedString.init(string: NSLocalizedString(messageString, comment: ""))
                attText.yy_setColor(.white, range: NSRange(location: 0, length: attText.length))
                attText.yy_setFont(UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: attText.length))
                for string in notificationMessageModel?.invitjoinList ?? List<String>() {
                    
                    if let dic = JSON(parseJSON: string).dictionaryObject {
                        guard let jid = dic.keys.first, let name = dic.values.first as? String else {
                            continue
                        }
//                        let jid = dic.keys.first
//                        let name = dic.values.first
                        let str = NSString.init(string: messageString)
                        
                        let memberId = CODGroupMemberModel.getMemberId(roomId: notificationMessageModel!.roomId, userName: jid)
                        
                        attText.yy_setFont(UIFont.boldSystemFont(ofSize: 14), range: str.range(of: name))
                        attText.yy_setTextHighlight(str.range(of: name), color: nil, backgroundColor: nil) { [weak self] (containerView, text, range, rect) in
                            
                            guard let `self` = self else { return }
                            
                            if jid == UserManager.sharedInstance.jid || jid == UserManager.sharedInstance.loginName {
                                let msgCtl = MessageViewController()
                                msgCtl.chatType = .privateChat
                                msgCtl.toJID = kCloudJid + XMPPSuffix
                                msgCtl.chatId = CloudDiskRosterID
                                msgCtl.title = NSLocalizedString("我的云盘", comment: "")
                                UIViewController.current()?.navigationController?.pushViewController(msgCtl, animated: true)
                                return
                            }
                            
                            if let contactModel = CODContactRealmTool.getContactByJID(by: jid) {
                                
                                if contactModel.isValid == true {
                                    
                                    CustomUtil.pushToPersonVC(contactModel: contactModel, messageModel: self.notificationMessageModel)
                                    
                                }else{
                                    
                                    if CODChatListRealmTool.getChatList(id: self.notificationMessageModel?.roomId ?? 0)?.groupChat?.isICanCheckUserInfo() ?? true == false  {
                                        CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
                                        return
                                    }
                                    
                                    if let member = CODGroupMemberRealmTool.getMemberById(memberId){
                                        
                                        CustomUtil.pushToStrangerVC(type: .groupType, memberModel: member)
                                        
                                    }else{
                                        
                                        CustomUtil.pushToStrangerVC(type: .cardType, contactModel: contactModel)
                                    }
                                }
                            }else{
                                
                                if CODChatListRealmTool.getChatList(id: self.notificationMessageModel?.roomId ?? 0)?.groupChat?.isICanCheckUserInfo() ?? true == false  {
                                    CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
                                    return
                                }
                                
                                
                                if let member = CODGroupMemberRealmTool.getMemberById(memberId) {
                                    
                                    CustomUtil.pushToStrangerVC(type: .groupType, memberModel: member)
                                }
                            }
                            
                        }
                    }
                    
                }
//                attText.yy_setAlignment(.center, range: NSRange(location: 0, length: attText.length))
                messageLabel.attributedText = attText
//                messageLabel.font = UIFont.systemFont(ofSize: 13)
                messageLabel.isHidden = false
                self.blackView.isHidden = messageLabel.isHidden
            }else{
                messageLabel.text = ""
                messageLabel.isHidden = true
                self.blackView.isHidden = messageLabel.isHidden
            }
            messageLabel.numberOfLines = (notificationMessageModel?.messageBody  ?? "" == COD_Topmsg) ? 2 : 0

            self.updateView()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public lazy var notiTimeLabel:UIButton = {
        let timeLabel = UIButton(frame: CGRect.zero)
        timeLabel.titleLabel?.font = UIFont.init(name: "PingFang-SC-Medium", size: 13)
        timeLabel.layer.masksToBounds = true
//        timeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1)
        timeLabel.setTitleColor(.white, for: .normal)
        timeLabel.setTitle("", for: .normal)
//        timeLabel.insets = UIEdgeInsets(top: 2, left: 10, bottom: 4, right: 12)
        timeLabel.contentEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 4, right: 10)
        timeLabel.layer.cornerRadius = 10
        timeLabel.backgroundColor = UIColor.init(hexString: "#879EAE")?.withAlphaComponent(0.5)
        return timeLabel
    }()
    
    public lazy var blackView: UIView = {
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor.init(hexString: "#879EAE")?.withAlphaComponent(0.5)
        bgView.layer.cornerRadius = 11
        bgView.clipsToBounds = true
        return bgView
    }()
    

//    public lazy var messageLabel:ActiveLabel = {
//        let meaasageLabel = ActiveLabel(frame: CGRect.zero)
//        meaasageLabel.font =  UIFont.systemFont(ofSize: 13)
//        meaasageLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
//        meaasageLabel.numberOfLines = 0
//        meaasageLabel.text = ""
//        let customType = ActiveType.custom(pattern: NSLocalizedString("发送好友验证  ", comment: ""))
//        meaasageLabel.enabledTypes = [customType]
//        meaasageLabel.customColor[customType] = UIColor.init(hexString: kSubmitBtnBgColorS)
//
//        meaasageLabel.handleCustomTap(for: customType, handler: {[weak self] (customType) in
//            if self?.delegate != nil {
//                self?.delegate?.cellTapMessage(message: self?.notificationMessageModel, CODBaseChatCell())
//            }
//        })
//        return meaasageLabel
//    }()
    
    public lazy var messageLabel:YYLabel = {
        let messageLabel = YYLabel(frame: .zero)
        messageLabel.preferredMaxLayoutWidth = KScreenWidth - 60
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .white
        return messageLabel
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setUpView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateView() {
        
        if self.isFirst == false {
            self.notiTimeLabel.setTitle("", for: .normal)
            self.notiTimeLabel.isHidden = true
        }else{
            let timeStr = TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double(self.notificationMessageModel!.datetime))!/1000), format: NSLocalizedString("MM 月 dd 日", comment: ""))
            self.notiTimeLabel.setTitle(timeStr, for: .normal)
            self.notiTimeLabel.isHidden = false
        }
                
        self.notiTimeLabel.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(3)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        self.messageLabel.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            if self.isFirst == false {
                make.top.equalTo(4)
            }else{
                make.top.equalTo(29)
            }
            make.bottom.equalToSuperview().offset(-8)
            make.left.greaterThanOrEqualToSuperview().offset(30)
        }
        
        self.blackView.snp.remakeConstraints { (make) in
            make.left.equalTo(self.messageLabel).offset(-8)
            make.right.equalTo(self.messageLabel).offset(8)
            make.top.equalTo(self.messageLabel).offset(-3)
            make.bottom.equalTo(self.messageLabel).offset(3)
        }
    }
    
    fileprivate func setUpView(){
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.notiTimeLabel)
        self.contentView.addSubview(self.blackView)
        self.contentView.addSubview(self.messageLabel)

    }

}

