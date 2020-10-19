//
//  CODMoreKeyboardCell.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODMoreKeyboardCell: UICollectionViewCell {
    var item: CODMoreKeyboardItem? {
        didSet{
            self.updataUI()
        }
    }
    typealias ItemClickBlock = (_ item: CODMoreKeyboardItem) -> Void
    public var clickBlock:ItemClickBlock?
    fileprivate lazy var iconButton:UIButton = {
        let iconButton = UIButton(type: .custom)
        iconButton.contentMode = .scaleAspectFit
        iconButton.addTarget(self, action: #selector(iconButtonDown), for: .touchUpInside)
        return iconButton
    }()
    
    fileprivate lazy var titleLabel:UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        titleLabel.textAlignment = .left
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.iconButton)
        self.contentView.addSubview(self.titleLabel)
        
        self.addSnpKit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func addSnpKit(){
        self.iconButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.iconButton.snp.bottom).offset(9)
            make.centerX.equalToSuperview()
        }
    }
    fileprivate func updataUI(){
        if self.item == nil {
            self.iconButton.isHidden = true
            self.titleLabel.isHidden = true
            self.isUserInteractionEnabled = false
            return
        }else{
//            if item?.type == .CODMoreKeyboardItemTypeCancel {
//                self.iconButton.isHidden = true
//                self.titleLabel.textAlignment = .center
//                self.titleLabel.textColor = UIColor(red: 0.02, green: 0.49, blue: 0.96,alpha:1)
//                self.titleLabel.text = item?.title
//                self.iconButton.isHidden = true
//            }else{
                self.iconButton.isHidden = false
                self.titleLabel.isHidden = false
                self.isUserInteractionEnabled = true
                self.titleLabel.text = item?.title
                self.iconButton.setImage(UIImage(named: (item?.imagePath)!), for: .normal)
                self.titleLabel.textAlignment = .left
                self.titleLabel.textColor = UIColor.black
                self.iconButton.isHidden = false
//            }
            
        }
    }
    @objc func iconButtonDown(){
        if self.clickBlock != nil && self.item != nil{
            self.clickBlock!(self.item!)
        }
    }
}
