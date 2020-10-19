//
//  MediaFileTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/8/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class MediaFileTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
