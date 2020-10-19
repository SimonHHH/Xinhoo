//
//  MessageViewController+GetData.swift
//  COD
//
//  Created by XinHoo on 2019/3/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

let reloadCount = 60

extension MessageViewController{
    
    func initData() {
        
        self.messageView.fetchData()
    }
    
    func addRealmNotificationToken() {
        
        if self.chatType == .groupChat {
            
            if let listModel = CODChatListRealmTool.getChatList(id: self.chatId){
                inCallNotificationToken = listModel.observe({ [weak self] (objectChange) in
                    guard let `self` = self else { return }
                    switch objectChange {
                        
                    case .error(_):
                        break
                    case .change(let properties):
                        dispatch_async_safely_to_main_queue({[weak self] in
                            guard let `self` = self else { return }
                            for property in properties.1 {

                                if property.name == "groupRtc"{
                                    self.updateInCallView()
                                }
                            }
                            
                        })
                        
                        break
                    case .deleted:
                        break
                    }
                })
            }
            
            if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId){
                notificationToken = groupModel.observe({ [weak self] (objectChange) in
                    switch objectChange {
                        
                    case .error(_):
                        break
                    case .change(let properties):
                        dispatch_async_safely_to_main_queue({[weak self] in
                            guard let `self` = self else { return }
                            for property in properties.1 {
//                                if property.name == "isValid"{
//                                    self.updateGroupIsVaild()
//                                }
                                if property.name == COD_CanSpeak{
                                    self.updateGroupIsVaild()
                                }
                                if property.name == "burn"{
                                    self.updateBurn()
                                }
                                if property.name == "showname"{
                                    self.updateShowName()
                                }
                                if property.name == "descriptions"{
                                    self.navBarTitleView.titleLabel.attributedText = self.navBarTitleView.getAttributesTitle(property.newValue as? String, isMute: self.isMute)
                                    self.title = property.newValue as? String
                                }
                                if property.name == "mute" {
                                    self.isMute = property.newValue as? Bool ?? false
                                    self.navBarTitleView.titleLabel.attributedText = self.navBarTitleView.getAttributesTitle(self.title, isMute: self.isMute)
                                }
                                if property.name == "grouppic" {
                                    self.setGroupAvatar()
                                }
                                if property.name == "userdetail" {
                                    self.navBarTitleView.setSubTitle(userDetail: property.newValue as? Bool ?? false)
                                }
                            }
                            
                        })
                        
                        break
                    case .deleted:
                        break
                    @unknown default:
                        break
                    }
                    
                })
            }
            
            
        } else if self.chatType == .privateChat {
            
            if let contactModel = CODContactRealmTool.getContactById(by: self.chatId){
                
                notificationToken = contactModel.observe({ [weak self] (change) in
                    guard let `self` = self else { return }
                    switch change{
                        
                    case .error(_):
                        break
                    case .change(let properties):
                        self.messageView.tableView.reloadData()
                        for property in properties.1 {
                            if property.name == "nick" || property.name == "name" {
                                self.title = contactModel.getContactNick()
                                self.navBarTitleView.titleLabel.attributedText = self.navBarTitleView.getAttributesTitle(contactModel.getContactNick(), isMute: self.isMute)
                            }
                            if property.name == "burn"{
                                self.updateBurn()
                            }
                            if property.name == "isValid"{
                                self.updateGroupIsVaild()
                            }
                            if property.name == "mute" {
                                self.isMute = (property.newValue as? Bool)!
                                self.navBarTitleView.titleLabel.attributedText = self.navBarTitleView.getAttributesTitle(self.title, isMute: self.isMute)

                            }
                            if property.name == "loginStatus"{
                                self.updateLoginStatus()
                            }
                            if property.name == "lastLoginTimeVisible"{
                                self.updateLoginStatus()
                            }
                        }
                        break
                    case .deleted:
                        break
                    }
                })
            }
        } else if self.chatType == .channel {
            
            if let channelModel = CODChannelModel.getChannel(by: self.chatId) {
                
                notificationToken = channelModel.observe({ [weak self] (change) in
                    
                    guard let `self` = self else { return }
                    
                    switch change{
                        
                    case .error(_):
                        break
                    case .change(let properties):
                        for property in properties.1 {
                            
                            if property.name == "mute" {
                                self.isMute = (property.newValue as? Bool)!
                                self.navBarTitleView.titleLabel.attributedText = self.navBarTitleView.getAttributesTitle(self.title, isMute: self.isMute)
                                self.updateGroupIsVaild()
                            }
                            
                            if property.name == "descriptions"{
                                self.navBarTitleView.titleLabel.attributedText = self.navBarTitleView.getAttributesTitle(property.newValue as? String, isMute: self.isMute)
                                self.title = property.newValue as? String
                            }
                            
                            if property.name == "isValid" {
                                if property.newValue as? Bool == false {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                            if property.name == "isValid"{
                                self.updateGroupIsVaild()
                            }
                            if property.name == COD_CanSpeak{
                                self.updateGroupIsVaild()
                            }
                            
                        }
                        break
                    case .deleted:
                        break
                    }
                })
            }
            
        }
    }
    
    func getGroupInfo() {
        
        
        guard let groupChat = self.chatListModel?.groupChat else {
            return
        }
        

        
        let paramDic = ["requester":"\(UserManager.sharedInstance.jid)",
            "name": COD_groupSetting,
            "itemID": self.chatId] as [String: Any]
        
        if groupChat.isValid {
            
            XMPPManager.shareXMPPManager.getRequest(param: paramDic, xmlns: COD_com_xinhoo_setting) { [weak self] (result) in
                
                guard let `self` = self else { return }
                switch result {
                    
                case .success(let model):
                    
                    guard let groupChat = self.chatListModel?.groupChat else {
                        return
                    }
                    
                    if let settingJson = model.dataJson?["setting"].dictionaryObject {
                        try! Realm.init().write {
                            groupChat.setJsonModel(jsonModel: CODGroupChatHJsonModel.deserialize(from: settingJson))
                        }
                        
                        guard let noticeContent = settingJson["noticecontent"] as? Dictionary<String, Any> else{
                            return
                        }
                        self.noticeModel = CODNoticeContentModel.deserialize(from: noticeContent)
                        if let publisher = self.noticeModel?.pulisher {
                            if publisher.count <= 0 {
                                self.noticeModel = nil
                            }else{
                                try! Realm.init().write {
                                    groupChat.notice = self.noticeModel?.notice ?? ""
                                }
                                
                                if !groupChat.readednotice {
                                    DispatchQueue.main.asyncAfter(deadline:.now()+0.5) { [weak self] in
                                        guard let `self` = self else { return }
                                        self.showNotices()
                                    }
                                    /////需要改成发IQ
                                    try! Realm.init().write {
                                        groupChat.readednotice = true
                                    }
                                    self.sendReadedNoticesIQ()
                                }
                                
                            }
                        }
                    }
                    
                    if let listModel = CODChatListRealmTool.getChatList(id: self.chatId) {
                        try! Realm.init().write {
                            listModel.stickyTop = groupChat.stickytop
                        }
                    }
                    
                    break
                    
                case .failure(_):
                    break
                    
                }
            }
            
            
        }
        
        
    }
    
    func sendReadedNoticesIQ() {
        let dict: [String : Any] = ["name": COD_changeGroup,
                                    "requester": UserManager.sharedInstance.jid,
                                    "itemID": self.chatId,
                                    "setting": ["readednotice":true]]
        
        XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_setting) { [weak self] (result) in
            switch result {
            case .success(_):
                //                CODProgressHUD.showErrorWithStatus("设置成功")
                break
            case .failure(_):
                //                CODProgressHUD.showErrorWithStatus("设置失败")
                break
            }
        }
    }
    
    
    //    func updateGroupMemberNameDic(memberModel: CODGroupMemberModel){
    //        groupMemberNameDic?[memberModel.jid] = memberModel.getMemberNickName()
    //    }
    
