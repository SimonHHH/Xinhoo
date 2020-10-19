//
//  CODSavedGroupChatCell.swift
//  COD
//
//  Created by 1 on 2019/3/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSavedGroupChatCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var headerImgId: String? {
        didSet {
            guard let headerImgId = headerImgId else {
                return
            }
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: headerImgId) {[weak self] (image) in
                self?.imgView.image = image
            }

        }
    }
    
    public var title: String? {
        didSet {
            if let con = title {
                titleLab.text = con
            }
        }
    }
    
    
    public var isLast: Bool? {
        didSet {
            lineView.isHidden = isLast!
        }
    }
    
    // MARK - 懒加载
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "default_header_110"))
        imgView.contentMode = .scaleToFill
        imgView.layer.cornerRadius = 17.5
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 16)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    private lazy var lineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return linev
    }()
}

extension CODSavedGroupChatCell{
    private func setupUI() {
        contentView.addSubviews([imgView,titleLab,lineView])
        
    }
    
    private func setupLayout() {
        
        imgView.snp.makeConstraints { (make) in
            make.width.height.equalTo(35)
            make.left.equalTo(10)
            make.top.equalTo(10)
            make.bottom.lessThanOrEqualTo(-10)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(imgView)
            make.left.equalTo(imgView.snp.right).offset(12)
            make.right.equalTo(self.contentView).offset(-12)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab.snp.left)
            make.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
            
        }
    }
    
}

