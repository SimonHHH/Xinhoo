//
//  CODPrivacyVC.swift
//  COD
//
//  Created by 1 on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODPrivacyVC: BaseViewController ,XMPPStreamDelegate{

   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("隐私与权限", comment: "")
        self.setBackButton()
        self.createDataSource()
        self.setUpUI()
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createDataSource()
        self.tableView.reloadData()
    }
    
    private var dataSource: Array = [[CODCellModel]]()
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tabelV.estimatedRowHeight = 80
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor.clear
        tabelV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.delegate = self
        tabelV.dataSource = self
        
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    func sendIQ(indexPath:IndexPath,isOn:Bool) {
        
//        var setting = ""
//        var title = ""
//        var desc = ""
//        switch indexPath.row {
//        case 0:
//            setting = "lastLoginTimeVisible"
//            title = "上线时间不可见？"
//            desc = "关闭后，当您下线时所有人看不到您最近上线的具体时间，只会显示上线于不久前，但您上线时依然能看到您的在线状态"
//            break
//        case 1:
//            setting = "callVisible"
//            title = "拒绝语音通话？"
//            desc = "关闭后，所有人将不能与您进行语音通话"
//            break
//        case 2:
//            setting = "showtel"
//            title = "电话号码不可见？"
//            desc = "关闭后，所有人将不能看到您的电话号码"
//            break
//        case 3:
//            setting = "inviteJoinRoomVisible"
//            title = "拒绝加入群组？"
//            desc = "关闭后，所有人将不能将您加入到群组"
//            break
//        case 4:
//            setting = "xhinvitejoinchannel"
//            title = "拒绝加入频道？"
//            desc = "关闭后，所有人将不能将您加入到频道"
//            break
//        case 5:
//            setting = "messageVisible"
//            title = "拒绝接收消息？"
//            desc = "关闭后，所有人将不能给您发送消息"
//            break
//        default:
//            break
//        }
//
//        if !isOn {
//            let alert = UIAlertController.init(title: title, message: desc, preferredStyle: .alert)
//
//            let cancelAction = UIAlertAction.init(title: "否", style: .default) { (action) in
//                self.tableView.reloadData()
//            }
//            let confirmAction = UIAlertAction.init(title: "是", style: .default) { (action) in
//                self.sendIQWithSetting(setting: setting,isOn: isOn)
//            }
//            alert.addAction(cancelAction)
//            alert.addAction(confirmAction)
//
//            self.present(alert, animated: true, completion: nil)
//        }else{
//            self.sendIQWithSetting(setting: setting,isOn: isOn)
//        }
        
        var dict:NSDictionary? = [:]
        
        if indexPath.section == 1 {
            if indexPath.row == 0{
                dict = ["name":COD_changePerson,
                        "requester":UserManager.sharedInstance.jid,
                        "setting":["searchtel":isOn]]
            }
            
            if indexPath.row == 1{
                dict = ["name":COD_changePerson,
                        "requester":UserManager.sharedInstance.jid,
                        "setting":["searchuser":isOn]]
            }
        }
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: dict!)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func sendIQWithSetting(setting:String,isOn:Bool)  {
        var dict:NSDictionary? = [:]
        if setting == "showtel" {
            
            var value = ""
            if isOn {
                value = "all"
            }else{
                value = "none"
            }
            
            dict = ["name":COD_changePerson,
                    "requester":UserManager.sharedInstance.jid,
                    "setting":[setting:value]]
        }else{
            dict = ["name":COD_changePerson,
                    "requester":UserManager.sharedInstance.jid,
                    "setting":[setting:isOn]]
        }
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: dict!)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { (actionDic, infoDic) in
            guard let infoDic = infoDic else {
                return
            }
            if (actionDic["name"] as? String == COD_changePerson){
                
                if !(infoDic["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus("设置失败")
                    self.tableView.reloadData()
                }
                
                let dict = actionDic["setting"] as! NSDictionary
                if (dict["searchuser"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.searchUser = (dict["searchuser"] as! String).bool!
                    }
                }
                
                if (dict["searchtel"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.searchtel = (dict["searchtel"] as! String).bool!
                    }
                }
                
                if (dict["lastLoginTimeVisible"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.lastOnlineTime = dict["lastLoginTimeVisible"] as? String
                    }
                }
                
                if (dict["callVisible"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.allowVoip = dict["callVisible"] as? String
                    }
                }
                
                if (dict["showtel"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        
                        UserManager.sharedInstance.showTel = (dict["showtel"] as! String)
                    }
                }
                
                if (dict["inviteJoinRoomVisible"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.allowJoinGroup = dict["inviteJoinRoomVisible"] as? String
                    }
                }
                
                if (dict["xhinvitejoinchannel"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.allowJoinChannel = dict["xhinvitejoinchannel"] as? String
                    }
                }
                
                if (dict["messageVisible"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.allowMessage = dict["messageVisible"] as? String
                    }
                }
                self.createDataSource()
                self.tableView.reloadData()

            }
        }
        
        return true
    }
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
    }
    
}
private extension CODPrivacyVC {
    
