//
//  CODChatMessageDisplayVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import RxOptional
import SwifterSwift

typealias ChatSectionVM = TableViewSectionVM<String, ChatCellVM>

extension CODChatMessageDisplayPageVM: CODIMChatCellDelegate {
    func cellDidTapedAvatarImage(_ cell: CODBaseChatCell, model: CODMessageModel) {
        self.cellDidTapedAvatarImageBR.accept((cell, model))
    }
    
    func cellDidTapedFwdImageView(_ cell: CODBaseChatCell, model: CODMessageModel) {
        self.cellDidTapedFwdImageViewBR.accept((cell, model))
    }
    
    func cellDidLongTapedAvatarImage(_ cell: CODBaseChatCell, model: CODMessageModel) {
        self.cellDidLongTapedAvatarImageBR.accept((cell, model))
    }
    
    func cellDidTapedLink(_ cell: CODBaseChatCell, linkString: URL) {
        self.cellDidTapedLinkBR.accept((cell, linkString))
    }
    
    func cellDidTapedPhone(_ cell: CODBaseChatCell, phoneString: String) {
        self.cellDidTapedPhoneBR.accept((cell, phoneString))
    }
    
    func cellSendMsgReation(message: CODMessageModel?) {
        self.cellSendMsgReationBR.accept(message)
    }
    
    func cellCardAction(_ cell: CODBaseChatCell, message: CODMessageModel?) {
        self.cellCardActionBR.accept((cell, message))
    }
    
    func cellTapMessage(message: CODMessageModel?, _ cell: CODBaseChatCell) {
        self.cellTapMessageBR.accept((cell, message))
    }
    
    func cellLongPressMessage(cellVM: ChatCellVM?, _ cell: UIView, _ view: UIView) {
        self.cellLongPressMessageBR.accept((cell, cellVM, view))
    }
    
    func cellTapViewer(cell:CODBaseChatCell,message: CODMessageModel) {
        self.cellTapViewerBR.accept((cell, message))
    }
    
    func cellDeleteMessage(message: CODMessageModel?) {
        
        guard let msgID = message?.msgID else {
            return
        }
        
        self.removeMeesage.accept([msgID])
    }
    
    func cellDeleteMessage(msgIDs: [String]) {
        self.removeMeesage.accept(msgIDs)
    }
    
    func cellTapAtAll(message: CODMessageModel?, cell: CODBaseChatCell) {
        self.cellTapAtAllBR.accept((cell, message))
    }
    
    func cellTapAt(jidStr: String, model: CODMessageModel, cell: CODBaseChatCell) {
        cellTapAtBR.accept((jid: jidStr, cell: cell, model: model))
    }
    
    
}

class CODChatMessageDisplayPageVM: NSObject, XMPPManagerDelegate {
    
    enum LoadingState {
        case idle
        case loading
        case notAnyMore
    }
    
    let chatListModel: CODChatListModel
    let chatObj: CODChatObjectType
    var isCloudDisk: Bool = false
    var rpIndexPath: BehaviorRelay<IndexPath?> = BehaviorRelay(value: nil)
    
    var dataSources: [ChatSectionVM] = [ChatSectionVM]()
    
    let originalNewMessageCount: Int
    
