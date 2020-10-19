//
//  CODPersonHeaderView.swift
//  COD
//
//  Created by 1 on 2019/3/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODPersonHeaderView: UIView {
    
    let labelRightContrains = 80.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var roomID: Int?
    
    public var iconImage: UIImage? {
        didSet {
            self.iconImageView.image = iconImage
        }
    }
    
    public var userAvatar: String? {
        didSet {
            self.iconImageView.cod_loadHeader(url: URL(string: userAvatar?.getHeaderImageFullPath(imageType: 1) ?? "")) { [weak self] _, _, _, _ in
            }
            
        }
    }
    
    ///在线状态
    public var statusString: NSAttributedString? {
        didSet {
            if let statusString = statusString {
                statusLab.attributedText = statusString
            }
        }
    }
    
    /// 原昵称
    public var nameString: String? {
        didSet {
            if let con = nameString {
                nameLab.text = con
            }else{
                nameLab.text = ""
            }
        }
    }
    
    /// 富文本原昵称 
    public var attrNameString: NSAttributedString? {
        didSet {
            if let con = attrNameString {
                nameLab.attributedText = con
            }else {
                nameLab.attributedText = NSAttributedString.init(string: "")
            }
        }
    }
 
    public var isWoman: Bool? {
        didSet {
            if let isWoman = isWoman {
                sexImageView.image = isWoman ? UIImage(named: "woman_icon") : UIImage(named: "man_icon")
            }else{
                sexImageView.image = UIImage(named: "nogender_icon")
            }
        }
    }
    
    /// 当备注名存在显示的昵称
    public var nickNameString: String? {
        didSet {
            if let nickNameString = nickNameString {
                nickNameLab.text = nickNameString
            }else {
                nickNameLab.text = ""
            }
        }
    }
    
    /// 群昵称
    public var groupNickString: String? {
        didSet {
            if let groupNickString = groupNickString {
                groupNickLab.text = groupNickString
            }else{
                groupNickLab.text = ""
            }
        }
    }
    
    // MARK - 懒加载
    lazy var iconImageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "default_header_110"))
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 66/2
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    /// 备注名/昵称
    private lazy var nameLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.boldSystemFont(ofSize: 19)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    private lazy var sexImageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "nogender_icon"))
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    /// 群昵称
    private lazy var groupNickLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 14)
        titleLab.textColor = UIColor(hexString: kSubTitleColors)
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    /// 当备注名存在显示的昵称
    private lazy var nickNameLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 14)
        titleLab.textColor = UIColor(hexString: kSubTitleColors)
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    private lazy var statusLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 14)
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    private lazy var topLine: UIView = {
        let topLine = UIView()
        topLine.backgroundColor = UIColor(hexString: kSepLineColorS)
        return topLine
    }()
    
    lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(hexString: kSepLineColorS)
        return bottomLine
    }()
    
    override func layoutSubviews() {
        if nameString != nil && nickNameString != nil && groupNickString != nil {
            sexImageView.snp.remakeConstraints { (make) in
                make.left.equalTo(iconImageView.snp.right).offset(11)
                make.bottom.equalTo(iconImageView).offset(17)
                make.width.height.equalTo(17)
            }
            nickNameLab.snp.remakeConstraints { (make) in
                make.bottom.equalTo(groupNickLab.snp.top).offset(-1)
                make.left.equalTo(nameLab)
                make.right.equalToSuperview().offset(-labelRightContrains)
            }
            self.height = 108
        }else{
            if nickNameString != nil {
                nickNameLab.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(groupNickLab.snp.top).offset(-1)
                    make.left.equalTo(nameLab)
                    make.right.equalToSuperview().offset(-labelRightContrains)
                }
            }else{
                nickNameLab.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(groupNickLab.snp.top).offset(0)
                    make.left.equalTo(nameLab)
                    make.right.equalToSuperview().offset(-labelRightContrains)
                }
            }
            sexImageView.snp.remakeConstraints { (make) in
                make.left.equalTo(iconImageView.snp.right).offset(11)
                make.bottom.equalTo(iconImageView).offset(-3)
                make.width.height.equalTo(17)
            }
            self.height = 90
        }
        if isWoman == nil {
            sexImageView.snp.remakeConstraints { (make) in
                make.left.equalTo(iconImageView.snp.right).offset(11)
                make.bottom.equalTo(iconImageView).offset(-3)
                make.width.equalTo(0)
            }
        }
    }
}

private extension CODPersonHeaderView{
    func setupUI() {
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor.white
        
        self.addSubviews([bgView,iconImageView,nameLab,sexImageView,nickNameLab,statusLab,groupNickLab,bottomLine,topLine])
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
        }
        
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(16)
            make.left.equalTo(self).offset(15)
            make.width.height.equalTo(66)
        }
        
        sexImageView.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(11)
            make.bottom.equalTo(iconImageView).offset(-3)
            make.width.height.equalTo(17)
        }
        
        statusLab.snp.makeConstraints { (make) in
            make.left.equalTo(sexImageView.snp.right).offset(5)
            make.right.equalToSuperview().offset(-labelRightContrains)
            make.centerY.equalTo(sexImageView)
        }
        
        groupNickLab.snp.makeConstraints { (make) in
            make.bottom.equalTo(sexImageView.snp.top).offset(-1)
            make.left.equalTo(nameLab)
            make.right.equalToSuperview().offset(-labelRightContrains)
        }
        
        nickNameLab.snp.makeConstraints { (make) in
            make.bottom.equalTo(groupNickLab.snp.top).offset(-1)
            make.left.equalTo(nameLab)
            make.right.equalToSuperview().offset(-labelRightContrains)
        }
        
        nameLab.snp.makeConstraints { (make) in
            make.bottom.equalTo(nickNameLab.snp.top).offset(-3)
            make.left.equalTo(iconImageView.snp.right).offset(11)
            make.right.equalToSuperview().offset(-labelRightContrains)
        }
        
        topLine.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
}
