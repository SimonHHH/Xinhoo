//
//  CODSetTelTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/4/17.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

typealias endEditingBlock = (String) -> ()
class CODSetTelTableViewCell: UITableViewCell {

    var endEdit : endEditingBlock?
    @IBOutlet weak var phoneTF: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension CODSetTelTableViewCell:UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (self.endEdit != nil) {
            self.endEdit?(textField.text!)
        }
        
    }
}
