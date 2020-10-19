//
//  CODCropImageFunctionView.swift
//  COD
//
//  Created by 1 on 2019/4/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODCropImageFunctionView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(cancelButton)
        self.addSubview(sureButton)
        self.addSubview(rotatingButton)
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconWH : CGFloat = 50.0
        let iconW = KScreenWidth/3
        
        let y: CGFloat = 0
        cancelButton.frame = CGRect.init(x: 0, y: y, width: iconW, height: iconWH)
        sureButton.frame = CGRect.init(x: iconW, y: y, width: iconW, height: iconWH)
        rotatingButton.frame = CGRect.init(x: iconW*2, y: y, width: iconW, height: iconWH)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var cancelButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle("取消", for:.normal)

        return button
    }()
    
    lazy var rotatingButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle("旋转", for:.normal)
        
        return button
    }()
    
    
    lazy var sureButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle("确定", for:.normal)

        return button
    }()
    
}
