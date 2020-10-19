//
//  CODLittleAssistantDetailVC.swift
//  COD
//
//  Created by 1 on 2019/3/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODLittleAssistantDetailVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("详细资料", comment: "")
        self.setBackButton()
        self.setupUI()
        self.iconImageView.image = UIImage.helpIcon()
        let attriStr = NSMutableAttributedString.init(string: CustomUtil.formatterStringWithAppName(str: "%@小助手"))
        let textAttachment = NSTextAttachment.init()
        let img = UIImage(named: "cod_helper_sign_m")
        textAttachment.image = img
        textAttachment.bounds = CGRect.init(x: 0, y: 0, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
        let attributedString = NSAttributedString.init(attachment: textAttachment)
        attriStr.append(attributedString)
        self.nameLab.attributedText = attriStr
    }

    // MARK - 懒加载
    private lazy var iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 66/2
        imgView.layer.masksToBounds = true
        imgView.backgroundColor = UIColor.red
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
    
    private lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 16)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = NSTextAlignment.center
        titleLab.text = "功能介绍"
        return titleLab
    }()
    
    private lazy var subTitlePlaceholder: UILabel = {
        let placeholder = UILabel()
        placeholder.textAlignment = NSTextAlignment.left
        placeholder.font = UIFont.systemFont(ofSize: 12)
        placeholder.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        placeholder.text = "提供常见问题解决方案, 各类系统消息通知等。"
        placeholder.numberOfLines = 0
        placeholder.sizeToFit()
        return placeholder
    }()

    func setupUI() {
        
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor.white
        
        let topLine = UIView()
        topLine.backgroundColor = UIColor(hexString: kSepLineColorS)
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(hexString: kSepLineColorS)

        self.view.addSubviews([bgView,nameLab,iconImageView,titleLab,subTitlePlaceholder])
        bgView.addSubviews([topLine,bottomLine])
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(16)
            make.top.equalTo(self.view).offset(12)
            make.width.height.equalTo(66)
        }
        
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(14)
            make.centerY.equalTo(iconImageView)
            make.right.equalTo(self.view).offset(-16)
        }
                
        topLine.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self.view)
            make.height.equalTo(0.5)
        }

        bottomLine.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(bgView)
            make.height.equalTo(0.5)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalTo(iconImageView)
            make.top.equalTo(self.iconImageView.snp.bottom).offset(9.5)
            make.left.equalToSuperview()
            make.right.equalTo(iconImageView.snp.right).offset(14)
            make.height.equalTo(16.0)
        }
        
        subTitlePlaceholder.snp.makeConstraints { (make) in
            make.left.equalTo(nameLab.snp.left)
            make.centerY.equalTo(titleLab)
            make.right.equalTo(self.view).offset(-16)
        }
        
        bgView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self.view)
            make.bottom.equalTo(subTitlePlaceholder.snp.bottom).offset(16)
        }
    }
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
