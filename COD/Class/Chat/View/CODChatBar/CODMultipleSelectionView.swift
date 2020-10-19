//
//  CODMultipleSelectionView.swift
//  COD
//
//  Created by 1 on 2019/12/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODMultipleSelectionView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView() {
        
        self.addSubviews([self.deleteBtn, shareBtn])
        self.deleteBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.height.equalTo(32)
            make.centerY.equalTo(self)
        }
        self.shareBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-12)
            make.height.equalTo(32)
            make.centerY.equalTo(self)
        }
    }
    
    public lazy var deleteBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "mult_delete"), for: .normal)
        btn.contentMode = .left
        btn.setTitleColor(UIColor.init(red: 7, green: 129, blue: 229), for: .normal)
        return btn;
    }()
    
    public lazy var shareBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "mult_forward"), for: .normal)
        btn.contentMode = .left
        btn.setTitleColor(UIColor.init(red: 7, green: 129, blue: 229), for: .normal)
        return btn;
    }()
}
