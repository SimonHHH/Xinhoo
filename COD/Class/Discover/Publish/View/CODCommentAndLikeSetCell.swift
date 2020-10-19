//
//  CODCommentAndLikeSetCell.swift
//  COD
//
//  Created by xinhooo on 2020/6/2.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODCommentAndLikeSetCell: UITableViewCell {

    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var descLab: UILabel!
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var divLeadingCos: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
