//
//  CODPersonDetailVC.swift
//  COD
//
//  Created by 1 on 2019/3/16.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework
import SVProgressHUD
import RxCocoa
import RxSwift

class CODPersonDetailVC: BaseViewController {
    
    enum IQAction {
        case stickytop
        case mute
        case blacklist
        
    }
    
    enum PersonShowType: Int {
        case common
        case group
    }
    
    typealias DeleteAllHistoryBlock = () -> Void
    public var deleteAllHistoryBlock: DeleteAllHistoryBlock?
    
    typealias UpdateMemberInfoBlock = () -> Void
    public var updateMemberInfoBlock: UpdateMemberInfoBlock?
    
    var showType: PersonShowType = .common
    
    var rosterId :Int = 0
    var contactModel: CODContactModel!
    var statusStr: NSAttributedString!
    var burnModel: CODCellModel?
    var stickytopModel: CODCellModel?
    var muteModel: CODCellModel?
    var blacklistModel: CODCellModel?
    var groupNick: String?
    
    var momentsPics: BehaviorRelay<[CODMomentsPicModel]> = BehaviorRelay(value: [])
    

    var bigImage: UIImage = UIImage()
    
    var notificationToken: NotificationToken? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("个人信息", comment: "")
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        contactModel = CODContactRealmTool.getContactById(by: rosterId)
        notificationToken = contactModel.observe({ [weak self] (change) in
            switch change {
                
            case .error(_):
                break
            case .change(let properties):
                for property in properties.1 {
                    if property.name == "loginStatus"{
                        self?.updateLoginStatus()
                    }
                }
                break
            case .deleted:
                break
            @unknown default:
                break
            }
            
        })
        
//         ()
        
        self.setBackButton()
        self.setRightButton()
        self.rightButton.setImage(UIImage(named: "nick_edit"), for: UIControl.State.normal)
        
        self.setUpUI()
        self.updateLoginStatus()
        self.createDataSource()
//        self.requestContactLoginStatus()
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapMessageView(gestureRecognizer:)))
        self.headerView.iconImageView.addGestureRecognizer(tap)
        self.headerView.iconImageView.isUserInteractionEnabled = true
        
        self.requestMomentsPics()
        self.getData()

    }
    
    
    private var dataSource: Array = [[CODCellModel]]()
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tabelV.estimatedRowHeight = 43
        tabelV.rowHeight = UITableView.automaticDimension
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
        
        let headerView = CODPersonHeaderView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 90))
        if showType == .common {
            if contactModel.nick.count > 0 {
                headerView.nameString = contactModel.nick
                headerView.nickNameString = "\(NSLocalizedString("昵称", comment: ""))：\(contactModel.name)"
            }else{
                headerView.nameString = contactModel.name
            }
        }else{
            if contactModel.nick.count > 0 {
                headerView.nameString = contactModel.nick
                headerView.nickNameString = "\(NSLocalizedString("昵称", comment: ""))：\(contactModel.name)"
                if let groupNick = groupNick {
                    headerView.groupNickString = "\(NSLocalizedString("群昵称", comment: ""))：\(groupNick)"
                }
                
            }else{
                headerView.nameString = contactModel.name
                if let groupNick = groupNick {
                    headerView.groupNickString = "\(NSLocalizedString("群昵称", comment: ""))：\(groupNick)"
                }
            }
        }

        headerView.userAvatar = contactModel.userpic
        headerView.isWoman = contactModel.gender.compareNoCaseForString("FEMALE")
        return headerView
    }()
    
    lazy var createGroupBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage.init(named: "cre_group"), for: UIControl.State.normal)
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
    
    override func navBackClick() {
        self.burnView.dismissAlert()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func navRightClick() {
        self.pushSetContactInfoVC()
    }
}

private extension CODPersonDetailVC {
    
    func updateLoginStatus() {
        let result = CustomUtil.getOnlineTimeStringAndStrColor(with: contactModel)
        self.headerView.statusString = NSAttributedString(string: result.timeStr).colored(with: result.strColor)
    }
    
    func createDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
        
        var arr = Array<CODCellModel>()
        
        if contactModel.userdesc.count > 0 {
            let model13 = self.createModel(title: contactModel.userdesc, subTitle: "", placeholder: "", image: "at", type: .baseType)
            arr.append(model13)
        }
        
