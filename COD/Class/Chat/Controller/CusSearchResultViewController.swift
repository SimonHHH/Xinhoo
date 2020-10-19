//
//  CusSearchResultViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/22.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CusSearchResultViewController: BaseViewController{

//    let searchCtl = UISearchController(searchResultsController: nil)
    
    var textField : UITextField?
    
    var inputString : String?
    var searchArr = NSMutableArray()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        searchCtl.searchBar.backgroundColor = UIColor(hexString: kVCBgColorS)   //改掉navgationbar底色
//        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: kVCBgColorS)
        
        textField?.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
 
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: kNavBarBgColorS)
    }
    
//    private lazy var tableView:UITableView = {
//        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
//        tabelV.estimatedRowHeight = 80
//        tabelV.rowHeight = UITableView.automaticDimension
//        tabelV.separatorStyle = .none
//        tabelV.backgroundColor = UIColor.clear
//        tabelV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
//        tabelV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
//        tabelV.delegate = self
//        tabelV.dataSource = self
//        return tabelV
//    }()
    private lazy var searchCtl:UISearchController = {
        let searchc = UISearchController(searchResultsController: nil)
        //        searchCtl.searchBar.isTranslucent = false
        searchc.searchBar.placeholder = "用户名/手机号码"
        searchc.searchResultsUpdater = self
        searchc.dimsBackgroundDuringPresentation = false
        searchc.hidesNavigationBarDuringPresentation = true
        searchc.searchBar.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 44)
        searchc.searchBar.delegate = self
        searchc.delegate = self
        searchc.searchBar.showsCancelButton = true
        searchc.searchBar.isUserInteractionEnabled = true

        return searchc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelBtn : UIButton = searchCtl.searchBar.value(forKey: "cancelButton") as! UIButton
        cancelBtn.setTitle("取消", for: UIControl.State.normal)
        cancelBtn.addTarget(self, action: #selector(cancelSearchVcActivity), for: UIControl.Event.touchUpInside)
        
        textField = self.searchCtl.searchBar.value(forKey: "searchField") as? UITextField
        
        self.navigationItem.titleView = searchCtl.searchBar
        
        self.navigationItem.hidesBackButton = true
    }

    @objc func cancelSearchVcActivity(sender : UIButton) {

//        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: false)
    }
    

    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell : FriendSearchResultCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FriendSearchResultCell
//
//        return cell
//    }
    
}

extension CusSearchResultViewController:UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            self.searchCtl.searchBar.becomeFirstResponder()
        }
    }
}
