//
//  CODChatSearchLeftView.swift
//  COD
//
//  Created by 1 on 2019/11/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODChatSearchLeftView: UIView {
    private lazy var textLabel:UILabel = {
        let textLabel = UILabel(frame: CGRect.zero)
        textLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 14)
        textLabel.textColor = UIColor.black
        textLabel.numberOfLines = 1
        textLabel.text = NSLocalizedString("来自", comment: "")
        return textLabel;
    }()
    
    private lazy var searchImage:UIImageView = {
        let searchImg = UIImageView.init()
        searchImg.contentMode = .scaleAspectFill
        searchImg.image = UIImage.init(named: "member_search")
        return searchImg;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    func setUpView() {
        self.addSubviews([self.textLabel,self.searchImage])
        self.searchImage.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.size.equalTo(self.searchImage.image?.size ?? CGSize.zero)
            make.centerY.equalToSuperview()
        }
        self.textLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.searchImage.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
    }
    func isHiddenLable(isHidden: Bool) {
        
        self.textLabel.isHidden = isHidden
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
