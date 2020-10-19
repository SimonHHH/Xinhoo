//
//  CODSetGroupNameAndAvatarVC.swift
//  COD
//
//  Created by XinHoo on 2019/8/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSetGroupNameAndAvatarVC: BaseViewController {
    
    enum VCType {
        case createGroup   //创建群组
        case createChannel  //创建频道
    }
    
    var isEnableInvite: Bool = true
    var isEnableSpeak: Bool = true

    var vcType: VCType = .createGroup
    
    private var cropImage: UIImage?
    private var isnNeedCrop: Bool = false
    
    var avatarID: String?
    
    var channelDescStr: String = ""
    
    var dataSource: Array<AnyObject> = []
    var searchUsers: Array<CODSearchResultContact>?
    
    var allDataSource: Array<AnyObject> = []
    
    typealias CreateGroupSuccessCloser = (_ groupChatModel: CODGroupChatModel) -> Void
    var createGroupSuccess: CreateGroupSuccessCloser!
    
    let inputLimitLength = 40
    
    let titleBackGroupView: UIView = {
        let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth-190, height: 44))
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.boldSystemFont(ofSize: 18.0)
        lb.textAlignment = NSTextAlignment.center
        lb.textColor = UIColor(hexString: kNavTitleColorS)
        return lb
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tv.estimatedRowHeight = 44
        tv.rowHeight = UITableView.automaticDimension
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.register(UINib.init(nibName: "CODGroupMemberAdvTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupMemberAdvTableViewCell")
        tv.register(UINib.init(nibName: "CODSetGroupAvatarTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODSetGroupAvatarTableViewCell")
        tv.register(UINib.init(nibName: "CODGroupNameAndAvatarCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupNameAndAvatarCell")
        tv.register(CODTextFieldTableViewCell.self, forCellReuseIdentifier: "CODTextFieldTableViewCell")
        tv.register(CODMessageDetailSwitchCell.self, forCellReuseIdentifier: "CODMessageDetailSwitchCellID")
        return tv
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let cell: CODGroupNameAndAvatarCell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? CODGroupNameAndAvatarCell else {
            return
        }
        cell.groupNameField.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBarTitle()
        
        self.setBackButton()
        self.backButton.setTitle("返回", for: UIControl.State.normal)
        
        self.setRightTextButton()
        rightTextButton.isEnabled = false
        let rightBtnText = vcType == .createGroup ? "创建" : "下一步"
        rightTextButton.setTitle(rightBtnText, for: UIControl.State.normal)
        
        self.initUI()
        
        // Do any additional setup after loading the view.
    }
    
    func setNavBarTitle() {
        
        self.navigationItem.titleView = self.titleBackGroupView
        self.titleBackGroupView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.left.equalToSuperview()
            make.height.equalTo(18)
        }
        if vcType == .createGroup {
            self.titleLabel.attributedText = self.getAttributesTitle()
        }else{
            self.titleLabel.text = NSLocalizedString("新建频道", comment: "")
        }
        
    }
    
    override func navRightTextClick() {
        if vcType == .createGroup {
            self.submit()
        }else{
            self.createChannelNextStep()
        }
        
    }
    
    func initUI() {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    func initSectionFootview() -> UIView {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 32))
        let lab = UILabel(frame: CGRect(x: 15, y: 8, width: KScreenWidth-30, height: 16))
        lab.text = vcType == .createChannel ? "为频道设置简介。" : "开启后，群成员可通过二维码邀请他人入群，通过群链接入群也将生效"
        lab.textColor = UIColor(hexString: kSubTitleColors)
        lab.font = UIFont.systemFont(ofSize: 12.0)
        v.addSubview(lab)
        
        return v
    }
    
    func submit() {
        
        var roomName: String?
        guard let cell: CODGroupNameAndAvatarCell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? CODGroupNameAndAvatarCell else {
            return
        }
        roomName = cell.groupNameField.text
        
        guard var roomNameStr = roomName else {
            return
        }
        CODProgressHUD.showWithStatus(nil)
        roomNameStr = roomNameStr.removeHeadAndTailSpacePro
        if roomNameStr.count <= 0 {
            CODProgressHUD.showErrorWithStatus("请输入群组名称")
            cell.groupNameField.text = ""
            return
        }
        
        if roomNameStr.count > self.inputLimitLength {
            CODProgressHUD.showErrorWithStatus(String(format: "群组名称不能超过%d个字符",inputLimitLength))
            return
        }
        
        XMPPManager.shareXMPPManager.createGroupChat(members: dataSource as! Array<CODContactModel>, searchUsers: searchUsers, picID: avatarID, roomName: roomNameStr, isInvite: self.isEnableInvite, success: { (model, nameStr) in
            
            if nameStr == "createRoom" {
                print("success：\(model.data ?? "空")")
                print("++++++++++++++++++收到群组创建的IQ")
                CODProgressHUD.dismiss()
                let groupChatModel = CODGroupChatModel()
                if let dataDic = model.data as? Dictionary<String, Any> {
                    if let dic = dataDic["data"] as?  Dictionary<String, Any>{
                        groupChatModel.jsonModel = CODGroupChatHJsonModel.deserialize(from: dic)
                        groupChatModel.isValid = true
                        //创建成功加入聊天室
                        XMPPManager.shareXMPPManager.joinGroupChatWith(groupJid: groupChatModel.jid)
                        
                        if let memberArr = dic["member"] as! [Dictionary<String,Any>]? {
                            for member in memberArr {
                                let memberTemp = CODGroupMemberModel()
                                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                                memberTemp.memberId = String(format: "%d%@", groupChatModel.roomID, memberTemp.username)
                                groupChatModel.member.append(memberTemp)
                            }
                        }
                        groupChatModel.customName = CODGroupChatModel.getCustomGroupName(memberList: groupChatModel.member)
                    }
                }
                groupChatModel.createDate = String(format: "%.0f", Date.milliseconds)
                CODChatListModel.insertOrUpdateGroupChatListModel(by: groupChatModel, message: nil)
                self.navigationController?.popToRootViewController(animated: true)
                if self.createGroupSuccess != nil{
                    self.createGroupSuccess(groupChatModel)
                }
            }
            
        }) { (error) in
            switch error.code {
            case 30026:
                CODProgressHUD.showErrorWithStatus("您邀请的用户全部拒绝加入群聊，请选择其他用户")
            default:
                if let msg = error.msg {
                    CODProgressHUD.showErrorWithStatus(msg)
                }else{
                    CODProgressHUD.showErrorWithStatus("创建群失败")
                }
                
            }
            
            
            print("失败：\(error.msg ?? "空")")
        }
    }
    
    func createChannelNextStep() {
        var channelName: String?
        guard let cell: CODGroupNameAndAvatarCell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? CODGroupNameAndAvatarCell else {
            return
        }
        channelName = cell.groupNameField.text
        
        guard var channelNameStr = channelName else {
            return
        }
        
        channelNameStr = channelNameStr.removeHeadAndTailSpacePro
        if channelNameStr.count <= 0 {
            CODProgressHUD.showErrorWithStatus("请输入频道名称")
            cell.groupNameField.text = ""
            return
        }
        
        if channelNameStr.count > self.inputLimitLength {
            CODProgressHUD.showErrorWithStatus(String(format: "群组名称不能超过%d个字符",inputLimitLength))
            return
        }
        
        
        CODProgressHUD.showWithStatus(nil)
                
        XMPPManager.shareXMPPManager.createChannel(members: [], searchUsers: nil, picID: avatarID, channelType: .CPRI, channelPubLink: nil, roomName: channelNameStr, destription: channelDescStr, success: { (model, nameStr) in
            
            if nameStr == COD_createchannel {
                print("success：\(model.data ?? "空")")
                print("++++++++++++++++++收到频道创建的IQ")
                CODProgressHUD.dismiss()
                var channelModel = CODChannelModel()
                if let dataDic = model.data as? Dictionary<String, Any> {
                    channelModel = CODChannelModel.init(jsonModel: CODChannelHJsonModel.deserialize(from: dataDic)!)
                    channelModel.isValid = true
                    
                    if let memberArr = dataDic["channelMemberVoList"] as? [Dictionary<String,Any>] {
                        
                        let members = memberArr.map { member -> CODGroupMemberModel in
                            let memberTemp = CODGroupMemberModel()
                            memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                            memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                            return memberTemp
                        }
                        channelModel.member.append(objectsIn: members)
                    }
                    channelModel.customName = CODGroupChatModel.getCustomGroupName(memberList: channelModel.member)
                }
                channelModel.createDate = String(format: "%.0f", Date.milliseconds)
                channelModel.channelTypeEnum = .CPRI
                CODChatListModel.insertOrUpdateChannelListModel(by: channelModel, message: nil)
                
                let channelVC = CODChannelTypeVC()
                channelVC.channelModel = channelModel
                channelVC.vcType = .create
//                channelVC.channelName = channelNameStr
//                channelVC.channelDesc = channelDescStr
                
                self.navigationController?.pushViewController(channelVC, animated: true)
                
            }
            
        }) { (error) in
            switch error.code {
            case 30026:
                CODProgressHUD.showErrorWithStatus("您邀请的用户全部拒绝加入频道，请选择其他用户")
            default:
                if let msg = error.msg {
                    CODProgressHUD.showErrorWithStatus(msg)
                }else{
                    CODProgressHUD.showErrorWithStatus("创建频道失败")
                }
                
            }
            
            print("失败：\(error.msg ?? "空")")
        }
    }
    
    func getAttributesTitle() -> NSAttributedString {
        var attribute = NSAttributedString.init(string: NSLocalizedString("新建群组", comment: ""))
        attribute = attribute.colored(with: UIColor.init(hexString: kNavTitleColorS)!)
        var attributeCount = NSAttributedString.init(string: " \(allDataSource.count)")
        attributeCount = attributeCount.colored(with: UIColor.init(hexString: kSubTitleColors)!)
        attribute = attribute + attributeCount
        return attribute
    }
    
}


extension CODSetGroupNameAndAvatarVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 1 {
            
            CODImagePickerTools.defualt.showPhotoWay(roomID: "0", fetchImage: nil) { [weak self] (imageID) in
                
                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: imageID) { (image) in
                    
                    guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CODGroupNameAndAvatarCell else {
                        return
                    }
                    
                    cell.avatarImgBtn.setImage(image, for: .normal)
                    
                }
                
                self?.avatarID = imageID
                
            }

    
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
//            if vcType == .createGroup {
//                return 2
//            }
            return 1
        default:
            return allDataSource.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if vcType == .createGroup {
            return 3
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell :CODGroupNameAndAvatarCell = tableView.dequeueReusableCell(withIdentifier: "CODGroupNameAndAvatarCell") as! CODGroupNameAndAvatarCell
                cell.isEdit = true
                if vcType == .createGroup {
                    cell.placeholder = "群组名称"
                }else{
                    cell.placeholder = "频道名称"
                }
                
                cell.selectAvatarCloser = { [weak cell] in
                    
                    CODImagePickerTools.defualt.showPhotoWay(roomID: "0", fetchImage: nil) { [weak self, weak cell] (imageID) in
                        
                        guard let cell = cell else { return }
                        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: imageID) { (image) in
                            cell.avatarImgBtn.setImage(image, for: .normal)
                        }
                        self?.avatarID = imageID
                    }
                }
                cell.textFieldDidEditChangeCloser = { [weak self] (textField: UITextField) in
                    guard let self = self else {
                        return
                    }
                    guard var text = textField.text else {
                        return
                    }
                    
                    if text.count > self.inputLimitLength {
                        let textStr = text.slice(from: 0, length: self.inputLimitLength)
                        textField.text = textStr
                    }
                    
                    if text.removeHeadAndTailSpacePro.count > 0 {
                        self.rightTextButton.isEnabled = true
                    }else{
                        self.rightTextButton.isEnabled = false
                    }
                }
                cell.selectionStyle = .none
                return cell
            }else{
                let cell :CODSetGroupAvatarTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CODSetGroupAvatarTableViewCell") as! CODSetGroupAvatarTableViewCell
                if vcType == .createGroup {
                    cell.titleStr = "设置群组头像"
                }else{
                    cell.titleStr = "设置频道头像"
                }
                return cell
            }
        case 1:
            if vcType == .createGroup {
                var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailSwitchCellID", for: indexPath) as? CODMessageDetailSwitchCell
                if cell == nil{
                    cell = CODMessageDetailSwitchCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailSwitchCellID")
                }
                if indexPath.row == 0{
        
//                    cell?.isTop = true
//                    cell?.isLast = true
//                    cell?.title = "允许群成员发言"
//                    cell?.imageStr = nil
//                    cell?.switchIsOn = isEnableSpeak
//                    
//                    cell?.onBlock = { [weak self] isOn -> () in
//                        self?.isEnableInvite = isOn
//                    }
//                }else{
//      
                    cell?.isTop = true
                    cell?.isLast = true
                    cell?.title = "允许邀请入群"
                    cell?.imageStr = nil
                    cell?.switchIsOn = !isEnableInvite
                    
                    cell?.onBlock = { [weak self] isOn -> () in
                        self?.isEnableInvite = !isOn
                    }
                }
                return cell!

            }else{
                let cell :CODTextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CODTextFieldTableViewCell") as! CODTextFieldTableViewCell
                cell.placeholder = NSLocalizedString("简介", comment: "")
                cell.fieldEditingCloser = {[weak self] (text: String) in
                    guard let self = self else {
                        return
                    }
                    self.channelDescStr = text
                    
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
                cell.isTop = true
                cell.isLast = true
                return cell
            }
        default:
            let cell :CODGroupMemberAdvTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CODGroupMemberAdvTableViewCell") as! CODGroupMemberAdvTableViewCell
            let model = allDataSource[indexPath.row]
            if let contactModel = model as? CODContactModel {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: contactModel.userpic) { (image) in
                    cell.imgView.image = image
                }
                cell.titleStr = contactModel.getContactNick()
                cell.subTitleStr = nil
            }
            
            if let memberModel = model as? CODGroupMemberModel {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: memberModel.userpic) { (image) in
                    cell.imgView.image = image
                }
                cell.titleStr = memberModel.getMemberNickName()
                cell.subTitleStr = nil
            }
            
            if let searchUser = model as? CODSearchResultContact {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: searchUser.pic) { (image) in
                    cell.imgView.image = image
                }
                cell.titleStr = searchUser.name
                cell.subTitleStr = nil
            }
            
            if indexPath.row == 0 {
                cell.isTop = true
            }else{
                cell.isTop = false
            }
            
            if indexPath.row == self.dataSource.count - 1 {
                cell.isLast = true
            }else{
                cell.isLast = false
            }
            
            cell.placeholderStr = nil
            
            return cell
        }
            
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 32.0
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }else{
            if vcType == .createChannel {
                return 35.0
            }
            else {
                return 20.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            return initSectionFootview()
        }else{
            return UIView()
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
}