    func createDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
//        let model1 = self.createModel(title: "添加我的方式", subTitle: "", placeholder: "", image: "", type: .baseType,isOn: true)
        let model2 = self.createModel(title: "黑名单", subTitle: "", placeholder: "", image: "", type: .baseType,isOn: true)
        dataSource.append([model2])
        
        let model9 = self.createModel(title: "手机号码", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.searchtel)
        let model10 = self.createModel(title: "用户名", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.searchUser)
        dataSource.append([model9,model10])
        
        let model3 = self.createModel(title: "最后上线时间", subTitle: self.getSubTitleString(privacyString: UserManager.sharedInstance.lastOnlineTime ?? ""), placeholder: "", image: "", type: .baseType, isOn: true)
        let model4 = self.createModel(title: "语音通话", subTitle: self.getSubTitleString(privacyString: UserManager.sharedInstance.allowVoip ?? ""), placeholder: "", image: "", type: .baseType, isOn: true)
        let model5 = self.createModel(title: "电话号码", subTitle: self.getSubTitleString(privacyString: UserManager.sharedInstance.showTel ?? ""), placeholder: "", image: "", type: .baseType, isOn: true)
        let model6 = self.createModel(title: "群组", subTitle: self.getSubTitleString(privacyString: UserManager.sharedInstance.allowJoinGroup ?? ""), placeholder: "", image: "", type: .baseType, isOn: true)
        let model7 = self.createModel(title: "频道", subTitle: self.getSubTitleString(privacyString: UserManager.sharedInstance.allowJoinChannel ?? ""), placeholder: "", image: "", type: .baseType, isOn: true)
        let model8 = self.createModel(title: "消息", subTitle: self.getSubTitleString(privacyString: UserManager.sharedInstance.allowMessage ?? ""), placeholder: "", image: "", type: .baseType, isOn: true)
        
        dataSource.append([model3,model4,model5,model6,model7,model8])
        
//        let model3 = self.createModel(title: "已读回执", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.readreceipt)
//        dataSource.append([model3])
        
    }
    
    func createModel(title: String = "",
                     subTitle: String = "",
                     placeholder: String = "",
                     image: String = "",
                     type: CODCellType,
                     isOn: Bool) -> (CODCellModel) {
        var model = CODCellModel()
        model.title = title
        model.subTitle = subTitle
        model.placeholderString = placeholder
        model.type = type
        model.isOn = isOn
        model.iconName = image
        return model
    }
    
    func setUpUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }
    
    func getSubTitleString(privacyString: String) -> String {
        var titleString = ""
        if privacyString.contains(kCOD_all){
            titleString = "所有人"
        }else if privacyString.contains(kCOD_roster) {
            titleString = "我的联系人"
        }else if privacyString.contains(kCOD_none){
            titleString = "不允许任何人"
        }
        if titleString.removeAllSapce.count == 0 {
            
            if privacyString.contains("true"){
                titleString = "所有人"
            }else{
               titleString = "不允许任何人"
            }
        }
        return titleString
    }
}

