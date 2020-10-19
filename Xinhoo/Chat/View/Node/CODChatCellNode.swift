//
//  CODChatCellNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import SwifterSwift




class CODChatCellNode: CODDisplayNode {
    
    var vm: ChatCellVM!
    weak var pageVM: CODChatMessageDisplayPageVM!
    
    let dateTimeBG = ASDisplayNode()
    
    
    
    init(vm: ChatCellVM, pageVM: CODChatMessageDisplayPageVM) {
        super.init()
        self.vm = vm
        self.pageVM = pageVM
        
        dateTimeBG.backgroundColor = UIColor(hex: 0x879EAE, transparency: 0.5)
        
        loadHeaderImage()
        self.bindData()
    }
    
    func loadHeaderImage() {
        
        if self.vm.messageModel.userPic.count <= 0 {
            
            var userJid = self.vm.messageModel.fromJID
            
            if self.vm.messageModel.isCloudDiskMessage {
                userJid = self.vm.messageModel.fw
            }
            
            if userJid.contains("cod_60000000") {
                self.headerImageNode.setImage(image: UIImage(named: UIImage.getHelpIconName()))
            } else {
                
                XMPPManager.shareXMPPManager.requestUserInfo(userJid: userJid, success: { [weak self] (model) in
                    
                    guard let `self` = self else { return }
                    
                    let users = model.dataJson?["users"]
                    
                    if let jid = users?["jid"].stringValue, let name = users?["name"].stringValue, let userpic = users?["userpic"].stringValue {
                        
                        DispatchQueue.realmWriteQueue.async {
                            CODPersonInfoModel.createModel(jid: jid, name: name, userpic: userpic).addToDB()
                        }
                        
                        self.headerImageNode.setImageURL(URL(string: userpic.getHeaderImageFullPath(imageType: 1)), placeholderImage: UIImage(named: "default_header_80"))

                    }
                    

                }) {
                    
                }
                
            }
            
            
        } else {
            self.headerImageNode.setImageURL(URL(string: vm.model.userPic.getHeaderImageFullPath(imageType: 1)), placeholderImage: UIImage(named: "default_header_80"))
        }
        
        if vm.messageModel.isCloudDiskMessage != true {
            self.headerImageNode.isHidden = true
        }
        
        
        self.headerImageNode.isHidden = true
        
        
    }
    
    var headerImageNode: CODImageHeaderNode = {
        
        let imageNode = CODImageHeaderNode(image: UIImage(named: "default_header_80"))
        
        return imageNode
        
    }()
    
    lazy var burnIconNode: ASImageNode = {
        let image = ASImageNode(image: UIImage(named: "readDestroy"))
        image.style.preferredSize = CGSize(width: 16, height: 16)
        return image
    }()
    
    lazy var resendBtn: ASButtonNode = {
        
        let resendBtn = ASButtonNode()
        
        resendBtn.setImage(UIImage(named: "chat_send_failure"), for: .normal)
        resendBtn.style.preferredSize = CGSize(width: 30, height: 30)
        
        return resendBtn
        
    }()
    
    lazy var fwButton: ASButtonNode = {
        
        let fwButton = ASButtonNode()
        
        fwButton.setImage(UIImage(named: "left_share_icon"), for: .normal)
        fwButton.style.preferredSize = CGSize(width: 30, height: 30)
        fwButton.displaysAsynchronously = false
        
        return fwButton
        
    }()
    
    lazy var cloudDiskJumpButton: ASButtonNode = {
        
        let fwButton = ASButtonNode()
        
        fwButton.setImage(UIImage(named: "cloud_disk_jump"), for: .normal)
        fwButton.style.preferredSize = CGSize(width: 30, height: 30)
        fwButton.displaysAsynchronously = false
        
        return fwButton
        
    }()
    
    lazy var activityIndicatorNode: ActivityIndicatorNode = {
        
        return ActivityIndicatorNode()
        
    }()
    
    var bubblesImage: UIImage {
        
        if vm.cellDirection == .right {
            return self.vm.telegram_rightBubblesImage
        } else {
            return self.vm.telegram_leftBubblesImage
        }
        
    }
    
