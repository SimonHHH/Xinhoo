//
//  CustomUtil+PushVCTools.swift
//  COD
//
//  Created by XinHoo on 8/17/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import LGAlertView

extension CustomUtil {
    
    class func pushToMessageVC(jid: String) {

        if let chatList = CODChatListRealmTool.getChatList(jid: jid) {
            
            let msgCtl = MessageViewController()
            
            msgCtl.chatType = chatList.chatTypeEnum
            msgCtl.toJID = jid
            switch chatList.chatTypeEnum {
            case .groupChat:
                msgCtl.title = chatList.groupChat?.getGroupName()
                msgCtl.chatId = chatList.id
                msgCtl.roomId = chatList.id.string
                msgCtl.isMute = chatList.groupChat?.mute ?? false
                
            case .privateChat:
                msgCtl.chatId = chatList.id
                msgCtl.title = chatList.contact?.getContactNick() ?? ""
                msgCtl.isMute = chatList.contact?.mute ?? false
                break
                
            case .channel:
                msgCtl.title = chatList.channelChat?.getGroupName()
                msgCtl.chatId = chatList.id
                msgCtl.roomId = chatList.id.string
                msgCtl.isMute = chatList.channelChat?.mute ?? false
                break
    
            }
            
            if let first = UIViewController.current()?.navigationController?.viewControllers.first {
                
                if let app = UIApplication.shared.delegate as? AppDelegate {
                    app.pushInfo = nil
                }
                
                if UIViewController.current()?.isKind(of: CODSecurityCodeViewController.self) ?? false {
                    return
                }
                
                if let messageVC = UIViewController.current() as? MessageViewController, messageVC.chatListModel?.jid == jid {
                    return
                }
                
                
                UIViewController.current()?.navigationController?.setViewControllers([first, msgCtl], animated: true)

                

            }
            
        } else {
            
            DDLogInfo("pushToMessageVC chatList miss")
            
        }
        

    }
    
    class func pushToMessageVC(jid formChatList: String, jumpMessageId: String) {
        
        if let chatListModel = CODChatListRealmTool.getChatList(jid: formChatList), chatListModel.isInValid == false {
            
            let msgCtl = MessageViewController()
            
            msgCtl.chatType = chatListModel.chatTypeEnum
            msgCtl.toJID = chatListModel.jid
            msgCtl.chatId = chatListModel.id
            msgCtl.title = chatListModel.title
            msgCtl.isMute = chatListModel.mute
            msgCtl.newMessageCount = chatListModel.count
            msgCtl.jumpMessage = CODMessageRealmTool.getExistMessage(jumpMessageId)
            
            switch msgCtl.chatType {
            case .channel:
                msgCtl.roomId = msgCtl.chatId.string
            case .groupChat:
                msgCtl.roomId = msgCtl.chatId.string
            case .privateChat:
                break

            }

            UIViewController.current()?.navigationController?.pushViewController(msgCtl, animated: true)
            
        } else {
            CODAlertView_show(NSLocalizedString("原会话已被删除", comment: ""))
        }
        
        
    }
    
    class func pushChannel(messageModel: CODMessageModel) {
        let dict:[String:Any] = ["name": COD_Getchannelbyjid,
                                 "channelName": messageModel.fw as Any]
        
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
                    
                    channelModel.addToDB()
                    
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
    
    
    class func pushPersonInfoVC(jid: String) {

        if let contactModel = CODContactRealmTool.getContactByJID(by: jid), contactModel.isValid == true {
            CustomUtil.pushToPersonVC(contactModel: contactModel)
        }else{
            CustomUtil.searchUserBID(jid: jid, pushToVCWithSourceType: .cardType)
        }
    }
    
    class func pushMemberInfoVC(memberId: String, jid: String) {
        if let member = CODGroupMemberRealmTool.getMemberById(memberId) {
            CustomUtil.pushToStrangerVC(type: .groupType, memberModel: member)
        }else{
            CustomUtil.searchUserBID(jid: jid, pushToVCWithSourceType: .groupType)
        }
    }
    
    class func searchUserBID(jid: String, pushToVCWithSourceType sourceType: SourceType) {
        
