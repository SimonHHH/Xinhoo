//
//  CODKeyboardProtocol.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

@objc protocol CODKeyboardProtocol:NSObjectProtocol{
    /// 返回键盘的高度
    ///
    /// - Returns: 高度
    func keyboardHeight() -> CGFloat
    
    
}
