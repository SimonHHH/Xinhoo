//
//  CODStrangerDetailVC.swift
//  COD
//
//  Created by XinHoo on 2019/6/14.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework
import RxSwift
import RxCocoa
import SwiftyJSON

class CODStrangerDetailVC: BaseViewController {
    
    typealias DeleteAllHistoryBlock = () -> Void
    public var deleteAllHistoryBlock: DeleteAllHistoryBlock?
    
    enum StrangerShowType: Int {
        case common
        case group
    }
    
    var rosterID: Int?
    var jid = ""
    var name = ""
    var userName = ""
    var userDesc = ""
    var gender = ""
    var userPic = ""
    var mute = false
    var stickytop = false
    var blacklist = false
    var burn:Int = 0
    
    var userType: UserType = .user {
        didSet {
            
            if userType == .bot {
                createGroupBtn.setImage(UIImage(named: "cre_group"), for: .normal)
            } else {
                createGroupBtn.setImage(UIImage.init(named: "add_friend"), for: UIControl.State.normal)
            }
        }
    }
    
    var groupNick: String?
    
    var type:SourceType?
    
    var showType: StrangerShowType = .common
    
    var contactModel: CODContactModel?
    
    var momentsPics: BehaviorRelay<[CODMomentsPicModel]> = BehaviorRelay(value: [])
    
    
    /// 是否临时好友，是：已添加到本地数据库，否：未添加
    var isTemporary = false
    var isMyself = false
    
    var burnModel: CODCellModel? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("个人信息", comment: "")
        self.setBackButton()
        
        contactModel = CODContactRealmTool.getContactByJID(by: self.jid)
        if let contact = contactModel {
            self.mute = contact.mute
            self.stickytop = contact.stickytop
            self.blacklist = contact.blacklist
            self.rosterID = contact.rosterID
            self.burn = contact.burn
            self.isTemporary = true
            self.userType = contact.userTypeEnum
        } else if self.jid == UserManager.sharedInstance.jid {
            self.isMyself = true
        } else {
            self.isTemporary = false
        }
        
        if self.userType == .bot {
            self.type = .groupType
        }
        
        self.createDataSource()
        self.setUpUI()
        self.requestContactLoginStatus()
        self.requestMomentsPics()
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapMessageView(gestureRecognizer:)))
        
        self.headerView.iconImageView.addGestureRecognizer(tap)
        self.headerView.iconImageView.isUserInteractionEnabled = true
        if self.jid.contains(UserManager.sharedInstance.loginName ?? "") {
            createGroupBtn.isHidden = true
        }else {
            createGroupBtn.isHidden = false
        }
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        // Do any additional setup after loading the view.
        
        XMPPManager.shareXMPPManager.requestUserInfo(userJid: jid, success: { (model) in

            if let users = model.actionJson?["users"].dictionaryObject {
                if let name = users["name"] as? String, let userPic = users["userpic"] as? String {
                    let person = CODPersonInfoModel.init()
                    person.jid = self.jid
                    person.name = name
                    person.userpic = userPic
                    try! Realm.init().write {
                        try! Realm.init().add(person, update: .all)
                    }
                }
                
                if let username = users["username"] as? String{
                    self.userName = username
                }
                if let userpic = users["userpic"] as? String{
                    self.userPic = userpic
                }
                if let gender = users["gender"] as? String{
                    self.gender = gender
                }
                if let userDesc = users["userdesc"] as? String{
                    self.userDesc = userDesc
                }
                
                if let name = users["name"] as? String {
                    self.name = name
                }
                
                if let xhtype = users["xhtype"] as? String, xhtype == "B" {
                    self.userType = .bot
                }
                
                if let members = CODGroupMemberRealmTool.getMembersByJid(self.userName) {
                    
                    members.forEach { (memberModel) in
                        
                        try? Realm().safeWrite {
                        
                            memberModel.name = self.name
                            
                        }
                    }
                    
                }
                
                if let contact = CODContactRealmTool.getContactByJID(by: self.userName) {
                    try? Realm().safeWrite {
                    
                        contact.name = self.name
                    }
                }
                
                if let listModel = CODChatListRealmTool.getChatList(jid: self.userName) {
                    try? Realm().safeWrite {
                        listModel.title = self.name
                    }
                }
                
                self.reloadHeaderView()
                
            }
            
            
        }) {
            
        }
        
