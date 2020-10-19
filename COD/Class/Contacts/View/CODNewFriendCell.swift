//
//  CODNewFriendCell.swift
//  COD
//
//  Created by 1 on 2019/3/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

protocol CODNewFriendCellDelegate: class {
    func cellBtn(indexPath: IndexPath)
}
class CODNewFriendCell: UITableViewCell {
    
    var cellHeight: CGFloat = 47.5
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: CODNewFriendCellDelegate?
    
    
    public var cellIndexPath: IndexPath? {
        didSet {
        }
    }
    
    public var iconImage: UIImage? {
        didSet {
            imgView.image = iconImage
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
    public var title: String? {
        didSet {
            if let con = title {
                titleLab.text = con
            }
        }
    }
    
    public var type: CODNewFriendStatus? {
        didSet {
            if type == .beAdd {
                self.addButton.isEnabled = true
                self.addButton.backgroundColor = UIColor(hexString: kSubmitBtnBgColorS)
                self.addButton.setTitleColor(UIColor.white, for: .normal)
                self.addButton.setTitle("通过", for: .normal)
            }else if type == .added {
                self.addButton.isEnabled = false
                self.addButton.setTitle("已添加", for: .normal)
                self.addButton.setTitleColor(UIColor(hexString: kSubTitleColors), for: .normal)
                self.addButton.backgroundColor = UIColor(hexString: kVCBgColorS)
            }else if type == .isValidation {
                self.addButton.isEnabled = false
                self.addButton.setTitle("正在等待验证", for: .normal)
                self.addButton.backgroundColor = UIColor.clear
            }else{
                self.addButton.isEnabled = true
                self.addButton.backgroundColor = UIColor(red: 0.02, green: 0.49, blue: 0.96,alpha:1)
                self.addButton.setTitleColor(UIColor.white, for: .normal)
                self.addButton.setTitle("通过", for: .normal)
            }
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
                height = (cellHeight-7.5)/2.0
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
        let imgView = UIImageView(image: UIImage(named: "default_header_80"))
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
        placeholder.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        return placeholder
    }()
    
    private lazy var addButton: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("添加", for: UIControl.State.normal)
//        btn.setTitle("已添加", for: UIControl.State.disabled)
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
        linev.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return linev
    }()
}

extension CODNewFriendCell{
    private func setupUI() {
        contentView.addSubviews([imgView,titleLab,addButton,subTitlePlaceholder,lineView])
        
    }
    
    private func setupLayout() {
        
        imgView.snp.makeConstraints { (make) in
            make.top.equalTo(4)
            make.width.height.equalTo(cellHeight-7)
            make.left.equalTo(15)
            make.bottom.equalTo(-3.5)
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
            make.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
            
        }
    }
    
}
//开关的点击事件
extension CODNewFriendCell{
    
    @objc private func clickButton() {
        if let delegate = self.delegate {
            delegate.cellBtn(indexPath: self.cellIndexPath ?? IndexPath.init(row: 0, section: 0))
        }
    }
}
