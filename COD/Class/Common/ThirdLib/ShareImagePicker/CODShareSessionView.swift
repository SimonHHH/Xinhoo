//
//  CODShareSessionView.swift
//  COD
//
//  Created by 1 on 2019/8/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import SnapKit
fileprivate let AVER_IMAGE_WIDTH:CGFloat = 60
private let CODShareSessionCollectionViewCell_identity = "CODShareSessionCollectionViewCell"
class CODShareSessionView: UIView {
    weak var delegate:CODShareSessionViewDelegate?
    var contactListArr :Array = [AnyObject]()
    var messageModel :CODMessageModel?
    var msgUrl:String = ""
    var shareText: String = ""
    var contactModel :CODContactModel?
    var groupModel :CODGroupChatModel?
    var channelModel :CODChannelModel?
    var chatListModel :CODChatListModel?
    var fromType: CODShareImagePickerFromType = .Chat

    fileprivate var lastPosition:CGFloat = 0
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: AVER_IMAGE_WIDTH, height: AVER_IMAGE_WIDTH + 40)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        
        return collectionView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
//        self.collectionView.register(CODShareSessionCollectionViewCell.self, forCellWithReuseIdentifier: CODShareSessionCollectionViewCell_identity)
        self.collectionView.register(UINib.init(nibName: "CODShareSession_ZZS_CollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CODShareSession_ZZS_CollectionViewCell")
        
        self.addSubViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func addSubViews() {
        self.addSubview(self.collectionView);
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview();
        }
    }
}

extension CODShareSessionView:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.contactListArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CODShareSessionCollectionViewCell_identity, for: indexPath) as! CODShareSessionCollectionViewCell
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CODShareSession_ZZS_CollectionViewCell", for: indexPath) as! CODShareSession_ZZS_CollectionViewCell
        if let model :CODContactModel = self.contactListArr[indexPath.row] as? CODContactModel {
            cell.title = model.getContactNick()
            if model.rosterID <= 0 {
                if model.rosterID == CloudDiskRosterID  {
                    cell.averImageView.image = UIImage(named: "cloud_disk_icon")
                }else if model.rosterID == RobotRosterID{
                    cell.averImageView.image = UIImage.helpIcon()
                }
            }else{
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.userpic) { (image) in
                    cell.averImageView.image = image
                }
            }

        }

        if let model :CODGroupChatModel = self.contactListArr[indexPath.row] as? CODGroupChatModel {
            cell.title = model.getGroupName()
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.grouppic) { (image) in
                cell.averImageView.image = image
            }
        }
        
        if let model :CODChannelModel = self.contactListArr[indexPath.row] as? CODChannelModel {
            cell.title = model.getGroupName()
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.grouppic) { (image) in
                cell.averImageView.image = image
            }
        }

        if let model :CODChatListModel = self.contactListArr[indexPath.row] as? CODChatListModel {

            cell.title = model.title
            if model.id <= 0 {
                if model.id == CloudDiskRosterID  {
                    cell.averImageView.image = UIImage(named: "cloud_disk_icon")
                }else if model.id == RobotRosterID{
                    cell.averImageView.image = UIImage.helpIcon()
                }
            }else{
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.icon) { (image) in
                    cell.averImageView.image = image
                }
            }

        }

        UIGraphicsBeginImageContextWithOptions(cell.averImageView.bounds.size, false, 0)
        
        UIBezierPath.init(roundedRect: cell.averImageView.bounds, cornerRadius: 30).addClip()
        cell.averImageView.draw(cell.averImageView.bounds)
        cell.averImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        //结束画图
        UIGraphicsEndImageContext()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let contactModel1 :CODContactModel = self.contactListArr[indexPath.row] as? CODContactModel {
             self.contactModel = contactModel1
        }
        if let groupModel1 :CODGroupChatModel = self.contactListArr[indexPath.row] as? CODGroupChatModel {
            self.groupModel = groupModel1
        }
        if let channelModel1 :CODChannelModel = self.contactListArr[indexPath.row] as? CODChannelModel {
            self.channelModel = channelModel1
        }
        if let chatListModel1 :CODChatListModel = self.contactListArr[indexPath.row] as? CODChatListModel {
            self.chatListModel = chatListModel1
        }
        
        if self.messageModel != nil {
            self.shareImage(indexPath: indexPath)
        }else{
            self.shareTextString()
        }
    }
    
    func shareImage(indexPath: IndexPath) {
        //判断服务器是不是存在这个文件
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: (self.messageModel?.msgType)!) ?? .text
        
        if modelType == .text || modelType == .businessCard {
            self.choosePersonTransMessage(isNet: true, isLocal: false,fileIDs: [])
            return
        }
        if modelType == .location {
            
            let locationIDs: Array<String> = CustomUtil.getPictureID(fileIDs: [self.messageModel?.location?.locationImageString ?? ""])
            if locationIDs.count > 0 {
                self.choosePersonTransMessage(isNet: false, isLocal: true, picString: "", videoString: "", fileString: "",locationString: locationIDs[0],fileIDs:locationIDs)
                return
            }
        }

        var fileIDs: Array<String> = CustomUtil.getMessageFileIDS(messages: [self.messageModel ?? CODMessageModel()])
        if modelType == .multipleImage{
            let fileModel = self.getTransCopyModel(model: self.messageModel ?? CODMessageModel(), isGroupChat: false)

            if self.fromType == .Moments || self.fromType == .HomeMoments{
                fileIDs = CustomUtil.getMessageFileIDS(messages: [fileModel])
            }else{
                fileIDs = CustomUtil.getMessageFileIDS(messages: [fileModel])
            }
        }

        //服务器不存在的话在进入判断本地是不是存在这个文件
