//
//  CODUserInfoHeaderCell.swift
//  COD
//
//  Created by XinHoo on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODUserInfoHeaderCell: UITableViewCell {
    
    @IBOutlet weak var topLine: UIView!
    
    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var headerImgView: UIImageView!
    
    var headerUrlStr :String? = nil {
        didSet{
            self.headerImgView.image = UIImage(named: "default_header_94")
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: UserManager.sharedInstance.avatar!) { [weak self] (image) in
                guard let self = self else {
                    return
                }
                self.headerImgView.image = image
            }
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
    
}
