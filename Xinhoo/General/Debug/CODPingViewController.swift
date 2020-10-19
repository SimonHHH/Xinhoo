//
//  CODPingViewController.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/3.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import DoraemonKit
import RxSwift
import RxCocoa
import SwiftDate
import PhoneNetSDK


//
//class CODPingViewController: DoraemonBaseViewController, UITableViewDataSource, GBPingDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        self.serverList.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCell(withClass: CODPingCell.self, for: indexPath)
//        
//        cell.titleLab.text = self.serverList[indexPath.row].serverName
//        cell.subTitleLab.text = self.serverList[indexPath.row].timeMs
//        
//        self.serverList[indexPath.row].timeMsRP.bind(to: cell.subTitleLab.rx.text)
//            .disposed(by: cell.rx.prepareForReuseBag)
//        
//        return cell
//        
//    }
//    
//    
//    
//    
//
//    @IBOutlet weak var tableView: UITableView!
//    
//    var serverList: [ServerInfo] = []
//    
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.dataSource = self
//        tableView.register(nibWithCellClass: CODPingCell.self)
//        
//        #if MANGO
//        
//        serverList = [
//            ServerInfo(serverName: "im.imangoim.com", host: "im.imangoim.com"),
//            ServerInfo(serverName: "SG01", host: "34.87.41.175"),
//            ServerInfo(serverName: "HK01", host: "34.92.229.109"),
//            ServerInfo(serverName: "HK02", host: "120.77.216.116"),
//            ServerInfo(serverName: "CN01", host: "120.77.216.116"),
//            ServerInfo(serverName: "PH01", host: "156.236.93.62"),
//        ]
//        
//        #elseif PRO
//        
//        serverList = [
//            ServerInfo(serverName: "im.flygram.im", host: "im.flygram.im"),
//            ServerInfo(serverName: "CN", host: "120.78.185.89"),
//            ServerInfo(serverName: "HK", host: "34.92.191.241"),
//            ServerInfo(serverName: "SG", host: "35.247.162.93"),
//        ]
//        
//        #else
//        
//        serverList = [
//            ServerInfo(serverName: "cod.xinhoo.com", host: "cod.xinhoo.com"),
//        ]
//                
//        #endif
//        
//    }
//    
//    @IBAction func onClickPing(_ sender: UIButton) {
//        startPinging()
//    }
//    
//    func startPinging() {
//        
////        for server in self.serverList {
////            
////            server.ping.delegate = self
////            
////            server.ping.setup { (success, _) in
////                if success {
////                    server.ping.startPinging()
////                }
////            }
////            
////        }
//        
//    }
//    
//    func stopPinging() {
//        
//        for server in self.serverList {
//            server.ping.stop()
//        }
//        
//    }
//    
//
//    
//    func ping(_ pinger: GBPing, didFailWithError error: Error) {
//        for var server in self.serverList{
//            
//            if server.ping != pinger {
//                continue
//            }
//
//            server.timeMs = "失败"
//            pinger.stop()
//                        
//        }
//    }
//    
//    func ping(_ pinger: GBPing, didTimeoutWith summary: GBPingSummary) {
//        for var server in self.serverList{
//            
//            if server.ping != pinger {
//                continue
//            }
//
//            server.timeMs = "超时"
//            pinger.stop()
//                        
//        }
//    }
//    
//    func ping(_ pinger: GBPing, didReceiveReplyWith summary: GBPingSummary) {
//        
//        for var server in self.serverList{
//            
//            if server.ping != pinger {
//                continue
//            }
//
//            if let sendData = summary.sendDate, let receiveDate = summary.receiveDate {
//                server.timeMs = "\((receiveDate.secondsSince(sendData) * 1000).rounded(numberOfDecimalPlaces: 3, rule: .up)) ms"
//            }
//            pinger.stop()
//                        
//        }
//        
//    }
//
//    
//    override func leftNavBackClick(_ clickView: Any!) {
//        
//        stopPinging()
//        super.leftNavBackClick(clickView)
//    }
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