//        if fileIDs.count > 0 {
//            self.judgeServerIsExist(fileIDs: CustomUtil.getPictureID(fileIDs: fileIDs))
//        }else{
//            self.choosePersonTransMessage(isNet: true, isLocal: false,fileIDs: [])
//        }
        
        self.choosePersonTransMessage(isNet: true, isLocal: false,fileIDs: fileIDs)
    }
    
    func shareTextString() {
        self.choosePersonTransMessage(isNet: true, isLocal: false,fileIDs: [])
    }
    
    func choosePersonTransMessage(isNet: Bool,isLocal: Bool,picString: String = "",videoString: String = "",fileString: String = "",locationString: String = "",fileIDs: Array<String>) {
        
        if  let chatListModel = self.chatListModel {
            
            switch chatListModel.chatTypeEnum {
            case .groupChat:
                
                if !CustomUtil.judgeInGroupRoomCanSpeak(roomId: chatListModel.id) {
                    CODProgressHUD.showErrorWithStatus(NSLocalizedString("抱歉，您不能在此会话发布消息", comment: ""))
                }else{
                    self.chooseGroupTransMessage(groupModel: chatListModel.groupChat ?? CODGroupChatModel(), isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString, fileIDs: fileIDs)
                }
                
            case .channel:
                //TODO: 频道对应处理
                //TODO: 频道对应处理
                let channelResult = CustomUtil.judgeInChannelRoom(roomId: chatListModel.id)
                if !channelResult.isManager {
                    CODProgressHUD.showErrorWithStatus(NSLocalizedString("抱歉,您不能在此频道发布消息", comment: ""))
                    if let superView = self.superview as? CODShareImagePicker {
                        superView.dismiss()
                    }
                }else{
                    self.chooseChannelTransMessage(channelModel: chatListModel.channelChat ?? CODChannelModel(), isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString, fileIDs: fileIDs)
                }
                break
            case .privateChat:
                if let contactModel = chatListModel.contact {
                    if contactModel.rosterID == CloudDiskRosterID {

                        
                        self.transmitMessageToCloudDisk(contactModel: contactModel, isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString, fileIDs: fileIDs)
                        
                        //转发至云盘
                        
                    }else{
                        self.choosePersonTransMessage(contactModel: contactModel, isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString, fileIDs: fileIDs)
                    }
                }
            }

        }
        
        if self.contactModel != nil {
            self.choosePersonTransMessage(contactModel: contactModel ?? CODContactModel(), isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString, fileIDs: fileIDs)
        }
        
        if self.groupModel != nil {
            self.chooseGroupTransMessage(groupModel: groupModel ?? CODGroupChatModel(), isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString, fileIDs: fileIDs)
        }
        
        if self.channelModel != nil {
            self.chooseChannelTransMessage(channelModel: channelModel ?? CODChannelModel(), isNet: isNet, isLocal: isLocal, picString: picString, videoString: videoString, fileString: fileString, locationString: locationString, fileIDs: fileIDs)
        }
    }
    
    func transmitMessageToCloudDisk(contactModel: CODContactModel,isNet: Bool,isLocal: Bool,picString: String = "",videoString: String = "",fileString: String = "",locationString: String = "", fileIDs: [String]) {
        
        switch self.fromType {
        case .Chat:
            self.vaildTranfile(fileIDs: fileIDs, type: .ChatToCloudDisk)
        case .Moments,.HomeMoments:
            self.vaildTranfile(fileIDs: fileIDs, type: .MomentToCloudDisk)
        default:
            break
        }

        var getCopyModel = CODMessageModel()
        if self.messageModel != nil {
            getCopyModel = self.getTransCopyModel(model: self.messageModel ?? CODMessageModel(), isGroupChat: false)
        }else{
            var msgIDTemp = ""
            if (contactModel.jid.contains(kCloudJid)){
                msgIDTemp = UserManager.sharedInstance.getCloudDiskMessageId()
            }else{
                msgIDTemp = UserManager.sharedInstance.getMessageId()
            }
            getCopyModel = CODMessageModelTool.default.createTextModel(msgID: msgIDTemp, toJID: contactModel.jid, textString: self.shareText, chatType: .privateChat, roomId: String.init(format: "%ld", contactModel.rosterID), chatId: contactModel.chatId, burn: contactModel.burn)
        }
        getCopyModel.msgID = UserManager.sharedInstance.getCloudDiskMessageId()
        getCopyModel.toJID = contactModel.jid
        getCopyModel.toWho = contactModel.jid
        getCopyModel.burn = contactModel.burn
        getCopyModel.chatTypeEnum = .privateChat
        let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
        getCopyModel.datetime = timestr
        getCopyModel.datetimeInt = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
        
        self.insertChatHistory(message: getCopyModel, contact: contactModel)
        
        copyVideo(getCopyModel)
        
        CODChatListRealmTool.addChatListMessage(id: contactModel.chatId, message: getCopyModel)
        CODMessageSendTool.default.sendMessage(messageModel: getCopyModel, sender: getCopyModel.fromWho)
        CODMessageSendTool.default.postAddMessageToView(messageID: getCopyModel.msgID)
        self.shareSuccess()
       if let superView = self.superview as? CODShareImagePicker {
           superView.dismiss()
       }
    }

    func choosePersonTransMessage(contactModel: CODContactModel,isNet: Bool,isLocal: Bool,picString: String = "",videoString: String = "",fileString: String = "",locationString: String = "", fileIDs: [String]) {
        
        switch fromType {
        case .Chat:
            self.vaildTranfile(fileIDs: fileIDs, type: .ChatToChat)
        case .CloudDisk:
            self.vaildTranfile(fileIDs: fileIDs, type: .CloudDiskToChat)
        case .Moments,.HomeMoments:
            self.vaildTranfile(fileIDs: fileIDs, type: .MomentToChat)
        }
        

        var getCopyModel = CODMessageModel()
        if self.messageModel != nil {
            getCopyModel = self.getTransCopyModel(model: self.messageModel ?? CODMessageModel(), isGroupChat: true)
        }else{
            var msgIDTemp = ""
            if (contactModel.jid.contains(kCloudJid)){
                msgIDTemp = UserManager.sharedInstance.getCloudDiskMessageId()
            }else{
                msgIDTemp = UserManager.sharedInstance.getMessageId()
            }
            getCopyModel = CODMessageModelTool.default.createTextModel(msgID: msgIDTemp, toJID: contactModel.jid, textString: self.shareText, chatType: .privateChat, roomId: String.init(format: "%ld", contactModel.rosterID), chatId: contactModel.chatId, burn: contactModel.burn)
        }
        getCopyModel.msgID = UserManager.sharedInstance.getCloudDiskMessageId()
        getCopyModel.toJID = contactModel.jid
        getCopyModel.toWho = contactModel.jid
        getCopyModel.burn = contactModel.burn
        getCopyModel.chatTypeEnum = .privateChat
        
        copyVideo(getCopyModel)

        let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
        getCopyModel.datetime = timestr
        getCopyModel.datetimeInt = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
        CODChatListRealmTool.addChatListMessage(id: contactModel.chatId, message: getCopyModel)
        CODMessageSendTool.default.sendMessage(messageModel: getCopyModel)
        CODMessageSendTool.default.postAddMessageToView(messageID: getCopyModel.msgID)
        self.shareSuccess()
        if let superView = self.superview as? CODShareImagePicker {
            superView.dismiss()
        }
    }
    
    fileprivate func copyVideo(_ getCopyModel: CODMessageModel) {
        
        var fromPathJid = self.messageModel?.toJID ?? ""
        if self.fromType == .Moments || self.fromType == .HomeMoments {
            fromPathJid = DiscoverHomeCache
        }
        
        CustomUtil.copyMediaFile(messageModel: getCopyModel, fromPathJid: fromPathJid, toPathJid: getCopyModel.toJID)
    }
    
    func chooseGroupTransMessage(groupModel: CODGroupChatModel,isNet: Bool,isLocal: Bool,picString: String = "",videoString: String = "",fileString: String = "",locationString: String = "", fileIDs: [String]) {
        
        switch fromType {
        case .Chat:
            self.vaildTranfile(fileIDs: fileIDs, type: .ChatToChat)
        case .CloudDisk:
            self.vaildTranfile(fileIDs: fileIDs, type: .CloudDiskToChat)
        case .Moments,.HomeMoments:
            self.vaildTranfile(fileIDs: fileIDs, type: .MomentToChat)
        }
        
        
        var getCopyModel = CODMessageModel()
        if self.messageModel != nil {
            getCopyModel = self.getTransCopyModel(model: self.messageModel ?? CODMessageModel(), isGroupChat: true)
        }else{
            var msgIDTemp = ""
            if (groupModel.jid.contains(kCloudJid)){
                msgIDTemp = UserManager.sharedInstance.getCloudDiskMessageId()
            }else{
                msgIDTemp = UserManager.sharedInstance.getMessageId()
            }
            getCopyModel = CODMessageModelTool.default.createTextModel(msgID: msgIDTemp, toJID: groupModel.jid, textString: self.shareText, chatType: .groupChat, roomId: String.init(format: "%ld", groupModel.roomID), chatId: groupModel.chatId, burn: groupModel.burn.int ?? 0)
        }
        getCopyModel.msgID = UserManager.sharedInstance.getCloudDiskMessageId()
        getCopyModel.toJID = groupModel.jid
        getCopyModel.toWho = groupModel.jid
        getCopyModel.roomId = groupModel.roomID
        getCopyModel.chatTypeEnum = .groupChat
        getCopyModel.burn = groupModel.burn.int ?? 0
        
        copyVideo(getCopyModel)
        
        CODChatListRealmTool.addChatListMessage(id: groupModel.chatId, message: getCopyModel)
        CODMessageSendTool.default.sendMessage(messageModel: getCopyModel)
        CODMessageSendTool.default.postAddMessageToView(messageID: getCopyModel.msgID)
        self.shareSuccess()
    }
    
    func chooseChannelTransMessage(channelModel: CODChannelModel,isNet: Bool,isLocal: Bool,picString: String = "",videoString: String = "",fileString: String = "",locationString: String = "", fileIDs: [String]) {
        
        switch fromType {
        case .Chat:
            self.vaildTranfile(fileIDs: fileIDs, type: .ChatToChat)
        case .CloudDisk:
            self.vaildTranfile(fileIDs: fileIDs, type: .CloudDiskToChat)
        case .Moments,.HomeMoments:
            self.vaildTranfile(fileIDs: fileIDs, type: .MomentToChat)
        }
        
        
        
        
        var getCopyModel = CODMessageModel()
        var msgIDTemp = ""
        if (channelModel.jid.contains(kCloudJid)){
            msgIDTemp = UserManager.sharedInstance.getCloudDiskMessageId()
        }else{
            msgIDTemp = UserManager.sharedInstance.getMessageId()
        }
        if self.messageModel != nil {
            getCopyModel = self.getTransCopyModel(model: self.messageModel ?? CODMessageModel(), isGroupChat: true)
        }else{

            getCopyModel = CODMessageModelTool.default.createTextModel(msgID: msgIDTemp, toJID: channelModel.jid, textString: self.shareText, chatType: .channel, roomId: String.init(format: "%ld", channelModel.roomID), chatId: channelModel.chatId, burn: channelModel.burn.int ?? 0)
        }
         getCopyModel.msgID = msgIDTemp
         getCopyModel.toJID = channelModel.jid
         getCopyModel.toWho = channelModel.jid
         getCopyModel.roomId = channelModel.roomID
         getCopyModel.chatTypeEnum = .channel
         getCopyModel.burn = channelModel.burn.int ?? 0
        
        copyVideo(getCopyModel)
        CODChatListRealmTool.addChatListMessage(id: channelModel.chatId, message: getCopyModel)
        CODMessageSendTool.default.sendMessage(messageModel: getCopyModel)
        CODMessageSendTool.default.postAddMessageToView(messageID: getCopyModel.msgID)
        self.shareSuccess()

    }
    //文件迁移
    func vaildTranfile(fileIDs: Array<String>,type: HttpTools.VaildandType) {
        
        //        验证类型 ctd(聊天转发到云盘)，默认 dtc(云盘转发到聊天)
        if fileIDs.count > 0 {
            HttpTools.vaildandTranfile(attIdList: fileIDs, type: type)
        }
        
        
    }
    

    func insertChatHistory(message :CODMessageModel, contact: CODContactModel) {
        
        if let chatListModel = CODChatListRealmTool.getChatList(id: contact.rosterID){
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
            chatHistoryModel.id = contact.rosterID
            chatHistoryModel.messages.append(message)
            
            let chatListModel = CODChatListModel()
            if let contactModel = CODContactRealmTool.getContactById(by: contact.rosterID) {
                chatListModel.id = contact.rosterID
                chatListModel.icon = contact.userpic
                chatListModel.chatTypeEnum = .privateChat
                chatListModel.lastDateTime = message.datetime
                chatListModel.contact = contact
                chatListModel.jid = contactModel.jid
                chatListModel.chatHistory = chatHistoryModel
                chatListModel.title = contactModel.getContactNick()
                chatListModel.stickyTop = contactModel.stickytop
            }
            CODChatListRealmTool.insertChatList(by: chatListModel)
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
    
    func getTransCopyModel(model: CODMessageModel,isGroupChat: Bool) -> CODMessageModel {
        
        let getCopyModel = CODMessageSendTool.default.getCopyModel(messageModel: model)
        if getCopyModel.type == .multipleImage {
            
            for photoModel in model.imageList {
                if photoModel.serverImageId.getImageFullPath(imageType: 1) == self.msgUrl.getImageFullPath(imageType: 1) || self.msgUrl.contains(photoModel.serverImageId)  {
                    let copyPhotoModel = PhotoModelInfo.deserialize(from: photoModel.toJSONString())
                    getCopyModel.photoModel = copyPhotoModel
                    getCopyModel.photoModel?.photoId = UUID().uuidString
                    getCopyModel.photoModel?.photoImageData = photoModel.photoImageData
                    getCopyModel.photoModel?.serverImageId = photoModel.serverImageId
                    getCopyModel.photoModel?.photoLocalURL = photoModel.photoLocalURL
                    getCopyModel.photoModel?.descriptionImage = photoModel.descriptionImage
                    getCopyModel.photoModel?.isGIF = photoModel.isGIF
                    getCopyModel.imageList = List<PhotoModelInfo> ()
                }
            }
     
            getCopyModel.msgType = EMMessageBodyType.image.rawValue
        }
        let msgIDTemp = UserManager.sharedInstance.getMessageId()
        getCopyModel.msgID = msgIDTemp 
        getCopyModel.status =  CODMessageStatus.Pending.rawValue
        getCopyModel.fromJID = UserManager.sharedInstance.jid
        getCopyModel.fromWho = UserManager.sharedInstance.jid
        getCopyModel.chatTypeEnum = .privateChat
        getCopyModel.isReaded = false
        getCopyModel.isDelete = false
        getCopyModel.isReadedDestroy = false
        getCopyModel.edited = 0
        getCopyModel.rp = ""
        
        if model.chatTypeEnum == .privateChat && model.isMeSend == false {
            getCopyModel.itemID = model.fromJID
        } else {
            getCopyModel.itemID = model.toJID
        }
        
        
        getCopyModel.smsgID = model.msgID
        
        if self.fromType == .Moments || self.fromType == .HomeMoments {
            
            getCopyModel.fw = ""
            getCopyModel.fwn = ""
            getCopyModel.n = ""
            getCopyModel.fwf = ""
            
        }else{
            
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
                       if channelModel.signmsg{
                           getCopyModel.n = UserManager.sharedInstance.nickname ?? ""
                       }
                       getCopyModel.fwn = channelModel.getGroupName()
                       getCopyModel.fw = channelModel.jid
                   }else{
                        getCopyModel.n = ""
                   }
               }else{
                   getCopyModel.n = UserManager.sharedInstance.nickname ?? ""
               }
            
        }

        let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
        getCopyModel.datetime = timestr
        getCopyModel.datetimeInt = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp

        return getCopyModel
    }
    
    func shareSuccess() {
        if self.fromType == .Moments || self.fromType == .HomeMoments  {
            NotificationCenter.default.post(name: NSNotification.Name.init("kSendmessage"), object: nil)
            if self.fromType == .HomeMoments {
                CODProgressHUD.showSuccessWithStatus(NSLocalizedString("已分享", comment: ""))
            }
        }else if self.messageModel != nil {
            NotificationCenter.default.post(name: NSNotification.Name.init("kTransmessage"), object: nil)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name.init("kTransmessage"), object: nil)
//            CODProgressHUD.showSuccessWithStatus(NSLocalizedString("已分享", comment: ""))
        }
    }
}
extension CODShareSessionView:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        let height = scrollView.frame.size.height
        let contentOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentOffset
        let offset = contentOffset - self.lastPosition
        
        self.lastPosition = contentOffset;
        if (offset > 0 && contentOffset > 0) {
            ///ScrollUp now
            if self.delegate != nil{
                if contentOffset + height < scrollView.contentSize.height  {
                    self.delegate?.shareSessionViewScrollStatus(shareSessionView: self, isScrollUp: true)
                }
            }
        }
        if(offset < 0 && distanceFromBottom > height){
            //ScrollDown now
            if self.delegate != nil{
                if contentOffset + height < scrollView.contentSize.height  {
                    self.delegate?.shareSessionViewScrollStatus(shareSessionView: self, isScrollUp: false)
                }
            }
        }
        ///滑动到底部
        if (distanceFromBottom < height) {
            if self.delegate != nil{
                if contentOffset + height < scrollView.contentSize.height  {
                    self.delegate?.shareSessionViewScrollBottom(shareSessionView: self, bottomHeight: height - distanceFromBottom)
                }
            }
        }
    }
    
}
class CODShareSessionCollectionViewCell:UICollectionViewCell{
    public var urlStr :String? {
        didSet {
            averImageView.sd_setImage(with: URL.init(string: urlStr ?? ""), placeholderImage: UIImage.init(named: "default_header_110"), options: [])
        }
    }
    