//        var dict:NSDictionary? = [:]
//        dict = ["name":COD_searchUserBID,
//                "requester":UserManager.sharedInstance.jid,
//                "search":[["content":jid]]]
//
//        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_contacts, actionDic: dict!)
//        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: userpic, complete: )
        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: userPic) { (image) in
            self.headerView.userAvatar = self.userPic
        }
    }
    
    private var dataSource: Array = [[CODCellModel]]()
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor.clear
        tabelV.tableHeaderView = headerView
        tabelV.delegate = self
        tabelV.dataSource = self
        
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    fileprivate lazy var headerView:CODPersonHeaderView = {
        
        let headerV = CODPersonHeaderView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 90))
        headerV.nameString = self.name
        if let groupNick = self.groupNick {
            headerV.groupNickString = "群昵称：\(groupNick)"
        }
        //        headerV.statusString = NSAttributedString.init(string: "上线于不久前").colored(with: UIColor(hexString: kSubTitleColors)!)
        headerV.userAvatar = userPic
        
        if self.userType != .bot {
            headerV.isWoman = gender.compareNoCaseForString("FEMALE")
        } else {
            headerV.statusString = NSAttributedString(string: NSLocalizedString("机器人", comment: "")).colored(with: UIColor(hexString: kWeakTitleColorS)!)
        }
        
        
        return headerV
    }()
    

    
    lazy var createGroupBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        //        btn.frame = CGRect.init(x: KScreenWidth-85, y: 40, width: 70, height: 70)
        
        if userType == .bot {
            btn.setImage(UIImage(named: "cre_group"), for: .normal)
        } else {
            btn.setImage(UIImage.init(named: "add_friend"), for: UIControl.State.normal)
        }
        
        
        btn.addTarget(self, action: #selector(createGroupAction), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var takePhoneBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage.init(named: "take_tel"), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(takePhoneAction), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var chatBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage.init(named: "chat_with"), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(chatAction), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var burnView: CODBurnSettingView = {
        let burnv = CODBurnSettingView.init(frame: CGRect.zero)
        return burnv
    }()
    
    @objc public func tapMessageView(gestureRecognizer:UITapGestureRecognizer){
        let url =  URL.init(string: (self.userPic.getHeaderImageFullPath(imageType: 2)))
        CustomUtil.removeImageCahch(imageUrl: self.userPic.getHeaderImageFullPath(imageType: 2))
        
        let photoIndex: Int = 0
        let imageData: YBIBImageData = YBIBImageData()
        //        imageData.projectiveView = self.headerView.iconImageView
        imageData.imageURL = url
        let browser:YBImageBrowser =  YBImageBrowser()
        browser.dataSourceArray = [imageData]
        browser.currentPage = photoIndex
        browser.show()
    }
    
    func updateBurn(burn: Int){
        
        if let model = CODContactRealmTool.getContactById(by: self.rosterID!) {
            try! Realm.init().write {
                model.burn = burn
                if let chatListModel = CODChatListRealmTool.getChatList(id: model.rosterID) {
                    chatListModel.lastDateTime = "\(Date.milliseconds)"
                }
            }
        }
        
        burnModel?.subTitle = self.convertBurnStr(burn: burn).0
        
        //通知去聊天列表中更新数据
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
    }
    
    override func navBackClick() {
        self.burnView.dismissAlert()
        self.navigationController?.popViewController(animated: true)
    }
    
    func reloadHeaderView() {
        if self.userType != .bot {
            headerView.isWoman = gender.compareNoCaseForString("FEMALE")
        } else {
            headerView.statusString = NSAttributedString(string: NSLocalizedString("机器人", comment: "")).colored(with: UIColor(hexString: kWeakTitleColorS)!)
        }
    }
    
}

