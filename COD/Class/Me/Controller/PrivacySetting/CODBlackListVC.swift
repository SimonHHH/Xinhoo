//
//  CODBlackListVC.swift
//  COD
//
//  Created by 1 on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODBlackListVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "黑名单"
        self.setBackButton()
        self.setUpUI()
        self.reloadView()
    }
    
    private var dataSource: Array = ["sunshine","sunshine","sunshine","sunshine"]

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
        
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    private lazy var noContent: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 15)
        titleLab.textColor = UIColor(red: 0.47, green: 0.47, blue: 0.47,alpha:1)
        titleLab.textAlignment = NSTextAlignment.center
        titleLab.text = "暂无黑名单"
        return titleLab
    }()
    
    func reloadView() {
        
        if dataSource.count == 0 {
            tableView.isHidden = true
            noContent.isHidden = false
        }else{
            tableView.isHidden = false
            noContent.isHidden = true
        }
    }
  
}
extension CODBlackListVC{
    func setUpUI() {
        self.view.addSubviews([tableView,noContent])
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
        noContent.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
    }
}

extension CODBlackListVC:UITableViewDelegate,UITableViewDataSource{
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODBlackListCell.self, forCellReuseIdentifier: "CODBlackListCellID")
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let  dataString = dataSource[indexPath.row]
        let cell: CODBlackListCell = tableView.dequeueReusableCell(withIdentifier: "CODBlackListCellID", for: indexPath) as! CODBlackListCell
        cell.title = dataString
        if indexPath.row == dataSource.count - 1 {
            cell.isLast = true
        }else{
            cell.isLast = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeight = 20
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: CGFloat(sectionHeight)))
        bgView.backgroundColor = UIColor.clear
        
        return bgView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        bgView.backgroundColor = UIColor.clear
        
        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
}
