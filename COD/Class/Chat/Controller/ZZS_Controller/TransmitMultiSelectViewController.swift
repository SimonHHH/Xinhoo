//
//  TransmitMultiSelectViewController.swift
//  COD
//
//  Created by zzs on 2020/2/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import LGAlertView

class TransmitMultiSelectViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var tipLab: UILabel!
    
    var chatListArr :Array<CODChatListModel> = Array()
    
    var stringsToSort = Array<String>()
    var indexArray: Array = [String]()
    var contactListArr :Array = [CODContactModel]()
    var contactSortResultArr: Array = [Array<CODContactModel>]()
    
    var selectArr: Array = [String]()
    
    var messages = Array<CODMessageModel>()
    
    typealias DismissBlock = () -> ()
    var dismissBlock:DismissBlock?
    
    var remark:NSAttributedString?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any addition al setup after loading the view.
        
        self.sendBtn.setTitle(NSLocalizedString("发送", comment: ""), for: .normal)
        self.cancelBtn.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
        self.tipLab.text = NSLocalizedString("请选择联系人", comment: "")
        
        chatTableView.register(UINib(nibName: "ChatListCell", bundle: nil), forCellReuseIdentifier: "cell")
        contactTableView.register(CODChoosePersonCell.self, forCellReuseIdentifier: "CODChoosePersonCellID")
        
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "collectionCell")
        
        contactTableView.isEditing = true
        contactTableView.allowsMultipleSelectionDuringEditing = true
        
        chatTableView.isEditing = true
        chatTableView.allowsMultipleSelectionDuringEditing = true
                
        initChatData()
        initContactData()
    }

    func initChatData() {
        var chatSTList = Array<CODChatListModel>()
        if CODChatListRealmTool.getStickyTopList().count > 0 {
            for model in CODChatListRealmTool.getStickyTopList(filterNewFriend: false) {
                if let model = self.filterUnvalidChat(chatListModel: model) {
                    chatSTList.append(model)
                }
            }
        }
        chatListArr.append(contentsOf: chatSTList)
        
        var chatNSTList = Array<CODChatListModel>()
        if CODChatListRealmTool.getNoneStickyTopList(filterNewFriend: false).count > 0 {
            for model in CODChatListRealmTool.getNoneStickyTopList() {
                if let model = self.filterUnvalidChat(chatListModel: model) {
                    chatNSTList.append(model)
                }
            }
        }
        chatListArr.append(contentsOf: chatNSTList)
        chatTableView.reloadData()
    }
    
    func filterUnvalidChat(chatListModel: CODChatListModel) -> CODChatListModel? {
        if let _ = chatListModel.contact {
            return chatListModel
        }
        if let groupChat = chatListModel.groupChat {
            if groupChat.isValid {
                return chatListModel
            }else{
                return nil
            }
        }
        if let _ = chatListModel.channelChat {
            return chatListModel
        }
        return nil
    }
    
    func initContactData() {
        
        let contacts = CODContactRealmTool.getContactsNotBlackList()
        if let contactList = contacts , contactList.count > 0 {
            
            for contact in contactList {

                self.stringsToSort.append(contact.getContactNick())
                self.contactListArr.append(contact)
            }
        }
        
        if let indexStringS = ChineseString.indexArray(self.stringsToSort) as? [String]   {
            for string in indexStringS {
                self.indexArray.append(string)
            }
        }
        
        if let contactResults = ChineseString.modelSortArray(self.contactListArr) as? [Array<CODContactModel>] {
            self.contactSortResultArr = contactResults
        }
        contactTableView.reloadData()
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        self.scrollView.setContentOffset(CGPoint(x: KScreenWidth * CGFloat(sender.selectedSegmentIndex), y: 0), animated: false)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    /// 发送方法
    /// - Parameter sender: button
    @IBAction func sendAction(_ sender: Any) {
        
        let sendView = TransmitMultiSelectView.initWitXib(selectArr: selectArr,messages:messages)
        sendView.remarkChangeBlock = { (attribute) in
            self.remark = attribute
        }
        
        let alertView = LGAlertView(viewAndTitle: nil,
                                    message: nil,
                                    style: .alert,
                                    view: sendView,
                                    buttonTitles: [NSLocalizedString("发送", comment: "") + "(\(selectArr.count))"],
                                    cancelButtonTitle: NSLocalizedString("取消", comment: ""),
                                    destructiveButtonTitle: nil,
                                    actionHandler: { [weak self] (alert, index, title) in
                                        
                                        guard let `self` = self else {
                                            return
                                        }
                                        
                                        alert.dismiss(animated: true) {
                                        
                                            self.sendTransMessage()
                                        }
                                        
        },
                                    cancelHandler: nil,
                                    destructiveHandler: nil)
        
        
        alertView.width = KScreenWidth - 56
        alertView.isCancelOnTouch = false
        alertView.show(animated: true, completionHandler: nil)
    }
    
    func selectArrCountChange() {
        titleLab.text = NSLocalizedString("转发", comment: "") + " \(selectArr.count)"
        sendBtn.isEnabled = (selectArr.count != 0)
        tipLab.isHidden = sendBtn.isEnabled
    }
    
    deinit {
        print("多选转发控制器销毁了")
    }
}

