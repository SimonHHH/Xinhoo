//
//  MessageViewController+NavBarTitleView.swift
//  COD
//
//  Created by XinHoo on 5/7/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension MessageViewController {
    func requestContactLoginStatus() {
        if self.chatId == RobotRosterID {
            self.navBarTitleView.subTitleLab.text = "服务通知"
            return
        }
        
        if let contact = self.chatListModel?.contact, contact.userTypeEnum == UserType.bot {
            self.navBarTitleView.subTitleLab.text = "机器人"
            return
        }
        
        self.updateLoginStatus()
    }
    
    func updateLoginStatus() {
        guard let contactModel = CODContactRealmTool.getContactById(by: self.chatId) else {
            return
        }
        let result = CustomUtil.getOnlineTimeStringAndStrColor(with: contactModel)
        self.navBarTitleView.subTitleLab.attributedText = NSAttributedString.init(string: result.timeStr).colored(with: result.strColor)
    }
    
    func setNavBarTitle() {
        if chatId == CloudDiskRosterID {
            return
        }
        
        self.navigationItem.titleView = self.navBarTitleView
    }
    
    @objc func updateMemberCount() {
        
        dispatch_async_safely_to_main_queue {
            
            switch self.chatType {
            case .groupChat:
                self.getMemberOnlineStatus()
                if let groupChatModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId) {
                    var onlineCount = 0
                    for member in groupChatModel.member {
                        if member.loginStatus.compareNoCaseForString("ONLINE") {
                            onlineCount += 1
                        }
                    }
                    let groupMemberCount = groupChatModel.member.count
                    self.navBarTitleView.setSubTitle(userDetail: groupChatModel.isICanCheckUserInfo(), memberCount: groupMemberCount, onlineCount: onlineCount)
                }
                break
            case .channel:
                
                if let channelModel = CODChannelModel.getChannel(by: self.chatId) {
                    let groupMemberCount = channelModel.member.count
                    let subText = String(format: NSLocalizedString("%d 位订阅者", comment: ""), groupMemberCount)
                    self.navBarTitleView.subTitleLab.text = subText
                }else{
                    let groupMemberCount = self.channelModel!.member.count
                    let subText = String(format: NSLocalizedString("%d 位订阅者", comment: ""), groupMemberCount)
                    self.navBarTitleView.subTitleLab.text = subText
                }
                
                break
            default:
                break
            }
            
        }
    }
    
}

class NavBarTitleView: UIView {
    
    var userDetail: Bool?
    var memberCount: Int?
    var onlineCount: Int?
    
    var isHiddenForInputtingState: Bool = true {
        didSet {
            self.inputtingBtn.isHidden = isHiddenForInputtingState
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        
        self.widthAnchor.constraint(equalToConstant: self.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: self.height).isActive = true
        self.addSubview(titleLabel)
        self.addSubview(muteImage)
        self.addSubview(subTitleLab)
        self.addSubview(inputtingBtn)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(3)
            make.left.equalToSuperview()
            make.height.equalTo(20)
        }
        
        muteImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right)
            make.right.equalToSuperview()
            make.width.equalTo(0.0)
        }
        
        subTitleLab.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(0.0)
            make.right.left.equalToSuperview()
        }
        
        inputtingBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(subTitleLab)
        }
        
    }
    
    lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 18.0)
        lb.textAlignment = NSTextAlignment.center
        lb.textColor = UIColor(hexString: kNavTitleColorS)
        return lb
    }()
    
    lazy var muteImage: UIImageView = {
        let imgV = UIImageView.init()
        imgV.image = UIImage(named: "msgvc_nav_mute")
        return imgV
    }()
    
    lazy var subTitleLab: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13)
        lb.textAlignment = NSTextAlignment.center
        lb.textColor = UIColor(hexString: "787878")
        return lb
    }()
    
    // MARK: -正在输入Btn
    lazy var inputtingBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        
        let path = Bundle.main.path(forResource: "inputting", ofType: "gif")!
        let url : URL = URL(fileURLWithPath: path)
        let data = try! Data.init(contentsOf: url)
        let gif = UIImage.sd_image(withGIFData: data)
        btn.setImage(gif, for: UIControl.State.normal)
        btn.isUserInteractionEnabled = false
        
        btn.backgroundColor = UIColor.init(hexString: kNavBarBgColorS)
        btn.imageEdgeInsets = UIEdgeInsets.init(top: 6, left: 0, bottom: 6, right: 0)
        btn.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        
        btn.setTitle("正在输入", for: UIControl.State.normal)
        btn.setTitleColor(UIColor.init(hexString: kBlueTitleColorS), for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -30, bottom: 0, right: 0)
        btn.isHidden = self.isHiddenForInputtingState
        return btn
    }()
    
    func getAttributesTitle(_ string: String!, isMute: Bool!) -> NSAttributedString {
        let attributes: Dictionary<NSAttributedString.Key, Any> = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue) : UIColor(hexString: kNavTitleColorS)!,
            NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont(name: "PingFang-SC-Medium", size: 18.0)!]
        let attriStr = NSMutableAttributedString.init(string: string, attributes: attributes)
        
        if isMute {
            let size = string.getLabelStringSize(font: UIFont(name: "PingFang-SC-Medium", size: 18.0)!, lineSpacing: 0.0, fixedWidth: KScreenWidth)
            if size.width+24 > KScreenWidth-152 {
                muteImage.snp.updateConstraints { (make) in
                    make.width.equalTo(12.0)
                }
            }else{
                muteImage.snp.updateConstraints { (make) in
                    make.width.equalTo(0.0)
                }
                let textAttachment = NSTextAttachment.init()
                let img = UIImage(named: "msgvc_nav_mute")
                textAttachment.image = img
                textAttachment.bounds = CGRect.init(x: 2, y: 0, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
                let attributedString = NSAttributedString.init(attachment: textAttachment)
                attriStr.append(attributedString)
            }
        }else{
            muteImage.snp.updateConstraints { (make) in
                make.width.equalTo(0.0)
            }
        }
        
        return attriStr
    }

    func setSubTitle(userDetail: Bool? = nil, memberCount: Int? = nil, onlineCount: Int? = nil) {
        if let userDetail = userDetail {
            self.userDetail = userDetail
        }
        if let memberCount = memberCount {
            self.memberCount = memberCount
        }
        if let onlineCount = onlineCount {
            self.onlineCount = onlineCount
        }
        
        var subText = String(format: NSLocalizedString("%d 位成员，%d 人在线", comment: ""), self.memberCount ?? 0, self.onlineCount ?? 0)
        if !(self.userDetail ?? false) {
            subText = String(format: NSLocalizedString("%d 位成员", comment: ""), self.memberCount ?? 0)
        }
        self.subTitleLab.text = subText
    }

}
