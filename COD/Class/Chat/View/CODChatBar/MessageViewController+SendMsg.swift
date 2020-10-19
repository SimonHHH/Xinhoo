//
//  MessageViewController+SendMsg.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework
import RxSwift

///这个是发送消息的类全部的消息在这个类w
extension MessageViewController {
    
    func sendMessage(messageModel: CODMessageModel) {
        
        self.isHaveReplyMessage(messageModel: messageModel)
        
        messageModel.update(burn: self.isBurn)
        if self.chatType == .channel {
            if let channelModel = CODChannelModel.getChannel(by: self.chatId),channelModel.signmsg {
                messageModel.update(n: UserManager.sharedInstance.nickname)
            }else{
                messageModel.update(n: "")
            }
        }
        
        self.messageView.messageDisplayViewVM.sendMessage(message: CODMessageSendTool.default.getCopyModel(messageModel: messageModel))
        
        CODMessageSendTool.default.sendMessage(messageModel: messageModel)
        self.messageView.scrollToBottomWithAnimation(animation: false)
        
    }
    
    ///发送文本消息
    func sendEmojiMessage(text: String?, toJID: String?) {
        
        //回复消息
        var msgIDTemp = ""
        if (toJID?.contains(kCloudJid))!{
            msgIDTemp = UserManager.sharedInstance.getCloudDiskMessageId()
        }else{
            msgIDTemp = UserManager.sharedInstance.getMessageId()
        }
        let model = CODMessageModelTool.default.createTextModel(msgID: msgIDTemp, toJID: toJID!, textString: text ?? "", chatType: self.chatType, roomId: roomId, chatId: self.chatId, burn: self.isBurn )
        
        model.type = .gifMessage
        self.sendMessage(messageModel: model)
    }
    
    var isTransmit: Bool {
        
        if self.transMessage.msgID != "0" || self.transMessages.count > 0 {
            return true
        }
        
        return false
        
    }
    
    var isEdit: Bool {
        
        if self.chatBar.isEdit && self.editMessage.msgID != "0" {
            return true
        }
        
        return false
        
    }
    
    func sendTextMessage(text: String?,attributeStr : NSAttributedString? = nil, toJID: String?, memberArr: Array<CODGroupMemberModel>) {
        
        let newTextString = text ?? ""
        
        func sendTextOrReply() {
            
            if newTextString.removeHeadAndTailSpacePro.count == 0 {
                CODProgressHUD.showWarningWithStatus("不能发送空白消息")
                return
            }
            
            //回复消息
            var msgIDTemp = ""
            if (toJID?.contains(kCloudJid))!{
                msgIDTemp = UserManager.sharedInstance.getCloudDiskMessageId()
            }else{
                msgIDTemp = UserManager.sharedInstance.getMessageId()
            }
            
            let model = self.createReplyModel(model: CODMessageModelTool.default.createTextModel(msgID: msgIDTemp, toJID: toJID!, textString: newTextString,attributeStr: attributeStr , chatType: self.chatType, roomId: roomId, chatId: self.chatId, burn: self.isBurn))
            
            for member in memberArr {
                model.referTo.append(member.jid)
            }
            
            self.sendMessage(messageModel: model)
            
        }
        
        /// 转发
        if isTransmit {
            self.isHaveTransMessage(toJID: toJID)
            
            /// 如果带文字
            if text?.removeHeadAndTailSpacePro.count ?? 0 == 0 {
                return
            }
            
            sendTextOrReply()
            return
            
        }
        
        /// 编辑
        if self.isEdit {
            self.isHaveEidtMessage(newTextString: newTextString,attributeStr: attributeStr, memberArr: memberArr)
            return
        }
        
        /// 回复
        sendTextOrReply()
        
        
    }
    
    func createMessageModel(value: MessageValue.MessageAction) -> CODMessageModel? {
        
        guard let chatListModel = self.chatListModel else {
            return nil
        }
        
        switch chatListModel.chatTypeEnum {
        case .channel:
            return CODMessageModelTool.default.createMessageModel(messageValue: .value(receiver: chatListModel.jid, chatType: .channel(action: value, roomId: chatListModel.channelChat!.roomID)))
            
        case .groupChat:
            return CODMessageModelTool.default.createMessageModel(messageValue: .value(receiver: chatListModel.jid, chatType: .groupChat(action: value, roomId: chatListModel.groupChat!.roomID)))
            
        case .privateChat:
            return CODMessageModelTool.default.createMessageModel(messageValue: .value(receiver: chatListModel.jid, chatType: .privateChat(action: value, jid: chatListModel.jid)))
        }
        
    }
    
    
    /// 重新发送消息
    ///
    /// - Parameters:
    ///   - cell: cell
    ///   - message: 消息
    func cellSendMsgReation(message:CODMessageModel?){
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        
        guard let messageModel = message else {
            return
        }
        
        if let msgID = message?.msgID {
            
            CODMessageRealmTool.getRemoteMessageByMsgId(msgId: msgID, addToRealm: false) { [weak self] (model) in
                
                guard let `self` = self else{
                    return
                }
                guard let model = model else {
                    
                    //先修改按钮
                    CODMessageRealmTool.updateMessageStyleByMsgId(message?.msgID ?? "0", status: CODMessageStatus.Delivering.rawValue, sendTime: message?.datetimeInt ?? 0)
                    
                    if messageModel.edited > 0 {
                        self.resendEditMessage(messageModel: messageModel)
                        return
                    }
                    
                    if messageModel.type == .multipleImage {
                        self.resendMultipleImage(messageModel: messageModel)
                    } else if messageModel.type == .video || messageModel.type == .image {
                        self.resendMessage(messageModel: messageModel)
                    } else if messageModel.type == .file {
                        self.resendFileMessage(model: messageModel)
                    } else {
                        CODMessageSendTool.default.sendMessage(messageModel: messageModel)
                    }
                    
                    return
                }
                
                CODMessageRealmTool.updateMessageStyleByMsgId(message?.msgID ?? "0", status: CODMessageStatus.Succeed.rawValue, sendTime: model.datetimeInt)
                
            }
            
        }
        
    }
    
    
    func resendEditMessage(messageModel: CODMessageModel) {
        
        messageModel.setValue(\.edited, value: messageModel.edited - 1)
        
        self.editMessage = messageModel
        self.editFileMessage = messageModel.editMessage
        
        
        
        if let message = editFileMessage {
            
            self.sendEditMessage(newTextString: message.attrText.string, attributeStr: message.attrText, referToArr: message.referTo.toArray())
        } else {
            self.sendEditMessage(newTextString:  self.editMessage.attrText.string, attributeStr:  self.editMessage.attrText, referToArr:  self.editMessage.referTo.toArray())
        }
        
        
        
        
    }
    
