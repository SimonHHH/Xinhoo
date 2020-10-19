//
//  CODBootLogPlugin.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/3.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import DoraemonKit

class CODBootLogPlugin: NSObject, DoraemonPluginProtocol {
    
    func pluginDidLoad() {
        
        let vc = Xinhoo_LogsViewController(nibName: "Xinhoo_LogsViewController", bundle: Bundle.main)
        DoraemonHomeWindow.openPlugin(vc)
        

    }
    

}
