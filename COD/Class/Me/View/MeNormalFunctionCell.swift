//
//  MeNormalFunctionCell.swift
//  COD
//
//  Created by XinHoo on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class MeNormalFunctionCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var subTitleLab: UILabel!
    
    @IBOutlet weak var topLine: UIView!
    
    @IBOutlet weak var bottomLineLeftContrains: NSLayoutConstraint!
    var isTop: Bool = false {
        didSet {
            if isTop {
                topLine.isHidden = false
            }else{
                topLine.isHidden = true
            }
        }
    }
    
    var isBottom: Bool = false {
        didSet {
            if isBottom {
                bottomLineLeftContrains.constant = 0.0
            }else{
                bottomLineLeftContrains.constant = 55.5
            }
        }
    }
    
    var subTitle: String? = nil {
        didSet{
            if let title = subTitle {
                subTitleLab.text = title
            }else{
                subTitleLab.text = ""
            }
        }
    }
    
    var subTitleAttri: NSAttributedString? = nil {
        didSet{
            if subTitleAttri != nil {
                subTitleLab.attributedText = subTitleAttri
            }else{
                subTitleLab.attributedText = nil
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
