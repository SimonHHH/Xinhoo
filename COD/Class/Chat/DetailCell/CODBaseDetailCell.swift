//
//  CODBaseDetailCell.swift
//  COD
//
//  Created by 1 on 2019/3/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

let margin: CGFloat = 10

import RxSwift
import RxCocoa
import UIKit

 enum CODCellType {
    case headerType
    case baseType
    case imageType
    case switchType
    case deleteType
    case longTextType
    case memberType
    case textFieldType
    case custom(cellType: UITableViewCell.Type)
}

 struct CODCellModel {
    
    struct RX {
        let iconName: BehaviorRelay<String> = BehaviorRelay(value: "")
        let placeholderString: BehaviorRelay<String> = BehaviorRelay(value: "")
    }
    
    struct Action {
        var switchButtonAction: ((Bool) -> Void)? = nil
        var switchButtonActionWithIndexPath: ((Bool, IndexPath) -> Void)? = nil
        var didSelected: (() -> ())? = nil
        var didSelectedWithModel: ((CODCellModel) -> ())? = nil
    }
    
    var iconName: String? {
        didSet {
            self.rx.iconName.accept(self.iconName ?? "")
        }
    }
    
    @CODBehaviorRelay var title: String?
    
    var titleColor: UIColor?
    
    @CODBehaviorRelay var subTitle: String?
    
    var subTitleColor: UIColor?
    var attributeSubTitle: NSAttributedString?
    var placeholderString:    String? {
        didSet {
            self.rx.placeholderString.accept(self.placeholderString ?? "")
        }
    }
    var type: CODCellType = .baseType
    @CODBehaviorRelay var isOn: Bool?
    var isEnable:   Bool?
    var ishiddenBottomLine: Bool?
    var ishiddenArrow: Bool?
    var tip = ""
    var pinYin = ""  //用于字母排序
    var memberID = ""
    
    var userType: UserType = .user
    
    var action: Action = Action()
    
    var rx: RX = RX()
    
}

extension CODCellModel {
    fileprivate struct AssociatedKeys {
        static var _subTitle: Void = ()
    }
    
//    var subTitleBR: BehaviorRelay<String> {
//        
//        if let title = objc_getAssociatedObject(self, &CODCellModel.AssociatedKeys._subTitle) as? BehaviorRelay<String> {
//            return title
//        }
//
//        let title = BehaviorRelay(value: self.subTitle ?? "")
//        objc_setAssociatedObject(self, &CODCellModel.AssociatedKeys._subTitle, title, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//        
//        return title
//        
//    }
}


class CODBaseDetailCell: UITableViewCell {
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
    
    var iconWidth: CGFloat = 0
    var iconHeight: CGFloat = 0
    
