//
//  CODCacheSetTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/6/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODCacheSetTableViewCell: UITableViewCell {

    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var sizeLab: UILabel!
    @IBOutlet weak var nameLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
