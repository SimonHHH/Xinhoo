//
//  CODLimitInputNumberTextField.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CODLimitInputNumberTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var limitInputNumber = 0
    
    let disposeBag = DisposeBag()
    

    func setInputNumber(number: Int) {
        
        self.limitInputNumber = number
        
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged);

    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if (self.limitInputNumber == 0) {
            return
        }
        
        if self.textInputMode?.primaryLanguage == "zh-Hans" {

            if let selectedRange = self.markedTextRange, let _ = self.position(from: selectedRange.start, offset: 0) {
                return
            }

        }

        if textField.text?.count ?? 0 > limitInputNumber {
            
            textField.text = textField.text?.slice(from: 0, length: limitInputNumber)
            
        }
        
    }
    

    
}


