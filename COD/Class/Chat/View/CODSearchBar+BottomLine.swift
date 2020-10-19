//
//  CODSearchBar+BottomLine.swift
//  COD
//
//  Created by XinHoo on 7/6/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODSearchBar_BottomLine: CODSearchBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(hexString: kSepLineColorS)
        
        self.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
