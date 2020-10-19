//
//  MessageViewController+CODChatBarDelegate.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

// MARK: - CODChatBarDelegate
extension MessageViewController:CODChatBarDelegate{
    
    func presentGroupMember() {
        if self.isGroupChat {
            
            if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId){
                
                if groupModel.isICanCheckUserInfo() == false {
                    return
                }
                
                let groupMember = CODGroupMemberViewController()
                groupMember.userpic = groupModel.grouppic
                groupMember.memberArr = groupModel.member
                let memberId = CODGroupMemberModel.getMemberId(roomId: self.chatId, userName: UserManager.sharedInstance.jid)
                let member = CODGroupMemberRealmTool.getMemberById(memberId)
                var isAdmin = false
                if member!.userpower < 30 {
                    isAdmin = true
                }else {
                    isAdmin = false
                }
                groupMember.chatId = groupModel.chatId
                groupMember.isAdmin = isAdmin
                groupMember.delegate = self
                groupMember.location = self.chatBar.textView.selectedRange.location
                self.chatBar.changeVoiceImage()
                let nav = UINavigationController.init(rootViewController: groupMember)
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    ///状态变化
    func  chatBarChange(chatBar: CODChatBar, fromStatus: CODChatBarStatus, toStatus: CODChatBarStatus) {
        
        if (curStatus == toStatus) {
            if curStatus == .CODChatBarStatusVoice || curStatus == .CODChatBarStatusMore  {
                self.dismisskeyboard()
            }
            return
        }
        lastStatus = fromStatus
        curStatus = toStatus
        //        if fromStatus == .CODChatBarStatusEmoji{
        //            self.emojiKeyboard.dismissWithAnimation(animation: true)
        //        }
        //        if fromStatus == .CODChatBarStatusMore{
        //            self.moreKeyboard.dismissWithAnimation(animation: true)
        //        }
        //        if fromStatus == .CODChatBarStatusVoice{
        //            self.recordKeyboared.dismissWithAnimation(animation: true)
        //        }
        if toStatus == .CODChatBarStatusInit {
            if fromStatus == .CODChatBarStatusEmoji{
                self.emojiKeyboard.dismissWithAnimation(animation: true)
            }
            if fromStatus == .CODChatBarStatusMore{
                self.moreKeyboard.dismissWithAnimation(animation: true)
            }
            if fromStatus == .CODChatBarStatusVoice{
                self.recordKeyboared.dismissWithAnimation(animation: true)
            }
        }else if(toStatus == .CODChatBarStatusVoice){
            self.recordKeyboared.isHidden = false
            self.recordKeyboared.showInView(view: self.view, animation: true)
        }else if(toStatus == .CODChatBarStatusEmoji){
            //            self.emojiKeyboard.emojiDisplayView.commonFaceButtonDown()
            if self.chatBar.textView.text.count == 0 {
                //                self.emojiKeyboard.emjioGroupControl.sendButton.isEnabled = false
                //                self.emojiKeyboard.emjioGroupControl.sendButton.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
            }else{
                //                self.emojiKeyboard.emjioGroupControl.sendButton.isEnabled = true
                //                self.emojiKeyboard.emjioGroupControl.sendButton.backgroundColor = UIColor.init(hexString: kSubmitBtnBgColorS)
            }
            self.emojiKeyboard.showInView(view: self.view, animation: true)
        }else if(toStatus == .CODChatBarStatusMore){
            self.checkRecentPhoto()
            self.moreKeyboard.showInView(view: self.view, animation: true)
        }else if(toStatus == .CODChatBarStatusKeyboard) {
            
        }
    }
    
    func checkRecentPhoto() {
        CODRecentPhotoView.recentPhoto.showRecentPhoto(showView: self.chatBar)
        CODRecentPhotoView.recentPhoto.delegate = self
    }
    
    ///高度变化
    func changeTextViewHeight(chatBar: CODChatBar, height: CGFloat) {

        self.updateMessageView()
        self.view.layoutIfNeeded()
//        self.messageView.scrollToBottomWithAnimation(animation: false)
    }
    ///开始录音
    func chatBarStartRecording(chatBar: CODChatBar) {
        self.view.isUserInteractionEnabled = false
        self.view.addSubview(self.recorderIndicatorView)
        //        self.recorderIndicatorView.removeFromSuperview()
        self.recorderIndicatorView.status = .CODRecorderStatusRecording
        self.recorderIndicatorView.snp.remakeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 150, height: 150))
        }
        AudioRecordInstance.delegate = self
        AudioRecordInstance.startRecord()
        
    }
    //取消录音
    func chatBarDidCancelRecording(chatBar: CODChatBar) {
        self.recorderIndicatorView.status = .CODRecorderStatusWillCancel
        self.recorderIndicatorView.countDown = 0
        let time: TimeInterval = 0.5
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            self.recorderIndicatorView.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }
        AudioRecordInstance.cancelRrcord()
    }
    ///将要取消
    func chatBarWillCancelRecording(chatBar: CODChatBar, cancle: Bool) {
        self.recorderIndicatorView.status = cancle ? .CODRecorderStatusWillCancel:.CODRecorderStatusRecording
    }
    ///完成录音
    func chatBarFinishedRecoding(chatBar: CODChatBar) {
        //        self.recorderIndicatorView.status = .CODRecorderStatusTooShort
        self.view.isUserInteractionEnabled = true
        AudioRecordInstance.stopRecord()
    }
    
    ///关闭键盘
    func dismisskeyboard() {
        CODRecentPhotoView.recentPhoto.dismissRecentPhoto()

        if self.isRecording {
            return
        }
        self.chatBar.textView.resignFirstResponder()
        self.chatBar.initialization()
        if curStatus == .CODChatBarStatusMore{
            self.moreKeyboard.dismissWithAnimation(animation: true)
        }else if(curStatus == .CODChatBarStatusEmoji){
            self.chatBar.snp.updateConstraints { (make) in
                make.bottom.equalTo(self.view.snp.bottom).offset(-kSafeArea_Bottom)
            }
            self.emojiKeyboard.snp.updateConstraints({ (make) in
                make.height.equalTo(HEIGHT_CHAT_KEYBOARD+CGFloat(kSafeArea_Bottom))
            })
            self.view.needsUpdateConstraints()
            self.view.updateConstraintsIfNeeded()
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            self.emojiKeyboard.dismissWithAnimation(animation: true)
        } else if(curStatus == .CODChatBarStatusVoice){
            self.recordKeyboared.dismissWithAnimation(animation: true)
        }
        curStatus = .CODChatBarStatusInit
    }
}