    func resendMessage(messageModel: CODMessageModel) {
        
        let uploadId = messageModel.videoModel?.videoId ?? messageModel.photoModel?.photoId ?? ""
        
        if let videoInfo = messageModel.videoModel?.toVideoInfo() {
            UploadTool.precreateUploadPublishRelay(uploadId: uploadId, file: .video(videoInfo: videoInfo))
        }
        
        if let imageInfo = messageModel.photoModel?.toImageInfo() {
            UploadTool.precreateUploadPublishRelay(uploadId: uploadId, file: .image(imageInfo: imageInfo))
        }
        
        
        
        self.messageView.messageDisplayViewVM.resendMessage(message: messageModel)
        
        CODMessageSendTool.default.resendMessage(messageModel: messageModel)
        
    }
    
    func resendMultipleImage(messageModel: CODMessageModel) {
        
        var unUploadImageInfos: [UploadTool.ImageInfo] = []
        var observers: [Observable<UploadTool.Result>] = []
        
        guard let chatListModel = self.chatListModel else {
            return
        }
        
        let jid = chatListModel.jid
        
        
        let photoList = messageModel.imageList.filter("uploadState != \(UploadStateType.Finished.intValue)").toArray()
        
        for photo in photoList {
            
            if photo.serverImageId.isEmpty == false {
                continue
            }
            
            if let imageData = CODImageCache.default.originalImageCache?.diskImageData(forKey: photo.photoLocalURL) {
                
                var uploadImageInfo = UploadTool.ImageInfo()
                
                uploadImageInfo.photoid = photo.photoId
                uploadImageInfo.h = imageData.imageSize.height.float
                uploadImageInfo.w = imageData.imageSize.width.float
                uploadImageInfo.size = imageData.count
                uploadImageInfo.ishdimg = photo.ishdimg
                
                unUploadImageInfos.append(uploadImageInfo)
                
                let observer = UploadTool.upload(chatType: self.chatType, receiver: jid, fileType: .image(imageInfo: uploadImageInfo)).filter { (result) -> Bool in
                    return result.isProgress != true
                }
                
                observers.append(observer)
                
                
            }
            
        }
        
        messageModel.update(status: .Pending)
        
        if observers.count > 0 {
            
            let _ = Observable.zip(observers).subscribe(onNext: { (result) in
                
                if messageModel.imageList.filter("uploadState != \(UploadStateType.Finished.intValue)").count > 0 {
                    messageModel.update(status: .Failed)
                    return
                }
                
                if messageModel.imageList.count == 1 {
                    messageModel.toImageModel()
                    CODMessageSendTool.default.sendMessage(messageModel: messageModel)
                    
                } else {
                    CODMessageSendTool.default.sendMessage(by: messageModel)
                }
                
                PhotoModelInfo.updateUploadState(photoList: messageModel.imageList, uploadState: .None)
                
            })
            
        } else {
            CODMessageSendTool.default.sendMessage(by: messageModel)
            PhotoModelInfo.updateUploadState(photoList: messageModel.imageList, uploadState: .None)
        }
        
        
        
    }
    
