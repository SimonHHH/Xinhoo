//
//  CODMessageHeaderView.swift
//  COD
//
//  Created by 1 on 2019/5/16.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODMessageHeaderView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let view = UIView.init()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 0.76, alpha: 1)
        self.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(5)
            make.width.lessThanOrEqualTo(KScreenWidth - 80)
        }
        
        view.addSubview(self.contentLb)
        view.addSubview(self.contentImageView)
        
        self.contentImageView.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 10, height: 12))
        }
        
        self.contentLb.snp.makeConstraints { (make) in
            make.left.equalTo(contentImageView.snp.right).offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var contentImageView: UIImageView = {
        let conImgV = UIImageView.init(frame: CGRect.zero)
        conImgV.image = UIImage.init(named: "encryption_lock_icon")
        conImgV.contentMode = UIView.ContentMode.scaleAspectFit
        return conImgV
        
    }()

    private lazy var contentLb: ActiveLabel = {
        let contentLable = ActiveLabel.init(frame: CGRect.zero)
        contentLable.textColor = UIColor.black
        contentLable.font = UIFont.systemFont(ofSize: 13)
        contentLable.numberOfLines = 0
        contentLable.adjustsFontSizeToFitWidth = true
        contentLable.text = "此对话中所发送的信息都已进行端到端加密"
        return contentLable
    }()

}
