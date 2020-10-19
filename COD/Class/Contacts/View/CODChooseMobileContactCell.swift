//
//  CODChooseMobileContactCell.swift
//  COD
//
//  Created by 1 on 2019/3/14.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
protocol CODChooseMobileContactCellDelegate: class {
    func contactCellBtn(indexPath: IndexPath)
}

class CODChooseMobileContactCell: UITableViewCell {
    
    var cellHeight: CGFloat = 47.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: CODChooseMobileContactCellDelegate?

    
    public var cellIndexPath: IndexPath? {
        didSet {
        }
    }
    public var iconUrlString: String? {
        didSet {
//            self.imgView.sd_setImage(with: URL.init(string:iconUrlString?.getHeaderImageFullPath(imageType: 0) ?? ""), placeholderImage: UIImage.init(named: "default_header_80"))
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: iconUrlString ?? "") { (image) in
                self.imgView.image = image
            }
        }
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
    
    public var style: ContactStyle = .unregistered {
        didSet {
            self.addButton.borderColor = nil
            self.addButton.borderWidth = 0.0
            switch self.style {
            case .unregistered ,.notFriend:
                self.addButton.isHidden = false
                self.addButton.isEnabled = true
                var title = ""
                if self.style == .unregistered {
                    title = "邀请"
                    self.addButton.backgroundColor = UIColor.clear
                    self.addButton.setTitleColor(UIColor(hexString: kTabItemSelectedColorS), for: .normal)
                    self.addButton.borderColor = UIColor(hexString: kTabItemSelectedColorS)
                    self.addButton.borderWidth = 1.0
                }else{
                    title = "添加"
                    self.addButton.backgroundColor = UIColor(hexString: kSubmitBtnBgColorS)
                    self.addButton.setTitleColor(UIColor.white, for: .normal)
                }
                self.addButton.setTitle(title, for: UIControl.State.normal)
            case .isFriend:
                self.addButton.isHidden = false
                self.addButton.isEnabled = false
                self.addButton.backgroundColor = UIColor.clear
                self.addButton.setTitleColor(UIColor(hexString: kSubTitleColors), for: .normal)
            }
        }
    }

    public var isAdd: Bool? {
        didSet {

            if let isAddC = isAdd {
                self.addButton.isHidden = false
                self.addButton.isEnabled = !isAddC
                if isAddC {
                    self.addButton.backgroundColor = UIColor(hexString: kVCBgColorS)
                    self.addButton.setTitleColor(UIColor(hexString: kSubTitleColors), for: .normal)
                }else{
                    self.addButton.backgroundColor = UIColor(hexString: kSubmitBtnBgColorS)
                    self.addButton.setTitleColor(UIColor.white, for: .normal)
                }
            }else{
                self.addButton.isHidden = true
            }
        }
    }
    
    public var isHiddenBtn: Bool? {
        didSet {
            self.addButton.isHidden = isHiddenBtn ?? false
        }
    }
    public var isLast: Bool? {
        didSet {
            lineView.isHidden = isLast!
        }
    }
    
    public var placeholer: String? {
        didSet {
            var placeholerString = ""
            var height: CGFloat = 0.0
            var bottom: CGFloat = 0.0
            if placeholer?.count ?? 0 > 0 {
                placeholerString  = placeholer!
                height = (cellHeight-7)/2.0
                bottom = 2.5
            }else{
                subTitlePlaceholder.text = ""
                height = 0.0
                bottom = 2.0
            }
            subTitlePlaceholder.text = placeholerString
            
            subTitlePlaceholder.snp.updateConstraints { (make) in
                make.height.equalTo(height)
                make.bottom.equalTo(imgView).offset(bottom)
            }
        }
    }
    
    // MARK - 懒加载
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.cornerRadius = (cellHeight-7.5)/2
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 17)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    private lazy var subTitlePlaceholder: UILabel = {
        let placeholder = UILabel()
        placeholder.textAlignment = NSTextAlignment.left
        placeholder.font = UIFont.systemFont(ofSize: 13)
        placeholder.textColor = UIColor.init(hexString: "007EE5")
        return placeholder
    }()
    
    private lazy var addButton: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("添加", for: UIControl.State.normal)
        btn.setTitle("已添加", for: UIControl.State.disabled)
        btn.setTitleColor(UIColor.white, for:.normal)
        btn.setTitleColor(UIColor(hexString: kSubTitleColors8E8E92), for: .disabled)
        btn.backgroundColor = UIColor(red: 0.01, green: 0.45, blue: 0.89, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds  = true
        btn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        return btn
    }()
    
    private lazy var lineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(hexString: kSepLineColorS)
        return linev
    }()
}

extension CODChooseMobileContactCell{
    private func setupUI() {
        contentView.addSubviews([imgView,titleLab,addButton,subTitlePlaceholder,lineView])
    
    }
    
    private func setupLayout() {
        
        imgView.snp.makeConstraints { (make) in
            make.width.height.equalTo(cellHeight-7)
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(3.5)
            make.bottom.equalToSuperview().offset(-3.5)
        }
        
        addButton.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalTo(self.contentView)
            make.height.equalTo(24)
            make.width.equalTo(57)
        }
        
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(imgView).offset(-2)
            make.left.equalTo(imgView.snp.right).offset(12)
            make.right.equalTo(addButton.snp.left).offset(-12)
        }

        subTitlePlaceholder.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom)
            make.left.right.equalTo(titleLab)
            make.height.equalTo(0)
            make.bottom.equalTo(imgView).offset(2)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab.snp.left)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
            
        }
    }
    
}
//开关的点击事件
extension CODChooseMobileContactCell{
    
    @objc private func clickButton(switchBtn: UISwitch) {
        if let delegate = self.delegate {
            delegate.contactCellBtn(indexPath: self.cellIndexPath ?? IndexPath.init(row: 0, section: 0))
        }
    }

}

