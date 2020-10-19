//
//  CODCallMemberViewController.swift
//  COD
//
//  Created by xinhooo on 2020/9/9.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class CODCallMemberViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    /// 参与人数
    @objc dynamic var memberList: Array<String> = []
    
    /// 已经加入人数
    @objc dynamic var joinMemberList: Array<String> = []
    
    /// 未加入人数
    var unJoinMemberList: Array<String> = []
    
    var groupModel:CODGroupChatModel?
    var presenterJid: String = ""
    
    var room = ""
    
    var isCanRequest: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.navigationController?.navigationBar.setTitleFont(UIFont.systemFont(ofSize: 17, weight: .medium), color: .white)
        
        self.navigationController?.navigationBar.tintColor = .white
        
        self.navigationController?.navigationBar.barStyle = .black
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.setBackButton()
        
        self.backButton.setTitleColor(.white, for: .normal)
        self.backButton.setImage(UIImage(named: "button_nav_back_white"), for: .normal)
        
        if let backColor = UIColor(hexString: "141E2A") {
            
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: backColor), for: .default)
            self.view.backgroundColor = backColor
        }
        
        tableView.register(UINib(nibName: "CODCallMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "CODCallMemberTableViewCell")
        tableView.tableFooterView = UIView()
        
        self.rx.observeWeakly(Array<String>.self, "memberList")
            .subscribe(onNext: { [weak self] (list) in
                
                self?.configView()
                
            })
            .disposed(by: self.rx.disposeBag)
        
        self.rx.observeWeakly(Array<String>.self, "joinMemberList")
            .subscribe(onNext: { [weak self] (list) in
                
                self?.configView()
                
            })
            .disposed(by: self.rx.disposeBag)
        
        self.configView()
    }

    func configView() {
        
        unJoinMemberList = memberList.filter({ !joinMemberList.contains($0) })
        
        self.navigationItem.title = "\(NSLocalizedString("成员", comment: "")) \(joinMemberList.count)/\(memberList.count)"
        self.tableView.reloadData()
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

extension CODCallMemberViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isCanRequest {
         
            return 3
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isCanRequest {
            if section == 0 {
                return 1
            }else if section == 1 {

                return joinMemberList.count
            }else if section == 2 {
                return unJoinMemberList.count
            }else{
                return 0
            }
        }else{
            if section == 0 {
                return joinMemberList.count
            }else if section == 1 {

                return unJoinMemberList.count
            }else{
                return 0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var member: CODGroupMemberModel? = nil
        var isPresenter = false
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CODCallMemberTableViewCell", for: indexPath) as! CODCallMemberTableViewCell
        
        cell.micImabeView.isHidden = true
        
        if indexPath.section == (isCanRequest ? 1 : 0) {
        
            if let m = groupModel?.getMember(jid: joinMemberList[indexPath.row]) {
                member = m
            }
            cell.micImabeView.isHidden = false
            
            let peer = CODWebRTCManager.shared().getPeerConnection(fromConnectedPeerDic: member?.jid ?? "")
            let peerState: Array<RTCPeerConnectionState> = [.connecting,.connected]
            if peerState.contains(peer.connectionState) {
                cell.micImabeView.image = UIImage(named: "multiple_voice_on")
            }else{
                cell.micImabeView.image = UIImage(named: "multiple_voice_disconnect")
            }
            
        }
        
        if indexPath.section == (isCanRequest ? 2 : 1) {
            
            if let m = groupModel?.getMember(jid: unJoinMemberList[indexPath.row]) {
                member = m
            }
        }
        
        if member?.jid == presenterJid {
            isPresenter = true
        }
        
        
        cell.configModel(member: member, isPresenter: isPresenter)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {

            let ctl = CreGroupChatViewController()
            ctl.ctlType = .requestmore_multipleVoice
            ctl.groupChatModel = groupModel
            ctl.roomID = groupModel?.roomID.string ?? ""
            ctl.selctMemberList = memberList
            ctl.maxSelectedCount = 9
            ctl.room = self.room
            self.navigationController?.pushViewController(ctl, animated: true)

        }
        
    }
    
    
}
