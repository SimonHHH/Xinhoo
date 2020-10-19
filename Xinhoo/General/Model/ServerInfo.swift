//
//  ServerInfo.swift
//  COD
//
//  Created by Sim Tsai on 2020/9/1.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PhoneNetSDK


struct ServerInfo {
    
    let serverName: String
    let host: CODAppInfo.ServerClass
    var timeMs: String? = nil {
        didSet {
            self.timeMsRP.accept(timeMs)
        }
    }
    
    var ping = PNTcpPing()
    var pingEnd: Bool = false
    
    let timeMsRP: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    
    init(serverName: String, host: CODAppInfo.ServerClass, pingEnd: Bool = false) {
        self.serverName = serverName
        self.host = host
        ping.stop()
//        self.pingEnd = pingEnd
//
//        self.ping.host = host
//        self.ping.timeout = 1.0
//        self.ping.pingPeriod = 0.9
        
    }
    
}
