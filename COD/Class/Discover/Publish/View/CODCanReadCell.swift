//
//  CODCanReadCell.swift
//  COD
//
//  Created by XinHoo on 5/22/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODCanReadCell: UITableViewCell, CanReadCellDataSourcesType {
    
    let bottomLineLeft: CGFloat = 16.0
    
    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var subTitleLab: UILabel!
    
    @IBOutlet weak var selectImgView: UIImageView!
    
    @IBOutlet weak var arrowImgView: UIImageView!
    
    @IBOutlet weak var bottomLineLeadingConstraint: NSLayoutConstraint!
    
    func configCellVM(pageVM: CODCanReadViewModel, cellVM: CODCanReadCellModel, indexPath: IndexPath) {
        self.titleLab.text = cellVM.title
        self.subTitleLab.text = cellVM.subTitle
        if let isSelect = cellVM.isSelected {
            selectImgView.isHidden = !isSelect
            if cellVM.readType == .partialNotRead {
                selectImgView.image = UIImage(named: "can_read_select")
            }else{
                selectImgView.image = UIImage(named: "can_read_blue_select")
            }
        }else{
            selectImgView.isHidden = true
        }
        if let arrowType = cellVM.arrowType {
            arrowImgView.isHidden = false
            if arrowType == .up {
                arrowImgView.image = UIImage(named: "arrow_up")
            }else{
                arrowImgView.image = UIImage(named: "arrow_down")
            }
        }else{
            arrowImgView.isHidden = true
        }
        self.isLast(indexPath.row == pageVM.dataSource.value.count - 1)
    }
    
    func isLast(_ last :Bool) {
        if last {
            bottomLineLeadingConstraint.constant = 0.0
        }else{
            bottomLineLeadingConstraint.constant = bottomLineLeft
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
