//
//  MessageUIModel.swift
//  COD
//
//  Created by XinHoo on 2019/2/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

public enum MessageToolbarState: Int, CustomStringConvertible {
    
    case Default
    case BeginTextInput
    case TextInputing
    case VoiceRecord
    
    public var description: String {
        switch self {
        case .Default:
            return "Default"
        case .BeginTextInput:
            return "BeginTextInput"
        case .TextInputing:
            return "TextInputing"
        case .VoiceRecord:
            return "VoiceRecord"
        }
    }
    
    public var isAtBottom: Bool {
        switch self {
        case .Default:
            return true
        case .BeginTextInput, .TextInputing:
            return false
        case .VoiceRecord:
            return true
        }
    }
}

