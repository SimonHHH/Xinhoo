//
//  CODCirclePublishTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2020/5/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODCirclePublishTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var subTitleLab: UILabel!
    
    
    func configView(cellInfo:CODCirclePublishVM.CellInfo) {
        
        imgView.image = UIImage(named: cellInfo.imgName)
        titleLab.text = cellInfo.title
        subTitleLab.text = cellInfo.subTitle
        
        titleLab.textColor = cellInfo.color
        subTitleLab.textColor = cellInfo.color
        
        
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
