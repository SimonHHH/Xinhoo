//
//  CODBlackListViewController.swift
//  COD
//
//  Created by xinhooo on 2019/4/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODBlackListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource:Array<CODContactModel> = Array()
    var notificationToken:NotificationToken? = nil
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("黑名单", comment: "")
        self.setBackButton()
        
        self.tableView.register(CODBlackListCell.self, forCellReuseIdentifier: "blackListCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.getDataSource()
        
        notificationToken = try! Realm.init().objects(CODContactModel.self).filter("blacklist = true").observe({ [weak self] (changes) in
            guard let `self` = self else { return }
            switch changes{
                
            case .initial(_):
                break
            case .update(_, _,  _,  _):
                self.getDataSource()
            case .error(_):
                break

            }
        })
    }

    
    func getDataSource() {
        
        dataSource.removeAll()
        let realm = try! Realm.init()
        let results = realm.objects(CODContactModel.self).filter("blacklist = true")
        for model in results {
            dataSource.append(model)
        }
        
        if dataSource.count > 0 {
            self.tableView.tableFooterView = self.footView
        }else{
            self.tableView.tableFooterView = nil
        }
        
        self.tableView.reloadData()
        self.tableView.reloadEmptyDataSet()
        
    }
    
    lazy var footView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 44))
        
        let lab = UILabel(text: NSLocalizedString("加入黑名单,您将不再收到对方的消息,对方也无法将您加入群组和频道", comment: ""))
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.textColor = UIColor(hexString: kWeakTitleColorS)
        lab.font = UIFont.systemFont(ofSize: 12.0)
        view.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 7, left: 21, bottom: 7, right: 21))
        }
        return view
    }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CODBlackListViewController:UITableViewDataSource,UITableViewDelegate,EmptyDataSetDelegate,EmptyDataSetSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let contact = self.dataSource[indexPath.row]

        
        let cell: CODBlackListCell = tableView.dequeueReusableCell(withIdentifier: "blackListCell", for: indexPath) as! CODBlackListCell
        cell.title = contact.getContactNick()
        if indexPath.row == dataSource.count - 1 {
            cell.isLast = true
        }else{
            cell.isLast = false
        }
        cell.userpic = contact.userpic
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = self.dataSource[indexPath.row]
        if contact.isValid {
            CustomUtil.pushToPersonVC(contactModel: contact)
        }else{
            
            CustomUtil.pushToStrangerVC(type: .cardType, contactModel: contact)
        }

    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let contact = self.dataSource[indexPath.row]
        let action = UITableViewRowAction(style: .destructive, title: "移除黑名单") { (action, indexPath) in
            let dict = ["name":COD_changeChat,
                        "requester":UserManager.sharedInstance.jid,
                        "itemID":contact.rosterID,
                        "setting":["blacklist":false]] as [String : Any]
            
            XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_setting) { (result) in
                switch result {
                case .success(_):
                    try! Realm.init().write {
                        contact.blacklist = false
                    }
                    break
                case .failure(_):
                    CODProgressHUD.showErrorWithStatus("设置失败")
                }
            }
            
        }
        return [action]
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString.init(string: NSLocalizedString("加入黑名单,您将不再收到对方的消息,对方也无法将您加入群组和频道", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.init(name: "PingFangSC-Light", size: 14) as Any,NSAttributedString.Key.foregroundColor:UIColor.init(hexString: kEmptyTitleColorS)!])
    }

    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    
}
