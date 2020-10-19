//
//  ContactsViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class ContactsViewController: BaseViewController {
    
    var listHeadArr = [["img":"new_friend_icon","title":"新的好友"],
                       ["img":"save_gpChat_icon","title":"已保存的群聊"]] as [Dictionary<String, String>]
    
    var contactList = NSMutableArray()
    

    @IBOutlet weak var tableView: UITableView!
    
    let searchCtl = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "通讯录"
        
        //防止UISearchBar跳动或偏移
        self.definesPresentationContext = true
        self.edgesForExtendedLayout = UIRectEdge.left
        
        self.setRightButton()
        self.rightButton.setImage(UIImage(named: "chat_more"), for: UIControl.State.normal)
        self.rightButton.setImage(UIImage(named: "chat_more_selected"), for: UIControl.State.selected)
        
        self.initContactData()
        
        self.initUI()
    }
    
    func initContactData() {
        let model = CODContactModel()
        model.avatarUrl = "cod_help_icon"
        model.userName = "COD小助手"
        
        contactList.add(model)
        
        let contacts = XMPPManager.shareXMPPManager.getContactArr()
        if (contacts != nil) && (contacts?.count)! > 0 {
            contactList.addObjects(from: contacts!)
        }
        tableView.reloadData()
    }
    
    func initUI() {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 56))
        bgView.addSubview(searchCtl.searchBar)
        searchCtl.searchBar.placeholder = "搜索好友"
        self.tableView.tableHeaderView = bgView
        //取掉上下两条黑线
        searchCtl.searchBar.backgroundImage = UIImage()

    }
    
    override func navRightClick() {
        // 显示更多（发起群聊、添加好友、扫一扫、等）
        self.rightButton.isSelected = !self.rightButton.isSelected
        let moreOptionsView = ChatMoreOptionsView(frame: CGRect(x: Double(CGFloat(kScreenWidth-160.0)), y: kSafeArea_Top+64.0+10.0, width: 150.0, height: 44.0*3))
        weak var weakSelf = self
        moreOptionsView.disappearCloser = {
            weakSelf?.rightButton.isSelected = false
        }
        moreOptionsView.selectRowCloser = {(row : NSInteger) in
            switch row {
            case 0:
                let ctl = CreGroupChatViewController()
                weakSelf?.navigationController?.pushViewController(ctl, animated: true)
            case 1:
                let ctl = AddFriendViewController()
                weakSelf?.navigationController?.pushViewController(ctl, animated: true)
            default:
                let ctl = ScanViewController()
                weakSelf?.navigationController?.pushViewController(ctl, animated: true)
            }
            moreOptionsView.disappear()
        }
        moreOptionsView.show()
        
    }

    


}

extension ContactsViewController :UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{
                self.navigationController?.pushViewController(CODNewFriendVC())
            }else{
                self.navigationController?.pushViewController(CODSavedGroupChatVC())
            }
        }else{
            let model: CODContactModel = contactList[indexPath.row] as! CODContactModel
            let msgCtl = MessageViewController()
            msgCtl.toID = model.userName
            msgCtl.title = model.userName
            self.navigationController?.pushViewController(msgCtl, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 20))
        view.backgroundColor = UIColor(hexString: kVCBgColorS)
        return view
    }
    
}

extension ContactsViewController :UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return listHeadArr.count
        }else{
//            (contactList[section] as! Array<Any>).count  //预留做筛选a-z标签
            return contactList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        }
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        if indexPath.section == 0 {
            let dic = listHeadArr[indexPath.row]
            cell?.imageView?.image = UIImage(named: dic["img"]!)
            cell?.textLabel?.text = dic["title"]
        }else{
            let model: CODContactModel = contactList[indexPath.row] as! CODContactModel
            if (model.userName == "COD小助手") {
                cell?.imageView?.image = UIImage(named: model.avatarUrl!)
            }else{
                cell?.imageView?.sd_setImage(with: NSURL.init(string: model.avatarUrl ?? "")! as URL, placeholderImage: UIImage(named: "default_header_icon_40"))
            }
            cell?.textLabel?.text = model.userName
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    
}
