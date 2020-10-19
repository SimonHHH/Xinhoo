//
//  CODBlackListCell.swift
//  COD
//
//  Created by 1 on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODBlackListCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var title: String? {
        didSet {
            if let con = title {
                titleLab.text = con
            }
        }
    }
    public var isLast: Bool = false {
        didSet {
            lastLineView.isHidden = !isLast
        }
    }
    
    public var userpic: String? {
        didSet {
//            imgView.sd_setImage(with: NSURL.init(string: userpic!.getHeaderImageFullPath(imageType: 0)) as URL?, placeholderImage: UIImage.init(named: "default_header_110"))
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: userpic ?? "") { (image) in
                self.imgView.image = image
            }
        }
    }

    // MARK - 懒加载
    private lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 17)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "default_header_110"))
        imgView.contentMode = .scaleAspectFit
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    private lazy var lineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return linev
    }()
    
    private lazy var lastLineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return linev
    }()
}

extension CODBlackListCell{
    private func setupUI() {
        
        contentView.addSubview(titleLab)
        contentView.addSubview(imgView)
        self.addSubview(lineView)
        self.addSubview(lastLineView)
    }
    
    private func setupLayout() {
        
        imgView.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.left.equalTo(self.contentView).offset(21)
            make.top.equalTo(self.contentView).offset(8)
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-8)
        }
        
        imgView.layer.cornerRadius = 40/2
        
        titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(imgView.snp.right).offset(13)
            make.right.equalTo(self.contentView).offset(-10)
            make.centerY.equalTo(imgView)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(63.0)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        lastLineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
