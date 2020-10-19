//
//  MyQRCodeCell.swift
//  COD
//
//  Created by XinHoo on 2019/2/21.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class MyQRCodeCell: UITableViewCell {
    
    typealias ShowMyQRCodeBlock = () -> Void
    var showMyQRCodeBlock :ShowMyQRCodeBlock?

    @IBOutlet weak var codeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func showCode(_ sender: Any) {
        if let block = self.showMyQRCodeBlock {
            block()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
