    //
    //  CODMessageModelTool.swift
    //  COD
    //
    //  Created by 1 on 2019/4/24.
    //  Copyright © 2019 XinHoo. All rights reserved.
    //

    import UIKit
    import XMPPFramework
    import SwiftyJSON

    extension CODMessageModel {
        

        func getFirstImageURL() -> String? {
            
            switch self.type {
            case .image:
                return self.photoModel?.serverImageId
            case .multipleImage:
                return self.imageList.first?.serverImageId
            case .location:
                return self.location?.locationImageString
            case .video:
                return self.videoModel?.firstpicId
            default:
                return nil
            }
            
        }
        
        func getFirstImageCacheKey() -> String? {
            
            switch self.type {
            case .image:
                return self.photoModel?.photoLocalURL
            case .multipleImage:
                return self.imageList.first?.photoLocalURL
            case .location:
                return self.location?.locationImageId
            case .video:
                return self.videoModel?.videoId
            default:
                return nil
            }
            
        }
        
        func toXMPPMessage() -> XMPPMessage {
            
            let message = XMPPMessage(messageType: XMPPMessage.MessageType(rawValue: self.chatTypeEnum.chatTypeStr),
                                      to: XMPPJID(string: self.toJID),
                                      elementID: self.msgID)
            
            message.addBody(self.toJSON()?.jsonString() ?? "")
            
            return message
            
        }
        
        func toJSON() -> [String : Any]? {
            
            var json: [String: Any] =  [:]
            
            json["sender"] = self.fromJID
            json["n"] = self.n
            json["receiver"] = self.toJID
            json["chatType"] = self.chatTypeEnum.intValue
            json["msgType"] = self.type.rawValue
            json["burn"] = self.burn
            json["sendTime"]  = self.datetimeInt
            
            json["fwf"] = self.fwf
            json["fwn"] = self.fwn
            json["fw"] = self.fw
            json["rp"] = self.rp
            json["edited"] = self.edited
            json["l"] = self.l
            
            if let itemID = self.itemID, let smsgID = self.smsgID {
                json["itemID"] = itemID
                json["smsgID"] = smsgID
            }
            
           
            
            if self.roomId > 0 {
                json["roomID"] = self.roomId
            }
            
            
            if entities.count > 0 {
                json["entities"] = entities.toArrayJSON()
            }
            
            if entities.hasLink() {
                json["l"] = 1
            }
            
            switch self.type {
            case .multipleImage:
                if self.imageList.count > 0 {
                    
                    let photos =  self.imageList.toArray().map { $0.toJSON() ?? [:] }
                    json["mphoto"] = [
                        "layouttype": photos.count,
                        "photos": photos
                    ]
                    
                }
                
                if self.text.count > 0 {
                   json["setting"] = [
                       "description": AES128.aes128EncryptECB(self.text)
                   ]
                }
                
            case .file:
                if let fileModel = fileModel {
                    
                    json["setting"] = fileModel.toJSON()
                    json["body"] = fileModel.fileID
                    
                }
                
                
            default:
                break
            }
            
            
            return json
        }
        
        func resizeImageList() {
            
            if self.type != .multipleImage {
                return
            }
            
            
            let unUploadList = self.imageList.filter("uploadState != \(UploadStateType.Finished.intValue)")
            
            if self.imageList.filter("uploadState == \(UploadStateType.Finished.intValue)").count == 0 {
                return
            }
            
            if unUploadList.count <= 0 {
                return
            }
            
            try? realm?.safeWrite {
                realm?.delete(unUploadList)
            }


        }
        

        
        func update(burn: Int? = nil, n: String? = nil, text: String? = nil, edited: Int? = nil, imageList: [PhotoModelInfo]? = nil, status: CODMessageStatus? = nil, sender: String? = nil) {
            
            try! realm?.safeWrite {
                
                if let burn = burn {
                    self.burn = burn
                }
                
                if let n = n {
                    self.n = n
                }
                
                if let text = text {
                    self.text = text
                }
                
                if let edited = edited {
                    self.edited = edited
                }
                
                if let imageList = imageList, imageList.count > 0 {
                    self.imageList.removeAll()
                    self.imageList.append(objectsIn: imageList)
                    
                }
                
                if let status = status {
                    self.statusType = status
                }
                
                if let sender = sender {
                    self.fromJID = sender
                    self.fromWho = sender.subStringTo(string: "@")
                }
                

            }
            
        }
        
        func deleteImageFormImageList(photoId: String) {
            
            for image in self.imageList {
                
                if image.photoId == photoId {
                    
                    try! realm?.safeWrite {
                        realm?.delete(image)
                    }
                    
                    return
                }
                
            }
            
        }
        
        func toImageModel(photoId: String? = nil) {
            
            if self.type != .multipleImage {
                return
            }
            
            let realm = self.realm ?? (try? Realm())
            
            try? realm?.safeWrite {
                
                self.type = .image
                
                if let photoId = photoId, let photoModel = PhotoModelInfo.getPhotoInfo(photoId: photoId) {
                    self.photoModel = photoModel
                    self.imageList = List<PhotoModelInfo>()
                } else {
                    self.photoModel = self.imageList.first
                    self.imageList = List<PhotoModelInfo>()
                }
                

            }
            
        }
        
        func getNickNameColor() -> UIColor? {

            return CustomUtil.getMessageModelTextColor(messageModel: self)

        }
        
        func getMessageSenderNickName() -> String {

            return CustomUtil.getMessageModelNickName(messageModel: self)
            
        }
        

        
        func editMessage(model: CODMessageModel?, status: CODMessageStatus) {
            
            if self.type != .image && self.type != .video {
                return
            }
            
            try! realm?.safeWrite {
                
                switch status {
                case .Succeed:
                    if let editMessage = self.editMessage {
                        
                        if editMessage.photoModel != nil{
                            self.photoModel = editMessage.photoModel
                        }
                        if editMessage.videoModel != nil{
                            self.videoModel = editMessage.videoModel
                        }
                        self.entities = editMessage.entities
                        realm?.delete(editMessage)
                        self.editMessage = nil
                        self.statusType = .Succeed
                    }
                    
                case .Failed:
                    self.statusType = .Failed

                case .Pending:
                    self.editMessage = model
                    self.statusType = .Pending
                    
                case .Cancal:
                    if let editMessage = self.editMessage {
                        realm?.delete(editMessage)
                        self.editMessage = nil
                    }
                    self.edited -= 1
                    self.statusType = .Succeed

                default:
                    break
                }
                
                
                
            }
        }
        
    }

    class CODMessageModelTool: NSObject {
        
        
        static var `default`: CODMessageModelTool  = CODMessageModelTool()
        
        func createBaseModel(msgID: String, toJID :String, chatType: CODMessageChatType, roomId: String?,chatId: Int,burn: Int, sendTime: String? = nil) -> CODMessageModel {
            let model = CODMessageModel.init()
            model.toJID = toJID
            model.toWho = toJID
            model.fromWho = UserManager.sharedInstance.jid
            model.fromJID = UserManager.sharedInstance.jid
            model.msgID = msgID
            model.status =  CODMessageStatus.Pending.rawValue
            model.chatTypeEnum = chatType
            let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
            model.datetime = (sendTime != nil) ? sendTime! : timestr
            model.datetimeInt = (sendTime != nil) ? sendTime!.int! : Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
            model.burn = burn
            
            if model.chatTypeEnum == .channel {
                if let channelModel = CODChannelModel.getChannel(by: roomId?.int ?? 0) {
                    if channelModel.signmsg {
                        model.n = UserManager.sharedInstance.nickname ?? ""
                    }
                }else{
                    model.n = ""
                }
            }else{
                model.n = ""
            }
            
            switch model.chatTypeEnum {
            case .groupChat, .channel:
                model.roomId = roomId!.int!
                if let messageHistoryModelTemp = CODChatHistoryRealmTool.getChatHistory(from: (roomId?.int)!){
                    if let lastMsg = messageHistoryModelTemp.messages.sorted(byKeyPath: "datetime", ascending: true).last {
                        
                        model.isShowDate = !CustomUtil.isSameDay(starTime: lastMsg.datetime as NSString, endTime: model.datetime as NSString)
                    }else{
                        model.isShowDate = true
                    }
                    
                }else{
                    model.isShowDate = true
                }
                
            case .privateChat:
                if let messageHistoryModelTemp = CODChatHistoryRealmTool.getChatHistory(from: chatId){
                    if let lastMsg = messageHistoryModelTemp.messages.sorted(byKeyPath: "datetime", ascending: true).last {
                        //                    model.isShowDate = (CustomUtil.getTimeDiff(starTime: lastMsg.datetime as NSString, endTime: model.datetime as NSString) > 300)
                        model.isShowDate = !CustomUtil.isSameDay(starTime: lastMsg.datetime as NSString, endTime: model.datetime as NSString)
                    }else{
                        model.isShowDate = true
                    }
                }else{
                    model.isShowDate = true
                }
            }
            
            
            // 如果从数据库取到指定联系人的聊天记录，就把它遍历放到chatHistoryModel.messages中
            //        if let messageHistoryModelTemp = CODChatHistoryRealmTool.getChatHistory(from: contact.rosterID) {
            //            let messageHistoryList = messageHistoryModelTemp.messages
            //            for message in messageHistoryList{
            //                chatHistoryModel.messages.append(message)
            //            }
            //
            //            let lastMsg = messageHistoryModelTemp.messages.filter("isShowDate = true").sorted(byKeyPath: "datetime", ascending: true).last
            //            message.isShowDate = (CustomUtil.getTimeDiff(starTime: lastMsg!.datetime as NSString, endTime: message.datetime as NSString) > 300)
            //
            //        }else{
            //            message.isShowDate = true
            //        }
            
            return model
        }
        
        //文本model
        func createTextModel(msgID:String, toJID :String, textString: String?,attributeStr : NSAttributedString? = nil, chatType: CODMessageChatType, roomId: String?,chatId: Int,burn: Int, sendTime: String? = nil) -> CODMessageModel {
            let model = self.createBaseModel(msgID: msgID, toJID: toJID, chatType: chatType, roomId: roomId, chatId: chatId, burn: burn,sendTime: sendTime)
            model.type = .text
            //        model.attrText = String.messageTextTranscode(text:textString)
            model.text = textString ?? ""
            model.l = 0
            
            let list = List<CODAttributeTextModel>()
            if let arr = attributeStr?.getAttributesWithArray() {
                for dic in arr{
                    if let attributeModel = CODAttributeTextModel.deserialize(from: dic) {
                        list.append(attributeModel)
                        if attributeModel.typeEnum == .text_link{
                            model.l = 1
                        }
                    }
                }
            }
            
            model.entities = list
            return model
        }
        
        //位置model
        func createLocationModel(msgID:String, toJID :String ,longitude :CGFloat,latitude :CGFloat,titleString :String,subtitleString :String,pictrueImage :UIImage, chatType: CODMessageChatType, roomId: String?,chatId: Int,burn: Int) -> CODMessageModel {
            
            let model = self.createBaseModel(msgID: msgID, toJID: toJID, chatType: chatType, roomId: roomId, chatId: chatId,burn: burn)
            model.type = .location
            model.location = LocationInfo()
            //        let longStr = String(format: "%f", currenPOI.pt.longitude)
            //        let latitudeStr = String(format: "%f", currenPOI.pt.latitude)
            model.location?.longitude = Double(longitude)
            model.location?.latitude = Double(latitude)
            model.location?.name = titleString
            model.location?.address = subtitleString
            model.location?.locationImageId = msgID.md5()
            
            CODImageCache.default.originalImageCache?.store(pictrueImage, forKey: model.location?.locationImageId, completion: nil)

            return model
        }
        
        //图片
        func createPhotoModel(msgID:String, toJID :String,photoImage: UIImage, photoImageData: Data,chatType: CODMessageChatType, ishdimg: Bool,roomId: String?,chatId: Int,burn: Int,description: String = "", size: Int = 0) -> CODMessageModel {
            let model = self.createBaseModel(msgID: msgID, toJID: toJID, chatType: chatType, roomId: roomId,chatId: chatId,burn: burn)
            model.type = .image
            model.photoModel = PhotoModelInfo()
            
    //        if ishdimg == false {
    //             model.photoModel?.photoImageData = photoImageData
    //        }
            
            model.photoModel?.h = photoImageData.imageSize.height.float
            model.photoModel?.w = photoImageData.imageSize.width.float
            model.photoModel?.descriptionImage = description
            model.photoModel?.ishdimg = ishdimg
            model.photoModel?.size = size
            return model
        }
        
        //录音
        func createAudioModel(msgID:String, toJID :String,duration: CGFloat,audioData: NSData,audioLocalURl: String,chatType: CODMessageChatType, roomId: String?,chatId: Int,burn: Int,description: String = "", size: Int = 0) -> CODMessageModel {
            
            let model = self.createBaseModel(msgID: msgID, toJID: toJID, chatType: chatType, roomId: roomId, chatId: chatId,burn: burn)
            model.type = .audio
            model.audioModel = AudioModelInfo()
            model.audioModel?.audioDuration = duration.float
            model.audioModel?.audioLocalURL = audioLocalURl
            model.audioModel?.descriptionAudio = description
            model.audioModel?.size = size
            return model
            
        }
        
        //短视频
        func createVideoModel(msgID:String, toJID :String,duration: CGFloat,firstpicImage: UIImage, chatType: CODMessageChatType, roomId: String?,chatId: Int,burn: Int,description: String = "",size :Int = 0) -> CODMessageModel {
            
            let model = self.createBaseModel(msgID: msgID, toJID: toJID, chatType: chatType, roomId: roomId, chatId: chatId,burn: burn)
            model.type = .video
            model.videoModel = VideoModelInfo()
            model.videoModel?.videoDuration = duration.float
            model.videoModel?.h = firstpicImage.size.height.float
            model.videoModel?.w = firstpicImage.size.width.float
            model.videoModel?.videoDuration = duration.float
            model.videoModel?.descriptionVideo = description
            model.videoModel?.size = size
            return model
            
        }
        //发送名片
        func createBusinessCardModel(msgID:String, toJID :String, username: String,name: String,userdesc: String,userpic: String,jid : String,gender: String, chatType: CODMessageChatType, roomId: String?,chatId: Int,burn: Int) -> CODMessageModel {
            let model = self.createBaseModel(msgID: msgID, toJID: toJID, chatType: chatType, roomId: roomId, chatId: chatId,burn: burn)
            model.type = .businessCard
            model.businessCardModel = BusinessCardModelInfo()
            model.businessCardModel?.username = username
            model.businessCardModel?.name = name
            model.businessCardModel?.userdesc = userdesc
            model.businessCardModel?.userpic = userpic
            model.businessCardModel?.jid = jid
            model.businessCardModel?.gender = gender
            
            return model
        }
        
        //发送语音聊天
        
        func createVideoCallModel(msgID:String, toJID :String,duration:Int = 0, chatType: CODMessageChatType, roomId: String?,chatId: Int,type:String,burn: Int) -> CODMessageModel {
            
            let model = self.createBaseModel(msgID: msgID, toJID: toJID, chatType: chatType, roomId: roomId, chatId: chatId,burn: burn)
            model.type = .voiceCall
            model.videoCallModel = VideoCallModelInfo()
            model.videoCallModel?.videoString = type
            model.videoCallModel?.duration = duration
            model.videoCallModel?.room = String.randomSmallCaseString(length: 32)
            return model
            
        }
        
        func createFileModel(msgID:String = UserManager.sharedInstance.getMessageId(),
                             fileURL: URL?,
                             fileName: String?,
                             toJID :String,
                             duration:Int = 0,
                             chatType: CODMessageChatType,
                             roomId: String?,
                             chatId: Int,
                             burn: Int) -> CODMessageModel  {
            
            let model = self.createBaseModel(msgID: msgID, toJID: toJID, chatType: chatType, roomId: roomId, chatId: chatId,burn: burn)
            model.type = .file
            
            let fileModel = FileModelInfo()
            
            if let fileUrl = fileURL {
                fileModel.filename = fileUrl.lastPathComponent
            }else{
                fileModel.filename = fileName ?? ""
            }
            

            model.fileModel = fileModel
            
            return model
            
        }
        
        //发送已读回执
        func createHaveReadModel(msgID:String,lastMessageTime: String,toJID :String,chatType: CODMessageChatType, roomId: String?,chatId: Int,burn: Int) -> CODMessageModel {
            
            let model = self.createBaseModel(msgID: msgID, toJID: toJID, chatType: chatType, roomId: roomId, chatId: chatId,burn: burn)
            model.type = .haveRead
            model.datetime = lastMessageTime
            return model
            
        }
        
        //以下为新消息
        func createNewMessageCountMessage() -> CODMessageModel {
            let model = CODMessageModel.init()
            model.type = .newMessage
            return model
        }
        
        func createMessageModel(messageValue: MessageValue) -> CODMessageModel {
            
            return messageValue.createMessageModel()
            
        }
        
        
        
        
    }
