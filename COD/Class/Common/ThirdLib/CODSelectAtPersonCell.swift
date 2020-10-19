//
//  CODSelectAtPersonCell.swift
//  COD
//
//  Created by 1 on 2020/8/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODSelectAtPersonCell: UITableViewCell {
    
    var iconWidth: CGFloat = 32
    var iconHeight: CGFloat = 32
    // MARK - 懒加载
    lazy var iconView: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = ContentMode.scaleAspectFit
        imageV.layer.cornerRadius = iconWidth/2
        imageV.clipsToBounds = true
        return imageV
    }()
    
    lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 15)
        titleLab.textColor = UIColor.white
        titleLab.textAlignment = NSTextAlignment.left
        titleLab.numberOfLines = 1
        return titleLab
    }()
    
//    private lazy var subTitlePlaceholder: UILabel = {
//        let placeholder = UILabel()
//        placeholder.textAlignment = NSTextAlignment.left
//        placeholder.font = UIFont.systemFont(ofSize: 12.0)
//        placeholder.textColor = UIColor(hexString: kSubTitleColors8E8E92)
//        return placeholder
//    }()
    
    private lazy var lineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1)
        return linev
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        contentView.addSubview(iconView)
        contentView.addSubview(titleLab)
        self.addSubview(lineView)
    }
    
    private func setupLayout() {
        
        iconView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(8)
            make.width.height.equalTo(iconWidth)
        }

        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconView.snp.right).offset(11)
            make.right.equalTo(self.contentView).offset(-11)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
