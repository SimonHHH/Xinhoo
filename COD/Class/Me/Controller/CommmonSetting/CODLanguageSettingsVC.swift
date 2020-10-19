//
//  CODLanguageSettingsVC.swift
//  COD
//
//  Created by 1 on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODLanguageSettingsVC: BaseViewController {
    
    private var lastIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
//        self.rightTextButton.setTitle("完成", for: .normal)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.rightTextButton)
        self.setUpUI()
//        var  language = ""
        
        if let language = UserDefaults.standard.object(forKey: kMyLanguage) as? String,language.count > 0 {
            
            
            if language == "zh-Hans" {
                self.lastIndexPath = IndexPath.init(row: 0, section: 0)
            }
            
            if language == "zh-Hant" {
                self.lastIndexPath = IndexPath.init(row: 1, section: 0)
            }
            
            if language == "en" {
                self.lastIndexPath = IndexPath.init(row: 2, section: 0)
            }
            
        }else{
            let arr = UserDefaults.standard.object(forKey: "AppleLanguages") as? NSArray
            let languageStr = arr?.firstObject as? String
            if (languageStr?.contains("zh-Hans"))! {
                self.lastIndexPath = IndexPath.init(row: 0, section: 0)
            }else if (languageStr?.contains("en"))! {
                self.lastIndexPath = IndexPath.init(row: 2, section: 0)
            }else if (languageStr?.contains("zh-Hant"))! {
                self.lastIndexPath = IndexPath.init(row: 1, section: 0)
            }else{
                self.lastIndexPath = IndexPath.init(row: 2, section: 0)
            }
        }
        
        self.reloadView()
        
    }
     private var dataSource: Array = ["中文(简体)","中文(繁体)","English"]
    
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
    override func navRightTextClick() {
        print("点击完成")
        self.navigationController?.popViewController()
    }
}
extension CODLanguageSettingsVC{
    func setUpUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }
}

extension CODLanguageSettingsVC:UITableViewDelegate,UITableViewDataSource{
    
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
        let textLabel = UILabel.init(frame: CGRect(x: 20, y: 20, width: KScreenWidth-42, height: 17))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = UIColor(hexString: kSubTitleColors)
        textLabel.text = "请选择一种语言"
        bgView.addSubview(textLabel)
        return bgView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        bgView.backgroundColor = UIColor.clear
        
        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 42.5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if lastIndexPath.row != indexPath.row{

            lastIndexPath = indexPath

            var language = ""
            var lang = ""
            switch indexPath.row {
            case 0:
                language = "zh-Hans"
                lang = "zh"
            case 1:
                language = "zh-Hant"
                lang = "zht"
            case 2:
                language = "en"
                lang = "en"
            default:
                language = ""
            }
                    
            let requestUrl = HttpConfig.updateLang
            CODProgressHUD.showWithStatus(nil)
            HttpManager().post(url: requestUrl, param: ["username":UserManager.sharedInstance.loginName ?? "",
                                                        "lang":lang],
                               successBlock: { (result, json) in
                                

                                Bundle.setLanguage(language)
                                UserDefaults.standard.set(language, forKey: kMyLanguage)
                                UserDefaults.standard.synchronize()
                                AutoSwitchIPManager.share.updateServerList()
                                self.reloadView()
                                NotificationCenter.default.post(name: NSNotification.Name.init(kChangeLanguageNoti), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name.init(kChangeRootCtlNoti), object: nil, userInfo: nil)
                                CODProgressHUD.dismiss()
            }) { (error) in
                CODProgressHUD.showErrorWithStatus(error.message)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func reloadView() {
        self.navigationItem.title = NSLocalizedString("语言设置", comment: "")
        self.tableView.reloadData()
    }
    
}
