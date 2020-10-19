//
//  CODGroupLinkTextCell.swift
//  COD
//
//  Created by XinHoo on 2020/4/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class CODGroupLinkTextCell: UITableViewCell, TableViewCellDataSourcesType {
    
    lazy var titleLab: UILabel = {
        let lab = UILabel.init(frame: CGRect.zero)
        lab.font = UIFont(name: "San Francisco Display", size: 17)
        return lab
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(-15.0)
            make.centerY.equalToSuperview()
        }
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCellVM(cellVM: TableViewCellVM, indexPath: IndexPath) {
        
        guard let cellVM = cellVM as? GroupLinkCellVM else {
            return
        }
        self.titleLab.textColor = UIColor.black
        
        cellVM.rx.title.bind(to: self.titleLab.rx.text)
            .disposed(by: self.rx.prepareForReuseBag)
        self.isUserInteractionEnabled = false
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


class CODGroupLinkOtherCell: CODGroupLinkTextCell {
    
    override func configCellVM(cellVM: TableViewCellVM, indexPath: IndexPath) {
        
        guard let cellVM = cellVM as? GroupLinkCellVM else {
            return
        }
        self.titleLab.textColor = UIColor(hexString: kTabItemSelectedColorS)
        cellVM.rx.title.bind(to: self.titleLab.rx.text)
            .disposed(by: self.rx.prepareForReuseBag)
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

