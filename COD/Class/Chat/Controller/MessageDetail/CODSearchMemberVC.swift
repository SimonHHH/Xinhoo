//
//  CODSearchMemberVC.swift
//  COD
//
//  Created by XinHoo on 2019/12/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSearchMemberVC: BaseViewController {
    
    var sourceDatas:[CODGroupMemberModel] = [CODGroupMemberModel]() ///所有成员的数据
    private var searchDatas:[CODGroupMemberModel] = [CODGroupMemberModel]() ///搜索的数据
    private let searchPlaceholder = "搜索"
    private var searchStr = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchDatas = sourceDatas
        
        self.navigationController?.navigationBar.isHidden = true
        self.definesPresentationContext = true
        
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.searchTableView)
        
        
        
        self.addSnpkit()
        self.searchBar.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.searchBar.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    fileprivate lazy var searchBar: CODSearchBar = {
        let searchBar = CODSearchBar(frame: CGRect.zero)
        searchBar.backgroundColor = UIColor(hexString: kVCBgColorS)
        searchBar.barTintColor = UIColor.init(hexString: kVCBgColorS)
        searchBar.tintColor = UIColor.init(hexString: kBlueTitleColorS)
        searchBar.placeholder = searchPlaceholder
        searchBar.customTextField?.font = UIFont.systemFont(ofSize: 14)
        searchBar.customTextField?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
        searchBar.delegate = self
        searchBar.customTextField?.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControl.Event.editingChanged)
        self.searchTableView.register(UINib.init(nibName: "CODGroupMemberAdvTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupMemberAdvTableViewCell")
        return searchBar
    }()
    
    //搜索的显示视图
    fileprivate lazy var searchTableView:UITableView = {
        let searchTableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.emptyDataSetSource = self
        searchTableView.backgroundColor = UIColor.init(hexString: kVCBgColorS)
        searchTableView.estimatedRowHeight = 80
        searchTableView.rowHeight = UITableView.automaticDimension
        searchTableView.estimatedSectionHeaderHeight = 0
        searchTableView.estimatedSectionFooterHeight = 0
        searchTableView.tableHeaderView =  UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        if #available(iOS 11.0, *) {
            searchTableView.contentInsetAdjustmentBehavior = .never
        }
        return searchTableView
    }()
    
    fileprivate func addSnpkit(){
        searchBar.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view).offset(KNAV_STATUSHEIGHT)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        })

        searchTableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo((self.searchBar.snp.bottom)).offset(0)
            make.bottom.equalToSuperview()
        }
    }
}

extension CODSearchMemberVC :UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = searchDatas[indexPath.row]
        self.pushToDetailVC(model: model)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 20))
        view.backgroundColor = .clear
        return view
    }
}

extension CODSearchMemberVC :UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.searchDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CODGroupMemberAdvTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CODGroupMemberAdvTableViewCell", for: indexPath) as! CODGroupMemberAdvTableViewCell
        let model = self.searchDatas[indexPath.row]

        if indexPath.row == sourceDatas.count - 1 {
            cell.isLast = true
        }else{
            cell.isLast = false
        }
        if indexPath.row == 0 {
            cell.isTop = true
        }else{
            cell.isTop = false
        }
        cell.titleStr = model.getMemberNickName()
        if model.loginStatus.count > 0 {
            let result = CustomUtil.getOnlineTimeStringAndStrColor(with: model)
            cell.attributeSubTitleStr = NSAttributedString(string: result.timeStr).colored(with: result.strColor)
        }else{
            cell.attributeSubTitleStr = nil
        }
        var placeHolder = ""
        switch model.userpower {
        case 10:
            placeHolder = NSLocalizedString("群主", comment: "")
        case 20:
            placeHolder = NSLocalizedString("管理员", comment: "")
        default:
            placeHolder = ""
        }
        if placeHolder.count > 0 {
            cell.placeholderStr = placeHolder
        }else{
            cell.placeholderStr = nil
        }
        
        cell.userType = model.userTypeEnum
        
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.userpic) { (image) in
            cell.imgView.image = image
        }
        return cell
    }
    
}

extension CODSearchMemberVC:UISearchBarDelegate{
    ///开始编辑
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //开始
        searchBar.showsCancelButton = true
        searchBar.setCancelButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        ///取消
        self.navigationController?.popViewController(animated: false)
    }
    
    /* 点击了清空文字按钮 */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchStr = searchText
        self.searchDatas.removeAll()
        if searchText.count > 0 {
            self.searchDatas = self.sourceDatas.filter({ (memberModel) -> Bool in
                var remarkName = ""
                if let contact = CODContactRealmTool.getContactByJID(by: memberModel.jid) {
                    if contact.nick.count > 0 {
                        remarkName = contact.nick
                    }
                }
                return memberModel.nickname.contains(searchText, caseSensitive: false) || memberModel.name.contains(searchText, caseSensitive: false) || remarkName.contains(searchText, caseSensitive: false)
            })
        }else{
            self.searchDatas = self.sourceDatas
        }
        self.searchTableView.reloadData()
    }
    /*点击搜索*/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        ///关闭编辑
//        searchBar.endEditing(true)
        self.view.endEditing(true)
        
    }
    
    ///内容变化
    @objc func textFieldChanged(textField:UITextField) {
        if textField.text?.count == 0 {
            return
        }
        searchStr = textField.text!
        ///搜索好友
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func getSearchBarPlaceholderWidth() -> CGFloat {
    
        let textWidth = searchPlaceholder.getStringWidth(font: self.searchBar.customTextField?.font ?? UIFont.systemFont(ofSize: 17), lineSpacing: 0, fixedWidth: KScreenWidth)
        
        return 50 + textWidth
    }
}

extension CODSearchMemberVC: EmptyDataSetSource {
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        let view = UIView()
        view.isHidden = false
        view.backgroundColor = UIColor.init(hexString: kVCBgColorS)
        let label = UILabel()
        label.text = NSLocalizedString("无结果", comment: "")
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = UIColor.init(hexString: kSubTitleColors)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-150)
        }
        return view
    }
}

extension CODSearchMemberVC {
    
    func pushToDetailVC(model: CODGroupMemberModel){
        if model.jid == UserManager.sharedInstance.jid {
            return
        }
        if model.jid == (kCloudJid + XMPPSuffix) || UserManager.sharedInstance.jid.contains(model.username){
            let msgCtl = MessageViewController()
            msgCtl.chatType = .privateChat
            msgCtl.toJID = model.jid
            if UserManager.sharedInstance.jid.contains(model.username){
              msgCtl.toJID = kCloudJid + XMPPSuffix
            }
            msgCtl.chatId = CloudDiskRosterID
            msgCtl.title = NSLocalizedString("我的云盘", comment: "")
            self.navigationController?.pushViewController(msgCtl, animated: true)
            return
        }
        if let contact = CODContactRealmTool.getContactByUsername(username: model.username.subStringTo(string: "@")) {
            if contact.isValid {
                CustomUtil.pushToPersonVC(contactModel: contact)
            }else{
                CustomUtil.pushToStrangerVC(type: .searchType, contactModel: contact)
            }
            
        }else{
            
            CustomUtil.pushToStrangerVC(type: .searchType, memberModel: model)
        }
    }
    
    
}

extension CODSearchMemberVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
