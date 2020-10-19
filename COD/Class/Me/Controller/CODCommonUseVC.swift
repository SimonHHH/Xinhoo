//
//  CODCommonUseVC.swift
//  COD
//
//  Created by 1 on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import AdSupport

class CODCommonUseVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("通用", comment: "")
        self.setBackButton()
        self.createDataSource()
        self.setUpUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name.init(kChangeLanguageNoti), object: nil)
    }
    
    @objc func reloadView() {
        
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
    
    
}
private extension CODCommonUseVC {
    
    func createDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
//        let model1 = self.createModel(title: "多语言", subTitle: "", placeholder: "", image: "", type: .baseType)
        let model2 = self.createModel(title: "字体大小", subTitle: "", placeholder: "", image: "", type: .baseType)
        let model3 = self.createModel(title: "聊天背景", subTitle: "", placeholder: "", image: "", type: .baseType)
//        let model4 = self.createModel(title: "缓存设置", subTitle: "", placeholder: "", image: "", type: .baseType)
//        let model5 = self.createModel(title: "一键清除聊天记录", subTitle: "", placeholder: "", image: "", type: .baseType)

        dataSource.append([model2,model3/*,model5*/])
        
//        let model6 = self.createModel(title: "关于", subTitle: "", placeholder: "", image: "", type: .baseType)
//        dataSource.append([model6])
        
//        let model7 = self.createModel(title: "退出登录", subTitle: "", placeholder: "", image: "", type: .deleteType)
//        dataSource.append([model7])
  
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
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }
}

extension CODCommonUseVC:UITableViewDelegate,UITableViewDataSource{
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODDetailImageCell.self, forCellReuseIdentifier: "CODDetailImageCellID")
        tableView.register(CODBaseDetailCell.self, forCellReuseIdentifier: "CODBaseDetailCellID")
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
            cell?.imageStr = model.iconName
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
                cell?.titleC = UIColor.black
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
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 42.5))
        bgView.backgroundColor = UIColor.clear
        let textLabel = UILabel.init(frame: CGRect(x: 20, y: 20, width: KScreenWidth-42, height: 17))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = UIColor(hexString: kSubTitleColors)
        textLabel.text = "聊天"
        
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

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                self.pushChangeFontVC()
            case 1:
                self.pushChatBGImageVC()
//            case 2:
//                self.clearData()
            default:
                break
            }
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
        
//        if indexPath.section == 1 {
//            self.showAboutVC()
//        }
        
//        if indexPath.section == dataSource.count - 1 {
//            self.loginOut()
//
//        }
    }
}

private extension CODCommonUseVC{
    
    //多语言
//    func pushLanguageSettingsVC() {
//        self.navigationController?.pushViewController(CODLanguageSettingsVC(), animated: true)
//    }
    
    ///MARK: 字体大小
    func pushChangeFontVC() {
        self.navigationController?.pushViewController(CODChangeFontViewController(),animated: true)
    }
    
//    func showAboutVC() {
//        let ctl = CODAboutViewController()
//        self.navigationController?.pushViewController(ctl, animated: true)
//    }
    
    //MARK:聊天背景
    func pushChatBGImageVC() {
        self.navigationController?.pushViewController(CODChatBGImageViewController(),animated: true)
    }
    
    //MARK:缓存设置
//    func pushCacheSet() {
//        self.navigationController?.pushViewController(CODCacheSetViewController(),animated: true)
//    }
    
    //MARK:清除所有聊天记录
    func clearData() {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: nil, message: "将一键清除所有个人和群的聊天记录", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "取消", style: .default, handler: { (action) in
                
            }))
            alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                
                CODFileManager.shareInstanceManger().deleteEMConversationAllFilePath()
//                try! Realm.init().write {
//
//                    try! Realm.init().delete(Realm.init().objects(FileModelInfo.self))
//                    try! Realm.init().delete(Realm.init().objects(LocationInfo.self))
//                    try! Realm.init().delete(Realm.init().objects(PhotoModelInfo.self))
//                    try! Realm.init().delete(Realm.init().objects(VideoCallModelInfo.self))
//                    try! Realm.init().delete(Realm.init().objects(VideoModelInfo.self))
//                    try! Realm.init().delete(Realm.init().objects(AudioModelInfo.self))
//                    try! Realm.init().delete(Realm.init().objects(BusinessCardModelInfo.self))
//
//                    try! Realm.init().delete(Realm.init().objects(CODMessageModel.self))
//                    try! Realm.init().delete(Realm.init().objects(CODChatHistoryModel.self))
//                    try! Realm.init().delete(Realm.init().objects(CODChatListModel.self))
                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadCallVC), object: nil, userInfo:nil)
//                }
                
                let chatList = CODChatListRealmTool.getChatList()
                
                chatList.forEach { (listModel) in
                    if listModel.id != CloudDiskRosterID {
                        CODChatListRealmTool.removeChatList(id: listModel.id)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadCallVC), object: nil, userInfo:nil)
            }))
            
            
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