    var isTop: Bool = false {
        didSet {
            if isTop {
                topLine.isHidden = false
            }else{
                topLine.isHidden = true
            }
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if cellType == .common {
            if imageStr?.count == 0 {
                iconView.snp.remakeConstraints { (make) in
                    make.top.equalTo(margin)
                    make.left.equalTo(20)
                    make.width.equalTo(0)
                    make.height.equalTo(contentView.height-2*margin)
                }
                titleLab.snp.remakeConstraints { (make) in
                    make.top.equalTo(margin)
                    make.left.equalTo(iconView.snp.right)
                    make.width.equalTo(KScreenWidth/2)
                    make.height.equalTo(24)
                    make.bottom.equalTo(-margin)
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
                    make.bottom.equalTo(-margin)
                }
            }
        }
        
        guard let isDelete = isDelete else {
            return
        }
        
        if isDelete {
            titleLab.snp.remakeConstraints { (make) in
                make.top.equalTo(margin)
                make.centerX.equalToSuperview()
                make.width.equalTo(KScreenWidth - 100)
            }
            
        }else{
            titleLab.snp.updateConstraints { (make) in
                make.width.equalTo(KScreenWidth/2)
            }
        }

    }
    
    public var imageStr: String? {
        didSet {
            if let imageStr = imageStr, let image = UIImage(named: imageStr) {
                iconWidth = image.size.width
                iconHeight = image.size.height
                iconView.image = image
            }else{
                iconView.image = nil
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
    
    public var titleColor: UIColor? {
        didSet {
            guard let titleColor = titleColor else {
                return
            }
            titleLab.textColor = titleColor
        }
    }
    
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 15.0) {
        didSet {
            titleLab.font = titleFont
        }
    }
    
    public var subTitle: String? {
        didSet {
            var show = false
            if (subTitle?.count)! > 0  {
                subTitleLab.text = subTitle
                show = true
            }
            showSubTilteView(showLab: show)
        }
    }
    
    public var subTitleColor: UIColor? {
        didSet {
            guard let subTitleColor = subTitleColor else {
                return
            }
            subTitleLab.textColor = subTitleColor
        }
    }
    
    public var subTitleFont: UIFont = UIFont.systemFont(ofSize: 15.0) {
        didSet {
            subTitleLab.font = subTitleFont
        }
    }
    
    public var hiddenImage: Bool? {
        didSet {
            imgView.isHidden = hiddenImage!
            if hiddenImage ?? true {
                imgView.snp.updateConstraints { (make) in
                    make.width.equalTo(0.0)
                }
                subTitleLab.snp.updateConstraints { (make) in
                    make.right.equalTo(imgView.snp.left)
                }
            }else{
                imgView.snp.updateConstraints { (make) in
                    make.width.equalTo(13.0)
                }
                subTitleLab.snp.updateConstraints { (make) in
                    make.right.equalTo(imgView.snp.left).offset(-10)
                }
            }
        }
    }
    
    public var isDelete: Bool? {
        didSet {
            if let isDeleteView = isDelete {
                if isDeleteView {
                    titleLab.textColor = UIColor.red
                    titleLab.textAlignment = .center
                    titleLab.snp.updateConstraints { (make) in
                        make.width.equalTo(KScreenWidth - 50)
                    }
                    self.hiddenImage = true
                } else {
                    titleLab.textColor  = UIColor.black
                    titleLab.textAlignment = .left
                    self.hiddenImage = false
                    titleLab.snp.updateConstraints { (make) in
                        make.width.equalTo(KScreenWidth/2)
                    }
                }
            }
        }
    }
    
    public var titleC: UIColor?{
        didSet {
            titleLab.textColor  = titleC!
        }
    }
    
    public var isLast: Bool? {
        didSet {
            guard let isLast = isLast else {
                return
            }
            if isLast {
                lineView.snp.remakeConstraints { (make) in
                    make.left.right.bottom.equalToSuperview()
                    make.height.equalTo(0.5)
                }
            }else{
                lineView.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.titleLab)
                    make.right.bottom.equalToSuperview()
                    make.height.equalTo(0.5)
                }
            }
        }
    }
    
    ///显示subTitle
    private func showSubTilteView(showLab: Bool) {
        if showLab {
            subTitleLab.isHidden = false
        } else {
            subTitleLab.isHidden = true
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
                make.bottom.equalToSuperview().offset(bottomGap)
            }
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
        titleLab.font = UIFont.systemFont(ofSize: 15)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.left
        return titleLab
    }()
    
    lazy var subTitleLab: UILabel = {
        let placeholder = UILabel()
        placeholder.textAlignment = NSTextAlignment.right
        placeholder.font = self.subTitleFont
        placeholder.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        return placeholder
    }()
    
    private lazy var subTitlePlaceholder: UILabel = {
        let placeholder = UILabel()
        placeholder.textAlignment = NSTextAlignment.left
        placeholder.font = UIFont.systemFont(ofSize: 12)
        placeholder.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        return placeholder
    }()
    
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "next_step_icon"))
        return imgView
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

extension CODBaseDetailCell{
    private func setupUI() {
        self.addSubview(topLine)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLab)
        contentView.addSubview(subTitleLab)
        contentView.addSubview(subTitlePlaceholder)
        contentView.addSubview(imgView)
        self.addSubview(lineView)
    }
    
    private func setupLayout() {
//        topLine.snp.makeConstraints { (make) in
//            make.left.right.top.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
        
        
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
            make.bottom.equalTo(-margin)
        }
        
        imgView.snp.makeConstraints { (make) in
            make.width.equalTo(13)
            make.height.equalTo(13)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(titleLab)
        }
        
        subTitleLab.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab.snp.right).offset(margin)
            make.right.equalTo(imgView.snp.left).offset(-9)
            make.centerY.equalTo(imgView)
        }
        
        subTitlePlaceholder.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalTo(imgView)
            make.top.equalTo(titleLab.snp.bottom).offset(12)
            make.bottom.equalTo(self.contentView).offset(-3)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
    }
}
