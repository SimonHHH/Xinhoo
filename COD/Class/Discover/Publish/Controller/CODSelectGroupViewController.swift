//
//  CODSelectGroupViewController.swift
//  COD
//
//  Created by XinHoo on 5/18/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODSelectGroupViewController: BaseViewController {
    
    var selectedArray: Array<CODGroupChatModel>?
    
    typealias SelectedGroupsSuccess = (_ groupList: [CODGroupChatModel]? ) -> Void
    
    var selectedGroupsSuccess: SelectedGroupsSuccess?
        
    /// 群名称未经过筛选搜索的总集合
    var groupAllArr: Array = [CODGroupChatModel]()
    
    var groupOperationArr: Array = [CODGroupChatModel]()
    
    var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("群聊", comment: "")
        
        self.setCancelButton()
        
        self.setRightTextButton()
        rightTextButton.setTitle(NSLocalizedString("完成", comment: ""), for: UIControl.State.normal)
        
        setUpUI()
        getData()
    }
    
    override func navCancelClick() {
        self.navBackClick()
    }
    
    override func navRightTextClick() {
        if self.selectedGroupsSuccess != nil {
            self.selectedGroupsSuccess!(self.selectedArray)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func getData() {
        self.groupAllArr = CODChatListRealmTool.getGroupChatList()
        self.groupOperationArr = groupAllArr
        
        if let selectedArray = self.selectedArray, selectedArray.count > 0 {
            self.selectView.setDataSource(objs: selectedArray)
        }
        
        self.tableView.reloadData()
    }
    
    func setUpUI() {
        self.view.addSubview(selectView)
        selectView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(selectView.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }
    
    fileprivate lazy var selectView:CODGroupMemberSelectView = {
        let selectView = CODGroupMemberSelectView(frame: CGRect.zero)
        selectView.backgroundColor = .clear
        selectView.delegate = self
        selectView.searchDelegate = self
        selectView.placeholder = "请选择群聊"
        return selectView
    }()
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tabelV.estimatedRowHeight = 48
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor(hexString: kVCBgColorS)
        tabelV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.delegate = self
        tabelV.dataSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()

}

extension CODSelectGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupModel = self.groupOperationArr[indexPath.row]
        
        if self.selectedArray == nil {
            self.selectedArray = Array<CODGroupChatModel>()
        }
        
        if var array = self.selectedArray {
            for i in 0..<array.count {
                let model = array[i]
                if model.jid == groupModel.jid {
                    array.remove(at: i)
                    self.selectView.deleteDataSource(index: i)
                    self.selectedArray = array
                    tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    return
                }
            }
        }
        self.selectView.addDataSource(obj: groupModel)
        self.selectedArray?.append(groupModel)
        
        self.selectView.clearTextField()
        self.searchFieldText(text: "")
        
    }
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(UINib(nibName: "CODGroupCanReadTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupCanReadTableViewCell")
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.groupOperationArr.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell: CODGroupCanReadTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CODGroupCanReadTableViewCell", for: indexPath) as! CODGroupCanReadTableViewCell
        
        if indexPath.row == self.groupOperationArr.count - 1 {
            cell.bottomLineLeftConstrains.constant = 0.0
        }else{
            cell.bottomLineLeftConstrains.constant = 101.0
        }
        
        let model = self.groupOperationArr[indexPath.row]
        
        cell.selectedView.image = UIImage(named: "person_select")
        
        if let array = self.selectedArray {
            let _ = array.map { (groupModel) in
                if model.jid == groupModel.jid {
                    cell.selectedView.image = UIImage(named: "person_selected")
                }
            }
        }
        cell.titleLab.text = model.getGroupName()
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.grouppic) { (image) in
            cell.imgBtn.setImage(image, for: .normal)
        }
        cell.showMembersBlock = { [weak self] in
            guard let `self` = self else { return }
            let ctl = CODShowGroupMembersViewController()
            ctl.members = model.member.map({ (memberModel) -> CODGroupMemberModel in
                return memberModel
            })
            self.navigationController?.pushViewController(ctl, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let textFont = UIFont.systemFont(ofSize: 12)
        let sectionHeight: CGFloat = 28
        let textLabel = UILabel.init(frame: CGRect(x: 14, y: 0, width: KScreenWidth-28, height: sectionHeight))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.font = textFont
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(hexString: kSectionHeaderTextColorS)
        textLabel.text = "最近群聊"
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
        bgView.backgroundColor = UIColor(hexString: kVCBgColorS)
        bgView.addSubview(textLabel)
        return bgView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let sectionHeight: CGFloat = 0.01
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
        bgView.backgroundColor = UIColor.clear
        
        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 28.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
}

extension CODSelectGroupViewController : CODGroupMemberSelectDelegate{
    func didSelectDeleteMember(modelArr: Array<AnyObject>) {
        selectedArray = modelArr as? Array<CODGroupChatModel>
        self.tableView.reloadData()

    }
    
    func didSelectDeleteSearchContact(searchUser: CODSearchResultContact) {
        
    }
    
    func collectionViewsContentSizeDidChange(height: CGFloat) {
        print("self.groupMemberSelectView.contentHeight :\(height)")
    }
}

extension CODSelectGroupViewController : CODGroupMemberSearchCellDelegate{
    func selectViewDeleteMember() {
        if (selectedArray?.count ?? 0) > 0 {
            selectedArray?.removeLast()
            tableView.reloadData()
        }
    }
    
    func selectViewSearchTextDidEditChange(field: UITextField) {
        print("搜索内容：\(field.text ?? "nil")")
        
        guard let text = field.text else {
            return
        }
        
        self.searchFieldText(text: text)
    }
    
    func searchFieldText(text: String) {
        self.view.bringSubviewToFront(self.tableView)
        self.groupOperationArr.removeAll()
        
        let textTemp = text.removeHeadAndTailSpacePro
        if textTemp.count > 0 {
            let arr = self.groupAllArr.filter { (object) -> Bool in
                return object.getGroupName().contains(textTemp, caseSensitive: false)
            }
            
            if arr.count > 0 {
                for model in arr {
                    self.groupOperationArr.append(model)
                }
            }else{
                //搜索不到内容不显示，预留做其他处理
            }
        }else{
            for model in groupAllArr {
                self.groupOperationArr.append(model)
            }
        }
        
        self.tableView.reloadData()
    }
}

extension CODSelectGroupViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}

