//
//  CODSetGroupAvatarTableViewCell.swift
//  COD
//
//  Created by XinHoo on 2019/8/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSetGroupAvatarTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var bottomLine: UIView!
    
    var titleStr: String? {
        didSet {
            titleLab.text = titleStr
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
