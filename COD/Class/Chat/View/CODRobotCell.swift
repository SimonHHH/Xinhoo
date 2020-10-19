
//
//  CODRobotCell.swift
//  COD
//
//  Created by 1 on 2019/12/4.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODRobotCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.white
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var headerImageView:UIImageView = {
        let imgView = UIImageView.init()
        return imgView
    }()
    
    lazy var nameLb:UILabel = {
        let nameLb = UILabel(frame: CGRect.zero)
        nameLb.font =  UIFont(name: "PingFang SC", size: 17)
        nameLb.textColor = UIColor.init(hexString: "#080808")
        nameLb.numberOfLines = 0
        nameLb.backgroundColor = UIColor.clear
        nameLb.text = ""
        return nameLb
    }()
    
    lazy var subtTitleLb:UILabel = {
        let nameLb = UILabel(frame: CGRect.zero)
        nameLb.font =  UIFont(name: "PingFang SC", size: 17)
        nameLb.textColor = UIColor.init(hexString: "#B2B2B2")
        nameLb.numberOfLines = 1
        nameLb.text = ""
        nameLb.textAlignment = .right
        nameLb.backgroundColor = UIColor.clear
        return nameLb
    }()
    
    func setUpView(){
         
        self.contentView.addSubviews([self.headerImageView,self.nameLb,self.subtTitleLb])
        self.headerImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(18)
            make.centerY.equalTo(self.contentView)
            make.height.width.equalTo(24)
        }
        
        self.nameLb.snp.makeConstraints { (make) in
            make.left.equalTo(self.headerImageView.snp.right).offset(19)
            make.top.equalTo(self.contentView).offset(12)
            make.right.equalTo(self.contentView.snp.right).offset(-22)
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-11)
        }
        
        self.subtTitleLb.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView).offset(-16)
            make.centerY.equalTo(self.contentView)
            make.width.lessThanOrEqualTo(KScreenWidth/2)
        }
        
    }
    
}
