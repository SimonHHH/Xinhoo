//
//  CODPicTitleDetailView.swift
//  COD
//
//  Created by 1 on 2020/5/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
enum CODCircleStaute :Int {
    
    case Open = 0
    case Private = 5
    case Failed = 10
}

@objcMembers
@objc class CODPicTitleDetailView: UIView {
    var imageTitle: String? {
        didSet{
            self.desLabel.text = imageTitle
//            self.desLabel.backgroundColor = UIColor.red
//            self.lableBackView.snp.updateConstraints { (make) in
//                make.top.equalTo(self.desLabel.top).offset(4)
//            }
        }
    }
    
    var circleStaute: CODCircleStaute? {
        didSet{
            self.desLabel.snp.updateConstraints { (make) in
                make.right.equalTo(self).offset( (circleStaute == .Open) ? -6 : -58)
            }
    
            self.lableBackView.snp.updateConstraints { (make) in
                make.top.equalTo(self.desLabel.snp.top).offset( -8 )
            }
            
            self.privateImage.isHidden = (circleStaute == .Open)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func setupView() {
        
        self.addSubviews([self.lableBackView,self.desLabel,self.privateImage])
        self.desLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-6)
//            make.top.equalTo(self).offset(4)
            make.bottom.equalTo(self).offset(-8)
            make.height.lessThanOrEqualTo(110)
        }
        
        self.lableBackView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.desLabel.snp.top).offset(-4)
//            make.edges.equalTo(self.desLabel)
        }
        
        self.privateImage.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-14)
            make.width.height.equalTo(22)
            make.centerY.equalTo(self.lableBackView)
        }
        
    }
    
    private lazy var lableBackView: UIView = {
        let backView = UIView.init()
        backView.backgroundColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return backView;
    }()
    
    private lazy var desLabel:UILabel = {
        let desLb = UILabel(frame: CGRect.zero)
        desLb.font = UIFont.systemFont(ofSize: 13)
        desLb.textColor = UIColor.white
        desLb.sizeToFit()
        desLb.numberOfLines = 0
        return desLb;
    }()
    
    private lazy var privateImage:UIImageView = {
        let desImg = UIImageView.init()
        desImg.contentMode = .scaleAspectFill
        desImg.image = UIImage.init(named: "circle_image_lock")
        return desImg;
    }()
}