        if contactModel.deftel.count > 0 {
            var model = self.createModel(title: "(+\(contactModel.defareacode)) \(contactModel.deftel)", subTitle: "", placeholder: "", image: "phone_number", type: .baseType)
            model.action.didSelected = { [weak self] in
                
                guard let `self` = self else {
                    return
                }
                
                let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let appCallAction = UIAlertAction(title: "\(kApp_Name) Call", style: .default) { (action) in
                    self.vioceCall()
                }
                
                let phoneCallAction = UIAlertAction(title: NSLocalizedString("手机通话", comment: ""), style: .default) { (action) in
                    
                    let phone = "telprompt://" + self.contactModel.deftel
                    if let url = URL(string: phone) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel) { (action) in
                    
                }
                
                actionsheet.addAction(appCallAction)
                actionsheet.addAction(phoneCallAction)
                actionsheet.addAction(cancelAction)
                
                
                self.present(actionsheet, animated: true, completion: nil)
                
                
            }
            arr.append(model)
        }
        
        if contactModel.tels.count > 0 {
            var count = 0
            for i in 0..<contactModel.tels.count {
                let tel = contactModel.tels[i]
                if tel.removeHeadAndTailSpacePro.count > 0 {
                    count += 1
                    let model = self.createModel(title: tel, subTitle: "", placeholder: "", image: i == 0 ? "remark_tel" : "1", type: .baseType)
                    arr.append(model)
                }
            }
        }
        
        if arr.count > 0 {
            dataSource.append(arr)
        }
        
        if contactModel.about.count > 0 {
            let model = self.createModel(title: contactModel.about, subTitle: "", placeholder: "", image: "about_icon_2", type: .custom(cellType: CODPresenDetailIntroCell.self))
            dataSource.append([model])
        }
        
        
        if contactModel.descriptions.count > 0 {
            let model14 = self.createModel(title: "描述", subTitle: contactModel.descriptions, placeholder: "", image: "desctription", type: .longTextType)
            dataSource.append([model14])
        }
        
        var model15 = self.createModel(title: "朋友圈", subTitle: "", placeholder: "", image: "moments_icon", type: .custom(cellType: CODMomentsTableVCell.self))
        model15.action.didSelected = { [weak self] in
            guard let `self` = self else { return }
            self.pushToMomentsVC()
        }
        dataSource.append([model15])
        
        var model5 = self.createModel(title: "分享名片", subTitle: "", placeholder: "", image: "Share_business_cards", type: .baseType)
        model5.action.didSelected = { [weak self] in
            guard let `self` = self else { return }
            self.sendContactCard()
        }
        dataSource.append([model5])
        
        let list = CODGroupMemberRealmTool.getMembersByJid(contactModel.jid)
        
        var model6 = self.createModel(title: "共享媒体", subTitle: "", placeholder: "", image: "shared_media", type: .baseType)
        
        model6.action.didSelected = { [weak self] in
            guard let `self` = self else { return }
            self.pushToShareMediaVC()
        }
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
            var model8 = self.createModel(title: "共同加入的群组", subTitle: "\(listCount)", placeholder: "", image: "group_joined_together", type: .baseType)
            model8.action.didSelected = { [weak self] in
                guard let `self` = self else { return }
                self.pushToTogetherVC()
            }
            dataSource.append([model8, model6])
        }else{
            dataSource.append([model6])
        }
        
        
        burnModel = self.createModel(title: "阅后即焚", subTitle: self.convertBurnStr(burn: self.contactModel?.burn ?? 0).0, placeholder: "", image: "burn", type: .baseType)
        
        burnModel!.action.didSelected = { [weak self] in
            guard let `self` = self else { return }
            self.burnSetting()
        }
        
        dataSource.append([burnModel!])
        
        stickytopModel = self.createSwitchModel(title: "置顶聊天", subTitle: "", placeholder: "", image: "setTop", type: .switchType, switchIsOn: self.contactModel.stickytop, isEnable: true)
        stickytopModel!.action.switchButtonAction = { [weak self] isOn in
            guard let `self` = self else { return }
            self.sendIQ(action: .stickytop, isOn: isOn)
        }
        
        muteModel = self.createSwitchModel(title: "消息通知", subTitle: "", placeholder: "", image: "message_avoidance", type: .switchType, switchIsOn: !self.contactModel.mute, isEnable: true)
        
        muteModel!.action.switchButtonAction = { [weak self] isOn in
            guard let `self` = self else { return }
            self.sendIQ(action: .mute, isOn: isOn)
        }
        