    func sendMultipleImage(imageInfos: [(image: UIImage, imageData: Data?)], ishdimg: Bool) {
        
        guard let chatListModel = self.chatListModel else {
            return
        }
        
        let jid = chatListModel.jid
        
        var imageData: Data? = nil
        var uploadImageInfos: [UploadTool.ImageInfo] = []
        
        for imageInfo in imageInfos {
            
            guard let rawData = imageInfo.imageData else {
                continue
            }
            
            var uploadImageInfo = UploadTool.ImageInfo()
            uploadImageInfo.h = imageInfo.image.size.height.float
            uploadImageInfo.w = imageInfo.image.size.width.float
            uploadImageInfo.size = imageInfo.imageData?.count ?? 0
            uploadImageInfo.ishdimg = ishdimg
            
            uploadImageInfos.append(uploadImageInfo)
            
            if let smallImageData = ImageCompress.compressImageData(rawData, limitLongWidth: kChatImageMaxWidth * UIScreen.main.scale) {
                CODImageCache.default.smallImageCache?.store(UIImage(data: smallImageData), forKey: uploadImageInfo.photoid, completion: nil)
            }
            
            
        }
        
        guard let messageModel = self.createMessageModel(value: .send(messageType: .multipleImage(images: uploadImageInfos))) else {
            return
        }
        
        self.isHavePictureCaption(messageModel: messageModel)
        
        self.messageView.messageDisplayViewVM.sendMessage(message: messageModel)
        
        var observers: [Observable<UploadTool.Result>] = []
        for (index, imageInfo) in imageInfos.enumerated() {
            
            guard let rawData = imageInfo.imageData else {
                continue
            }
            
            let uploadImageInfo = uploadImageInfos[index]
            
            if ishdimg != true {
                imageData = ImageCompress.compressImageData(rawData, limitLongWidth: 1280)
            } else {
                imageData = ImageCompress.compressImageDataToJPEG(rawData)
            }
            
            CODImageCache.default.originalImageCache?.storeImageData(toDisk: imageData, forKey: uploadImageInfo.photoid)
            
            let observer = UploadTool.upload(chatType: self.chatType, receiver: jid, fileType: .image(imageInfo: uploadImageInfo)).filter { (result) -> Bool in
                return result.isProgress != true
            }
            
            observers.append(observer)
            
        }
        
        if observers.count > 0 {
            
            let _ = Observable.zip(observers).subscribe(onNext: { (result) in
                
                let imageList = result.map { (r) -> UploadTool.ImageInfo? in
                    switch r {
                    case .success(file: .image(imageInfo: let imageInfo)):
                        return imageInfo
                    default:
                        return nil
                    }
                }
                .compactMap { $0 }
                .map { PhotoModelInfo.createModel(imageInfo: $0) }
                
                //                if imageList.count != messageModel.imageList.count {
                //                    messageModel.update(status: .Failed)
                //                    return
                //                }
                
                if imageList.count == 0 {
                    messageModel.update(status: .Failed)
                    return
                }
                
                if messageModel.imageList.filter("uploadState == \(UploadStateType.Fail.intValue)").count > 0 {
                    messageModel.update(status: .Failed)
                    return
                }
                
                
                if messageModel.imageList.contains(imageList) == false {
                    messageModel.update(status: .Failed)
                    return
                }
                
                messageModel.update(imageList: imageList)
                
                if messageModel.imageList.count == 1 {
                    
                    messageModel.toImageModel()
                    CODMessageSendTool.default.sendMessage(messageModel: messageModel)
                    
                } else if imageList.count > 1 {
                    CODMessageSendTool.default.sendMessage(by: messageModel)
                } else {
                    return
                }
                
                PhotoModelInfo.updateUploadState(photoList: messageModel.imageList, uploadState: .None)
                
                
            })
            
        }
        
        
        
        
    }
    
    ///发送图片消息
    func sendImagePreprocess(image: UIImage, isGif: Bool = false, imageData: Data?, ishdimg: Bool) -> CODMessageModel {
        
        //非原图片限制长宽1280
        var imageData = imageData
        
        let isGif  = imageData?.imageFormat == .gif
        
        if let rawData = imageData, isGif != true, ishdimg != true {
            imageData = ImageCompress.compressImageData(rawData, limitLongWidth: 1280)
        }
        
        if let rawData = imageData, isGif != true && ishdimg == true {
            imageData = ImageCompress.compressImageDataToJPEG(rawData)
        }
        
        let msgIDTemp = UserManager.sharedInstance.getMessageId()
        let model = self.createReplyModel(model: CODMessageModelTool.default.createPhotoModel(msgID: msgIDTemp, toJID: self.toJID, photoImage: image, photoImageData: imageData ?? Data(), chatType: self.chatType, ishdimg: ishdimg, roomId: self.roomId, chatId: self.chatId, burn: self.isBurn ,size: imageData?.count ?? 0))
        model.photoModel?.photoLocalURL = model.photoModel?.photoId ?? ""
        if isGif {
            model.photoModel?.isGIF = true
            model.photoModel?.h = image.size.height.float
            model.photoModel?.w = image.size.width.float
        }
        
        if let photoLocalURL = model.photoModel?.photoLocalURL, let rawData = imageData  {
            
            
            if rawData.imageFormat == .gif {
                if let image = UIImage(data: rawData), let smallImageData = ImageCompress.resetImgSize(sourceImage: image, maxImageLenght: kChatImageMaxWidth * UIScreen.main.scale, maxSizeKB: 1024) {
                    CODImageCache.default.smallImageCache?.store(UIImage(data: smallImageData), forKey: photoLocalURL, completion: nil)
                }
            } else {
                if let smallImageData = ImageCompress.compressImageData(rawData, limitLongWidth: kChatImageMaxWidth * UIScreen.main.scale) {
                    CODImageCache.default.smallImageCache?.store(UIImage(data: smallImageData), forKey: photoLocalURL, completion: nil)
                }
            }
            
            CODImageCache.default.originalImageCache?.storeImageData(toDisk: imageData, forKey: photoLocalURL)
            
        }
        
        return model
        
    }
    
    func editImageMessage(image: UIImage, isGif: Bool = false, imageData: Data?, ishdimg: Bool) {
        
        let model = sendImagePreprocess(image: image, isGif: isGif, imageData: imageData, ishdimg: ishdimg)
        
        self.editFileMessage = model
        self.editView.setEidtImageView(model)
    }
    
