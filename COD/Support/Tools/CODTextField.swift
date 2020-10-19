//
//  CODTextField.swift
//  COD
//
//  Created by XinHoo on 2019/3/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODTextField: UITextField {
    
    weak var deleteDelegate : CODTextFieldDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        /// 监听键盘删除键的触发
        if let delDelegate = deleteDelegate{
            delDelegate.keyBoardDeleteBtnClick(field: self)
        }
    }
    
}


protocol CODTextFieldDelegate: class {
    func keyBoardDeleteBtnClick(field :UITextField)
}