    var dataSouecesBR: BehaviorRelay<[ChatSectionVM]>
    var newMessageBR: PublishRelay<CODMessageModel> = PublishRelay()
    var sendMessageBR: PublishRelay<CODMessageModel> = PublishRelay()
    var editMessageBR: PublishRelay<IndexPath> = PublishRelay()
    var cellDidTapedAvatarImageBR: PublishRelay<(CODBaseChatCell, CODMessageModel)> = PublishRelay()
    var cellDidTapedFwdImageViewBR: PublishRelay<(CODBaseChatCell, CODMessageModel)> = PublishRelay()
    var cellDidLongTapedAvatarImageBR: PublishRelay<(CODBaseChatCell, CODMessageModel)> = PublishRelay()
    var cellDidTapedLinkBR: PublishRelay<(CODBaseChatCell, URL)> = PublishRelay()
    var cellDidTapedPhoneBR: PublishRelay<(CODBaseChatCell, String)> = PublishRelay()
    var cellSendMsgReationBR: PublishRelay<CODMessageModel?> = PublishRelay()
    var cellCardActionBR: PublishRelay<(CODBaseChatCell, CODMessageModel?)> = PublishRelay()
    var cellTapMessageBR: PublishRelay<(CODBaseChatCell, CODMessageModel?)> = PublishRelay()
    var cellLongPressMessageBR: PublishRelay<(UIView, ChatCellVM?, UIView)> = PublishRelay()
    var cellTapAtAllBR: PublishRelay<(CODBaseChatCell, CODMessageModel?)> = PublishRelay()
    var cellTapAtBR: PublishRelay<(jid: String, cell: CODBaseChatCell, model: CODMessageModel)> = PublishRelay()
    var cellTapViewerBR: PublishRelay<(CODBaseChatCell,CODMessageModel)> = PublishRelay()
    var removeMeesage: PublishRelay<[String]> = PublishRelay()
    var removeAllMessage: PublishRelay<Void> = PublishRelay()
    var playNextAudioPR: PublishRelay<(indexPath: IndexPath, cellVM: ChatCellVM)> = PublishRelay()
    var closeImageUploadPR: PublishRelay<(cellVM: ChatCellVM, uploadId: String)> = PublishRelay()
    var onClickImagePR: PublishRelay<(cellVM: ChatCellVM, imageIndex: Int)> = PublishRelay()
    var resendMessageBR: PublishRelay<CODMessageModel>  = PublishRelay()
    var resendMessageReloadCellBR: PublishRelay<IndexPath>  = PublishRelay()
    
    var referToMessageIDBR: BehaviorRelay<[(sendTime: String, msgId: String)]> = BehaviorRelay(value: [])
    var referToMessageIDRemove: PublishRelay<(sendTime: String, msgId: String)> = PublishRelay()
    var referToMessageIDAdd: PublishRelay<(sendTime: String, msgId: String)> = PublishRelay()
    var updateReadMessageBR: PublishRelay<Void> = PublishRelay()
    var updateNewMessageBR: BehaviorRelay<Int>
    var updateTopMsgBR: BehaviorRelay<CODMessageModel?>
    var reloadTableViewBR: PublishRelay<IndexPath> = PublishRelay()
    var isMultipleSelelct: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var imageData: [YBIBDataProtocol] = []
    var realoadEndBR: PublishRelay<Void> = PublishRelay()
    var fileImageData: [YBIBDataProtocol] = []

    var hasNewMessageCell = false
    
    var referToMessageID: [(sendTime: String, msgId: String)] = []
    
    var lastMessageID: String {
        return self.dataSources.first?.items.last?.messageModel.msgID ?? "0"
    }
    
    var remoteLastMessageID: String?
    var remoteLastMessageTime: Int?
    
    var lastMessageDataTime: Int {
        return self.dataSources.first?.items.last?.messageModel.datetimeInt ?? 0
    }
    
    var editMessage: Observable<CODMessageModel> {
        
        return self.editMessageBR.map { [weak self] (indexPath) -> CODMessageModel? in
            guard let `self` = self else { return nil }
            
            if (self.dataSources.count > indexPath.section && self.dataSources[indexPath.section].items.count > indexPath.item) {
                return self.dataSources[indexPath.section].items[indexPath.row].messageModel
            } else {
                return nil
            }

        }
        .filterNil()
        
    }
    
    
    init(chatId: Int, chatType: CODMessageChatType = .privateChat) {
        
        if let chatList = CODChatListRealmTool.getChatList(id: chatId) {
            self.chatListModel = chatList
            
            self.chatListModel.fixChatList(id: chatId, chatType: chatType)
            
        } else {
            
            CODChatListRealmTool.insertChatList(chatId: chatId, type: chatType)
            self.chatListModel = CODChatListRealmTool.getChatList(id: chatId)!
        }
        
        if chatType == .channel {
            
            if self.chatListModel.channelChat?.isMember(by: UserManager.sharedInstance.jid) ?? false == false {
                /// 频道为加入时，会话列表不可见
                CODChatListRealmTool.setIsInValid(id: chatId, isInValid: true)
            }
            
        }
        
        dataSouecesBR = BehaviorRelay(value: dataSources)
        
        self.originalNewMessageCount = chatListModel.count
        self.updateNewMessageBR = BehaviorRelay(value: self.originalNewMessageCount)
        
        switch chatListModel.chatTypeEnum {
        case .channel:
            chatObj = chatListModel.channelChat!
            self.updateTopMsgBR = BehaviorRelay(value: CODMessageRealmTool.getExistMessage(chatListModel.channelChat!.topmsg))
        case .privateChat:
            chatObj = chatListModel.contact!
            self.updateTopMsgBR =  BehaviorRelay(value: nil)
        case .groupChat:
            chatObj = chatListModel.groupChat!
            self.updateTopMsgBR = BehaviorRelay(value: CODMessageRealmTool.getExistMessage(chatListModel.groupChat!.topmsg))
        }
        
        super.init()
        
        self.fetchData()
        
        referToMessageID = chatListModel.referToMessageID.map { (jsonString) -> (sendTime: String, msgId: String) in
            let json = JSON(parseJSON: jsonString)
            return (sendTime: json["sendTime"].stringValue, msgId: json["msgId"].stringValue)
        }
        .sorted(by: { (value1, value2) -> Bool in
            return value1.sendTime.int ?? 0 <= value2.sendTime.int ?? 0
        })
        
        referToMessageIDBR.accept(referToMessageID)
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: XMPPManager.shareXMPPManager.messageQueue)
        XMPPManager.shareXMPPManager.addDelegate(self)
        
