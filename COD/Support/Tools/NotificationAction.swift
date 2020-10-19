//
//  NotificationAction.swift
//  COD
//
//  Created by XinHoo on 4/30/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import MulticastDelegateSwift


protocol TargetAction {
    func performAction(jsonModel: CODMessageHJsonModel)
    func canDeinit() -> Bool
}

typealias NotiAction = ((CODMessageHJsonModel) -> Void)

struct TargetActionWrapper<T: AnyObject>:
TargetAction {
    weak var target: T?
    let action: NotiAction?
    
    func performAction(jsonModel: CODMessageHJsonModel) -> () {
        if let _ = target {
            action?(jsonModel)
        }
    }
    
    func canDeinit() -> Bool {
        
        if target == nil {
            return true
        } else {
            return false
        }
        
    }
}


class NotificationAction {
    
    
    
    var actionSels: [String: NotiAction] = [:]
    
    var actions = [String: [TargetAction]]()
    
    
    static var `default` = NotificationAction()
    
    init() {
        
        
        self.addAction(body: COD_seturlinvitjoin, handle: seturlinvitjoin)
        self.addAction(body: COD_urlinvitjoin, handle: urlInvitJoin)
        self.addAction(body: COD_QrInvitJoin, handle: qrInvitJoin)
        self.addAction(body: COD_SetQrInvitJoin, handle: setQrInvitJoin)
        self.addAction(body: COD_SetCreateJoin, handle: setCreateJoin)
        self.addAction(body: COD_InvitJoin, handle: invitJoin)
        self.addAction(body: COD_SetInvitJoin, handle: setCreateJoin)
        self.addAction(body: COD_SetKickOut, handle: setKickOut)
        self.addAction(body: COD_KickOut, handle: kickOut)
        self.addAction(body: COD_SignOut, handle: signOut)
        self.addAction(body: COD_SetSignOut, handle: setSignOut)
        
        self.addAction(body: COD_TransferOwner, handle: transferOwner)
        self.addAction(body: COD_SetNotice, handle: setNotice)
        self.addAction(body: COD_Notinvite, handle: notInvite)
        self.addAction(body: COD_CanSpeak, handle: canSpeak)
        self.addAction(body: COD_SetMucname, handle: setMucname)
        self.addAction(body: COD_XHReferall, handle: XHReferall)
        self.addAction(body: COD_xhshowallhistory, handle: xhShowAllHistory)
        self.addAction(body: COD_ChangeGroupAvatar, handle: changeGroupAvatar)
        self.addAction(body: COD_SetAdmins, handle: setAdmins)
        self.addAction(body: COD_SetAllAdmins, handle: setAdmins)
        self.addAction(body: COD_ChangeName, handle: changeName)
        self.addAction(body: COD_setBurn, handle: setBurn)
        self.addAction(body: COD_screenShot, handle: screenShot)
        self.addAction(body: COD_Stickytop, handle: stickytop)
        self.addAction(body: COD_Mute, handle: setMute)
        self.addAction(body: COD_Topmsg, handle: topMsg)
        self.addAction(body: COD_Showname, handle: showName)
        self.addAction(body: COD_Savecontacts, handle: savecontacts)
        self.addAction(body: COD_userdetail, handle: userDetail)
        
        self.addAction(body: COD_Addinvitjoinchannel, handle: createChannel)
        self.addAction(body: COD_Invitjoinchannel, handle: invitjoinchannel)
        self.addAction(body: COD_createchannel, handle: createChannel)
        self.addAction(body: COD_channeltype, handle: channelType)
        self.addAction(body: COD_channelsignmsg, handle: channelSignMsg)
        
        self.addAction(body: COD_AddRoster, handle: addRoster)
        self.addAction(body: COD_deleteRoster, handle: deleteRoster)
        self.addAction(body: COD_Bothroster, handle: bothRoster)
        self.addAction(body: COD_RemarksTelephone, handle: remarksTelephone)
        self.addAction(body: COD_Blacklist, handle: blackList)
        self.addAction(body: COD_temporaryfriend, handle: temporaryfriend)
        
        self.addAction(body: COD_Changepassword, handle: changePassword)
        self.addAction(body: COD_changePerson, handle: changePerson)
        self.addAction(body: COD_readrosterrequest, handle: readRosterRequest)
        
        self.addAction(body: COD_removeChatMsg, handle: removeMsg)
        self.addAction(body: COD_removeGroupMsg, handle: removeMsg)
        self.addAction(body: COD_removeChannelMsg, handle: removeMsg)
        self.addAction(body: COD_removeLocalChatMsg, handle: removeMsg)
        self.addAction(body: COD_removeLocalGroupMsg, handle: removeMsg)
        self.addAction(body: COD_removeclouddiskmsg, handle: removeMsg)
        
        self.addAction(body: COD_clearmsgsync, handle: clearMsgSync)
        self.addAction(body: COD_deletesessionitemsync, handle: deleteSessionItemSync)
        self.addAction(body: COD_momentsbage, handle: momentsbage)
        self.addAction(body: COD_momentsupdate, handle: momentsupdate)
        self.addAction(body: COD_clearallmsgsync, handle: clearallmsgsync)
        self.addAction(body: COD_Topranking, handle: topranking)
        
        self.addAction(body: COD_creatertcroommsg, handle: creatertcroommsg)
        self.addAction(body: COD_endrtcroommsg, handle: endrtcroommsg)
        
    }
    
    
    