extension MessageViewController:RecordAudioDelegate{
    
    /// 更新录音的音量大小
    ///
    /// - Parameter audiotime: 音量大小
    func audioRecordVolume(_ volume: Float){
        //        self.recorderIndicatorView.volume = CGFloat(volume)
    }
    /// 更新录音的时间
    ///
    /// - Parameter audiotime: 录音的时间
    func audioRecordTime(_ audioTime:Int){
        self.recordKeyboared.recordTime = audioTime
        if audioTime >= 55 {
            let countNumber = Int(60 - audioTime)
            if(countNumber >= 0 && countNumber <= 10){
                self.recorderIndicatorView.countDown = countNumber
                self.recorderIndicatorView.status = .CODRecorderStatusCountDown
            }else{
                
            }
        }
    }
    /**
     录音太短
     */
    func audioRecordTooShort(){
        self.recorderIndicatorView.status = .CODRecorderStatusTooShort
        self.view.isUserInteractionEnabled = true
        AudioRecordInstance.cancelRrcord()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
            self.recorderIndicatorView.removeFromSuperview()
        }
 
    }
    /**
     录音失败
     */
    func audioRecordFailed(){
    }
    
    /**
     取消录音
     */
    func audioRecordCanceled(){
    }
    
    /**
     录音完成
     
     - parameter recordTime:        录音时长
     - parameter uploadAmrData:     上传的 amr Data
     - parameter fileHash:          音频数据的文件地址
     */
    func audioRecordFinish(recordTime: Float, disPlayName:String,fileName: String){
        self.recorderIndicatorView.countDown = 0
        self.recorderIndicatorView.removeFromSuperview()
        self.view.isUserInteractionEnabled = true
        if recordTime == 0 {
            print("录音时间和录音的路径 \(fileName) shijian\(recordTime)")
        }
        
        let audioAsset = AVURLAsset.init(url: URL.init(fileURLWithPath: fileName))
        let audioDuration = audioAsset.duration
        var audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        
        if audioDurationSeconds < 0.5 {
            self.audioRecordTooShort()
            return
        }
        
        if audioDurationSeconds  < 1 {
            audioDurationSeconds = 1
        }
        if audioDurationSeconds  > 60 {
            audioDurationSeconds = 60
        }
        
        //        if recordTime >= 1 {
        self.sendVoiceMessage(audioLocalPath: fileName, displayName: disPlayName, duration: Int(audioDurationSeconds), toJID: self.toJID)
        self.recorderIndicatorView.removeFromSuperview()
        //        }
    }
}


extension MessageViewController:CODGroupMemberViewControllerDelegate{
    
    func clickCell(model: CODGroupMemberModel, location: Int) {
        
        let mutableAttStr = NSMutableAttributedString.init(attributedString: self.chatBar.textView.attributedText)
        
        let nameAttribute = NSAttributedString.init(string: "\(model.zzs_getMemberNickName())", attributes: [.font : IMChatTextFont,.foregroundColor : UIColor.init(hexString: "#1D49A7") as Any])
        
        mutableAttStr.insert(nameAttribute, at: location)
        mutableAttStr.insert(NSAttributedString.init(string: " ", attributes: [.font : IMChatTextFont]), at: location + nameAttribute.length)
        
        let str = "\(model.zzs_getMemberNickName()) " as NSString
        
        let attachment = YYTextAttachment.init(content:nil)
        attachment.userInfo = ["jid":model.jid]
        
        mutableAttStr.yy_setTextAttachment(attachment, range: NSRange.init(location: location - 1, length: str.length))
        
        self.chatBar.textView.attributedText = mutableAttStr
        
        self.chatBar.textView.selectedRange = NSMakeRange(location+str.length, 0)
        self.chatBar.memberNotificationArr.append(model)
    }
}

