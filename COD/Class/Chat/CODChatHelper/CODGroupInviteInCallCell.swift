//
//  CODGroupInviteInCallCell.swift
//  COD
//
//  Created by 1 on 2020/9/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODGroupInviteInCallCell: UICollectionViewCell {
    lazy var groupIconView:UIImageView = {
        let groupIconView = UIImageView(frame: CGRect.zero)
        groupIconView.backgroundColor = UIColor.red
        groupIconView.layer.cornerRadius = 15
        groupIconView.contentMode = .scaleAspectFill
        groupIconView.contentMode = .center
        return groupIconView
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpSubviews(){
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.groupIconView)
    }
    fileprivate func setUpLayout(){
        self.groupIconView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
    }
}
