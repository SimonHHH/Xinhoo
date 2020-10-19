//
//  CODSecurityVC.swift
//  COD
//
//  Created by 1 on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSecurityVC: BaseViewController ,XMPPStreamDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("账号与安全", comment: "")
        self.setBackButton()
        self.createDataSource()
        self.setUpUI()
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.createDataSource()
        self.tableView.reloadData()
    }
    
    func sendIQ(indexPath:IndexPath,isOn:Bool) {
        
        if indexPath.section == 0 && indexPath.row == 0{
        
            var dict:NSDictionary? = [:]
            if (indexPath.section == 0){
                dict = ["name":COD_changePerson,
                        "requester":UserManager.sharedInstance.jid,
                        "setting":["smslogin":isOn]]
            }
            
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: dict!)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { (actionDic, infoDic) in
            if (actionDic["name"] as? String == COD_changePerson){
                guard let infoDic = infoDic else {
                    return
                }
                if !(infoDic["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus("设置失败")
                }
                
                let dict = actionDic["setting"] as! NSDictionary
                if (dict["smslogin"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.smsLogin = (dict["smslogin"] as! String).bool!
                    }
                }
            }
        }
        
        return true
    }
    
    private var dataSource: Array = [[CODCellModel]]()
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tabelV.estimatedRowHeight = 43
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor.clear
        tabelV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
//        tabelV.tableFooterView = self.initTableFooterView()
        tabelV.delegate = self
        tabelV.dataSource = self
        
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
    }
}
private extension CODSecurityVC {
    
    func createDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
//        let model1 = self.createModel(title: "禁止使用验证码登录", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.smsLogin)
//        dataSource.append([model1])
        
//        let model2 = self.createModel(title: "设置登录密码", subTitle: "", placeholder: "", image: "", type: .baseType,isOn: false)
        
//        if UserManager.sharedInstance.phoneNum?.count ?? 0 > 0 {
            let model3 = self.createModel(title: "登录密码", subTitle: "", placeholder: "", image: "", type: .baseType, isOn: false, tip: "安全")
//        }
        
        
        let subtitle = UserDefaults.standard.string(forKey: kSecurityCode + UserManager.sharedInstance.loginName!)!.count > 0 ? "已开启":"已关闭"
        let model4 = self.createModel(title: "锁定码", subTitle: subtitle, placeholder: "", image: "", type: .baseType, isOn: false, tip: "")
        dataSource.append([model3, model4])
                
        
        let model5 = self.createModel(title: "登录的设备", subTitle: "", placeholder: "", image: "", type: .baseType, isOn: false, tip: "账号")
        dataSource.append([model5])
         
    }
    
    func createModel(title: String = "",
                     subTitle: String = "",
                     placeholder: String = "",
                     image: String = "",
                     type: CODCellType,
                     isOn: Bool,
                     tip: String = "") -> (CODCellModel) {
        var model = CODCellModel()
        model.title = title
        model.subTitle = subTitle
        model.placeholderString = placeholder
        model.type = type
        model.isOn = isOn
        model.iconName = image
        model.tip = tip
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

extension CODSecurityVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let vc = EditPasswordViewController(nibName: "EditPasswordViewController", bundle: Bundle.main)
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                self.navigationController?.pushViewController(CODSecurityCodeConfigViewController(), animated: true)
            default:
                break
            }
            
        }
        
        if indexPath.section == 1 {
            self.navigationController?.pushViewController(CODLoginedDeviceViewController(), animated: true)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODBaseDetailCell.self, forCellReuseIdentifier: "CODBaseDetailCellID")
        tableView.register(CODDetailImageCell.self, forCellReuseIdentifier: "CODDetailImageCellID")
        tableView.register(CODDetailSwitchCell.self, forCellReuseIdentifier: "CODDetailSwitchCellID")
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        let datas = dataSource[section]
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
        } else if case .imageType = model.type  {
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
            cell?.subTitleFont = UIFont.systemFont(ofSize: 15.0)
            cell?.imageStr = model.iconName
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 55))
        bgView.backgroundColor = UIColor.clear
        let textLabel = UILabel.init(frame: CGRect(x: 20, y: 32.5, width: KScreenWidth-42, height: 17))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = UIColor(hexString: kSubTitleColors)

        
        bgView.addSubview(textLabel)

        
        if let model = dataSource[section].first {
            textLabel.text = model.tip
        }

        return bgView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let bgView = UIView.init()
        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func initTableFooterView() -> UIView {
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 51))
        bgView.backgroundColor = UIColor.clear
        let textFrame = CGRect(x: 20, y: 5, width: KScreenWidth-42, height: 46)
        let textLabel = UILabel.init(frame: textFrame)
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineSpacing = 7.0
        let attributes = [NSAttributedString.Key.paragraphStyle : paragraphStyle,
                          NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                          NSAttributedString.Key.foregroundColor : UIColor(hexString: kSubTitleColors)!]


        let attriStr = NSAttributedString(string: NSLocalizedString(CustomUtil.formatterStringWithAppName(str: "开启后，%@切换到后台运行时，自动锁定程序。再次切换到前台时，需输入锁定码解除锁定。"), comment:""), attributes: attributes)
        textLabel.attributedText = attriStr
        bgView.addSubview(textLabel)
        return bgView
    }
    
    func getHeaderString(section: Int) -> String {
        var sectionString = ""
        
        switch section {
        case 0:
//            sectionString = "开启后，将只能使用密码登录，无法通过手机验证码找回密码。"
            sectionString = ""
        case 2:
            sectionString = CustomUtil.formatterStringWithAppName(str: "开启后，%@切换到后台运行时，自动锁定程序。再次切换到前台时，需输入锁定码解除锁定。")
        default:
            sectionString = ""
        }
        return sectionString
    }
    
    func getHeaderHeight(textString: String, width: CGFloat, textFont:UIFont) -> CGFloat {
       var footerHeight = textString.getStringHeight(font: textFont, lineSpacing: 0, fixedWidth: width)
       if footerHeight < 20 {
           footerHeight = 42.5
       }else{
           footerHeight = 57.5
       }
       return footerHeight
    }
    
}