    func sendImageMessage(image: UIImage, isGif: Bool = false, imageData: Data?, ishdimg: Bool)  {
        
        let model = sendImagePreprocess(image: image, isGif: isGif, imageData: imageData, ishdimg: ishdimg)
        
        self.isHavePictureCaption(messageModel: model)
        
        self.sendMessage(messageModel: model)
    }
    
    
    func isHavePictureCaption(messageModel: CODMessageModel) {
        
        if self.captionView != nil {
            if messageModel.type == .multipleImage {
                messageModel.text = self.captionView?.textView.text ?? ""
            }else if messageModel.type == .image {
                messageModel.photoModel?.descriptionImage = self.captionView?.textView.text ?? ""
            }else if messageModel.type == .video {
                messageModel.videoModel?.descriptionVideo = self.captionView?.textView.text ?? ""
            }
            messageModel.l = 0
            
            let list = List<CODAttributeTextModel>()
            if let arr = self.captionView?.textView.attributedText?.getAttributesWithArray() {
                for dic in arr{
                    if let attributeModel = CODAttributeTextModel.deserialize(from: dic) {
                        list.append(attributeModel)
                        if attributeModel.typeEnum == .text_link{
                            messageModel.l = 1
                        }
                    }
                }
            }
            messageModel.entities = list
            self.captionView?.dismissCaptionView()
            //            self.captionView?.toolView = UIView()
            //            self.captionView?.selectPersonView = nil
            //            self.captionView?.removeFromSuperview()
            //            self.captionView = nil
        }
    }
    
    //发送语音
    func sendVoiceMessage(audioLocalPath:String?,displayName:String?,duration:Int,toJID:String?) {
        
        let msgIDTemp = UserManager.sharedInstance.getMessageId()
        self.recordLabel.isHidden = true
        
        self.view.layoutIfNeeded()
        self.messageView.scrollToBottomWithAnimation(animation: false)
        if let data = NSData.init(contentsOfFile: audioLocalPath ?? "") , data.count > 10{
            let model = self.createReplyModel(model: CODMessageModelTool.default.createAudioModel(msgID: msgIDTemp, toJID: self.toJID, duration: CGFloat(duration), audioData: data, audioLocalURl: displayName ?? "", chatType: self.chatType, roomId: roomId, chatId: self.chatId, burn: self.isBurn ,size: data.count))
            self.sendMessage(messageModel: model)
            self.messageView.tableView.isUserInteractionEnabled = true
            self.view.isUserInteractionEnabled = true 
            self.chatBar.isUserInteractionEnabled = true
            self.isRecording = false
        }
    }
    
    func prepareEditVideoMessage(msgID: String, duration:CGFloat, firstpic: UIImage, editVideoUrl: URL?) {
        
        let model = self.createReplyModel(model: CODMessageModelTool.default.createVideoModel(msgID: msgID, toJID: self.toJID, duration: duration, firstpicImage: firstpic, chatType: self.chatType, roomId: roomId, chatId: self.chatId, burn: self.isBurn, size: 0))
        
        
        self.editVideoUrl = editVideoUrl
        model.msgID = UserManager.sharedInstance.getMessageId()
        
        if self.chatType == .channel {
            if let channelModel = CODChannelModel.getChannel(by: self.chatId),channelModel.signmsg {
                model.n = UserManager.sharedInstance.nickname ?? ""
            }else{
                model.n = ""
            }
        }
        
        if let videoId = model.videoModel?.videoId {
            
            if let smallImageData = ImageCompress.resetImgSize(sourceImage: firstpic, maxImageLenght: 280, maxSizeKB: 600) {
                CODImageCache.default.smallImageCache?.store(UIImage(data: smallImageData), forKey: videoId, completion: nil)
            }
            
            CODImageCache.default.originalImageCache?.store(firstpic, forKey: videoId, completion: nil)
            
            
            if let editVideoUrl = editVideoUrl {
                try? FileManager.default.copyItem(at: editVideoUrl, to: URL(fileURLWithPath: CODFileManager.shareInstanceManger().mp4TempPathWithName(fileName: videoId)))
            }
            
            
        }
        
        model.addToDB()
        model.setValue(\.editMessage, value: model)
        
        
        
        self.editView.setEidtImageView(model)
        self.editFileMessage = model
        
        
        
    }
    
    ///发送视频消息
    func prepareSendVideoMessage(msgID: String, duration:CGFloat, firstpic: UIImage, toID:String?) {
        
        let model = self.createReplyModel(model: CODMessageModelTool.default.createVideoModel(msgID: msgID, toJID: self.toJID, duration: duration, firstpicImage: firstpic, chatType: self.chatType, roomId: roomId, chatId: self.chatId, burn: self.isBurn, size: 0))
        if self.chatType == .channel {
            if let channelModel = CODChannelModel.getChannel(by: self.chatId),channelModel.signmsg {
                model.n = UserManager.sharedInstance.nickname ?? ""
            }else{
                model.n = ""
            }
        }
        
        
        if let videoModel = model.videoModel {
            
            let videoId = videoModel.videoId
            
            _ = videoModel.setValue(UploadStateType.Handling.intValue, forKey: \.uploadState)
            
            if let smallImageData = ImageCompress.resetImgSize(sourceImage: firstpic, maxImageLenght: 280, maxSizeKB: 600) {
                CODImageCache.default.smallImageCache?.store(UIImage(data: smallImageData), forKey: videoId, completion: nil)
            }
            
            CODImageCache.default.originalImageCache?.store(firstpic, forKey: videoId, completion: nil)
            
            UploadTool.precreateUploadPublishRelay(uploadId: videoId, file: .video(videoInfo: videoModel.toVideoInfo()))
            
        }
        
        self.isHavePictureCaption(messageModel: model)
        
        self.messageView.messageDisplayViewVM.sendMessage(message: model)
        
        
    }
    
