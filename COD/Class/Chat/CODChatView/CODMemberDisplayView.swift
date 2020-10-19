//
//  CODMemberDisplayView.swift
//  COD
//
//  Created by 1 on 2019/11/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

private let CODMemberCell_Identifier = "CODMemberCell_Identifier"

class CODMemberDisplayView: UIView {
    weak var delegate:CODMemberDisplayViewDelegate?

    public var chatId: Int = 0 {
        didSet{
            self.getData()
        }
    }
    public var lastString: String = ""
    public var nameString: String = "" {
        didSet{
            self.getDataByName()
            print("getDataByName\(nameString)")
        }
    }

    private var memberList :Array<CODGroupMemberModel> = Array<CODGroupMemberModel>() {
        didSet{
        }
    }
    
    private var chatMemberList :Array<CODGroupMemberModel> = Array<CODGroupMemberModel>() {
        didSet{
        }
    }
    
    private lazy var topView: UIView = {
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor.init(hexString: kSepLineColorS)?.withAlphaComponent(0.5)
        return bgView
    }()
    
    private lazy var bottomView: UIView = {
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor.init(hexString: kSepLineColorS)?.withAlphaComponent(0.5)
        return bgView
    }()

    lazy var tableView:UITableView = {
        let tabelView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tabelView.rowHeight = UITableView.automaticDimension
        tabelView.separatorStyle = .none
        tabelView.backgroundColor = UIColor.clear
        let footerView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        tabelView.tableFooterView = footerView
        tabelView.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        tabelView.estimatedSectionHeaderHeight = 0;
        tabelView.backgroundColor = UIColor.clear
        tabelView.bounces = false
        return tabelView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.setUpView()
    }
    
    func setUpView() {
        
        self.addSubviews([self.tableView,self.topView,self.bottomView])
        self.tableView.register(CODMemberCell.self, forCellReuseIdentifier: CODMemberCell_Identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.topView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        self.bottomView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
     func getData() {
        
        if self.chatMemberList.count > 0 && self.chatMemberList.count >= self.memberList.count {
            self.memberList = self.chatMemberList
        }else{
            if let groupChatModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId) {
                    if let members = groupChatModel.member as? List<CODGroupMemberModel>{
                         let membersTemp = members.sorted(byKeyPath: "userpower", ascending: true)
                         var membersArr = Array<CODGroupMemberModel>()
                         
                         for member in membersTemp {
                             membersArr.append(member)
                         }
                
                        membersArr.sort { (model1, model2) -> Bool in
                            model1.lastlogintime > model2.lastlogintime
                        }
                       self.memberList = membersArr
                       self.chatMemberList = membersArr
                   }
                 }
        }
        
        self.tableView.reloadData()
    }
    
     func getDataByName() {
        self.isHidden = false
        if self.nameString.removeHeadAndTailSpacePro.count == 0{
            self.getData()
        }else{
            var searchList :Array<CODGroupMemberModel> = []
            let nameStr: String = self.nameString.removeHeadAndTailSpacePro
            for model in self.chatMemberList {
                if model.getMemberNickName().contains(nameStr){
                    searchList.append(model)
                }
            }
            self.memberList = searchList
            self.tableView.reloadData()
        }
    }
}

extension CODMemberDisplayView:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CODMemberCell_Identifier) as! CODMemberCell
        let model = self.memberList[indexPath.row]
        cell.groupModel = model
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.delegate != nil {
            let model = self.memberList[indexPath.row]
            self.delegate?.cellDidSelectMember(groupModel: model)
        }
    }
}
protocol CODMemberDisplayViewDelegate:NSObjectProtocol
{
    /*cell的点击事件*/
    func cellDidSelectMember(groupModel:CODGroupMemberModel)

}
