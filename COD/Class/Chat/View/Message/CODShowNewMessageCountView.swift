//
//  CODShowNewMessageCountView.swift
//  COD
//
//  Created by 1 on 2019/5/30.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODShowNewMessageCountView: UIView {
    var countString = "" {
        didSet{
            self.showCountLabel.text = " " + countString + " "
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bgImageView:UIImageView = {
        let bubbleImageView = UIImageView(frame: CGRect.zero)
        bubbleImageView.contentMode =  .scaleToFill
        bubbleImageView.backgroundColor = UIColor.clear
        bubbleImageView.image = UIImage.init(named: "backgrond_showCounts")
      
        bubbleImageView.isUserInteractionEnabled = true
        return bubbleImageView
    }()
//
//    private lazy var arrowImageView:UIImageView = {
//        let arrowImage = UIImageView(frame: CGRect.zero)
//        arrowImage.contentMode =  .scaleToFill
//        arrowImage.backgroundColor = UIColor.clear
//        arrowImage.image = UIImage.init(named: "on_arrow_showCounts")
//        arrowImage.isUserInteractionEnabled = true
//        return arrowImage
//    }()
    
    private lazy var showCountLabel:UILabel = {
        let showLabel = UILabel(frame: CGRect.zero)
        showLabel.font = UIFont.systemFont(ofSize: 13)
        showLabel.backgroundColor = UIColor.init(hexString: "#007EE5")
        showLabel.layer.cornerRadius = 11
        showLabel.clipsToBounds = true
        showLabel.textColor = UIColor.white
//        showLabel.textAlignment = .center
        return showLabel;
    }()
    
    func setupUI() {
        
        self.addSubviews([self.bgImageView,self.showCountLabel])
        self.showCountLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.bgImageView)
            make.top.equalToSuperview()
            make.height.equalTo(22)
            make.width.lessThanOrEqualTo(KScreenWidth-20)
        }
        
        self.bgImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(38)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
}