    //发名片
    func sendCardWithModel(model: CODMessageModel) {
        
        self.sendMessage(messageModel: self.createReplyModel(model:model))
    }
    
    ///发送语音聊天信息
    func sendVideoCallMessage(model: CODMessageModel) {
        
        self.sendMessage(messageModel: self.createReplyModel(model:model))
    }
    
    func sendLocationWithModel(model: CODMessageModel) {
        
        self.sendMessage(messageModel: self.createReplyModel(model:model))
    }
    
    func sendFile(fileURL: URL?) {
        
        guard let fileURL = fileURL else {
            return
        }
        
        if FileManager.default.isReadableFile(atPath: fileURL.path) == false {
            return
        }
        
        var model = CODMessageModelTool.default.createFileModel(fileURL: fileURL, fileName: nil, toJID: self.toJID, chatType: self.chatType, roomId: self.roomId, chatId: self.chatId, burn: self.isBurn)
        
        guard let fileModel = model.fileModel else {
            return
        }
        
        let newFilePath = CODFileManager.shareInstanceManger().filePathWithName(fileName: "\(fileModel.localFileID).\(fileModel.filename.pathExtension)")
        
        do {
            
            let newURL = URL(fileURLWithPath: newFilePath)
            
            try FileManager.default.copyItem(at: fileURL, to: newURL)
            
            if fileModel.fileType == .VideoType {
                
                CODImageCache.default.smallImageCache?.store(CustomUtil.generateThumbnailForVideo(at: newURL),
                                                             forKey: fileModel.localFileID, toDisk: true, completion: nil)
                
                CODImageCache.default.originalImageCache?.store(CustomUtil.generateThumbnailForVideo(at: newURL),
                                                                forKey: fileModel.localFileID, toDisk: true, completion: nil)
                
            } else if fileModel.fileType == .ImageType {
                
                do {
                    
                    let imageData = try Data(contentsOf: newURL, options: .mappedRead)
                    
                    guard let image = UIImage(data: imageData) else {
                        return
                    }
                    
                    let miniImageData = ImageCompress.resetImgSize(sourceImage: image, maxImageLenght: 256, maxSizeKB: 100)
                    
                    CODImageCache.default.smallImageCache?.storeImageData(toDisk: miniImageData, forKey: fileModel.localFileID)
                    CODImageCache.default.originalImageCache?.storeImageData(toDisk: miniImageData, forKey: fileModel.localFileID)
                    
                } catch {
                    
                }
                
                
            }
            
            
            let attributes = try FileManager.default.attributesOfItem(atPath: newFilePath)
            
            if let size = attributes[.size] as? Int {
                model.fileModel?.size = size
                model.fileModel?.fileSizeString = CODFileHelper.getFileSize(fileSize: CGFloat(size))
            }
            
            model = self.createReplyModel(model: model)
            
            self.sendFileMessage(model: model)
            

        } catch {
            
            DDLogError("发送文件失败！")
            
        }
    }
    
    func sendFile(fileData: Data?, fileName: String) {
        
        guard let fileData = fileData else {
            return
        }
        var model = CODMessageModelTool.default.createFileModel(fileURL: nil, fileName: fileName, toJID: self.toJID, chatType: self.chatType, roomId: self.roomId, chatId: self.chatId, burn: self.isBurn)
        
        guard let fileModel = model.fileModel else {
            return
        }
        
        let newFilePath = CODFileManager.shareInstanceManger().filePathWithName(fileName: "\(fileModel.localFileID).\(fileName.pathExtension)")
        
        do {
            
            let newURL = URL(fileURLWithPath: newFilePath)
            
            
            try FileManager.default.createFile(atPath: newFilePath, contents: fileData, attributes: nil)
            
            if fileModel.fileType == .VideoType {
                
                CODImageCache.default.smallImageCache?.store(CustomUtil.generateThumbnailForVideo(at: newURL),
                                                             forKey: fileModel.localFileID, toDisk: true, completion: nil)
                
                CODImageCache.default.originalImageCache?.store(CustomUtil.generateThumbnailForVideo(at: newURL),
                                                                forKey: fileModel.localFileID, toDisk: true, completion: nil)
                
            } else if fileModel.fileType == .ImageType {
                
                do {
                    
                    let imageData = try Data(contentsOf: newURL, options: .mappedRead)
                    
                    guard let image = UIImage(data: imageData) else {
                        return
                    }
                    
                    let miniImageData = ImageCompress.resetImgSize(sourceImage: image, maxImageLenght: 256, maxSizeKB: 100)
                    
                    CODImageCache.default.smallImageCache?.storeImageData(toDisk: miniImageData, forKey: fileModel.localFileID)
                    CODImageCache.default.originalImageCache?.storeImageData(toDisk: miniImageData, forKey: fileModel.localFileID)
                    
                } catch {
                    
                }
                
                
            }
            
            
            let attributes = try FileManager.default.attributesOfItem(atPath: newFilePath)
            
            if let size = attributes[.size] as? Int {
                model.fileModel?.size = size
                model.fileModel?.fileSizeString = CODFileHelper.getFileSize(fileSize: CGFloat(size))
            }
            
            model = self.createReplyModel(model: model)
            
            self.sendFileMessage(model: model)
            

        } catch {
            
            DDLogError("发送文件失败！")
            
        }
        
    }
    
