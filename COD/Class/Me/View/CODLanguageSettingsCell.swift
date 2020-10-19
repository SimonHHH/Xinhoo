//
//  CODLanguageSettingsCell.swift
//  COD
//
//  Created by 1 on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODLanguageSettingsCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
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
    public var isLast: Bool? {
        didSet {
            lineView.isHidden = isLast!
        }
    }
    public var isHiddenImage: Bool? {
        didSet {
            imgView.isHidden = isHiddenImage!
        }
    }
    // MARK - 懒加载
    private lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 15)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "selectlanguage_icon"))
        imgView.tag = 10
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private lazy var lineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return linev
    }()
}
extension CODLanguageSettingsCell{
    private func setupUI() {
        contentView.addSubview(titleLab)
        contentView.addSubview(imgView)
        contentView.addSubview(lineView)
    }
    
    private func setupLayout() {
        let margin: CGFloat = 20
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(11)
            make.left.equalTo(margin)
            make.width.equalTo(KScreenWidth/2)
            make.bottom.equalTo(self.contentView).offset(-12)
        }
        
        imgView.snp.makeConstraints { (make) in
            make.width.equalTo(14)
            make.height.equalTo(12)
            make.right.equalTo(-20)
            make.centerY.equalTo(self.contentView)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
    }
}