extension TransmitMultiSelectViewController : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == contactTableView {
            return self.contactSortResultArr.count
        }else{
            return 1
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if tableView == contactTableView {
            return self.indexArray
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == contactTableView {
            return self.contactSortResultArr[section].count
        }else{
            return chatListArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == contactTableView {
            return getContactsCell(indexPath: indexPath)
        }else{
            return getChatCell(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == contactTableView {
            return 48
        }else{
            return 76
        }
    }
    
    func getChatCell(indexPath: IndexPath) -> UITableViewCell {
        let cell : ChatListCell = chatTableView.dequeueReusableCell(withIdentifier: "cell") as! ChatListCell
        let model = chatListArr[indexPath.row]
        if indexPath.row == chatListArr.count - 1 {
            cell.isLast = true
        }else{
            cell.isLast = false
        }
        cell.model = model
        if model.id <= 0 {
            if model.id == CloudDiskRosterID  {
                cell.imgView.image = UIImage(named: "cloud_disk_icon")
                cell.isReadImageView.image = UIImage.init(named: "list_blue_Haveread")
            }else if model.id == RobotRosterID{
                cell.imgView.image = UIImage.helpIcon()
                cell.isReadImageView.image = UIImage.init(named: "list_blue_Haveread")
            }else if model.id == NewFriendRosterID {
                cell.imgView.image = UIImage(named: "new_friend_icon")
                cell.isReadImageView.image = nil
            }
            
        }else{
            var imgUrl = model.icon
            
            if imgUrl == "" {
                imgUrl =  model.icon
            }
            
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: imgUrl) { (image) in
                cell.imgView.image = image
            }
        }
        cell.title = model.title
        cell.stickyTop = model.stickyTop
        return cell
    }
    
    func getContactsCell(indexPath: IndexPath) -> UITableViewCell {
        let cell: CODChoosePersonCell = contactTableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
        
         let datas = self.contactSortResultArr[indexPath.section]
         let model: CODContactModel = self.contactSortResultArr[indexPath.section][indexPath.row]
         if (model.name == "\(kApp_Name)小助手") {
             //网络图片需要处理一下
             cell.iconImage = UIImage.helpIcon()
         }else{
             if let _ = URL.init(string: model.userpic.getHeaderImageFullPath(imageType: 0)) {
                 CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.userpic) { (image) in
                     cell.imgView.image = image
                 }
             }else{
                 cell.imgView.image = UIImage(named: "default_header_80")
             }
         }
         cell.title = model.getContactNick()
         cell.titleFont = UIFont.systemFont(ofSize: 17)
         cell.imgView.contentMode = .scaleAspectFit
         
         if indexPath.row == datas.count - 1 {
             cell.isLast = true
         }else{
             cell.isLast = false
         }
         
         let result = CustomUtil.getOnlineTimeStringAndStrColor(with: model)
         cell.placeholer = result.timeStr
         cell.placeholerColor = result.strColor
         
         return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == contactTableView {
            let textString = self.indexArray[section]
            let textFont = UIFont.systemFont(ofSize: 12)
            let sectionHeight: CGFloat = 28
            let textLabel = UILabel.init(frame: CGRect(x: 14, y: 0, width: KScreenWidth-28, height: sectionHeight))
            textLabel.textAlignment = NSTextAlignment.left
            textLabel.font = textFont
            textLabel.numberOfLines = 0
            textLabel.textColor = UIColor(hexString: kSectionHeaderTextColorS)
            textLabel.text = textString
            
            let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
            bgView.backgroundColor = UIColor.init(hexString: kVCBgColorS)
            bgView.addSubview(textLabel)
            return bgView
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == contactTableView {
            return 28.0
        }else{
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var jid:String = ""
        
        if tableView == chatTableView {
            let chatModel = chatListArr[indexPath.row]
            
            ///如果是频道的话，需要做权限判断，是否允许在该频道发消息
            if chatModel.chatTypeEnum == .channel {
                
                let channelResult = CustomUtil.judgeInChannelRoom(roomId: chatModel.id)
                if !channelResult.isManager {
                    CODProgressHUD.showErrorWithStatus(NSLocalizedString("抱歉,您不能在此频道发布消息", comment: ""))
                    tableView.deselectRow(at: indexPath, animated: true)
                    return
                }
            }
            
            ///如果是群聊的话，也需要判断是否允许发言
            if chatModel.chatTypeEnum == .groupChat {
                if !CustomUtil.judgeInGroupRoomCanSpeak(roomId: chatModel.id) {
                    CODProgressHUD.showErrorWithStatus(NSLocalizedString("抱歉，您不能在此会话发布消息", comment: ""))
                    tableView.deselectRow(at: indexPath, animated: true)
                    return
                }
            }
            
            jid = chatModel.jid
            if let model = chatModel.contact {
                
                for section in 0...(self.contactSortResultArr.count - 1) {
                    for row in 0...(self.contactSortResultArr[section].count - 1) {
                        let resultModel: CODContactModel = self.contactSortResultArr[section][row]
                        if model.jid == resultModel.jid {
                            contactTableView.selectRow(at: IndexPath(row: row, section: section), animated: false, scrollPosition: .none)
                        }
                    }
                }
            }
        }
        
        if tableView == contactTableView {
            let model: CODContactModel = self.contactSortResultArr[indexPath.section][indexPath.row]
            jid = model.jid
            for row in 0...(chatListArr.count - 1) {
                let chatModel = chatListArr[row]
                if chatModel.jid == model.jid {
                    chatTableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
                }
            }
        }
        
        selectArr.append(jid)
        self.selectArrCountChange()
        
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(row: selectArr.count - 1, section: 0), at: .right, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        var jid:String = ""
        
        if tableView == chatTableView {
            let chatModel = chatListArr[indexPath.row]
            jid = chatModel.jid
            if let model = chatModel.contact {
                
                for section in 0...(self.contactSortResultArr.count - 1) {
                    for row in 0...(self.contactSortResultArr[section].count - 1) {
                        let resultModel: CODContactModel = self.contactSortResultArr[section][row]
                        if model.jid == resultModel.jid {
                            contactTableView.deselectRow(at: IndexPath(row: row, section: section), animated: false)
                        }
                    }
                }
            }
        }
        
        if tableView == contactTableView {
            let model: CODContactModel = self.contactSortResultArr[indexPath.section][indexPath.row]
            jid = model.jid
            for row in 0...(chatListArr.count - 1) {
                let chatModel = chatListArr[row]
                if chatModel.jid == model.jid {
                    chatTableView.deselectRow(at: IndexPath(row: row, section: 0), animated: false)
                }
            }
        }
        
        if let index = selectArr.firstIndex(of: jid) {
        
            selectArr.remove(at: index)
            self.selectArrCountChange()
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(row: selectArr.count - 1, section: 0), at: .right, animated: true)
        }
        
    }
    
}

extension TransmitMultiSelectViewController : UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        cell.contentView.removeSubviews()
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 49, height: 49)
        imageView.contentMode = .scaleToFill
        imageView.cornerRadius = 24.5
        cell.contentView.addSubview(imageView)
        
        let jid = selectArr[indexPath.item]
        
        
        /// 优先查询历史会话，如果查询不到则去查询联系人表
        if let chatModel = CODChatListRealmTool.getChatList(jid: jid) {
            if chatModel.id <= 0 {
                if chatModel.id == CloudDiskRosterID  {
                    imageView.image = UIImage(named: "cloud_disk_icon")
                }else{
                    imageView.image = UIImage.helpIcon()
                }
                
            }else{
                var imgUrl = chatModel.icon
                
                if imgUrl == "" {
                    imgUrl =  chatModel.icon
                }
                
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: imgUrl) { (image) in
                    imageView.image = image
                }
            }
        }else if let contactModel = CODContactRealmTool.getContactByJID(by: jid) {
            if (contactModel.name == "\(kApp_Name)小助手") {
                //网络图片需要处理一下
                imageView.image = UIImage.helpIcon()
            }else{
                if let _ = URL.init(string: contactModel.userpic.getHeaderImageFullPath(imageType: 0)) {
                    CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: contactModel.userpic) { (image) in
                        imageView.image = image
                    }
                }else{
                    imageView.image = UIImage(named: "default_header_80")
                }
            }
        }
        
        return cell
        
    }
    
    
}
extension TransmitMultiSelectViewController {
    
