//
//  CODChangeFontSlider.swift
//  COD
//
//  Created by xinhooo on 2019/4/13.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODChangeFontSlider: UISlider {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        
        return CGRect.init(x: 0.5, y: bounds.height/2-0.5, width: bounds.width-1, height: 1)
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {

        return CGRect.init(x: bounds.width*(CGFloat(value)/4)-15, y: 0, width: 30, height: 30)
    }
}
