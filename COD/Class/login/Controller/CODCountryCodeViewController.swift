//
//  CODCountryCodeViewController.swift
//  COD
//
//  Created by xinhooo on 2019/8/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODCountryCodeViewController: BaseViewController {

    typealias SelectCountryCodeBlock = (CODCountryCodeModel) -> Void
    /// 数据源
    private var dataArray = [[CODCountryCodeModel]]()
    /// 每个 section 的标题
    private var sectionTitleArray = [String]()
    private var indexedCollation = UILocalizedIndexedCollation.current()
    
    var selectBlock : SelectCountryCodeBlock?
    
    var searchArr:NSMutableArray = NSMutableArray.init()
    var language = ""
    let searchCtl = UISearchController(searchResultsController: nil)
    
    var requestCompleted = false
    
    @IBOutlet weak var listView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.requestCompleted {
            CODProgressHUD.showWithStatus(nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("选择地区", comment: "")
        
        self.setBackButton()
        
        self.listView.tableFooterView = UIView.init()
        self.listView.emptyDataSetSource = self
        self.listView.emptyDataSetDelegate = self
        
        if let languageWithApp = UserDefaults.standard.object(forKey: kMyLanguage) as? String,languageWithApp.count > 0 {
            
            if languageWithApp == "zh-Hans"{
                language = "ZH"
            }else if languageWithApp == "zh-Hant"{
                language = "ZHT"
            }else{
                language = "EN"
            }
            
        }else{
            let arr = UserDefaults.standard.object(forKey: "AppleLanguages") as? NSArray
            let languageStr = arr?.firstObject as? String
            if (languageStr?.contains("zh-Hans"))! {
                language = "ZH"
            }else if (languageStr?.contains("zh-Hant"))! {
                language = "ZHT"
            }else{
                language = "EN"
            }
        }
        
        
        self.configView()
        
        guard CODWebRTCManager.whetherConnectedNetwork() else {
            self.requestCompleted = true
            CODProgressHUD.dismiss()
            return
        }
        
        HttpManager.share.get(url: HttpConfig.COD_CountryCode + "?lang=\(language)", successBlock: { [weak self] (success, json) in
            guard let `self` = self else { return }
            if let result = success["areacodes"] as? NSArray {
                
                for countryInfo in result {
                    let countryModel = CODCountryCodeModel.deserialize(from: countryInfo as? NSDictionary ?? [:])
                    self.searchArr.add(countryModel as Any)
                }
                self.sortSource(arr: self.searchArr)
            }
            self.requestCompleted = true
            CODProgressHUD.dismiss()
        }) { [weak self] (error) in
            self?.requestCompleted = true
            self?.listView.reloadData()
            CODProgressHUD.dismiss()
            
            print(error)
        }
        
        
    }

    /// 对数据源进行排序
    func sortSource(arr:NSMutableArray) {
        // 获得索引数, 这里是27个（26个字母和1个#）
        let indexCount = self.indexedCollation.sectionTitles.count
        
        self.dataArray.removeAll()
        self.sectionTitleArray.removeAll()
        
        // 每一个一维数组可能有多个数据要添加，所以只能先创建一维数组，到时直接取来用
        for _ in 0..<indexCount {
            let array = [CODCountryCodeModel]()
            self.dataArray.append(array)
        }
        
        // 将数据进行分类，存储到对应数组中
        for person in arr {
            
            // 根据 person 的 name 判断应该放入哪个数组里
            // 返回值就是在 indexedCollation.sectionTitles 里对应的下标
            
            
            let sectionNumber = self.indexedCollation.section(for: person, collationStringSelector: #selector(getter: CODCountryCodeModel.name))
            
            // 添加到对应一维数组中
            self.dataArray[sectionNumber].append(person as! CODCountryCodeModel)
        }
        
        // 对每个已经分类的一维数组里的数据进行排序，如果仅仅只是分类可以不用这步
        for i in 0..<indexCount {
            
            // 排序结果数组
            let sortedPersonArray = self.indexedCollation.sortedArray(from: self.dataArray[i], collationStringSelector: #selector(getter: CODCountryCodeModel.name))
            // 替换原来数组
            self.dataArray[i] = sortedPersonArray as! [CODCountryCodeModel]
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
        
        self.listView.reloadData()
    }
    

    func configView(){
        let bgView = UIView(frame: CGRect(x: 0, y: 100, width: kScreenWidth, height: 56))
        bgView.addSubview(searchCtl.searchBar)
        searchCtl.searchBar.placeholder = "搜索"
        searchCtl.delegate = self
        searchCtl.searchResultsUpdater = self
        searchCtl.dimsBackgroundDuringPresentation = false
//        searchCtl.searchBar.searchBarStyle = .minimal
        //租的悬浮的r特性会将下面的内容折叠，因此屏蔽
        self.listView.tableHeaderView = bgView
        //取掉上下两条黑线
        searchCtl.searchBar.backgroundImage = UIImage()
        searchCtl.searchResultsUpdater = self
        searchCtl.dimsBackgroundDuringPresentation = false
        for view in searchCtl.searchBar.subviews {
            view.backgroundColor = UIColor.white
            // UISearchBarBackground与UISearchBarTextField是searchBar的简介子控件
            for subview in view.subviews {
                subview.backgroundColor = UIColor.white

            }
        }
        self.view.addSubview(listView)
        listView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(bgView.snp.bottom)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
        self.definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        
        let searchBarTF = searchCtl.searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 14)
        searchBarTF?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
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

extension CODCountryCodeViewController : UITableViewDelegate,UITableViewDataSource{
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sectionTitleArray.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.dataArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = dataArray[indexPath.section][indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CodeCell") {
            cell.textLabel?.text = model.name
            cell.detailTextLabel?.text = "+" + model.phonecode
            return cell
            
        }else{
            let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "CodeCell")
            cell.textLabel?.text = model.name
            cell.detailTextLabel?.text = "+" + model.phonecode
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = dataArray[indexPath.section][indexPath.row]
        
        if self.selectBlock != nil {
            self.selectBlock!(model)
        }
        self.navigationController?.popViewController(animated: true)
        self.searchCtl.searchBar.text = ""
        self.searchCtl.isActive = false
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


extension CODCountryCodeViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return CODCountryCodeEmptyView()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        if self.requestCompleted && self.dataArray.count <= 0 {
            return true
        }
        return false
    }
}


extension CODCountryCodeViewController:UISearchControllerDelegate,UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let preicateStr = "name CONTAINS[cd] %@ || phonecode CONTAINS[cd] %@"
        let preicate:NSPredicate = NSPredicate.init(format: preicateStr, self.searchCtl.searchBar.text!,self.searchCtl.searchBar.text!)
        
        let result = self.searchArr.filtered(using: preicate)
        let stringNSArray:NSMutableArray = NSMutableArray.init()
        for model in result {
            stringNSArray.add(model)
        }
        if self.searchCtl.searchBar.text?.count != 0 {
            
            self.sortSource(arr:stringNSArray)
        }else{
            self.sortSource(arr: self.searchArr)
        }
    }
}
