//
//  CODPrivacySelectVC.swift
//  COD
//
//  Created by 1 on 2020/4/27.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

enum CODPrivacyType :Int {
    
    case LastLoginTime  = 0
    case VoiceCall      = 1
    case ShowTel  = 2
    case InviteJoinRoom   = 3
    case InviteJoinChannle   = 4
    case MessageVisible   = 5

}

class CODPrivacySelectVC: BaseViewController {
    
    var privacyType: CODPrivacyType  = .LastLoginTime
    
    private var lastIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
    
    private var dataSource: Array = ["所有人","我的联系人","不允许任何人"]

    private var selIndex: IndexPath = IndexPath.init(row: 0, section: 0)
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tabelV.estimatedRowHeight = 80
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.backgroundColor = UIColor.clear
        tabelV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.delegate = self
        tabelV.dataSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackButton()
        self.getTitleString()
        self.getLastIndexPath()
        self.setUpUI()
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
    }
    
    func getTitleString() {
        
        var titleString = ""
        switch privacyType {
        case .LastLoginTime:
            titleString = "最后上线时间"
        case .VoiceCall:
            titleString = "语音通话"
        case .ShowTel:
            titleString = "电话号码"
        case .InviteJoinRoom:
            titleString = "群组"
        case .InviteJoinChannle:
            titleString = "频道"
        case .MessageVisible:
            titleString = "消息"
        }
        self.navigationItem.title = NSLocalizedString(titleString, comment: "")
    }
    
    func getLastIndexPath() {
        var titleString = ""
        switch privacyType {
        case .LastLoginTime:
            titleString = UserManager.sharedInstance.lastOnlineTime ?? ""
        case .VoiceCall:
            titleString = UserManager.sharedInstance.allowVoip ?? ""
        case .ShowTel:
            titleString = UserManager.sharedInstance.showTel ?? ""
        case .InviteJoinRoom:
            titleString = UserManager.sharedInstance.allowJoinGroup ?? ""
        case .InviteJoinChannle:
            titleString = UserManager.sharedInstance.allowJoinChannel ?? ""
        case .MessageVisible:
            titleString = UserManager.sharedInstance.allowMessage ?? ""
        }
        
        var rowIndex: Int = 0
        if titleString.contains(kCOD_all){
            rowIndex = 0
        }else if titleString.contains(kCOD_roster) {
            rowIndex = 1
        }else if titleString.contains(kCOD_none){
            rowIndex = 2
        }else if titleString.contains("true"){
            rowIndex = 0
        }else if titleString.contains("false"){
           rowIndex = 2
        }else {
            rowIndex = 2
        }
        lastIndexPath = IndexPath.init(row: rowIndex, section: 0)
    }
    

    func setUpUI() {
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }

}

