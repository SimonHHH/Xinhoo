//
//  CODMessageSendTool.swift
//  COD
//
//  Created by 1 on 2019/4/24.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODMessageSendTool: Object {
    
    static var `default`: CODMessageSendTool  = CODMessageSendTool()
    var cancelMsgID: String = "0"
    
    func getCopyModel(messageModel: CODMessageModel) -> CODMessageModel {
        
        if var newMessage = CODMessageModel.deserialize(from: messageModel.toJSONString()) {
            newMessage.rp  = messageModel.rp
            newMessage.nick  = messageModel.nick
            newMessage.type = messageModel.type
            newMessage.msgType = messageModel.msgType
            newMessage.l = messageModel.l
            newMessage.editMessage = messageModel.editMessage
            //            newMessage.burn = messageModel.burn
            let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: messageModel.msgType) ?? .text
            newMessage.type = modelType
            newMessage.entities = messageModel.entities
            //转发的时候会崩
            let referToArr = List<String>()
            for referToString in messageModel.referTo {
                referToArr.append(referToString)
            }
            newMessage.referTo = referToArr
            switch modelType {
            case .text:
                
                break
                
            case .image:
                newMessage = CODMessageModel(value: messageModel)
                break
                
            case .audio:
                let audioModel = AudioModelInfo.deserialize(from: messageModel.audioModel?.toJSONString())
                newMessage.audioModel = audioModel
                let lastStr = messageModel.audioModel?.audioLocalURL.components(separatedBy: "/").last
                let audioFilePath = CODAudioPlayerManager.sharedInstance.pathUserPathWithAudio(jid: messageModel.toJID).appendingPathComponent(lastStr!)
                newMessage.audioModel?.audioDuration = messageModel.audioModel?.audioDuration ?? 0
                newMessage.audioModel?.audioLocalURL = messageModel.audioModel?.audioLocalURL ?? ""
                newMessage.audioModel?.audioURL = messageModel.audioModel?.audioURL ?? ""
                newMessage.audioModel?.descriptionAudio = messageModel.audioModel?.descriptionAudio ?? ""
                newMessage.audioModel?.size = messageModel.audioModel?.size ?? 0
                break
                
            case .video:
                newMessage = CODMessageModel(value: messageModel)
                break
                
            case .voiceCall, .videoCall:
                let videoCallModel = VideoCallModelInfo.deserialize(from: messageModel.videoCallModel?.toJSONString())
                newMessage.videoCallModel = videoCallModel
                newMessage.videoCallModel?.videoString = messageModel.videoCallModel?.videoString ?? " "
                newMessage.videoCallModel?.room = messageModel.videoCallModel?.room ?? "1234"
                break
                
            case .location:
                let locationModel = LocationInfo.deserialize(from: messageModel.location?.toJSONString())
                newMessage.location = locationModel
                newMessage.location?.latitude = messageModel.location?.latitude ?? 0
                newMessage.location?.longitude = messageModel.location?.longitude ?? 0
                newMessage.location?.name = messageModel.location?.name ?? ""
                newMessage.location?.address = messageModel.location?.address ?? ""
                newMessage.location?.loactionImageData = messageModel.location?.loactionImageData
                newMessage.location?.descriptionLoaction = messageModel.location?.descriptionLoaction ?? ""
                
                break
            case .businessCard:
                let businessCardModel = BusinessCardModelInfo.deserialize(from: messageModel.businessCardModel?.toJSONString())
                newMessage.businessCardModel = businessCardModel
                newMessage.businessCardModel?.descriptionBusiness = messageModel.businessCardModel?.descriptionBusiness ?? ""
                break
            case .file:
                newMessage = CODMessageModel(value: messageModel)
                break
                
            case .multipleImage:
                newMessage = CODMessageModel(value: messageModel)
            default:
                
                break
            }
            
            return newMessage
        }else{
            return messageModel
        }
    }
    
    func sendMessage(by messageModel: CODMessageModel) {
        
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            CODMessageRealmTool.updateMessageStyleByMsgId(messageModel.msgID, status: CODMessageStatus.Failed.rawValue, sendTime: messageModel.datetimeInt)
            return
        }
        
        XMPPManager.shareXMPPManager.xmppStream.send(messageModel.toXMPPMessage())
    }
    
    func resendMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        if !CODWebRTCManager.whetherConnectedNetwork() {
            
            CODProgressHUD.showErrorWithStatus("暂无网络")
            CODMessageRealmTool.updateMessageStyleByMsgId(messageModel.msgID, status: CODMessageStatus.Failed.rawValue, sendTime: messageModel.datetimeInt)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                CODUploadTool.default.postAUpdateMessageToView(messageID: messageModel.msgID)
            }
            return
        }
        
        if messageModel.msgID == cancelMsgID  {
            cancelMsgID = "0"
            return
        }
        
        let messageModel = messageModel.editMessage ?? messageModel
        
        
        let newMessage = CODMessageModel(value: messageModel)
        newMessage.type = EMMessageBodyType(rawValue: messageModel.msgType) ?? .text
        switch newMessage.type {
        case .text:
            
            self.sendTextMessage(messageModel: newMessage, sender: sender)
            break
        case .gifMessage:
            
            self.sendEmojiMessage(messageModel: newMessage, sender: sender)
            break
        case .image:
            
            self.sendImageMessage(messageModel: messageModel, sender: sender)
            break
            
        case .audio:
            
            self.sendAudioMessage(messageModel: newMessage, sender: sender)
            break
            
        case .video:
            
            self.sendVideoMessage(messageModel: messageModel, sender: sender)
            break
            
        case .voiceCall,.videoCall:
            
            self.sendVideoCallMessage(messageModel: newMessage, sender: sender)
            break
            
        case .location:
            
            self.sendLocationMessage(messageModel: newMessage, sender: sender)
            break
        case .businessCard:
            
            self.sendBusinessCardMessage(messageModel: newMessage, sender: sender)
            break
        case .file:
            
            self.sendFileMessage(messageModel: newMessage, sender: sender)
            break
            
        case .multipleImage:
            self.sendMessage(by: newMessage)
            break
        default:
            
            break
        }
    }
    
    func sendMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            CODMessageRealmTool.updateMessageStyleByMsgId(messageModel.msgID, status: CODMessageStatus.Failed.rawValue, sendTime: messageModel.datetimeInt)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                CODUploadTool.default.postAUpdateMessageToView(messageID: messageModel.msgID)
            }
            return
        }
        if messageModel.msgID == cancelMsgID  {
            cancelMsgID = "0"
            return
        }
        
        let newMessage = self.getCopyModel(messageModel: messageModel)
        newMessage.type = EMMessageBodyType(rawValue: messageModel.msgType) ?? .text
        switch newMessage.type {
        case .text:
            
            self.sendTextMessage(messageModel: newMessage, sender: sender)
            break
        case .gifMessage:
            
            self.sendEmojiMessage(messageModel: newMessage, sender: sender)
            break
        case .image:
            
            self.sendImageMessage(messageModel: messageModel, sender: sender)
            break
            
        case .audio:
            
            self.sendAudioMessage(messageModel: newMessage, sender: sender)
            break
            
        case .video:
            
            self.sendVideoMessage(messageModel: messageModel, sender: sender)
            break
            
        case .voiceCall,.videoCall:
            
            self.sendVideoCallMessage(messageModel: newMessage, sender: sender)
            break
            
        case .location:
            
            self.sendLocationMessage(messageModel: newMessage, sender: sender)
            break
        case .businessCard:
            
            self.sendBusinessCardMessage(messageModel: newMessage, sender: sender)
            break
        case .file:
            self.sendMessage(by: newMessage)
            break
            
        case .multipleImage:
            self.sendMessage(by: newMessage)
            break
        default:
            
            break
        }
    }
}