extension MessageViewController: ChatBarTextViewDelegate {
    func chatBarTextViewDidEndEdit(textView: UITextView) {
        guard !self.isGroupChat else {
            return
        }
        XMPPManager.shareXMPPManager.sendChatStateTo(userName: self.toJID, chatState: XMPPMessage.ChatState.paused)
    }
    
    func chatBarTextViewDidChangeEdit(textView: UITextView) {
        guard !self.isGroupChat else {
            return
        }
        if sendChatStateTimer != nil {
            self.sendChatStateTimer.invalidate()
        }
        
        self.sendChatStateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { [weak self](time) in
            XMPPManager.shareXMPPManager.sendChatStateTo(userName: self?.toJID ?? "", chatState: XMPPMessage.ChatState.paused)
            self?.sendChatStateTimer.invalidate()
            self?.sendChatStateTimer = nil
        })
        
        if isNeedSendComposing {
            XMPPManager.shareXMPPManager.sendChatStateTo(userName: self.toJID, chatState: XMPPMessage.ChatState.composing)
            self.isNeedSendComposing = false
            Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { [weak self](time) in
                self?.isNeedSendComposing = true
            })
        }
        
    }
    
    
}

extension MessageViewController{
    func hiddenMultipleSelectionView(isHidden: Bool) {
        
        if self.chatType == .channel {
            let channleResult = CustomUtil.judgeInChannelRoom(roomId: self.chatId)
            self.multipleSelectionView.deleteBtn.isHidden = !channleResult.isManager
        }
        
        self.multipleSelectionView.shareBtn.isHidden = !(chatListModel?.groupChat?.isICanCheckUserInfo() ?? true)
        
        if isHidden {
            self.multipleTopView.removeFromSuperview()
        }else{
            
            self.navigationController?.navigationBar.addSubview(self.multipleTopView)
            self.multipleTopView.deleteBtn.setTitle(NSLocalizedString("全部删除", comment: ""), for: .normal)
            self.multipleTopView.shareBtn.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
            self.multipleTopView.deleteBtn.addTarget(self, action: #selector(removeAllMessage), for: .touchUpInside)
            self.multipleTopView.shareBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            self.multipleTopView.deleteBtn.setImage(nil, for: .normal)
            self.multipleTopView.shareBtn.setImage(nil, for: .normal)
            self.multipleTopView.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: self.navigationController?.navigationBar.frame.height ?? 0)
        }
        
        self.multipleSelectionView.isHidden = isHidden
        var ishiddenChatBar = true
        if self.chatType == .channel {
            let channleResult = CustomUtil.judgeInChannelRoom(roomId: self.chatId)
            ishiddenChatBar = channleResult.isManager
        }
        if ishiddenChatBar {
            self.chatBar.isHidden = !isHidden
        }else{
            self.channelBottomView.isHidden = !isHidden
        }
        
        if !isHidden{
            self.hideSearchToolView()
            if  self.replyMessage.msgID != "0" {
                self.editView.isHidden = true
                if ishiddenChatBar {
                    self.chatBar.isEdit = false
                }
                
            }
            self.replyMessage = CODMessageModel()
            if  self.editMessage.msgID != "0" {
                self.editView.isHidden = true
                if ishiddenChatBar {
                    self.chatBar.isEdit = false
                }
            }
            self.editMessage = CODMessageModel()
            if  self.transMessage.msgID != "0" {
                self.editView.isHidden = true
                if ishiddenChatBar {
                    self.chatBar.isEdit = false
                }
            }
            self.transMessage = CODMessageModel()
            self.dismisskeyboard()
            if self.isSearch {
                self.searchBarCancelButtonClicked(self.searchBar)
            }
        }
    }
    
