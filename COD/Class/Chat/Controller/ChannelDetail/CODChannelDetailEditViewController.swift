//
//  CODChannelDetailEditViewController.swift
//  COD
//
//  Created by XinHoo on 2019/12/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm

class CODChannelDetailEditViewController: BaseViewController {

    public var channelModel: CODChannelModel?  = nil
    
    var channelDescStr = ""
    var chatId = 0
    
    var myPower: Int = 30
    
    var introductionRowAddition = 0
    var linkRowAddition = 0
    
    private let disposeBag = DisposeBag()

    
    private var cropImage: UIImage?
    
    public var channelName: String = ""
    
    private var dataSource: Array = [[CODCellModel]]()
    
    let inputLimitLength = 40

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
        self.mySetRightTextButton()
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.navigationItem.title = NSLocalizedString("频道详情", comment: "")
        self.getChannelInfo()
        self.createChannelDataSource()
        
        self.channelDescStr = channelModel?.notice ?? ""
        
        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func setUpUI() {
        
        tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0.01))
        tableView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0.01))

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
        }
    }
    
    
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
    
    override func navBackClick() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func mySetRightTextButton() {
        self.setRightTextButton()
        self.rightTextButton.setTitle("完成", for: UIControl.State.normal)
        self.rightTextButton.setTitleColor(UIColor.init(hexString: kBlueTitleColorS), for: UIControl.State.normal)
    }
    
    override func navRightTextClick() {
        
        guard let channelModel = self.channelModel else {
            return
        }
        
        if self.channelName != channelModel.descriptions {
            XMPPManager.shareXMPPManager.changeGroupChatName(roomId: channelModel.chatId, roomName: self.channelName, chatType: .channel, success: {  (_, name) in
            }) { (_) in
            }
        }
        
        if channelDescStr != channelModel.notice {
            XMPPManager.shareXMPPManager.settingGroupAnnounce(roomId: channelModel.chatId, notice: self.channelDescStr, chatType:.channel, success: { (_, _) in
            }) { (_) in
            }
        }
        
        self.navigationController?.popViewController(animated: false)

    }
    
    @objc func createChannelDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()

        }
        
        guard let channelModel = self.channelModel else {
            return
        }
        
        var model1 = self.createModel(title: self.channelName, subTitle: "", placeholder: "", image: self.channelModel?.grouppic ?? "", type: .headerType)
        var model13 = self.createModel(title: "设置频道头像", subTitle: "", placeholder: "", image: "", type: .baseType)
        model13.action.didSelected = { [weak channelModel] in
            
            guard let channelModel = channelModel else { return }
            
            CODImagePickerTools.defualt.showPhotoWay(roomID: channelModel.roomID.string) { [weak channelModel] (imageId) in
                
                guard let channelModel = channelModel else { return }

                model1.iconName = imageId
                channelModel.updateChannel(grouppic: imageId)
            }
            
        }
        
        model13.titleColor = UIColor.init(hexString: kBlueTitleColorS)
        dataSource.append([model1, model13])
        
        let model3 = self.createModel(title: "简介", subTitle: channelModel.shareLink, placeholder: self.channelModel?.notice ?? "", image: "", type: .textFieldType)
        dataSource.append([model3])        
        
        var model2 = self.createModel(title: "频道类型", subTitle: channelModel.channelTypeEnum.name, placeholder: "", image: "", isHiddenArrow: false, type: .baseType)

        model2.action.didSelected = { [weak self] in
            
            guard let `self` = self else { return }
            
            let channelVC = CODChannelTypeVC()
            channelVC.channelModel = channelModel
            channelVC.vcType = .edit
            
            
            self.navigationController?.pushViewController(channelVC, animated: true)            
        }
        
        
        if channelModel.isOwner(by: UserManager.sharedInstance.jid) {
            dataSource[1].insert(model2, at: 0)
        }
        
        
        var model4 = self.createSwitchModel(title: "署名", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: channelModel.signmsg, isEnable: true)
        
        model4.action.switchButtonAction = { isOn in
            XMPPManager.shareXMPPManager.channelSetting(roomID: channelModel.roomID, signmsg: isOn)
        }
        
        dataSource.append([model4])