        self.removeMeesage.bind(to: self.rx.removeMeesageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.removeAllMessage.bind(to: self.rx.removeAllMeesageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.resendMessageBR.bind(to: self.rx.resendMessageBinder)
            .disposed(by: self.rx.disposeBag)
        
        
    }
    
    func jumpToMessage(msgID: String) {
        
        if let messageModel = CODMessageRealmTool.getExistMessage(msgID) {
            
            if let index = self.findIndexPath(messageId: msgID) {
                self.rpIndexPath.accept(index)
            } else {
                
                CODProgressHUD.showWithStatus(nil)
                
                self.getHistoryList(beginTime: "\(messageModel.datetimeInt - 10 * 1000)", endTime: "\(self.lastMessageDataTime - 1)") { [weak self] (vms) in
                    
                    CODProgressHUD.dismiss()
                    guard let `self` = self else { return }

                    self.appendChatCellVMs(cellVms: vms)
                    if let index = self.findIndexPath(messageId: messageModel.msgID) {
                        self.rpIndexPath.accept(index)
                    }
                    
                }
                
            }
            
            
        }
        
        
    }
    
    func onClickCloudDaskJump(jid: String, msgID: String) {
        
        if jid.contains(kCloudJid) {
            
            if CODMessageRealmTool.getExistMessage(msgID) != nil {
                self.jumpToMessage(msgID: msgID)
            } else {
                CODMessageRealmTool.getRemoteMessageByMsgId(msgId: msgID) { [weak self] model in
                    guard let `self` = self else { return }
                    self.jumpToMessage(msgID: msgID)
                }
            }
            
            
        } else {
            CustomUtil.pushToMessageVC(jid: jid, jumpMessageId: msgID)
        }

    }
    
    func onClickImage(cellVM: ChatCellVM, imageIndex: Int = 0) {
        
        self.onClickImagePR.accept((cellVM: cellVM, imageIndex: imageIndex))
        
    }
    
    func closeImageUpload(cellVm: ChatCellVM, uploadId: String) {
        
        self.closeImageUploadPR.accept((cellVM: cellVm, uploadId: uploadId))
        
        cellVm.messageModel.deleteImageFormImageList(photoId: uploadId)
        
        if cellVm.messageModel.imageList.count == 0 {
            self.cellDeleteMessage(message: cellVm.messageModel)
        } else {
            self.reloadTableViewBR.accept(cellVm.indexPath!)
        }
        
        UploadTool.cancel(uploadId: uploadId)
        
        
    }
    
    func playNextAudio(cellVm: ChatCellVM) {
        
        guard let nextVm = cellVm.nextCellVM, let indexPath = nextVm.indexPath else {
            return
        }
        
        if nextVm is Xinhoo_AudioViewModel && nextVm.model.isMeSend != true {
            self.playNextAudioPR.accept((indexPath: indexPath, cellVM: nextVm))
        } else {
            playNextAudio(cellVm: nextVm)
        }
        
    }
    
    func cancelEditMessage(message: CODMessageModel) {
        
        let cancalMessage = message.editMessage ?? message
        
        let uploadId = cancalMessage.photoModel?.photoId ?? cancalMessage.videoModel?.videoId ?? ""
        
        UploadTool.cancel(uploadId: uploadId)
        
        if message.editMessage != nil {
            
            message.editMessage(model: nil, status: .Cancal)
            if let index = findIndexPath(messageId: message.msgID) {
                self.editMessageBR.accept(index)
            }
            
        } else {
            message.editMessage(model: nil, status: .Cancal)
            self.cellDeleteMessage(message: message)
        }
        
    }
    
    func updateNewMessageCount() {
        
        let needsCount = self.dataSources.first?.items.filter({ (vm) -> Bool in
            vm.model.type != .notification
        })
        .count ?? 0
        
        var count = self.originalNewMessageCount  - needsCount
        
        if count < 0 {
            count = 0
        }
        
        self.updateNewMessageBR.accept(count)
    }
    
    func messageToImageDataArray(model: CODMessageModel) -> [YBIBDataProtocol]? {
        return CustomUtil.messageToImageDataArray(model: model, isCloudDisk: self.isCloudDisk)
    }
    
    func messageToImageData(model: CODMessageModel) -> YBIBDataProtocol? {
        
        return CustomUtil.messageToImageData(model: model, isCloudDisk: self.isCloudDisk)
        
    }
    
    var newMessage: Observable<CODMessageModel> {
        return self.newMessageBR.asObservable().filter { (message) -> Bool in
            return message.type != .haveRead
        }
    }
    
    var dataSouecesObserver: Observable<[ChatSectionVM]> {
        
        return self.dataSouecesBR.asObservable()
        
    }
    
    
    var referToMessageIDObservable: Observable<[(sendTime: String, msgId: String)]> {
        return referToMessageIDBR.asObservable()
    }
    
    func fetchData() {
        
        let sectionVM = ChatSectionVM(model: "chat", items: [])
        dataSources = [sectionVM]
        
        self.dataSouecesBR.accept(dataSources)
        
        
        
    }
    
    func fetchImageData() {
        
        var imageData: [YBIBDataProtocol] = []
        
        let messages = HistoryMessageManger.default.getLocatImageAndVideoList(chatId: self.chatObj.chatId).sorted(by: \.datetimeInt, ascending: true)
        
        for message in messages {
            
            if message.type == .image || message.type == .video {
                
                if let data = self.messageToImageData(model: message) {
                    imageData.append(data)
                }
                
            }
            
            if message.type == .multipleImage {
                
                if let dataArray = self.messageToImageDataArray(model: message) {
                    imageData.append(contentsOf: dataArray)
                }
                
                
            }
            
        }
        
        
        self.imageData = imageData
        
    }
    
    func fetchFileImageData() {
        
        var imageData: [YBIBDataProtocol] = []
        
        let messages = HistoryMessageManger.default.getLocatFileImageList(chatId: self.chatObj.chatId)
        
        for message in messages {
            
            if message.fileModel?.isImageOrVideo == true {
                
                if let data = self.messageToImageData(model: message) {
                    imageData.append(data)
                }
                
            }

        }
        
        
        self.fileImageData = imageData
        
    }
    
    func findFileImageIndex(messageModel: CODMessageModel) -> Int? {

        if messageModel.type != .file {
            return nil
        }

        let index = self.fileImageData.lastIndex { (data) -> Bool in
            
            if let data = data as? YBIBImageData, data.msgID == messageModel.msgID {
                return true
            } else if let data = data as? YBIBVideoData, data.msgID == messageModel.msgID {
                return true
            } else {
                return false
            }
            
        }
        
        return index


    }
    
    
    func findImageIndex(messageModel: CODMessageModel, imageIndex: Int = 0) -> Int? {
        
        if messageModel.type != .video && messageModel.type != .image && messageModel.type != .multipleImage {
            return nil
        }
        
        let index = self.imageData.lastIndex { (data) -> Bool in
            
            if messageModel.type == .video {
                
                if let data = data as? YBIBVideoData, data.msgID == messageModel.msgID {
                    return true
                } else {
                    return false
                }
                
            } else {
                
                if let data = data as? YBIBImageData, data.msgID == messageModel.msgID {
                    return true
                } else {
                    return false
                }
                
            }
            
        }
        
        if let index = index {
            
            var realIndex = index
            
            if messageModel.type == .multipleImage {
                
                realIndex -= (messageModel.imageList.count - 1)
                realIndex += imageIndex
                
                
            }
            
            return realIndex
            
            
        }
        
        return nil
        
    }
    
    
    
    func getLocalHistoryList(lastMessageId: String = "0", count: Int = 50, checkBurn: Bool = false, isReadedDestroy: Bool = false, insertShowNewMessageCell: Bool = true, complete: (([ChatCellVM]) -> Void)?) {
        
        var messages = HistoryMessageManger.default.getLocalHistoryList(chatId: self.chatObj.chatId, lastMessageId: lastMessageId, count: count)
        
        if checkBurn == true && messages.count > 0 {
            let needShowMessages = CODMessageRealmTool.burnMessage(messages: messages)
            
            if needShowMessages.count == 0 {
                getLocalHistoryList(lastMessageId: messages[0].msgID, count: count, checkBurn: checkBurn, isReadedDestroy: isReadedDestroy, complete: complete)
                return
            }
            
            messages = needShowMessages
        }
        
        if isReadedDestroy {
            CODMessageRealmTool.setReadedDestroy(by: messages)
        }
        
        let cellVms = messagesToCellVMs(messageModels: messages)
        
        complete?(cellVms)
        
        
    }
    
    func getHistoryList(lastMessageId: String = "0", count: Int = 50, checkBurn: Bool = true, insertShowNewMessageCell: Bool = true, complete: (([ChatCellVM]) -> Void)?)  {
        
        self.getRemoteHistoryList(lastMessageId: lastMessageId, count: count) { [weak self] (cellVMs, isComplete, isFailure) in
            
            guard let `self` = self else {
                complete?([])
                return
            }
            
            
            var newCount = cellVMs.count
            
            if newCount == 0 {
                newCount = count
            }
            
            
            func loadMessageComplete(cellVM: [ChatCellVM]) {
                
                if let datetimeInt = cellVM.last?.model.datetimeInt, let remoteLastMessageTime = self.remoteLastMessageTime,
                    datetimeInt < remoteLastMessageTime {
                    self.remoteLastMessageID = cellVM.last?.model.msgID
                    self.remoteLastMessageTime = cellVM.last?.model.datetimeInt
                }
                
                if cellVM.count == 0 && isComplete == false && isFailure != true {
                    self.getHistoryList(lastMessageId: self.remoteLastMessageID ?? "0", count: count, insertShowNewMessageCell: insertShowNewMessageCell, complete: loadMessageComplete)
                    return
                }
                
                if cellVM.count == 0 && isComplete {
                    self.realoadEndBR.accept(Void())
                    return
                }
                
                complete?(cellVM)
                
            }
            
            
            if let beginTime = cellVMs.last?.model.datetime {
                
                var endTime = CODMessageRealmTool.getMessageByMsgId(lastMessageId)?.datetime ?? "0"
                
                if lastMessageId == "0" {
                    endTime = "0"
                }
                
                self.getLocalHistoryList(beginTime: beginTime, endTime: endTime, checkBurn: checkBurn, isReadedDestroy: true, insertShowNewMessageCell: insertShowNewMessageCell, complete: loadMessageComplete)
            } else {
                self.getLocalHistoryList(lastMessageId: lastMessageId, count: count, checkBurn: checkBurn, isReadedDestroy: true, insertShowNewMessageCell: insertShowNewMessageCell, complete: loadMessageComplete)
            }
            
            
        }
        
    }
    
    func getHistoryList(beginTime: String, endTime: String, updateRemoteLastMessage: Bool = true, complete: (([ChatCellVM]) -> Void)?) {
        
        HistoryMessageManger.default.getRemoteHistoryList(chatId: self.chatObj.chatId, beginTime: beginTime, endTime: endTime) { [weak self] (messageModel) in
            guard let `self` = self else { return }
            if updateRemoteLastMessage == true, let remoteLastMessageID = messageModel.last?.msgID {
                self.remoteLastMessageID = remoteLastMessageID
                self.remoteLastMessageTime = messageModel.last?.datetimeInt
            }
            
            self.getLocalHistoryList(beginTime: beginTime, endTime: endTime, complete: complete)
        }
        
        
    }
    
    func getLocalHistoryList(beginTime: String, endTime: String, checkBurn: Bool = false, isReadedDestroy: Bool = false, insertShowNewMessageCell: Bool = true, complete: (([ChatCellVM]) -> Void)?) {
        
        var messages = HistoryMessageManger.default.getLocalHistoryList(chatId: self.chatObj.chatId, beginTime: beginTime, endTime: endTime)
        
        if checkBurn == true && messages.count > 0 {
            let needShowMessages = CODMessageRealmTool.burnMessage(messages: messages)
            messages = needShowMessages
        }
        
        if isReadedDestroy {
            CODMessageRealmTool.setReadedDestroy(by: messages)
        }
        
        let cellVms = messagesToCellVMs(messageModels: messages)
        
        complete?(cellVms)
        
        
    }
    
    func findIndexPath(messageId: String) -> IndexPath? {
        
        guard let section = self.dataSources.first else {
            return nil
        }
        
        let index = section.items.lastIndex { (cellVM) -> Bool in
            return cellVM.model.msgID == messageId
        }
        
        if let index = index {
            return IndexPath(row: index, section: 0)
        }
        
        return nil
        
    }
    
    func findIndexPath(datatime: Int) -> IndexPath? {
        
        guard let section = self.dataSources.first else {
            return nil
        }
        
        //        let index = section.items.firstIndex { (cellVM) -> Bool in
        //            return cellVM.model.datetimeInt < datatime
        //        }
        
        var newIndexPath: IndexPath? = nil
        for (index, item) in section.items.enumerated() {
            
            if item.messageModel.type == .newMessage {
                continue
            }
            
            if item.model.datetimeInt < datatime {
                newIndexPath = IndexPath(row: index, section: 0)
                break
            }
        }
        
        if let newIndexPath = newIndexPath {
            return newIndexPath
        }
        
        return nil
        
    }
    
    func contains(msgTime: Int) -> Bool {
        
        guard let section = self.dataSources.first else {
            return false
        }
        
        if let messageModel = section.items.last?.model, messageModel.datetimeInt <= msgTime {
            return true
        } else {
            return false
        }
        
        
    }
    
    func getRemoteHistoryList(beginTime: String, endTime: String, complete: (([ChatCellVM]) -> Void)?) {
        
        HistoryMessageManger.default.getRemoteHistoryList(chatId: self.chatListModel.id, beginTime: beginTime, endTime: endTime) { [weak self] (messages) in
            guard let `self` = self else { return }
            
            if let remoteLastMessageID = messages.last?.msgID {
                self.remoteLastMessageID = remoteLastMessageID
                self.remoteLastMessageTime = messages.last?.datetimeInt
            }
            
            self.getLocalHistoryList(beginTime: beginTime, endTime: endTime, complete: complete)
        }
        
    }
    
    func getRemoteHistoryList(toDate: String, complete: (([ChatCellVM]) -> Void)?) {
        
        self.getRemoteHistoryList(beginTime: toDate, endTime: "\(self.lastMessageDataTime)", complete: complete)
        
    }
    
    func getRemoteHistoryList(lastMessageId: String = "0", count: Int = 50, complete: (([ChatCellVM], Bool, Bool) -> Void)?) {
        
        var lastPushTime = "0"
        
        if lastMessageId != "0" {
            
            if let messageModel = CODMessageRealmTool.getMessageByMsgId(lastMessageId) {
                lastPushTime = messageModel.datetime
            } else if let remoteLastMessageTime = remoteLastMessageTime {
                lastPushTime = remoteLastMessageTime.string
            }
            
        }
        
        
        HistoryMessageManger.default.getRemoteHistoryList(chatId: self.chatObj.chatId, lastPushTime: lastPushTime, count: count) { [weak self] (messages, isComplete, isFailure) in
            
            guard let `self` = self else { return }
            
            if let remoteLastMessageID = messages.last?.msgID {
                self.remoteLastMessageID = remoteLastMessageID
                self.remoteLastMessageTime = messages.last?.datetimeInt
            }
            
            
            let deleteMessages = messages.filter { (model) -> Bool in return model.isDelete }
            
            // 如果消息都被删除再次问服务器要
            if deleteMessages.count > 0 && deleteMessages.count == messages.count {
                if let msgId = deleteMessages.first?.msgID {
                    self.getRemoteHistoryList(lastMessageId: msgId, count: count, complete: complete)
                    return
                }
            }
            
            var cellVms = self.messagesToCellVMs(messageModels: messages)
            
            cellVms = cellVms.removeDuplicates()
            
            complete?(cellVms, isComplete, isFailure)
            
        }
        
        
    }
    
    func insertShowNewMessageCell() {
        
        if let sectionVM = self.dataSources.first, self.updateNewMessageBR.value > 0, self.originalNewMessageCount > 0, sectionVM.items.count > self.originalNewMessageCount , hasNewMessageCell == false {

            var messageCount = 0
            var newMessageIndex = 0
            for (index, item) in sectionVM.items.enumerated() {
                
                if item.model.type == .notification {
                    continue
                }
                
                messageCount += 1
                
                if messageCount >= self.originalNewMessageCount {
                    newMessageIndex = index + 1
                    break
                }
                

            }
            
            if newMessageIndex <= 0 {
                return
            }
            
            sectionVM.items.insert(ChatCellVM(name: CODShowNewMessageCell.self.description(),
                       messageModel: CODMessageModelTool.default.createNewMessageCountMessage()),
            at: newMessageIndex)
            
            hasNewMessageCell = true
            
        }
        
    }
    
    func appendChatCellVMs(cellVms: [ChatCellVM]) {
        
        
        if let sectionVM = self.dataSources.first, cellVms.count > 0 {
            
            if let remoteLastMessageTime = self.remoteLastMessageTime {
                
                if cellVms.last!.messageModel.datetimeInt < remoteLastMessageTime {
                    self.remoteLastMessageID = cellVms.last?.messageModel.msgID
                    self.remoteLastMessageTime = cellVms.last?.messageModel.datetimeInt
                }
                
            } else {
                self.remoteLastMessageID = cellVms.last?.messageModel.msgID
                self.remoteLastMessageTime = cellVms.last?.messageModel.datetimeInt
            }
            
            
            var cellVms = cellVms
            
            if sectionVM.items.contains(cellVms) {
                return
            }
            
            if cellVms.first == sectionVM.items.last {
                cellVms.removeFirst()
            }
            
            if let firstModel = cellVms.first?.model, let lastModel = sectionVM.items.last?.model {
                sectionVM.items.last?.isFirst = !CustomUtil.getTimeTampIsSameDay(time1: firstModel.datetimeInt, time2: lastModel.datetimeInt)
            }            
            
            sectionVM.items.append(contentsOf: cellVms)
            dataSources = [sectionVM]
            
            self.insertShowNewMessageCell()
            self.updateNewMessageCount()
            
            self.dataSouecesBR.accept(dataSources)
        }
        
    }
    
    func insertChatCellVmsToBottom(cellVms: [ChatCellVM]) {
        
        if let sectionVM = self.dataSources.first, cellVms.count > 0 {
            
            if sectionVM.items.contains(cellVms) {
                return
            }
            
            cellVms.reversed().forEach { (cellVM) in
                
                let b = sectionVM.items.contains { (vm) -> Bool in
                    return cellVM.messageModel.msgID == vm.messageModel.msgID
                }
                
                if !b {
                    sectionVM.items.insert(cellVM, at: 0)
                }
            }
            
            dataSources = [sectionVM]
            self.dataSouecesBR.accept(dataSources)
        }
        
        
    }
    
    func setChatCellVMs(cellVms: [ChatCellVM], showNewMessage: Bool = true) {
        
        guard let sectionVM = self.dataSources.first else {
            return
        }
        
        self.remoteLastMessageID = cellVms.last?.messageModel.msgID
        self.remoteLastMessageTime = cellVms.last?.messageModel.datetimeInt
        
        sectionVM.items = cellVms
        dataSources = [sectionVM]
        
        if showNewMessage {
            self.insertShowNewMessageCell()
        }
        
        
        self.dataSouecesBR.accept(dataSources)
        
    }
    
    func messageToCellVM(messageModel: CODMessageModel) -> ChatCellVM? {
        
        switch messageModel.type {
        case .text, .unknown:
            return Xinhoo_TextViewModel(messageModel: messageModel)
        case .multipleImage:
            return Xinhoo_MultipleImageCellVM(messageModel: messageModel)
        case .image, .gifMessage, .video:
            return Xinhoo_ImageViewModel(messageModel: messageModel)
        case .audio:
            return Xinhoo_AudioViewModel(messageModel: messageModel)
        case .businessCard:
            return Xinhoo_CardViewModel(messageModel: messageModel)
        case .file:
            return Xinhoo_FileViewModel(messageModel: messageModel)
        case .notification:
            return ChatNotificationCellVM(messageModel: messageModel)
        case .videoCall, .voiceCall:
            return Xinhoo_CallViewModel(messageModel: messageModel)
        case .location:
            return Xinhoo_LocationViewModel(messageModel: messageModel)
        default:
            return nil
        }
        
        
    }
    
    func messagesToCellVMs(messageModels: [CODMessageModel]) -> [ChatCellVM] {
        
        var cellVMs: [ChatCellVM] = []
        
        for (index, model) in messageModels.enumerated() {
            
            var lastModel: CODMessageModel?
            if index + 1 < messageModels.count {
                lastModel = messageModels[index + 1]
            }
            
            if let chatVM = self.messageToCellVM(messageModel: model) {
                
                if let lastModel = lastModel {
                    chatVM.isFirst = !CustomUtil.getTimeTampIsSameDay(time1: lastModel.datetimeInt, time2: model.datetimeInt)
                } else {
                    chatVM.isFirst = true
                }
                
                cellVMs.append(chatVM)
                
            }
            
        }
        
        return cellVMs
        
    }
    
    func compareTwoTimeIsShowTime(chatCellVM: ChatCellVM, modelRow: Int) -> Bool{
        
        let messageModel = chatCellVM.messageModel
        
        if messageModel.type == .newMessage {
            return false
        }
        
        if let lastModel = chatCellVM.lastModel {
            
            if lastModel.type == .newMessage {
                
                if let lastLastModel = chatCellVM.lastCellVM?.lastModel {
                    return !CustomUtil.getTimeTampIsSameDay(time1: lastLastModel.datetimeInt, time2: messageModel.datetimeInt)
                }
                
            }
            
            return !CustomUtil.getTimeTampIsSameDay(time1: lastModel.datetimeInt, time2: messageModel.datetimeInt)
        } else {
            return true
        }
        
        
    }
    
    func receiveMessage(message: CODMessageModel) {
        
        guard let sectionVM = self.dataSources.first else {
            return
        }
        
        CODMessageRealmTool.setReadedDestroy(message: message)
        
        if message.type == .haveRead {
            
        } else {
            
            guard let cellVM = messageToCellVM(messageModel: message) else { return }
            
            
            
            if let index = findIndexPath(messageId: cellVM.model.msgID)  {
                
                if cellVM.messageModel.edited >= sectionVM.items[index.row].messageModel.edited {
                    
                    if cellVM.cellType != sectionVM.items[index.row].cellType{
                        sectionVM.items[index.row] = cellVM
                    } else {
                        sectionVM.items[index.row].messageModel = message
                    }
                    
                    
                    self.editMessageBR.accept(index)
                    
                } 
                
            } else {
                
                if let firstModel = sectionVM.items.first?.messageModel {
                    cellVM.isFirst = !CustomUtil.getTimeTampIsSameDay(time1: firstModel.datetimeInt, time2: message.datetimeInt)
                } else {
                    cellVM.isFirst = true
                }
                
                sectionVM.items.insert(cellVM, at: 0)
                self.dataSouecesBR.accept(dataSources)
            }
            
            self.newMessageBR.accept(message)
            
            
        }
        
    }
    
    func updateEditMessage(message: CODMessageModel) {
        
        if let indexPath = self.findIndexPath(messageId: message.msgID) {
            self.editMessageBR.accept(indexPath)
        }
        
    }
    
    func resendMessage(message: CODMessageModel) {
        self.resendMessageBR.accept(message)
    }
    
    func sendMessage(message: CODMessageModel) {
        
        guard let sectionVM = self.dataSources.first else {
            return
        }
        
        CODChatListRealmTool.addChatListMessage(id: self.chatObj.chatId, message: message)
        CODMessageRealmTool.updateMessageStyleByMsgId(message.msgID, status: CODMessageStatus.Pending.rawValue)
        
        if message.burn > 0 {
            CODMessageRealmTool.setReadedDestroy(message: message)
        }
        
        guard let cellVM = messageToCellVM(messageModel: message) else { return }
        
        if let firstModel = sectionVM.items.first?.messageModel {
            cellVM.isFirst = !CustomUtil.getTimeTampIsSameDay(time1: firstModel.datetimeInt, time2: message.datetimeInt)
        } else {
            cellVM.isFirst = true
        }
        
        if sectionVM.items.contains(cellVM) == false {
            sectionVM.items.insert(cellVM, at: 0)
            self.dataSouecesBR.accept(dataSources)
            self.sendMessageBR.accept(message)
        }
        
    }
    
    func getMessageModel(indexPath: IndexPath) -> CODMessageModel? {
        
        if indexPath.section > self.dataSources.count {
            return nil
        }
        
        if indexPath.row > self.dataSources[indexPath.section].items.count {
            return nil
        }
        
        return self.dataSources[indexPath.section].items[indexPath.row].messageModel
        
    }
    
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
        XMPPManager.shareXMPPManager.removeDeleagte(self)
    }
    
}