    @objc func multipleSelectionDelete() {
        
        print("多选删除")
        guard let indexList = self.messageView.tableView.indexPathsForSelectedRows else {
            return
        }
        
        var btnArr: Array<String> = Array()
        
        /// 是否是十分钟以内的消息
        var is_inTenMinutes = true
        

        var removeTime:Double = 600
//        if self.chatType != .privateChat {
            #if MANGO
            removeTime = 172800

            #elseif PRO
            removeTime = 86400

            #else
            removeTime = 600
            
            #endif
//        }
        
        /// 是否全部来自自己的消息
        var is_allOneself = true
        
        var msgIDList = Array<String>()
        var msgIDFailList = Array<String>()

        
        //添加一个判断。如果是发送失败的消息，就只进行本地删除
        for indexPath in indexList {
            guard let model = self.messageView.messageDisplayViewVM.dataSources.first?.items[indexPath.row].messageModel else {
                return
            }
            
            if (CustomUtil.getTimeDiff(starTime: model.datetime as NSString, endTime: "\(Int(Date.milliseconds))" as NSString) > removeTime) {
                is_inTenMinutes = false
            }
            
            if !UserManager.sharedInstance.jid.contains(model.fromWho) {
                is_allOneself = false
            }
            if model.statusType == .Failed {
                msgIDFailList.append(model.msgID)
            }else{
                msgIDList.append(model.msgID)
            }
        }
        
        /// 所有消息都是在十分钟内的消息
        if is_inTenMinutes {
            
            /// 所有消息都是来自自己
            if is_allOneself {
                
                /* 所选消息都是十分钟以内的消息并且都是来自于自己，能双向删除 */
                btnArr = ["消息双向删除","从本地删除"]
                
            }else{
                
                /// 如果是群聊则判断当前操作用户权限是否是管理员
                if self.isGroupChat {
                    let memberId = CODGroupMemberModel.getMemberId(roomId: self.chatId, userName: UserManager.sharedInstance.jid)
                    let member = CODGroupMemberRealmTool.getMemberById(memberId)
                    var isAdmin = false
                    if member?.userpower ?? 30 < 30 {
                        isAdmin = true
                    }else {
                        isAdmin = false
                    }
                    
                    if isAdmin {
                        
                        /* 所选消息都是十分钟以内的消息 但是包含对方的消息（群聊，管理员），能双向删除 */
                        btnArr = ["消息双向删除","从本地删除"]
                    }else{
                        
                        /* 所选消息都是十分钟以内的消息 但是包含对方的消息（群聊，非管理员），不能双向删除 */
                        btnArr = ["从本地删除"]
                    }
                    
                }else{
                    
                    /* 所选消息都是十分钟以内的消息 但是包含对方的消息（非群聊），不能双向删除 */
                    btnArr = ["从本地删除"]
                }
            }
            
            if msgIDFailList.count > 0 {
                btnArr = ["从本地删除"]
            }
        }else{
            
            /* 所选消息有超出十分钟以内的消息，不能双向删除 */
            btnArr = ["从本地删除"]
        }
        
        if self.isCloudDisk {
            if btnArr.contains("从本地删除") {
                btnArr.removeAll("从本地删除")
                btnArr.append("删除")
            }
        }
        if self.chatId == 0 {
            btnArr = ["删除"]
        }
        if self.chatType == .channel {
            btnArr = ["为所有人删除"]
        } 
        CODActionSheet.show(withTitle: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: btnArr, cancelButtonColor: UIColor.init(hexString: "#367CDE"), destructiveButtonColor: UIColor.init(hexString: "#367CDE"), otherButtonColors: [UIColor.red,UIColor.red]) { (actionSheet, index) in
            
            if index != 0 {
                
                if btnArr.count == 2 {
                    
                    if index == 1{
                        self.sendRemoveMessageIQ(isGroup: self.isGroupChat, isLocal: false, msgIDs: msgIDList)
                    }else{
                        self.sendRemoveMessageIQ(isGroup: self.isGroupChat, isLocal: true, msgIDs: msgIDList)
                    }
                    
                }else if btnArr.count == 1 {
                    if self.chatType == .channel {
                        self.sendRemoveMessageIQ(isGroup: self.isGroupChat, isLocal: false, msgIDs: msgIDList)
                    }else{
//                        self.messageView.messageDisplayViewVM.removeMeesage.accept([msgIDFailList])
                        self.messageView.messageDisplayViewVM.cellDeleteMessage(msgIDs: msgIDFailList)
                        if msgIDList.count > 0 {
                            self.sendRemoveMessageIQ(isGroup: self.isGroupChat, isLocal: true, msgIDs: msgIDList)
                        }
                    }
                }
                
                for msgID in msgIDList {
                    
                    if CODAudioPlayerManager.sharedInstance.isPlaying() {
                        if CODAudioPlayerManager.sharedInstance.playModel?.msgID == msgID {
                            CODAudioPlayerManager.sharedInstance.stop()
                        }
                    }
//
//                    do {
//                        let realm = try Realm()
//                        try realm.write {
//
//                            guard let chatHistory = CODChatHistoryRealmTool.getChatHistory(from: self.chatId) else{
//                                return
//                            }
//                            guard let message = CODMessageRealmTool.getMessageByMsgId(model.msgID) else{
//                                return
//                            }
//                            chatHistory.messages.remove(at: chatHistory.messages.index(of: message)!)
//                            realm.delete(message)
//
//                        }
//                    }catch{
//                    }
                }
                
                
                self.messageView.messageDisplayViewVM.isMultipleSelelct.accept(false)
                
                //TODO: removeObjects
                
                //                self.messageView.messageDisplayViewVM.dataSources.first?.items
//                self.messageView.messageList.removeObjects(at: set)
//                self.messageView.tableView.reloadData()
                
                DispatchQueue.main.async {
                    self.cancel()
                }
            }
        }
    }
    
