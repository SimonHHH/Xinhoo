//
//  CODChatMessageDisplayView+Menu.swift
//  COD
//
//  Created by 1 on 2019/5/31.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension CODChatMessageDisplayView{
    //    func dismissMenu() {
    //        GMenuController.shared().setMenuVisible(false, animated: true)
    //    }
    func menuSave() {
        
        
        guard let messageModel = messageModel else {
            return
        }
        
        let messageModelRef = ThreadSafeReference(to: messageModel)
        
        DispatchQueue(label: "saveToCanmeraRoll").async {
            
            autoreleasepool {
                
                let realm = try! Realm()
                guard let messageModel = realm.resolve(messageModelRef) else {
                    CODProgressHUD.dismiss()
                    return
                }
                
                
                if messageModel.type == .image {
                    
                    CODProgressHUD.showWithStatus("正在保存")
                    
                    if let photo = messageModel.photoModel {
                        
                        if photo.photoLocalURL.isEmpty != true {
                            
                            if let data = CODImageCache.default.originalImageCache?.diskImageData(forKey: photo.photoLocalURL) {
                                self.saveToCanmeraRoll(imageData: data)
                                CODProgressHUD.showSuccessWithStatus(NSLocalizedString("保存成功", comment: ""))
                            } else {
                                self.saveToCanmeraRollSemaphore.signal()
                                CODProgressHUD.showSuccessWithStatus(NSLocalizedString("保存失败", comment: ""))
                            }
                            
                            
                            
                        } else {
                            
                            SDWebImageManager.shared.loadImage(with: URL(string: photo.serverImageId.getImageFullPath(imageType: 2, isCloudDisk: self.isCloudDisk)), options:[], context: nil, progress: nil) { (image, data, error, _, _, _) in
                                
                                if let data = image?.pngData() {
                                    self.saveToCanmeraRoll(imageData: data)
                                    CODProgressHUD.showSuccessWithStatus(NSLocalizedString("保存成功", comment: ""))
                                } else {
                                    self.saveToCanmeraRollSemaphore.signal()
                                    CODProgressHUD.showSuccessWithStatus(NSLocalizedString("保存失败", comment: ""))
                                }
                                
                            }
                            
                        }
                        
                    }
                    

                } else if messageModel.type == .multipleImage {
                    
                    if messageModel.imageList.count <= 0  {
                        return
                    }
                    
                    CODProgressHUD.showWithStatus("正在保存")
                    
                    for photo in messageModel.imageList {
                        
                        self.saveToCanmeraRollSemaphore.wait()
                        
                        if photo.photoLocalURL.isEmpty != true {
                            
                            if let data = CODImageCache.default.originalImageCache?.diskImageData(forKey: photo.photoLocalURL) {
                                self.saveToCanmeraRoll(imageData: data)
                            } else {
                                self.saveToCanmeraRollSemaphore.signal()
                            }
                            
                            
                        } else {
                            
                            
                            
                            SDWebImageManager.shared.loadImage(with: URL(string: photo.serverImageId.getImageFullPath(imageType: 2, isCloudDisk: self.isCloudDisk)), options: [], context: nil, progress: nil) { (image, data, error, _, _, _) in
                                
                                if let data = data {
                                    self.saveToCanmeraRoll(imageData: data)
                                } else {
                                    self.saveToCanmeraRollSemaphore.signal()
                                }
                                
                            }
                            
                        }
                    }
                    
                    DispatchQueue.main.async {
                        CODProgressHUD.showSuccessWithStatus(NSLocalizedString("保存成功", comment: ""))
                    }
                    
                    
                    
                    
                }
                
                
            }
            
            
        }
        
        
        
        
    }
    
    func saveToCanmeraRoll(imageData: Data) {
        
        if let photoImage = UIImage.init(data: imageData) {
            //保存相册
            UIImageWriteToSavedPhotosAlbum(photoImage, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        
//        if error != nil {
//
//            CODProgressHUD.showErrorWithStatus(NSLocalizedString("保存失败", comment: ""))
//        } else {
//
//            CODProgressHUD.showSuccessWithStatus(NSLocalizedString("保存成功", comment: ""))
//        }
        
        self.saveToCanmeraRollSemaphore.signal()
    }
    
    @objc func cancalSend(message: CODMessageModel) {
        self.messageDisplayViewVM.cancelEditMessage(message: message)
    }
    
    @objc func menuCopy() {
        //        self.dismissMenu()
        let pastboard = UIPasteboard.general
        pastboard.yy_AttributedString = self.messageModel?.attrText
    }
    
    @objc func menuCollection() {
        //        self.dismissMenu()
        
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: (self.messageModel?.msgType)!) ?? .text
        if modelType == .text {
            
            var favFrom = ""
            if (self.messageModel?.fromWho.contains(XMPPDomainTemp))! {
                favFrom = self.messageModel!.fromWho
            }else{
                favFrom = self.messageModel!.fromWho + XMPPSuffix
            }
            
            let messages = [["burn":self.messageModel?.burn as Any,
                             "msgType":self.messageModel?.msgType as Any,
                             "receiver":UserManager.sharedInstance.jid,
                             "sender":favFrom,
                             "body":self.messageModel?.text as Any,
                             "chatType":self.messageModel!.isGroupChat ? "2":"1",
                             "sendTime":""] as [String:Any]]
            
            
            let  dict:NSDictionary = ["name":COD_createFavorite,
                                      "requester":UserManager.sharedInstance.jid,
                                      "favType":"1",
                                      "favFrom":favFrom,
                                      "createDate":String(format: "%.0f", Date.milliseconds),
                                      "messages":messages]
            
            
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_favorite, actionDic: dict)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
            
        }else{
            
        }
        
    }
    
    @objc func replyMessage(){
        //        self.dismissMenu()
        if self.delegate != nil {
            let copyMessage: CODMessageModel = CODMessageSendTool.default.getCopyModel(messageModel: self.cellVM?.messageModel ?? CODMessageModel())
            copyMessage.msgID = self.cellVM?.messageModel.msgID ?? "0"
            copyMessage.nick = self.cellVM?.messageModel.nick ?? ""
            self.delegate?.replyMessage(message: copyMessage)
        }
    }
    
    @objc func more(){
        //        self.dismissMenu()
        if self.delegate != nil {
            //            self.messageModel?.isSelect = true
            self.delegate?.more()
            self.cellVM?.isSelect = true
            self.messageDisplayViewVM.isMultipleSelelct.accept(true)
        }
    }
    
    @objc func collectionMessage() {
        //        self.dismissMenu()
        if self.delegate != nil {
            //            self.messageModel?.isSelect = true
            self.delegate?.collectionMessage(message:self.messageModel ?? CODMessageModel())
        }
    }
    
    //转发消息
    @objc func retransionMessage() {
        //        self.dismissMenu()
        if self.delegate != nil {
            
            self.delegate?.transMessage(message: self.messageModel ?? CODMessageModel())
        }
    }
    
    /// 举报 - 其他
    func other(reportType: BalloonActionViewController.ReportType) {
        
        if self.delegate != nil {
            self.delegate?.reportOther(message: self.messageModel ?? CODMessageModel(),reportType: reportType)
        }
    }
    
    @objc func cancalSend() {
        
    }
    
    @objc func menuDelete() {
        if self.delegate != nil {
            self.delegate?.chatMessageDisplayViewDidTouched(chatTVC: self)
        }
        CustomUtil.removeMessage(messageModel: self.cellVM?.messageModel ?? CODMessageModel(), chatType: self.chatType, chatId: self.chatId, superView: nil) { (index) in
            self.cellVM = nil
        }
    }

    func insertChatHistory(message :CODMessageModel, group: CODGroupChatModel) {
        
        if let chatListModel = CODChatListRealmTool.getChatList(id: group.roomID){
            try! Realm.init().write {
                chatListModel.chatHistory?.messages.append(message)
                chatListModel.lastDateTime = message.datetime
                chatListModel.isShowBurned = false
            }
            //通知去聊天列表中更新数据
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        }else{
            //新增消息到数据库
            let chatHistoryModel = CODChatHistoryModel()
            chatHistoryModel.id = group.roomID
            chatHistoryModel.messages.append(message)
            
            let chatListModel = CODChatListModel()
            if let group = CODGroupChatRealmTool.getGroupChat(id: group.roomID) {
                chatListModel.id = group.roomID
                chatListModel.icon = group.grouppic
                chatListModel.chatTypeEnum = .groupChat
                chatListModel.lastDateTime = message.datetime
                chatListModel.groupChat = group
                chatListModel.jid = group.jid
                chatListModel.chatHistory = chatHistoryModel
                chatListModel.title = group.getGroupName()
                chatListModel.stickyTop = group.stickytop
            }
            CODChatListRealmTool.insertChatList(by: chatListModel)
        }
    }
    //编辑信息
    @objc func editNewMessage() {
        //        self.dismissMenu()
        if self.delegate != nil {
            self.delegate?.editMessage(message: self.messageModel ?? CODMessageModel())
        }
    }
    
    func topMessage() {
        //        self.dismissMenu()
        if self.delegate != nil {
            self.delegate?.topMessage(message: self.messageModel ?? CODMessageModel())
            
        }
    }
    
}