    func sendFileMessage(model: CODMessageModel) {
        
        guard let localFileID = model.fileModel?.localFileID else {
            return
        }
        
        
        UploadTool.precreateUploadPublishRelay(uploadId: localFileID, file: .file(msgID: model.msgID))

        self.messageView.messageDisplayViewVM.sendMessage(message: model)

        self.uploadAndSendFileMessage(model: model)
        

    }

    func uploadAndSendFileMessage(model: CODMessageModel) {
        
        let uploadObserver = UploadTool.upload(chatType: model.chatTypeEnum, receiver: model.toJID, fileType: .file(msgID: model.msgID))
        
        uploadObserver
            .filter { $0.isSuccess }
            .bind { (_) in
                
                CODMessageSendTool.default.sendMessage(by: model)
                
        }
        .disposed(by: self.rx.disposeBag)
        
    }
    
    func resendFileMessage(model: CODMessageModel) {
        
        guard let localFileID = model.fileModel?.localFileID else {
            return
        }
        
        UploadTool.precreateUploadPublishRelay(uploadId: localFileID, file: .file(msgID: model.msgID))
        
        
        self.messageView.messageDisplayViewVM.resendMessage(message: model)
        
        if model.fileModel?.fileID.count ?? 0 > 0  {
            CODMessageSendTool.default.sendMessage(by: model)
        } else {
            self.uploadAndSendFileMessage(model: model)
        }
        
    }
    
}
extension MessageViewController {
    
    
    func receiveChatState() {
        XMPPManager.shareXMPPManager.receiveChatState = { [weak self] (state: XMPPMessage.ChatState) in
            guard let self = self else {
                return
            }
            if state == .composing {
                self.navBarTitleView.isHiddenForInputtingState = false
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+30, execute: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.navBarTitleView.isHiddenForInputtingState = true
                })
            }
            if state == .paused {
                self.navBarTitleView.isHiddenForInputtingState = true
            }
        }
    }
    
    func createReplyModel(model: CODMessageModel) -> CODMessageModel {
        if  self.replyMessage.msgID != "0" {
            self.editView.isHidden = true
            self.chatBar.isEdit = false
            self.updateMessageView()
            if let chatListModel = CODChatListRealmTool.getChatList(id: self.chatId) {
                try! Realm.init().write {
                    chatListModel.replyMessage = nil
                }
            }
            model.rp = self.replyMessage.msgID
            if self.isGroupChat && !(self.replyMessage.fromWho.contains(UserManager.sharedInstance.loginName!)) {
                model.referTo.insert(self.replyMessage.fromJID, at: 0)
            }
            self.replyMessage = CODMessageModel()
        }
        
        self.view.layoutIfNeeded()
        return model
    }
    
    
}

extension MessageViewController {
    
    func editTextMsg(editText: String,attributeStr : NSAttributedString? = nil, msgID: String, referTo:Array<String>) {
        
        if let message = CODMessageRealmTool.getMessageByMsgId(msgID) {
            CODMessageSendTool.default.editMsg(editText: editText, attributeStr: attributeStr, msgID: msgID, referTo: referTo, messageModel: message)
        }
        
        
    }
    
}

extension MessageViewController {
    
    func isHaveReplyMessage(messageModel: CODMessageModel) {
        
        if  self.replyMessage.msgID != "0" && messageModel.msgType != 14 {
            self.editView.isHidden = true
            self.chatBar.isEdit = false
            self.updateMessageView()
            if let chatListModel = CODChatListRealmTool.getChatList(id: self.chatId) {
                try! Realm.init().write {
                    chatListModel.replyMessage = nil
                }
            }
            messageModel.rp = self.replyMessage.msgID
            messageModel.referTo.insert(self.replyMessage.fromJID, at: 0)
            self.replyMessage = CODMessageModel()
        }
    }
    