//        let model6 = self.createSwitchModel(title: "设为星标好友", subTitle: "", placeholder: "", image: "star_friend", type: .switchType, switchIsOn: false, isEnable: true)
        blacklistModel = self.createSwitchModel(title: "加入黑名单", subTitle: "", placeholder: "", image: "add_blacklist", type: .switchType, switchIsOn: self.contactModel.blacklist, isEnable: true)
        blacklistModel!.action.switchButtonAction = { [weak self] isOn in
            guard let `self` = self else { return }
            
            if self.contactModel.blacklist {
                self.sendIQ(action: .blacklist, isOn: isOn)
            }else{
                _ = self.showAlert(title: "将对方加入黑名单?", message: "加入黑名单，您将不再收到对方的消息。", buttonTitles: ["否","是"]) { [weak self] (index) in
                    guard let `self` = self else { return }
                    if index == 1 {
                        self.sendIQ(action: .blacklist, isOn: isOn)
                    }else{
                        self.blacklistModel?.isOn = false
                    }
                }
            }
            
        }
        
        self.createGroupBtnSetHidden(hidden: self.contactModel.blacklist, isAnimation: false)
        dataSource.append([stickytopModel!,muteModel!,blacklistModel!])
        
        var model7 = self.createModel(title: "清除聊天记录", subTitle: "", placeholder: "", image: "clear_chat_history", type: .baseType)
        model7.action.didSelected = { [weak self] in
            guard let `self` = self else { return }
            self.deleteAllHistory()
        }
        dataSource.append([model7])
        
        
        var model9 = self.createModel(title: "删除联系人", subTitle: "", placeholder: "", image: "", type: .deleteType)
        model9.action.didSelected = { [weak self] in
            guard let `self` = self else { return }
            self.deleteContactAction()
        }
        dataSource.append([model9])
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
    
    func setUpUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
        self.createSuspenView()
    }
    
    func getData(){
        let dict:NSDictionary = ["name":COD_ChatSetting,
                                 "requester":UserManager.sharedInstance.jid,
                                 "itemID":self.contactModel.rosterID]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_setting, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func requestContactLoginStatus() {
        var dict:NSDictionary = [:]

        dict = ["name":COD_GetStatus,
                "requester":UserManager.sharedInstance.jid,
                "receiver":self.contactModel.jid]

        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_roster, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func requestMomentsPics() {
        DiscoverHttpTools.getUserMomentsPics(jid: self.contactModel.jid) {  (response) in
                        
            guard !response.result.isFailure else {
//                CODAlertView_show(NSLocalizedString("该内容已不可见", comment: ""))
                return
            }
            let json = JSON(response.value as Any)
            let picListStr = json["data"]["picList"].stringValue
            let picList = JSON(parseJSON: picListStr).arrayValue
            print(picList)
            

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
    
}

private extension CODPersonDetailVC{
    
    //发送消息
    @objc func sendMessage() {
        
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
    
    func createSuspenView() {
        
//        let view = UIView.init(frame: CGRect.init(x: KScreenWidth-85, y: 40, width: 70, height: 190))
//        tableView.addSubview(view)
//        let window = UIApplication.shared.keyWindow
        let btnArr = [createGroupBtn, takePhoneBtn, chatBtn]
        self.view.addSubviews(btnArr)
//        view.addSubview(createGroupBtn)
//        view.addSubview(takePhoneBtn)
//        view.addSubview(chatBtn)
        
        createGroupBtn.snp.makeConstraints { (make) in
            make.top.equalTo(46)
            make.right.equalTo(-5)
            make.width.height.equalTo(70)
        }
        
        takePhoneBtn.snp.makeConstraints { (make) in
            make.top.equalTo(createGroupBtn.snp.bottom).offset(-10)
            make.right.equalTo(createGroupBtn)
            make.width.height.equalTo(70)
        }
        
        chatBtn.snp.makeConstraints { (make) in
            make.top.equalTo(takePhoneBtn.snp.bottom).offset(-10)
            make.right.equalTo(createGroupBtn)
            make.width.height.equalTo(70)
        }
        
    }
    
    @objc func createGroupAction() {
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
//            let baseNavCtl = ctl?.getViewControllerWith(index: 0) as? BaseNavigationController
//            let chatCtl = baseNavCtl?.children[0]
            //获取pop之后的ChatviewController
            ctl?.navigationController?.pushViewController(msgCtl, animated: true)
        }
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
    @objc func takePhoneAction() {
        self.vioceCall()
    }
    
    @objc func chatAction() {
        let msgCtl = MessageViewController()
        msgCtl.toJID = contactModel.jid
        msgCtl.chatId = contactModel.rosterID
        msgCtl.isMute = contactModel.mute
        msgCtl.title = contactModel.getContactNick()
        guard let nav = self.navigationController, let rootVC = nav.viewControllers.first else {
            return
        }
        nav.setViewControllers([rootVC,msgCtl], animated: true)
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
                                  "memberList":[contactModel.jid],
                                  "chatType":"1",
                                  "roomID":"0",
                                  "msgType":COD_call_type_voice]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func pushSetContactInfoVC() {
        let contactInfoVC = CODEditRemarksVC()
        contactInfoVC.model = self.contactModel
        contactInfoVC.callBack = { [weak self] in
            guard let self = self else {
                return
            }
            self.configView()
            if self.updateMemberInfoBlock != nil {
                self.updateMemberInfoBlock!()
            }
        }
        self.navigationController?.pushViewController(contactInfoVC, animated: true)
    }
    
    func configView() {
        if let contactModel = CODContactRealmTool.getContactByJID(by: self.contactModel.jid) {
            self.contactModel = contactModel
            headerView.userAvatar = contactModel.userpic
            if showType == .common {
                if contactModel.nick.count > 0 {
                    headerView.nameString = contactModel.nick
//                    headerView.nickNameString = "昵称：\(contactModel.name)"
                    headerView.nickNameString = "\(NSLocalizedString("昵称：", comment: ""))\(contactModel.name)"
                }else{
                    headerView.nameString = contactModel.name
                    headerView.nickNameString = nil
                }
            }else{
                if contactModel.nick.count > 0 {
                    headerView.nameString = contactModel.nick
//                    headerView.nickNameString = "昵称：\(contactModel.name)"
                    headerView.nickNameString = "\(NSLocalizedString("昵称：", comment: ""))\(contactModel.name)"
                    headerView.height = 90
                    if let groupNick = groupNick {
//                        headerView.groupNickString = "群昵称：\(groupNick)"
                        headerView.groupNickString = "\(NSLocalizedString("群昵称：", comment: ""))\(groupNick)"
                        headerView.height = 108
                    }
                    
                }else{
                    headerView.height = 90
                    headerView.nameString = contactModel.name
                    if let groupNick = groupNick {
//                        headerView.groupNickString = "群昵称：\(groupNick)"
                        headerView.groupNickString = "\(NSLocalizedString("群昵称：", comment: ""))\(groupNick)"
                    }
                    headerView.nickNameString = nil
                }
            }
            
            self.createDataSource()
            tableView.reloadData()
        }
    }
}

extension CODPersonDetailVC:UITableViewDelegate,UITableViewDataSource{
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODMessageDetailCell.self, forCellReuseIdentifier: "CODMessageDetailCellID")
        tableView.register(CODMessageDetailImageCell.self, forCellReuseIdentifier: "CODMessageDetailImageCellID")
        tableView.register(CODMessageDetailSwitchCell.self, forCellReuseIdentifier: "CODMessageDetailSwitchCellID")
        tableView.register(CODLongLongTextCell.self, forCellReuseIdentifier: "CODLongLongTextCellID")
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
            cell?.onBlock = {  isOn -> () in
                model.action.switchButtonAction?(isOn)
            }
            cell?.iconView.layer.cornerRadius = 0.0
            model.$isOn
                .filterNil()
                .bind(to: cell!.switchBtn.rx.isOn)
                .disposed(by: cell!.rx.prepareForReuseBag)
            
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
        } else if case .longTextType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODLongLongTextCellID", for: indexPath) as? CODLongLongTextCell
            if cell == nil{
                cell = CODLongLongTextCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODLongLongTextCellID")
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
            cell?.subTitle = model.subTitle
            cell?.imageStr = model.iconName
            return cell!
        } else if case .custom(cellType: let cellType) = model.type, cellType == CODPresenDetailIntroCell.self {
            
            let cell = tableView.dequeueReusableCell(withClass: CODPresenDetailIntroCell.self, for: indexPath)
            cell.introLabel.text = model.title
            return cell
            
        } else if case .custom(cellType: let cellType) = model.type, cellType == CODMomentsTableVCell.self {
            
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
            if indexPath.section == 0 {
                cell?.selectionStyle = .none
            }else{
                cell?.selectionStyle = .gray
            }
            
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
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 43
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectChatRow(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
}

extension CODPersonDetailVC: XMPPStreamDelegate {
    
    fileprivate func burnSetting() {
        //阅后即焚
        burnView = CODBurnSettingView.init(frame: self.view.frame)
        burnView.delegate = self
        burnView.defaultSelectRow = self.convertBurnStr(burn: self.contactModel?.burn ?? 0).1
        burnView.showAlert()
    }
    
    func selectChatRow(indexPath: IndexPath){
        self.dataSource[indexPath.section][indexPath.row].action.didSelected?()
    }
    
    func deleteAllHistory() {
        LPActionSheet.show(withTitle: String.init(format: "确定清除当前对话的历史记录?"), cancelButtonTitle: "取消", destructiveButtonTitle: "确定", otherButtonTitles: []) { (actionSheet, index) in
            
            if index == -1 {
                if let block = self.deleteAllHistoryBlock {
                    block()
                }else{
                    
                    CustomUtil.clearChatRecord(chatId: self.rosterId) { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                    
                        CODChatListRealmTool.deleteChatListHistory(by: self.rosterId)
                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                    }
                    
//                    if let chatModel = try! Realm.init().object(ofType: CODChatListModel.self, forPrimaryKey: self.rosterId){
//                        if let chatHistory = chatModel.chatHistory {
//                            try! Realm.init().write {
//                                for message in chatHistory.messages{
//                                    try! Realm.init().delete(message)
//                                }
//                                chatHistory.messages.removeAll()
//                                chatModel.count = 0
//                                chatModel.lastDateTime = "0"
//                                chatModel.isShowBurned = false
//                            }
//                        }
//                        //通知去聊天列表中更新数据
//                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
//                    }
                }
            }
        }
    }
    
    func pushToTogetherVC() {
        let vc = CODSavedGroupChatVC()
        vc.type = .togetherGroup
        vc.jid = contactModel.jid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushToMomentsVC() {
        let vc = CODDiscoverPersonalListVC(jid: contactModel.jid)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushToShareMediaVC() {
        let vc = SharedMediaFileViewController.init(nibName: "SharedMediaFileViewController", bundle: nil)
        vc.title = NSLocalizedString("共享媒体", comment: "")
        vc.chatId = self.rosterId
        if let listModel = CODChatListRealmTool.getChatList(id: self.contactModel.rosterID) {
            vc.list = listModel.chatHistory?.messages
            
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func sendContactCard() {
        let chooseVC = CODChooseChatListVC()
        chooseVC.choosePersonBlock = { [weak self] (contactModel) in

            guard let self = self else {
                return
            }
            if let fromContactModel = CODContactRealmTool.getContactByJID(by: self.contactModel.jid) {
                self.sendCard(toContactModel: contactModel, orGroupModel: nil, orChannelModel: nil, orChatListModel: nil, fromContactModel: fromContactModel)
            }
        }
        
        chooseVC.chooseGroupBlock = { [weak self] (groupModel) in
            
            guard let self = self else {
                return
            }
            if let fromContactModel = CODContactRealmTool.getContactByJID(by: self.contactModel.jid) {
                self.sendCard(toContactModel: nil, orGroupModel: groupModel, orChannelModel: nil, orChatListModel: nil, fromContactModel: fromContactModel)
            }
        }
        
        chooseVC.chooseChannelBlock = { [weak self] (channelModel) in
            
            guard let self = self else {
                return
            }
            if let fromContactModel = CODContactRealmTool.getContactByJID(by: self.contactModel.jid) {
                self.sendCard(toContactModel: nil, orGroupModel: nil, orChannelModel: channelModel, orChatListModel: nil, fromContactModel: fromContactModel)
            }
        }
        
        chooseVC.chooseChatListBlock = { [weak self] (chatListModel) in
            
            guard let self = self else {
                return
            }
            if let fromContactModel = CODContactRealmTool.getContactByJID(by: self.contactModel.jid) {
                self.sendCard(toContactModel: nil, orGroupModel: nil, orChannelModel: nil, orChatListModel: chatListModel, fromContactModel: fromContactModel)
            }
        }
        
        self.navigationController?.pushViewController(chooseVC)
    }
    
    func sendCard(toContactModel: CODContactModel?, orGroupModel: CODGroupChatModel?, orChannelModel: CODChannelModel?, orChatListModel: CODChatListModel?, fromContactModel: CODContactModel) {
        let msgIDTemp = UserManager.sharedInstance.getMessageId()
        //发送消息
        if let toContactModel = toContactModel {
            let model = CODMessageModelTool.default.createBusinessCardModel(msgID: msgIDTemp, toJID: toContactModel.jid, username: fromContactModel.jid , name: fromContactModel.name, userdesc: fromContactModel.userdesc, userpic: fromContactModel.userpic, jid: fromContactModel.jid, gender: fromContactModel.gender, chatType: .privateChat, roomId: nil, chatId: toContactModel.rosterID, burn: toContactModel.burn)
            CODMessageSendTool.default.sendMessage(messageModel: model)
            //添加消息到数据库
            self.insertChatHistory(message: model, contact: toContactModel)
        }
        
        if let orGroupModel = orGroupModel {
            let model = CODMessageModelTool.default.createBusinessCardModel(msgID: msgIDTemp, toJID: orGroupModel.jid, username: fromContactModel.jid , name: fromContactModel.name, userdesc: fromContactModel.userdesc, userpic: fromContactModel.userpic, jid: fromContactModel.jid, gender: fromContactModel.gender, chatType: .groupChat, roomId: "\(orGroupModel.roomID)", chatId: orGroupModel.roomID, burn: orGroupModel.burn.int ?? 0)
            CODMessageSendTool.default.sendMessage(messageModel: model)
            //添加消息到数据库
            self.insertChatHistory(message: model, group: orGroupModel)
        }
        
        if let channel = orChannelModel {
            let model = CODMessageModelTool.default.createBusinessCardModel(msgID: msgIDTemp, toJID: channel.jid, username: fromContactModel.jid , name: fromContactModel.name, userdesc: fromContactModel.userdesc, userpic: fromContactModel.userpic, jid: fromContactModel.jid, gender: fromContactModel.gender, chatType: .channel, roomId: "\(channel.roomID)", chatId: channel.roomID, burn: channel.burn.int ?? 0)
            CODMessageSendTool.default.sendMessage(messageModel: model)
            //添加消息到数据库
            self.insertChatHistory(message: model, channel: channel)
        }
        
        if let orChatListModel = orChatListModel {
            
            switch orChatListModel.chatTypeEnum {
            case .groupChat:
                guard let group = orChatListModel.groupChat else {
                    return
                }
                let model = CODMessageModelTool.default.createBusinessCardModel(msgID: msgIDTemp, toJID: group.jid, username: fromContactModel.jid , name: fromContactModel.name, userdesc: fromContactModel.userdesc, userpic: fromContactModel.userpic, jid: fromContactModel.jid, gender: fromContactModel.gender, chatType: .groupChat, roomId: "\(group.roomID)", chatId: group.roomID, burn: group.burn.int ?? 0)
                CODMessageSendTool.default.sendMessage(messageModel: model)
                //添加消息到数据库
                self.insertChatHistory(message: model, group: group)
                break
            case .channel:
                guard let channel = orChatListModel.channelChat else {
                    return
                }
                let model = CODMessageModelTool.default.createBusinessCardModel(msgID: msgIDTemp, toJID: channel.jid, username: fromContactModel.jid , name: fromContactModel.name, userdesc: fromContactModel.userdesc, userpic: fromContactModel.userpic, jid: fromContactModel.jid, gender: fromContactModel.gender, chatType: .channel, roomId: "\(channel.roomID)", chatId: channel.roomID, burn: channel.burn.int ?? 0)
                CODMessageSendTool.default.sendMessage(messageModel: model)
                //添加消息到数据库
                self.insertChatHistory(message: model, channel: channel)
                break
                
            case .privateChat:
                guard let contact = orChatListModel.contact else {
                    return
                }
                let model = CODMessageModelTool.default.createBusinessCardModel(msgID: msgIDTemp, toJID: contact.jid, username: fromContactModel.jid , name: fromContactModel.name, userdesc: fromContactModel.userdesc, userpic: fromContactModel.userpic, jid: fromContactModel.jid, gender: fromContactModel.gender, chatType: .privateChat, roomId: nil, chatId: contact.rosterID, burn: contact.burn)
                CODMessageSendTool.default.sendMessage(messageModel: model)
                
                //添加消息到数据库
                self.insertChatHistory(message: model, contact: contact)
                
                CODMessageSendTool.default.postAddMessageToView(messageID: model.msgID, isNeedAddToDB: false)
                break
            }
            
        }
        

    }
    
    func deleteContactAction() {
        
        LPActionSheet.show(withTitle: String.init(format: NSLocalizedString("删除“%@”联系人后，将不会出现在联系人列表", comment: ""), self.contactModel!.nick.count != 0 ? self.contactModel!.nick : self.contactModel!.name), cancelButtonTitle: "取消", destructiveButtonTitle: "删除联系人", otherButtonTitles: []) { [weak self] (actionSheet, index) in
            
            guard let self = self else {
                return
            }
            
            print(index)
            if index == -1 {
                let  dict:NSDictionary = ["name":COD_deleteRoster,
                                          "requester":UserManager.sharedInstance.jid,
                                          "receiver":self.contactModel.jid]
                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_roster, actionDic: dict)
                XMPPManager.shareXMPPManager.xmppStream.send(iq)
            }
            
        }
    }
    
    func sendIQ(action: IQAction,isOn:Bool) {
        
        var dict:NSDictionary? = [:]
        
        switch action {
        case .stickytop:
            dict = self.dictionaryWithChangeMute(typeStr: COD_Stickytop, isOn: isOn)
        case .mute:
            dict = self.dictionaryWithChangeMute(typeStr: COD_Mute, isOn: !isOn)
        case .blacklist:
            if let model = self.contactModel {
                dict = self.dictionaryWithChangeMute(typeStr: COD_Blacklist, isOn: isOn)
                
            } else {
                return
            }
        default:
            return
        }
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict!)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func dictionaryWithChangeMute(typeStr: String, isOn: Bool) -> NSDictionary? {
        let dict = ["name":COD_changeChat,
                    "requester":UserManager.sharedInstance.jid,
                    "itemID":self.rosterId,
                    "setting":[typeStr:isOn]] as [String : Any]
        return dict as NSDictionary
    }
    
    
    //MARK: -------------------- 接收IQ
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { [weak self] (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            guard let self = self else {
                return
            }
            
            if (actionDict["name"] as? String == COD_ChatSetting) {
                if !(infoDict["success"] as! Bool){
                    CODProgressHUD.showErrorWithStatus("好友设置获取失败，请稍后重试！")
                }else{
                    if let setting = infoDict["setting"] as? NSDictionary {
                        let contactModel = CODContactModel()
                        contactModel.jsonModel = CODContactHJsonModel.deserialize(from: setting)
//                        contactModel.loginStatus = self.contactModel.loginStatus
//                        contactModel.lastlogintime = self.contactModel.lastlogintime
                        contactModel.isValid = true
                        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: contactModel.userpic, complete: nil)
                        CODContactRealmTool.insertContact(by: contactModel)
                        
                        var name = contactModel.nick
                        
                        if name.count <= 0 {
                            name = contactModel.name
                        }
                        
                        let person = CODPersonInfoModel.createModel(jid: contactModel.jid, name: name)
                        person.addToDB()
                        
                        if let chatListModel = CODChatListRealmTool.getChatList(id: contactModel.rosterID) {
                            try! Realm.init().write {
                                chatListModel.title = contactModel.getContactNick()
                            }
                        }
                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                        
                        self.configView()
                        
                        if let groupMemberList = CODGroupMemberRealmTool.getMembersByJid(contactModel.jid) {
                            if groupMemberList.count > 0 {
                                for member in groupMemberList {
                                    try! Realm.init().write {
                                        member.userdesc = contactModel.userdesc
                                        member.name = contactModel.name
                                        member.gender = contactModel.gender
                                        member.pinYin = contactModel.pinYin
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            /*
            if (actionDict["name"] as? String == COD_GetStatus){
                if let isSuccess = infoDict["success"] as? Bool {
                    guard isSuccess else {
                        return
                    }
                    if let dataDic = infoDict.object(forKey: "data") as? NSDictionary,
                        let lastloginTime = dataDic.object(forKey: "lastloginTime") as? Int,
                        let status = dataDic.object(forKey: "status") as? String,
                        let lastLoginTimeVisible = dataDic.object(forKey: "lastLoginTimeVisible") as? Bool
                    {
                        try! Realm.init().write {
                            self.contactModel.lastlogintime = lastloginTime
                            self.contactModel.loginStatus = status
                            self.contactModel.lastLoginTimeVisible = lastLoginTimeVisible
                        }
                    }
                }
            }
            */
            
            if (actionDict["name"] as? String == COD_changeChat){ //单聊设置
                
                if !(infoDict["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus("设置失败")
                    return
                }
                let dict = actionDict["setting"] as! NSDictionary
                if let result = dict["stickytop"] as? Bool{
                    self.updateSourceData(action: .stickytop, result: result)
                }else if let result = dict["mute"] as? Bool{
                    self.updateSourceData(action: .mute, result: result)
                }else if let result = dict["blacklist"] as? Bool{
                    self.updateSourceData(action: .blacklist, result: result)
                }else if let result = dict["burn"] as? Int{
                    self.updateBurn(burn: result)
                }
            }
            
            if (actionDict["name"] as? String == COD_deleteRoster) { //删除好友
                if !(infoDict["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus("设置失败")
                    return
                }
      
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
        
        return true
        
    }
    
    func updateSourceData(action: IQAction, result: Bool){
        if let model = self.contactModel {
            try! Realm.init().write {
                switch action {
                case .stickytop:
                    model.stickytop = result
                                            if let chatListModel = CODChatListRealmTool.getChatList(id: model.rosterID) {
                                                chatListModel.stickyTop = result
                                            }
                    stickytopModel?.isOn = result
                    
                case .mute:
                    model.mute =  result
                    muteModel?.isOn = !result
                    
                case .blacklist:
                    model.blacklist =  result
                    blacklistModel?.isOn = result
                    self.createGroupBtnSetHidden(hidden: result, isAnimation: true)
                    
                }
                
            }
        }
        
//        var cellModel = self.dataSource[section][row]
//        if section == 3+telSectionCount+descSectionCount && row == 1 {
//            cellModel.isOn = !result
//        }else{
//            cellModel.isOn = result
//        }
//        self.dataSource[section][row] = cellModel
//        self.tableView.reloadData()
        
        //通知去聊天列表中更新数据
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
    }
    
    func updateBurn(burn: Int){
        
        if let model = self.contactModel {
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
    
    @objc public func tapMessageView(gestureRecognizer:UITapGestureRecognizer){
        let url =  URL.init(string: (self.contactModel.userpic.getHeaderImageFullPath(imageType: 2)))
        SDImageCache.shared.removeImageFromDisk(forKey: url?.absoluteString)
        if let url = url {
            SDImageCache.shared.removeImageFromDisk(forKey: CODImageCache.default.getCacheKey(url: url))
        }
        
//        CustomUtil.removeImageCahch(imageUrl: self.contactModel.userpic.getHeaderImageFullPath(imageType: 2))
        let photoIndex: Int = 0
        let imageData: YBIBImageData = YBIBImageData()
//        imageData.projectiveView = self.headerView.iconImageView
        imageData.imageURL = url
        let browser:YBImageBrowser =  YBImageBrowser()
        browser.dataSourceArray = [imageData]
        browser.currentPage = photoIndex
        browser.show()
    }
    
    func createGroupBtnSetHidden(hidden: Bool, isAnimation: Bool) {
        if hidden {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else {
                    return
                }
                self.takePhoneBtn.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(46) //104
                    make.right.equalToSuperview().offset(-5)
                    make.width.height.equalTo(70)
                }
                
                self.chatBtn.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.takePhoneBtn.snp.bottom).offset(-10)
                    make.right.equalTo(self.createGroupBtn)
                    make.width.height.equalTo(70)
                }
                if isAnimation {
                    self.view.layoutIfNeeded()
                }
                
            }
        }else{
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else {
                    return
                }
                self.createGroupBtn.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(46) //104
                    make.right.equalToSuperview().offset(-5)
                    make.width.height.equalTo(70)
                }
                
                self.takePhoneBtn.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.createGroupBtn.snp.bottom).offset(-10)
                    make.right.equalTo(self.createGroupBtn)
                    make.width.height.equalTo(70)
                }
                
                self.chatBtn.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.takePhoneBtn.snp.bottom).offset(-10)
                    make.right.equalTo(self.createGroupBtn)
                    make.width.height.equalTo(70)
                }
                
                if isAnimation {
                    self.view.layoutIfNeeded()
                }
            }
        }
        createGroupBtn.isHidden = hidden
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
    
    func insertChatHistory(message :CODMessageModel, channel: CODChannelModel) {
        
        if let chatListModel = CODChatListRealmTool.getChatList(id: channel.roomID){
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
            chatHistoryModel.id = channel.roomID
            chatHistoryModel.messages.append(message)
            
            let chatListModel = CODChatListModel()
            if let group = CODChannelModel.getChannel(by: channel.roomID) {
                chatListModel.id = group.roomID
                chatListModel.icon = group.grouppic
                chatListModel.chatTypeEnum = .channel
                chatListModel.lastDateTime = message.datetime
                chatListModel.channelChat = group
                chatListModel.jid = group.jid
                chatListModel.chatHistory = chatHistoryModel
                chatListModel.title = group.getGroupName()
                chatListModel.stickyTop = group.stickytop
            }
            CODChatListRealmTool.insertChatList(by: chatListModel)
        }
    }
    
}

extension CODPersonDetailVC: BurnSettingDelegate {
    func didSelectRow(burnDelayDic: Dictionary<String, Any>) {
        guard let model = CODContactRealmTool.getContactById(by: self.rosterId) else {
            return
        }
        if model.burn == burnDelayDic["burn"] as! Int {
            return
        }
        let dict:NSMutableDictionary = NSMutableDictionary.init(dictionary: ["requester":UserManager.sharedInstance.jid,"itemID":self.rosterId,"setting":["burn":burnDelayDic["burn"]]])
        dict.setValue(COD_changeChat, forKey: "name")
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
}


