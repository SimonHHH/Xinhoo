//
//  CODChatMoreOptionsCell.swift
//  COD
//
//  Created by XinHoo on 2019/10/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODChatMoreOptionsCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
        
    }
    
    public var iconImage: UIImage? {
        didSet {
            imgView.image = iconImage
        }
    }
    
    public var title: String? {
        didSet {
            if let con = title {
                titleLab.text = con
            }
        }
    }
    
    // MARK - 懒加载
    lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 15)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()

    private func setupUI() {
        contentView.addSubviews([imgView, titleLab])
    }
    
    private func setupLayout() {
        
        imgView.snp.makeConstraints { (make) in
            make.left.equalTo(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(47)
            make.height.equalTo(21)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