private extension CODStrangerDetailVC {
    
    func requestContactLoginStatus() {
        var dict:NSDictionary = [:]
        
        dict = ["name":COD_GetStatus,
                "requester":UserManager.sharedInstance.jid,
                "receiver":jid]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_roster, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func requestMomentsPics() {
        DiscoverHttpTools.getUserMomentsPics(jid: self.jid) {  (response) in
            
            guard !response.result.isFailure else {
                return
            }
            let json = JSON(response.value as Any)
            let picListStr = json["data"]["picList"].stringValue
            let picList = JSON(parseJSON: picListStr).arrayValue
            
            let picArr = picList.map { (picJson) -> CODMomentsPicModel? in
                if let duration = picJson["duration"].float, duration > 0 {
                    return CODMomentsPicModel(picId: picJson["firstpic"].stringValue, type: 1)
                } else if let photoid = picJson["photoid"].string, photoid.count > 0 {
                    return CODMomentsPicModel(picId: photoid, type: 0)
                } else if let firstpic = picJson["firstpic"].string, firstpic.count > 0 {
                    return CODMomentsPicModel(picId: firstpic, type: 0)
                } else if let filepic = picJson["filepic"].string, filepic.count > 0 {
                    return CODMomentsPicModel(picId: filepic, type: 0)
                } else {
                    return nil
                }
            }.compactMap{ $0 }
            
            self.momentsPics.accept(picArr)
            
        }
        
    }
    
    func createDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
        
        if userDesc.count > 0 {
            let model1 = self.createModel(title: userDesc, subTitle: "", placeholder: "", image: "at", type: .baseType)
            dataSource.append([model1])
        }
        
        
        if let contactModel = contactModel, contactModel.about.count > 0 {
            let model = self.createModel(title: contactModel.about, subTitle: "", placeholder: "", image: "about_icon_2", type: .custom(cellType: CODPresenDetailIntroCell.self))
            dataSource.append([model])
        } else if isMyself {
            
            let modelPhone = self.createModel(title: "(+\(UserManager.sharedInstance.areaNum ?? "")) \(UserManager.sharedInstance.phoneNum ?? "")", subTitle: "", placeholder: "", image: "phone_number", type: .baseType)
            
            dataSource.append([modelPhone])
            
            if let intro = UserManager.sharedInstance.intro, intro.count > 0 {
                let model = self.createModel(title: intro, subTitle: "", placeholder: "", image: "about_icon_2", type: .custom(cellType: CODPresenDetailIntroCell.self))
                dataSource.append([model])
            }
            
            
        }
        
        if self.isMyself {
            var model15 = self.createModel(title: "朋友圈", subTitle: "", placeholder: "", image: "moments_icon", type: .custom(cellType: CODMomentsTableVCell.self))
            model15.action.didSelected = { [weak self] in
                guard let `self` = self else { return }
                self.pushToMomentsVC()
            }
            dataSource.append([model15])
        }
        
        var midArr: Array<CODCellModel> = []
        let list = CODGroupMemberRealmTool.getMembersByJid(jid)
        if let list = list, list.count > 0 {
            var listCount = 0
            for member in list {
                let roomId = member.memberId.subStringTo(string: "c")
                if let groupModel = CODGroupChatRealmTool.getGroupChat(id: roomId.int!) {
                    if groupModel.isValid == true {
                        listCount += 1
                    }
                }
            }
            if self.jid != UserManager.sharedInstance.jid {
                var model5 = self.createModel(title: "共同加入的群组", subTitle: "\(listCount)", placeholder: "", image: "group_joined_together", type: .baseType)
                model5.action.didSelected = { [weak self] in
                    guard let `self` = self else { return }
                    self.pushToTogetherVC()
                }
                midArr.append(model5)
            }
        }
        
        if self.isTemporary {
            var model6 = self.createModel(title: "共享媒体", subTitle: "", placeholder: "", image: "shared_media", type: .baseType)
            model6.action.didSelected = { [weak self] in
                guard let `self` = self else { return }
                self.pushToShareMediaVC()
            }
            midArr.append(model6)
        }
        dataSource.append(midArr)
        
        if self.isTemporary && self.userType != .bot {
            burnModel = self.createModel(title: "阅后即焚", subTitle: self.convertBurnStr(burn: self.burn).0, placeholder: "", image: "burn", type: .baseType)
            burnModel!.action.didSelected = { [weak self] in
                guard let `self` = self else { return }
                self.burnView = CODBurnSettingView.init(frame: self.view.frame)
                self.burnView.delegate = self
                self.burnView.defaultSelectRow = self.convertBurnStr(burn: self.burn).1
                self.burnView.showAlert()
            }
            dataSource.append([burnModel!])
        }
        
        if self.isTemporary {
            var model7 = self.createSwitchModel(title: "置顶聊天", subTitle: "", placeholder: "", image: "setTop", type: .switchType, switchIsOn: self.stickytop, isEnable: true)
            model7.action.switchButtonAction = { [weak self] isOn in
                guard let `self` = self else { return }
                self.sendIQ(action: .stickytop, isOn: isOn)
            }
            var model8 = self.createSwitchModel(title: "消息通知", subTitle: "", placeholder: "", image: "message_avoidance", type: .switchType, switchIsOn: !self.mute, isEnable: true)
            model8.action.switchButtonAction = { [weak self] isOn in
                guard let `self` = self else { return }
                self.sendIQ(action: .mute, isOn: isOn)
            }
            
            
            
            var model9 = self.createSwitchModel(title: "加入黑名单", subTitle: "", placeholder: "", image: "add_blacklist", type: .switchType, switchIsOn: self.blacklist, isEnable: true)
            
            model9.action.switchButtonAction = { [weak self] isOn in
                guard let `self` = self else { return }
                self.sendIQ(action: .blacklist, isOn: isOn)
            }
            
            if self.userType == .bot {
                dataSource.append([model7,model8])
            } else {
                dataSource.append([model7,model8,model9])
            }
            
            
            var model10 = self.createModel(title: "清除聊天记录", subTitle: "", placeholder: "", image: "clear_chat_history", type: .baseType)
            model10.action.didSelected = { [weak self] in
                guard let `self` = self else { return }
                self.deleteAllHistory()
            }
            dataSource.append([model10])
        }
        
        
    }
    
    
    