extension CODPrivacySelectVC:UITableViewDelegate,UITableViewDataSource{
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODLanguageSettingsCell.self, forCellReuseIdentifier: "CODLanguageSettingsCellID")
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
      return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let  dataString = dataSource[indexPath.row]
        let cell: CODLanguageSettingsCell = tableView.dequeueReusableCell(withIdentifier: "CODLanguageSettingsCellID", for: indexPath) as! CODLanguageSettingsCell
        cell.title = dataString
        if indexPath.row == lastIndexPath.row{
            cell.isHiddenImage = false
        }else{
            cell.isHiddenImage = true
        }
        if indexPath.row == dataSource.count - 1 {
            cell.isLast = true
        }else{
            cell.isLast = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 42.5))
        bgView.backgroundColor = UIColor.clear
        let textLabel = UILabel.init(frame: CGRect(x: 20, y: 32, width: KScreenWidth-42, height: 17))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = UIColor(hexString: kSubTitleColors)
        textLabel.text = self.getHeaderViewString()
        bgView.addSubview(textLabel)
        return bgView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let textString = self.getFooterViewString()
        let textFont = UIFont.systemFont(ofSize: 12)
        var sectionHeight: CGFloat = 0.01
        sectionHeight = textString.getStringHeight(font: textFont, lineSpacing: 0, fixedWidth: KScreenWidth - 30) + 14
        let footerHeight = textString.getStringHeight(font: textFont, lineSpacing: 0, fixedWidth: KScreenWidth - 30)
        let textLabel = UILabel.init(frame: CGRect(x: 15, y: 7, width: KScreenWidth-30, height: footerHeight))
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 55
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let textString = self.getFooterViewString()
        let textFont = UIFont.systemFont(ofSize: 12)
        var sectionHeight: CGFloat = 0.01
        sectionHeight = textString.getStringHeight(font: textFont, lineSpacing: 0, fixedWidth: KScreenWidth - 30) + 14
        return sectionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if lastIndexPath.row != indexPath.row{

            lastIndexPath = indexPath
            self.sendIQ()
            tableView.reloadData()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func getHeaderViewString() -> String {
        
        var titleString = ""
        switch privacyType {
        case .LastLoginTime:
            titleString = "谁可以看到您最近上线的具体时间"
        case .VoiceCall:
            titleString = "谁可以给您拨打语音通话"
        case .ShowTel:
            titleString = "谁可以看到您的电话号码"
        case .InviteJoinRoom:
            titleString = "谁可以将您加入群组"
        case .InviteJoinChannle:
            titleString = "谁可以将您加入频道"
        case .MessageVisible:
            titleString = "谁可以给您发送消息"
        }
        return NSLocalizedString(titleString, comment: "")
    }
    
    func getFooterViewString() -> String  {
        if privacyType == .LastLoginTime{
            
            return NSLocalizedString("注意：当您离线时，对于被设置为看不到您最近具体上线时间的人只会显示“上线于不久前”，但是您上线时依然能看到您的在线状态。", comment: "")
        }
        return ""
    }
    
    func getIQString() -> String {
        
//        给好友显示自己电话号码
//        all(所有人显示)
//        none(全部不显示)
//        roster（好友显示，不包括临时好友）
        var IQString = ""
        switch lastIndexPath.row {
        case 0:
            IQString = "all"
        case 1:
            IQString = "roster"
        default:
            IQString = "none"
        }

        return IQString
    }
    
    func sendIQ() {
        
        var setting = ""
//        var title = ""
//        var desc = ""
        switch privacyType {
        case .LastLoginTime:
            setting = "lastLoginTimeVisible"
//            title = "上线时间不可见？"
//            desc = "关闭后，当您下线时所有人看不到您最近上线的具体时间，只会显示上线于不久前，但您上线时依然能看到您的在线状态"
            break
        case .VoiceCall:
            setting = "callVisible"
//            title = "拒绝语音通话？"
//            desc = "关闭后，所有人将不能与您进行语音通话"
            break
        case .ShowTel:
            setting = "showtel"
//            title = "电话号码不可见？"
//            desc = "关闭后，所有人将不能看到您的电话号码"
            break
        case .InviteJoinRoom:
            setting = "inviteJoinRoomVisible"
//            title = "拒绝加入群组？"
//            desc = "关闭后，所有人将不能将您加入到群组"
            break
        case .InviteJoinChannle:
            setting = "xhinvitejoinchannel"
//            title = "拒绝加入频道？"
//            desc = "关闭后，所有人将不能将您加入到频道"
            break
        case .MessageVisible:
            setting = "messageVisible"
//            title = "拒绝接收消息？"
//            desc = "关闭后，所有人将不能给您发送消息"
            break
        }
        
        self.sendIQWithSetting(setting: setting)

    }
    
    func sendIQWithSetting(setting:String)  {
        var dict:NSDictionary? = [:]

        
        dict = ["name":COD_changePerson,
                "requester":UserManager.sharedInstance.jid,
                "setting":[setting:self.getIQString()]]
        
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
                self.tableView.reloadData()

            }
        }
        
        return true
    }

}

