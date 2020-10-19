//
//  AutoSwitchIPManager.swift
//  COD
//
//  Created by xinhooo on 2020/7/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import PhoneNetSDK

class AutoSwitchIPManager: NSObject {
    
    static let share = AutoSwitchIPManager()
        
    var serverList: [ServerInfo] = []
    var pingGroup: DispatchGroup?
    
    var bestIP: CODAppInfo.ServerClass?
    var bestDelay: Int = 0
    
    var pingQueue = DispatchQueue(label: "ping")
    
    var isTimeOutWithCurrentIP: Bool = false
    
    var isChoosing = false
    
    override init() {
        super.init()
        self.updateServerList()
        
    }
    
    func updateServerList() {
        

        serverList.removeAll()
        for value in CODAppInfo.serverList {
            serverList.append(ServerInfo(serverName: value.teamName, host: value, pingEnd: false))
        }
        
        HttpManager.share.refreshManager()
                
    }
    
    func starPing() {
        
        bestIP = nil
        bestDelay = 0
        
        for index in 0 ..< self.serverList.count {
        
            var server = self.serverList[index]

//            pingGroup?.enter()
            
            let pingQueue = DispatchQueue(label: "tcp_ping")
            
            DispatchQueue.tcpPing.async {
                
            }
            
            pingQueue.async(group: pingGroup, qos: .default, flags: []) {
                
                let semp = DispatchSemaphore(value: 0)
                
                server.ping = PNTcpPing.start(server.host.imServer.host, port: UInt(server.host.imServer.port), count: 3, complete: { (value) in
                    
                    print(value)
                    
                }, complete2: { [weak self] (results) in
                    
                    semp.signal()
                    
                    guard let `self` = self else { return }
                    
                    if let result = results?.last {
                        
                        let timeMs = result.avg_time.int
                        
                        if result.ip == "127.0.0.1" || result.ip == "0.0.0.0" || result.avg_time < 1 {
                            server.timeMs = NSLocalizedString("超时", comment: "")
                            self.isTimeOut(host: server.host)
                        } else {
                            server.timeMs = timeMs.string
                            

                            if self.bestDelay == 0 || timeMs < self.bestDelay {
                                self.bestDelay = timeMs
                                self.bestIP = server.host
                            }
                            
                        }
                        
                        
                        
                    } else {
                        
                        server.timeMs = NSLocalizedString("超时", comment: "")
                        self.isTimeOut(host: server.host)
                        
                    }
                    
                    print("server: \(server.serverName) -- \(server.timeMs ?? "")ms")

                    
                })
                
                semp.wait()

                
            }
            
            
            

        }
        
    }
    
    func isValidHost(host: String) -> Bool {
        
        if let url = URL(string: host), url.scheme != nil {
            return false
        }
        
        return true
        
    }
    
//    func pingResult(withUCPing ucPing: PhonePing!, pingResult pingRes: PPingResModel!, pingStatus status: PhoneNetPingStatus) {
//
//        if status != .didReceivePacket && status != .didTimeout {
//            return
//        }
//
//        for var server in serverList {
//
//            if server.ping == ucPing {
//
//                if status == .didTimeout || pingRes.ipAddress == "127.0.0.1" || pingRes.ipAddress == "0.0.0.0" || pingRes.timeMilliseconds < 1 {
//                    server.timeMs = NSLocalizedString("超时", comment: "")
//                    self.isTimeOut(host: server.host)
//                    server.ping.stop()
//                    pingGroup?.leave()
//                    print("server: \(server.serverName) -- 超时")
//                    break
//                }
//
//                server.timeMs = pingRes.timeMilliseconds.int.string
//                print("server: \(server.serverName) -- \(pingRes.timeMilliseconds.int.string)ms")
//
//                if bestDelay == 0 || pingRes.timeMilliseconds.int < bestDelay {
//                    bestDelay = pingRes.timeMilliseconds.int
//                    bestIP = server.host
//                }
//
//                pingGroup?.leave()
//
//                break
//
//            }
//
//        }
//
//        ucPing.stop()
//
//    }
    
    func setBestIP(autoSwitch: Bool = true) {
       
        self.isTimeOutWithCurrentIP = false
        
        if self.isChoosing {
            return
        }
        
        self.isChoosing = true
        
        self.pingQueue.async {
            
            
            
            self.pingGroup = DispatchGroup()
            
            self.starPing()
            
            let result = self.pingGroup?.wait(timeout: .now() + .seconds(20))
            
            switch result {
                
            case .success,.timedOut:
                print("&&&&&&&&&& 最优IP:\(self.bestIP),延时:\(self.bestDelay)")
                self.isChoosing = false
                
                if self.bestIP == nil {
                    self.bestIP = CODAppInfo.serverList[0]
                }

                if autoSwitch || self.isTimeOutWithCurrentIP {
                    
                    if let bestIP = self.bestIP {
                        self.updateServer(serverClass: bestIP)
                    }

                }
                                
            case .none:
                break
            }
            
            self.pingGroup = nil
            

        }
        
        
        
        
    }
    
    func updateServer(serverClass: CODAppInfo.ServerClass) {
        
        UserDefaults.standard.set(serverClass.toJsonString(), forKey: kServersName)
        
//        WebBaseDomain = server
//        WebBaseDomain_circle = server
//        WebBaseDomain_circle_file = server
        
        XMPPHost = serverClass.imServer.address
        XMPPPort = serverClass.imServer.port
        

        WebServiveDomain = serverClass.apiServer.serverHttpsURL
        WebServiveDomain1 = serverClass.fileServer.serverHttpsURL
        WebServiveDomain2 = serverClass.restApiServer.serverHttpsURL
        WebServiveDomain3 = serverClass.momnetServer.serverHttpsURL
        
        // 切换xmpphost地址
        XMPPManager.shareXMPPManager.xmppStream.hostName = XMPPHost
        XMPPManager.shareXMPPManager.xmppStream.hostPort = UInt16(XMPPPort)
        // 重置xmpp重连计数
        XMPPManager.shareXMPPManager.reconnectCount = 0
        
        if XMPPManager.shareXMPPManager.xmppStream.isConnected || XMPPManager.shareXMPPManager.xmppStream.isConnecting  {
            
            // 断开xmpp链接，触发重连
            XMPPManager.shareXMPPManager.disconnect()
            XinhooTool.addLog(log:"【主动断开连接】切换服务器")
        }
        
        
    }
    
    
    
    func isTimeOut(host: CODAppInfo.ServerClass) {
        
        if let current = CODAppInfo.getCurrentServerClass() {
            
            if host.imServer.address == current.imServer.address {
                self.isTimeOutWithCurrentIP = true
            }
            
        }

    }
    
}
