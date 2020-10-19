//
//  CODGroupNoticesTitleCell.swift
//  COD
//
//  Created by 黄玺 on 2020/2/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODGroupNoticesTitleCell: UITableViewCell {
    
    var titleStr: String! {
        didSet {
            titleLab.text = self.titleStr
        }
    }

    @IBOutlet weak var titleLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
