//
//  CODMessageDetailSwitchCell.swift
//  COD
//
//  Created by 1 on 2019/11/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

protocol CODMessageDetailSwitchCellDelegate: class {
    func cellSwichBtn(index: Int,isOn: Bool)
}

typealias switchBlock = (Bool) -> ()


class CODMessageDetailSwitchCell: UITableViewCell {
    enum CellType {
        case common
        case channel
    }
    
    var cellType: CellType = .common {
        didSet {
            if cellType == .channel {
                titleLab.snp.updateConstraints { (make) in
                    make.left.equalTo(35.0)
                }
            }
        }
    }
    
    let margin: CGFloat = 10
    let gap :CGFloat = 3
    
    var iconWidth: CGFloat = 40
    var iconHeight: CGFloat = 40
    
    var isTop: Bool = false {
        didSet {
            if isTop {
                topLine.isHidden = false
            }else{
                topLine.isHidden = true
            }
        }
    }
    
    var onBlock : switchBlock?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: CODMessageDetailSwitchCellDelegate?
    public var index = 0
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if cellType == .common {
            if imageStr?.count ?? 0 == 0 {
                iconView.snp.remakeConstraints { (make) in
                    make.top.equalTo(margin)
                    make.left.equalTo(15)
                    make.width.equalTo(0)
                    make.height.equalTo(contentView.height-2*margin)
                }
                titleLab.snp.remakeConstraints { (make) in
                    make.top.equalTo(margin)
                    make.left.equalTo(iconView.snp.right)
                    make.right.equalTo(switchBtn.snp.left).offset(-15)
                    make.height.equalTo(24)
                }
            }else{
                iconView.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.width.equalTo(iconWidth)
                    make.height.equalTo(iconHeight)
                    make.left.equalTo((65-iconWidth)/2)
                }
                titleLab.snp.remakeConstraints { (make) in
                    make.top.equalTo(margin)
                    make.left.equalTo(61)
                    make.right.equalTo(switchBtn.snp.left).offset(-15)
                    make.height.equalTo(24)
                }
            }
        }
        
        var titleLabGap: CGFloat = 0
        var topGap: CGFloat = 0
        var placeholerBottom: CGFloat = 0
        
        if subTitlePlaceholder.text?.count ?? 0 > 0 {
            titleLabGap = gap
            topGap = 1
            placeholerBottom = -gap-2
        }else{
            titleLabGap = margin
            topGap = 0
            placeholerBottom = -margin
        }
        titleLab.snp.updateConstraints { (make) in
            make.top.equalTo(titleLabGap)
        }
        subTitlePlaceholder.snp.updateConstraints { (make) in
            make.top.equalTo(self.titleLab.snp.bottom).offset(topGap)
            make.bottom.equalTo(placeholerBottom)
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
    
    public var enable: Bool! {
        didSet {
            switchBtn.isEnabled = enable
        }
    }
    
    public var switchIsOn: Bool? {
        didSet {
            switchBtn.isOn = switchIsOn ?? false
        }
    }
    
    public var hiddenImage: Bool? {
        didSet {
            switchBtn.isHidden = hiddenImage!
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
            subTitlePlaceholder.text = placeholer
        }
    }
    
    public var placeholerAttrStr: NSAttributedString? {
        didSet {
            subTitlePlaceholder.attributedText = placeholerAttrStr
        }
    }
    
    // MARK - 懒加载
    lazy var iconView: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = ContentMode.scaleAspectFit
        imageV.layer.cornerRadius = iconWidth/2
        imageV.clipsToBounds = true
        return imageV
    }()
    
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
        placeholder.font = UIFont.systemFont(ofSize: 13.0)
        placeholder.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        return placeholder
    }()
    
    lazy var switchBtn: UISwitch = {
        let btn = UISwitch()
        btn.setOn(false, animated: true)
        btn.addTarget(self, action: #selector(clickSwitch), for: .valueChanged)
        btn.onTintColor = UIColor.init(hexString: "7BD772")
        return btn
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

extension CODMessageDetailSwitchCell{
    private func setupUI() {
        self.addSubview(topLine)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLab)
        contentView.addSubview(subTitlePlaceholder)
        contentView.addSubview(switchBtn)
        self.addSubview(lineView)
    }
    
    private func setupLayout() {
        
        topLine.isHidden = true
        
        iconView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(18.5)
            make.width.equalTo(contentView.height-2*margin)
            make.height.equalTo(contentView.height-2*margin)
        }
        
        switchBtn.snp.makeConstraints { (make) in
            make.width.equalTo(51)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(margin)
            make.left.equalTo(61)
            make.right.equalTo(switchBtn.snp.left).offset(-15)
            make.height.equalTo(24)
            make.bottom.equalTo(-margin)
        }
        
        subTitlePlaceholder.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalTo(switchBtn.snp.left).offset(-15)
            make.top.equalTo(titleLab.snp.bottom).offset(3)
            make.bottom.equalTo(self.contentView).offset(-3)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
        
    }
}

//开关的点击事件
extension CODMessageDetailSwitchCell{
    
    @objc private func clickSwitch(switchBtn: UISwitch) {
        if let delegate = self.delegate {
            delegate.cellSwichBtn(index: index,isOn: switchBtn.isOn)
        }
        
        if (self.onBlock != nil) {
            self.onBlock?(switchBtn.isOn)
//            switchBtn.isOn = !switchBtn.isOn
        }
    }
}
