//
//  CODChatContentNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport
import SwifterSwift
import RxSwift
import RxCocoa
import LGAlertView
import SwiftyJSON
import RxSwiftExt


class CODChatContentNode: CODDisplayNode {
    
    var vm: ChatCellVM!
    weak var pageVM: CODChatMessageDisplayPageVM!
    
    var timeLabBG: ASDisplayNode = ASDisplayNode()
    
    init(vm: ChatCellVM, pageVM: CODChatMessageDisplayPageVM) {
        super.init()
        self.vm = vm
        self.pageVM = pageVM
        
        timeLabBG.backgroundColor = UIColor(hexString: "#000000", transparency: 0.4)
        timeLabBG.cornerRadius = 9
        
    }
    
    var cellWidth: CGFloat {
        return (KScreenWidth - 60)
    }
    
    var contentInsets: UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    var contentWidth: CGFloat {
        return cellWidth
    }
    
    lazy var titleHStackLayout: ASLayoutSpec = {
        
        
        return LayoutSpec {
            HStackLayout(spacing: 10, justifyContent: .spaceBetween, alignItems: .center) {
                
                if CODChatListRealmTool.getChatList(id: vm.messageModel.roomId)?.chatTypeEnum == .groupChat || CustomUtil.getIsCloudMessage(messageModel: vm.model){
                    
                    RelativeLayout(horizontalPosition: .end, verticalPosition: .center) {
                        
                        ASTextNode2(text: vm.model.getMessageSenderNickName())
                            .font(UIFont.systemFont(ofSize: 14, weight: .medium))
                            .foregroundColor(vm.model.getNickNameColor())
                        
                    }
                    .flexShrink(1)
                    
                } else {
                    
                    RelativeLayout(horizontalPosition: .end, verticalPosition: .center) {
                        
                        ASTextNode2(text: CODChannelModel.getChannel(by: vm.messageModel.roomId)?.descriptions ?? "")
                            .font(UIFont.boldSystemFont(ofSize: 14))
                            .foregroundColor(vm.model.getNickNameColor())
                        
                    }
                    .flexShrink(1)
                    
                }
                
                
                if ((CODGroupChatRealmTool.getGroupChat(id: vm.messageModel.roomId)?.isAdmin(jid: vm.messageModel.fromJID) ?? false ||
                    CODGroupChatRealmTool.getGroupChat(id: vm.messageModel.roomId)?.isOwner(jid: vm.messageModel.fromJID) ?? false) ||
                    CODChannelModel.getChannel(by: vm.messageModel.roomId)?.isAdmin(by: vm.messageModel.fromJID)  ?? false)
                    && vm.messageModel.chatTypeEnum != .channel && !vm.messageModel.isCloudDiskMessage {
                    
                    RelativeLayout(horizontalPosition: .start, verticalPosition: .center) {
                        
                        ASTextNode(text: NSLocalizedString("管理员", comment: ""))
                            .font(UIFont.systemFont(ofSize: 12))
                            .foregroundColor(UIColor(hexString: "#979797"))
                            .flexShrink(1)
                        
                    }
                    
                }
                
            }
            .height(27)
            .maxWidth(self.contentWidth)
            .padding(.top, -contentInsets.top)
            .padding([.right, .left], 8)
            .flexGrow(1)
        }
        
    }()
    
    
    func createTimeLabLayout() -> ASLayoutSpec {
        
        self.timeLab = ChatUITools.createTimeLab(vm: self.vm)
        
        return LayoutSpec {
            
            self.timeLab.padding([.right, .left], 5)
                .height(18)
                .background(timeLabBG)
            
        }
        
    }
    
    
    lazy var timeLab: XinhooTimeAndReadViewNode = {
        
        return ChatUITools.createTimeLab(vm: self.vm)
        
        
    }()
    
    
    lazy var fwNode = {
        
        return FWNode(fwname: vm.fwName, color: vm.fwColor)
        
    }()
    