private extension CODMessageSendTool{
    //文本
    func sendTextMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        XMPPManager.shareXMPPManager.sendTextMessageTo(toJID: messageModel.toJID, sender: sender, msgType: String(format: "%ld", messageModel.msgType), messageID: messageModel.msgID,rp: messageModel.rp,fw: messageModel.fw,fwn: messageModel.fwn, messageStr: messageModel.text, chatType: messageModel.chatTypeEnum, roomId:String(format: "%ld", messageModel.roomId),referTo: messageModel.referTo, burn: messageModel.burn, fwf: messageModel.fwf, n: messageModel.n, itemID: messageModel.itemID, smsgID: messageModel.smsgID,entities: messageModel.entities)
    }
    
    //表情
    func sendEmojiMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        XMPPManager.shareXMPPManager.sendEmojiMessageTo(toJID: messageModel.toJID, sender: sender, msgType: String(format: "%ld", messageModel.msgType), messageID: messageModel.msgID,rp: messageModel.rp,fw: messageModel.fw,fwn: messageModel.fwn, messageStr: messageModel.text, chatType: messageModel.chatTypeEnum, roomId:String(format: "%ld", messageModel.roomId),referTo: messageModel.referTo, burn: messageModel.burn, fwf: messageModel.fwf, n: messageModel.n, itemID: messageModel.itemID, smsgID: messageModel.smsgID)
    }
    
    //图片
    func  sendImageMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        
        guard let messageModel = CODMessageRealmTool.getMessageByMsgId(messageModel.msgID) else {
            return
        }
        
        func sendXMPPMessage() {
            
            var pictrueString: String = messageModel.photoModel?.serverImageId ?? ""
            if pictrueString.contains("http") {
                let picArray:Array = CustomUtil.getPictureID(fileIDs: [pictrueString])
                if picArray.count > 0 {
                    pictrueString = picArray[0]
                }
            }
            let messageID = messageModel.msgID
            let msgType = String(format: "%ld", messageModel.msgType)
            let mD5Url = messageModel.photoModel?.serverImageId ?? ""
            let fileName = mD5Url + ((messageModel.photoModel?.isGIF ?? false) ? ".gif":".png")
            XMPPManager.shareXMPPManager.sendPhotoMessageTo(toJID: messageModel.toJID, msgType: msgType, messageID: messageID,rp: messageModel.rp,fw: messageModel.fw,fwn: messageModel.fwn, pictrueString: pictrueString, filename: fileName, chatType: messageModel.chatTypeEnum, ishdimg: messageModel.photoModel?.ishdimg ?? false, w: Int(messageModel.photoModel?.w ?? 0), h: Int(messageModel.photoModel?.h ?? 0), size: messageModel.photoModel?.size ?? 0, description: messageModel.photoModel?.descriptionImage ?? "",roomId: String(format: "%ld", messageModel.roomId), referTo: messageModel.referTo, burn: messageModel.burn, fwf: messageModel.fwf, n: messageModel.n, itemID: messageModel.itemID, smsgID: messageModel.smsgID, entities:messageModel.entities)
            
        }
        
        
        guard let photoModel = messageModel.photoModel else {
            return
        }
        
        if photoModel.serverImageId.count > 0 {
            sendXMPPMessage()
        } else {
            
            UploadTool.upload(chatType: messageModel.chatTypeEnum, receiver: messageModel.toJID, fileType: .image(imageInfo: photoModel.toImageInfo()))
                .subscribe(onNext: { (result) in
                    
                    
                    
                    switch result {
                        
                    case.success(file: _):
                        sendXMPPMessage()
                        
                    case .fail:
                        messageModel.update(status: .Failed)
                        
                    default:
                        break
                        
                    }
                    
                })
                .disposed(by: rx.disposeBag)
            
        }
        
        
        
        
        
    }
    
    //语音
    func sendAudioMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        if messageModel.audioModel?.audioURL.removeAllSapce.count ?? 0 > 0{
            let messageID = messageModel.msgID
            let msgType = String(format: "%ld", messageModel.msgType)
            let voiceIDs = CustomUtil.getPictureID(fileIDs: [messageModel.audioModel?.audioURL ?? ""])
            XMPPManager.shareXMPPManager.sendVoiceMessageTo(toJID: messageModel.toJID, msgType: msgType, messageID: messageID,rp: messageModel.rp,fw: messageModel.fw,fwn: messageModel.fwn, duration:Int((messageModel.audioModel?.audioDuration) ?? 0), voiceString: voiceIDs[0], chatType: messageModel.chatTypeEnum, roomId: String(format: "%ld", messageModel.roomId), referTo: messageModel.referTo, burn: messageModel.burn, fwf: messageModel.fwf, n: messageModel.n,description:messageModel.audioModel?.descriptionAudio ?? "",size:messageModel.audioModel?.size ?? 0, itemID: messageModel.itemID, smsgID: messageModel.smsgID)
        }else{
            CODUploadTool.default.voiceMessageUpload(model: messageModel)
        }
        
    }
    
    //发送视频
    func sendVideoMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        
        
        guard let videoModel = messageModel.videoModel else {
            return
        }
        
        func _sendVideoMessage() {
            
            guard let serverVideoId = messageModel.videoModel?.serverVideoId, serverVideoId.count > 0 else {
                return
            }
            
            let messageID = messageModel.msgID
            let msgType = String(format: "%ld", messageModel.msgType)
            let videoString: String =   serverVideoId
            let pictrueString: String =  messageModel.videoModel?.firstpicId ?? ""
            
            XMPPManager.shareXMPPManager.sendVideoMessageTo(toJID: messageModel.toJID, msgType: msgType, messageID: messageID,rp: messageModel.rp,fw: messageModel.fw,fwn: messageModel.fwn, duration: Int(roundf(Float((messageModel.videoModel?.videoDuration) ?? 0))), videoString: videoString, firstpicString: pictrueString, chatType: messageModel.chatTypeEnum, roomId: String(format: "%ld", messageModel.roomId), referTo: messageModel.referTo, burn: messageModel.burn, fwf: messageModel.fwf, n: messageModel.n, w: Int(messageModel.videoModel?.w ?? 0), h: Int(messageModel.videoModel?.h ?? 0),description: messageModel.videoModel?.descriptionVideo ?? "",size: messageModel.videoModel?.size ?? 0, itemID: messageModel.itemID, smsgID: messageModel.smsgID)
            
        }
        
        func _uploadVideo() {
            
            UploadTool.upload(chatType: messageModel.chatTypeEnum, receiver: messageModel.toJID, fileType: .video(videoInfo: videoModel.toVideoInfo()))
                .subscribe(onNext: { (result) in
                    
                    if result.isSuccess {
                        _sendVideoMessage()
                    }
                    switch result {
                    case .fail:
                        messageModel.update(status: .Failed)
                    default:
                        break
                    }
                    
                    
                })
                .disposed(by: self.rx.disposeBag)
            
        }
        
        if let serverVideoId = messageModel.videoModel?.serverVideoId, serverVideoId.count > 0 {
            
            _sendVideoMessage()
            
            
        } else {
            
            
            if let videoModel = messageModel.videoModel {
                
                let savePath = CODFileManager.shareInstanceManger().mp4PathWithName(fileName: videoModel.videoId)
                
                
                if FileManager.default.fileExists(atPath: savePath) {
                    
                    _uploadVideo()
                    
                } else {
                    /// 如果视频文件存在 iCloud 上，在断网的情况下，会下载不了，这时本地就没有对应的视频文件
                    CustomUtil.compressVideoWithPHAsset(messageModel: messageModel) { (_) in
                        
                        _uploadVideo()
                        
                    }
                }
                
            }
            
            
            
            
        }
        
    }
    
    //发送语音视频
    func sendVideoCallMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        
        let messageID = messageModel.msgID
        let msgType = String(format: "%ld", messageModel.msgType)
        XMPPManager.shareXMPPManager.sendVideoCallMessageTo(toJID: messageModel.toJID, msgType: msgType, messageID: messageID, rp: messageModel.rp,fw: messageModel.fw,fwn: messageModel.fwn,duration: messageModel.videoCallModel?.duration ?? 0, videoType: messageModel.videoCallModel?.videoString ?? "request", room:messageModel.videoCallModel?.room ?? "1234", chatType: messageModel.chatTypeEnum, roomId: String(format: "%ld", messageModel.roomId), referTo: messageModel.referTo, burn: messageModel.burn, fwf: messageModel.fwf, n: messageModel.n)
        
    }
    
    //发送位置
    func sendLocationMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        
        if messageModel.location?.locationImageString.removeAllSapce.count ?? 0 > 0 {
            var pictrueString: String = messageModel.location?.locationImageString ?? ""
            if pictrueString.contains("http") {
                let picArray:Array = CustomUtil.getPictureID(fileIDs: [pictrueString])
                if picArray.count > 0 {
                    pictrueString = picArray[0]
                }
            }
            let messageID = messageModel.msgID
            let msgType = String(format: "%ld", messageModel.msgType)
            let lngString = String(format: "%f", messageModel.location?.longitude ?? 0)
            let latString = String(format: "%f", messageModel.location?.latitude ?? 0)
            XMPPManager.shareXMPPManager.sendLocationMessageTo(toJID: messageModel.toJID, msgType: msgType, messageID: messageID,rp: messageModel.rp,fw: messageModel.fw,fwn: messageModel.fwn, lngString: lngString, latString: latString, titleString: messageModel.location?.name ?? " ", subtitleString: messageModel.location?.address ?? " ", pictrueString: pictrueString, chatType: messageModel.chatTypeEnum, roomId: String(format: "%ld", messageModel.roomId), referTo: messageModel.referTo, burn: messageModel.burn, fwf: messageModel.fwf, n: messageModel.n, itemID: messageModel.itemID, smsgID: messageModel.smsgID)
        }else{
            CODUploadTool.default.pictureUpload(model: messageModel)
        }
    }
    
    //发送名片
    func sendBusinessCardMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        
        var pictrueString: String = messageModel.businessCardModel?.userpic ?? ""
        if pictrueString.contains("http") {
            if let picArray = CustomUtil.getPictureID(fileIDs: [pictrueString]) as? Array<String>,picArray.count > 0 {
                pictrueString = picArray[0]
            }
        }
        let messageID = messageModel.msgID
        let msgType = String(format: "%ld", messageModel.msgType)
        XMPPManager.shareXMPPManager.sendCards(toJID: messageModel.toJID, msgType: msgType, messageID: messageID,rp: messageModel.rp,fw: messageModel.fw,fwn: messageModel.fwn, username: messageModel.businessCardModel?.username ?? "", name: messageModel.businessCardModel?.name ?? "", userdesc: messageModel.businessCardModel?.userdesc ?? "", userpic: pictrueString, jidString: messageModel.businessCardModel?.jid ?? "", gender: messageModel.businessCardModel?.gender ?? "", chatType: messageModel.chatTypeEnum, roomId: String(format: "%ld", messageModel.roomId), referTo: messageModel.referTo, burn: messageModel.burn, fwf: messageModel.fwf, n: messageModel.n, itemID: messageModel.itemID, smsgID: messageModel.smsgID)
    }
    
    //发送文件
    func sendFileMessage(messageModel: CODMessageModel, sender: String = UserManager.sharedInstance.jid) {
        
        var fileString: String = messageModel.fileModel?.filename ?? ""
        if fileString.contains("http") {
            if let picArray = CustomUtil.getPictureID(fileIDs: [fileString]) as? Array<String>,picArray.count > 0 {
                fileString = picArray[0]
            }
        }
        if messageModel.fileModel?.fileID.removeAllSapce.count ?? 0 > 0 {
            let messageID = messageModel.msgID
            let msgType = String(format: "%ld", messageModel.msgType)
            XMPPManager.shareXMPPManager.sendFile(toJID: messageModel.toJID, msgType: msgType, messageID: messageID,rp: messageModel.rp,fw: messageModel.fw,fwn: messageModel.fwn, fileID: messageModel.text, filename: fileString, size: messageModel.fileModel?.size ?? 0, description: messageModel.fileModel?.descriptionFile ?? "", thumb: messageModel.fileModel?.thumb ?? "",chatType: messageModel.chatTypeEnum, roomId: String(format: "%ld", messageModel.roomId), referTo: messageModel.referTo, burn: messageModel.burn, fwf: messageModel.fwf, n: messageModel.n, itemID: messageModel.itemID, smsgID: messageModel.smsgID)
        }else{
            if messageModel.editMessage != nil {
                self.sendEditMessage(messageModel: messageModel)
            }else{
                CODUploadTool.default.fileUpload(model: messageModel)
            }
        }
    }
}

