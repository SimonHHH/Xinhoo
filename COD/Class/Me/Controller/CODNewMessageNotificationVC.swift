//
//  CODNewMessageNotificationVC.swift
//  COD
//
//  Created by 1 on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

class CODNewMessageNotificationVC: BaseViewController,XMPPStreamDelegate{

    var titleLab = UITextField.init()
    var notificationSwitch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("通知与声音", comment: "")
        self.setBackButton()
        self.setUpUI()
        self.reloadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name.init(kChangeSystemNoti), object: nil)
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        UserManager.sharedInstance.reactive.signal(forKeyPath: "notice").merge(with: UserManager.sharedInstance.reactive.signal(forKeyPath: "voipNotice")).merge(with: UserManager.sharedInstance.reactive.signal(forKeyPath: "noticeDetail")).merge(with: UserManager.sharedInstance.reactive.signal(forKeyPath: "sound")).merge(with: UserManager.sharedInstance.reactive.signal(forKeyPath: "vibrate")).observeValues { [weak self] (change) in

            self?.reloadView()
        }
    }
    
    @objc func reloadView() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    self.notificationSwitch = false
                    self.createDataSource()
                }
            }else if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    self.notificationSwitch = true
                    self.createDataSource()
                }
            }
        }
    }
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
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

    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { (actionDic, infoDic) in
            guard let infoDic = infoDic else {
                return
            }
            if (actionDic["name"] as? String == COD_changePerson){
                
                if !(infoDic["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus("设置失败")
                }
                
                let dict = actionDic["setting"] as! NSDictionary
                if (dict["notice"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.notice = (dict["notice"] as! String).bool!
                    }
                }
                
                if (dict["voipnotice"] as? String != nil){
                    if ((infoDic["success"] as! Bool)) {
                        UserManager.sharedInstance.voipNotice = (dict["voipnotice"] as! String).bool!
                    }
                }
                
                if (dict["noticedetail"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.noticeDetail = (dict["noticedetail"] as! String).bool!
                    }
                }
                
                if (dict["sound"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.sound = (dict["sound"] as! String).bool!
                    }
                }
                
                if (dict["vibrate"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.vibrate = (dict["vibrate"] as! String).bool!
                    }
                    
                }
            }
        }
        
        return true
    }
    
    func sendIQ(indexPath:IndexPath,isOn:Bool) {
        
        var dict:NSDictionary? = [:]
        if (indexPath.section == 0){
            switch indexPath.row {
            case 1:
                dict = ["name":COD_changePerson,
                "requester":UserManager.sharedInstance.jid,
                "setting":["notice":isOn]]
            case 2:
                dict = ["name":COD_changePerson,
                "requester":UserManager.sharedInstance.jid,
                "setting":["voipnotice":isOn]]
            default:
                dict = ["name":COD_changePerson,
                "requester":UserManager.sharedInstance.jid,
                "setting":["noticedetail":isOn]]
            }
            
        }
        
        if (indexPath.section == 1){
            if (indexPath.row == 0){
//                dict = ["name":COD_changePerson,
//                        "requester":UserManager.sharedInstance.jid,
//                        "setting":["sound":isOn]]
                UserManager.sharedInstance.sound = !UserManager.sharedInstance.sound
            }
            if (indexPath.row == 1){
//                dict = ["name":COD_changePerson,
//                        "requester":UserManager.sharedInstance.jid,
//                        "setting":["vibrate":isOn]]
                UserManager.sharedInstance.vibrate = !UserManager.sharedInstance.vibrate
            }
            if (indexPath.row == 2){
                UserManager.sharedInstance.preview = !UserManager.sharedInstance.preview
            }
            self.reloadView()
            return
        }
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: dict!)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
}

private extension CODNewMessageNotificationVC {
    
    func createDataSource() {
        if self.dataSource.count > 0 {
            self.dataSource.removeAll()
        }
        
        let notiTitle = notificationSwitch ? "":NSLocalizedString("权限未开启", comment: "")
        
        let model = self.createModel(title: "消息通知系统设置", subTitle: notiTitle, placeholder: "", image: "", type: .baseType, isOn: false)
        
        let model1 = self.createModel(title: "新消息提醒", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.notice)
        
        let model2 = self.createModel(title: "接收语音聊天邀请通知", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.voipNotice)
        
        let model3 = self.createModel(title: "通知显示发送人信息", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.noticeDetail)
        
        if notificationSwitch {
            dataSource.append([model,model1,model2,model3])
        }else{
            dataSource.append([model])
        }
        
        
        let model4 = self.createModel(title: "声音", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.sound)
        let model5 = self.createModel(title: "震动", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.vibrate)
        let model6 = self.createModel(title: "预览", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.preview)
        dataSource.append([model4,model5,model6])
     
        self.tableView.reloadData()
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
}

extension CODNewMessageNotificationVC:UITableViewDelegate,UITableViewDataSource{
    
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
            
        }else if case .imageType = model.type {
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
            
            if model.subTitle == NSLocalizedString("权限未开启", comment: "") {
                
                let imgText = NSTextAttachment()
                let img = UIImage(named: "notification_error_icon")!
                imgText.image = img
                imgText.bounds = CGRect(x: 0.0, y: -3, width: img.size.width, height: img.size.height)
                let imgAttri = NSAttributedString(attachment: imgText)
                
//                titleLab.attributedText = imgAttri + " " + NSAttributedString(string: channel.getGroupName())
                cell?.subTitleLab.attributedText = imgAttri + " " + NSAttributedString(string: NSLocalizedString("权限未开启", comment: ""))
            }else{
                cell?.subTitleLab.attributedText = nil
            }
            
            cell?.imageStr = model.iconName
            return cell!
        }
        
        
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 42.5))
        bgView.backgroundColor = UIColor.clear
        let textLabel = UILabel.init(frame: CGRect(x: 20, y: 32, width: KScreenWidth-42, height: 17))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = UIColor(hexString: kSubTitleColors)

        
        bgView.addSubview(textLabel)
        
        switch section {
        case 0:
            textLabel.text = "消息通知"
            break
        case 1:
            textLabel.text = "应用内提醒"
            break
        default:
            break
        }

        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 55
    }
    
    
    func getFooterString(section: Int) -> String {
        var sectionString = ""
        
        switch section {
        case 0:
            sectionString = NSLocalizedString("关闭后，手机将不再接收新消息提醒。", comment: "")
        case 1:
            sectionString = NSLocalizedString("关闭后，手机将不再接收语音聊天邀请通知。", comment: "")
        case 2:
            sectionString = NSLocalizedString("关闭后，当接收到通知时，通知提示将不显示发送人信息。", comment: "")
        case 3:
            sectionString = CustomUtil.formatterStringWithAppName(str: "当%@在运行时，你可以设置是否需要声音或者震动。")
        default:
            sectionString = ""
        }
        
        return sectionString
    }
    
}