    var flashingBubblesImage: UIImage {
        if vm.cellDirection == .right {
            return self.vm.telegram_right_FlashingBubblesImage
        } else {
            return self.vm.telegram_left_FlashingBubblesImage
        }
        
    }
    
    lazy var backgroundNode: ASImageNode = {
        let backgroundNode = ASImageNode(image: self.bubblesImage)
        backgroundNode.displaysAsynchronously = false
        return backgroundNode
    }()
    
    var cellBottomPadding: CGFloat {
        switch vm.cellLocation {
        case .bottom, .only:
            return 6
        case .top, .mid:
            return 1
        }
    }
    
    var messageReadNode: ASButtonNode = {
        let button = ASButtonNode()
        button.setImage(UIImage(named: "chat_viewers_icon"), for: .normal)
        return button
    }()
    
    
    
    @objc func onClickHeader() {
        pageVM.cellDidTapedAvatarImage(self.getSuperTableViewCell() as! CODBaseChatCell, model: self.vm.model)
    }
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        
        _ = self.layoutThatFits(ASSizeRangeMake(CGSize.zero,
                                                CGSize(width: size.width,
                                                       height: CGFloat.greatestFiniteMagnitude)))
        return self.calculatedSize
        
    }
    
    @objc func onClickFW() {
        
        pageVM.cellDidTapedFwdImageView(self.getSuperTableViewCell() as! CODBaseChatCell, model: self.vm.model)
        
    }
    
    func flashingCell() {
        
        self.backgroundNode.image = flashingBubblesImage
        
        self.perform(#selector(bubblesAction), with: nil, afterDelay: 1.0)
        
    }
    
    @objc func bubblesAction() {
        self.backgroundNode.image = bubblesImage
    }
    
    @objc func onClickResend() {
        
        pageVM.cellSendMsgReation(message: vm.messageModel)
        
    }
    
    @objc func onClickCheckReadPeople() {
        
        pageVM.cellTapViewer(cell: self.getSuperTableViewCell() as! CODBaseChatCell, message: vm.model)
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        headerImageNode.view.cornerRadius = 19
        dateTimeBG.cornerRadius = 10
        
        headerImageNode.addTarget(self, action: #selector(onClickHeader), forControlEvents: .touchUpInside)
        fwButton.addTarget(self, action: #selector(onClickFW), forControlEvents: .touchUpInside)
        resendBtn.addTarget(self, action: #selector(onClickResend), forControlEvents: .touchUpInside)
        messageReadNode.addTarget(self, action: #selector(onClickCheckReadPeople), forControlEvents: .touchUpInside)
        cloudDiskJumpButton.addTarget(self, action: #selector(onClickDiskJump), forControlEvents: .touchUpInside)
        
        
        headerImageNode.view.addLongTap { [weak self] in
            
            guard let `self` = self else { return }
            
            self.pageVM.cellDidLongTapedAvatarImage(self.getSuperTableViewCell() as! CODBaseChatCell, model: self.vm.model)
            
        }
        
        
        self.view.addLongTap { [weak self ] in
            
            guard let `self` = self else { return }
            
            if let cell = self.getSuperTableViewCell() {
                self.pageVM.cellLongPressMessage(cellVM: self.vm, cell, self.view)
            }
            
        }
        
        
    }
    
    
    func bindData() {
        
        vm.cellLocationBR
            .distinctUntilChanged()
            .bind(to: self.rx.cellLocationBinder)
            .disposed(by: self.rx.disposeBag)
        
        let model = CODMessageRealmTool.getMessageByMsgId(self.vm.model.msgID) ?? self.vm.model
        
        model.rx.observe(\.status)
            .skip(1)
            .filterNil()
            .map { CODMessageStatus(rawValue: $0) ?? CODMessageStatus.Succeed }
            .distinct()
            .bind(to: self.rx.statusBinder)
            .disposed(by: self.rx.disposeBag)
        
        
        pageVM.isMultipleSelelct.skip(1).distinctUntilChanged().bind(to: self.rx.isMultipleSelelctBinder)
            .disposed(by: self.rx.disposeBag)
        
        
    }
    
    var justifyContent: ASStackLayoutJustifyContent {
        switch vm.cellDirection {
        case .right:
            return .end
        case .left:
            return .start
        }
    }
    
    var chatContentNode: ASLayoutSpec {
        return ASLayoutSpec()
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            VStackLayout() {
                
                if vm.isFirst {
                    
                    ASTextNode2(text: vm.dateTime)
                        .font(UIFont.boldSystemFont(ofSize: 13))
                        .foregroundColor(.white)
                        .padding([.left, .right], 10)
                        .padding([.top, .bottom], 2)
                        .background(dateTimeBG)
                        .padding(.top, 15)
                        .padding(.bottom, 10)
                        .alignSelf(.center)
                    
                }
                
                
                HStackLayout(justifyContent: justifyContent, alignItems: .baselineLast) {
                    
                    if (vm.messageModel.toJID.contains(kCloudJid) && vm.messageModel.fw.removeAllSapce.count > 0) {
                        /// 头像
                        self.headerImageNode
                            .preferredSize(CGSize(width: 38, height: 38))
                            .padding(.left, 3)
                            .padding(.bottom, 8)
                            .padding(.right, 2)
                            .alignSelf(.end)
                    }else if vm.messageModel.chatTypeEnum == .groupChat {
                        
                        /// 头像
                        if vm.model.isMeSend == false {
                            self.headerImageNode
                                .preferredSize(CGSize(width: 38, height: 38))
                                .padding(.left, 3)
                                .padding(.bottom, 8)
                                .padding(.right, 2)
                                .alignSelf(.end)
                        }
                        
                        /// 查看消息接收人列表
                        //                        if vm.model.isMeSend && pageVM.chatListModel.groupChat!.isICanCheckUserInfo() && vm.model.statusType == .Succeed {
                        //                            self.messageReadNode
                        //                                .padding(.right, 6)
                        //                        }
                        
                        
                    }
                    
                    
                    /// 消息展示内容
                    OverlayLayout(content: {
                        
                        HStackLayout(justifyContent: justifyContent) {
                            
                            if vm.model.statusType == .Pending && vm.cellDirection == .right {
                                activityIndicatorNode.alignSelf(.center)
                                    .padding(.right, 5)
                            }
                            
                            chatContentNode
                                .flexShrink(1)
                        }
                        
                        
                    }) {
                        
                        LayoutSpec {
                            
                            /// 阅后即焚
                            if vm.isBurn == false {
                                
                                if vm.cellDirection == .left {
                                    
                                    RelativeLayout(horizontalPosition: .end) {
                                        burnIconNode
                                    }
                                    
                                } else {
                                    
                                    RelativeLayout() {
                                        burnIconNode
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    /// 重发按钮
                    if vm.model.statusType == .Failed {
                        resendBtn
                            .padding(.right, 3)
                            .alignSelf(.end)
                    }
                    
                    /// 快速转发按钮
                    if vm.model.chatTypeEnum == .channel && (vm.model.statusType != .Failed && vm.model.statusType != .Pending) {
                        
                        fwButton
                            .alignSelf(.end)
                            .padding(.left, 5)
                        
                    }
                    
                    /// 云盘消息跳转原消息按钮
                    if vm.showCloudDiskJumButton {
                        
                        cloudDiskJumpButton
                            .alignSelf(.end)
                            .padding(.left, 5)
                        
                    }
                    
                    
                    /// loading 转圈
                    if vm.model.statusType == .Pending && vm.cellDirection == .left {
                        activityIndicatorNode.alignSelf(.center)
                    }
                    
                }
                .width(cellWidth)
                .padding(.bottom, cellBottomPadding)
                
                
                
            }
            
        }
        
    }
    
    @objc func onClickDiskJump() {
        
        if let jid = self.vm.model.itemID, let msgID = self.vm.model.smsgID {
            self.pageVM.onClickCloudDaskJump(jid: jid, msgID: msgID)
        }
        
    }
    
    var cellWidth: CGFloat {
        
        return KScreenWidth
        
    }
    
    
}
