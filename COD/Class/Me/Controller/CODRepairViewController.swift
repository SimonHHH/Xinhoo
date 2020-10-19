//
//  CODRepairViewController.swift
//  COD
//
//  Created by xinhooo on 2020/7/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class RepairModel:NSObject {
    
    enum Style {
        case none
        case highlighted
    }
    
    var title: String = ""
    var image: String? = nil
    var action: Selector? = nil
    var style: Style = .none
    
    init(title: String, image: String?, action: Selector?, style: Style = .none) {
        self.title = NSLocalizedString(title, comment: "")
        self.image = image
        self.action = action
        self.style = style
        super.init()
    }
    
}


class CODRepairViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [[RepairModel]] = [[]]
    
    var isRepairContact: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "\(kApp_Name)" + NSLocalizedString("修复工具", comment: "")
        self.setBackButton()
        let repairView = CODRepairView.initRepairView()
        self.tableView.tableHeaderView = repairView
        
        self.tableView.tableFooterView = UIView()
        
        initData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(repairSuccess), name: NSNotification.Name.init(kRepairSuccess), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    
    func initData() {
        
        
        let contactModel = RepairModel(title: "联系人修复", image: nil, action: #selector(repairContact))
        let chatListModel = RepairModel(title: "聊天列表修复", image: nil, action: #selector(repairChatList))
        
        dataSource.append([contactModel,chatListModel])
        
        tableView.reloadData()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabShadowImageView()?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.tabShadowImageView()?.isHidden = false
    }

    @objc func repairSuccess() {
        
        if isRepairContact {
            
            isRepairContact = false
            CustomUtil.getSessionItemList(lastPushTime: "0", isFull: true)
            
        }else{
            
            XMPPManager.shareXMPPManager.isRepairData = false
            CODProgressHUD.dismiss()
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: NSLocalizedString("修复成功", comment: ""), message: nil, preferredStyle: .alert)
                alert.addAction(title: NSLocalizedString("确定", comment: ""), style: .cancel, isEnabled: true, handler: nil)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    
    /// 修复联系人
    @objc func repairContact() {
        
        isRepairContact = true
        
        CustomUtil.sendPresenceWithUnavailable()
        
        if let realm = try? Realm() {
        
            try? realm.safeWrite {
                realm.delete(realm.objects(CODContactModel.self))
                realm.delete(realm.objects(CODGroupChatModel.self))
                realm.delete(realm.objects(CODChannelModel.self))
            }
        }
        
        CODProgressHUD.showWithStatus("正在修复数据...")
        XMPPManager.shareXMPPManager.isRepairData = true
        XMPPManager.shareXMPPManager.getRequest(paramStr: "{\"name\":\"getContacts\",\"requester\":\"\(UserManager.sharedInstance.jid)\"}",actionStr: "contacts")
        
    }
    
    /// 修复聊天列表
    @objc func repairChatList() {
        CODProgressHUD.showWithStatus("正在修复数据...")
        
        let realm = try? Realm()
        let normalArr = realm?.objects(CODChatListModel.self).filter("isInValid == \(false)")
        normalArr?.forEach { (listModel) in
            
            switch listModel.chatTypeEnum {
            case .privateChat:

                if listModel.contact == nil || listModel.icon == ""  {
                    
                    try? realm?.safeWrite {
                    
                        if let messages = listModel.chatHistory?.messages {
                        
                            try? Realm().delete(messages)
                        }
                        
                        if let history = listModel.chatHistory {
                        
                            try? Realm().delete(history)
                        }
                        
                        try? Realm().delete(listModel)
                    }
                }

                    
                
            case .groupChat:

                if listModel.groupChat == nil || listModel.icon == ""  {
                    
                    try? realm?.safeWrite {
                    
                        if let messages = listModel.chatHistory?.messages {
                        
                            try? Realm().delete(messages)
                        }
                        
                        if let history = listModel.chatHistory {
                        
                            try? Realm().delete(history)
                        }
                        
                        try? Realm().delete(listModel)
                    }
                }
                
                
            case .channel:
                
                if listModel.channelChat == nil || listModel.icon == ""  {
                    
                    try? realm?.safeWrite {
                    
                        if let messages = listModel.chatHistory?.messages {
                        
                            try? Realm().delete(messages)
                        }
                        
                        if let history = listModel.chatHistory {
                        
                            try? Realm().delete(history)
                        }
                        
                        try? Realm().delete(listModel)
                    }
                }

            }
            
        }
        
        
        XMPPManager.shareXMPPManager.isRepairData = true
        CustomUtil.getSessionItemList(lastPushTime: "0", isFull: true)
    }
    

}

extension CODRepairViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = dataSource[indexPath.section][indexPath.row]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = model.title
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        if cell?.accessoryView == nil {
            let arrowImageView = UIImageView(image: UIImage(named: "next_step_icon"))
            cell?.accessoryView = arrowImageView
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = dataSource[indexPath.section][indexPath.row]
        
        let alert = UIAlertController(title: NSLocalizedString("修复时间可能较长，您确定要修复吗？", comment: ""), message: nil, preferredStyle: .alert)
        
        alert.addAction(title: "确定", style: .default, isEnabled: true) { [weak self] (action) in
        
            if let sel = model.action {
                self?.perform(sel)
            }
        }
        
        alert.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= 200 {
            self.tabShadowImageView()?.isHidden = false
        }else{
            self.tabShadowImageView()?.isHidden = true
        }
        
    }
}
