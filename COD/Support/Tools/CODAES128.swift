//
//  CODAES128.swift
//  COD
//
//  Created by Sim Tsai on 2020/9/22.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


enum CODAES128Key {
    case chatText
    case serverList
    case nickName
    case phoneNum
    
    var key: String {
        
        switch self {
        case .chatText:
            return "PAiQdP08utzssVQm"
        case .serverList:
            return "QbhBl9ecx850SkMa"
        case .nickName:
            return "PAiQdP08utzssVQm"
        case .phoneNum:
            return "PAiQdP08utzssVQm"
        }
        
    }
}

extension String {
    
    
    func aes128DecryptECB(key: CODAES128Key) -> String {
        
        switch key {
        case .nickName, .phoneNum:
            return self
        default:
            break
        }
        
        guard let str = AES128.aes128DecryptECB(self, aesKey: key.key) else {
            return self
        }
        
        if str.count <= 0 {
            return self
        }
        
        return str

    }
    
}