    func sendTransMessage() {
                
        var copyMessages = [CODMessageModel]()
        for copyMessage in self.messages {
            let messageModel = self.getTransCopyModel(model: copyMessage)
            if messageModel.type == .audio {
                messageModel.audioModel?.audioLocalURL = ""
            }
            copyMessages.append(messageModel)
        }
        copyMessages = copyMessages.sorted(by: \.datetimeInt, ascending: true)
        
        var id = 0
        
        for jidString in self.selectArr {
            
            if let contactModel = CODContactRealmTool.getContactByJID(by: jidString) {
                id = contactModel.rosterID
                self.sendMessageByPerson(copyMessages:copyMessages, contactModel: contactModel)
            }else if let groupModel = CODGroupChatRealmTool.getGroupChatByJID(by: jidString) {
                id = groupModel.roomID
                self.sendMessageByGroup(copyMessages: copyMessages, groupModel: groupModel)
            }else if let channelModel = CODChannelModel.getChannel(jid: jidString) {
                id = channelModel.roomID
                self.sendMessageByChannel(copyMessages: copyMessages, channelModel: channelModel)
            }
            
            if let chatListModel = CODChatListRealmTool.getChatList(id: id) {
                try! Realm().safeWrite {
                    chatListModel.count = 0
                    chatListModel.referToMessageID.removeAll()
                }
            }
            
        }
        
        self.dismiss(animated: false) {
            if self.dismissBlock != nil {
                self.dismissBlock!()
            }
        }
    }
    