    func isHaveTransMessage(toJID: String?) {
        
        if self.transMessage.msgID != "0" {
            let fileIDs = CustomUtil.getMessageFileIDS(messages: [self.transMessage])
            
            
            self.vaildTranfile(fileIDs: CustomUtil.getPictureID(fileIDs: fileIDs), type: .ChatToCloudDisk, messages: [self.transMessage])
            //            let copyModel = CODMessageSendTool.default.getCopyModel(messageModel: self.transMessage)
            //            copyModel.burn = self.isBurn
            let copyModel = self.getTransCopyModel(model: self.transMessage, isGroupChat: self.isGroupChat)
            copyModel.toJID = self.toJID
            copyModel.toWho = self.toJID
            copyModel.burn = self.isBurn
            copyModel.chatTypeEnum = self.chatType
            var msgIDTemp = ""
            if (toJID?.contains(kCloudJid))!{
                msgIDTemp = UserManager.sharedInstance.getCloudDiskMessageId()
            }else{
                msgIDTemp = UserManager.sharedInstance.getMessageId()
            }
            copyModel.msgID = msgIDTemp
            copyModel.roomId = roomId?.int ?? 0
            if self.transMessage.msgType == 4 {
                self.addMessageToView(model: copyModel)
            }
            
            if self.transMessage.msgType == 4 ||  self.transMessage.msgType == 2 || (self.transMessage.msgType == 7  && self.transMessage.fileModel?.thumb.removeAllSapce.count ?? 0 > 0){
            }
            
            if self.transMessage.type == .multipleImage {
                CODMessageSendTool.default.sendMessage(by: copyModel)
            } else {
                self.sendMessage(messageModel: copyModel)
            }
            
            self.copyMediaFile(messageModel: copyModel)
            self.editView.isHidden = true
            self.chatBar.isEdit = false
            self.updateMessageView()
            self.transMessage = CODMessageModel()
            
        }
        
        if self.transMessages.count > 0 {
            
            let fileIDs = CustomUtil.getMessageFileIDS(messages: self.transMessages)
            
            if transJid.contains(kCloudJid) {
                self.vaildTranfile(fileIDs: CustomUtil.getPictureID(fileIDs: fileIDs), type: .CloudDiskToChat, isNeedJump: false, messages: self.transMessages)
            } else {
                self.vaildTranfile(fileIDs: CustomUtil.getPictureID(fileIDs: fileIDs), type: .ChatToChat, isNeedJump: false, messages: self.transMessages)
            }
            
            for messageModel in self.transMessages {
                //回复消息
                var msgIDTemp = ""
                if (toJID?.contains(kCloudJid))!{
                    msgIDTemp = UserManager.sharedInstance.getCloudDiskMessageId()
                }else{
                    msgIDTemp = UserManager.sharedInstance.getMessageId()
                }
                
                let copySendModel = self.getTransCopyModel(model: messageModel, isGroupChat: self.isGroupChat)
                copySendModel.msgID = msgIDTemp
                copySendModel.roomId = roomId?.int ?? 0
                copySendModel.burn = self.isBurn
                copySendModel.toJID = self.toJID
                copySendModel.toWho = self.toJID
                copySendModel.burn = self.isBurn
                copySendModel.chatTypeEnum = self.chatType
                if messageModel.type == .multipleImage {
                    CODMessageSendTool.default.sendMessage(by: copySendModel)
                } else {
                    self.sendMessage(messageModel: copySendModel)
                }
                
                
                self.copyMediaFile(messageModel: copySendModel)
                if messageModel.msgType == 4 {
                    self.addMessageToView(model: copySendModel)
                    //                 self.messageView.lastMeassage = copySendModel
                }
                if messageModel.msgType == 4 ||  messageModel.msgType == 2 || (messageModel.msgType == 7  && messageModel.fileModel?.thumb.removeAllSapce.count ?? 0 > 0){
                }
            }
            
            self.editView.isHidden = true
            self.chatBar.isEdit = false
            self.updateMessageView()
            self.transMessages = []
        }
        CODChatListRealmTool.deleteSavedTransMsgs(chatId: self.chatId)
        
    }
    
    
    fileprivate func editImageOrVideo(_ newTextString: String, _ attributeStr: NSAttributedString?, _ referToArr: [String]) {
        //刷新编辑视频
        let editFileCopyModel = self.editFileMessage
        editFileCopyModel?.referTo.append(objectsIn: referToArr)
        
        /// 修改消息状态
        if self.editFileMessage?.msgID == "0" {
            self.editMessage.editMessage(model: nil, status: .Pending)
        }else{
            self.editMessage.editMessage(model: editFileCopyModel, status: .Pending)
            
        }
        
        self.editMessage.update(edited: self.editMessage.edited + 1)
        
        self.editMessage.setValue(\.status, value: CODMessageStatus.Pending.rawValue)
        self.editFileMessage?.setValue(\.status, value: CODMessageStatus.Pending.rawValue)
        
        
        let msgID = self.editMessage.msgID
        
        switch self.editFileMessage?.type {
        case .image:
            
            guard let imageInfo = self.editFileMessage?.photoModel?.toImageInfo() else {
                return
            }
            
            
            /// 刷新UI
            UploadTool.precreateUploadPublishRelay(uploadId: self.editFileMessage?.photoModel?.photoId ?? "", file: .image(imageInfo: imageInfo))
            
            self.messageView.messageDisplayViewVM.updateEditMessage(message: self.editMessage)
            
            /// 上传图片
            
            
            UploadTool.upload(chatType: self.editMessage.chatTypeEnum, receiver: chatListModel?.jid ?? "", fileType: .image(imageInfo: imageInfo))
                .subscribe(onNext: { [weak self] (result) in
                    
                    guard let `self` = self else { return }
                    
                    switch result {
                        
                    case .success(file: _):
                        //                        self.editMessage.setValue(\.photoModel, value: self.editFileMessage?.photoModel)
                        self.editTextMsg(editText: newTextString,attributeStr: attributeStr, msgID: "\(msgID)", referTo: referToArr)
                    default:
                        break
                    }
                    
                })
                .disposed(by: rx.disposeBag)
            
        case .video:
            
            guard let editFileMessage = self.editFileMessage,
                let videoModel = self.editFileMessage?.videoModel else {
                    return
            }
            
            let editVideoUrl = URL(fileURLWithPath: CODFileManager.shareInstanceManger().mp4TempPathWithName(fileName: videoModel.videoId))
            _ = videoModel.setValue(UploadStateType.Handling.intValue, forKey: \.uploadState)
            
            /// 上传视频
            
            //            let editMsgID = editFileMessage.msgID
            let videoId = videoModel.videoId
            
            UploadTool.precreateUploadPublishRelay(uploadId: videoId, file: .video(videoInfo: videoModel.toVideoInfo()))
            
            /// 刷新UI
            self.messageView.messageDisplayViewVM.updateEditMessage(message: self.editMessage)
            
            DispatchQueue(label: "compressVideo").async {
                
                let fileURL = URL(fileURLWithPath: CODFileManager.shareInstanceManger().mp4PathWithName(fileName: videoId))
                
                func uploadVideo() {
                    
                    guard let videoInfo = editFileMessage.videoModel?.toVideoInfo() else {
                        return
                    }
                    
                    _ = editFileMessage.videoModel?.setValue((try? Data(contentsOf: fileURL).count) ?? 0, forKey: \.size)
                    
                    UploadTool.upload(chatType: self.editMessage.chatTypeEnum, receiver: self.chatListModel?.jid ?? "", fileType: .video(videoInfo: videoInfo))
                        .subscribe(onNext: { [weak self] (result) in
                            
                            guard let `self` = self else { return }
                            
                            if result.isSuccess {
                                self.editTextMsg(editText: newTextString,attributeStr: attributeStr, msgID: "\(msgID)", referTo: referToArr)
                            }
                            
                            
                        })
                        .disposed(by: self.rx.disposeBag)
                    
                }
                
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    
                    DispatchQueue.main.async {
                        uploadVideo()
                    }
                    
                } else {
                    
                    CODVideoCompressTool.compressVideoV2(editVideoUrl, withOutputUrl: fileURL, complete: { (success) in
                        
                        if success {
                            
                            DispatchQueue.main.async {
                                uploadVideo()
                            }
                            
                            
                            
                        }
                    })
                    
                }
                
                
                
                
            }
            
            
            break
            
        default:
            
            self.messageView.messageDisplayViewVM.updateEditMessage(message: self.editMessage)
            self.editTextMsg(editText: newTextString,attributeStr: attributeStr, msgID: "\(msgID)", referTo: referToArr)
            break
        }
        
        
    }
    
    
    func sendEditMessage(newTextString: String,attributeStr:NSAttributedString? = nil, referToArr: [String]) {
        
        let editMessage = self.editFileMessage ?? self.editMessage
        
        if self.editFileMessage != nil {
            
            try? Realm().safeWrite {
                
                switch editMessage.type {
                case .image:
                    editMessage.photoModel?.descriptionImage = newTextString
                case .video:
                    editMessage.videoModel?.descriptionVideo = newTextString
                case .audio:
                    editMessage.audioModel?.descriptionAudio = newTextString
                case .file:
                    editMessage.fileModel?.descriptionFile = newTextString
                default:
                    break
                    //                editMessage.text = newTextString
                }
                
                if let attributeStr = attributeStr {
                    let attList = List<CODAttributeTextModel>()
                    attList.append(objectsIn: attributeStr.toAttributeTextModelList())
                    editMessage.entities = attList
                }
                
            }
            
            
        }
        
        
        
        switch self.editMessage.type {
        case .image, .video:
            editImageOrVideo(newTextString, attributeStr, referToArr)
        default:
            
            if newTextString.removeHeadAndTailSpacePro.count == 0 {
                CODProgressHUD.showWarningWithStatus("不能发送空白消息")
                return
            }
            
            self.editTextMsg(editText: newTextString,attributeStr: attributeStr, msgID: "\(editMessage.msgID)", referTo: referToArr)
        }
        
        
        self.editView.isHidden = true
        self.chatBar.isEdit = false
        self.updateMessageView()
        self.editMessage = CODMessageModel()
        self.editFileMessage = nil
        if let chatListModel = CODChatListRealmTool.getChatList(id: self.chatId) {
            try! Realm.init().write {
                chatListModel.editMessage = nil
            }
        }
        
    }
    
    func isHaveEidtMessage(newTextString: String,attributeStr:NSAttributedString? = nil, memberArr: Array<CODGroupMemberModel>) {
        
        var referToArr = Array<String>()
        for member in memberArr {
            referToArr.append(member.jid)
        }
        
        self.sendEditMessage(newTextString: newTextString, attributeStr: attributeStr, referToArr: referToArr)
        
    }
    
    func sendVideoEidtMessage(messageModel: CODMessageModel) {
        CODMessageSendTool.default.sendMessage(messageModel: messageModel)
        
        if self.editMessage.msgID == messageModel.rp {
            
            self.editView.isHidden = true
            self.chatBar.isEdit = false
            self.updateMessageView()
        }
    }
    
}

