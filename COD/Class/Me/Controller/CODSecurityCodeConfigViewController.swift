//
//  CODSecurityCodeConfigViewController.swift
//  COD
//
//  Created by xinhooo on 2019/5/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import LPActionSheet

class CODSecurityCodeConfigViewController: BaseViewController {
    
    let lineSpacingFloat: CGFloat = 3.0
    let actionSheetTextColor = UIColor(hexString: kSubmitBtnBgColorS)

    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: Array = [[CODCellModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setBackButton()
        self.navigationItem.title = NSLocalizedString("锁定码", comment: "")
        
        
        // Do any additional setup after loading the view.
        self.configView()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createDataSource()
    }
    
    func configView() {
        tableView.register(CODBaseDetailCell.self, forCellReuseIdentifier: "CODBaseDetailCellID")
        tableView.register(CODDetailImageCell.self, forCellReuseIdentifier: "CODDetailImageCellID")
        tableView.register(CODDetailSwitchCell.self, forCellReuseIdentifier: "CODDetailSwitchCellID")
    }
    
    func createDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
        
        if UserDefaults.standard.string(forKey: kSecurityCode + UserManager.sharedInstance.loginName!)!.count > 0{
            let model1 = self.createModel(title: "锁定码", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: true)
            dataSource.append([model1])
            
            let model2 = self.createModel(title: "安全防护", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserDefaults.standard.bool(forKey: kSecurityCode_ClearData + UserManager.sharedInstance.loginName!))
            dataSource.append([model2])
            
//            let model3 = self.createModel(title: "通讯流畅保护", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: UserDefaults.standard.bool(forKey: kSecurityCode_Smooth + UserManager.sharedInstance.loginName!))
//            dataSource.append([model3])
            
            let model4 = self.createModel(title: "重置锁定码", subTitle: "", placeholder: "", image: "", type: .baseType,isOn: false)
            let model5 = self.createModel(title: "自动锁定", subTitle: SecurityCodeAutoLocking.timeValueString, placeholder: "", image: "", type: .baseType,isOn: false)
            dataSource.append([model4, model5])
        }else{
            let model1 = self.createModel(title: "锁定码", subTitle: "", placeholder: "", image: "", type: .switchType,isOn: false)
            dataSource.append([model1])
        }
        
        tableView.reloadData()
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
    
    func clickSwitch(indexPath:IndexPath,isOn:Bool) {
        
        switch indexPath.section {
        case 0:
            if isOn {
                self.navigationController?.pushViewController(CODSecurityCodeSetViewController(vcType: .set), animated: true)
            }else{
                UserDefaults.standard.set("", forKey: kSecurityCode + UserManager.sharedInstance.loginName!)
                UserDefaults.standard.set(false, forKey: kSecurityCode_ClearData + UserManager.sharedInstance.loginName!)
                UserDefaults.standard.set(false, forKey: kSecurityCode_Smooth + UserManager.sharedInstance.loginName!)
            }
            break
        case 1:
            UserDefaults.standard.set(isOn, forKey: kSecurityCode_ClearData + UserManager.sharedInstance.loginName!)
            break
        case 2:
            UserDefaults.standard.set(isOn, forKey: kSecurityCode_Smooth + UserManager.sharedInstance.loginName!)
            break
        default:
            break
        }
        if UserDefaults.standard.synchronize(){
            self.createDataSource()
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension CODSecurityCodeConfigViewController:UITableViewDelegate,UITableViewDataSource{
    
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
                self?.clickSwitch(indexPath: indexPath, isOn: isOn)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                self.navigationController?.pushViewController(CODSecurityCodeSetViewController(vcType: .reset), animated: true)
            default:
                let otherBtnColors: [UIColor] = SecurityCodeAutoLocking.timeValueStringArr.map { (_) -> UIColor in
                    return actionSheetTextColor!
                }
                CODActionSheet(title: "", cancelButtonTitle: NSLocalizedString("取消", comment: ""), destructiveButtonTitle: "", otherButtonTitles: SecurityCodeAutoLocking.timeValueStringArr, cancelButtonColor: actionSheetTextColor, destructiveButtonColor: actionSheetTextColor, otherButtonColors: otherBtnColors) { [weak self] (actionSheep, index) in
                    
                    let indexInt = index - 1
                    if indexInt >= 0 {
                        SecurityCodeAutoLocking.setTimeValue(value: indexInt)
                        self?.createDataSource()
                    }
                    
                }.show()
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let textString = self.getHeaderString(section: section)
        let textFont = UIFont.systemFont(ofSize: 12)
        var sectionHeight: CGFloat = 0.01
        let labelWidth = KScreenWidth - 40
        sectionHeight = self.getHeaderHeight(textString: textString, width: labelWidth, textFont: textFont)
        let labelHeight = textString.getStringHeight(font: textFont, lineSpacing: lineSpacingFloat, fixedWidth: labelWidth)
        let textLabel = UILabel.init(frame: CGRect(x: 20, y: 4, width: labelWidth, height: labelHeight))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.numberOfLines = 0
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = lineSpacingFloat
        let attributs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: textFont, NSAttributedString.Key.foregroundColor: UIColor(hexString: kSubTitleColors)!, NSAttributedString.Key.paragraphStyle: paragraph]
        textLabel.attributedText = NSMutableAttributedString(string: textString, attributes: attributs)
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
        bgView.backgroundColor = UIColor.clear
        bgView.addSubview(textLabel)
        
        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if [0,1,2].contains(section){
            let textString = self.getHeaderString(section: section)
            let textFont = UIFont.systemFont(ofSize: 12)
            return  self.getHeaderHeight(textString: textString, width: KScreenWidth - 40, textFont: textFont)
        }
        return 0.01
    }
    
    func getHeaderString(section: Int) -> String {
        var sectionString = ""
        
        switch section {
        case 0:
            sectionString = CustomUtil.formatterStringWithAppName(str: "开启后，%@切换到后台运行时，自动锁定程序。再次切换到前台时，需输入锁定码解除锁定。")
        case 1:
            sectionString = NSLocalizedString("开启后，解除页面锁定时，密码连续5次输入错误，将清除所有本地聊天记录。", comment: "")
        default:
            sectionString = ""
        }
        return sectionString
    }
    
    func getHeaderHeight(textString: String, width: CGFloat,textFont:UIFont) -> CGFloat {
        
        var footerHeight = textString.getStringHeight(font: textFont, lineSpacing: lineSpacingFloat, fixedWidth: width)
        footerHeight = footerHeight + 4 + 8
        return footerHeight
    }
    
    
}


