//
//  CODCanReadListTVCell.swift
//  COD
//
//  Created by XinHoo on 6/8/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODCanReadListTVCell: UITableViewCell, TableViewCellDataSourcesType {

    @IBOutlet weak var headView: UIImageView!
    
    @IBOutlet weak var titleLab: UILabel!
    
    func configCellVM(cellVM: TableViewCellVM, indexPath: IndexPath) {
        if let cellVM = cellVM as? CODCanReadListCellVM {
            let url = URL(string: cellVM.model.userpic.getHeaderImageFullPath(imageType: 1))
            self.headView.sd_setImage(with: url, placeholderImage: UIImage(named: "default_header_80"), options: [])
            titleLab.text = cellVM.model.getContactNick()
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
