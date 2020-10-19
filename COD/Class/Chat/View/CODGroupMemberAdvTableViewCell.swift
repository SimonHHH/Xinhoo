//
//  CODGroupMemberAdvTableViewCell.swift
//  COD
//
//  Created by XinHoo on 2019/8/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupMemberAdvTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var subTitleLab: UILabel!
    
    @IBOutlet weak var topLine: UIView!
        
    @IBOutlet weak var titleHeightContrains: NSLayoutConstraint!
    
    @IBOutlet weak var adminLab: UILabel!
    
    @IBOutlet weak var adminLabWidthConstrains: NSLayoutConstraint!
    @IBOutlet weak var robootImageView: UIImageView!
    
    var userType: UserType = .user {
        didSet {
            
            if userType == .user {
                
                robootImageView.isHidden = true
                robootImageView.fd_collapsed = true
                
                
            } else {
                robootImageView.isHidden = false
                robootImageView.fd_collapsed = false
                
                subTitleStr = NSLocalizedString("机器人", comment: "")
            }
        }
    }
    
    var placeholderStr: String? = nil{
        didSet {
            if let placeholderStr = placeholderStr {
                adminLab.text = placeholderStr
                let fontWidth = placeholderStr.getStringWidth(font: UIFont.systemFont(ofSize: 13.0), lineSpacing: 0, fixedWidth: KScreenWidth)
                adminLabWidthConstrains.constant = fontWidth
            }else{
                adminLab.text = ""
                adminLabWidthConstrains.constant = 0.0
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
    
    var isLast: Bool = false {
        didSet {
            if isLast {
                bottomLine.snp.updateConstraints { (make) in
                    make.left.equalTo(0)
                }
            }else{
                bottomLine.snp.updateConstraints { (make) in
                    make.left.equalTo(66.0)
                }
            }
        }
    }
    
    var titleStr: String? {
        didSet {
            guard let title = titleStr else {
                return
            }
            titleLab.text = title
        }
    }
    
    var subTitleStr: String? {
        didSet {
            if let subtitleStr = subTitleStr, subtitleStr.count > 0 {
                titleHeightContrains.constant = 22.0
            }else{
                titleHeightContrains.constant = 40.0
            }
            subTitleLab.text = subTitleStr
        }
    }
    
    var attributeSubTitleStr: NSAttributedString? {
        didSet {
            if let attributeSubTitleStr = attributeSubTitleStr, attributeSubTitleStr.length > 0 {
                titleHeightContrains.constant = 22.0
            }else{
                titleHeightContrains.constant = 40.0
            }
            subTitleLab.attributedText = attributeSubTitleStr
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        
    }
    
    lazy var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kSepLineColorS)
        return line
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userType = .user
        
        self.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(66)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setData(title: String?, subTitle: NSAttributedString?, placeholer: String?) {
        self.titleStr = title
        if subTitle != nil {
            self.attributeSubTitleStr = subTitle!
        }else{
            self.attributeSubTitleStr = nil
        }
        if placeholer != nil {
            self.placeholderStr = placeholer!
        }else{
            self.placeholderStr = nil
        }
        titleHeightContrains.constant = 22.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
