//
//  CODFavoriteCell.swift
//  COD
//
//  Created by XinHoo on 2019/3/13.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import SwipeCellKit

let cellNormalHeight = 127.0


enum ContentType {
    case text
    case image
    case location
}

class CODFavoriteCell: SwipeTableViewCell {
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        
        self.addRequiredSubView()
        
        headerView.image = UIImage(named: "default_header_110")
        nameLab.text = "张无忌"
        timeLab.text = "今天"
    }
    
    open var contentType: ContentType?{
        didSet{
            if contentType == ContentType.text {
                
                self.addTextContentView()
                
                textContentLab.text = "是你吗？"
                
            }else if contentType == ContentType.image {
                
                self.addImageContentView()
                
                textContentImage.image = UIImage(named: "user_header")
                
            }else if contentType == ContentType.location {
                
                self.addLocationContentView()
                
                locationTitleLab.text = "[位置]"
                locationSubTitleLab.text = "深圳市龙岗区坂田街道"
            }
        }
    }
    
    
    func addRequiredSubView() {
        self.addSubview(bgView)
        bgView.addSubview(headerView)
        bgView.addSubview(nameLab)
        bgView.addSubview(timeLab)
        
        bgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(cellNormalHeight)
        }
        
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(23)
        }
        
        nameLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(headerView)
            make.left.equalTo(headerView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-80)
            make.height.equalTo(23)
        }
        
        timeLab.snp.makeConstraints { (make) in
            make.bottom.equalTo(nameLab)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(50)
            make.height.equalTo(13)
        }
    }
    
    
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.cornerRadius = kCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    lazy var headerView: UIImageView = {
        let imgV = UIImageView()
        return imgV
    }()
    
    lazy var nameLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hexString: kSubTitleColors)
        lab.font = UIFont.systemFont(ofSize: 16)
        return lab
    }()
    
    lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hexString: kSubTitleColors)
        lab.textAlignment = NSTextAlignment.right
        lab.font = UIFont.systemFont(ofSize: 13)
        return lab
    }()
    
    
    
    /// ContentType.text
    lazy var textContentLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 16)
        return lab
    }()
    
    /// ContentType.image
    lazy var textContentImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    /// ContentType.Location
    lazy var locationBg: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var locationIcon: UIImageView = {
        let imgV = UIImageView()
        imgV.image = UIImage(named: "favorite_location_icon")
        return imgV
    }()
    
    lazy var locationTitleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 16)
        return titleLab
    }()
    
    lazy var locationSubTitleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.textColor = UIColor(hexString: kSubTitleColors)
        titleLab.font = UIFont.systemFont(ofSize: 13)
        return titleLab
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTextContentView() {
        bgView.addSubview(textContentLab)
        textContentLab.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.left.equalTo(headerView)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func addImageContentView() {
        bgView.addSubview(textContentImage)
        
        bgView.snp.updateConstraints { (make) in
            make.height.equalTo(cellNormalHeight+40)
        }
        
        textContentImage.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.left.equalTo(headerView)
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(84)
        }
    }
    
    func addLocationContentView() {
        bgView.addSubview(locationBg)
        locationBg.addSubview(locationIcon)
        locationBg.addSubview(locationTitleLab)
        locationBg.addSubview(locationSubTitleLab)
        
        locationBg.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.left.equalTo(headerView)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        locationIcon.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(44)
        }
        
        locationTitleLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(locationIcon.snp.right).offset(10)
            make.right.equalToSuperview()
            make.height.equalTo(22)
        }
        
        locationSubTitleLab.snp.makeConstraints { (make) in
            make.top.equalTo(locationTitleLab.snp.bottom)
            make.left.equalTo(locationIcon.snp.right).offset(10)
            make.right.equalToSuperview()
            make.height.equalTo(22)
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    override func didTransition(to state: UITableViewCell.StateMask) {
//        super.didTransition(to: state)
//
//        let dict = ["转发":"collect_transmit_img","删除":"collect_delete_img"]
//        if state == UITableViewCell.StateMask.showingDeleteConfirmation {
//            for view in self.subviews{
//                if NSStringFromClass(view.classForCoder) == "UIView"{
//                    view.backgroundColor = UIColor.clear
//                    for actionBtn in view.subviews{
//                        if NSStringFromClass(actionBtn.classForCoder) == "_UITableViewCellActionButton"{
//                            let btn = actionBtn as? UIButton
//                            let title = btn?.titleLabel?.text
//                            btn?.setTitle("", for: UIControl.State.normal)
//                            btn?.setImage(UIImage.init(named: dict[title!]!), for: UIControl.State.normal)
//                        }
//                    }
//                }
//            }
//        }
//    }

    
    
}
