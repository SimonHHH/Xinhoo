//
//  CODGroupNameAndAvatarCell.swift
//  COD
//
//  Created by XinHoo on 2019/8/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupNameAndAvatarCell: UITableViewCell {
    
    typealias SelectAvatarCloser = () -> Void
    var selectAvatarCloser: SelectAvatarCloser?
    
    typealias GroupNameTextFieldDidEditChangeCloser = (_ textField: UITextField) -> Void
    var textFieldDidEditChangeCloser: GroupNameTextFieldDidEditChangeCloser?
    
    @IBOutlet weak var avatarImgBtn: UIButton!
    
    @IBOutlet weak var groupNameField: UITextField!
    
    var placeholder: String? {
        didSet {
            groupNameField.placeholder = placeholder
        }
    }
    
    @IBOutlet weak var editLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    
    @IBOutlet weak var bottomLineLeftConstrains: NSLayoutConstraint!
    
    @IBAction func selectAvatar(_ sender: Any) {
        print("selectAvatar")
        if selectAvatarCloser != nil {
            self.selectAvatarCloser!()
        }
    }
    
    var isEdit: Bool = false {
        didSet {
            if isEdit {
//                avatarImgBtn.isUserInteractionEnabled = true
                editLine.isHidden = false
                groupNameField.isEnabled = true
                groupNameField.font = UIFont.systemFont(ofSize: 20)
            } else {
//                avatarImgBtn.isUserInteractionEnabled = false
                editLine.isHidden = true
                groupNameField.isEnabled = false
                groupNameField.font = UIFont.boldSystemFont(ofSize: 20)
            }
        }
    }
    
    var isLast: Bool = false {
        didSet {
            if isLast {
                bottomLineLeftConstrains.constant = 0.0
            }else{
                bottomLineLeftConstrains.constant = 14.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        groupNameField.addTarget(self, action: #selector(groupNameTextFieldDidEditChange), for: UIControl.Event.editingChanged)
        
    }
    
    @objc func groupNameTextFieldDidEditChange(textField: UITextField) {
        if textFieldDidEditChangeCloser != nil {
            textFieldDidEditChangeCloser!(textField)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