    func getMemberOnlineStatus(){
        
        CODGroupMemberOnlineManger.default.getGroupMembersOnlineTime(roomID: self.chatId.string)

    }
    
}


extension MessageViewController{
    

    @objc func updateTopMessage() {
        
        if self.isGroupChat{
            if let messageID = self.chatListModel?.groupChat?.topmsg{
                self.topMessageSettingSuccess(messageID: messageID)
            }
            
            if let messageID = self.chatListModel?.channelChat?.topmsg{
                self.topMessageSettingSuccess(messageID: messageID)
            }
        }
    }

    
    @objc func updateMessageUploadProgress(notification : NSNotification) {
        let model = notification.object as? CODMessageModel
        self.messageView.updateMeassageUploadProgress = model!
    }
    
    @objc func deleteMessageFromView(notification : NSNotification) {
        
        if let dic = notification.userInfo, let messageID = dic["id"] as? String {
        }
        
    }
    
}

//阅后即焚的逻辑
extension MessageViewController{
    
    func updatePendingMessage() {
        if let pendingMessages = CODChatHistoryRealmTool.getChatHistoryPendingMessage(from: self.chatId)?.filter("datetimeInt <= \(Int(Date.milliseconds) + UserManager.sharedInstance.timeStamp - 10000)"), pendingMessages.count > 0{
            dispatch_async_safely_to_main_queue({[weak self] in
                for messageModel in pendingMessages {
//                    let model = CODUploadTool.default.uploadingModel
//                    if model != nil && model?.msgID == messageModel.msgID {
//                        if model?.uploadState != CODMessageFileUploadState.UploadSucceed.rawValue && model?.status != CODMessageFileUploadState.UploadFailed.rawValue {
//                            continue
//                        }
//                    }
                   CODMessageRealmTool.updateMessageStyleByMsgId(messageModel.msgID, status: CODMessageStatus.Failed.rawValue, sendTime: messageModel.datetimeInt)
                }
                
            })
        }
    }
    
