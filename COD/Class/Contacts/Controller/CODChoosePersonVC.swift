//
//  CODChoosePersonVC.swift
//  COD
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Lottie

class CODChoosePersonVC: BaseViewController {
    
    typealias ChoosePersonCompeleteBlock = (_ model: CODContactModel) -> Void ///选择联系人
    
    var fromJID = ""  //删除当前页面传过来的jid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
        self.navigationItem.title = NSLocalizedString("选择联系人", comment: "")
        self.definesPresentationContext = true
        self.getData()
        self.setUpUI()
    }
    
    let searchCtl = UISearchController(searchResultsController: nil)
    public var choosePersonBlock:ChoosePersonCompeleteBlock?
        
    var stringsToSort = Array<String>()
    var indexArray: Array = [String]()
    
    var contactListArr :Array = [CODContactModel]()
    var contactSortResultArr: Array = [Array<CODContactModel>]()
    
    
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
        tabelV.emptyDataSetSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
}

extension CODChoosePersonVC{
    
    func getData() {
        
        if let contactList = CODContactRealmTool.getContactsNotBlackList() {
            guard contactList.count > 0 else {
                return
            }
            
            for contact in contactList {
                if contact.jid.contains("cod_60000000") {
                    continue
                }
                if contact.jid.contains(XMPPManager.shareXMPPManager.currentChatFriend) {
                    continue
                }
                if contact.jid.contains(fromJID) {
                    continue
                }
                self.contactListArr.append(contact)
            }
            
            self.sortSource(contactSource: self.contactListArr)
        }
        
    }
    
    func sortSource(contactSource: [CODContactModel]) {
        
        var stringsToSortTemp: Array<String> = []
        for contact in contactSource {
            stringsToSortTemp.append(contact.getContactNick())
        }
        self.stringsToSort = stringsToSortTemp
        
        if let indexStringS = ChineseString.indexArray(self.stringsToSort) as? [String]   {
            self.indexArray = indexStringS
        }
        
        if let contactResults = ChineseString.modelSortArray(contactSource) as? [Array<CODContactModel>] {
            self.contactSortResultArr = contactResults
        }
    }
    
    func setUpUI() {
        
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 56))
        bgView.addSubview(searchCtl.searchBar)
        searchCtl.searchBar.placeholder = "搜索好友"
        searchCtl.delegate = self
        searchCtl.searchResultsUpdater = self
//        searchCtl.searchBar.delegate = self
        self.tableView.tableHeaderView = bgView
        //取掉上下两条黑线
        searchCtl.searchBar.backgroundImage = UIImage()
        searchCtl.dimsBackgroundDuringPresentation = false
        searchCtl.hidesNavigationBarDuringPresentation = true
        
        let searchBarTF = searchCtl.searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 17)
        searchBarTF?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }
}

extension CODChoosePersonVC:UITableViewDelegate,UITableViewDataSource,EmptyDataSetSource{
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODChoosePersonCell.self, forCellReuseIdentifier: "CODChoosePersonCellID")
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {

        return self.indexArray
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.indexArray.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section < self.indexArray.count {
            return self.contactSortResultArr[section].count
        }
        return 0
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID", for: indexPath) as! CODChoosePersonCell
        let datas = self.contactSortResultArr[indexPath.section]
        let model :CODContactModel = datas[indexPath.row]
        cell.iconImage = UIImage.init(named: "default_header_110")
        cell.placeholer = ""
        cell.cellIndexPath = indexPath
        cell.title = model.getContactNick()
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.userpic) { (image) in
            cell.imgView.image = image
        }
        
        if indexPath.row == datas.count - 1 {
            cell.isLast = true
        }else{
            cell.isLast = false
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let textString = self.indexArray[section]
        let textFont = UIFont.systemFont(ofSize: 12)
        let sectionHeight: CGFloat = 24
        let textLabel = UILabel.init(frame: CGRect(x: 14, y: 0, width: KScreenWidth-28, height: sectionHeight))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.font = textFont
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(hexString: kSectionHeaderTextColorS)
        textLabel.text = textString
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
        bgView.backgroundColor = UIColor.clear
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
        
        return 25.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model :CODContactModel = self.contactSortResultArr[indexPath.section][indexPath.row]
        if self.choosePersonBlock != nil {
            self.choosePersonBlock!(model)
            self.navigationController?.popViewController()
        }
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 100))
        
        let lottieView = AnimationView.init()
        let animation = Animation.filepath(Bundle.main.path(forResource: "404", ofType: "json")!, animationCache: nil)
        lottieView.animation = animation
        lottieView.loopMode = .loop
        lottieView.play()
        view.addSubview(lottieView)
        lottieView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 55, height: 65))
            make.centerX.equalToSuperview()
        }
        
        let lab = UILabel.init(frame: .zero)
        lab.text = CustomUtil.formatterStringWithAppName(str:"您暂时还没有加入%@的朋友\n推荐朋友下载一起畅聊吧")
        lab.numberOfLines = 0
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textAlignment = .center
        lab.textColor = UIColor.init(hexString: kWeakTitleColorS)
        view.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.top.equalTo(lottieView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        return view
    }
}

extension CODChoosePersonVC: UISearchControllerDelegate,UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if self.searchCtl.searchBar.text?.count ?? 0 > 0 {
            let result = self.contactListArr.filter { [weak self] (contact) -> Bool in
                return contact.name.contains(self?.searchCtl.searchBar.text ?? "", caseSensitive: false) || contact.nick.contains(self? .searchCtl.searchBar.text ?? "", caseSensitive: false) || contact.pinYin.contains(self?.searchCtl.searchBar.text ?? "", caseSensitive: false)
            }
            self.sortSource(contactSource: result)
            tableView.reloadData()
        }else{
            self.sortSource(contactSource: self.contactListArr)
            tableView.reloadData()
        }
        
    }
    
}

