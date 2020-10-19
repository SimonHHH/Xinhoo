//
//  CODGroupChatCell.swift
//  COD
//
//  Created by 1 on 2019/3/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupChatCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupUILayout()
    }
    
    public var headerImage: UIImage? {
        didSet {
            imgView.image = headerImage
        }
    }
    public var urlStr: String? {
        didSet {
//            imgView.sd_setImage(with: URL.init(string: urlStr!) , placeholderImage: UIImage(named: "default_header_80"))
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: urlStr ?? "") { (image) in
                self.imgView.image = image
            }
        }
    }
    public var nameString: String? {
        didSet {
            nameLab.text = nameString
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = UIView.ContentMode.scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 3
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    private lazy var nameLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.black
        lab.font = UIFont.systemFont(ofSize: 11)
        lab.textAlignment = .center
        lab.text = ""
        return lab
    }()
}

private extension CODGroupChatCell {
    func setupUI() {
        contentView.addSubview(imgView)
        contentView.addSubview(nameLab)
    }
    func setupUILayout() {
        imgView.layer.cornerRadius = 53/2
        imgView.clipsToBounds = true
        imgView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(contentView)
            make.height.equalTo(53)
        }
        nameLab.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(contentView)
            make.top.equalTo(imgView.snp.bottom).offset(2)
        }
        
    }
}
