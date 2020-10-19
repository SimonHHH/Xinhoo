//
//  SelectServersView.swift
//  COD
//
//  Created by xinhooo on 2020/5/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftDate

class SelectServersView: UIView,CODPopupViewType,UITableViewDelegate,UITableViewDataSource {
    
    var serverList: [ServerInfo] = []
    
    var currentServer: CODAppInfo.ServerClass? {
        return CODAppInfo.getCurrentServerClass()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func comfirmAction(_ sender: Any) {
                    
        if let currentServer = currentServer {
            AutoSwitchIPManager.share.updateServer(serverClass: currentServer)
        }
        

        self.dismiss(animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.register(UINib(nibName: "SelectServersTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "SelectServersTableViewCell")
        
        serverList = AutoSwitchIPManager.share.serverList
        AutoSwitchIPManager.share.setBestIP(autoSwitch: false)
        
        UserDefaults.standard.rx.observe(String.self, kServersName).skip(1).bind { [weak self] (_) in
            
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            
            
        }
        .disposed(by: self.rx.disposeBag)
        

    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let serverInfo = serverList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectServersTableViewCell", for: indexPath) as! SelectServersTableViewCell
        
        if currentServer?.imServer.address == serverInfo.host.imServer.address {
            cell.selectImgView.image = UIImage(named: "person_selected")
        }else{
            cell.selectImgView.image = UIImage(named: "person_select")
        }
        
        cell.serverInfo = serverInfo
        
        serverInfo.timeMsRP.bind(to: cell.rx.pingBinder)
            .disposed(by: cell.rx.prepareForReuseBag)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let serverInfo = serverList[indexPath.row]
        AutoSwitchIPManager.share.updateServer(serverClass: serverInfo.host)
        tableView.reloadData()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
