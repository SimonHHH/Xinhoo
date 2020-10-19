//
//  CODGroupMemberViewController.swift
//  COD
//
//  Created by xinhooo on 2019/5/17.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

@objc protocol CODGroupMemberViewControllerDelegate {
    //代理方法
    func clickCell(model:CODGroupMemberModel, location:Int)
}

class CODGroupMemberViewController: BaseViewController {

    var location = 0
    var memberArr = List<CODGroupMemberModel>()
    var userpic = ""
    var isAdmin  = false
    var chatId = 0
    weak var delegate:CODGroupMemberViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    /// 数据源
    private var dataArray = [[CODGroupMemberModel]]()
    /// 每个 section 的标题
    private var sectionTitleArray = [String]()
    private var indexedCollation = UILocalizedIndexedCollation.current()
    
//    let searchCtl = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("选择提醒的人", comment: "")
        
        let backBtn = UIButton.init(type: .custom)
        backBtn.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
        backBtn.setTitleColor(UIColor.black, for: .normal)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        backBtn.addTarget(self, action: #selector(customDismiss), for: .touchUpInside)
        backBtn.sizeToFit()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
        
        backBtn.widthAnchor.constraint(equalToConstant: backBtn.frame.width + 30).isActive = true
        
        
        
//        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 56))
//        bgView.backgroundColor = UIColor.init(hexString: "#EAEAEA")
//        searchCtl.searchBar = self.searchBar
        
//        searchCtl.searchBar.placeholder = "搜索好友"
//        searchCtl.delegate = self
//        searchCtl.searchResultsUpdater = self
//        searchCtl.dimsBackgroundDuringPresentation = false
//        searchCtl.hidesNavigationBarDuringPresentation = false

//        self.definesPresentationContext = false
//        self.modalPresentationStyle = UIModalPresentationStyle.currentContext
//        bgView.addSubview(searchCtl.searchBar)
//        self.tableView.tableHeaderView = searchCtl.searchBar
        //取掉上下两条黑线
        self.searchBar.backgroundImage = UIImage()
        
        
        let searchBarTF = self.searchBar.customTextField
        searchBarTF?.delegate = self
        searchBarTF?.font = UIFont.systemFont(ofSize: 17)
        searchBarTF?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
        searchBarTF?.addTarget(self, action: #selector(searchTextChange), for: .editingChanged)
        self.tableView.register(UINib.init(nibName: "CODGroupMemberTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupMemberTableViewCell")
        
        let resultList = List<CODGroupMemberModel>()
        for model in memberArr.filter("jid != %@",UserManager.sharedInstance.jid) {
            resultList.append(model)
        }
        self.sortSource(arr:  resultList)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    
    @objc func customDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    /// 对数据源进行排序
    func sortSource(arr:List<CODGroupMemberModel>) {
        // 获得索引数, 这里是27个（26个字母和1个#）
        let indexCount = self.indexedCollation.sectionTitles.count
        
        self.dataArray.removeAll()
        self.sectionTitleArray.removeAll()
        // 每一个一维数组可能有多个数据要添加，所以只能先创建一维数组，到时直接取来用
        for _ in 0..<indexCount {
            let array = [CODGroupMemberModel]()
            self.dataArray.append(array)
        }
        // 将数据进行分类，存储到对应数组中
        for person in arr {
            // 根据 person 的 name 判断应该放入哪个数组里
            // 返回值就是在 indexedCollation.sectionTitles 里对应的下标
            let sectionNumber = self.indexedCollation.section(for: person, collationStringSelector: #selector(CODGroupMemberModel.getMemberNickName))
            // 添加到对应一维数组中
            self.dataArray[sectionNumber].append(person)
        }
        
        // 对每个已经分类的一维数组里的数据进行排序，如果仅仅只是分类可以不用这步
        for i in 0..<indexCount {
            
            // 排序结果数组
            let sortedPersonArray = self.indexedCollation.sortedArray(from: self.dataArray[i], collationStringSelector: #selector(CODGroupMemberModel.getMemberNickName))
            // 替换原来数组
            self.dataArray[i] = sortedPersonArray as! [CODGroupMemberModel]
        }
        
        // 用来保存没有数据的一维数组的下标
        var tempArray = [Int]()
        for (i, array) in self.dataArray.enumerated() {
            
            if array.count == 0 {
                tempArray.append(i)
            } else {
                // 给标题数组添加数据
                self.sectionTitleArray.append(self.indexedCollation.sectionTitles[i])
            }
        }
        
        // 删除没有数据的数组
        for i in tempArray.reversed() {
            self.dataArray.remove(at: i)
        }
        
        if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId), groupModel.xhreferall == true || (groupModel.xhreferall == false && isAdmin == true) {
            
            let allMember = CODGroupMemberModel.init()
            allMember.nickname = NSLocalizedString("all", comment: "")
            allMember.jid = kAtAll
            allMember.userpic = self.userpic
            
            self.dataArray.insert([allMember], at: 0)
            self.sectionTitleArray.insert(NSLocalizedString("all", comment: ""), at: 0)
        }
        
        self.tableView.reloadData()
    }
    
    @objc func searchTextChange(sender: UITextField) {
        let string = sender.text ?? ""
        let preicate:NSPredicate = NSPredicate.init(format: "name CONTAINS %@ || nickname CONTAINS %@ || pinYin CONTAINS %@", string, string, string)
        
        let result = self.memberArr.filter("jid != %@",UserManager.sharedInstance.jid).filter(preicate)
        let resultList = List<CODGroupMemberModel>()
        for model in result {
            resultList.append(model)
        }
        if string.count != 0 {
            self.sortSource(arr:resultList)
        }else{
            
            let r = List<CODGroupMemberModel>()
            for model in self.memberArr.filter("jid != %@",UserManager.sharedInstance.jid) {
                r.append(model)
            }
            self.sortSource(arr: r)
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

extension CODGroupMemberViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sectionTitleArray.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.dataArray[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let model = dataArray[indexPath.section][indexPath.row]
        let cell: CODGroupMemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CODGroupMemberTableViewCell", for: indexPath) as! CODGroupMemberTableViewCell
//        cell.headImageView.sd_setImage(with: URL.init(string: model.userpic.getImageFullPath(imageType: 0)), placeholderImage: UIImage.init(named: "default_header_110"))
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.userpic) { (image) in
            cell.headImageView.image = image
        }
        cell.nameLab.text = model.getMemberNickName()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = dataArray[indexPath.section][indexPath.row]
        if self.delegate != nil {
            self.delegate?.clickCell(model: model, location: self.location)
        }
//        self.searchCtl.isActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 25.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitleArray[section]
    }
    
    /// 这是右侧可以点击跳转的控件 title
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitleArray
    }
    
    
}


extension CODGroupMemberViewController:UISearchControllerDelegate,UISearchResultsUpdating{
    
    //    func willDismissSearchController(_ searchController: UISearchController) {
    //
    //        self.sortSource(arr:self.mobileContactModelList)
    //    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.setCancelButton()
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.layoutIfNeeded()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let preicate:NSPredicate = NSPredicate.init(format: "name CONTAINS %@ || nickname CONTAINS %@ || pinYin CONTAINS %@", self.searchBar.text ?? "",self.searchBar.text ?? "",self.searchBar.text ?? "")
        
        let result = self.memberArr.filter("jid != %@",UserManager.sharedInstance.jid).filter(preicate)
        let resultList = List<CODGroupMemberModel>()
        for model in result {
            resultList.append(model)
        }
        if self.searchBar.text?.count != 0 {
            self.sortSource(arr:resultList)
        }else{
            
            let r = List<CODGroupMemberModel>()
            for model in self.memberArr.filter("jid != %@",UserManager.sharedInstance.jid) {
                r.append(model)
            }
            self.sortSource(arr: r)
        }
    }
}

extension CODGroupMemberViewController: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.searchBar.showsCancelButton = true
        self.searchBar.setCancelButton()
        self.searchBar.addCancelTarget()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchBar.showsCancelButton = false
    }

}