    func sendMessageByPerson(copyMessages:[CODMessageModel],contactModel: CODContactModel) {
        
        for messageModel in copyMessages {
            self.choosePersonTransMessage(contactModel: contactModel, getCopyModel: CODMessageSendTool.default.getCopyModel(messageModel: messageModel))
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            if self.remark?.string.removeAllSapce.count ?? 0 > 0 {
                let messageModel = CODMessageModel()
                messageModel.msgType = 1
                messageModel.text = self.remark?.string ?? ""
                
                let list = List<CODAttributeTextModel>()
                if let arr = self.remark?.getAttributesWithArray() {
                    for dic in arr{
                        if let model = CODAttributeTextModel.deserialize(from: dic) {
                            list.append(model)
                        }
                    }
                }
                
                messageModel.entities = list
                
                messageModel.fromJID = UserManager.sharedInstance.jid
                messageModel.fromWho = UserManager.sharedInstance.jid
                self.choosePersonTransMessage(contactModel: contactModel, getCopyModel: messageModel)
            }
        }
    }
    
    func sendMessageByGroup(copyMessages:[CODMessageModel],groupModel: CODGroupChatModel) {
        
        for messageModel in copyMessages {
            self.chooseGroupTransMessage(groupModel: groupModel, getCopyModel: CODMessageSendTool.default.getCopyModel(messageModel: messageModel))
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            if self.remark?.string.removeAllSapce.count ?? 0 > 0 {
                let messageModel = CODMessageModel()
                messageModel.msgType = 1
                messageModel.text = self.remark?.string ?? ""
                
                let list = List<CODAttributeTextModel>()
                if let arr = self.remark?.getAttributesWithArray() {
                    for dic in arr{
                        if let model = CODAttributeTextModel.deserialize(from: dic) {
                            list.append(model)
                        }
                    }
                }
                
                messageModel.entities = list
                
                messageModel.fromJID = UserManager.sharedInstance.jid
                messageModel.fromWho = UserManager.sharedInstance.jid
                self.chooseGroupTransMessage(groupModel: groupModel, getCopyModel: messageModel)
            }
        }
        
    }
    
