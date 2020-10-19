//
//  CODUserInfoCell.swift
//  COD
//
//  Created by XinHoo on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODUserInfoCell: UITableViewCell {

    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var subTitleLab: UILabel!
    
    @IBOutlet weak var qrCodeView: UIImageView!
    
    @IBOutlet weak var arrowBtn: UIButton!
    
    @IBOutlet weak var bottomLine: UIView!
    open var isQRcode: Bool? {
        didSet {
            if let isQRcode = isQRcode {
                subTitleLab.isHidden = isQRcode
                qrCodeView.isHidden = !isQRcode
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
