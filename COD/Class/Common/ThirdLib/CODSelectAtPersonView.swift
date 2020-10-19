//
//  CODSelectAtPersonView.swift
//  COD
//
//  Created by 1 on 2020/8/17.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODSelectAtPersonView: UIView {
    
    var location = 0
    var memberArr = List<CODGroupMemberModel>(){
        didSet {
            setData()
        }
    }
    
    var memberName = String() {
        didSet {
            setAtData()
        }
    }
    var userpic = ""
    var isAdmin  = false
    var chatId = 0
    
    weak var delegate:CODSelectAtPersonViewDelegate?

    lazy var tableView:UITableView = {
        let tabelView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tabelView.rowHeight = UITableView.automaticDimension
        tabelView.separatorStyle = .none
//        tabelView.backgroundColor = UIColor.clear
        let footerView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        tabelView.tableFooterView = footerView
        tabelView.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        tabelView.estimatedSectionHeaderHeight = 0;
        tabelView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        tabelView.delegate = self
        tabelView.dataSource = self
        tabelView.bounces = true
        return tabelView
    }()
    
    /// 数据源
    private var dataArray = [CODGroupMemberModel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        self.tableView.register(CODSelectAtPersonCell.self, forCellReuseIdentifier: "CODSelectAtPersonCellID")
        self.setUpSubViews()
        
    }
    
    func setData() {
        
        let resultList = List<CODGroupMemberModel>()
        for model in memberArr.filter("jid != %@",UserManager.sharedInstance.jid) {
            resultList.append(model)
            self.dataArray.append(model)
        }
        self.sortSource(arr:  resultList)
    
        self.tableView.snp.updateConstraints { (make) in
            make.height.equalTo((self.dataArray.count>3) ? 42*3 : self.dataArray.count*42 )
        }
        self.tableView.reloadData()
    }
    
    func setAtData() {
        
        if memberName.count > 0 {
            self.dataArray.removeAll()

        }else{
            self.setData()
        }
        let resultList = List<CODGroupMemberModel>()

        for model in memberArr.filter("userdesc contains[c] %@ OR name contains[c] %@", self.memberName, self.memberName) {
            resultList.append(model)
            self.dataArray.append(model)
        }
        self.tableView.snp.updateConstraints { (make) in
            make.height.equalTo((self.dataArray.count>3) ? 42*3 : self.dataArray.count*42 )
        }
        self.tableView.reloadData()
        
    }
    
    /// 对数据源进行排序
    func sortSource(arr:List<CODGroupMemberModel>) {
        
        if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId), groupModel.xhreferall == true || (groupModel.xhreferall == false && isAdmin == true) {
            
            let allMember = CODGroupMemberModel.init()
            allMember.nickname = NSLocalizedString("all", comment: "")
            allMember.jid = kAtAll
            allMember.userpic = self.userpic
            
            self.dataArray.insert(allMember, at: 0)
        }
        
        self.tableView.reloadData()
    }
    
    func setUpSubViews() {
        
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            
            make.top.equalTo(self.snp.top).offset(0)
            make.bottom.equalTo(self.snp.bottom).offset(0)
            make.left.equalTo(self.snp.left).offset(0)
            make.right.equalTo(self.snp.right).offset(0)
            make.height.equalTo(1)
        }
    }
    
    func dismissSelectView() {
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        self.removeFromSuperview()
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension CODSelectAtPersonView:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 42
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = dataArray[indexPath.row]
        let cell: CODSelectAtPersonCell = tableView.dequeueReusableCell(withIdentifier: "CODSelectAtPersonCellID", for: indexPath) as! CODSelectAtPersonCell
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.userpic) { (image) in
            cell.iconView.image = image
            cell.backgroundColor = UIColor.clear
        }
        cell.titleLab.text = model.getMemberNickName()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = dataArray[indexPath.row]
        if self.delegate != nil {
            self.delegate?.selectAtPersonclickCell(model: model, location: self.location)
        }
        self.dismissSelectView()
    }
}

@objc protocol CODSelectAtPersonViewDelegate {
    //代理方法s
    func selectAtPersonclickCell(model:CODGroupMemberModel, location:Int)
}