    func createModel(title: String = "",
                     subTitle: String = "",
                     placeholder: String = "",
                     image: String = "",
                     type: CODCellType) -> (CODCellModel) {
        var model = CODCellModel()
        model.title = title
        model.subTitle = subTitle
        model.placeholderString = placeholder
        model.type = type
        model.iconName = image
        return model
    }
    
    func createSwitchModel(title: String = "",
                           subTitle: String = "",
                           placeholder: String = "",
                           image: String = "",
                           type: CODCellType,
                           switchIsOn: Bool,
                           isEnable: Bool) -> (CODCellModel) {
        var model = self.createModel(title: title, subTitle: subTitle, placeholder: placeholder, image: image, type: type)
        model.isOn = switchIsOn
        model.isEnable = isEnable
        return model
    }
    
    
    
    func setUpUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
        self.createSuspenView()
    }
    
    func createSuspenView() {
        
        var btnArr:Array<UIButton> = []
        
        if self.userType == .bot {
            btnArr = [createGroupBtn, chatBtn]
        } else if self.isTemporary {
            btnArr = [createGroupBtn, takePhoneBtn, chatBtn]
        } else {
            btnArr = [createGroupBtn, chatBtn]
        }
        
        self.view.addSubviews(btnArr)
        
        
        let bottom: ConstraintItem = self.isTemporary ? takePhoneBtn.snp.bottom : createGroupBtn.snp.bottom
        
        if self.userType == .bot {
            
            
            
            createGroupBtn.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(40) //104
                make.right.equalToSuperview().offset(-15)
                make.width.height.equalTo(70)
            }
            
            chatBtn.snp.makeConstraints { (make) in
                make.top.equalTo(createGroupBtn.snp.bottom).offset(-10)
                make.right.equalTo(createGroupBtn)
                make.width.height.equalTo(70)
            }
            
        } else if self.isTemporary {
            
            createGroupBtn.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(40) //104
                make.right.equalToSuperview().offset(-15)
                make.width.height.equalTo(70)
            }
            
            takePhoneBtn.snp.makeConstraints { (make) in
                make.top.equalTo(createGroupBtn.snp.bottom).offset(-10)
                make.right.equalTo(createGroupBtn)
                make.width.height.equalTo(70)
            }
            
            chatBtn.snp.makeConstraints { (make) in
                make.top.equalTo(bottom).offset(-10)
                make.right.equalTo(createGroupBtn)
                make.width.height.equalTo(70)
            }
            
            
        } else {
            
            createGroupBtn.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(40) //104
                make.right.equalToSuperview().offset(-15)
                make.width.height.equalTo(70)
            }
            
            chatBtn.snp.makeConstraints { (make) in
                make.top.equalTo(bottom).offset(-10)
                make.right.equalTo(createGroupBtn)
                make.width.height.equalTo(70)
            }
            
        }
        
        
    }
    
    func suspenViewSetHidden(hidden: Bool) {
        createGroupBtn.isHidden = hidden
    }
    
    
    
    @objc func createGroupAction() {
        
        if userType == .bot {
            createGroup()
        } else {
            addFriend()
        }
        
    }
    
    func addFriend() {
        let model = CODChatPersonModel()
        model.username = self.userName
        model.name = self.name
        model.tojid = self.jid
        
        let verificationVC = CODVerificationApplicationVC()
        verificationVC.model = model
        verificationVC.type = self.type
        self.navigationController?.pushViewController(verificationVC)
    }
    
    func createGroup() {
        let ctl = CreGroupChatViewController()
        ctl.ctlType = .createGroup
        ctl.contactModel = self.contactModel
        ctl.createGroupSuccess = {(_ groupChatModel : CODGroupChatModel) in
            let msgCtl = MessageViewController()
            msgCtl.chatType = .groupChat
            if groupChatModel.descriptions.count > 0 {
                msgCtl.title = groupChatModel.descriptions
            }else{
                msgCtl.title = NSLocalizedString("群组", comment: "")
            }
            msgCtl.toJID = groupChatModel.jid
            msgCtl.roomId = "\(groupChatModel.roomID)"
            msgCtl.chatId = groupChatModel.roomID
            msgCtl.isMute = groupChatModel.mute
            //获取pop之后的ChatviewController
            let ctl = UIViewController.current() /*as? CODCustomTabbarViewController*/
            
            ctl?.navigationController?.pushViewController(msgCtl, animated: true)
        }
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
    @objc func takePhoneAction() {
        self.vioceCall()
    }
    
    @objc func chatAction() {
        if self.jid == UserManager.sharedInstance.jid {
            let msgCtl = MessageViewController()
            msgCtl.chatType = .privateChat
            msgCtl.toJID = kCloudJid + XMPPSuffix
            msgCtl.chatId = CloudDiskRosterID
            msgCtl.title = NSLocalizedString("我的云盘", comment: "")
            UIViewController.current()?.navigationController?.pushViewController(msgCtl, animated: true)
            return
        }
        
        self.requestAddTempFriend()
    }
    
    func requestAddTempFriend() {
        let  dict:NSDictionary = ["name":COD_temporaryfriend,
                                  "requester":UserManager.sharedInstance.jid,
                                  "receiver":self.jid]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_roster, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func vioceCall() {
        if UserDefaults.standard.bool(forKey: kIsVideoCall) {
            CODProgressHUD.showWarningWithStatus("当前无法发起语音通话")
            return
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.callObserver.calls.first != nil {
            let alert = UIAlertController.init(title: "正在通话", message: String.init(format: NSLocalizedString("您不能在电话通话时同时使用 %@ 通话。", comment: ""), kApp_Name), preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if delegate.manager?.status == .notReachable {
            
            let alert = UIAlertController.init(title: "无法呼叫", message: "请检查您的互联网连接并重试。", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
                
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let  dict:NSDictionary = ["name":COD_request,
                                  "requester":UserManager.sharedInstance.jid,
                                  "memberList":[self.jid],
                                  "chatType":"1",
                                  "roomID":"0",
                                  "msgType":COD_call_type_voice]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func pushToTogetherVC() {
        let vc = CODSavedGroupChatVC()
        vc.type = .togetherGroup
        vc.jid = jid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushToMomentsVC() {
        let vc = CODDiscoverPersonalListVC(jid: self.jid)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushToShareMediaVC() {
        let vc = SharedMediaFileViewController.init(nibName: "SharedMediaFileViewController", bundle: nil)
        vc.title = NSLocalizedString("共享媒体", comment: "")
        vc.chatId = self.rosterID!
        if let listModel = CODChatListRealmTool.getChatList(id: self.rosterID!) {
            vc.list = listModel.chatHistory?.messages
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteAllHistory() {
        LPActionSheet.show(withTitle: String.init(format: "确定清除当前对话的历史记录?"), cancelButtonTitle: "取消", destructiveButtonTitle: "确定", otherButtonTitles: []) { (actionSheet, index) in
            
            if index == -1 {
                if let block = self.deleteAllHistoryBlock {
                    block()
                }else{
                    if let chatModel = try! Realm.init().object(ofType: CODChatListModel.self, forPrimaryKey: self.rosterID!){
                        if let chatHistory = chatModel.chatHistory {
                            try! Realm.init().write {
                                for message in chatHistory.messages{
                                    try! Realm.init().delete(message)
                                }
                                chatHistory.messages.removeAll()
                                chatModel.count = 0
                                chatModel.lastDateTime = "0"
                                chatModel.isShowBurned = false
                            }
                        }
                        //通知去聊天列表中更新数据
                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                    }
                }
            }
        }
    }
    
    enum IQAction {
        case stickytop
        case mute
        case blacklist
        
    }
    
    func sendIQ(action: IQAction,isOn:Bool) {
        
        var dict:NSDictionary? = [:]
        switch action {
        case .stickytop:
            dict = self.dictionaryWithChangeMute(typeStr: COD_Stickytop, isOn: isOn)
        case .mute:
            dict = self.dictionaryWithChangeMute(typeStr: COD_Mute, isOn: !isOn)
        case .blacklist:
            if self.blacklist {
                dict = self.dictionaryWithChangeMute(typeStr: COD_Blacklist, isOn: isOn)
            }else{
                _ = showAlert(title: "将对方加入黑名单?", message: "加入黑名单，您将不再收到对方的消息。", buttonTitles: ["否","是"]) { (index) in
                    if index == 1 {
                        dict = self.dictionaryWithChangeMute(typeStr: COD_Blacklist, isOn: isOn)
                        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict!)
                        XMPPManager.shareXMPPManager.xmppStream.send(iq)
                    }else{
                        self.tableView.reloadData()
                    }
                }
                return
            }
            
        }
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict!)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        
    }
    
    func dictionaryWithChangeMute(typeStr: String, isOn: Bool) -> NSDictionary? {
        let dict = ["name":COD_changeChat,
                    "requester":UserManager.sharedInstance.jid,
                    "itemID":self.rosterID as Any,
                    "setting":[typeStr:isOn]] as [String : Any]
        return dict as NSDictionary
    }
    
    func convertBurnStr(burn: Int) -> (String, Int) {
        switch burn {
        case 0:
            return ("关闭",0)
        case 1:
            return ("即刻焚烧",1)
        case 10:
            return ("10秒",2)
        case 300:
            return ("5分钟",3)
        case 3600:
            return ("1小时",4)
        case 86400:
            return ("24小时",5)
        default:
            return ("关闭",6)
        }
    }
}

extension CODStrangerDetailVC:UITableViewDelegate,UITableViewDataSource{
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODMessageDetailCell.self, forCellReuseIdentifier: "CODMessageDetailCellID")
        tableView.register(CODMessageDetailImageCell.self, forCellReuseIdentifier: "CODMessageDetailImageCellID")
        tableView.register(CODMessageDetailSwitchCell.self, forCellReuseIdentifier: "CODMessageDetailSwitchCellID")
        tableView.register(nibWithCellClass: CODPresenDetailIntroCell.self)
        tableView.register(nibWithCellClass: CODMomentsTableVCell.self)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        let  datas = dataSource[section]
        return datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let  datas = dataSource[indexPath.section]
        let model = datas[indexPath.row]
        if case .switchType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailSwitchCellID", for: indexPath) as? CODMessageDetailSwitchCell
            if cell == nil{
                cell = CODMessageDetailSwitchCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailSwitchCellID")
            }
            if indexPath.row == 0 {
                cell?.isTop = true
            }else{
                cell?.isTop = false
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.enable = model.isEnable ?? false
            cell?.switchIsOn = model.isOn
            cell?.imageStr = model.iconName
            cell?.iconView.layer.cornerRadius = 0.0
            cell?.onBlock = { isOn -> () in
                model.action.switchButtonAction?(isOn)
            }
            return cell!
        }else if case .imageType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailImageCellID", for: indexPath) as? CODMessageDetailImageCell
            if cell == nil{
                cell = CODMessageDetailImageCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailImageCellID")
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.imageV = UIImage.init(named: model.iconName ?? "")
            return cell!
        } else if case .custom(cellType: let cellType) = model.type, cellType == CODPresenDetailIntroCell.self {
            
            let cell = tableView.dequeueReusableCell(withClass: CODPresenDetailIntroCell.self, for: indexPath)
            cell.introLabel.text = model.title
            return cell
            
        }  else if case .custom(cellType: let cellType) = model.type, cellType == CODMomentsTableVCell.self {
            
            let cell = tableView.dequeueReusableCell(withClass: CODMomentsTableVCell.self, for: indexPath)
            cell.titleLab.text = model.title
            self.momentsPics.bind(to: cell.rx.dataSourceBind).disposed(by: self.rx.disposeBag)
            return cell
            
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailCellID", for: indexPath) as? CODMessageDetailCell
            if cell == nil{
                cell = CODMessageDetailCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailCellID")
            }
            if case .deleteType = model.type {
                cell?.isDelete = true
            }else{
                cell?.isDelete = false
            }
            if indexPath.row == 0 {
                cell?.isTop = true
            }else{
                cell?.isTop = false
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.subTitle = model.subTitle
            cell?.imageStr = model.iconName
            cell?.isHiddenArrow = true
            
            model.$subTitle
                .bind(to: cell!.subTitleLab.rx.text)
                .disposed(by: cell!.rx.prepareForReuseBag)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 12))
        bgView.backgroundColor = UIColor.clear
        return bgView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 1))
        view.backgroundColor = UIColor(hexString: kVCBgColorS)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dataSource[indexPath.section][indexPath.row].action.didSelected?()
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }
    
    //    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 43
    //    }
}

extension CODStrangerDetailVC: XMPPStreamDelegate {
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        CustomUtil.analyticxXML(iq: iq) { [weak self] (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            guard let self = self else {
                return
            }
            if (actionDict["name"] as? String == COD_GetStatus) {
                if let isSuccess = infoDict["success"] as? Bool {
                    guard isSuccess else {
                        return
                    }
                    if let dataDic = infoDict.object(forKey: "data") as? NSDictionary,
                        let lastloginTime = dataDic.object(forKey: "lastloginTime") as? Int,
                        let status = dataDic.object(forKey: "status") as? String,
                        let lastLoginTimeVisible = dataDic.object(forKey: "lastLoginTimeVisible") as? Bool,
                        let jid = dataDic.object(forKey: "jid") as? String
                    {
                        if self.userType == .bot {
                            return
                        }
                        
                        if jid == self.jid {
                            if let contact = CODContactRealmTool.getContactByJID(by: jid) {
                                try! Realm.init().write {
                                    contact.lastlogintime = lastloginTime
                                    contact.loginStatus = status
                                    contact.lastLoginTimeVisible = lastLoginTimeVisible
                                }
                                let result = CustomUtil.getOnlineTimeStringAndStrColor(with: contact)
                                self.headerView.statusString = NSAttributedString.init(string: result.timeStr).colored(with: result.strColor)
                            }else{
                                let member = CODGroupMemberModel()
                                member.lastlogintime = lastloginTime
                                member.loginStatus = status
                                member.lastLoginTimeVisible = lastLoginTimeVisible
                                let result = CustomUtil.getOnlineTimeStringAndStrColor(with: member)
                                self.headerView.statusString = NSAttributedString.init(string: result.timeStr).colored(with: result.strColor)
                            }
                            
                            
                        }
                        
                    }
                }
            }
            
            if(actionDict["name"] as? String == COD_changeChat) {
                if !(infoDict["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus("设置失败")
                    self.tableView.reloadData()
                }else{
                    let dict = actionDict["setting"] as! NSDictionary
                    if (dict["stickytop"] as? Bool) != nil{
                        self.stickytop = !self.stickytop
                    }else if (dict["mute"] as? Bool) != nil{
                        self.mute = !self.mute
                    }else if (dict["blacklist"] as? Bool) != nil{
                        self.blacklist = !self.blacklist
                    }else if let result = dict["burn"] as? Int{
                        self.updateBurn(burn: result)
                    }
                }
                
                
            }
//            if (actionDict["name"] as? String == COD_searchUserBID){
//                if (infoDict["success"] as! Bool) {
//                    if let users = infoDict["users"] as? NSDictionary {
//                        if let name = users["name"] as? String, let userPic = users["userpic"] as? String {
//                            let person = CODPersonInfoModel.init()
//                            person.jid = self.jid
//                            person.name = name
//                            person.userpic = userPic
//                            try! Realm.init().write {
//                                try! Realm.init().add(person, update: .all)
//                            }
//                        }
//                        
//                        if let username = users["username"] as? String{
//                            self.userName = username
//                        }
//                        if let userpic = users["userpic"] as? String{
//                            self.userPic = userpic
//                        }
//                        if let gender = users["gender"] as? String{
//                            self.gender = gender
//                        }
//                        if let userDesc = users["userdesc"] as? String{
//                            self.userDesc = userDesc
//                        }
//                        
//                        if let name = users["name"] as? String {
//                            self.name = name
//                        }
//                        
//                        if let xhtype = users["xhtype"] as? String, xhtype == "B" {
//                            self.userType = .bot
//                        }
//                        
//                        if let members = CODGroupMemberRealmTool.getMembersByJid(self.userName) {
//                            
//                            members.forEach { (memberModel) in
//                                
//                                try? Realm().safeWrite {
//                                
//                                    memberModel.name = self.name
//                                    
//                                }
//                            }
//                            
//                        }
//                        
//                        if let contact = CODContactRealmTool.getContactByJID(by: self.userName) {
//                            try? Realm().safeWrite {
//                            
//                                contact.name = self.name
//                            }
//                        }
//                        
//                        if let listModel = CODChatListRealmTool.getChatList(jid: self.userName) {
//                            try? Realm().safeWrite {
//                                listModel.title = self.name
//                            }
//                        }
//                        
//                        self.reloadHeaderView()
//                        
//                    }
//                }
//            }
        }
        
        return true
    }
}


extension CODStrangerDetailVC: BurnSettingDelegate {
    func didSelectRow(burnDelayDic: Dictionary<String, Any>) {
        guard let model = CODContactRealmTool.getContactByJID(by: self.jid) else {
            return
        }
        if model.burn == burnDelayDic["burn"] as! Int {
            return
        }
        let dict:NSMutableDictionary = NSMutableDictionary.init(dictionary: ["requester":UserManager.sharedInstance.jid,"itemID":self.rosterID!,"setting":["burn":burnDelayDic["burn"]]])
        dict.setValue(COD_changeChat, forKey: "name")
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
}
