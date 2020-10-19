//
//  CODGroupMenberSelectCell.swift
//  COD
//
//  Created by XinHoo on 2019/3/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupMenberSelectCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    public var imageString: String? {
        didSet {
            if let imgUrl = imageString {
//                imgView.sd_setImage(with: NSURL.init(string: imgUrl) as URL?, placeholderImage: UIImage(named: "default_header_110"))
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: imgUrl ) { (image) in
                    self.imgView.image = image
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: ""))
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    
    
    func setupUI() {
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
        }
        imgView.layer.cornerRadius = self.width/2
        imgView.clipsToBounds = true
    }
}