    public var title: String? {
        didSet {
            if let con = title {
                nameLabel.text = con
            }
            
            if title == "\(kApp_Name)小助手", let title = title {
                let attriStr = NSMutableAttributedString.init(string: CustomUtil.formatterStringWithAppName(str: "%@小助手"))
                let textAttachment = NSTextAttachment.init()
                let img = UIImage(named: "cod_helper_sign")
                textAttachment.image = img
                textAttachment.bounds = CGRect.init(x: 0, y: 0, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
                let attributedString = NSAttributedString.init(attachment: textAttachment)
                attriStr.append(attributedString)
                nameLabel.attributedText = attriStr
            }else{
                nameLabel.text = title
            }
        }
    }
    lazy var averImageView:UIImageView = {
        let averImageView = UIImageView(frame: CGRect.zero)
        averImageView.contentMode = UIView.ContentMode.scaleAspectFill
        averImageView.image = UIImage(named:"save_gpChat_icon")
        averImageView.cornerRadius = AVER_IMAGE_WIDTH/2
        return averImageView
    }()
    lazy var nameLabel:UILabel = {
        let nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.font = UIFont.systemFont(ofSize: 11)
        nameLabel.textColor = UIColor.black
        nameLabel.text  = ""
        nameLabel.textAlignment = .center
        return nameLabel
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpSubviews(){
        self.contentView.addSubview(self.averImageView)
        self.contentView.addSubview(self.nameLabel)
        
        self.averImageView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: AVER_IMAGE_WIDTH, height: AVER_IMAGE_WIDTH))
        }
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(self.averImageView.snp.bottom)
        }
    }
}

protocol CODShareSessionViewDelegate:NSObjectProtocol {
    
    /// 上滑或者下滑
    ///
    /// - Parameters:
    ///   - shareSessionView: 数据显示视图
    ///   - isScrollUp: 是否上滑 true为上滑
    func shareSessionViewScrollStatus(shareSessionView:CODShareSessionView,isScrollUp:Bool)
    
    /// 滑动到底部
    ///
    /// - Parameters:
    ///   - shareSessionView: 数据显示视图
    ///   - bottomHeight: 超出底部的距离 做动画效果
    func shareSessionViewScrollBottom(shareSessionView:CODShareSessionView,bottomHeight:CGFloat)
    
}