//        var model6 = self.createSwitchModel(title: "保存到频道", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: self.channelModel?.savecontacts ?? false, isEnable: true)
//
//        model6.action.switchButtonAction = { [weak channelModel] isOn in
//            guard let channelModel = channelModel else { return }
//            XMPPManager.shareXMPPManager.channelSetting(roomID: channelModel.chatId, savecontacts: isOn)
//        }
        
        var model7 = self.createSwitchModel(title: "置顶频道", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: self.channelModel?.stickytop ?? false, isEnable: true)

        model7.action.switchButtonAction = { [weak channelModel] (isOn) -> Void in
            guard let channelModel = channelModel else { return }
            XMPPManager.shareXMPPManager.channelSetting(roomID: channelModel.chatId, stickytop: isOn)
        }
        
        var model8 = self.createSwitchModel(title: "消息通知", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: !(self.channelModel?.mute ?? false), isEnable: true)
        
        model8.action.switchButtonAction = { [weak channelModel] (isOn) -> Void in
            guard let channelModel = channelModel else { return }
            XMPPManager.shareXMPPManager.channelSetting(roomID: channelModel.chatId, mute: !isOn)
        }
        
        dataSource.append([model7, model8])
//        dataSource.append([model6, model7, model8])
        
        Observable.from(object: channelModel)
            .subscribe(onNext: { (model) in
                
                model7.isOn = model.stickytop
                model8.isOn = !model.mute
//                model6.isOn = model.savecontacts
                model1.iconName = model.grouppic
                model4.isOn = model.signmsg
                model2.subTitle = model.channelTypeEnum.name
                
            })
            .disposed(by: self.disposeBag)
        
    }
    
    
    @objc dynamic func quitChanneModel(owner: Bool) {
        

        if owner {
            XMPPManager.shareXMPPManager.destroyChannel(roomId: self.channelModel?.roomID ?? 0, success: { [weak self] (_, name) in
                
                guard let `self` = self else { return }
                
                if (name != COD_destroyRoom) {
                    return
                }
                
                self.navigationController?.popToRootViewController(animated: true)
                
                
            }) { (_) in
                
            }
        }else{
            XMPPManager.shareXMPPManager.quitChannel(roomId: self.channelModel?.roomID ?? 0, success: { [weak self] (_, name) in
                
                guard let `self` = self else { return }
                
                if (name != COD_quitGroupChat) {
                    return
                }
                
                self.navigationController?.popToRootViewController(animated: true)
                
                
            }) { (_) in
                
            }
        }

    }
    
    func getChannelInfo() {
        self.channelName = self.channelModel?.descriptions ?? ""
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
                             isHiddenBottomLine: Bool = false,
                             isHiddenArrow:Bool = true,
                             type: CODCellType) -> (CODCellModel) {
        var model = CODCellModel()
        model.title = title
        model.subTitle = subTitle
        model.placeholderString = placeholder
        model.type = type
        model.iconName = image
        model.ishiddenBottomLine = isHiddenBottomLine
        model.ishiddenArrow = isHiddenArrow
        return model
    }

}

