//
//  CODLocationView.swift
//  COD
//
//  Created by 1 on 2019/3/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODLocationView: UIView {
    lazy var topTitleLabel:UILabel = {
        let topTitleLabel = UILabel(frame: CGRect.zero)
        topTitleLabel.font = FONT15
        topTitleLabel.textColor = UIColor.black
        topTitleLabel.textAlignment = .left
        return topTitleLabel
    }()
    lazy var detailLabel: UILabel = {
        let detailLabel = UILabel(frame: CGRect.zero)
        detailLabel.font = FONT12
        detailLabel.textColor = UIColor.lightGray
        detailLabel.textAlignment = .left
        detailLabel.text = "ceshi"
        return detailLabel
    }()
    lazy var mapImageView:CYCustomArcImageView = {
        let mapImageView = CYCustomArcImageView(frame: CGRect.zero)
        mapImageView.contentMode = .scaleAspectFill
        mapImageView.clipsToBounds = true
        mapImageView.borderBottomLeftRadius = 15
        mapImageView.borderBottomRightRadius = 15
        return mapImageView
    }()
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "位置"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    lazy var pinchView: UIImageView = {
        let pinchView = UIImageView(frame: CGRect.zero)
        return pinchView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpViews(){
        self.addSubview(self.topTitleLabel)
        self.addSubview(self.detailLabel)
        self.addSubview(self.mapImageView)
        self.addSubview(self.pinchView)
        self.addSubview(self.locationLabel)

        self.topTitleLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(7)
            make.right.equalToSuperview().offset(-7)
            make.height.equalTo(21)
        }
        self.detailLabel.snp.makeConstraints { (make) in
            make.right.left.equalTo(self.topTitleLabel)
            make.top.equalTo(self.topTitleLabel.snp.bottom).offset(0)
            make.height.equalTo(17)
        }
        self.mapImageView.snp.makeConstraints { (make) in
            make.right.bottom.left.equalToSuperview()
            make.top.equalTo(self.detailLabel.snp.bottom).offset(6)
        }
        self.locationLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.topTitleLabel)
            make.bottom.equalTo(self).offset(-5)
            make.height.equalTo(17)
            make.width.equalTo(34)
        }
        self.pinchView.snp.makeConstraints { (make) in
            make.center.equalTo(self.mapImageView.snp.center).offset(0)
        }
    
    }
}
