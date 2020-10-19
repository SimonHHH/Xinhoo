//
//  DebugTools.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/3.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import DoraemonKit

struct DebugTools {
    
    static func setup() {
        
        
        
        DoraemonManager.shareInstance().addPlugin(withTitle: "日志平台", icon: "", desc: "", pluginName: CODBootLogPlugin.description(), atModule: "常用工具")
        
        #if XINHOO
        
        DoraemonManager.shareInstance().addPlugin(withTitle: "日志上传", icon: "", desc: "", pluginName: CODUploadLogPlugin.description(), atModule: "常用工具")
        
        #endif
        

        
    }
    
}
