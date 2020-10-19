//
//  CODGroupMemberTextSelectCell.swift
//  COD
//
//  Created by XinHoo on 2019/8/5.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupMemberTextSelectCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.backgroundColor = UIColor.clear
    }
    
    public var memberText: String? {
        didSet {
            if let memberText = memberText {
                let text = "\(memberText),"
                self.nameLab.text = text
                let textSize = text.getStringWidth(font: self.nameLab.font, lineSpacing: 0, fixedWidth: KScreenWidth-10)
                self.nameLab.snp.remakeConstraints { (make) in
                    make.left.top.right.bottom.equalToSuperview()
                    make.width.equalTo(textSize)
                    make.height.equalTo(34.0)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var nameLab: UILabel = {
        let nameLab = UILabel()
        nameLab.textAlignment = NSTextAlignment.center
        nameLab.font = UIFont.systemFont(ofSize: 15.0)
        nameLab.textColor = UIColor.init(hexString: kNavTitleColorS)
        return nameLab
    }()
    
    
    
    func setupUI() {
        self.contentView.addSubview(nameLab)
        nameLab.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
}