extension CODChannelDetailEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODMessageDetailCell.self, forCellReuseIdentifier: "CODMessageDetailCellID")
        tableView.register(CODMessageDetailImageCell.self, forCellReuseIdentifier: "CODMessageDetailImageCellID")
        tableView.register(CODMessageDetailSwitchCell.self, forCellReuseIdentifier: "CODMessageDetailSwitchCellID")
        tableView.register(CODLongLongTextCell.self, forCellReuseIdentifier: "CODLongLongTextCellID")
        tableView.register(UINib.init(nibName: "CODGroupMemberAdvTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupMemberAdvTableViewCell")
        tableView.register(UINib.init(nibName: "CODGroupNameAndAvatarCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupNameAndAvatarCell")
        tableView.register(CODTextFieldTableViewCell.self, forCellReuseIdentifier: "CODTextFieldTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell: CODGroupNameAndAvatarCell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? CODGroupNameAndAvatarCell {
            if cell.groupNameField.isEditing {
                self.view.endEditing(true)
                return
            }
        }
        
        let model = dataSource[indexPath.section][indexPath.row]
        
        model.action.didSelected?()

//        self.selectGroupChatRow(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource[section].count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let datas = dataSource[indexPath.section]
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
            
            if let cell = cell {
                
                model.$isOn
                    .filterNil()
                    .bind(to: cell.switchBtn.rx.isOn)
                    .disposed(by: cell.rx.prepareForReuseBag)
                
            }
            
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.enable = model.isEnable ?? false
            cell?.switchIsOn = model.isOn
            cell?.imageStr = model.iconName
            cell?.onBlock = {  isOn -> () in
                
                model.action.switchButtonAction?(isOn)
//                self?.sendIQ(indexPath: indexPath , isOn: isOn)
            }
            
            return cell!
        }else if case .longTextType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODLongLongTextCellID", for: indexPath) as? CODLongLongTextCell
            if cell == nil{
                cell = CODLongLongTextCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODLongLongTextCellID")
            }
            if indexPath.row == 0 {
                cell?.isTop = true
            }else{
                cell?.isTop = false
            }
            cell?.title = model.title
            cell?.subTitle = model.subTitle
            return cell!
        }else if case .headerType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODGroupNameAndAvatarCell", for: indexPath) as? CODGroupNameAndAvatarCell
            if cell == nil{
                cell = CODGroupNameAndAvatarCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODGroupNameAndAvatarCell")
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.isEdit = true
            
            if let cell = cell {
                
                model.rx.iconName.debug("model.rx.iconName \(cell)", trimOutput: true).bind { [weak cell] (imageID) in
                    
                    CODDownLoadManager.sharedInstance.updateAvatar(userPicID: imageID) { [weak cell] (image) in
                        cell?.avatarImgBtn.setImage(image, for: .normal)
                    }
                    
                }
                .disposed(by: cell.rx.prepareForReuseBag)
            
            }
            
            cell?.selectAvatarCloser = { [weak cell] in
                let url =  URL.init(string: (model.iconName!.getHeaderImageFullPath(imageType: 2)))
                CustomUtil.removeImageCahch(imageUrl: model.iconName!.getHeaderImageFullPath(imageType: 2))
                SDImageCache.shared.removeImageFromMemory(forKey: CODImageCache.default.getCacheKey(url: url!))
                SDImageCache.shared.removeImageFromDisk(forKey: CODImageCache.default.getCacheKey(url: url!))
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
                guard let `self` = self else { return }
                guard var text = textField.text else {
                    return
                }
                if text.removeHeadAndTailSpacePro.count > 0 {
                    self.rightTextButton.isEnabled = true
                }else{
                    self.rightTextButton.isEnabled = false
                }
                
                if text.count > self.inputLimitLength {
                    let textStr = text.slice(from: 0, length: self.inputLimitLength)
                    textField.text = textStr
                }
                
                self.channelName = text
            }
            cell?.selectionStyle = .none
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.iconName!) { [weak cell] (image) in
                cell?.avatarImgBtn.setImage(image, for: .normal)
            }
            cell?.groupNameField.text = model.title
            
            return cell!
        } else if case .textFieldType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODTextFieldTableViewCell", for: indexPath) as? CODTextFieldTableViewCell
            if cell == nil{
                cell = CODTextFieldTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODTextFieldTableViewCell")
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
            cell?.placeholder = NSLocalizedString(model.title ?? "", comment: "")
            cell?.field.text = model.placeholderString
            cell?.fieldEditingCloser = {[weak self, weak tableView] (text: String) in
                guard let self = self, let tableView = tableView else {
                    return
                }
                
                self.rightTextButton.isEnabled = true
                
                self.channelDescStr = text
                
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailCellID", for: indexPath) as? CODMessageDetailCell
            if cell == nil{
                cell = CODMessageDetailCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailCellID")
            }
            cell?.cellType = .common
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
            cell?.imageStr = model.iconName
            cell?.isHiddenArrow = model.ishiddenArrow
            
            if let cell = cell {
                
                model.$subTitle.bind(to: cell.subTitleLab.rx.text)
                    .disposed(by: cell.rx.prepareForReuseBag)
                
            }
            
            return cell!
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 1,2:
            return 65.0
        default:
            return 22.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let channel = self.channelModel else {
            return UIView()
        }
        
        switch section {
        case 1:
            return createFootView(string: "为频道设置简介。")
        case 2:
            return createFootView(string: "在发布的内容后注明发布者。")
        default:
            return UIView()
        }
        
        
    }
    
    func createFootView(string: String) -> UIView {
        let bg = UIView.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: KScreenWidth, height: 65)))
        let lab = UILabel(frame: CGRect(x: 15, y: 7, width: KScreenWidth-30, height: 20))
        lab.text = string
        lab.textColor = UIColor(hexString: kSectionFooterTextColorS)
        lab.font = UIFont.systemFont(ofSize: 11)
        bg.addSubview(lab)
        return bg
    }
    
}
