//
//  SearchBarCell.swift
//  COD
//
//  Created by XinHoo on 2019/2/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class SearchBarCell: UITableViewCell {

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.searchBar.backgroundImage = UIImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