    func sendMessageByChannel(copyMessages:[CODMessageModel],channelModel: CODChannelModel) {
        
        for messageModel in copyMessages {
            self.chooseChannelTransMessage(channelModel: channelModel, getCopyModel: CODMessageSendTool.default.getCopyModel(messageModel: messageModel))
         }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
        
            if self.remark?.string.removeAllSapce.count ?? 0 > 0 {
                let messageModel = CODMessageModel()
                messageModel.msgType = 1
                messageModel.text = self.remark?.string ?? ""
                
                if let attributeTextModelList = self.remark?.toAttributeTextModelList() {
                    let list = List<CODAttributeTextModel>()
                    list.append(objectsIn: attributeTextModelList)
                    messageModel.entities = list
                }

                messageModel.fromJID = UserManager.sharedInstance.jid
                messageModel.fromWho = UserManager.sharedInstance.jid
                self.chooseChannelTransMessage(channelModel: channelModel, getCopyModel: messageModel)
            }
        }
    }
    
    func choosePersonTransMessage(contactModel: CODContactModel,getCopyModel: CODMessageModel) {
        
        var msgIDTemp = ""
        
        if (contactModel.jid.contains(kCloudJid)){
            msgIDTemp = UserManager.sharedInstance.getCloudDiskMessageId()
        }else{
            msgIDTemp = UserManager.sharedInstance.getMessageId()
        }
        getCopyModel.msgID = msgIDTemp
        
        getCopyModel.toJID = contactModel.jid
        getCopyModel.toWho = contactModel.jid
        getCopyModel.burn = contactModel.burn
        getCopyModel.chatTypeEnum = .privateChat
        let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
        getCopyModel.datetime = timestr
        getCopyModel.datetimeInt = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
        self.insertChatHistory(message: getCopyModel, contact: contactModel)
        
        self.sendTransMessage(transMessage: getCopyModel)
    }
    
    func chooseGroupTransMessage(groupModel: CODGroupChatModel,getCopyModel: CODMessageModel) {
        
        getCopyModel.msgID = UserManager.sharedInstance.getMessageId()
        getCopyModel.toJID = groupModel.jid
        getCopyModel.toWho = groupModel.jid
        getCopyModel.roomId = groupModel.roomID
        getCopyModel.chatTypeEnum = .groupChat
        getCopyModel.burn = groupModel.burn.int ?? 0
        let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
        getCopyModel.datetime = timestr
        getCopyModel.datetimeInt = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
        self.insertChatHistory(message :getCopyModel, group: groupModel)
        self.sendTransMessage(transMessage: getCopyModel)

    }
   
    func chooseChannelTransMessage(channelModel: CODChannelModel,getCopyModel: CODMessageModel) {
        
        getCopyModel.msgID = UserManager.sharedInstance.getMessageId()
        getCopyModel.toJID = channelModel.jid
        getCopyModel.toWho = channelModel.jid
        getCopyModel.roomId = channelModel.roomID
        getCopyModel.chatTypeEnum = .channel
        getCopyModel.burn = channelModel.burn.int ?? 0
        let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
        getCopyModel.datetime = timestr
        getCopyModel.datetimeInt = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
        XMPPManager.shareXMPPManager.insertChatContactHistory(messages: [getCopyModel], chatObject: channelModel, unreadCount: 0)
        self.sendTransMessage(transMessage: getCopyModel)

    }
    
    func sendTransMessage(transMessage: CODMessageModel) {
        
        CODMessageSendTool.default.sendMessage(messageModel: transMessage)
        CODMessageSendTool.default.postAddMessageToView(messageID: transMessage.msgID)
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

    
    func getTransCopyModel(model: CODMessageModel) -> CODMessageModel {
        
        let getCopyModel = CODMessageSendTool.default.getCopyModel(messageModel: model)
        let msgIDTemp = UserManager.sharedInstance.getMessageId()
        getCopyModel.msgID = msgIDTemp
        getCopyModel.status =  CODMessageStatus.Pending.rawValue
        getCopyModel.fromJID = UserManager.sharedInstance.jid
        getCopyModel.fromWho = UserManager.sharedInstance.jid
        getCopyModel.chatTypeEnum = .privateChat
        getCopyModel.isReaded = false
        getCopyModel.edited = 0
        getCopyModel.rp = ""
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
        let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
        getCopyModel.datetime = timestr
        getCopyModel.datetimeInt = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
        return getCopyModel
    }
}

