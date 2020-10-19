//
//  StringEx.swift
//  COD
//
//  Created by XinHoo on 9/18/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

extension String {
    var isAlphaNumeric_Hx: Bool {
        let hasLetters = rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
        let hasNumbers = rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
        return hasLetters && hasNumbers
    }
}
