//
//  CODRobotInfoVC.swift
//  COD
//
//  Created by 1 on 2019/12/4.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODRobotInfoVC: BaseViewController {
    private var dataSource: Array = [CODCellModel]()

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

    // MARK - 懒加载
    private lazy var iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 66/2
        imgView.layer.masksToBounds = true
        imgView.backgroundColor = UIColor.clear
        return imgView
    }()
    
    /// 备注名/昵称
    private lazy var nameLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.boldSystemFont(ofSize: 19)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    private lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 16)
        titleLab.textColor = UIColor.init(hexString: "#999999")
        titleLab.textAlignment = NSTextAlignment.left
        titleLab.text = "机器人"
        return titleLab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("机器人信息", comment: "")
        self.setBackButton()
        self.setupUI()
        self.iconImageView.image = UIImage.init(named: "robot_info")
        let attriStr = NSMutableAttributedString.init(string: CustomUtil.formatterStringWithAppName(str: "BotFather  "))
        let textAttachment = NSTextAttachment.init()
        let img = UIImage(named: "cod_helper_sign_m")
        textAttachment.image = img
        textAttachment.bounds = CGRect.init(x: 0, y: 0, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
        let attributedString = NSAttributedString.init(attachment: textAttachment)
        attriStr.append(attributedString)
        self.nameLab.attributedText = attriStr
        self.createDataSource()
    }

    func setupUI() {
        
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor.white
        
        let topLine = UIView()
        topLine.backgroundColor = UIColor(hexString: kSepLineColorS)
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(hexString: kSepLineColorS)

        self.view.addSubviews([bgView])
        bgView.addSubviews([nameLab,iconImageView,titleLab,topLine])
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(15)
            make.top.equalTo(bgView).offset(15.5)
            make.width.height.equalTo(66)
        }
        
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(9)
            make.top.equalTo(iconImageView).offset(9)
            make.height.equalTo(26)
            make.right.equalTo(self.view).offset(-16)
        }
                
        topLine.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(bgView)
            make.height.equalTo(0.5)
        }
        
        self.titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(nameLab)
            make.height.equalTo(21)
            make.top.equalTo(self.nameLab.snp.bottom).offset(3)
        }
        
        bgView.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: 90)
        self.tableView.tableHeaderView = bgView
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }
    func createDataSource() {
        
        if self.dataSource.count > 0 {
            self.dataSource.removeAll()
        }
        
        let model1 = self.createModel(title: "Botfather一只忠于工作，拒绝聊天的超级助理。",image: "about_icon")
        let model2 = self.createModel(title: "BotFather",image: "@_icon")
        let model3 = self.createModel(title: "添加到群组",image: "robot_icon")
        let model4 = self.createModel(title: "共同加入的群组",subTitle:"19",image: "groupjoinedtogether")
        self.dataSource.append(model1)
        self.dataSource.append(model2)
        self.dataSource.append(model3)
        self.dataSource.append(model4)

        self.tableView.reloadData()
    }
    
    func createModel(title: String = "",
                     subTitle: String = "",
                     image: String = "") -> CODCellModel {
        var model = CODCellModel()
        model.title = title
        model.subTitle = subTitle
        model.iconName = image
        return model
    }

}

extension CODRobotInfoVC:UITableViewDelegate,UITableViewDataSource{
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODRobotCell.self, forCellReuseIdentifier: "CODRobotCellID")
    }
    
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CODRobotCellID", for: indexPath) as! CODRobotCell
        let model = self.dataSource[indexPath.section]
        cell.headerImageView.image = UIImage.init(named: model.iconName ?? "")
        cell.nameLb.text = model.title
        cell.subtTitleLb.text = model.subTitle
        if indexPath.section == 1 {
            cell.nameLb.font = UIFont(name: "PingFang-SC-Medium", size: 17)
        }else{
            cell.nameLb.font = UIFont.systemFont(ofSize: 17)
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
         let view =  UIView()
        view.backgroundColor = UIColor(hexString: kSepLineColorS)

        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == self.dataSource.count - 1{
            return 0.5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 12.5))
        bgView.backgroundColor = UIColor.clear
        
        let topLineViwe = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.5))
        topLineViwe.backgroundColor = UIColor.init(hexString: "#C8C7CC")
        
        let bottomLineView = UIView.init(frame: CGRect(x: 0, y: 12, width: KScreenWidth, height: 0.5))
        bottomLineView.backgroundColor = UIColor.init(hexString: "#C8C7CC")
        
        bgView.addSubviews([topLineViwe,bottomLineView])
        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 12.5
    }
    
    
}