        XMPPManager.shareXMPPManager.requestUserInfo(userJid: jid, success: { (model) in
            guard let users = model.dataJson?["users"] else {
                return
            }
            
            CustomUtil.pushToStrangerVCWith(json: users, sourceType: sourceType)
        }) {
            
        }
        

    }
    
    class func pushToStrangerVC(type: SourceType, userType: UserType? = nil, contactModel: CODContactModel? = nil, memberModel: CODGroupMemberModel? = nil, businessCardModel:BusinessCardModelInfo? = nil, deleteAllHistoryBlock:(() -> Void)? = nil) {
        let personVC = CODStrangerDetailVC()
        if let model = contactModel {
            personVC.name = model.getContactNick()
            personVC.userName = model.username
            personVC.userPic = model.userpic
            personVC.gender = model.gender
            personVC.jid = model.jid
            personVC.userDesc = model.userdesc
            personVC.showType = .common
            personVC.userType = model.userTypeEnum
        }else if let member = memberModel {
            personVC.name = member.name
            personVC.userName = member.username
            personVC.userPic = member.userpic
            personVC.gender = member.gender
            personVC.jid = member.jid
            personVC.userDesc = member.userdesc
            personVC.showType = .group
            personVC.userType = member.userTypeEnum
            if member.nickname.count > 0 {
                personVC.groupNick = member.nickname
            }
        }else if let cardModel = businessCardModel {
            personVC.name = cardModel.name
            personVC.userName = cardModel.username
            personVC.userPic = cardModel.userpic
            personVC.gender = cardModel.gender
            personVC.userDesc = cardModel.userdesc
            personVC.jid = cardModel.jid
            personVC.type = .cardType
        }
        personVC.type = type
        if let userType = userType {
            personVC.userType = userType
        }
        if deleteAllHistoryBlock != nil {
            personVC.deleteAllHistoryBlock = {
                deleteAllHistoryBlock!()
            }
        }
        UIViewController.current()?.navigationController?.pushViewController(personVC, animated: true)
    }
    
    class func pushToStrangerVCWith(json: JSON, sourceType: SourceType) {
        let personVC = CODStrangerDetailVC()
        personVC.name = json["name"].stringValue
        personVC.userName = json["username"].stringValue
        personVC.userPic = json["userpic"].stringValue
        personVC.userDesc = json["userdesc"].stringValue
        personVC.gender = json["gender"].stringValue
        personVC.jid = json["jid"].stringValue
        if json["xhtype"].stringValue == "B" {
            personVC.userType = .bot
        }
        
        personVC.type = sourceType
        CODPersonInfoModel.createModel(jid: json["jid"].stringValue, name: json["name"].stringValue).addToDB()
        
        UIViewController.current()?.navigationController?.pushViewController(personVC, animated: true)
    }
    
    class func pushToPersonVC(contactModel: CODContactModel, messageModel: CODMessageModel? = nil, deleteAllHistoryBlock: (() -> Void)? = nil) {
        let personVC = CODPersonDetailVC()
        personVC.rosterId = contactModel.rosterID
        
        if let messageModel = messageModel, XMPPManager.shareXMPPManager.currentChatFriend.contains(XMPPGroupSuffix) {
            personVC.showType = .group
            let memberId = CODGroupMemberModel.getMemberId(roomId: messageModel.roomId, userName:messageModel.fromWho)
            if let member = CODGroupMemberRealmTool.getMemberById(memberId){
                if member.nickname.count > 0 {
                    personVC.groupNick = member.nickname
                }
            }
        }
        
        if deleteAllHistoryBlock != nil {
            personVC.deleteAllHistoryBlock = {
                deleteAllHistoryBlock!()
            }
        }
        
        UIViewController.current()?.navigationController?.pushViewController(personVC, animated: true)
    }
    
    class func pushToPersonVC(contactModel: CODContactModel, memberModel: CODGroupMemberModel, updateMemberInfoBlock: (() -> Void)? = nil) {
        let personVC = CODPersonDetailVC()
        personVC.rosterId = contactModel.rosterID
        personVC.showType = .group
        
        if memberModel.nickname.count > 0 {
            personVC.groupNick = memberModel.nickname
        }
        
        if updateMemberInfoBlock != nil {
            personVC.updateMemberInfoBlock = {
                updateMemberInfoBlock!()
            }
        }
        
        UIViewController.current()?.navigationController?.pushViewController(personVC, animated: true)
    }
    
}