extension CODPrivacyVC:UITableViewDelegate,UITableViewDataSource{
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODBaseDetailCell.self, forCellReuseIdentifier: "CODBaseDetailCellID")
        tableView.register(CODDetailImageCell.self, forCellReuseIdentifier: "CODDetailImageCellID")
        tableView.register(CODDetailSwitchCell.self, forCellReuseIdentifier: "CODDetailSwitchCellID")
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
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODDetailSwitchCellID", for: indexPath) as? CODDetailSwitchCell
            if cell == nil{
                cell = CODDetailSwitchCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODDetailSwitchCellID")
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
            cell?.titleFont = UIFont.systemFont(ofSize: 15.0)
            cell?.placeholer = model.placeholderString
            cell?.switchIsOn = model.isOn
            cell?.imageStr = model.iconName
            cell?.onBlock = { [weak self] isOn -> () in
                self?.sendIQ(indexPath: indexPath , isOn: isOn)
            }
            return cell!
        } else if case .imageType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODDetailImageCellID", for: indexPath) as? CODDetailImageCell
            if cell == nil{
                cell = CODDetailImageCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODDetailImageCellID")
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.title = model.title
            cell?.titleFont = UIFont.systemFont(ofSize: 15.0)
            cell?.placeholer = model.placeholderString
            cell?.imageV = UIImage.init(named: model.iconName ?? "")
            return cell!
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODBaseDetailCellID", for: indexPath) as? CODBaseDetailCell
            if cell == nil{
                cell = CODBaseDetailCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODBaseDetailCellID")
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
            cell?.titleFont = UIFont.systemFont(ofSize: 15.0)
            cell?.placeholer = model.placeholderString
            cell?.subTitle = model.subTitle
            cell?.imageStr = model.iconName
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let textString = self.getFooterString(section: section)
        let textFont = UIFont.systemFont(ofSize: 12)
        var sectionHeight: CGFloat = 0.01
        if section == 0 {
            sectionHeight = 55
        }else{
            sectionHeight = 57
        }
        var labelHeight: CGFloat = 0.01
        if section == 0 {
             labelHeight = 32
         }else{
             labelHeight = 34
         }
        let textLabel = UILabel.init(frame: CGRect(x: 20, y: labelHeight, width: KScreenWidth-42, height: 17))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.font = textFont
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        textLabel.text = textString
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
        bgView.backgroundColor = UIColor.clear
        bgView.addSubview(textLabel)
        
        return bgView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        bgView.backgroundColor = UIColor.clear
        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        let textString = self.getFooterString(section: section)
//        let textFont = UIFont.systemFont(ofSize: 12)
        var sectionHeight: CGFloat = 0.01
        if section == 0 {
            sectionHeight = 55
        }else{
            sectionHeight = 57
        }

        return sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func getFooterString(section: Int) -> String {
        var sectionString = ""
        
        switch section {
        case 0:
            sectionString = "隐私"
        case 1:
            sectionString = "找到我的方式"
        case 2:
            sectionString = "联系人权限"
        case 3:
            sectionString = "关闭后，您也无法看到其他人的读取状态。此选项不会影响群组对话的已读回执。"
        default:
            sectionString = ""
        }
        return sectionString
    }
    
    func getFooterHeight(textString: String, width: CGFloat,textFont:UIFont) -> CGFloat {
       var footerHeight = textString.getStringHeight(font: textFont, lineSpacing: 0, fixedWidth: width)
       if footerHeight < 20 {
           footerHeight = 42.5
       }else{
           footerHeight = 57.5
       }
       return footerHeight
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
//            case 0:
//                self.navigationController?.pushViewController(CODAddMeMethodVC(), animated: true)
//                break
            case 0:
                self.navigationController?.pushViewController(CODBlackListViewController(), animated: true)
                break
            default:
                break
            }
            break
        case 1:
            
            break
        case 2:
            self.pushToPrivacySelectVC(row: indexPath.row)
            break
        default:
            break
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func pushToPrivacySelectVC(row: Int) {
        
        let privacySelectVC = CODPrivacySelectVC()
        privacySelectVC.privacyType = CODPrivacyType(rawValue: row) ?? .LastLoginTime
        self.navigationController?.pushViewController(privacySelectVC)
    }
}

