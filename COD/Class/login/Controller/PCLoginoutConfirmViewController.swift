//
//  PCLoginoutConfirmViewController.swift
//  COD
//
//  Created by Xinhoo on 2019/5/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation

class PCLoginoutConfirmViewController: UIViewController {
    
    var confirmLoginout:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tabelV.estimatedRowHeight = 52
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor.clear
        tabelV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.delegate = self
        tabelV.dataSource = self
        return tabelV
    }()
}

extension PCLoginoutConfirmViewController{
    
    func setUpUI() {
       
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }
    }
}

extension PCLoginoutConfirmViewController:UITableViewDelegate,UITableViewDataSource{
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return kSafeArea_Bottom + 52
        } else {
            return 52
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell: UITableViewCell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        let lblTitle: UILabel = UILabel.init()
        lblTitle.textAlignment = .center
        cell.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalTo(cell)
        }
        
        if indexPath.section == 0 {
            lblTitle.text = CustomUtil.formatterStringWithAppName(str: "是否退出电脑%@?");
            lblTitle.textColor = UIColor.init(hexString: kEmptyTitleColorS)
            lblTitle.font = UIFont.systemFont(ofSize: 13)
            
            let lblSeperate: UILabel = UILabel.init()
            lblSeperate.backgroundColor = UIColor.init(hexString: kEmptyTitleColorS)?.withAlphaComponent(0.2)
            cell.addSubview(lblSeperate)
            lblSeperate.snp.makeConstraints { (make) in
                make.leading.trailing.bottom.equalTo(cell)
                make.height.equalTo(1)
            }
        } else if(indexPath.section == 1) {
            lblTitle.text = "退出";
            lblTitle.textColor = UIColor.init(hexString: "#F70115")
            lblTitle.font = UIFont.systemFont(ofSize: 17)
        } else {
            lblTitle.text = "取消";
            lblTitle.textColor = UIColor.init(hexString: kNavTitleColorS)
            lblTitle.font = UIFont.systemFont(ofSize: 17)
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 6
        } else {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            self.dismiss(animated: true) {
                CODProgressHUD.showWarningWithStatus("功能正在开发，敬请期待")
                self.confirmLoginout?()
            }
        } else if(indexPath.section == 2) {
            self.dismiss(animated: true) {
            }
        }
    }
    
}
