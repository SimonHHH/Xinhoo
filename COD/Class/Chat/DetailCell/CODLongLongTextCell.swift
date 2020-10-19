//
//  CODLongLongTextCell.swift
//  COD
//
//  Created by XinHoo on 2019/6/17.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODLongLongTextCell: UITableViewCell {
    
    enum CellType {
        case common
        case channel
    }
    
    var cellType: CellType = .common
    
    let margin: CGFloat = 10
    
    var iconWidth: CGFloat = 0
    var iconHeight: CGFloat = 0
    
    
    typealias LinkActionBlock = (_ linkStr: String) -> ()
    var linkActionBlock: LinkActionBlock?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setChannelLongText(title: String?, subTitle: String?, bottomLineIsHidden: Bool?, isTop: Bool) {
        cellType = .channel
        titleLab.text = title
        titleLab.font = UIFont.systemFont(ofSize: 14.0)
        titleLab.snp.updateConstraints { (make) in
            make.left.equalTo(35.0)
            make.height.equalTo(20.0)
        }
        var subTitleNumOfLines = 0
        subTitle_bottom.font = UIFont.systemFont(ofSize: 17.0)
        if !(subTitle?.contains("https://") ?? false) {
            subTitle_bottom.textColor = UIColor.black
            subTitleNumOfLines = 0
        }else{
            subTitleNumOfLines = 1
            subTitle_bottom.textColor = UIColor(hexString: kSubmitBtnBgColorS)
            let tap = UITapGestureRecognizer(target: self, action: #selector(linkClick))
            subTitle_bottom.addGestureRecognizer(tap)
        }
        
        subTitle_bottom.text = subTitle
        subTitle_bottom.numberOfLines = subTitleNumOfLines
        subTitle_bottom.snp.remakeConstraints { (make) in
            make.top.equalTo(self.titleLab.snp.bottom).offset(1.0)
            
            make.left.equalTo(titleLab)
            make.right.equalTo(-18)
            make.bottom.equalTo(-margin)
            
            if subTitleNumOfLines <= 0 {
                make.height.greaterThanOrEqualTo(24)
            } else {
                make.height.equalTo(24)
            }
        }
        lineView.isHidden = bottomLineIsHidden ?? false
    }
    
    public var title: String? {
        didSet {
            if let con = title {
                titleLab.text = con
            }
        }
    }
    
    public var subTitle: String? {
        didSet {
            if let pText = subTitle, pText.count > 5 {
                subTitle_bottom.text = pText
                subTitle_right.text = ""
                subTitle_bottom.snp.updateConstraints { (make) in
                    make.top.equalTo(self.titleLab.snp.bottom).offset(5.0)
                }
            }else{
                subTitle_bottom.text = ""
                subTitle_right.text = subTitle
                subTitle_bottom.snp.updateConstraints { (make) in
                    make.top.equalTo(self.titleLab.snp.bottom).offset(0.0)
                }
            }
        }
    }
    
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 17.0) {
        didSet {
            titleLab.font = titleFont
        }
    }
    
    public var subTitleFont: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            subTitle_right.font = subTitleFont
            subTitle_bottom.font = subTitleFont
        }
    }
    
    public var subTitleTextColor: UIColor = UIColor(hexString: kSubTitleColors)! {
        didSet {
            subTitle_right.textColor = subTitleTextColor
            subTitle_bottom.textColor = subTitleTextColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if cellType == .common {
            if imageStr?.count == 0 {
                iconView.snp.remakeConstraints { (make) in
                    make.top.equalTo(margin)
                    make.left.equalTo(15)
                    make.width.equalTo(0)
                    make.height.equalTo(contentView.height-2*margin)
                }
                titleLab.snp.remakeConstraints { (make) in
                    make.top.equalTo(margin)
                    make.left.equalTo(iconView.snp.right)
                    make.width.equalTo(KScreenWidth/2)
                    make.height.equalTo(24)
                }
            }else{
                iconView.snp.remakeConstraints { (make) in
                    make.centerY.equalTo(titleLab)
                    make.width.equalTo(iconWidth)
                    make.height.equalTo(iconHeight)
                    make.left.equalTo((65-iconWidth)/2)
                }
                
                titleLab.snp.remakeConstraints { (make) in
                    make.top.equalTo(margin)
                    make.left.equalTo(61)
                    make.width.equalTo(KScreenWidth/2)
                    make.height.equalTo(24)
                }
            }
        }
        
    }
    
    public var imageStr: String? {
        didSet {
            if let imageStr = imageStr, let image = UIImage(named: imageStr) {
                iconWidth = image.size.width
                iconHeight = image.size.height
                iconView.image = image
            }
        }
    }
    
    var isTop: Bool = false {
        didSet {
            if isTop {
                topLine.isHidden = false
            }else{
                topLine.isHidden = true
            }
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
    
    public var setHiddenBottomLine: Bool? {
        didSet {
            guard let setHiddenBottomLine = setHiddenBottomLine else {
                return
            }
            lineView.isHidden = setHiddenBottomLine
        }
    }
    
    
    // MARK - 懒加载
    private lazy var iconView: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = ContentMode.scaleAspectFit
        return imageV
    }()
    
    private lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = titleFont
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    private lazy var subTitle_right: UILabel = {
        let titleLab = UILabel()
        titleLab.font = subTitleFont
        titleLab.textColor = subTitleTextColor
        titleLab.textAlignment = NSTextAlignment.right
        return titleLab
    }()
    
    private lazy var subTitle_bottom: UILabel = {
        let placeholder = UILabel()
        placeholder.textAlignment = NSTextAlignment.left
        placeholder.numberOfLines = 0
        placeholder.font = subTitleFont
        placeholder.textColor = subTitleTextColor
        return placeholder
    }()
    
    private lazy var lineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(hexString: kSepLineColorS)
        return linev
    }()
    
    private lazy var topLine: UIView = {
        let linev = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: KScreenWidth, height: 0.5))
        linev.backgroundColor = UIColor(hexString: kSepLineColorS)
        return linev
    }()
}

extension CODLongLongTextCell{
    private func setupUI() {
        contentView.addSubview(topLine)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLab)
        contentView.addSubview(subTitle_right)
        contentView.addSubview(subTitle_bottom)
        contentView.addSubview(lineView)
    }
    
    private func setupLayout() {

        topLine.isHidden = true
        
        iconView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(18.5)
            make.width.equalTo(contentView.height-2*margin)
            make.height.equalTo(contentView.height-2*margin)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(margin)
            make.left.equalTo(61)
            make.width.equalTo(KScreenWidth/2)
            make.height.equalTo(24)
        }
        
        subTitle_right.snp.makeConstraints { (make) in
            make.top.equalTo(margin)
            make.left.equalTo(titleLab.snp.right)
            make.right.equalTo(-18)
            make.width.equalTo(KScreenWidth/2)
        }

        subTitle_bottom.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(0)
            make.left.equalTo(titleLab)
            make.right.equalTo(-18)
            make.bottom.equalTo(-margin)
            make.height.lessThanOrEqualTo(40)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
    }
    
    @objc func linkClick(linkStr:String) {
        if linkActionBlock != nil , let text = subTitle_bottom.text {
            linkActionBlock!(text)
        }
    }
}