extension CODMessageSendTool{
    
    //已读消息回执
    func sendHaveReadMessage(messageModel: CODMessageModel) {
        //        print("发送消息了、、、、、、、、、、、")
        var toJID = messageModel.fromJID
        if messageModel.isGroupChat{
            toJID = messageModel.toWho
        }
        //        let sendTime = String(format: "%.0f", Date.milliseconds)
        
        var count = 0
        let results = try! Realm.init().objects(CODChatListModel.self).filter("((contact.mute = false || groupChat.mute = false || channelChat.mute = false) && isInValid = false) || id = -999")
        
        for chatModel in results {
            count = count + chatModel.count
        }
        
        var dict:NSDictionary? = [:]
        dict = ["name": COD_readedTime,"requester":UserManager.sharedInstance.jid,"target":toJID,"readedtime":messageModel.datetime,"chatType":messageModel.chatType.int ?? 1, "badge":count]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_readed, actionDic: dict!)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
}


extension CODMessageSendTool{
    
    func postAddMessageToView(messageID: String,isNeedAddToDB: Bool = false) {
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kUpdataMessageView), object: nil, userInfo: ["id":messageID,"isNeedAddToDB":isNeedAddToDB])
    }
    
    func sendEditMessage(messageModel: CODMessageModel) {
        
        let copyModel = self.getCopyModel(messageModel: messageModel)
        self.editMsg(editText: copyModel.editMessage?.text ?? "", msgID: messageModel.msgID, referTo: [], messageModel: copyModel)
    }
    
    func editMsg(editText: String, attributeStr : NSAttributedString? = nil, msgID: String, referTo:Array<String>,messageModel: CODMessageModel) {
        
        var editedmsgString = "editedmsg"
        if messageModel.toJID.contains(kCloudJid) {
            editedmsgString = "clouddiskeditedmsg"
        }
        
        let msgType = String(format: "%ld", messageModel.msgType)
        var  dict = ["name":editedmsgString,
                     "msgType": Int(msgType) ?? 1,
                     "requester":UserManager.sharedInstance.jid,
                     "body":(editText.removeAllSapce.count > 0) ? AES128.aes128EncryptECB(editText) : "",
                     "msgID":msgID,
                     "entities":attributeStr?.getAttributesWithArray() as Any,
                     "referTo":referTo
            ] as [String : Any]
        let message = messageModel.editMessage ?? messageModel
        
        switch message.type {
        case .image:
            let mD5Url = message.photoModel?.serverImageId ?? ""
            let fileName = mD5Url + ((message.photoModel?.isGIF ?? false) ? ".gif":".png")
            let setting = ["ishdimg":((message.photoModel?.ishdimg ?? false) ? true : false),
                           "description":(editText.removeAllSapce.count > 0) ? AES128.aes128EncryptECB(editText) : "",
                           "w":Int(message.photoModel?.w ?? 0),
                           "h":Int(message.photoModel?.h ?? 0),
                           "filename":fileName,
                           "size":message.photoModel?.size ?? 0] as [String : Any]
            dict["setting"] = setting
            dict["body"] = mD5Url
            
        case .video:
            let setting = ["firstpic":message.videoModel?.firstpicId ?? "",
                           "duration":Int(roundf(Float((message.videoModel?.videoDuration) ?? 0))),
                           "description":(editText.removeAllSapce.count > 0) ? AES128.aes128EncryptECB(editText) : "",
                           "w":Int(message.videoModel?.w ?? 0),
                           "h":Int(message.videoModel?.h ?? 0),
                           "size":message.videoModel?.size ?? 0] as [String : Any]
            dict["setting"] = setting
            dict["body"] = message.videoModel?.serverVideoId ?? ""
            
        case .multipleImage:
            let setting = [
                "description": AES128.aes128EncryptECB(editText)
            ]
            
            dict["setting"] = setting
            
        case .file:
            let setting = ["thumb":message.fileModel?.thumb ?? "",
                           "filename":message.fileModel?.filename ?? "",
                           "description":(editText.removeAllSapce.count > 0) ? AES128.aes128EncryptECB(editText) : "",
                           "size":message.fileModel?.size ?? 0,] as [String : Any]
            dict["setting"] = setting
            dict["body"] = message.fileModel?.fileID
            
        case .audio:
            let setting = ["duration":Int(roundf(Float((message.audioModel?.audioDuration) ?? 0))),
                           "description":(editText.removeAllSapce.count > 0) ? AES128.aes128EncryptECB(editText) : "",
                           "size":message.audioModel?.size ?? 0,] as [String : Any]
            dict["setting"] = setting
            
//            if message.audioModel?.audioLocalURL.removeAllSapce.count ?? 0 > 0 {
//
//                dict["body"] = ((message.audioModel?.audioLocalURL.components(separatedBy: "/").last)?.components(separatedBy: ".").first)!
//            }else{
                dict["body"] = message.audioModel?.audioURL
//            }
            
            
        default:
            break
        }
        
        self.sendEditMessageIQ(dict: dict as NSDictionary)
        
    }
    
    func sendEditMessageIQ(dict: NSDictionary) {
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_message_V2, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
}

extension CODMessageSendTool{
    //先看条件是不是可以发送消息
    func judgeIsSendMessage(messageModel: CODMessageModel) -> String? {
        
        if messageModel.isGroupChat {//群组
            return CustomUtil.judgeInGroupRoom(roomId: messageModel.roomId)
        }else{//单聊
            
            if let contectModel = CODContactRealmTool.getContactByJID(by: messageModel.toJID){
                if contectModel.blacklist {
                    return CustomUtil.judgeInMyBlackListByJID(jid: messageModel.toJID)
                }
            }else{
                return CustomUtil.judgeInMyFriendByJID(jid: messageModel.toJID)
            }
        }
        return ""
    }
}