    func sendRemoveMessageIQ(isGroup: Bool, isLocal: Bool,msgIDs: Array<String>) {
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus(NSLocalizedString("网络请求失败，请稍后再试", comment: ""))
            return
        }
        if isLocal {
            //删除本地的消息
            self.sendRemoveMsgIQ_Local(isGroup: isGroupChat, msgIDs: msgIDs)
//            self.messageView.messageDisplayViewVM.removeMeesage.accept(msgIDs)
        }else{
            //双向删除 单聊  为所有人删除 群聊
            self.sendRemoveMsgIQ(isGroup: isGroupChat, msgIDs: msgIDs)
        }
    }
    
    func sendRemoveMsgIQ_Local(isGroup: Bool,msgIDs: Array<String>) {
        var dict = ["requester":UserManager.sharedInstance.jid,
                    "msgID":msgIDs] as [String : Any]
        if isGroup {
            dict["name"] = COD_removeLocalGroupMsg
        }else{
            if self.isCloudDisk {
                dict["name"] = COD_removeclouddiskmsg
            }else{
                dict["name"] = COD_removeLocalChatMsg
            }
        }
        dict["receiver"] = XMPPManager.shareXMPPManager.currentChatFriend
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_message, actionDic: dict as NSDictionary)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func sendRemoveMsgIQ(isGroup: Bool,msgIDs: Array<String>) {
        var dict = ["requester":UserManager.sharedInstance.jid,
                    "msgID":msgIDs] as [String : Any]
        if self.chatType == .groupChat {
            dict["name"] = COD_removeGroupMsg
        } else if self.chatType == .channel{
            dict["name"] = COD_removeChannelMsg
        } else {
            dict["name"] = COD_removeChatMsg
        }
        dict["receiver"] = XMPPManager.shareXMPPManager.currentChatFriend
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_message, actionDic: dict as NSDictionary)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    @objc func multipleSelectionShare() {
        print("多选分享")
        guard let indexList = self.messageView.tableView.indexPathsForSelectedRows else {
            return
        }
        var msgIDList = Array<CODMessageModel>()
        for indexPath in indexList {
            guard let model = self.messageView.messageDisplayViewVM.dataSources.first?.items[indexPath.row].messageModel else {
                return
            }
            msgIDList.append(model)
        }
        self.retransionMessage(messages: msgIDList)
    }
    
    
    /// 全部删除
    @objc func removeAllMessage() {
        
        let alert = UIAlertController(title: NSLocalizedString("确认删除所有消息？", comment: ""), message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: NSLocalizedString("全部删除", comment: ""), style: .destructive) { (action) in
            if CODAudioPlayerManager.sharedInstance.isPlaying() {
                CODAudioPlayerManager.sharedInstance.playModel = nil
                CODAudioPlayerManager.sharedInstance.stop()
            }
            
            self.messageView.messageDisplayViewVM.removeAllMessage.accept(Void())
            //                self.messageView.tableView.reloadData()
            self.cancel()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel) { (action) in
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func cancel() {
        
//        guard let indexList = self.messageView.tableView.indexPathsForSelectedRows else {
//
//            self.hiddenMultipleSelectionView(isHidden: self.messageView.tableView.isEditing)
//            self.messageView.tableView.setEditing(!self.messageView.tableView.isEditing, animated: false)
//            XinhooTool.isEdit_MessageView = self.messageView.tableView.isEditing
//            NotificationCenter.default.post(name: NSNotification.Name.init("kCellMoreAction"), object: self.messageView.tableView.isEditing)
//            self.messageView.tableView.reloadData()
//            return
//        }
        
        if let indexList = self.messageView.tableView.indexPathsForSelectedRows {
            
            for indexPath in indexList {
                self.messageView.messageDisplayViewVM.dataSources.first?.items[indexPath.row].isSelect = false
            }
            
            
        }
        
        self.messageView.messageDisplayViewVM.isMultipleSelelct.accept(false)
        
        self.hiddenMultipleSelectionView(isHidden: self.messageView.tableView.isEditing)
        self.messageView.tableView.setEditing(!self.messageView.tableView.isEditing, animated: false)
        XinhooTool.isEdit_MessageView = self.messageView.tableView.isEditing
        NotificationCenter.default.post(name: NSNotification.Name.init("kCellMoreAction"), object: self.messageView.tableView.isEditing)
        
//        self.messageView.tableView.reloadData()
        
    }
    
    //转发消息
    func retransionMessage(messages: Array<CODMessageModel>) {
        let messagesTemp = messages.sorted(by: \.datetimeInt, ascending: true)
        let fileIDs = CustomUtil.getMessageFileIDS(messages: messagesTemp)
        
        //服务器不存在的话在进入判断本地是不是存在这个文件
        self.choosePersonTransMessage(isNet: true, isLocal: false,fileIDs: fileIDs,messages: messagesTemp)
        
    }
    
    
    
    func choosePersonTransMessage(isNet: Bool,isLocal: Bool,picString: String = "",videoString: String = "",fileString: String = "",locationString: String = "",fileIDs: Array<String>,messages: Array<CODMessageModel>) {
        
        let selectPersonVC = TransmitSelectPersonViewController.init(nibName: "TransmitSelectPersonViewController", bundle: Bundle.main)
        
        selectPersonVC.messages = messages
        selectPersonVC.chooseChatListBlock = { [weak self] (chatListModel) in
            
            guard let `self` = self else { return }
            
            switch chatListModel.chatTypeEnum {
            case .groupChat:
                
                if !CustomUtil.judgeInGroupRoomCanSpeak(roomId: chatListModel.id) {
                    CODProgressHUD.showErrorWithStatus(NSLocalizedString("抱歉，您不能在此会话发布消息", comment: ""))
                }else{
                    self.chooseGroupTransMessage(groupModel: chatListModel.groupChat ?? CODGroupChatModel(), isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString, messages: messages)
                }
                
                
            case .channel:
                //TODO: 频道对应处理
                let channelResult = CustomUtil.judgeInChannelRoom(roomId: chatListModel.id)
                if !channelResult.isManager {
                    CODProgressHUD.showErrorWithStatus(NSLocalizedString("抱歉,您不能在此频道发布消息", comment: ""))
                }else{
                    self.chooseChannelTransMessage(channelModel: chatListModel.channelChat ?? CODChannelModel(), isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString, messages: messages)
                }
            case .privateChat:
                if let contactModel = chatListModel.contact {
                    if contactModel.rosterID == CloudDiskRosterID {
                        
                        if fileIDs.count > 0 {
                            
                            switch (self.isCloudDisk, contactModel.isCloudDisk) {
                            case (true, false):
                                self.vaildTranfile(fileIDs: fileIDs, type: .CloudDiskToChat,isNeedJump: false,messages: messages)
                            case (false, false):
                                self.vaildTranfile(fileIDs: fileIDs, type: .ChatToChat,isNeedJump: false,messages: messages)
                            case (false, true):
                                self.vaildTranfile(fileIDs: fileIDs, type: .ChatToCloudDisk,isNeedJump: false,messages: messages)
                            default:
                                break
                            }
                            

                        }
     
                        self.transmitMessageToCloudDisk(contactModel: contactModel, isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString, messages: messages)
                        //转发至云盘
                    }else{
                        self.choosePersonTransMessage(contactModel: contactModel, isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString,messages: messages)
                    }
                }
            }
            
            
        }
        
        selectPersonVC.choosePersonBlock = { [weak self](contactModel) in
            print("BTransmitselectContact")
            self?.choosePersonTransMessage(contactModel: contactModel, isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString,messages: messages)
        }
        
        selectPersonVC.chooseGroupBlock = { [weak self] (groupModel) in
            print("BTransmitselectGroup")
            self?.chooseGroupTransMessage(groupModel: groupModel, isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString,messages: messages)
        }
        
        self.navigationController?.pushViewController(selectPersonVC)
        
    }
    

    //文件迁移
    func vaildTranfile(fileIDs: Array<String>, type: HttpTools.VaildandType, isNeedJump: Bool = true,messages: Array<CODMessageModel>) {
        //        验证类型 ctd(聊天转发到云盘)，默认 dtc(云盘转发到聊天)
        HttpTools.vaildandTranfile(attIdList: fileIDs, type: type)
        if type == .CloudDiskToChat && isNeedJump {
            self.choosePersonTransMessage(isNet: true, isLocal: false,fileIDs: fileIDs,messages: messages)
        }
    }
    
    
    func transmitMessageToCloudDisk(contactModel: CODContactModel,isNet: Bool,isLocal: Bool,picString: String = "",videoString: String = "",fileString: String = "",locationString: String = "",messages: Array<CODMessageModel>) {
        for messageModel in messages {
            let getCopyModel = self.getTransCopyModel(model: messageModel, isGroupChat: false)
            getCopyModel.msgID = UserManager.sharedInstance.getCloudDiskMessageId()
            getCopyModel.toJID = contactModel.jid
            getCopyModel.toWho = contactModel.jid
            getCopyModel.burn = contactModel.burn
            getCopyModel.chatTypeEnum = .privateChat
            
            CODChatListRealmTool.addChatListMessage(id: contactModel.rosterID, message: getCopyModel)
             
             //通知去聊天列表中更新数据
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
            
            self.copyMediaFile(messageModel: messageModel,toPathJid: kCloudJid + XMPPSuffix,fromPathJid: self.toJID)
            CODMessageSendTool.default.sendMessage(messageModel: getCopyModel, sender: getCopyModel.fromWho)
            CODMessageSendTool.default.postAddMessageToView(messageID: getCopyModel.msgID)
        }
        
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
            CODProgressHUD.showSuccessWithStatus(NSLocalizedString("已转发", comment: ""))
        }
    }
    
    
    func choosePersonTransMessage(contactModel: CODContactModel,isNet: Bool,isLocal: Bool,picString: String = "",videoString: String = "",fileString: String = "",locationString: String = "",messages: Array<CODMessageModel>) {
        
        var transList = Array<CODMessageModel>()
        for messageModel in messages {
            let getCopyModel = self.getTransCopyModel(model: messageModel, isGroupChat: false)
            getCopyModel.msgID = UserManager.sharedInstance.getCloudDiskMessageId()
            getCopyModel.toJID = contactModel.jid
            getCopyModel.toWho = contactModel.jid
            getCopyModel.burn = contactModel.burn
            getCopyModel.chatTypeEnum = .privateChat
            transList.append(getCopyModel)
            self.copyMediaFile(messageModel: messageModel,toPathJid: String(contactModel.jid),fromPathJid: self.toJID)

            
            //                self.messageView.insertChatHistory(message: getCopyModel, contact: contactModel)
            //                CODMessageSendTool.default.sendMessage(messageModel: getCopyModel, sender: getCopyModel.fromWho)
            //                CODMessageSendTool.default.postAddMessageToView(messageID: getCopyModel.msgID)
        }
        
        //            self.navigationController?.popViewController(animated: true)
        //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
        //                CODProgressHUD.showSuccessWithStatus("已转发")
        //            }
        let msgCtl = MessageViewController()
        if let listModel = CODChatListRealmTool.getChatList(id: contactModel.rosterID) {
            msgCtl.newMessageCount = listModel.count
        }
        msgCtl.chatType = .privateChat
        msgCtl.toJID = contactModel.jid
        msgCtl.chatId = contactModel.rosterID
        msgCtl.title = contactModel.getContactNick()
        msgCtl.isMute = contactModel.mute
        msgCtl.transMessages = transList
        msgCtl.transJid = self.toJID
        if let tab = UIApplication.shared.delegate?.window??.rootViewController as? CODCustomTabbarViewController  {
            tab.tabBar.isHidden = true
        }
        self.navigationController?.setViewControllers([(self.navigationController?.viewControllers.first)!,msgCtl], animated: false)
        
    }
    
    func chooseGroupTransMessage(groupModel: CODGroupChatModel,isNet: Bool,isLocal: Bool,picString: String = "",videoString: String = "",fileString: String = "",locationString: String = "",messages: Array<CODMessageModel>) {
        
        var transList = Array<CODMessageModel>()
        for messageModel in messages {
            let getCopyModel = self.getTransCopyModel(model: messageModel, isGroupChat: false)
            getCopyModel.msgID = UserManager.sharedInstance.getCloudDiskMessageId()
            getCopyModel.toJID = groupModel.jid
            getCopyModel.toWho = groupModel.jid
            getCopyModel.chatTypeEnum = .groupChat
            getCopyModel.burn = groupModel.burn.int ?? 0
            self.copyMediaFile(messageModel: messageModel,toPathJid: String(groupModel.jid),fromPathJid: self.toJID)
            transList.append(getCopyModel)
        }
        
        let msgCtl = MessageViewController()
        if let listModel = CODChatListRealmTool.getChatList(id: groupModel.roomID) {
            msgCtl.newMessageCount = listModel.count
            if (listModel.groupChat?.descriptions) != nil {
                let groupName = listModel.groupChat?.descriptions
                if let groupName = groupName, groupName.count > 0 {
                    msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
                }else{
                    msgCtl.title = NSLocalizedString("群组", comment: "")
                }
            }else{
                msgCtl.title = NSLocalizedString("群组", comment: "")
            }
            
            if let groupChatTemp = listModel.groupChat {
                msgCtl.toJID = String(groupChatTemp.jid)
            }
            msgCtl.chatId = listModel.id
            
        }else{
            if groupModel.descriptions.count > 0 {
                msgCtl.title = groupModel.descriptions.subStringToIndexAppendEllipsis(10)
            }else{
                msgCtl.title = NSLocalizedString("群组", comment: "")
            }
            msgCtl.toJID =  groupModel.jid
            msgCtl.chatId = groupModel.roomID
        }
        msgCtl.isMute = groupModel.mute
        msgCtl.chatType = .groupChat
        msgCtl.transMessages = transList
        msgCtl.transJid = self.toJID
        msgCtl.roomId = String(format: "%d", groupModel.roomID)
        self.navigationController?.setViewControllers([(self.navigationController?.viewControllers.first)!,msgCtl], animated: false)
        
    }
    
    func chooseChannelTransMessage(channelModel: CODChannelModel,isNet: Bool,isLocal: Bool,picString: String = "",videoString: String = "",fileString: String = "",locationString: String = "",messages: Array<CODMessageModel>) {
        var transList = Array<CODMessageModel>()
        for messageModel in messages {
            let getCopyModel = self.getTransCopyModel(model: messageModel, isGroupChat: false)
            getCopyModel.msgID = UserManager.sharedInstance.getCloudDiskMessageId()
            getCopyModel.toJID = channelModel.jid
            getCopyModel.toWho = channelModel.jid
            getCopyModel.chatTypeEnum = .channel
            getCopyModel.burn = channelModel.burn.int ?? 0
            transList.append(getCopyModel)
            self.copyMediaFile(messageModel: messageModel,toPathJid: String(channelModel.jid),fromPathJid: self.toJID)
        }
        
        let msgCtl = MessageViewController()
        msgCtl.chatType = .channel
        msgCtl.roomId = String(format: "%d", channelModel.roomID )
        
        if (channelModel.descriptions) != nil {
            let groupName = channelModel.descriptions
            if groupName.count > 0 {
                msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
            }else{
                msgCtl.title = NSLocalizedString("频道", comment: "")
            }
        }else{
            msgCtl.title = NSLocalizedString("频道", comment: "")
        }
        msgCtl.toJID = String(channelModel.jid)
        msgCtl.chatId = channelModel.roomID
        msgCtl.isMute = channelModel.mute
        msgCtl.transMessages = transList
        msgCtl.transJid = self.toJID

        self.navigationController?.setViewControllers([(self.navigationController?.viewControllers.first)!,msgCtl], animated: false)
    }
    
    func getTransCopyModel(model: CODMessageModel,isGroupChat: Bool) -> CODMessageModel {
        
        let getCopyModel = CODMessageSendTool.default.getCopyModel(messageModel: model)
        let msgIDTemp = UserManager.sharedInstance.getMessageId()
        getCopyModel.msgID = msgIDTemp
        getCopyModel.status =  CODMessageStatus.Pending.rawValue
        
        if getCopyModel.chatTypeEnum == .privateChat && getCopyModel.isMeSend == false {
            getCopyModel.itemID = getCopyModel.fromJID
        } else {
            getCopyModel.itemID = getCopyModel.toJID
        }
        
        
        if (CODMessageRealmTool.getMessageByMsgId(model.msgID) != nil) || model.smsgID?.count == 0 {
            getCopyModel.smsgID = model.msgID
        }else{
            getCopyModel.smsgID = model.smsgID
        }
        getCopyModel.fromJID = UserManager.sharedInstance.jid
        getCopyModel.fromWho = UserManager.sharedInstance.jid
        getCopyModel.chatTypeEnum = .privateChat
        getCopyModel.isReaded = false
        getCopyModel.edited = 0
        getCopyModel.rp = ""
        getCopyModel.isDelete = false
        getCopyModel.isReadedDestroy = false
        if model.fw.removeAllSapce.count > 1 {
            getCopyModel.fw = model.fw
            getCopyModel.fwn = model.fwn
        }else{
            if model.fromWho.contains(UserManager.sharedInstance.loginName ?? "") {
                getCopyModel.fw = (UserManager.sharedInstance.loginName ?? "") + XMPPSuffix
            }else{
                getCopyModel.fw = model.fromJID
            }
            var fwnString : String?
            //先判断是不是群组消息
            if model.isGroupChat{
                
                //是群消息就去获取消息对应的群成员
                let memberID = CODGroupMemberModel.getMemberId(roomId: model.roomId, userName: model.fromWho)
                if let member = CODGroupMemberRealmTool.getMemberById(memberID) {
                    //如果成员存在，则去判断当前消息是不是来自于自己，是自己就去自己的昵称，不是自己就取群成员的昵称
                    fwnString = (model.fromWho.contains(UserManager.sharedInstance.loginName!)) ? UserManager.sharedInstance.nickname : member.getMemberNickName()
                }else{
                    //如果成员不存在，则直接取自己的昵称
                    fwnString = UserManager.sharedInstance.nickname
                }
                
                //不是群消息就判断当前消息是不是来自于自己
                if  model.fromWho.contains(UserManager.sharedInstance.loginName!) {
                    fwnString = UserManager.sharedInstance.nickname
                }else{
                    //消息不是来自自己，就去获取联系人，取联系人的昵称
                    if let contact = CODContactRealmTool.getContactByJID(by: model.fromJID) {
                        fwnString = contact.name
                    }
                }
                
            }else{
                
                //不是群消息就判断当前消息是不是来自于自己
                if  model.fromWho.contains(UserManager.sharedInstance.loginName!) {
                    fwnString = UserManager.sharedInstance.nickname
                }else{
                    //消息不是来自自己，就去获取联系人，取联系人的昵称
                    if let contact = CODContactRealmTool.getContactByJID(by: model.fromJID) {
                        fwnString = contact.name
                    }
                }
                
            }
            getCopyModel.fwn = fwnString ?? ""
        }
        if model.fwf.removeAllSapce.count > 0 {
            getCopyModel.fwf = model.fwf
        }else{
            switch model.chatTypeEnum {
            case .privateChat:
                getCopyModel.fwf = "U"
                break
            case .groupChat:
                getCopyModel.fwf = "G"
                break
            case .channel:
                getCopyModel.fwf = "C"
                break
            }
        }
        
        if model.chatTypeEnum == .channel {
            if let channelModel = CODChannelModel.getChannel(by: model.roomId) {
                if channelModel.signmsg {
                    getCopyModel.n = UserManager.sharedInstance.nickname ?? ""
                }
                getCopyModel.fwn = channelModel.getGroupName()
                getCopyModel.fw = channelModel.jid
                
            }else{
                if let channelModel = self.channelModel {
                    getCopyModel.fwn = channelModel.getGroupName()
                    getCopyModel.fw = channelModel.jid
                }
                getCopyModel.n = ""
            }
        }else{
            getCopyModel.n = UserManager.sharedInstance.nickname ?? ""
        }
        
        let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
        getCopyModel.datetime = timestr
        getCopyModel.datetimeInt = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp

        return getCopyModel
        
    }
    
}
extension MessageViewController:CODRecentPhotoViewDelegate{
    func imageViewClick(image: UIImage, asset: PHAsset) {
        
        let vc = CODPhotoBrowserController()
        vc.recentImage = image
        vc.photoAsset = asset
        vc.sendImageBlock = { [weak self] (image, imageData, isOriginal) in
            self?.sendImageMessage(image: image, imageData: imageData, ishdimg: isOriginal)
        }
        self.navigationController?.pushViewController(vc)
    }
    
}

