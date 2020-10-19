//
//  CODSelectViewNornalCell.swift
//  COD
//
//  Created by XinHoo on 9/4/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODSelectViewNornalCell: UICollectionViewCell {

    @IBOutlet weak var nameLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
    }
    
    public var memberText: String? {
        didSet {
            if let memberText = memberText {
                self.nameLab.text = memberText
            }
        }
    }

}
