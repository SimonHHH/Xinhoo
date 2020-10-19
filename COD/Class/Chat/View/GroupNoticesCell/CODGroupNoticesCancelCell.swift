//
//  CODGroupNoticesCancelCell.swift
//  COD
//
//  Created by 黄玺 on 2020/2/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODGroupNoticesCancelCell: UITableViewCell {
    
    var cancelStr: String! = "知道了" {
        didSet {
            cancelLab.text = self.cancelStr
        }
    }
    

    @IBOutlet weak var cancelLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
