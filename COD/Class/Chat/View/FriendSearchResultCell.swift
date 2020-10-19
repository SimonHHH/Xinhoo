//
//  FriendSearchResultCell.swift
//  COD
//
//  Created by XinHoo on 2019/2/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class FriendSearchResultCell: UITableViewCell {

    @IBOutlet weak var phoneSLab: UILabel!  //手机搜索type显示
    
    @IBOutlet weak var addBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func addTheFriend(_ sender: Any) {
        
        print("add friend")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
