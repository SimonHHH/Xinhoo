//
//  CODDetailImageCell.swift
//  COD
//
//  Created by 1 on 2019/3/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

enum cellType: Int {
    case arrow
    case none
}

class CODDetailImageCell: UITableViewCell {
    
    var cellType :cellType = .none {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        if cellType == .arrow {
            arrowView.snp.remakeConstraints { (make) in
                make.right.equalTo(-18)
                make.centerY.equalTo(self.contentView)
                make.width.equalTo(13)
                make.height.equalTo(13)
            }
            imgView.snp.remakeConstraints { (make) in
                make.right.equalTo(arrowView.snp.left).offset(-10)
                make.centerY.equalTo(self.titleLab)
            }
        }else{
            arrowView.snp.remakeConstraints { (make) in
                make.centerY.equalTo(self.contentView)
                make.right.equalToSuperview()
                make.width.height.equalTo(0)
            }
            imgView.snp.remakeConstraints { (make) in
                make.right.equalTo(-18)
                make.centerY.equalTo(self.contentView)
            }
        }
    }

    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
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
    
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 17.0) {
        didSet {
            titleLab.font = titleFont
        }
    }
    
    public var imageV: UIImage? {
        didSet {
            imgView.image = imageV
        }
    }
    public var isLast: Bool? {
        didSet {
            guard let isLast = isLast else {
                return
            }
            if isLast {
                lineView.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.right.equalTo(self.contentView)
                    make.bottom.equalTo(self.contentView)
                    make.height.equalTo(0.5)
                }
            }else{
                lineView.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.titleLab)
                    make.right.equalTo(self.contentView)
                    make.bottom.equalTo(self.contentView)
                    make.height.equalTo(0.5)
                }
            }
        }
    }
    
    public var placeholer: String? {
        didSet {
            var placeholerString = ""
            var bottomGap = 0
            if placeholer?.count ?? 0 > 0 {
                placeholerString  = placeholer!
                bottomGap = -3
            }else{
                subTitlePlaceholder.text = ""
                bottomGap = 0
            }
            subTitlePlaceholder.text = placeholerString
            subTitlePlaceholder.snp.updateConstraints { (make) in
                make.bottom.equalTo(self.contentView).offset(bottomGap)
            }
        }
    }
    
    // MARK - 懒加载
    private lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = self.titleFont
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    
    private lazy var subTitlePlaceholder: UILabel = {
        let placeholder = UILabel()
        placeholder.textAlignment = NSTextAlignment.left
        placeholder.font = UIFont.systemFont(ofSize: 12)
        placeholder.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        return placeholder
    }()
    
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private lazy var arrowView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "next_step_icon"))
        return imgView
    }()
    
    private lazy var lineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return linev
    }()
}

extension CODDetailImageCell{
    private func setupUI() {
        contentView.addSubview(titleLab)
        contentView.addSubview(subTitlePlaceholder)
        contentView.addSubview(imgView)
        contentView.addSubview(lineView)
        contentView.addSubview(arrowView)
    }
    
    private func setupLayout() {
        let margin: CGFloat = 12
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(margin)
            make.left.equalTo(25)
            make.width.equalTo(KScreenWidth/2)
        }
        
        imgView.snp.makeConstraints { (make) in
            make.right.equalTo(-18)
            make.centerY.equalTo(self.contentView)
        }
        
        subTitlePlaceholder.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalTo(imgView)
            make.top.equalTo(titleLab.snp.bottom).offset(12)
            make.bottom.equalTo(self.contentView).offset(-3)
        }
        
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
            
        }
        
        arrowView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.right.equalToSuperview()
            make.width.height.equalTo(0)
        }
    }
}

