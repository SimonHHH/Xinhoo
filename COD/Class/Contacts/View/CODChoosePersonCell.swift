//
//  CODChoosePersonCell.swift
//  COD
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODChoosePersonCell: UITableViewCell {
    
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
    
    public var cellIndexPath: IndexPath? {
        didSet {
            
        }
    }
    
    public var iconImage: UIImage? {
        didSet {
            if let img = iconImage {
                imgView.image = img
            }
            imgView.isHidden = iconImage == nil
            
        }
    }
    
    /// 区分群组还是频道的图标
    public var iconGCImage: UIImage?
    
    
    public var urlStr :String? {
        didSet {
            self.imgView.isHidden = false
            self.imgView.cod_loadHeaderByCache(url: URL.init(string: urlStr ?? ""))
        }
    }
    
    public var title: String? {
        didSet {
            if let con = title {
                titleLab.text = con
            }
            
            if title == "\(kApp_Name)小助手", let _ = title {
                let attriStr = NSMutableAttributedString.init(string: CustomUtil.formatterStringWithAppName(str: "%@小助手"))
                let textAttachment = NSTextAttachment.init()
                let img = UIImage(named: "cod_helper_sign")
                textAttachment.image = img
                textAttachment.bounds = CGRect.init(x: 0, y: 0, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
                let attributedString = NSAttributedString.init(attachment: textAttachment)
                attriStr.append(attributedString)
                titleLab.attributedText = attriStr
            }else{
                titleLab.text = title
            }
        }
    }
    
    public var attributedTitle: NSAttributedString? {
        didSet {
            if let title = attributedTitle {
                titleLab.attributedText = title
            }
        }
    }
    
    public var titleColor: UIColor = UIColor.black {
        didSet {
            titleLab.textColor = titleColor
        }
    }
    
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            titleLab.font = titleFont
        }
    }
    
    public var titleTextAlignment = NSTextAlignment.left {
        didSet {
            titleLab.textAlignment = titleTextAlignment
        }
    }
    
    public var placeholerColor: UIColor? = UIColor.init(hexString: kSectionHeaderTextColorS) {
        didSet {
            subTitlePlaceholder.textColor = placeholerColor
        }
    }
    
    public var isHiddenRedView: Int? {
        didSet {
            if isHiddenRedView ?? 0 > 0 {
                redView.isHidden = false
                redView.text = String(format: "%ld", isHiddenRedView ?? 0)
            }else{
                redView.isHidden = true
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
                height = (cellHeight-7.0)/2.0
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
    lazy var imgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: ""))
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    lazy var iconImgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: ""))
        imgView.contentMode = .scaleAspectFill
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
    
    //红点
    private lazy var redView: UILabel = {
        let linev = UILabel.init()
        linev.backgroundColor = UIColor.red
        linev.textColor = UIColor.white
        linev.isHidden = true
        linev.textAlignment = .center
        linev.font = UIFont.systemFont(ofSize: 12)
        return linev
    }()
    
    private lazy var lineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        return linev
    }()
    
}

extension CODChoosePersonCell{
    private func setupUI() {
        contentView.addSubviews([imgView,titleLab,subTitlePlaceholder,lineView,redView])
    }
    
    private func setupLayout() {
        
        imgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(cellHeight-7)
            make.left.equalTo(14)
            make.bottom.equalToSuperview().offset(-4)
        }
        
        imgView.layer.cornerRadius =  (cellHeight-7)/2.0
        imgView.clipsToBounds = true
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(imgView).offset(-2)
            make.left.equalTo(imgView.snp.right).offset(12)
            make.right.equalTo(-(12+14+cellHeight-7))
            make.width.lessThanOrEqualTo(KScreenWidth - 24 - (cellHeight-7) - 14)
        }
        
        redView.layer.cornerRadius =  18/2
        redView.clipsToBounds = true
        redView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab.snp.left).offset(150)
            make.width.height.equalTo(18)
            make.centerY.equalTo(titleLab)
        }
        
        subTitlePlaceholder.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom)
            make.left.right.equalTo(titleLab)
            make.bottom.equalTo(imgView).offset(2)
            make.height.equalTo(0)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab.snp.left)
            make.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
        
    }
}

