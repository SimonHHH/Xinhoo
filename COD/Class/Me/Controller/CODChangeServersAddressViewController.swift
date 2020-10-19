//
//  CODChangeServersAddressViewController.swift
//  COD
//
//  Created by xinhooo on 2020/5/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftDate

class CODChangeServersAddressViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    var serverList: [ServerInfo] = []
    
    var currentServer: CODAppInfo.ServerClass?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = NSLocalizedString("连接设置", comment: "")
        
        self.setBackButton()
        
        self.tableView.register(UINib(nibName: "CODConnectionServersCell", bundle: Bundle.main), forCellReuseIdentifier: "CODConnectionServersCell")
        
        self.tableView.tableHeaderView = self.headView
        self.tableView.tableFooterView = UIView()
        
        currentServer = CODAppInfo.getCurrentServerClass()

        serverList = AutoSwitchIPManager.share.serverList
        AutoSwitchIPManager.share.starPing()
        
    }
    
    lazy var headView: UIView = {
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 55))
        bgView.backgroundColor = UIColor.clear
        let textLabel = UILabel.init(frame: CGRect(x: 20, y: 32.5, width: KScreenWidth-42, height: 17))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = UIColor(hexString: kSubTitleColors)
        textLabel.text = NSLocalizedString("连接服务器", comment: "")
        bgView.addSubview(textLabel)
        return bgView
    }()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let serverInfo = serverList[indexPath.row]
        
        let cell: CODConnectionServersCell = tableView.dequeueReusableCell(withIdentifier: "CODConnectionServersCell", for: indexPath) as! CODConnectionServersCell
        
        cell.isTop = indexPath.row == 0
        
        cell.isLast = (serverList.count-1 == indexPath.row)
        
        if currentServer?.imServer.address == serverInfo.host.imServer.address {
            cell.selectImgView.isHidden = false
        }else{
            cell.selectImgView.isHidden = true
        }
        
        cell.serverInfo = serverInfo
        
        serverInfo.timeMsRP.bind(to: cell.rx.pingBinder)
            .disposed(by: cell.rx.prepareForReuseBag)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let serverInfo = serverList[indexPath.row]
        
        currentServer = serverInfo.host
        
        AutoSwitchIPManager.share.updateServer(serverClass: serverInfo.host)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