    lazy var fwLayout = {
        
        return LayoutSpec {
            fwNode
        }
        .padding([.top, .bottom], 5)
        .padding(.left, 10)
        
    }()
    
    
    func bindData() {
        
        let model = CODMessageRealmTool.getMessageByMsgId(self.vm.model.msgID) ?? self.vm.model
        
        model.rx.observe(\.status)
            .skip(1)
            .filterNil()
            .map { CODMessageStatus(rawValue: $0) ?? CODMessageStatus.Succeed }
            .distinct()
            .bind(to: self.rx.statusBinder)
            .disposed(by: self.rx.disposeBag)
        
        model.rx.observe(\.isReaded)
            .skip(1)
            .distinct()
            .mapTo(Void())
            .bind(to: self.rx.isHaveReadBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.vm.rx.messageStatus
            .skip(1)
            .distinct()
            .bind(to: self.rx.messageStatusBinder)
            .disposed(by: self.rx.disposeBag)
        
    }
    
    
    @objc func longTap() {
        
        if let cell = self.getSuperTableViewCell() {
            pageVM.cellLongPressMessage(cellVM: vm, cell, self.view)
        }
        
    }
    
    
    override func didLoad() {
        super.didLoad()
        
        fwNode.addTarget(self, action: #selector(onClickFW), forControlEvents: .touchUpInside)
        
        bindData()
        
    }
    
    @objc func onClickFW() {
        
        let jid = vm.model.fw
        
        if jid == UserManager.sharedInstance.jid || jid == UserManager.sharedInstance.loginName{
            pushCloudVC()
            return
        }
        
        if vm.model.fwf == "C" {
            pushChannel()
        }else{
            pushPersonInfoVC()
        }
    }
    
    func pushCloudVC() {
        
        let msgCtl = MessageViewController()
        msgCtl.chatType = .privateChat
        msgCtl.toJID = kCloudJid + XMPPSuffix
        msgCtl.chatId = CloudDiskRosterID
        msgCtl.title = NSLocalizedString("我的云盘", comment: "")
        UIViewController.current()?.navigationController?.pushViewController(msgCtl, animated: true)
        
    }
    
    func configMessageStatus(status: XinhooTimeAndReadView.Status) {
        
    }
    
    func pushChannel() {
        let dict:[String:Any] = ["name": COD_Getchannelbyjid,
                                 "channelName": vm.model.fw]
        
        CODProgressHUD.showWithStatus(nil)
        
        XMPPManager.shareXMPPManager.getRequest(param: dict, xmlns: COD_com_xinhoo_channelsetting) { (response) in
            
            CODProgressHUD.dismiss()
            switch response {
            case .success(let model):
                
                if let jsonModel = CODChannelHJsonModel.deserialize(from: model.dataJson?.dictionaryObject) {
                    let channelModel = CODChannelModel.init(jsonModel: jsonModel)
                    
                    CODDownLoadManager.sharedInstance.updateAvatar(userPicID: channelModel.grouppic, complete: nil)
                    
                    if let memberArr = model.dataJson?["channelMemberVoList"].array {
                        for member in memberArr {
                            let memberTemp = CODGroupMemberModel()
                            memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
                            memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                            channelModel.member.append(memberTemp)
                        }
                    }
                    
                    channelModel.notice = model.dataJson?["noticecontent"]["notice"].stringValue ?? ""
                    
                    channelModel.customName = CODGroupChatModel.getCustomGroupName(memberList: channelModel.member)
                    
                    let msgCtl = MessageViewController()
                    
                    if let listModel = CODChatListRealmTool.getChatList(id: channelModel.roomID) {
                        msgCtl.newMessageCount = listModel.count
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
                        
                        if let groupChatTemp = listModel.channelChat {
                            msgCtl.toJID = String(groupChatTemp.jid)
                        }
                        msgCtl.chatId = listModel.id
                        
                    }else{
                        if channelModel.descriptions.count > 0 {
                            msgCtl.title = channelModel.descriptions.subStringToIndexAppendEllipsis(10)
                        }else{
                            msgCtl.title = NSLocalizedString("频道", comment: "")
                        }
                        
                        msgCtl.toJID =  channelModel.jid
                        msgCtl.chatId = channelModel.roomID
                    }
                    msgCtl.chatType = .channel
                    msgCtl.channelModel = channelModel
                    msgCtl.roomId = String(format: "%d", channelModel.roomID)
                    msgCtl.isMute = channelModel.mute
                    
                    if channelModel.channelTypeEnum == .CPRI {
                        
                        if !channelModel.isMember(by: UserManager.sharedInstance.jid) {
                            
                            let channelView = DeleteChatListModelView.initWitXib(imgID: channelModel.grouppic, desc: channelModel.descriptions, subDesc: String(format: NSLocalizedString("%d 位订阅者", comment: ""), channelModel.member.count))
                            
                            LGAlertView(viewAndTitle: nil, message: nil, style: .actionSheet, view: channelView,
                                        buttonTitles: [NSLocalizedString("加入", comment: "")], cancelButtonTitle: NSLocalizedString("取消", comment: ""), destructiveButtonTitle: nil,
                                        actionHandler: { (alertView, index, buttonTitle) in
                                            
                                            if index == 0 {
                                                XMPPManager.shareXMPPManager.joinGroupAndChannel(linkString: channelModel.userid, inviter: UserManager.sharedInstance.jid, add: true)
                                            }
                                            
                            }, cancelHandler: nil, destructiveHandler: nil).showAnimated()
                            break
                            
                        }
                        
                    }
                    
                    UIViewController.current()?.navigationController?.popToRootViewController(animated: false)
                    UIViewController.current()?.navigationController?.pushViewController(msgCtl, animated: true)
                }
                break
            default:
                LGAlertView(title: nil, message: NSLocalizedString("抱歉，你不能访问此频道", comment: ""), style: .alert, buttonTitles: nil, cancelButtonTitle: "好", destructiveButtonTitle: nil, actionHandler: nil, cancelHandler: nil, destructiveHandler: nil).show()
                
                break
            }
        }
    }
    
    
    func pushPersonInfoVC() {
        
        let jid = vm.model.fw
        
        if let contactModel = CODContactRealmTool.getContactByJID(by: jid), contactModel.isValid == true {
            CustomUtil.pushToPersonVC(contactModel: contactModel)
            
        }else{
            
            if let groupChat = CODChatListRealmTool.getChatList(id: vm.model.roomId)?.groupChat,
                groupChat.isICanCheckUserInfo() == false {
                
                CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
                
                return
            }
            
            XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
            CustomUtil.searchUserBID(jid: jid, pushToVCWithSourceType: .groupType)
            
        }
        
    }
    
    var contentNodeLayout: ASLayoutSpec {
        return ASLayoutSpec()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            HStackLayout {
                
                HSpacerLayout()
                
                VStackLayout() {
                    
                    /// 标题，群（人名），频道（频道名）
                    if vm.messageModel.chatTypeEnum == .groupChat {
                        
                        if (vm.cellLocation == .top || vm.cellLocation == .only) && vm.cellDirection == .left {
                            self.titleHStackLayout
                        }
                        
                    } else if vm.messageModel.chatTypeEnum == .channel || CustomUtil.getIsCloudMessage(messageModel: vm.messageModel) {
                        self.titleHStackLayout
                        
                    }
                    
                    if vm.model.isFw {
                        self.fwLayout
                    }
                    
                    contentNodeLayout
                    
                    
                }
                .padding(contentInsets)
                
                
            }
            .flexShrink(1)
            .maxWidth(self.cellWidth)
            
            
            
        }
        
        
    }
    
}