    func execAction(message: XMPPMessage) {
        
        guard let jsonModel = XMPPManager.shareXMPPManager.xmppMessageToJsonMessageModel(message: message) else {
            return
        }
        
        if let sel = actionSels[jsonModel.body] {
            sel(jsonModel)
        }
        
        performActionForControlEvent(jsonModel: jsonModel)
        
        return
        
    }
    
    func addAction(body: String, handle: @escaping NotiAction) {
        actionSels[body] = handle
    }
    
    func performActionForControlEvent(jsonModel: CODMessageHJsonModel) {
        
        actions[jsonModel.body]?.forEach({ (action) in
            action.performAction(jsonModel: jsonModel)
        })
        
    }
    
    func addTarget<T: AnyObject>(target: T, body: String,
                                 action: @escaping NotiAction) {
        
        if var bodyActions = actions[body] {
            
            bodyActions.append(TargetActionWrapper(target: target, action: action))
            actions[body] = bodyActions
            
        } else {
            
            let bodyActions = [TargetActionWrapper(target: target, action: action)]
            actions[body] = bodyActions
            
        }
        
    }
    
    func removeTarget() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            
            for (key, value) in self.actions {
                
                self.actions[key] = value.filter({ (action) -> Bool in
                    return action.canDeinit() == false
                })
                
            }
            
        }
        
    }
    
    
    func urlInvitJoin(jsonModel: CODMessageHJsonModel) {
        
        if jsonModel.chatType == .groupChat {
            
            invitJoinMember(jsonModel)
        } else if jsonModel.chatType == .channel {
            invitjoinchannel(jsonModel: jsonModel)
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kUpdateGroupMemberCountNoti), object: nil)
        }
    }
    
    func seturlinvitjoin(jsonModel: CODMessageHJsonModel) {
        
        if jsonModel.chatType == .groupChat {
            
            CODGroupChatRealmTool.createGroupChat(roomID: jsonModel.roomID, json: jsonModel.settingJson)
            
        } else if jsonModel.chatType == .channel {
            CODChannelModel.createChanel(roomID: jsonModel.roomID, json: jsonModel.settingJson)
            NotificationCenter.default.post(name: NSNotification.Name.init(kNotificationUpdateChannel), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
        }
        
    }
    
    func qrInvitJoin(jsonModel: CODMessageHJsonModel) {
        invitJoinMember(jsonModel)
        
        DispatchQueue.main.async {
            if jsonModel.chatType == .groupChat {
            }else if jsonModel.chatType == .channel {
                NotificationCenter.default.post(name: NSNotification.Name.init(kNotificationUpdateChannel), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
            }
        }
    }
    
    func setQrInvitJoin(jsonModel: CODMessageHJsonModel) {
        
        if jsonModel.chatType == .groupChat {
            CODGroupChatRealmTool.createGroupChat(roomID: jsonModel.roomID, json: jsonModel.settingJson)
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        } else if jsonModel.chatType == .channel {
            CODChannelModel.createChanel(roomID: jsonModel.roomID, json: jsonModel.settingJson)
            NotificationCenter.default.post(name: NSNotification.Name.init(kNotificationUpdateChannel), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
            
        }
    }
    
    func setCreateJoin(jsonModel: CODMessageHJsonModel) {
        if jsonModel.chatType == .groupChat {
            CODGroupChatRealmTool.createGroupChat(roomID: jsonModel.roomID, json: jsonModel.settingJson)
        }
    }
    
    
    func setKickOut(jsonModel: CODMessageHJsonModel) {
        
        if jsonModel.chatType == .groupChat {
            
            if let groupModel = CODGroupChatRealmTool.getGroupChat(id: jsonModel.roomID) {
                groupModel.kickOut()
            }
        } else if jsonModel.chatType == .channel {
            
            if let channel = CODChannelModel.getChannel(by: jsonModel.roomID) {
                channel.delete()
            }
        }
    }
    
    func kickOut(jsonModel: CODMessageHJsonModel) {
        
        let members = jsonModel.settingJson["member"].arrayValue
        if jsonModel.chatType == .channel {
            
            guard let channelModel = CODChannelModel.getChannel(by: jsonModel.roomID) else {
                return
            }
            
            let members = members.map { (member) -> CODGroupMemberModel in
                let memberTemp = CODGroupMemberModel()
                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
                memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.jid.subStringTo(string: "@"))
                return memberTemp
            }
            
            channelModel.removeMembers(members)
            
            
        } else if jsonModel.chatType == .groupChat {
            let members = members.map { (member) -> CODGroupMemberModel? in
                let memberTemp = CODGroupMemberModel()
                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
                memberTemp.memberId = String(format: "%d%@", jsonModel.roomID, memberTemp.jid.subStringTo(string: "@"))
                if let member = CODGroupMemberRealmTool.getMemberById(memberTemp.memberId) {
                    return member
                }else{
                    return nil
                }
            }.compactMap { $0 }
            
            let persons = members.map { CODPersonInfoModel.createModel(jid: $0.jid, name: $0.getMemberNickName()) }
            persons.addToDB()
            
            try! Realm.init().write {
                try! Realm.init().delete(members)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kUpdateGroupMemberCountNoti), object: nil)
        }
    }
    
    fileprivate func invitJoinMember(_ jsonModel: CODMessageHJsonModel) {
        for memberTemp in jsonModel.settingJson["member"].arrayValue {
            let memberModel = CODGroupMemberModel()
            memberModel.jsonModel = CODGroupMemberHJsonModel.deserialize(from: memberTemp.dictionaryObject)
            memberModel.memberId = CODGroupMemberModel.getMemberId(roomId: jsonModel.roomID, userName: memberModel.username)
            CODGroupMemberRealmTool.deleteMemberById(memberModel.memberId)
            CODGroupChatRealmTool.insertGroupMemberByChatId(id: jsonModel.roomID, and: [memberModel])
            
        }
        
    }
    
    func invitJoin(jsonModel: CODMessageHJsonModel) {
        
        invitJoinMember(jsonModel)
        
    }
    
    func signOut(jsonModel: CODMessageHJsonModel) {
        if !jsonModel.isMeSend {
            let members = jsonModel.settingJson["member"].arrayValue.map { (member) -> CODGroupMemberModel? in
                let memberTemp = CODGroupMemberModel()
                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
                memberTemp.memberId = String(format: "%d%@", jsonModel.roomID, memberTemp.jid.subStringTo(string: "@"))
                if let member = CODGroupMemberRealmTool.getMemberById(memberTemp.memberId) {
                    return member
                }else{
                    return nil
                }
            }.compactMap { $0 }
            try! Realm.init().write {
                try! Realm.init().delete(members)
            }
            
        }
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kUpdateGroupMemberCountNoti), object: nil)

    }
    
    func setSignOut(jsonModel: CODMessageHJsonModel) {
        
        if jsonModel.isMeSend {
            if let listModel = CODChatListRealmTool.getChatList(id: jsonModel.roomID) {
                if jsonModel.chatType == .channel {
                    
                    guard let channel = listModel.channelChat else {
                        return
                    }
                    channel.delete()
                } else {
                    guard let groupModel = listModel.groupChat else{
                        return
                    }
                    try! Realm.init().write {
                        if groupModel.member.count > 0 {
                            try! Realm.init().delete(groupModel.member)
                        }
                        
                        groupModel.delete()
                    }
                    listModel.delete()
                    
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kReloadChatListNoti), object: nil, userInfo: nil)
                }
                
            }
        }
    }
    
    func transferOwner(jsonModel: CODMessageHJsonModel) {
        if let newGroupOwnerJid = jsonModel.setting?.newGroupOwner {
            CODGroupChatRealmTool.updateGroupAdminByRoomID(by: jsonModel.roomID, newAdminJid: newGroupOwnerJid, oldAdminJid: jsonModel.sender)
        }else{
            CODGroupChatRealmTool.deleteGroupMemberByChatId(id: jsonModel.roomID, and: jsonModel.sender)
        }
    }
    
    func setNotice(jsonModel: CODMessageHJsonModel) {
        if jsonModel.chatType == .groupChat {
            guard let noticeContent = CODNoticeContentModel.deserialize(from: jsonModel.settingJson["noticecontent"].dictionaryObject) else {
                return
            }
            if noticeContent.pulisher.count > 0 {
                CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, notice: noticeContent.notice)
            }
        } else if jsonModel.chatType == .channel {
            guard let channel = CODChannelModel.getChannel(by: jsonModel.roomID)  else {
                return
            }
            
            channel.updateChannel(notice: jsonModel.setting?.notice ?? "")
        }
        
    }
    
    func notInvite(jsonModel: CODMessageHJsonModel) {
        if let setting = jsonModel.setting {
            CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, notinvite: setting.notinvite)
            //TODO: 禁止邀请入群
//            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kNotificationUpdateGroupMember), object: nil)
        }
    }
    
    func canSpeak(jsonModel: CODMessageHJsonModel) {
        if jsonModel.chatType == .groupChat {
            if let setting = jsonModel.setting {
                CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, canspeak: setting.canspeak)
            }
        } else if jsonModel.chatType == .channel {
            return
        }
    }
    
    func setMucname(jsonModel: CODMessageHJsonModel) {
        
        if let setting = jsonModel.setting {
            CODGroupChatRealmTool.modifyGroupChatNameByRoomID(by: jsonModel.roomID, newRoomName: setting.description)
        }
    }
    
    func XHReferall(jsonModel: CODMessageHJsonModel) {
        if let setting = jsonModel.setting {
            CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, xhreferall: setting.xhreferall)
        }
    }
    
    func xhShowAllHistory(jsonModel: CODMessageHJsonModel) {
        ///允许查看入群前消息
        if let setting = jsonModel.setting {
            CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, showallhistory: setting.xhshowallhistory)
        }
    }
    
    func changeGroupAvatar(jsonModel: CODMessageHJsonModel) {
        if let setting = jsonModel.setting {  //头像id不变，所以不需要更新数据
            //            CODDownLoadManager.sharedInstance.updateAvatar(userPicID: setting.grouppic ?? "", complete: nil)
            let _ = CODDownLoadManager.sharedInstance.cod_loadHeader(url: URL(string: setting.grouppic?.getHeaderImageFullPath(imageType: 1) ?? ""))
        }
    }
    
    func setAdmins(jsonModel: CODMessageHJsonModel) {
        if let jids = jsonModel.settingJson["admins"].arrayObject, let isAdd = jsonModel.settingJson["isAdd"].bool {
            guard let jids = jids as? [String] else { return }
            CODGroupChatRealmTool.setAdmins(roomID: jsonModel.roomID, jids: jids, isAdd: isAdd)
            
            if jsonModel.chatType == .groupChat {
                //TODO: 设置管理员
//                DispatchQueue.main.async {
//                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kNotificationUpdateGroupMember), object: nil)
//                }
            } else if jsonModel.chatType == .channel {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kNotificationUpdateChannel), object: nil)
                }
            }
        }
    }
    
    func changeName(jsonModel: CODMessageHJsonModel) {
        ///成员更改名称，不显示message，所以不做处理
        if let setting = jsonModel.setting {
            if let nick = setting.nick {
                let memberId = CODGroupMemberModel.getMemberId(roomId: jsonModel.roomID, userName: jsonModel.sender)
                guard let member = CODGroupMemberRealmTool.getMemberById(memberId) else {
                    return
                }
                try! Realm.init().write {
                    member.nickname = nick
                }
            }
        }
    }
    
    func setBurn(jsonModel: CODMessageHJsonModel) {
        guard let setting = jsonModel.setting else {
            return
        }
        
        if jsonModel.chatType == .privateChat {
            if let contactModel = CODContactRealmTool.getContactByJID(by: jsonModel.sender) {
                try! Realm.init().write {
                    contactModel.burn = setting.burn
                }
                
            } else {
                if let contactModel = CODContactRealmTool.getContactByJID(by: jsonModel.receiver) {
                    try! Realm.init().write {
                        contactModel.burn = setting.burn
                    }
                }
            }
        }else if jsonModel.chatType == .groupChat {
            CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, burn: setting.burn)
        }
    }
    
    func screenShot(jsonModel: CODMessageHJsonModel) {
        guard let setting = jsonModel.setting else {
            return
        }
        
        if jsonModel.chatType == .privateChat {
            if let contactModel = CODContactRealmTool.getContactByJID(by: jsonModel.sender) {
                try! Realm.init().write {
                    contactModel.screenshot = setting.screenshot
                }
                
            } else {
                if let contactModel = CODContactRealmTool.getContactByJID(by: jsonModel.receiver) {
                    try! Realm.init().write {
                        contactModel.screenshot = setting.screenshot
                    }
                }
            }
        }else if jsonModel.chatType == .groupChat {
            CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, screenshot: setting.screenshot)
        }
    }
    
    func stickytop(jsonModel: CODMessageHJsonModel) {
        
        guard let setting = jsonModel.setting else { return }
        if jsonModel.chatType == .groupChat {
            CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, stickytop: setting.stickytop)
        }else if jsonModel.chatType == .channel {
            if let channel = CODChannelModel.getChannel(by: jsonModel.roomID) {
                channel.updateChannel(stickytop: setting.stickytop)
            }
        }else if jsonModel.chatType == .privateChat {
            
            if let chatList = CODChatListRealmTool.getChatList(jid: jsonModel.receiver) {
                try! Realm.init().write {
                    chatList.stickyTop = setting.stickytop ?? false
                }
            }
            if let contact = CODContactRealmTool.getContactByJID(by: jsonModel.receiver) {
                try! Realm.init().write {
                    contact.stickytop = setting.stickytop ?? false
                }
            }
        }
        
        let stickytop = jsonModel.settingJson["stickytop"].boolValue
        let jid = jsonModel.settingJson["jid"].stringValue
        
        var list: [CODChatListModel]? = nil
        
        if stickytop {
            
            if jsonModel.roomID > 0 {
                list = CustomUtil.pinChatToTop(chatId: jsonModel.roomID)
            } else {
                list = CustomUtil.pinChatToTop(jid: jid)
            }
            
            if let list = list {
                let chatJIDList = list.map { $0.jid }
                CustomUtil.topRankListHander(chatJIDList: chatJIDList, needReload: false)
            }
            
            
            
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        }
    }
    
    func setMute(jsonModel: CODMessageHJsonModel) {
        guard let setting = jsonModel.setting else { return }
        if jsonModel.chatType == .groupChat {
            CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, mute: setting.mute)
        }else if jsonModel.chatType == .channel {
            if let channel = CODChannelModel.getChannel(by: jsonModel.roomID) {
                channel.updateChannel(mute: setting.mute)
            }
        }else if jsonModel.chatType == .privateChat {
            
            if let chatList = CODChatListRealmTool.getChatList(jid: jsonModel.receiver) {
                try! Realm.init().write {
                    chatList.mute = setting.mute ?? false
                }
            }
            if let contact = CODContactRealmTool.getContactByJID(by: jsonModel.receiver) {
                try! Realm.init().write {
                    contact.mute = setting.mute ?? false
                }
            }
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        }
    }
    
    func topMsg(jsonModel: CODMessageHJsonModel) {
        guard let setting = jsonModel.setting else {
            return
        }
        if jsonModel.chatType == .groupChat {
            CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, topmsg: setting.topmsg)
            
        } else if jsonModel.chatType == .channel {
            if let channel = CODChannelModel.getChannel(by: jsonModel.roomID) {
                channel.updateChannel(topmsg: setting.topmsg)
            }
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kNotificationTopMessage), object: nil)
        }
    }
    
    func showName(jsonModel: CODMessageHJsonModel) {
        guard let setting = jsonModel.setting else {
            return
        }
        if jsonModel.chatType == .groupChat {
            CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, showname: setting.showname)
        }

    }
    
    func savecontacts(jsonModel: CODMessageHJsonModel) {
        guard let setting = jsonModel.setting else {
            return
        }
        if jsonModel.chatType == .groupChat {
            CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, savecontacts: setting.savecontacts)
        }else if jsonModel.chatType == .channel {
            if let channel = CODChannelModel.getChannel(by: jsonModel.roomID) {
                channel.updateChannel(savecontacts: setting.savecontacts)
            }
        }
    }
    
    func userDetail(jsonModel: CODMessageHJsonModel) {
        
        let userdetail = jsonModel.setting?.userdetail
        CODGroupChatRealmTool.updateGroup(roomId: jsonModel.roomID, userdetail: userdetail)
    }
    
    func invitjoinchannel(jsonModel: CODMessageHJsonModel) {
        
        guard let dic = jsonModel.settingJson.dictionaryObject else {
            return
        }
        
        guard let channel = CODChannelModel.getChannel(by: jsonModel.roomID) else {
            return
        }
        
        channel.updateChannel(isValid: true)
        
        if let memberArr = dic["member"] as? [Dictionary<String,Any>] {
            
            let members = memberArr.map { member -> CODGroupMemberModel in
                let memberTemp = CODGroupMemberModel()
                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                memberTemp.memberId = String(format: "%d%@", channel.roomID, memberTemp.username)
                return memberTemp
            }
            channel.addMembers(members)
        }
    }
    
    func createChannel(jsonModel: CODMessageHJsonModel) {
        
        guard let dic = jsonModel.settingJson.dictionaryObject else {
            return
        }
        
        guard let channelModel = CODChannelHJsonModel.deserialize(from: dic) else {
            return
        }
        
        if channelModel.roomID == 0 {
            return
        }
        
        if let channelModel = CODChannelModel.getChannel(by: channelModel.roomID) {
            channelModel.updateChannel(isValid: true)
            CODChatListModel.insertOrUpdateChannelListModel(by: channelModel, message: nil)
            
        } else {
            
            let channelModel = CODChannelModel.init(jsonModel: CODChannelHJsonModel.deserialize(from: dic)!)
            channelModel.isValid = true
            
            if let memberArr = dic["channelMemberVoList"] as? [Dictionary<String,Any>] {
                
                let members = memberArr.map { member -> CODGroupMemberModel in
                    let memberTemp = CODGroupMemberModel()
                    memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                    memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                    return memberTemp
                }
                channelModel.member.append(objectsIn: members)
            }
            
            channelModel.customName = CODGroupChatModel.getCustomGroupName(memberList: channelModel.member)
            channelModel.createDate = String(format: "%.0f", Date.milliseconds)
            CODChatListModel.insertOrUpdateChannelListModel(by: channelModel, message: nil)
        }
    }
    
    func channelType(jsonModel: CODMessageHJsonModel) {
        let setting = jsonModel.settingJson
        
        let roomID = jsonModel.roomID
        let type = CODChannelType(rawValue: setting["type"].stringValue)
        let userid = setting["userid"].stringValue
        
        if let channelModel = CODChannelModel.getChannel(by: roomID) {
            channelModel.updateChannel(channelType: type, link: userid)
        }
    }
    
    func channelSignMsg(jsonModel: CODMessageHJsonModel) {
        
        let setting = jsonModel.settingJson
        let roomID = jsonModel.roomID
        
        let signmsg = setting["signmsg"].boolValue
        if let channelModel = CODChannelModel.getChannel(by: roomID) {
            channelModel.updateChannel(signmsg: signmsg)
        }
        
    }
    
    func changePassword(jsonModel: CODMessageHJsonModel) {
        let newpassword = jsonModel.settingJson["newpassword"].stringValue
        UserManager.sharedInstance.password = newpassword
    }
    
    func addRoster(jsonModel: CODMessageHJsonModel) {
        if let addModel = CODAddFriendModel.deserialize(from: jsonModel.dataJson.dictionaryObject) {
            guard addModel.sender != UserManager.sharedInstance.jid else { return }
            
            CODChatListRealmTool.setIsInValid(id: NewFriendRosterID, isInValid: false)
            //判断是不是本地的好友
            let contact = CODContactRealmTool.getContactByJID(by: addModel.sender)
            guard contact == nil || contact?.isValid == false else { return }
            
            var newFriend = UserManager.sharedInstance.haveNewFriend
            
            var senderString = addModel.sender
            if !senderString.contains(XMPPSuffix) {
                senderString = senderString + XMPPSuffix
            }
            if let models = CODAddFriendRealmTool.getContactBySender(requester: senderString) {
                if models.count > 0{
                    for model in models {
                        if model.haveRead == false{
                            newFriend = newFriend - 1
                            if newFriend < 0 {
                                newFriend = 0
                            }
                            CODAddFriendRealmTool.updateReadAllAddFriend(fromJID: senderString, isRead: false)
                        }
                        CODAddFriendRealmTool.deleteAddFriend(by: model)
                    }
                }else{
                    CODAddFriendRealmTool.updateReadAllAddFriend(fromJID: senderString, isRead: false)
                }
            }else{
                CODAddFriendRealmTool.updateReadAllAddFriend(fromJID: senderString, isRead: false)
            }
            addModel.addType = .recived
            CODAddFriendRealmTool.insertAddFriend(by: addModel)
            CODChatListRealmTool.updateNewFriendModel(name: addModel.setting?.name, desc: addModel.setting?.request?.desc, dateTime: addModel.sendTime)
            
            dispatch_async_safely_to_main_queue{
                UserManager.sharedInstance.haveNewFriend = newFriend+1
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: HAVE_NEWFRIEND_NOTICATION), object: nil, userInfo: nil)
            }
        }
    }
    
    func deleteRoster(jsonModel: CODMessageHJsonModel) {
        
        let contactModel = CODContactModel()
        contactModel.jsonModel = CODContactHJsonModel.deserialize(from: jsonModel.settingJson.dictionaryObject)
        guard let contact = CODContactRealmTool.getContactById(by: contactModel.rosterID) else {
            return
        }
        try! Realm.init().write {
            contact.burn = 0
            contact.stickytop = false
            contact.mute = false
            contact.isValid = false
        }
        
        CODAddFriendRealmTool.deleteAddFriendApple(by: contactModel.jid)  //清除此好友的请求消息，避免判断显示互为好友的文本有误
        
        if let chatListModel = CODChatListRealmTool.getChatList(id: contactModel.rosterID) {
            try! Realm.init().write {
                chatListModel.title = contact.getContactNick()
                chatListModel.stickyTop = contact.stickytop
                chatListModel.jid = contact.jid
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
            }
        }
    }
    
    func bothRoster(jsonModel: CODMessageHJsonModel) {
        guard let setting = jsonModel.settingJson.dictionaryObject else { return }
        let contactModel = CODContactModel()
        contactModel.jsonModel = CODContactHJsonModel.deserialize(from: setting)
        contactModel.isValid = true
        if contactModel.jid.compareNoCaseForString(UserManager.sharedInstance.jid) {
            return
        }
        if let tels:Array = setting["tels"] as? Array<String> {
            for tel in tels{
                contactModel.tels.append(tel)
            }
        }
        if let chatListModel = CODChatListRealmTool.getChatList(id: contactModel.rosterID) {
            try! Realm.init().write {
                if chatListModel.contact == nil {
                    chatListModel.contact = contactModel
                }
                chatListModel.title = contactModel.getContactNick()
                chatListModel.stickyTop = contactModel.stickytop
                chatListModel.jid = contactModel.jid
            }
        }
        CODContactRealmTool.insertContact(by: contactModel)
        
        dispatch_async_safely_to_main_queue{
            UserManager.sharedInstance.haveNewFriend -= 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HAVE_NEWFRIEND_NOTICATION), object: nil, userInfo:nil)
        }
    }
    
    func remarksTelephone(jsonModel: CODMessageHJsonModel) {
        guard let setting = jsonModel.settingJson.dictionaryObject else { return }
        let contactModel = CODContactModel()
        contactModel.jsonModel = CODContactHJsonModel.deserialize(from: setting)
        
        guard let contact = CODContactRealmTool.getContactById(by: contactModel.rosterID) else {
            return
        }
        
        try! Realm.init().write {
            contact.nick = contactModel.nick
            contact.pinYin = ChineseString.getPinyinBy(contactModel.getContactNick())
            contact.descriptions = contactModel.descriptions
        }
        
        CODChatListRealmTool.updateChatListTitleByChatId(chatId: contactModel.rosterID, andTitle: contact.getContactNick())
        if let members = CODGroupMemberRealmTool.getMembersByJid(contactModel.jid) {
            try! Realm.init().write {
                for member in members {
                    member.pinYin = ChineseString.getPinyinBy(member.getMemberNickName())
                }
            }
        }
    }
    
    func blackList(jsonModel: CODMessageHJsonModel) {
        let blacklist = jsonModel.settingJson["blacklist"].boolValue
        if let contact = CODContactRealmTool.getContactByJID(by: jsonModel.receiver) {
            try! Realm.init().write {
                contact.blacklist = blacklist
            }
        }
    }
    
    func changePerson(jsonModel: CODMessageHJsonModel) {
        if let userInfo = CODUserInfoAndSetting.deserialize(from: jsonModel.settingJson.dictionaryObject) {
            UserManager.sharedInstance.userInfoSetting = userInfo
            
            var list: [CODChatListModel]? = nil
            
            if let xhnfsticktop = jsonModel.settingJson["xhnfsticktop"].bool, xhnfsticktop {
                list = CustomUtil.pinChatToTop(chatId: NewFriendRosterID)
            }
            
            if let xhassstickytop = jsonModel.settingJson["xhassstickytop"].bool, xhassstickytop {
                list = CustomUtil.pinChatToTop(chatId: CloudDiskRosterID)
            }
            
            if let list = list {
                let chatJIDList = list.map { $0.jid }
                CustomUtil.topRankListHander(chatJIDList: chatJIDList, needReload: false)
            }
            
        }
    }
    
    func readRosterRequest(jsonModel: CODMessageHJsonModel) {
        CODChatListRealmTool.setNewFriendCount(count: 0)
    }
    
    func temporaryfriend(jsonModel: CODMessageHJsonModel) {
        let contactModel = CODContactModel()
        contactModel.jsonModel = CODContactHJsonModel.deserialize(from: jsonModel.settingJson.dictionaryObject)
        
        //根据后台数据status判断该联系人改变，REMOVE 是被删除，ACTIVE 是改变或新增
        if jsonModel.settingJson["status"].stringValue == "REMOVE" {
            contactModel.isValid = false
        } else {
            contactModel.isValid = true
        }
        
        if let model = CODContactRealmTool.getContactById(by: contactModel.rosterID) {
            if model.timestamp > 0 {
                contactModel.timestamp = model.timestamp
            }
            try! Realm.init().write {
                model.loginStatus = contactModel.loginStatus
                model.lastlogintime = contactModel.lastlogintime
            }
        }else{
            CODContactRealmTool.insertContact(by: contactModel)
        }
        
        if let listModel = CODChatListRealmTool.getChatList(id: contactModel.rosterID) {
            try! Realm.init().write {
                listModel.title = contactModel.getContactNick()
                listModel.stickyTop = contactModel.stickytop
                listModel.jid = contactModel.jid
            }
        }
        
        if jsonModel.sender == UserManager.sharedInstance.jid {
            let msgCtl = MessageViewController()
            msgCtl.chatType = .privateChat
            msgCtl.toJID = contactModel.jid
            msgCtl.chatId = contactModel.rosterID
            let chatListModel = CODChatListModel()
            chatListModel.id = contactModel.rosterID
            chatListModel.chatTypeEnum = .privateChat
            chatListModel.contact = contactModel
            chatListModel.title = contactModel.getContactNick()
            chatListModel.jid = contactModel.jid
            chatListModel.icon = contactModel.userpic
            chatListModel.stickyTop = contactModel.stickytop
            msgCtl.chatListModel = chatListModel
            msgCtl.title = contactModel.getContactNick()
            
            if let tab = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                if let rootController = tab.selectedViewController as? UINavigationController {
                    rootController.popToRootViewController(animated: true)
                    rootController.pushViewController(msgCtl, animated: true)
                }
            }else{
                UIViewController.current()?.navigationController?.popToRootViewController(animated: true)
                UIViewController.current()?.navigationController?.pushViewController(msgCtl, animated: true)
            }
        }
    }
    
    func removeMsg(jsonModel: CODMessageHJsonModel) {
        guard let settingModel = SettingModel.deserialize(from: jsonModel.settingJson.dictionaryObject) else {
            print("解析removeMsg.setting错误")
            return
        }
        var jid = ""
        
        if jsonModel.chatType == .privateChat {
            jid = jsonModel.sender
        }else{
            jid = jsonModel.receiver
        }
        
        //如果是当前聊天对象，直接回调到MessageViewController
        if XMPPManager.shareXMPPManager.currentChatFriend == jid ||
            (jid == UserManager.sharedInstance.jid && XMPPManager.shareXMPPManager.currentChatFriend == jsonModel.receiver) {
            
            if (XMPPManager.shareXMPPManager.removeMsgBlock != nil) {
                if settingModel.msgID.count > 0 {
                    for msgId in settingModel.msgID {
                        XMPPManager.shareXMPPManager.removeMsgBlock(msgId)
                    }
                }
            }
            //删除会话的时候要去通知”呼叫“模块更新列表
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadCallVC), object: nil, userInfo:nil)
            }
        }else{
            if settingModel.msgID.count > 0 {
                for msgId in settingModel.msgID {
                    if let messageModel = CODMessageRealmTool.getMessageByMsgId(msgId) {
                        
                        try! Realm.init().safeWrite {
                            
                            if let messageHistoryModelTemp = CODChatListRealmTool.getChatList(jid: jid) {
                                
                                if messageHistoryModelTemp.count > 0 {
                                    messageHistoryModelTemp.count -= 1
                                }
                                
                                for refertoString in messageHistoryModelTemp.referToMessageID {
                                    let dic = refertoString.getDictionaryFromJSONString()
                                    if (dic["msgId"] as! String) == messageModel.msgID {
                                        messageHistoryModelTemp.referToMessageID.remove(at: messageHistoryModelTemp.referToMessageID.index(of: refertoString)!)
                                        break
                                    }
                                }
                            }
                            CODMessageRealmTool.deleteMessage(by: messageModel.msgID)
                        }
                    }
                }
                
                if let messageHistoryModelTemp = CODChatListRealmTool.getChatList(jid: jid) {
                    let lastMsg = messageHistoryModelTemp.chatHistory?.messages.filter("isDelete == false").sorted(byKeyPath: "datetime", ascending: true).last
                    CODChatListRealmTool.updateLastDateTimeWithDeleteMsg(id: messageHistoryModelTemp.id, lastDateTime: lastMsg?.datetime ?? "0")
                }
            }
            //删除会话的时候要去通知”呼叫“模块更新列表
            
            
            XMPPManager.shareXMPPManager.multicastDelegate |> { delegate in
                delegate.deleteMessage(message: jsonModel)
            }
            
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadCallVC), object: nil, userInfo:nil)
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
            }
            
            
        }
    }
    
    func deleteSessionItemSync(jsonModel: CODMessageHJsonModel) {
        
        if let model = CODChatListRealmTool.getChatList(jid: jsonModel.receiver) {
            
            if model.jid == XMPPManager.shareXMPPManager.currentChatFriend {
                let alert = UIAlertController(title: nil, message: "该会话已被删除", preferredStyle: .alert)
                alert.addAction(title: "确定", style: .cancel, isEnabled: true) { [weak alert] (action) in
                    guard let alert = alert else {
                        return
                    }
                    alert.dismiss(animated: true) {
                        
                        UIViewController.current()?.navigationController?.popToRootViewController(animated: true)
                    }
                }
                UIViewController.current()?.present(alert, animated: true, completion: nil)
            }
            CODFileManager.shareInstanceManger().deleteEMConversationFilePath(sessionID: model.jid)
            CODChatListRealmTool.removeChatList(id: model.id)
            
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
        
    }
    
    func clearMsgSync(jsonModel: CODMessageHJsonModel) {
        
        if let model = CODChatListRealmTool.getChatList(jid: jsonModel.receiver) {
            CODFileManager.shareInstanceManger().deleteEMConversationFilePath(sessionID: model.jid)
            CODChatListRealmTool.deleteChatListHistory(by: model.id)
            
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
        
    }
    
    func momentsbage(jsonModel: CODMessageHJsonModel) {
        
        let decoder = JSONDecoder()
        
        guard let model = try? decoder.decode(CODDiscoverNotificationJsonModel.self,
                                              from: jsonModel.settingJson.rawData()) else {
                                                return
        }
        
        if model.messageStatus == .normal {
            UserManager.sharedInstance.spreadMessageCount += 1
        }
        
        guard let moments = CODDiscoverMessageModel.getModel(serverMsgId: model.momentsId.string) else { return }
        
        switch model.messageType {
        case .comment:
            
            if model.messageStatus == .normal {
                
                let replyModel = CODDiscoverReplyModel.createModel(serverId: model.messageId.string, sender: jsonModel.sender, replayUser: model.replayUser, comments: model.comments ?? "")
                moments.addReply(replyModel: replyModel)
                
            } else {
                
                moments.deleteComment(serverId: model.messageId.string)
                
            }
            
            
            
        case .like:
            
            if model.messageStatus == .normal {
                let liker = CODPersonInfoModel.createModel(jid: jsonModel.sender, name: model.userNickName, userpic: model.userPic)
                moments.addLiker(liker: liker)
            } else {
                moments.removeLiker(jsonModel.sender)
            }
            
            
            
        default:
            break
        }
        
        
        
    }
    
    func momentsupdate(jsonModel: CODMessageHJsonModel) {
        guard let setting = jsonModel.settingJson.dictionaryObject, let userpic = setting["userPic"] as? String else {
            return
        }
        UserManager.sharedInstance.circleFirstPic = userpic.getHeaderImageFullPath(imageType: 0)
    }
    
    func topranking(jsonModel: CODMessageHJsonModel) {
        
        if let chatList = jsonModel.settingJson.arrayObject as? [String] {
            CustomUtil.topRankListHander(chatJIDList: chatList)
        }
        
    }
    
    
    /// 后台清除所有聊天信息
    /// - Parameter jsonModel: 通知消息jsonModel
    func clearallmsgsync(jsonModel: CODMessageHJsonModel) {
        
        
        let realm = try? Realm()
        let normalArr = realm?.objects(CODChatListModel.self).filter("isInValid == \(false)")
        normalArr?.forEach({ (model) in
            
            if model.jid == XMPPManager.shareXMPPManager.currentChatFriend {
                let alert = UIAlertController(title: nil, message: "该会话已被删除", preferredStyle: .alert)
                alert.addAction(title: "确定", style: .cancel, isEnabled: true) { [weak alert] (action) in
                    guard let alert = alert else {
                        return
                    }
                    alert.dismiss(animated: true) {
                        
                        UIViewController.current()?.navigationController?.popToRootViewController(animated: true)
                    }
                }
                UIViewController.current()?.present(alert, animated: true, completion: nil)
            }
            CODFileManager.shareInstanceManger().deleteEMConversationFilePath(sessionID: model.jid)
            CODChatListRealmTool.removeChatList(id: model.id)
            
        })
        
        
        if let model = CODChatListRealmTool.getChatList(id: NewFriendRosterID) {
            
            try? realm?.safeWrite {
                
                model.title = ""
                model.subTitle = ""
                model.count = 0
                model.lastDateTime = "0"
            }
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
        
    }
    
    /// 群语音通话创建通知
    /// - Parameter jsonModel: 通知消息jsonModel
    func creatertcroommsg(jsonModel: CODMessageHJsonModel) {
        
        let room = jsonModel.settingJson.dictionaryObject?["room"]
        
        if let model = CODChatListRealmTool.getChatList(jid: jsonModel.receiver) {
            
            try? Realm().safeWrite {
                model.groupRtc = 1
                model.groupRtcRoomId = room as? String ?? ""
            }
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
    }
    
    
    /// 群语音通话创建通知
    /// - Parameter jsonModel: 通知消息jsonModel
    func endrtcroommsg(jsonModel: CODMessageHJsonModel) {
        
        if let model = CODChatListRealmTool.getChatList(jid: jsonModel.receiver) {
            
            try? Realm().safeWrite {
                model.groupRtc = 0
                model.groupRtcRoomId = ""
            }
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
    }
    
}
