//
//  CODContactDetailInfoViewController.swift
//  COD
//
//  Created by xinhooo on 2019/4/16.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODContactDetailInfoViewController: BaseViewController {
    var jid = ""
    var roomId: String = ""
    var chatId: Int = 0
    
    var contactModel:CODContactModel!
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var remarkNameLab: UILabel!
    @IBOutlet weak var nickNameLab: UILabel!
    @IBOutlet weak var userNameLab: UILabel!
    @IBOutlet weak var a_telLab: UILabel!
    @IBOutlet weak var b_talLab: UILabel!
    @IBOutlet weak var descLab: UILabel!
    @IBOutlet weak var addBlakLab: UILabel!
    
    @IBOutlet weak var nickNameCos: NSLayoutConstraint!
    @IBOutlet weak var userNameCos: NSLayoutConstraint!
    @IBOutlet weak var telCos: NSLayoutConstraint!
    @IBOutlet weak var atelCos: NSLayoutConstraint!
    @IBOutlet weak var deleteCos: NSLayoutConstraint!
    
    @IBOutlet weak var stackBottomCos: NSLayoutConstraint!
    @IBOutlet weak var stackTopCos: NSLayoutConstraint!
    
    
    @IBOutlet weak var operationBtn: UIButton!
    @IBOutlet weak var blackListTipLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isTranslucent = false

        self.setBackButton()
        self.navigationItem.title = NSLocalizedString("详细资料", comment: "")
        // Do any additional setup after loading the view.
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapMessageView(gestureRecognizer:)))
        self.headImageView.addGestureRecognizer(tap)
        self.headImageView.isUserInteractionEnabled = true
        
        self.configView()
        //获取单聊设定
        self.getData()
        
//        CustomUtil.removeHeaderImageCahch(picID: self.contactModel?.userpic ?? "")
        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: self.contactModel.userpic ) { (image) in
            self.headImageView.image = image
        }
    }

    @objc public func tapMessageView(gestureRecognizer:UITapGestureRecognizer){
//        var items:Array<KSPhotoItem> = []
//
        let url =  URL.init(string: (self.contactModel?.userpic.getHeaderImageFullPath(imageType: 2))!)
        let thumbURL =  URL.init(string: (self.contactModel?.userpic.getHeaderImageFullPath(imageType: 1))!)

        CustomUtil.removeImageCahch(imageUrl: self.contactModel.userpic.getHeaderImageFullPath(imageType: 2))
//        let photoIndex: Int = 0
        let imageData: YBIBImageData = YBIBImageData()
//        imageData.projectiveView = self.headImageView
        imageData.imageURL = url
        imageData.thumbURL = thumbURL
        let browser:YBImageBrowser =  YBImageBrowser()
        browser.dataSourceArray = [imageData]
//        browser.currentPage = photoIndex
        browser.show()
    }
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
        print("个人信息页面被销毁")
    }

    
    func getData(){
        self.contactModel = CODContactRealmTool.getContactByJID(by: jid)
        let dict:NSDictionary = ["name":COD_ChatSetting,
                                  "requester":UserManager.sharedInstance.jid,
                                  "itemID":self.contactModel.rosterID]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_setting, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func configView() {
        if let contactModel = CODContactRealmTool.getContactByJID(by: jid) {
           
            self.contactModel = contactModel
            
//            self.headImageView.sd_setImage(with: URL.init(string: (self.contactModel?.userpic.getImageFullPath(imageType: 0))!), placeholderImage: UIImage(named: "default_header_80"))
//            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: self.contactModel.userpic) { (image) in
//                self.headImageView.image = image
//            }
            if contactModel.name.count > 0 && contactModel.nick.count > 0 {
                self.nickNameCos.constant = 20
                self.remarkNameLab.attributedText = self.getAttributedString(str: contactModel.nick)
                self.nickNameLab.text = "昵称：\(contactModel.name)"
            }else{
                self.nickNameCos.constant = 0
                self.remarkNameLab.attributedText = self.getAttributedString(str: contactModel.name)
                self.nickNameLab.text = ""
            }
            
            if contactModel.username.count > 0 {
                self.userNameCos.constant = 20
                self.userNameLab.text = "用户名：\(contactModel.username)"
            }else{
                self.userNameCos.constant = 0
                self.userNameLab.text = ""
            }
            
            if contactModel.nick.count > 0 && contactModel.username.count > 0 {
                self.stackTopCos.constant = 15
                self.stackBottomCos.constant = 15
            }else if contactModel.nick.count > 0 || contactModel.username.count > 0 {
                self.stackTopCos.constant = 25
                self.stackBottomCos.constant = 25
            }else{
                self.stackTopCos.constant = 31
                self.stackBottomCos.constant = 31
            }
            
            
            switch contactModel.tels.count {
            case 0:
                self.telCos.constant = 0
                self.atelCos.constant = 0
            case 1:
                self.telCos.constant = 0
                self.atelCos.constant = 44
                self.a_telLab.text = contactModel.tels.first
            case 2:
                self.telCos.constant = 44
                self.atelCos.constant = 44
                self.a_telLab.text = contactModel.tels.first
                self.b_talLab.text = contactModel.tels.last
            default: break
            }
            
            if contactModel.blacklist {
                self.deleteCos.constant = 0
                self.addBlakLab.text = "移除黑名单"
                self.blackListTipLab.isHidden = false
            }else{
                self.deleteCos.constant = 44
                self.addBlakLab.text = "加入黑名单"
                self.blackListTipLab.isHidden = true
            }
            
            self.descLab.text = contactModel.descriptions.count > 0 ? contactModel.descriptions : " "
            
        }else{
            
        }
        
    }
    
    func getAttributedString(str:String) -> NSAttributedString {
        
        let genderImage = UIImage.init(named: (self.contactModel!.gender.compareNoCaseForString("MALE")) ? "man_icon_detailinfo" : "woman_icon_detailinfo")
        
        let attachment = NSTextAttachment.init()
        attachment.image = genderImage
        attachment.bounds = CGRect.init(x: 0, y: -2, width: 20, height: 15)
        let attributeStr = NSMutableAttributedString.init(string: str)
        attributeStr.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15)], range: NSMakeRange(0, str.count))
