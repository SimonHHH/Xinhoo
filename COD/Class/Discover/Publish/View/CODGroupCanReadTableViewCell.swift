//
//  CODGroupCanReadTableViewCell.swift
//  COD
//
//  Created by XinHoo on 5/18/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODGroupCanReadTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedView: UIImageView!
        
    @IBOutlet weak var titleLab: UILabel!
        
    @IBOutlet weak var imgBtn: UIButton!
    
    @IBOutlet weak var bottomLineLeftConstrains: NSLayoutConstraint!
    
    typealias ShowGroupMembersBlock = () -> Void
    var showMembersBlock: ShowGroupMembersBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func showGroupMembers(_ sender: Any) {
        if showMembersBlock != nil {
            showMembersBlock!()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
