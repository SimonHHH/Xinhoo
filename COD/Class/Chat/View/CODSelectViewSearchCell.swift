//
//  CODSelectViewSearchCell.swift
//  COD
//
//  Created by XinHoo on 9/8/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODSelectViewSearchCell: UICollectionViewCell {
    
    
    weak var delegate :CODSelectViewSearchDelegate?
    
    @IBOutlet weak var textField: CODTextField!
    
    
    var ableToDeleteMember = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.deleteDelegate = self
        textField.addTarget(self, action: #selector(textFieldTextDidChange(field:)), for: UIControl.Event.editingChanged)
        
    }
    
    @objc func textFieldTextDidChange(field :UITextField) {
        
        if (delegate != nil) {
            ableToDeleteMember = false
            self.delegate!.searchTextDidEditChange(field: field)
        }
    }

}

extension CODSelectViewSearchCell : UITextFieldDelegate {
 
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if delegate != nil {
            return delegate!.searchFieldShouldBeginEditing(textField)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if delegate != nil {
            delegate?.searchFieldDidEndEditing(textField)
        }
    }

}

extension CODSelectViewSearchCell :CODTextFieldDelegate {
    func keyBoardDeleteBtnClick(field: UITextField) {
        if (field.text?.count)! <= 0 && ableToDeleteMember == false{
            ableToDeleteMember = true
        }else if (field.text?.count)! <= 0 && ableToDeleteMember == true {
            if delegate != nil {
                self.delegate!.deleteMember()
            }
        }
    }
    
}

protocol CODSelectViewSearchDelegate: class {
    func searchFieldShouldBeginEditing(_ field: UITextField) -> Bool
    func searchFieldDidEndEditing(_ field: UITextField)
    func searchTextDidEditChange(field: UITextField)
    func deleteMember()
}
