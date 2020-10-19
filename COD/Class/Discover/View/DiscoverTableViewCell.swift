//
//  DiscoverTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2020/5/8.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DiscoverTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var redPointView: UIView!
    @IBOutlet weak var viewerCountLab: UILabel!
    
    @IBOutlet weak var promptView: UIImageView!
    
    @IBOutlet weak var countWidthLayoutConstraint: NSLayoutConstraint!
    
    var type: DiscoverCellModel.DiscoverCellType = .normal {
        didSet{
            viewerCountLab.isHidden = self.type == .normal
            headImageView.isHidden = self.type == .normal
            redPointView.isHidden = self.type == .normal
        }
    }
    
    var reviewCount = 0 {
        didSet{
            if self.reviewCount <= 0 {
                viewerCountLab.isHidden = true
            }else{
                viewerCountLab.isHidden = false
                viewerCountLab.text = "\(self.reviewCount)"
                
                let rect = viewerCountLab.text!.getLabelStringSize(font: UIFont.systemFont(ofSize: 12.0), lineSpacing: 0, fixedWidth: KScreenWidth)
                if rect.width > 18.0 {
                    countWidthLayoutConstraint.constant = rect.width+9.0
                }else{
                    countWidthLayoutConstraint.constant = 18.0
                }
            }
        }
    }
    
    func setContactPicOrShowPromptIcon(contactPic: String?, showPromptIcon: Bool = false) {
        if showPromptIcon {
            self.promptView.isHidden = false
            
            self.headImageView.isHidden = true
            self.redPointView.isHidden = true
        }else{
            self.promptView.isHidden = true
            if let pic = contactPic, let url = URL(string: pic)  {
                self.headImageView.isHidden = false
                self.redPointView.isHidden = false
                _ = self.headImageView.cod_loadHeader(url: url)
            }else{
                self.headImageView.isHidden = true
                self.redPointView.isHidden = true
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