extension MessageViewController {
    
    func copyVideoFileToChat(videoModel: CODMessageModel,videoFile:String) {
        
        let filePath = CODFileManager.shareInstanceManger().mp4PathWithName(fileName: String(format: "%ld", videoModel.videoModel?.videoId ?? 0))
        ///已经下载 文件存在
        if (FileManager.default.fileExists(atPath: filePath)){
        }else{
            do {
                try FileManager.default.copyItem(atPath: videoFile, toPath: filePath)
            } catch {
                print("视频路径拷贝失败")
            }
        }
    }
    
    //保存图片至沙盒
    private func saveImage(imageData: Data, persent: CGFloat, imageName: String,messageModel: CODMessageModel){
        
        let mD5Url = imageName.md5()
        let filePath = CODFileManager.shareInstanceManger().imagePathWithName(fileName: mD5Url)
        do {
            try imageData.write(to: URL.init(fileURLWithPath: filePath))
            CODMessageRealmTool.updateMessagePhotoLocalURLByMsgId(imageName, photoLocalURL: filePath)
        } catch {
            print("保存失败")
        }
    }
    
    func copyMediaFile(messageModel: CODMessageModel,toPathJid: String = "",fromPathJid: String = "") {
        
        var orginalPathJid = self.transJid
        if fromPathJid.removeAllSapce.count > 0{
            orginalPathJid = fromPathJid
        }
        
        var pathJid = self.toJID
        if toPathJid.removeAllSapce.count > 0{
            pathJid = toPathJid
        }
        
        
        CustomUtil.copyMediaFile(messageModel: messageModel, fromPathJid: orginalPathJid, toPathJid: pathJid)
    }
}


