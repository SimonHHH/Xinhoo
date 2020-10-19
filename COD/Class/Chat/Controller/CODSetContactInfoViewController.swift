//
//  CODSetContactInfoViewController.swift
//  COD
//
//  Created by xinhooo on 2019/4/17.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSetContactInfoViewController: BaseViewController {
    typealias  block = () -> ()
    let maxCellNumber = 2
    var callBack : block?
    
    var model:CODContactModel?
    var telList:Array<String> = Array.init()
    var count = 0
    
    let textView : YZInputView = YZInputView.init(frame: .zero)
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var textViewCos: NSLayoutConstraint!
    @IBOutlet weak var remarkTF: UITextField!
    @IBOutlet weak var telTableView: UITableView!
    @IBOutlet weak var tableViewCos: NSLayoutConstraint!
    @IBOutlet weak var addBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.setBackButton()
        self.rightTextButton.setTitle("完成", for: .normal)
        self.rightTextButton.setTitleColor(UIColor.init(hexString: kBlueTitleColorS), for: .normal)
        self.setRightTextButton()
        self.navigationItem.title = NSLocalizedString("编辑备注", comment: "")
        
        self.remarkTF.text = self.model?.nick
        self.textView.font = UIFont.systemFont(ofSize: 14)
        self.textView.textColor = UIColor.init(hexString: kMainTitleColorS)
        self.backView.addSubview(self.textView)
        self.textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.textView.textContainerInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        self.textView.placeholder = NSLocalizedString("设置描述", comment: "")
        self.textView.text = self.model?.descriptions
        self.textView.yz_textHeightChangeBlock = { [weak self] (text,textHeight) in
            self?.textViewCos.constant = textHeight
        }
        
        self.telTableView.register(UINib.init(nibName: "CODSetTelTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "SettelCell")
        self.telTableView.delegate = self
        self.telTableView.dataSource = self
        
        if let tels = self.model?.tels {
            for tel in tels{
                self.telList.append(tel)
            }
            self.count = self.telList.count
            
            if self.telList.count < 2 {
                
                let a = (2 - self.telList.count)
                for _ in 1...a{
                    self.telList.append("")
                }
            }
            
            self.telTableView.reloadData()
        }
        
//        self.configAddBtn()
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    @IBAction func addTelAction(_ sender: Any) {
        self.count += 1
        self.configAddBtn()
    }
    
    override func navRightClick() {
        
        var telArr:Array<String> = Array.init()
        for cell in self.telTableView.visibleCells {
            let telCell = cell as! CODSetTelTableViewCell
            if telCell.phoneTF.text!.count > 0{
                
                telArr.append(telCell.phoneTF.text!)
            }
        }
        
        let  dict:NSDictionary = ["name":COD_changeChat,
                                  "requester":UserManager.sharedInstance.jid,
                                  "itemID":self.model?.rosterID as Any,
                                  "setting":["nick":self.remarkTF.text as Any,"description":self.textView.text as Any,"tels":telArr]]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func configAddBtn() {
        
        if self.count > 1 {
            self.addBtn.titleLabel?.text = "电话号码"
            self.addBtn.setTitle("电话号码", for: .normal)
            self.addBtn.setTitleColor(UIColor.init(hexString: kSubTitleColors), for: .normal)
            self.addBtn.isUserInteractionEnabled = false
        }else{
            self.addBtn.titleLabel?.text = "添加电话号码"
            self.addBtn.setTitle("添加电话号码", for: .normal)
            self.addBtn.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: .normal)
            self.addBtn.isUserInteractionEnabled = true
        }
        self.telTableView.isHidden = true
//        self.tableViewCos.constant = CGFloat(44 * self.count)
        self.telTableView.reloadData()
        self.telTableView.setEditing(true, animated: true)
    }
    
    deinit {
        print("设置个人备注、号码页面被销毁")
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

extension CODSetContactInfoViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CODSetTelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettelCell", for: indexPath) as! CODSetTelTableViewCell
        
        cell.phoneTF.text = self.telList[indexPath.row]
        cell.endEdit = { [weak self](text) in
            
            self?.telList.remove(at: indexPath.row)
            self?.telList.insert(text, at: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

            self.telList.remove(at: indexPath.row)
            self.telList.append("")
            self.count -= 1
            self.configAddBtn()
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}


extension CODSetContactInfoViewController:XMPPStreamDelegate{
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { (actionDic, infoDic) in
            guard let infoDic = infoDic else {
                return
            }
            if (actionDic["name"] as? String == COD_changeChat){
                if !(infoDic["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus("设置失败")
                    return
                }
                
                if let model = self.model {
                    try! Realm.init().write {
                        
                        model.nick = self.remarkTF.text ?? ""
                        model.descriptions = self.textView.text
                        
                        var telArr:Array<String> = Array.init()
                        for cell in self.telTableView.visibleCells {
                            let telCell = cell as! CODSetTelTableViewCell
                            if telCell.phoneTF.text!.count > 0{
                                telArr.append(telCell.phoneTF.text!)
                            }
                        }
                        if telArr.count > 0{
                            model.tels.removeAll()
                            for tel in telArr{
                                model.tels.append(tel)
                            }
                        }else{
                            model.tels.removeAll()
                        }
                        
                        
                        if let title = self.remarkTF.text {
                            if title.count > 0 {
                                model.pinYin = ChineseString.getPinyinBy(title)
                            }else {
                                model.pinYin = ChineseString.getPinyinBy(model.getContactNick())
                            }
                        }
                    }
                    if let title = self.remarkTF.text {
                        if title.count > 0 {
                            CODChatListRealmTool.updateChatListTitleByChatId(chatId: model.rosterID, andTitle: title)
                            
                            if let members = CODGroupMemberRealmTool.getMembersByJid(model.jid) {
                                try! Realm.init().write {
                                    for member in members {
                                        member.pinYin = ChineseString.getPinyinBy(title)
                                    }
                                }
                            }
                            
                            
                        }else {
                            CODChatListRealmTool.updateChatListTitleByChatId(chatId: model.rosterID, andTitle: model.getContactNick())
                            
                            if let members = CODGroupMemberRealmTool.getMembersByJid(model.jid) {
                                try! Realm.init().write {
                                    for member in members {
                                        member.pinYin = ChineseString.getPinyinBy(member.getMemberNickName())
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    
                }
                
//                CODProgressHUD.showSuccessWithStatus("设置成功")
                if self.callBack != nil{
                    self.callBack!()
                }
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        
        return true
    }
}
