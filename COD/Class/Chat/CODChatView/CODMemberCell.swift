//
//  CODMemberCell.swift
//  COD
//
//  Created by 1 on 2019/11/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODMemberCell: UITableViewCell {
    
    public var groupModel: CODGroupMemberModel = CODGroupMemberModel() {
        didSet{
            self.setContentModel()
        }
    }
    
    private lazy var headerImageView:UIImageView = {
        let imgView = UIImageView.init()
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 16.0
        return imgView
    }()
    
    private lazy var nameLb:CustomLabel = {
        let nameLb = CustomLabel(frame: CGRect.zero)
        nameLb.font =  UIFont(name: "PingFang SC", size: 15)
        nameLb.layer.masksToBounds = true
        nameLb.textColor = UIColor.black
        nameLb.numberOfLines = 1
        nameLb.text = ""
        return nameLb
    }()
    
    private lazy var lineView: UIView = {
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor.init(hexString: kSepLineColorS)?.withAlphaComponent(0.5)
        return bgView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView() {
        self.contentView.addSubviews([self.headerImageView,self.nameLb,self.lineView])
        
        headerImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(7.5)
            make.width.height.equalTo(32)
            make.top.equalTo(self.contentView).offset(4)
        }
        
        nameLb.snp.makeConstraints { (make) in
            make.left.equalTo(headerImageView.snp.right).offset(11)
            make.right.equalTo(self.contentView).offset(12.5)
            make.centerY.equalTo(self.headerImageView)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(52)
            make.top.equalTo(self.headerImageView.snp.bottom).offset(4)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
    }
    
    func setContentModel() {
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: groupModel.userpic) { (image) in
            self.headerImageView.image = image
        }
        nameLb.text = self.groupModel.getMemberNickName()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
