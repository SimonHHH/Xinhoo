//
//  CODGroupMemberCell.swift
//  COD
//
//  Created by XinHoo on 2019/3/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

enum SelectType: Int {
    case unselected = 0
    case selected
    case unableSelected
    case none
}

class CODGroupMemberCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var cellIndexPath: IndexPath? {
        didSet {
            
        }
    }
    
    public var iconImage: UIImage? {
        didSet {
            imgView.image = iconImage
        }
    }
    
    public var urlStr :String? {
        didSet {
//            imgView.sd_setImage(with: URL.init(string: urlStr ?? ""), placeholderImage: UIImage.init(named: "default_header_110"))
            imgView.image = UIImage(named: "default_header_110")  //避免复用时闪现其他人的头像
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: urlStr ?? "") { (image) in
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
    
    public var attribuTitle: NSAttributedString? {
        didSet {
            if let con = attribuTitle {
                titleLab.attributedText = con
            }
        }
    }
    
    public var isHiddenRedView: Bool? {
        didSet {
            redView.isHidden = (isHiddenRedView ?? false)
        }
    }
    public var isLast: Bool? {
        didSet {
            lineView.isHidden = isLast!
        }
    }
    
    public var selectType: SelectType = .unselected {
        didSet{
            if selectType == .none {
                selectedView.snp.remakeConstraints { (make) in
                    make.width.equalTo(0)
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview().offset(14)
                }
            }else{
                selectedView.snp.remakeConstraints { (make) in
                    make.width.equalTo(22)
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview().offset(14)
                }
            }
            
            switch selectType.rawValue {
            case 0:
                selectedView.image = UIImage(named: "person_select")
            case 1:
                selectedView.image = UIImage(named: "person_selected")
            case 2:
                selectedView.image = UIImage(named: "person_unable_selected")
            default:
                selectedView.image = nil
            }
            
        }
    }
    
    public var placeholder: String? {
        didSet {
            var placeHolderStr = ""
            
            if placeholder != nil && (placeholder?.charactersArray.count)! > 0 {
                placeHolderStr = placeholder!
                subTitlePlaceholder.text = placeHolderStr
                
                titleLab.snp.updateConstraints { (make) in
                    make.height.equalTo(20)
                }
                subTitlePlaceholder.snp.updateConstraints { (make) in
                    make.height.equalTo(20)
                }
            }else{
                subTitlePlaceholder.text = placeHolderStr
                titleLab.snp.updateConstraints { (make) in
                    make.height.equalTo(40)
                    
                }
                subTitlePlaceholder.snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                }
            }
        }
    }
    
    public var placeholerColor: UIColor? = UIColor.init(hexString: kSectionHeaderTextColorS) {
        didSet {
            subTitlePlaceholder.textColor = placeholerColor
        }
    }
    
    lazy var selectedView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "person_select"))
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    // MARK - 懒加载
    lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.cornerRadius = 20.0
        return imgView
    }()
    
    private lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 16)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    private lazy var subTitlePlaceholder: UILabel = {
        let placeholder = UILabel()
        placeholder.textAlignment = NSTextAlignment.left
        placeholder.font = UIFont.systemFont(ofSize: 12)
        placeholder.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        placeholder.backgroundColor = UIColor.clear
        return placeholder
    }()
    
    //红点
    private lazy var redView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor.red
        linev.isHidden = true
        return linev
    }()
    
    private lazy var lineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return linev
    }()
    
}

extension CODGroupMemberCell{
    private func setupUI() {
        contentView.addSubviews([selectedView, imgView, titleLab, subTitlePlaceholder, lineView, redView])
        
    }
    
    private func setupLayout() {
        
        selectedView.snp.makeConstraints { (make) in
            make.width.equalTo(22)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(14)
        }
        
        imgView.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.equalTo(selectedView.snp.right).offset(9)
            make.top.equalTo(4)
            make.bottom.lessThanOrEqualTo(-3)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(imgView)
            make.left.equalTo(imgView.snp.right).offset(10)
            make.right.equalTo(-18)
            make.height.equalTo(21)
        }
        
        subTitlePlaceholder.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom)
            make.left.equalTo(titleLab)
            make.bottom.equalTo(imgView)
            make.height.equalTo(21)
        }
        
        redView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab.snp.right).offset(5)
            make.width.height.equalTo(8)
            make.centerY.equalTo(titleLab)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
    }
    
}
