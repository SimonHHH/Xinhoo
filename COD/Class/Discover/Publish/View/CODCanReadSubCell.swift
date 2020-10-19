//
//  CODCanReadSubCell.swift
//  COD
//
//  Created by XinHoo on 5/22/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CODCanReadSubCell: UITableViewCell, CanReadCellDataSourcesType {
        
    let selectedViewHeight: CGFloat = 21.5
    
    let bottomLineLeft: CGFloat = 50.0

    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var selectedView: UIView!
    
    @IBOutlet weak var selectedImgView: UIImageView!
    
    @IBOutlet weak var subTitleLab: UILabel!
    
    @IBOutlet weak var bottomLineConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectedViewHeightConstrains: NSLayoutConstraint!
    
    
    func configCellVM(pageVM: CODCanReadViewModel, cellVM: CODCanReadCellModel, indexPath: IndexPath) {
        self.titleLab.text = cellVM.title
        
        self.setSelectedImgAndSubTitleColor(pageVM: pageVM)
        
        cellVM.rx.subTitle.bind(to: self.rx.setSubTitleBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        
        self.isLast(indexPath.row == pageVM.dataSource.value.count - 1)
    }
    
    func isLast(_ last :Bool) {
        if last {
            bottomLineConstraint.constant = CGFloat.zero
        }else{
            bottomLineConstraint.constant = bottomLineLeft
        }
    }
    
    func setSelectedImgAndSubTitleColor(pageVM: CODCanReadViewModel) {
        var imageName = ""
        var textColor = UIColor(hexString: kSubmitBtnBgColorS)
        switch pageVM.readType {
        case .partialCanRead:
            imageName = "can_read_blue_select"
            textColor = UIColor(hexString: kSubmitBtnBgColorS)
        case .partialNotRead:
            
            imageName = "can_read_select"
            textColor = UIColor(hexString: kRedTextForLimitColorS)
        default:
            break
        }
        self.selectedImgView.image = UIImage.init(named: imageName)
        self.subTitleLab.textColor = textColor
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

extension Reactive where Base: CODCanReadSubCell {
    var setSubTitleBinder: Binder<String?> {
        return Binder(base) { (view, text) in
            if let subTitle = text {
                view.subTitleLab.text = subTitle
                view.selectedViewHeightConstrains.constant = view.selectedViewHeight
            }else{
                view.selectedViewHeightConstrains.constant = CGFloat.zero
            }
        }
    }
}
