//
//  MeHeaderCell.swift
//  COD
//
//  Created by XinHoo on 2019/3/5.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class MeHeaderCell: UITableViewCell {

    @IBOutlet weak var headView: UIImageView!
    
    @IBOutlet weak var userNameLab: UILabel!
    
    @IBOutlet weak var sexIconContrainsWidth: NSLayoutConstraint!
    
    @IBOutlet weak var sexToStatusGapContrains: NSLayoutConstraint!
    
    @IBOutlet weak var sexImgView: UIImageView!
    
    var sex: String = "" {
        didSet {
            sexIconContrainsWidth.constant = 16
            sexToStatusGapContrains.constant = 7.0
            if sex.count > 0 {
                
                if sex.compareNoCaseForString("男") {
                    sexImgView.image = UIImage(named: "man_icon")
                }else{
                    sexImgView.image = UIImage(named: "woman_icon")
                }
            }else{
                sexImgView.image = UIImage(named: "man_icon")
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sexIconContrainsWidth.constant = 0.0
    }
    
    @IBAction func clickMyQRCode(_ sender: Any) {
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