//        attributeStr.insert(NSAttributedString.init(attachment: attachment), at: str.count)
        attributeStr.append(NSAttributedString.init(attachment: attachment))
        
        return attributeStr
    }
    
    
    /// 页面所有button点击事件，根据tag来做区分
    /// 100-设置备注；200-描述；300-发送名片；400-语音聊天；500-加入黑名单or移除黑名单；600-删除联系人；700-底部按钮点击事件
    /// - Parameter sender: button
    @IBAction func clickAction(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            print("设置备注")
            self.pushSetContactInfoVC()
        case 200:
            print("描述")
            self.pushSetContactInfoVC()
        case 300:
            print("发送名片")
            let chooseVC = CODChoosePersonVC()
//            chooseVC.fromJID = self.contactModel.jid
            chooseVC.choosePersonBlock = { [weak self](contactModel) in
                if let fromContactModel = CODContactRealmTool.getContactByJID(by: self?.jid ?? "") {
                    self?.sendCard(toContactModel: fromContactModel, fromContactModel: self?.contactModel ?? CODContactModel())
                }
            }
            self.navigationController?.pushViewController(chooseVC)
        case 400:
            print("语音聊天")
        case 500:
            print("加入黑名单")
            self.blackListAction()
        case 600:
            print("删除联系人")
            self.deleteContactAction()
        case 700:
            print("底部按钮")
            self.sendMessageAction()
        default:
            print("默认")
        }
    }
    
    func sendCard(toContactModel: CODContactModel, fromContactModel: CODContactModel) {
        let msgIDTemp = UserManager.sharedInstance.getMessageId()
        //发送消息
        let model = CODMessageModelTool.default.createBusinessCardModel(msgID: msgIDTemp, toJID: toContactModel.jid, username: fromContactModel.jid , name: fromContactModel.name, userdesc: fromContactModel.userdesc   , userpic: fromContactModel.userpic, jid: fromContactModel.jid, gender: fromContactModel.gender, chatType: .privateChat, roomId: nil, chatId: toContactModel.rosterID, burn: fromContactModel.burn)
        CODMessageSendTool.default.sendMessage(messageModel: model)
        //添加消息到h数据库
        let messageHistory = CODChatHistoryRealmTool.getChatHistory(from: toContactModel.rosterID)
        try! Realm.init().write {
            messageHistory?.messages.append(model)
        }
        //更新会话列表
        //更新会话列表
//        CODChatListRealmTool.updateLastDateTime(id: toContactModel.rosterID, lastDateTime: model.datetime)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
        }
        
    }
        
    
        
    
    
    /// 拨打电话
    ///
    /// - Parameter sender: button
    @IBAction func callPhoneAction(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            let tel = NSString.init(format: "tel://%@", self.a_telLab.text!)
            UIApplication.shared.openURL(NSURL.init(string: tel as String)! as URL)
        case 200:
            let tel = NSString.init(format: "tel://%@", self.b_talLab.text!)
            UIApplication.shared.openURL(NSURL.init(string: tel as String)! as URL)
        default:
            print("默认")
        }
    }
    
    func blackListAction() {
        let  dict:NSDictionary = ["name":COD_changeChat,
                                  "requester":UserManager.sharedInstance.jid,
                                  "itemID":self.contactModel?.rosterID as Any,
                                  "setting":[COD_Blacklist:(!self.contactModel!.blacklist).string]]
        
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func deleteContactAction() {
        
        LPActionSheet.show(withTitle: String.init(format: NSLocalizedString("删除“%@”联系人后，将不会出现在联系人列表", comment: ""), self.contactModel!.nick.count != 0 ? self.contactModel!.nick : self.contactModel!.name), cancelButtonTitle: "取消", destructiveButtonTitle: "删除联系人", otherButtonTitles: []) { (actionSheet, index) in
            
            print(index)
            if index == -1 {
                
                let  dict:NSDictionary = ["name":COD_deleteRoster,
                                          "requester":UserManager.sharedInstance.jid,
                                          "receiver":self.jid]


                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_roster, actionDic: dict)
                XMPPManager.shareXMPPManager.xmppStream.send(iq)
            }
            
        }
    }
    
    func pushSetContactInfoVC() {
        let contactInfoVC = CODEditRemarksVC.init()
        contactInfoVC.model = self.contactModel
        contactInfoVC.callBack = {
            self.configView()
        }
        self.navigationController?.pushViewController(contactInfoVC, animated: true)
    }
    
    func sendMessageAction() {
        let msgCtl = MessageViewController()
        msgCtl.toJID = self.jid
        msgCtl.chatId = self.contactModel!.rosterID
        msgCtl.title = self.contactModel?.name
        msgCtl.isMute = self.contactModel!.mute
        self.navigationController?.setViewControllers([(self.navigationController?.viewControllers.first)!,msgCtl], animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CODContactDetailInfoViewController:XMPPStreamDelegate{
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) {[weak self] (actionDic, infoDic) in
            guard let infoDic = infoDic else {
                return
            }
            guard let self = self else{
                return
            }
            
            if (actionDic["name"] as? String == COD_changeChat){
                if !(infoDic["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus("设置失败")
                    return
                }
                
                let dict = actionDic["setting"] as! NSDictionary
                if (dict[COD_Blacklist] as? String != nil){
                    try! Realm.init().write {
                        self.contactModel?.blacklist = !self.contactModel!.blacklist
                        let pop = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                        pop?.fromValue = NSNumber.init(value: (self.contactModel!.blacklist ? 40 : 0))
                        pop?.toValue = NSNumber.init(value: (self.contactModel!.blacklist ? 0 : 40))
                        self.deleteCos.pop_add(pop, forKey: "")
                        
                        self.addBlakLab.text = self.contactModel!.blacklist ? "移除黑名单" : "加入黑名单"
                        self.blackListTipLab.isHidden = !self.contactModel!.blacklist
                    }
                }
            }
            
            if (actionDic["name"] as? String == COD_deleteRoster){
                
                if !(infoDic["success"] as! Bool){
                    CODProgressHUD.showErrorWithStatus("好友删除失败，请稍后重试！")
                }else{
//                    let realm = try! Realm.init()
//                    try! realm.write {
//                        realm.delete(self.contactModel)
//                    }
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
            if (actionDic["name"] as? String == COD_ChatSetting) {
                if !(infoDic["success"] as! Bool){
                    CODProgressHUD.showErrorWithStatus("好友设置获取失败，请稍后重试！")
                }else{
                    if let setting = infoDic["setting"] as? NSDictionary {
                        let contactModel = CODContactModel()
                        contactModel.jsonModel = CODContactHJsonModel.deserialize(from: setting)
                        CODContactRealmTool.insertContact(by: contactModel)
                        if let chatListModel = CODChatListRealmTool.getChatList(id: contactModel.rosterID) {
                            try! Realm.init().write {
                                chatListModel.title = contactModel.getContactNick()
                            }
                        }
                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                        
                        self.configView()
                    }
                }
            }
            
        }
        
        return true
    }
}
