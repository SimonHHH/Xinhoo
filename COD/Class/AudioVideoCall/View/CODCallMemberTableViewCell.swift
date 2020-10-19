//
//  CODCallMemberTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2020/9/9.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODCallMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var presenterLab: UILabel!
    @IBOutlet weak var micImabeView: UIImageView!
    @IBOutlet weak var centerCos: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configModel(member: CODGroupMemberModel?, isPresenter: Bool) {
        
        presenterLab.text = NSLocalizedString("发起者", comment: "")
        
        /// 有成员参数
        if let member = member {
            
            let _ = headImageView.cod_loadHeaderByCache(url: URL(string: member.userpic.getHeaderImageFullPath(imageType: 1)))
            headImageView.contentMode = .scaleAspectFill
            nameLab.text = member.getMemberNickName()
            
        } else {
            
            headImageView.image = UIImage(named: "multip_call_add")
            headImageView.contentMode = .center
            nameLab.text = NSLocalizedString("添加成员", comment: "")
            
        }
        
        /// 主持人
        if isPresenter {
            
            centerCos.constant = -7
            presenterLab.isHidden = false
            
        } else {
            centerCos.constant = 0
            presenterLab.isHidden = true
        }
        
        
    }
    
}
