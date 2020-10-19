    //
    //  CODMessageDetailVC.swift
    //  COD
    //
    //  Created by 1 on 2019/3/11.
    //  Copyright © 2019 XinHoo. All rights reserved.
    //

    import UIKit
    import SwiftyJSON
    import RxSwift
    import RxCocoa
    import RxRelay


    enum CODMessageDetailVCType: Int {
        case groupChat  = 1
        case commonChat = 5
    }

    class CODMessageDetailVC: BaseViewController {
        
        //    typealias UpdateGroupMemberBlock = () -> Void
        //    public var updateGroupMemberBlock: UpdateGroupMemberBlock?
        
        typealias DeleteAllHistoryBlock = () -> Void
        public var deleteAllHistoryBlock: DeleteAllHistoryBlock?
        
        typealias UpdateGroupAvatarBlock = () -> Void
        public var updateGroupAvatarBlock: UpdateGroupAvatarBlock?
        
        public var groupMembers = List<CODGroupMemberModel>()
        
        var isClickFinish = false
        
        var originalGroupName: String?
        
        public var chatId: Int = 0
        
        public var contactModel: CODContactModel? = nil
        public var groupChatModel: CODGroupChatModel?  = nil
        
        //用于转让群主时或
        public var groupManager :CODGroupMemberModel?
        
        var groupMemberCells: [CODCellModel] = []
        
        var section1: [CODCellModel] = []
        var section2: [CODCellModel] = []
        var section3: [CODCellModel] = []
        
        var isAdmin = false
        var myPower: Int = 30
        
        //    var isEdit: Bool = false
        
        var noticeModel: CODNoticeContentModel?
        
        var sectionAddition = 0
        var memberSectionAddition = 1
        var showMemberFlag = false
        
        private var cropImage: UIImage?
        private var isnNeedCrop: Bool = false
        
        var groupNickNameModel: CODCellModel?
        var groupNoticeCellModel: CODCellModel?
        var groupBurnCellModel: CODCellModel?
        var groupShownameCellModel: CODCellModel?
        var groupStickytopCellModel: CODCellModel?
        var groupMuteCellModel: CODCellModel?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.setBackButton()
            
            XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: .messageQueue)
            
            self.navigationItem.title = NSLocalizedString("群组信息", comment: "")
            
            self.getGroupInfo()
            
            self.mySetSearchRightButton()
            
            self.setUpUI()
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateGroupMember), name: NSNotification.Name.init(rawValue: kNotificationUpdateGroupMember), object: nil)
            
            NotificationAction.default.addTarget(target: self, body: COD_KickOut) { [weak self] (model) in
                guard let `self` = self else { return }
                self.deleteMembers(model)
            }
            
            NotificationAction.default.addTarget(target: self, body: COD_SignOut) { [weak self] (model) in
                guard let `self` = self else { return }
                self.deleteMembers(model)
            }
            
            NotificationAction.default.addTarget(target: self, body: COD_InvitJoin) { [weak self] (model) in
                guard let `self` = self else { return }
                self.addMembers(model)
            }
            
            NotificationAction.default.addTarget(target: self, body: COD_QrInvitJoin) { [weak self] (model) in
                guard let `self` = self else { return }
                self.addMembers(model)
            }
            
            NotificationAction.default.addTarget(target: self, body: COD_urlinvitjoin) { [weak self] (model) in
                guard let `self` = self else { return }
                self.addMembers(model)
            }
            
            NotificationAction.default.addTarget(target: self, body: COD_SetSignOut) { [weak self] (jsonModel) in
                self?.navigationController?.popToRootViewController(animated: true)
            }

        }
        
        public var detailType: CODMessageDetailVCType = .commonChat
        
        private var dataSource: Array = [[CODCellModel]]()
        
        
        fileprivate lazy var tableView:UITableView = {
            let tabelView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
            tabelView.estimatedRowHeight = 48
            tabelView.rowHeight = UITableView.automaticDimension
            tabelView.separatorStyle = .none
            tabelView.backgroundColor = UIColor.clear
            tabelView.delegate = self
            tabelView.dataSource = self
            ///注册单元格
            self.registerCellClassForTableView(tableView: tabelView)
            return tabelView
        }()
        
        lazy var footerView: UIView = {
            let footerV = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 51))
            return footerV
        }()
        
        lazy var burnView: CODBurnSettingView = {
            let burnv = CODBurnSettingView.init(frame: CGRect.zero)
            return burnv
        }()
        
        func mySetSearchRightButton() {
            
            if groupChatModel?.isICanCheckUserInfo() ?? true == false {
                return
            }
            
            self.setRightButton()
            rightButton.setImage(UIImage(named: "member_search_icon"), for: UIControl.State.normal)
        }
        
        func mySetRightTextButton() {
            self.setRightTextButton()
            self.rightTextButton.setTitle("完成", for: UIControl.State.normal)
            self.rightTextButton.setTitleColor(UIColor.init(hexString: kBlueTitleColorS), for: UIControl.State.normal)
            self.rightTextButton.isEnabled = false
        }
        
        func deleteMembers(_ model: CODMessageHJsonModel) {
            
            if self.showMemberFlag == false {
                return
            }
            
            let memberSection = self.tableView.numberOfSections - 1
            
            DispatchQueue.groupMembersOnlineTimeQueue.async {
                
                var deleteIndexPaths: [IndexPath] = []
                var tempGroupMemberCells = self.groupMemberCells
                
                for member in model.settingJson["member"].arrayValue {
                    
                    let memberId = CODGroupMemberRealmTool.getMemberId(roomId: self.chatId, jid: member["jid"].stringValue)
                    
                    let index = self.groupMemberCells.firstIndex { (cellModel) -> Bool in
                        return cellModel.memberID == memberId
                    }
                    
                    tempGroupMemberCells.removeAll { (cellModel) -> Bool in
                        return cellModel.memberID == memberId
                    }
                    

                    if let index = index {
                        deleteIndexPaths.append(IndexPath(row: index, section: memberSection))
                    }
                    
                }
                
                dispatch_async_safely_to_main_queue {
                    
                    self.groupMemberCells = tempGroupMemberCells
                    self.dataSource[memberSection] = self.groupMemberCells
                    self.tableView.deleteRows(at: deleteIndexPaths, with: .none)
                    
                }
                
                
                
            }

        }
        
        func addMembers(_ model: CODMessageHJsonModel) {
            
            if self.showMemberFlag == false {
                return
            }
            
            let memberSection = self.tableView.numberOfSections - 1
            let memberCount = self.groupMemberCells.count
            
            
            DispatchQueue.groupMembersOnlineTimeQueue.async {
                
                var insertIndexPaths: [IndexPath] = []
                
                for (index, member) in model.settingJson["member"].arrayValue.enumerated() {
                    
                    if let memberModel = CODGroupMemberRealmTool.getMember(roomId: self.chatId, jid: member["jid"].stringValue) {
                        self.groupMemberCells.append(self.createMemberCellModel(member: memberModel))
                    }
                    
                    insertIndexPaths.append(IndexPath(row: memberCount + index, section: memberSection))

                }
                
                dispatch_async_safely_to_main_queue {
                    
                    self.dataSource[memberSection] = self.groupMemberCells
                    self.tableView.insertRows(at: insertIndexPaths, with: .none)
                    
                }

            }
            
            
            
            
            
        }
        
        override func navBackClick() {
            if let cell: CODGroupNameAndAvatarCell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? CODGroupNameAndAvatarCell {
                if cell.groupNameField.isEditing {
                    self.view.endEditing(true)
                    return
                }
            }
            self.burnView.dismissAlert()
            self.navigationController?.popViewController(animated: true)
        }
        
        override func navRightTextClick() {
            if let cell: CODGroupNameAndAvatarCell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? CODGroupNameAndAvatarCell {
                isClickFinish = true
                
                self.view.endEditing(true)
                
                guard let text = cell.groupNameField.text else{
                    cell.groupNameField.text = self.groupChatModel?.getGroupNameForDetailVC()
                    isClickFinish = false
                    return
                }
                
                if text == originalGroupName {
                    isClickFinish = false
                    return
                }
                
                if text.removeHeadAndTailSpacePro.count <= 0 {
                    cell.groupNameField.text = self.groupChatModel?.getGroupNameForDetailVC()
                    isClickFinish = false
                    return
                }
                
                if text.count > 50{
                    cell.groupNameField.text = self.groupChatModel?.getGroupNameForDetailVC()
                    CODProgressHUD.showErrorWithStatus("群组名称不能超过50个字符")
                    isClickFinish = false
                    return
                }
                
                if text.count <= 0 {
                    cell.groupNameField.text = self.groupChatModel?.getGroupNameForDetailVC()
                    isClickFinish = false
                    return
                }
                
                guard let groupModel = self.groupChatModel else {
                    isClickFinish = false
                    return
                }
                
                XMPPManager.shareXMPPManager.changeGroupChatName(roomId: groupModel.roomID, roomName: text, success: { [weak self] (successModel, nameStr) in
                    
                    guard let self = self, let groupModel = self.groupChatModel else {
                        return
                    }
                    self.isClickFinish = false
                    if nameStr == "editRoomName" {
                        self.rightTextButton.removeFromSuperview()
                        
                        print("设置群组名称成功")
                        cell.groupNameField.text = text
                        self.originalGroupName = text
                        
                        var cellModel = self.dataSource[0][0]
                        cellModel.title = text
                        self.dataSource[0][0] = cellModel
                        
                        CODGroupChatRealmTool.modifyGroupChatNameByRoomID(by: groupModel.roomID, newRoomName: text)
                        
                        //通知去聊天列表中更新数据
                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                        self.mySetSearchRightButton()
                    }
                    
                    }, fail: { (errorModel) in
                        self.isClickFinish = false
                        print("设置群组名称失败")
                        CODProgressHUD.showSuccessWithStatus(errorModel.msg)
                        cell.groupNameField.text = groupModel.getGroupNameForDetailVC()
                })
            }
            
        }
        
        override func navRightClick() {
            let ctl = CODSearchMemberVC()
            if let groupModel = self.groupChatModel {
                ctl.sourceDatas = groupModel.member.toArray()
            }
            
            self.navigationController?.pushViewController(ctl, animated: false)
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self, delegateQueue: DispatchQueue.messageQueue)
            
        }
        
        deinit {
            NotificationAction.default.removeTarget()
            //        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self, delegateQueue: DispatchQueue.messageQueue)
            print("CODMessageDetailVC销毁")
            
        }
    }

    extension CODGroupMemberModel {
        var userPowerString: String {
            switch self.userpower {
            case 10:
                return NSLocalizedString("群主", comment: "")
            case 20:
                return NSLocalizedString("管理员", comment: "")
            default:
                return ""
            }
        }
        
        var loginStatusAttribute: NSAttributedString {
            
            let result = CustomUtil.getOnlineTimeStringAndStrColor(with: self)
            return NSAttributedString(string: result.timeStr).colored(with: result.strColor)
            
        }
    }

    private extension CODMessageDetailVC {
        
        func createMemberCellModel(member: CODGroupMemberModel) -> CODCellModel {
            
            let placeHolder = member.userPowerString

            var model15 = self.createModel(title: member.getMemberNickName(), subTitle: "", placeholder: placeHolder, image: member.userpic, type: .memberType)
            
            model15.userType = member.userTypeEnum
            model15.pinYin = member.pinYin
            model15.memberID = member.memberId
            model15.action.didSelectedWithModel = { [weak self] cellModel in
                guard let `self` = self else { return }
                
                guard let model = CODGroupMemberRealmTool.getMemberById(cellModel.memberID) else {
                    return
                }
                
                
                if model.username.contains("cod_60000000") {
                    self.navigationController?.pushViewController(CODLittleAssistantDetailVC())
                    return
                }
                
                if model.jid == UserManager.sharedInstance.jid {
                    return
                }
                
                if let contactModel = CODContactRealmTool.getContactByJID(by: model.jid), contactModel.isValid == true  {
                    
                    CustomUtil.pushToPersonVC(contactModel: contactModel, memberModel: model, updateMemberInfoBlock: { [weak self] in
//                        self?.createMemberDataSources()
                    })
                    
                }else{
                    
                    if self.groupChatModel?.isICanCheckUserInfo() ?? true == false {
                        
                        let alertCtl = UIAlertController.init(title: NSLocalizedString("根据群管理设置，您无法查看他的个人信息", comment: ""), message: nil, preferredStyle: UIAlertController.Style.alert)
                        let action = UIAlertAction.init(title: "知道了", style: UIAlertAction.Style.default, handler: nil)
                        alertCtl.addAction(action)
                        self.present(alertCtl, animated: true, completion: nil)
                        return
                    }
                    
                    CustomUtil.pushToStrangerVC(type: .groupType, memberModel: model)
                }
            }
            
            
            if member.loginStatus.count > 0 {
                let result = CustomUtil.getOnlineTimeStringAndStrColor(with: member)
                model15.attributeSubTitle = NSAttributedString(string: result.timeStr).colored(with: result.strColor)
            }else{
                model15.attributeSubTitle = nil
            }
            
            return model15
            
            
        }
        
        func createMemberDataSources() {
            
            if groupChatModel?.isICanCheckUserInfo() ?? true == false {
                showMemberFlag = false
                return
            }
            
            DispatchQueue.groupMembersOnlineTimeQueue.async { [weak self] in
                
                guard let `self` = self else { return }
                
                if self.groupMemberCells.count > 0 {
                    //                self.dataSource.removeLast()
                    self.groupMemberCells.removeAll()
                }
                
                guard let groupChat = CODGroupChatRealmTool.getGroupChat(id: self.chatId) else { return }
                
                let onlineMembers = groupChat.member.getOnlineMembers().groupMemberSorted()
                let offlineMembers = groupChat.member.getOfflineMembers().groupMemberSorted()
                
                for member in onlineMembers {
                    self.groupMemberCells.append(self.createMemberCellModel(member: member))
                }
                
                for member in offlineMembers {
                    self.groupMemberCells.append(self.createMemberCellModel(member: member))
                }
                
                if self.memberSectionAddition != 0 {
                    var model = self.createModel(title: "添加成员", subTitle: "", placeholder: "", image: "groupmember_add", type: .baseType)
                    model.action.didSelected = { [weak self] in
                        guard let `self` = self else { return }
                        self.addMemberAction()
                    }
                    model.titleColor = UIColor.init(hexString: kBlueTitleColorS)
                    self.groupMemberCells.insert(model, at: 0)
                    
                    if self.memberSectionAddition == 2 {
                        var model1 = self.createModel(title: "删除成员", subTitle: "", placeholder: "", image: "groupmember_delete", type: .baseType)
                        model1.action.didSelected = { [weak self] in
                            guard let `self` = self else { return }
                            self.subtractMemberAction()
                        }
                        model1.titleColor = UIColor.init(hexString: kBlueTitleColorS)
                        self.groupMemberCells.insert(model1, at: 1)
                    }
                }
                
                DispatchQueue.main.sync {
                    
                    if self.showMemberFlag {
                        self.dataSource.removeLast()
                    }
                    
                    self.dataSource.append(self.groupMemberCells)
                    
                    if self.showMemberFlag {
                        self.tableView.reloadSections(IndexSet(integer: self.dataSource.count - 1), with: .automatic)
                    } else {
                        self.tableView.reloadData()
                    }
                    
                    
                    self.showMemberFlag = true
                    //                self.tableView.reloadData()
                }
                
                
            }
     
        }
        
        
        func getNickName() -> String {
            
            var nickName = UserManager.sharedInstance.nickname ?? ""
            if let username = UserManager.sharedInstance.loginName {
                let memberId = CODGroupMemberModel.getMemberId(roomId: self.chatId, userName: username)
                if let model = CODGroupMemberRealmTool.getMemberById(memberId) {
                    nickName = model.getMemberNickName()
                }
            }
            
            return nickName
            
        }
        
            func createSection2Data() {
                
                guard let groupChatModel = self.groupChatModel, self.groupChatModel?.isDelete != true else {
                         return
                     }
                
                let nickName = self.getNickName()
                
                self.groupNickNameModel = self.createModel(title: NSLocalizedString("我在本群的昵称", comment: ""), subTitle: nickName, placeholder: "", image: "", type: .baseType)
                groupNickNameModel?.action.didSelected = { [weak self] in
                    guard let `self` = self else { return }
                    let vc = CODGroupMyNickVC()
                    vc.titleStr = NSLocalizedString("我在本群的昵称", comment: "")
                    vc.tipsStr = "输入您在这个群里的昵称"
                    vc.fieldPlaceholder = NSLocalizedString("我在本群的昵称", comment: "")
                    vc.chatID = self.chatId
                    vc.defaultText = self.groupNickNameModel?.subTitle ?? ""
                    vc.successUpdateClose = {[weak self] (updateStr: String) in
                        
                        //                guard let tempSelf = self else{
                        //                    return
                        //                }
                        //                tempSelf.getLocalGroupInfo()
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                
                self.groupNoticeCellModel = self.createModel(title: "群公告", subTitle: groupChatModel.getGroupNoticeForDetailVC(), placeholder: "", image: "", type: .longTextType)
                groupNoticeCellModel?.action.didSelected = { [weak self] in
                    guard let `self` = self else { return }
                    let vc = CODGroupAnnouncementVC()
                    vc.groupChatId = self.chatId
                    vc.noticeContent = self.noticeModel
                    vc.myPower = self.myPower
                    vc.announceBlock = { [weak self] (announceStr: String) in
                        //                guard let tempSelf = self else {
                        //                    return
                        //                }
                        ////                model4.subTitle = announceStr
                        //                tempSelf.updateGroupNotice(noticeStr: announceStr)
                        //                tempSelf.getLocalGroupInfo()
                    }
                    self.navigationController?.pushViewController(vc)
                }
                
                
                section2 = [groupNickNameModel!, groupNoticeCellModel!]
                
                if self.isAdmin {
                    var model = self.createModel(title: NSLocalizedString("群管理", comment: ""), subTitle: "", placeholder: "", image: "", type: .baseType)
                    model.action.didSelected = { [weak self] in
                        guard let `self` = self else { return }
                        let ctl = CODGroupManageVC()
                        ctl.groupChatId = self.chatId
                        self.navigationController?.pushViewController(ctl, animated: true)
                    }
                    
                    section2.append(model)
                }
                
                if self.isAdmin || !groupChatModel.notinvite {
                    var model = self.createModel(title: "群二维码", subTitle: "", placeholder: "", image: "", type: .baseType)
                    model.action.didSelected = { [weak self] in
                        guard let `self` = self else { return }
                        let vc = CODMyQRcodeController()
                        vc.type = .groupType
                        vc.roomID = self.groupChatModel?.roomID
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                    section2.append(model)
                }
                
                var model5 = self.createModel(title: "分享媒体文件", subTitle: "", placeholder: "", image: "", type: .baseType)
                model5.action.didSelected = { [weak self] in
                    guard let `self` = self else { return }
                    let vc = SharedMediaFileViewController.init(nibName: "SharedMediaFileViewController", bundle: nil)
                    vc.title = NSLocalizedString("共享媒体", comment: "")
                    let listModel = CODChatListRealmTool.getChatList(id: self.chatId)
                    vc.list = listModel?.chatHistory?.messages
                    vc.chatId = self.chatId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                groupBurnCellModel = self.createModel(title: "阅后即焚", subTitle: self.convertBurnStr(burn: (self.groupChatModel?.burn)?.int ?? 0).0, placeholder: "", image: "", type: .baseType)
                groupBurnCellModel?.action.didSelected = { [weak self] in
                    guard let `self` = self else { return }
                    if self.isAdmin {
                        self.burnView = CODBurnSettingView.init(frame: self.view.frame)
                        self.burnView.delegate = self
                        self.burnView.defaultSelectRow = self.convertBurnStr(burn: (self.groupChatModel?.burn)?.int ?? 0).1
                        self.burnView.showAlert()
                    }else{
                        let alertCtl = UIAlertController.init(title: "你没有此权限", message: nil, preferredStyle: UIAlertController.Style.alert)
                        let action = UIAlertAction.init(title: "知道了", style: UIAlertAction.Style.default, handler: nil)
                        alertCtl.addAction(action)
                        self.present(alertCtl, animated: true, completion: nil)
                    }
                    
                }
                
                //        let model6 = self.createSwitchModel(title: "保存到群组", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: self.groupChatModel?.savecontacts ?? false, isEnable: true)
                groupShownameCellModel = self.createSwitchModel(title: "显示群组昵称", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: self.groupChatModel?.showname ?? false, isEnable: true)
                groupShownameCellModel?.action.switchButtonAction = { [weak self] isOn in
                    
                    guard let `self` = self else { return }
                    self.sendIQ(ctr: .showname, isOn: isOn)
                    
                }
                
                groupStickytopCellModel = self.createSwitchModel(title: "置顶聊天", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: self.groupChatModel?.stickytop ?? false, isEnable: true)
                groupStickytopCellModel?.action.switchButtonAction = { [weak self] isOn in
                    
                    guard let `self` = self else { return }
                    self.sendIQ(ctr: .stickytop, isOn: isOn)
                    
                }
                
                groupMuteCellModel = self.createSwitchModel(title: "消息通知", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: !(self.groupChatModel?.mute ?? false), isEnable: true)
                groupMuteCellModel?.action.switchButtonAction = { [weak self] isOn in
                    
                    guard let `self` = self else { return }
                    self.sendIQ(ctr: .mute, isOn: isOn)
                    
                }
                
                var mode10 = self.createModel(title: "清除聊天记录", subTitle: "", placeholder: "", image: "", type: .baseType)
                mode10.action.didSelected = { [weak self] in
                    guard let `self` = self else { return }
                    self.deleteAllHistory()
                }
                
                section2.append(contentsOf: [model5, groupBurnCellModel!,groupShownameCellModel!,groupStickytopCellModel!,groupMuteCellModel!,mode10])
        }
        
        func createGroupMemuDataSource() {
            
            if dataSource.count > 0 {
                
                if self.showMemberFlag {
                    dataSource.removeFirst((dataSource.count - 1))
                } else{
                    dataSource.removeAll()
                }

            }
            
            guard let groupChatModel = self.groupChatModel, self.groupChatModel?.isDelete != true else {
                return
            }
            originalGroupName = groupChatModel.getGroupNameForDetailVC()
            let model1 = self.createModel(title: groupChatModel.getGroupNameForDetailVC(), subTitle: "", placeholder: "", image: groupChatModel.grouppic, type: .headerType)
            
            section1 = [model1]
            
            if self.isAdmin {
                var model13 = self.createModel(title: "设置群组头像", subTitle: "", placeholder: "", image: "", type: .baseType)
                model13.titleColor = UIColor.init(hexString: kBlueTitleColorS)
                model13.action.didSelected = { [weak self] in
                    self?.showPhotoWay()
                }
                
                section1.append(model13)
            }
            
            dataSource.append(section1)
            
            createSection2Data()
                    
            dataSource.append(section2)
                    
            var model12 = self.createModel(title: "删除并退出", subTitle: "", placeholder: "", image: "", type: .deleteType)
            model12.action.didSelected = { [weak self] in
                guard let `self` = self else { return }
                let alertView = UIAlertController(title: nil, message: "删除并退出后，将不再接收此群组的信息", preferredStyle: UIAlertController.Style.actionSheet)
                let alertItem1 = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) {[weak self] (action) in
                    guard let self = self else {
                        return
                    }
                    
                    let paramDic :NSMutableDictionary = ["requester":"\(UserManager.sharedInstance.jid)","roomID": self.chatId]  as NSMutableDictionary
                    if self.groupMembers.count > 1 {
                        paramDic["name"] = COD_quitGroupChat
                    }else{
                        paramDic["name"] = COD_destroyRoom
                    }
                    let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_groupChat, actionDic: paramDic)
                    XMPPManager.shareXMPPManager.xmppStream.send(iq)
                }
                alertView.addAction(alertItem1)
                
                let alertItem2 = UIAlertAction(title: "取消", style: UIAlertAction.Style.default) {(action) in}
                alertView.addAction(alertItem2)
                
                self.present(alertView, animated: true, completion: nil)
            }
            section3 = [model12]
            dataSource.append(section3)
            
            groupInfoBind()
            
                
        }
        
        func createGroupDataSource() {
            
            if dataSource.count > 0 {
                dataSource.removeAll()
            }
            
            createGroupMemuDataSource()
            
            createMemberDataSources()
            
            self.tableView.reloadData()
        }
        
        func sortCellModelArr(_ array: Array<CODCellModel>) -> Array<CODCellModel> {
            //        var array = array.sorted(by: \.title, ascending: true)
            var array = array.sorted(by: \.pinYin, ascending: true)
            var symbolCellArr: Array<CODCellModel> = Array<CODCellModel>()
            for i in 0..<array.count {
                let member = array[i]
                var pinYin = member.pinYin
                let pinYinFirstStr = pinYin.slice(from: 0, to: 1)
                if pinYinFirstStr != "#" {
                    break
                }
                symbolCellArr.append(member)
            }
            if symbolCellArr.count > 0 {
                array.removeSubrange(0..<symbolCellArr.count)
                symbolCellArr = symbolCellArr.sorted(by: \.title, ascending: true)
                array.append(contentsOf: symbolCellArr)
            }
            return array
        }
        
        func getGroupInfo() {
            guard let groupChatModel = CODGroupChatRealmTool.getGroupChat(id: chatId) else {
                return
            }
            
            self.groupChatModel = groupChatModel
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            if delegate.isNetwork {
                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: groupChatModel.grouppic, complete: nil)
            }
            
            
            if let groupModel = self.groupChatModel {
                
                for member in groupModel.member {
                    // 判断自己是否管理员
                    if member.userpower < 30 {
                        if member.userpower == 10 {
                            self.groupManager = member
                        }
                        if member.username == UserManager.sharedInstance.loginName {
                            self.isAdmin = true
                            self.myPower = member.userpower
                            self.sectionAddition = 1
                            
                        }
                    }
                }

                self.groupMembers = groupModel.member
                if self.isAdmin {
                    self.memberSectionAddition = 2
                }else{
                    if groupChatModel.notinvite {
                        self.memberSectionAddition = 0
                    }else{
                        self.memberSectionAddition = 1
                    }
                }
            }
            
            //先展示本地数据
            self.createGroupDataSource()
            
            let paramDic: [String: Any] = ["requester":"\(UserManager.sharedInstance.jid)",
                "name": COD_groupSetting,
                "itemID": groupChatModel.roomID]
            
            XMPPManager.shareXMPPManager.getRequest(param: paramDic, xmlns: COD_com_xinhoo_setting) { [weak self] (result) in
                
                guard let `self` = self else { return }
                
                switch result {
                    
                case .success(let model):
                    
                    try! Realm.init().write {
                        self.groupChatModel?.setJsonModel(jsonModel: CODGroupChatHJsonModel.deserialize(from: model.dataJson?["setting"].dictionaryObject))
                    }
                    
                    if let listModel = CODChatListRealmTool.getChatList(id: self.chatId) {
                        try! Realm.init().write {
                            
                            if let stickytop =  self.groupChatModel?.stickytop {
                                listModel.stickyTop = stickytop
                            }
                        }
                    }
                    
                    self.noticeModel = CODNoticeContentModel.deserialize(from: model.dataJson?["setting"]["noticecontent"].dictionaryObject)
                    if let publisher = self.noticeModel?.pulisher {
                        if publisher.count <= 0 {
                            self.noticeModel = nil
                        }else{
                            try! Realm.init().write {
                                self.groupChatModel?.notice = self.noticeModel?.notice ?? ""
                            }
                        }
                    }
                    
                    //刷新外面的chatVC
                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                    
                    self.getGroupMembersOnlineTime()
                    
                case .failure(_):
                    break
                    
                }
                
            }
            
            
            
        }
        
        func groupInfoBind() {
            
            guard let groupChatModel = CODGroupChatRealmTool.getGroupChat(id: chatId) else {
                return
            }
            
            let nicknameObserver = groupChatModel.getMember(jid: UserManager.sharedInstance.loginName ?? "")?.rx.observe(\.nickname)
            
            let noticeObserver = Observable.from(object: groupChatModel, properties: ["notice"]).skip(1).map { $0.notice }.map { (value) -> String? in
                
                let count = value.count
                if count <= 0 {
                    
                    return "未设置"
                }else{
                    return value
                }
                
            }
            let burnObserver = groupChatModel.rx.observe(\.burn).skip(1).filterNil().map { [weak self] (value) -> String? in
                guard let `self` = self else { return "关闭" }
                return self.convertBurnStr(burn: value.int ?? 0).0
            }
            let shownameObserver = groupChatModel.rx.observe(\.showname).skip(1)
            let stickytopObserver = groupChatModel.rx.observe(\.stickytop).skip(1)
            let muteObserver = groupChatModel.rx.observe(\.mute).skip(1).map { (value) -> Bool? in
                return !(value ?? false)
            }
            
            
            
            
            noticeObserver.bind { [weak self] (value) in
                
                guard let `self` = self else { return }
                
                self.groupNoticeCellModel?.subTitle = value
                DispatchQueue.main.async {
                    self.reloadGroupNotice()
                }
                
            }
            .disposed(by: self.rx.disposeBag)

            if let nicknameObserver = nicknameObserver, let groupNickNameModel = self.groupNickNameModel {
                nicknameObserver.bind(to: groupNickNameModel.$subTitle).disposed(by: self.rx.disposeBag)
            }
            
            if let groupBurnCellModel = self.groupBurnCellModel {
                burnObserver.bind(to: groupBurnCellModel.$subTitle).disposed(by: self.rx.disposeBag)
            }
            
            if let groupShownameCellModel = self.groupShownameCellModel {
                shownameObserver.bind(to: groupShownameCellModel.$isOn).disposed(by: self.rx.disposeBag)
            }
            
            if let groupStickytopCellModel = self.groupStickytopCellModel {
                stickytopObserver.bind(to: groupStickytopCellModel.$isOn).disposed(by: self.rx.disposeBag)
            }
            
            if let groupMuteCellModel =  self.groupMuteCellModel {
                muteObserver.bind(to: groupMuteCellModel.$isOn).disposed(by: self.rx.disposeBag)
            }
            
                
            
        }
        
        func reloadGroupNotice() {
            

            if self.tableView.numberOfSections < 2 {
                return
            }
            
            self.tableView.reloadRows(at: [.init(row: 1, section: 1)], with: .none)
        }
        
        func getLocalGroupInfo(isUpdateMemberOnline: Bool = false) {
            guard let groupChatModel = CODGroupChatRealmTool.getGroupChat(id: chatId) else {
                return
            }
            
            self.groupChatModel = groupChatModel
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            if delegate.isNetwork {
                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: groupChatModel.grouppic, complete: nil)
            }
            
            
            if let groupModel = self.groupChatModel {
                
                
                for member in groupModel.member {
                    // 判断自己是否管理员
                    if member.userpower < 30 {
                        if member.userpower == 10 {
                            self.groupManager = member
                        }
                        if member.username == UserManager.sharedInstance.loginName {
                            self.isAdmin = true
                            self.myPower = member.userpower
                            self.sectionAddition = 1
                            
                        }
                    }
                }
                
                self.groupMembers = groupModel.member
                if self.isAdmin {
                    self.memberSectionAddition = 2
                }else{
                    if groupChatModel.notinvite {
                        self.memberSectionAddition = 0
                    }else{
                        self.memberSectionAddition = 1
                    }
                }
            }
            
        }
        
        func getGroupMembersOnlineTime() {
            CODGroupMemberOnlineManger.default.getGroupMembersOnlineTime(roomID: self.chatId.string)
        }
        
        
        @objc func updateGroupMember(notification: Notification) {
//            dispatch_async_safely_to_main_queue {
//                if let userInfo = notification.userInfo, let isUpdateMemberOnline = userInfo["isUpdateOnline"] as? Bool, isUpdateMemberOnline {
//
//                    self.getGroupMembersOnlineTime()
//
//                }else{
//                    self.createMemberDataSources()
//                }
//
//
//            }
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
            
            tableView.tableFooterView = self.footerView
            tableView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0.01))
            
            self.view.addSubview(tableView)
            tableView.snp.makeConstraints { (make) in
                make.left.right.top.equalTo(self.view)
                make.bottom.equalTo(self.view).offset(0)
            }
        }
        
        //    func setHeadViewData() {
        //        if (self.groupMembers.count) > 0 {
        //            headerView.setMembers(members: (self.groupMembers), isAdmin: self.isAdmin, notInvit: self.groupChatModel?.notinvite ?? false, type: self.detailType)
        //        }
        //    }
        
    }

    extension CODMessageDetailVC {
        func showMemberInformation(model: CODGroupMemberModel) {
            
            if model.username.contains("cod_60000000") {
                self.navigationController?.pushViewController(CODLittleAssistantDetailVC())
                return
            }
            
            if model.jid == UserManager.sharedInstance.jid || model.jid == UserManager.sharedInstance.loginName {
                let msgCtl = MessageViewController()
                msgCtl.chatType = .privateChat
                msgCtl.toJID = kCloudJid + XMPPSuffix
                msgCtl.chatId = CloudDiskRosterID
                msgCtl.title = NSLocalizedString("我的云盘", comment: "")
                self.navigationController?.pushViewController(msgCtl, animated: true)
                return
            }
            
            if let contactModel = CODContactRealmTool.getContactByJID(by: model.jid), contactModel.isValid == true  {
                
                CustomUtil.pushToPersonVC(contactModel: contactModel, memberModel: model)
                
            }else{
                
                CustomUtil.pushToStrangerVC(type: .groupType, memberModel: model)
            }
            
        }
        
        func addMemberAction() {
            
            guard let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId) else {
                return
            }
            
            let ctl = CreGroupChatViewController()
            
            ctl.ctlType = .addMember
            ctl.groupChatModel = groupModel
            //        }
            self.navigationController?.pushViewController(ctl, animated: true)
        }
        
        func subtractMemberAction() {
            
            guard let groupChatModel = self.groupChatModel else {
                return
            }
    //
            let memberTempArr = groupChatModel.member.filter("jid != '\(UserManager.sharedInstance.jid)' AND userpower > \(myPower)")
                    
            if groupChatModel.member.count <= 1 || memberTempArr.count <= 0 {
                CODProgressHUD.showErrorWithStatus("没有可移除的群成员")
            }else{
                
                guard let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId) else {
                    return
                }
                
                let ctl = CreGroupChatViewController()
                ctl.ctlType = .subtractMember
                ctl.groupChatModel = groupModel
                self.navigationController?.pushViewController(ctl, animated: true)
            }
        }
        
        /*
         func showMoreMembers() {
         let vc = CODGroupMembersVC()
         vc.chatId = self.chatId
         //        vc.setMembers(members: (self.groupMembers), isAdmin: self.isAdmin, notInvit: self.groupChatModel?.notinvite ?? false)
         vc.members = self.groupMembers
         vc.isAdmin = self.isAdmin
         vc.notInvit = self.groupChatModel?.notinvite ?? false
         self.navigationController?.pushViewController(vc, animated: true)
         }*/
        
        //    func reloadHeight(height: CGFloat) {
        //
        //        self.headerView.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: height)
        //        self.tableView.reloadData()
        //    }
        
        
    }

    extension CODMessageDetailVC: UITableViewDelegate,UITableViewDataSource{
        
        func registerCellClassForTableView(tableView:UITableView) {
            tableView.register(CODMessageDetailCell.self, forCellReuseIdentifier: "CODMessageDetailCellID")
            tableView.register(CODMessageDetailImageCell.self, forCellReuseIdentifier: "CODMessageDetailImageCellID")
            tableView.register(CODMessageDetailSwitchCell.self, forCellReuseIdentifier: "CODMessageDetailSwitchCellID")
            tableView.register(CODLongLongTextCell.self, forCellReuseIdentifier: "CODLongLongTextCellID")
            tableView.register(UINib.init(nibName: "CODGroupMemberAdvTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupMemberAdvTableViewCell")
            tableView.register(UINib.init(nibName: "CODGroupNameAndAvatarCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupNameAndAvatarCell")
        }
        
        public func numberOfSections(in tableView: UITableView) -> Int {
            return dataSource.count
        }
        
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            
            let  datas = dataSource[section]
            return datas.count
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
            let datas = dataSource[indexPath.section]
            let model = datas[indexPath.row]
            if case .switchType = model.type {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailSwitchCellID", for: indexPath) as? CODMessageDetailSwitchCell
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

                model.$isOn.filterNil()
                    .bind(to: cell!.switchBtn.rx.isOn)
                    .disposed(by: cell!.rx.prepareForReuseBag)
                
    //            model.isOn
    //            cell!.switchBtn.rx.isOn
                return cell!
            }else if case .imageType = model.type {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailImageCellID", for: indexPath) as? CODMessageDetailImageCell
                if indexPath.row == datas.count - 1 {
                    cell?.isLast = true
                }else{
                    cell?.isLast = false
                }
                cell?.cellType = .arrow
                cell?.title = model.title
                cell?.placeholer = model.placeholderString
                cell?.imageV = UIImage.init(named: model.iconName ?? "")
                return cell!
            }else if case .longTextType = model.type {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CODLongLongTextCellID", for: indexPath) as? CODLongLongTextCell
                if indexPath.row == datas.count - 1 {
                    cell?.isLast = true
                }else{
                    cell?.isLast = false
                }
                cell?.title = model.title
    //            cell?.subTitle = model.subTitle
                cell?.imageStr = model.iconName
                model.$subTitle
                    .bind(onNext: { [weak cell] (text) in
                        guard let cell = cell else { return }
                        cell.subTitle = text
                    })
                .disposed(by: cell!.rx.prepareForReuseBag)
                return cell!
            }else if case .headerType = model.type {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CODGroupNameAndAvatarCell", for: indexPath) as? CODGroupNameAndAvatarCell
                if indexPath.row == datas.count - 1 {
                    cell?.isLast = true
                }else{
                    cell?.isLast = false
                }
                if isAdmin {
                    cell?.isEdit = true
                }else{
                    cell?.isEdit = false
                }
                cell?.groupNameField.delegate = self
                cell?.selectAvatarCloser = {
                    let url =  URL.init(string: (model.iconName!.getHeaderImageFullPath(imageType: 2)))
                    SDImageCache.shared.removeImageFromDisk(forKey: url?.absoluteString)
                    if let url = url {
                        SDImageCache.shared.removeImageFromDisk(forKey: CODImageCache.default.getCacheKey(url: url))
                    }
                    
                    let photoIndex: Int = 0
                    let imageData: YBIBImageData = YBIBImageData()
                    //                imageData.projectiveView = cell?.avatarImgBtn
                    imageData.imageURL = url
                    let browser:YBImageBrowser =  YBImageBrowser()
                    browser.dataSourceArray = [imageData]
                    browser.currentPage = photoIndex
                    browser.show()
                    
                }
                cell?.textFieldDidEditChangeCloser = { [weak self] (textField: UITextField) in
                    guard let self = self else {
                        return
                    }
                    guard let text = textField.text else {
                        return
                    }
                    if text.removeHeadAndTailSpacePro.count > 0 {
                        self.rightTextButton.isEnabled = true
                    }else{
                        self.rightTextButton.isEnabled = false
                    }
                }
                cell?.selectionStyle = .none
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.iconName!) { [weak cell] (image) in
                    guard let cell = cell else { return }
                    cell.avatarImgBtn.setImage(image, for: .normal)
                }
                cell?.groupNameField.text = model.title
                
                return cell!
            }else if case .memberType = model.type {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CODGroupMemberAdvTableViewCell", for: indexPath) as? CODGroupMemberAdvTableViewCell
                if indexPath.row == datas.count - 1 {
                    cell?.isLast = true
                }else{
                    cell?.isLast = false
                }
                if indexPath.row == 0 {
                    cell?.isTop = true
                }else{
                    cell?.isTop = false
                }
                
                if let member = CODGroupMemberRealmTool.getMemberById(model.memberID) {
                    
//                    Observable.merge([
//                        member.rx.observe(\.name).mapTo(Void()),
//                        member.rx.observe(\.nickname).mapTo(Void()),
//                        member.rx.observe(\.userpower).mapTo(Void()),
//                        member.rx.observe(\.loginStatus).mapTo(Void()),
//                    ])
                    Observable.from(object: member)
                        .subscribe(onNext: { [weak cell, weak member] (_) in
                            guard let member = member, let cell = cell else { return }
                            cell.setData(title: member.getMemberNickName(), subTitle: member.loginStatusAttribute, placeholer: member.userPowerString)
                            }, onError: { (_) in
                                
                        })
                        .disposed(by: cell!.rx.prepareForReuseBag)
                    
                                    
                    
                }
                
                
                cell?.userType = model.userType
                _ = cell?.imgView.cod_loadHeader(url: URL(string: model.iconName!.getHeaderImageFullPath(imageType: 1)))

                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailCellID", for: indexPath) as? CODMessageDetailCell
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
                cell?.titleColor = model.titleColor
                cell?.placeholer = model.placeholderString
                cell?.subTitle = model.subTitle
                model.$subTitle
                    .bind(to: cell!.subTitleLab.rx.text)
                    .disposed(by: cell!.rx.prepareForReuseBag)
                cell?.imageStr = model.iconName
                cell?.isHiddenArrow = true
                return cell!
            }
            
            
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            return UIView()
        }
        
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            return UIView()
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if section == 0 {
                return 0
            }
            return 20
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return 0
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if let cell: CODGroupNameAndAvatarCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? CODGroupNameAndAvatarCell {
                if cell.groupNameField.isEditing {
                    self.view.endEditing(true)
                    return
                }
            }
            
            //        dataSource[indexPath.section][indexPath.row].action.didSelected?()
            
            let model = dataSource[indexPath.section][indexPath.row]
            
            model.action.didSelected?()
            
            model.action.didSelectedWithModel?(model)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }

    private extension CODMessageDetailVC{
        
        func deleteAllHistory() {
            LPActionSheet.show(withTitle: String.init(format: "确定清除当前对话的历史记录?"), cancelButtonTitle: "取消", destructiveButtonTitle: "确定", otherButtonTitles: []) { (actionSheet, index) in
                
                if index == -1 {
                    if let block = self.deleteAllHistoryBlock {
                        block()
                    }
                }
            }
        }
        
        func pushToComplaintVC() {
            self.navigationController?.pushViewController(CODComplaintVC())
        }
        
        @objc func updateGroupNotice(noticeStr: String) {
            if let groupModel = self.groupChatModel {
                try! Realm.init().write {
                    groupModel.notice = noticeStr
                }
            }
        }
        
        func updateSourceData(section: Int, row: Int, result: Bool){
            
            if let model = self.groupChatModel {
                try! Realm.init().write {
                    if section == 1 {
                        switch row {
                        case 5+sectionAddition :
                            model.showname = result
                        case 6+sectionAddition :
                            model.stickytop = result
                            if let chatListModel = CODChatListRealmTool.getChatList(id: model.roomID) {
                                chatListModel.stickyTop = result
                            }
                        case 7+sectionAddition :
                            model.mute =  result
                        default :
                            break
                        }
                    }
                }
            }
            
            var cellModel = self.dataSource[section][row]
            cellModel.isOn = result
            if section == 1 && row == 7+sectionAddition {
                cellModel.isOn = !result
            }else{
                cellModel.isOn = result
            }
            
            self.dataSource[section][row] = cellModel
            self.tableView.reloadRows(at: [.init(row: row, section: section)], with: .none)
            
            //通知去聊天列表中更新数据
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        }
        
        func resetSourceData(section: Int, row: Int){
            
            var cellModel = self.dataSource[section][row]
            guard let isOn = cellModel.isOn else{
                return
            }
            cellModel.isOn = isOn
            self.dataSource[section][row] = cellModel
            self.tableView.reloadRows(at: [.init(row: row, section: section)], with: .none)
            
            //通知去聊天列表中更新数据
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        }
        
        func updateBurn(section: Int, row: Int, burn: Int){
            if let model = self.groupChatModel {
                try! Realm.init().write {
                    model.burn = "\(burn)"
                    if let chatListModel = CODChatListRealmTool.getChatList(id: model.roomID) {
                        chatListModel.lastDateTime = "\(Date.milliseconds)"
                    }
                }
            }
            
            if let model = self.contactModel {
                try! Realm.init().write {
                    model.burn = burn
                    if let chatListModel = CODChatListRealmTool.getChatList(id: model.rosterID) {
                        chatListModel.lastDateTime = "\(Date.milliseconds)"
                    }
                }
            }
            
            var cellModel = self.dataSource[section][row]
            cellModel.subTitle = self.convertBurnStr(burn: burn).0
            self.dataSource[section][row] = cellModel
            self.tableView.reloadRows(at: [.init(row: row, section: section)], with: .none)
            
            //通知去聊天列表中更新数据
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
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



    extension CODMessageDetailVC {  //发送IQ

        
        enum IQControl {
            case showname
            case stickytop
            case mute
        }
        
        func sendIQ(ctr:IQControl, isOn:Bool) {
            
            var dict:NSDictionary? = [:]
            
            switch ctr {
            case .showname:
                dict = self.dictionaryWithChangeMute(typeStr: "showname", isGroup: true, isOn: isOn)
            case .stickytop:
                dict = self.dictionaryWithChangeMute(typeStr: "stickytop", isGroup: true, isOn: isOn)
            case .mute:
                dict = self.dictionaryWithChangeMute(typeStr: "mute", isGroup: true, isOn: !isOn)

            }
            
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict!)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
        }
        
        func dictionaryWithChangeMute(typeStr: String, isGroup: Bool, isOn: Bool) -> NSDictionary? {
            var dict = ["name":COD_changeGroup,
                        "requester":UserManager.sharedInstance.jid,
                        "itemID":self.chatId,
                        "setting":[typeStr:isOn]] as [String : Any]
            if !isGroup {
                dict["name"] = COD_changeChat
            }
            
            return dict as NSDictionary
        }
        
    }




    extension CODMessageDetailVC: XMPPStreamDelegate {
        func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
            
            CustomUtil.analyticxXML(iq: iq) {[weak self] (actionDic, infoDic) in
                guard let infoDic = infoDic else {
                    return
                }
                
                dispatch_sync_safely_to_main_queue {
                    
                    if (actionDic["name"] as? String == COD_changeGroup){ //群组设置
                        guard let success = infoDic["success"] as? Bool else{
                            return
                        }
                        guard let tempSelf = self else{
                            return
                        }
                        if !success {
                            
                            CODProgressHUD.showErrorWithStatus("设置失败")
                            let dict = actionDic["setting"] as! NSDictionary
                            if let _ = dict["mute"] as? Bool{
                                self?.groupMuteCellModel?.isOn = self?.groupMuteCellModel?.isOn
                            }else if let _ = dict["stickytop"] as? Bool{
                                self?.groupStickytopCellModel?.isOn = self?.groupStickytopCellModel?.isOn
                            }else if let _ = dict["showname"] as? Bool{
                                self?.groupShownameCellModel?.isOn = self?.groupShownameCellModel?.isOn
                            }else if let result = dict["burn"] as? Int{
                                tempSelf.updateBurn(section: 1, row: 4+tempSelf.sectionAddition, burn: result)
                            }
                            return
                        }
                        
                        let dict = actionDic["setting"] as! NSDictionary
                        if let result = dict["mute"] as? Bool{
                            self?.groupMuteCellModel?.isOn = !result
                        }else if let result = dict["stickytop"] as? Bool{
                            self?.groupStickytopCellModel?.isOn = result
                        }else if let result = dict["showname"] as? Bool{
                            self?.groupShownameCellModel?.isOn = result
                        }else if let result = dict["burn"] as? Int{
                            tempSelf.updateBurn(section: 1, row: 4+tempSelf.sectionAddition, burn: result)
                        }
                    }
                    
                    if actionDic["name"] as? String == COD_quitGroupChat || actionDic["name"] as? String == COD_destroyRoom {
                        guard let tempSelf = self else {
                            return
                        }
                        //                if let model = self.groupChatModel {
                        //                    try! Realm.init().write {
                        //                        model.isValid = false
                        //                        model.burn = ""
                        //                        model.stickytop = false
                        //                        model.mute = false
                        //                        model.savecontacts = false
                        //                    }
                        //                }
                        tempSelf.navigationController?.popToRootViewController(animated: true)
                        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(tempSelf, delegateQueue: DispatchQueue.messageQueue)
                        NotificationCenter.default.removeObserver(tempSelf)
                        //移除代理，是因为pop之后本VC不销毁，造成崩溃
                    }
                    

                }
                
                
            }
            return true
        }
    }

    extension CODMessageDetailVC: BurnSettingDelegate {
        func didSelectRow(burnDelayDic: Dictionary<String, Any>) {
            
            guard let model = CODGroupChatRealmTool.getGroupChat(id: self.chatId) else {
                return
            }
            if model.burn == "\(burnDelayDic["burn"] as! Int)" {
                return
            }
            
            let dict:NSMutableDictionary = NSMutableDictionary.init(dictionary: ["requester":UserManager.sharedInstance.jid,"itemID":self.chatId,"setting":["burn":burnDelayDic["burn"]],"name":COD_changeGroup])
            
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
        }
    }

    extension CODMessageDetailVC {
        
        func showPhotoWay() {
            let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "拍照", style: UIAlertAction.Style.default){ [weak self] (action:UIAlertAction)in
                self?.initCameraPicker()
            }
            let photoAction = UIAlertAction(title: "从相册中选择", style: UIAlertAction.Style.default){ [weak self] (action:UIAlertAction)in
                self?.initPhotoPicker()
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { (action: UIAlertAction) in
            }
            
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(photoAction)
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
        
        //从相册中选择
        func initPhotoPicker(){
            
            if !self.checkAuth() {
                return
            }
            
            let tzImgPicker = CustomUtil.getImagePickController(maxImagesCount: 1, delegate: self)
            tzImgPicker?.isSelectOriginalPhoto = false
            tzImgPicker?.allowPreview = false
            tzImgPicker?.allowTakePicture = false
            tzImgPicker?.allowTakeVideo  = false
            tzImgPicker?.allowCameraLocation = false
            tzImgPicker?.allowPickingVideo = false
            tzImgPicker?.allowPickingGif = false
            tzImgPicker?.delegate = self
            self.present(tzImgPicker ?? UIViewController.init(), animated: true, completion: nil)
            
        }
        
        //拍照
        func initCameraPicker(){
            
            if !self.checkAuth() {
                return
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let  cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
                cameraPicker.allowsEditing = false
                cameraPicker.sourceType = .camera
                //在需要的地方present出来
                self.present(cameraPicker, animated: true, completion: nil)
            } else {
                
                print("不支持拍照")
            }
        }
        
        //裁剪
        func cropImage(image: UIImage){
            
            let cropVC = CODCropViewController()
            cropVC.isRound = false
            cropVC.targetImage = image
            cropVC.delegate = self
            self.navigationController?.pushViewController(cropVC)
            
        }
        
        func checkAuth() -> Bool {
            
            let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if authStatus == .notDetermined {
                self.checkCameraPermission()
            } else if authStatus == .restricted || authStatus == .denied {
                CODAlertViewToSetting_show("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
            } else if authStatus == .authorized {
                return true
            }
            return false
            
        }
        
        func checkCameraPermission () {
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {granted in
                if !granted {
                    
                    DispatchQueue.main.async {
                        CODAlertViewToSetting_show("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
                    }
                    
                }
            })
            
        }
        
        
        
    }


    extension CODMessageDetailVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate,CODCropViewControllerDelegate{
        func CODClipImageDidCancel() {
            
        }
        
        func CODClipImageClipping(image: UIImage) {
            if let cell: CODGroupNameAndAvatarCell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? CODGroupNameAndAvatarCell {
                cell.avatarImgBtn.setImage(image, for: UIControl.State.normal)
            }
            self.uploadHeaderImage(image: image)
        }
        
        //选择图片
        func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
            
            if photos.count > 0 {
                for image in photos {
                    
                    isnNeedCrop = true
                    if let compressImage = ImageCompress.resetImgSize(sourceImage: image, maxImageLenght: KScreenHeight*2, maxSizeKB: 2000) {
                        self.cropImage = UIImage.init(data: compressImage)
                        self.cropImage(image: self.cropImage ?? UIImage() )
                    }
                    
                }
            }
            
        }
        
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            
            //获得照片
            let image:UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            // 拍照
            if picker.sourceType == .camera {
                //保存相册
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
            }
            isnNeedCrop = true
            if let compressImage = ImageCompress.resetImgSize(sourceImage: image, maxImageLenght: KScreenHeight*2, maxSizeKB: 2000) {
                self.cropImage = UIImage.init(data: compressImage)
                self.cropImage(image: self.cropImage ?? UIImage() )
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        
        @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
            
            if error != nil {
                
                print("保存失败")
                
                
            } else {
                
                print("保存成功")
                
                
            }
        }
    }

    //图片裁剪
    extension CODMessageDetailVC{
        
        //头像上传
        func uploadHeaderImage(image: UIImage) {
            
            
            CODProgressHUD.showWithStatus("正在上传头像...")
            UploadTool.upload(fileType: .groupHeader(roomID: self.groupChatModel?.roomID.string ?? "", image: image)) { [weak self] response in
                
                if let avatarID = JSON(response.value)["data"]["attId"].string {
                    self?.uploadImageSuccess(image: image)
                    CODProgressHUD.dismiss()
                } else {
                    CODProgressHUD.showErrorWithStatus("头像上传失败")
                }
                
            }
            
        }
        
        func uploadImageSuccess(image: UIImage) {
            guard let groupAvatarId = self.groupChatModel?.grouppic else {
                return
            }
            let url = URL(string: groupAvatarId.getHeaderImageFullPath(imageType: 2))
            if let _ = SDWebImageManager.shared.cacheKey(for: url) {
                SDImageCache.shared.removeImage(forKey: url?.absoluteString, fromDisk: true) {
                }
            }
            if let _ = SDWebImageManager.shared.cacheKey(for: URL.init(string: groupAvatarId) ) {
                
                SDImageCache.shared.removeImage(forKey: groupAvatarId, fromDisk: true) {
                }
            }
            
            if let cell: CODGroupNameAndAvatarCell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? CODGroupNameAndAvatarCell {

                _ = CODDownLoadManager.sharedInstance.cod_loadHeader(url: url) { (image, _, _, _) in
                    cell.avatarImgBtn.setImage(image, for: .normal)
                }
    //            cell.avatarImgBtn.sd_setImage(with: url, for: UIControl.State.normal, placeholderImage: image)
            }
            
            CODDownLoadManager.sharedInstance.updateAvatar(userPicID: groupAvatarId, complete: nil)
            if self.updateGroupAvatarBlock != nil {
                self.updateGroupAvatarBlock!()
            }
        }
        
        
    }

    extension CODMessageDetailVC: UITextFieldDelegate {
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.mySetRightTextButton()
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            
            if isClickFinish {
                return
            }
            
            guard let text = textField.text else{
                textField.text = self.groupChatModel?.getGroupNameForDetailVC()
                self.rightTextButton.removeFromSuperview()
                self.mySetSearchRightButton()
                return
            }
            
            if text == originalGroupName {
                self.rightTextButton.removeFromSuperview()
                self.mySetSearchRightButton()
                return
            }
            
            if text.removeHeadAndTailSpacePro.count <= 0 {
                textField.text = self.groupChatModel?.getGroupNameForDetailVC()
                self.rightTextButton.removeFromSuperview()
                self.mySetSearchRightButton()
                return
            }
            
            if text.count > 50{
                textField.text = self.groupChatModel?.getGroupNameForDetailVC()
                CODProgressHUD.showErrorWithStatus("群组名称不能超过50个字符")
                self.rightTextButton.removeFromSuperview()
                self.mySetSearchRightButton()
                return
            }
            
            if text.count <= 0 {
                textField.text = self.groupChatModel?.getGroupNameForDetailVC()
                self.rightTextButton.removeFromSuperview()
                self.mySetSearchRightButton()
                return
            }
            
            let alertCtl = UIAlertController.init(title: "确定修改此群名称？", message: nil, preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel) { (action) in
                textField.text = self.groupChatModel?.getGroupNameForDetailVC()
                self.mySetSearchRightButton()
            }
            alertCtl.addAction(action)
            let action1 = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default) { [weak self] (action) in
                guard let self = self, let groupModel = self.groupChatModel else {
                    return
                }
                XMPPManager.shareXMPPManager.changeGroupChatName(roomId: groupModel.roomID, roomName: text, success: { [weak self] (successModel, nameStr) in
                    
                    guard let self = self, let groupModel = self.groupChatModel else {
                        return
                    }
                    if nameStr == "editRoomName" {
                        self.rightTextButton.removeFromSuperview()
                        
                        print("设置群组名称成功")
                        textField.text = text
                        self.originalGroupName = text
                        
                        var cellModel = self.dataSource[0][0]
                        cellModel.title = text
                        self.dataSource[0][0] = cellModel
                        
                        CODGroupChatRealmTool.modifyGroupChatNameByRoomID(by: groupModel.roomID, newRoomName: text)
                        
                        //通知去聊天列表中更新数据
                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                        self.mySetSearchRightButton()
                    }
                    
                    }, fail: { (errorModel) in
                        print("设置群组名称失败")
                        self.rightTextButton.removeFromSuperview()
                        self.mySetSearchRightButton()
                        CODProgressHUD.showSuccessWithStatus(errorModel.msg)
                        textField.text = groupModel.getGroupNameForDetailVC()
                })
            }
            alertCtl.addAction(action1)
            self.present(alertCtl, animated: true, completion: nil)
            
        }
    }


