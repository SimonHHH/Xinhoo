//
//  CODGroupMemberTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/5/17.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupMemberTableViewCell: UITableViewCell {

    
    @IBOutlet weak var headImageView: UIImageView!
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