    @objc func updateGroupIsVaild() {
        
        if self.chatType == .groupChat {//群组
            self.updateTopMessageView()
            if let tipString = CustomUtil.judgeInGroupRoom(roomId: self.chatId),tipString.removeAllSapce.count > 0{
                if self.tipView.isHidden {
                    self.titleView.isUserInteractionEnabled = false
                    self.ishiddenTipView(isShow: true, tipString: tipString)
                    self.dismisskeyboard()
                }
            }else{
                if self.tipView.isHidden == false {
                    self.titleView.isUserInteractionEnabled = true
                    self.ishiddenTipView(isShow: false, tipString: "")
                }
                if CustomUtil.judgeInGroupRoomCanSpeak(roomId: self.chatId) {
                    self.channelBottomView.isHidden = true
                }else{
                    self.channelBottomView.isHidden = false
                    self.channelBottomView.setTitle(NSLocalizedString("全员禁言中", comment: ""), for: .normal)
                    self.channelBottomView.setTitleColor(UIColor.init(hexString: "#8E8E92"), for: .normal)
                    self.dismisskeyboard()
                }
            }
            
        }else if self.chatType == .channel {
            self.updateTopMessageView()
            if CustomUtil.judgeJoinChannelRoom(roomId: self.chatId) {
                let channelPower = CustomUtil.judgeInChannelRoom(roomId: self.chatId)
                if  channelPower.isManager {
                    self.titleView.isUserInteractionEnabled = true
                    self.chatBar.isHidden = false
                    self.channelBottomView.isHidden = true
                }else{
                    
                    self.titleView.isUserInteractionEnabled = true
                    self.chatBar.isHidden = true
                    self.channelBottomView.isHidden = false
                    self.channelBottomView.isSelected = channelPower.isOpenNoti
                    if channelPower.isOpenNoti {
                        self.channelBottomView.setTitle(NSLocalizedString("开启通知", comment: ""), for: .normal)
                    }else{
                        self.channelBottomView.setTitle(NSLocalizedString("关闭通知", comment: ""), for: .normal)
                    }
                    
                    self.dismisskeyboard()
                }
            }else{
                
                self.titleView.isUserInteractionEnabled = false
                self.chatBar.isHidden = true
                self.channelBottomView.isHidden = false
                self.channelBottomView.setTitle("+ 加入", for: .normal)
                self.dismisskeyboard()
            }
        }else{//单聊的时候记录是不是自己的好友
            //更新头像
            self.updateHeaderImage()
        }
    }
    
    
    
    
    func updateShowName(isUpdate: Bool = true) {
        if isUpdate {
            self.messageView.currentContentOffset = CGPoint(x: 0, y: 0)
        }else{
            self.messageView.currentContentOffset = nil
        }
        if  isGroupChat {//群组
            
            if self.chatType == .channel {
                self.showName = true
                self.messageView.showName = self.showName
            }else {
                if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId) {
                    self.showName = groupModel.showname
                    self.messageView.showName = self.showName
                }
            }
        }
    }
    func updateBurn() {
        if  isGroupChat {//群组
            if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId) {
                self.isBurn = groupModel.burn.int ?? 0
            }
        }else {
            if let contectModel = CODContactRealmTool.getContactById(by: self.chatId) {
                self.isBurn = contectModel.burn
            }
        }
    }
    
    func updateLastChatTime() {
        var lastChatMsgID: String = ""
        
        guard let model = self.messageView.messageDisplayViewVM.dataSources.first?.items.last?.messageModel, model.isInvalidated == true else {
            return
        }
        
        lastChatMsgID = model.msgID
        
        if  isGroupChat {//群组
            if CODGroupChatRealmTool.getGroupChat(id: self.chatId) != nil {
                CODGroupChatRealmTool.updateContactModelLastChatTimeStamp(by: self.chatId, lastChatTime: CustomUtil.getCurrentTime(), lastChatMsgID: lastChatMsgID)
                
            }
        }else {
            if let contectModel = CODContactRealmTool.getContactById(by: self.chatId) {
                CODContactRealmTool.updateContactModelLastChatTimeStamp(by: contectModel.jid, lastChatTime: CustomUtil.getCurrentTime(), lastChatMsgID: lastChatMsgID)
            }
        }
        
    }
    
    func deleteBurnMessage(){
        let lastChatTime = CustomUtil.getCurrentTime()
        if let chatlistModel = self.chatListModel, let chatHistory = chatlistModel.chatHistory {
            let lastMessageId = chatHistory.messages.last?.msgID
            let burnMessages = chatHistory.messages.filter("burn > 0 && msgType != 8 && datetimeInt < \(lastChatTime)")
            
            var deleteMsgs: Array<CODMessageModel> = []
            
            for msg in burnMessages {
                if (msg.burn * 1000 + msg.datetimeInt - lastChatTime) <= 0 {
                    deleteMsgs.append(msg)
                }
            }
            
            if deleteMsgs.count > 0 {
                DispatchQueue.main.async {
                    try! Realm.init().write {
                        if lastMessageId == deleteMsgs.last?.msgID {
                            chatlistModel.isShowBurned = true
                        }
                        
                        try! Realm.init().delete(deleteMsgs)
                    }
                }
            }
            
        }
    }
    
    func updateLastBurnTime() {
        let currentTime = CustomUtil.getCurrentTime()
        
        if  isGroupChat {//群组
            //            if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId) {
            //                if  (currentTime - groupModel.lastBurnTime) > (groupModel.burn.int ?? 0)*1000 {
            //                self.removeBurnTimeMessage(lastBurnTime: groupModel.lastChatTime)
            CODGroupChatRealmTool.updateContactModelLastBurnTimeStamp(by: self.chatId, lastBurnTime: currentTime)
            //                }
            //            }
        }else {
            //            if let contectModel = CODContactRealmTool.getContactById(by: self.chatId) {
            //                if  (currentTime - contectModel.lastBurnTime) > (contectModel.burn)*1000 {
            //                self.removeBurnTimeMessage(lastBurnTime: contectModel.lastChatTime)
            CODContactRealmTool.updateContactModelLastBurnTimeStamp(by: self.chatId, lastBurnTime: currentTime)
            //                }
            //            }
        }
        
    }
    
    //移除需要焚烧的消息
    func removeBurnTimeMessage(lastBurnTime: Int) {
        
        if let messageaArray = CODChatHistoryRealmTool.getChatHistoryMessage(from: self.chatId, lastMessageTime: lastBurnTime) {
            for brunMessage in messageaArray {
                
                //                print("===========kankan \(brunMessage.burn)")
                //                print("===========kankan \(brunMessage.datetimeInt)")
                //                print("===========kankan \(brunMessage.burn*1000 + brunMessage.datetimeInt - lastBurnTime)")
                if brunMessage.burn*1000 + brunMessage.datetimeInt - lastBurnTime <= 0 && brunMessage.burn > 0 && brunMessage.msgType != 8 {
                    try! Realm.init().write {
                        try! Realm.init().delete(brunMessage)
                    }
                }
            }
        }
    }
    
    private func ishiddenTipView(isShow: Bool,tipString: String?) {
        self.tipView.isHidden = !isShow
        self.chatBar.isHidden = isShow

        if IsiPhoneX {
            self.bottomView.isHidden = isShow
        }
        self.tipView.text = tipString
        if isShow {
            self.chatBar.textView.text = ""
        }

        self.updateMessageView()
        //        self.subRightButton.isUserInteractionEnabled = !isShow
        //        self.rightButton.isUserInteractionEnabled = !isShow
    }
    
    //点击图片的时候得到图片的下标
    func getPhotoMessageIndex(photoModel: CODMessageModel, imageIndex: Int = 0) -> Int? {
        return self.messageView.messageDisplayViewVM.findImageIndex(messageModel: photoModel, imageIndex: imageIndex)
    }
    
    //点击图片的时候得到图片的下标
    func getFileMessageIndex(photoModel: CODMessageModel) -> Int? {
        
        return self.fileImgArrayDic.firstIndex(where: {$0 == photoModel.msgID})
    }
    //将语音未读的消息加入数组
    func addAudioMessage(audioModel: CODMessageModel, insertLast: Bool = true) {
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: audioModel.msgType) ?? .text
        
        if modelType == .audio && audioModel.audioModel?.audioURL.count ?? 0 > 0 && audioModel.audioModel?.isPlayed == false  {
            let predicate = NSPredicate.init(format: "msgID == %@", audioModel.msgID)
            let resultArray = self.messageView.messageList.filtered(using: predicate)
            if resultArray.count > 0,let messageModel = resultArray[0] as? CODMessageModel {
                let modelIndex = self.messageView.messageList.index(of: messageModel)
                if let modelCell = self.messageView.tableView.cellForRow(at: IndexPath(row: modelIndex, section: 0)) as? CODAudioChatCell {
                    
                    self.audioArray[audioModel.msgID] = audioModel
                    self.audioCellArray[audioModel.msgID] = modelCell
                    if insertLast {
                        self.audioArrayDic.append(audioModel.msgID)
                    }else{
                        self.audioArrayDic.insert(audioModel.msgID, at: 0)
                    }
                }
            }
            
        }
    }
    
    //获取当前的这个cell是不是显示在屏幕里面
    func getMessageIndexPath(message: CODMessageModel) -> Bool{
        
        let predicate = NSPredicate.init(format: "msgID == %@", message.msgID)
        let resultArray = self.messageView.messageList.filtered(using: predicate)
        if resultArray.count > 0,let messageModel = resultArray[0] as? CODMessageModel {
            let modelIndex = self.messageView.messageList.index(of: messageModel)
            if let indexPaths = self.messageView.tableView.indexPathsForVisibleRows {
                
                for visibleIndexPath in indexPaths {
                    if visibleIndexPath.row == modelIndex {
                        return true
                    }
                }
                
            }
        }
        return false
    }
    
    //获取当前的cell
    func getMessageCellRow(message: CODMessageModel) -> Int?{
        var row: Int?
        let predicate = NSPredicate.init(format: "msgID == %@", message.msgID)
        let resultArray = self.messageView.messageList.filtered(using: predicate)
        if resultArray.count > 0,let messageModel = resultArray[0] as? CODMessageModel {
            let modelIndex = self.messageView.messageList.index(of: messageModel)
            row = modelIndex
        }
        return row
    }
    
    //点击语音的时候得到图片的下标
    func getAudioMessageIndex(audioModel: CODMessageModel) -> Int? {
        
        return self.audioArrayDic.firstIndex(where: {$0 == audioModel.msgID})
    }
    
    //点击语音的时候获取语音图标以后的数组
    func getAudioMessages(audioModel: CODMessageModel) -> ArraySlice<String> {
        
        guard self.audioArrayDic.contains(audioModel.msgID) else {
            return []
        }
        
        if let audioIndex = self.getAudioMessageIndex(audioModel: audioModel) {
            
            if audioIndex + 1 < self.audioArrayDic.count {
                let array = self.audioArrayDic.suffix(from: audioIndex+1)
                return array
            }
        }
        return []
    }
    
    //播放的时候从VC的语音的里面移除这个message
    func deleteFromAudioArray(audioModel: CODMessageModel) {
        if self.audioArrayDic.contains(audioModel.msgID) {
            self.audioArrayDic.removeAll(audioModel.msgID)
            self.audioCellArray.removeValue(forKey: audioModel.msgID)
            self.audioArray.removeValue(forKey: audioModel.msgID)
        }
    }
    
    func getVideoURL(message: CODMessageModel) -> URL? {
        return CustomUtil.getVideoURL(message: message, isCloudDisk: self.isCloudDisk)
    }
    
    func getFileURL(message: CODMessageModel) -> URL {
        return  URL(string:message.fileModel?.fileID.getImageFullPath(imageType: 0,isCloudDisk: self.isCloudDisk) ?? "") ?? URL.init(fileURLWithPath: "")
    }
    
}
