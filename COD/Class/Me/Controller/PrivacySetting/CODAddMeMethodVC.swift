//
//  CODAddMeMethodVC.swift
//  COD
//
//  Created by 1 on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODAddMeMethodVC: BaseViewController ,XMPPStreamDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("添加我的方式", comment: "")
        self.setBackButton()
        self.createDataSource()
        self.setUpUI()
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
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
//        var isOnInt = 0
//        if isOn {
//            isOnInt = 1
//        }
//        
        var dict:NSDictionary? = [:]
        
        if indexPath.section == 0 {
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
        
        if indexPath.section == 1 {
            if indexPath.row == 0{
                dict = ["name":COD_changePerson,
                        "requester":UserManager.sharedInstance.jid,
                        "setting":["addingroup":isOn]]
            }
            
            if indexPath.row == 1{
                dict = ["name":COD_changePerson,
                        "requester":UserManager.sharedInstance.jid,
                        "setting":["addinqrcode":isOn]]
                
                if !isOn {

                    let mD5Url = HttpConfig.COD_QRcode_DownLoadUrl.md5() + UserManager.sharedInstance.loginName!
                    let fileName = CODFileManager.shareInstanceManger().getPersonFilePath(userPath: "qrCode", fileName: mD5Url, formatString: ".png")
                    if FileManager.default.fileExists(atPath:fileName) {
                        do {
                            try FileManager.default.removeItem(atPath: fileName)
                        }catch{
                            print("个人二维码移除失败")
                        }
                    }
                    
                }
              

            }
            
            if indexPath.row == 2{
                dict = ["name":COD_changePerson,
                        "requester":UserManager.sharedInstance.jid,
                        "setting":["addincard":isOn]]
            }
        }
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: dict!)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
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
                
                if (dict["addingroup"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.addingroup = (dict["addingroup"] as! String).bool!
                    }
                }
                
                if (dict["addinqrcode"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.addinqrcode = (dict["addinqrcode"] as! String).bool!
                    }
                }
                
                if (dict["addincard"] as? String != nil){
                    if (infoDic["success"] as! Bool) {
                        UserManager.sharedInstance.addincard = (dict["addincard"] as! String).bool!
                    }
                }
            }
        }
        
        return true
    }
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
    }
    
    
}
private extension CODAddMeMethodVC {
    
    func createDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
        let model1 = self.createModel(title: "手机号码", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.searchtel)
        let model2 = self.createModel(title: "用户名", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.searchUser)
        dataSource.append([model1,model2])
        
//        let model3 = self.createModel(title: "群组", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.addingroup)
//        let model4 = self.createModel(title: "二维码", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.addinqrcode)
//        let model5 = self.createModel(title: "名片", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserManager.sharedInstance.addincard)
//
//        dataSource.append([model3,model4,model5])
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

extension CODAddMeMethodVC:UITableViewDelegate,UITableViewDataSource{
    
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
            cell?.imageStr = model.iconName
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let textString = self.getHeaderString(section: section)
        let textFont = UIFont.systemFont(ofSize: 12)
        var sectionHeight: CGFloat = 0.01
        sectionHeight = self.getHeaderHeight(textString: textString, width: KScreenWidth, textFont: textFont)
        
        var textFrame = CGRect(x: 20, y: 20, width: KScreenWidth-42, height: 17)
        if section == 1{
            textFrame = CGRect(x: 20, y: 5, width: KScreenWidth-42, height: 46)
        }
        
        let textLabel = UILabel.init(frame: textFrame)
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
        let sectionHeight = 0.01
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: CGFloat(sectionHeight)))
        bgView.backgroundColor = UIColor.clear
        
        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let textString = self.getHeaderString(section: section)
        let textFont = UIFont.systemFont(ofSize: 12)
        var sectionHeight = self.getHeaderHeight(textString: textString, width: KScreenWidth, textFont: textFont)
//        if section == 1 {
//             sectionHeight  = sectionHeight
//        }
        return sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func getHeaderString(section: Int) -> String {
        var sectionString = ""
        
        switch section {
        case 0:
            sectionString = "可以通过以下方式找到我。"
        case 1:
            sectionString = ""//"关闭后，其他用户将不能通过上述信息找到你。\n\n可以通过以下方式添加我。"
        default:
            sectionString = ""
        }
        return sectionString
    }
    
    func getHeaderHeight(textString: String, width: CGFloat,textFont:UIFont) -> CGFloat {
        
        var footerHeight = textString.getStringHeight(font: textFont, lineSpacing: 0, fixedWidth: width)
        if footerHeight < 20 {
            footerHeight = 42.5
        }else{
            footerHeight = 57.5
        }
        return footerHeight
    }
}

