//
//  XMPPManager+getMessageModel.swift
//  COD
//
//  Created by XinHoo on 2019/4/22.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework
import HandyJSON

extension XMPPManager {
    func getMessageWithXMPPMsg(message: XMPPMessage) -> CODMessageModel? {
        let messageModel = CODMessageModel()
        guard let messageBodyModel = CODMessageHJsonModel.deserialize(from: message.body?.getDictionaryFromJSONString()) else {
            print("解析Message错误")
            return nil
        }
        if let messageDic = message.body?.getDictionaryFromJSONString() as? Dictionary<String, Any> {
            
            
            if let messageIDStr = message.elementID {
                messageModel.msgID = messageIDStr
            }

            messageModel.msgType = messageBodyModel.msgType

            if let msgTypeIndex = messageDic["msgType"] as? Int {
                messageModel.type = EMMessageBodyType(rawValue: msgTypeIndex) ?? .text
            }
            
            messageModel.chatTypeEnum = messageBodyModel.chatType
            messageModel.userPic = CustomUtil.getUserPic(messageBodyModel: messageBodyModel)
            messageModel.fromWho = messageBodyModel.sender
            messageModel.fromJID = messageBodyModel.sender
            messageModel.toWho = messageBodyModel.receiver
            messageModel.toJID = messageBodyModel.receiver
            messageModel.roomId = messageBodyModel.roomID
            messageModel.edited = messageBodyModel.edited
            messageModel.rp = messageBodyModel.rp
            messageModel.reply = messageBodyModel.reply
            messageModel.fw = messageBodyModel.fw
            messageModel.fwn = messageBodyModel.fwn

            if messageModel.type == .location {
                messageModel.location = LocationInfo()
            }
            
            if let messageString = messageDic["body"] as? String {
                if messageModel.type == .location {
                    messageModel.location?.locationImageString = messageString.getImageFullPath(imageType: 0)
                }else if messageModel.type == .image {
                    if let settingDic = messageDic["setting"] as? Dictionary<String, Any> {
                        messageModel.photoModel = PhotoModelInfo.deserialize(from: settingDic)
                        if let description = settingDic["description"] as? String {
                            messageModel.photoModel?.descriptionImage = description
                        }
                        if let filename = settingDic["filename"] as? String {
                            messageModel.photoModel?.filename = filename
                            if filename.hasSuffix(".gif") || filename.hasSuffix(".GIF") {
                                messageModel.photoModel?.isGIF = true
                            }else{
                                messageModel.photoModel?.isGIF = false
                            }
                        }
                    }else{
                        messageModel.photoModel = PhotoModelInfo()
                    }

                    messageModel.photoModel?.serverImageId = messageString
                }else if messageModel.type == .notification {
//                    messageModel.attrText = String.messageTextTranscode(text:message.subject ?? "消息通知")
                    messageModel.text = message.subject ?? ""
                }else{
//                    messageModel.attrText = String.messageTextTranscode(text:messageString)
                    messageModel.text = messageString
                }
            }else{
                messageModel.text = " "
            }
            
            
            if let settingDic = messageDic["setting"] as? Dictionary<String, Any> {
                //位置
                if messageModel.type == .location {
                    if let subtitle = settingDic["subtitle"] as? String,
                        let title = settingDic["title"] as? String,
                        let lng = settingDic["lng"] as? String,
                        let lat = settingDic["lat"] as? String{
                        messageModel.location?.name = title
                        messageModel.location?.address = subtitle
                        messageModel.location?.latitude = Double(lat) ?? 0
                        messageModel.location?.longitude = Double(lng) ?? 0
                    }
                }
                //名片
                if messageModel.type == .businessCard{
                    messageModel.businessCardModel = BusinessCardModelInfo()
                    messageModel.businessCardModel?.username = settingDic["username"] as! String
                    messageModel.businessCardModel?.name = settingDic["name"] as! String
                    messageModel.businessCardModel?.userdesc = settingDic["userdesc"] as! String
                    messageModel.businessCardModel?.userpic = settingDic["userpic"] as! String
                }
                
                if messageModel.type == .file{
                    if let description = settingDic["description"] as? String {
                        messageModel.fileModel?.descriptionFile = description
                    }
                }

                //微语音
                if messageModel.type == .audio{
                    messageModel.audioModel = AudioModelInfo()
                    if let duration = settingDic["duration"] as? CGFloat {
                        messageModel.audioModel?.audioDuration = duration.float
                    }
                    if let setting = messageDic["setting"] as? Dictionary<String, Any> {
                        if let duration = setting["duration"] as? CGFloat {
                            messageModel.audioModel?.audioDuration = duration.float
                        }
                    }
                    if let audioURL = messageDic["body"] as? String {
                        messageModel.audioModel?.audioURL = audioURL
                    }
                    if let description = settingDic["description"] as? String {
                        messageModel.audioModel?.descriptionAudio = description
                    }
                }
                
                //微视频
                if messageModel.type == .video{
                    messageModel.videoModel = VideoModelInfo.deserialize(from: settingDic)
                    if let duration = settingDic["duration"] as? CGFloat {
                        messageModel.videoModel?.videoDuration = duration.float
                    }
                    if let videoURL = messageDic["body"] as? String {
                        messageModel.videoModel?.serverVideoId = videoURL
                    }
                    if let firstpic = settingDic["firstpic"] as? String {
                        messageModel.videoModel?.firstpicId = firstpic
                    }
                    if let description = settingDic["description"] as? String {
                        messageModel.videoModel?.descriptionVideo = description
                    }
                }
                
                //语音聊天
                if messageModel.type == .voiceCall || messageModel.type == .videoCall{
                    messageModel.videoCallModel = VideoCallModelInfo()
                    if let roomString = settingDic["room"] as? String {
                        messageModel.videoCallModel?.room = roomString
                    }
                    
                    if let type = messageDic["body"] as? String {
                        messageModel.videoCallModel?.videoString = type
                    }
                }
            }
            
            
            
            // 消息通知
            if messageModel.type == .notification{
                if let messageDic = message.body?.getDictionaryFromJSONString() as? Dictionary<String, Any> {
                    if let bodyString = messageDic["body"] as? String {
                        if bodyString == COD_SetInvitJoin{//收到群组邀请
                            let _  = self.isNotNeedInvitJoinFor(messageDic: messageDic)
                            
                        }else if bodyString == COD_InvitJoin {
                            if let setting = messageDic["setting"] as? Dictionary<String, Any> {
                                if let member = setting["member"] as? Array<Dictionary<String, Any>> {
                                    var memberTempStr = ""
                                    for memberTemp in member {
                                        let memberModel = CODGroupMemberModel()
                                        memberModel.jsonModel = CODGroupMemberHJsonModel.deserialize(from: memberTemp)
                                        memberModel.memberId = String(format: "%d%@", messageModel.roomId, memberModel.username)
                                        //看memberModel有没有值，看会不会重复添加
                                        CODGroupChatRealmTool.insertGroupMemberByChatId(id: messageModel.roomId, and: [memberModel])
                                        
                                        if let name = memberTemp["name"] as? String{
                                            memberTempStr.append(contentsOf: "\(name)、")
                                        }
                                    }
                                    messageModel.text = "\(memberTempStr)加入群聊"
                                }
                            }
                        }else if bodyString == COD_CanSpeak {
                            let text = self.canSpeak(messageDic: messageDic)
                             if text.count > 0 {
                                 messageModel.text = text
                             }
                        }else if bodyString == COD_KickOut {
                            if let setting = messageDic["setting"] as? Dictionary<String, Any> {
                                if let members = setting["member"] as? Array<String> {
                                    
                                    var tempStr = ""
                                    for memberJid in members {
                                        let memberId = CODGroupMemberModel.getMemberId(roomId: messageModel.roomId, userName: memberJid.subStringTo(string: "@"))
                                        if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                                            tempStr.append(contentsOf: "\(memberModel.getMemberNickName())、")
                                        }
                                    }
                                    messageModel.text = "\(tempStr)被移出群组"
                                }
                            }
                        }else if bodyString == COD_SetMucname {
                            messageModel.text = self.setMucname(messageDic: messageDic)
                        }
                        else if bodyString == COD_SetKickOut {

                            messageModel.text = "您被移出群聊"
                        }else if bodyString == COD_TransferOwner {
                            
                            if let newGroupOwnerJid = messageDic["newGroupOwner"] as? String {
                                let memberId = CODGroupMemberModel.getMemberId(roomId: messageModel.roomId, userName: newGroupOwnerJid.subStringTo(string: "@"))
                                if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
                                    messageModel.text = String(format: "“%@”已成为新管理员", memberModel.getMemberNickName())
                                }
                            }
                            
                        }
                    }
                }
                
            }
            messageModel.datetime = String(format: "%ld", messageBodyModel.sendTime)
            messageModel.datetimeInt = messageBodyModel.sendTime
            messageModel.burn = messageBodyModel.burn
        }
        
        return messageModel
    }
}

class SettingModel :HandyJSON{
    
    var msgID: Array<String> = []
    
    required init() {}
}

