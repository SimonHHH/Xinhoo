//
//  CODCallViewController.swift
//  COD
//
//  Created by xinhooo on 2019/8/13.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CallModel: NSObject {
    var count = 1
    var lastTime = 0
    var model:CODMessageModel?{
        didSet{
            lastTime = model?.datetimeInt ?? 0
            modelIDList.add("\(model?.msgID ?? "")")
        }
    }
    var modelIDList:NSMutableArray = NSMutableArray.init()
}

class CODCallViewController: BaseViewController {

    @IBOutlet weak var listView: UITableView!
    
    var dataSource:NSMutableArray = NSMutableArray.init()
    
    enum ViewType {
        case normal
        case missedCall
    }
    
    var type:ViewType = .normal
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(initData), name: NSNotification.Name.init(kReloadCallVC), object: nil)
        
        self.setRightButton()
        self.rightButton.setImage(UIImage(named: "call_newcall_icon"), for: UIControl.State.normal)
        
        self.backButton.setTitle(NSLocalizedString("编辑", comment: ""), for: .normal)
        self.backButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
        self.backButton.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: .normal)
        self.backButton.setImage(nil, for: .normal)
        self.setBackButton()
        
        self.listView.emptyDataSetSource = self
        
        self.initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tab = UIApplication.shared.delegate?.window??.rootViewController as? CODCustomTabbarViewController,tab.tabBar.isHidden  {
            tab.tabBar.isHidden = false
        }
    }
    
    override func navBackClick() {
        self.listView.setEditing(!self.listView.isEditing, animated: true)
        self.backButton.setTitle(self.listView.isEditing ? NSLocalizedString("完成", comment: "") : NSLocalizedString("编辑", comment: ""), for: .normal)
    }
    
    override func navRightClick() {
        
        let vc = ContactsViewController()
        vc.type = .newCall
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func initData() {
        do{
            var msgModel:CODMessageModel?
            dataSource.removeAllObjects()
            
            var results:Results<CODMessageModel>
            if self.type == .normal {
                results = try Realm.init().objects(CODMessageModel.self).filter("(msgType = 5 || msgType = 13) && isDelete = false").sorted(byKeyPath: "datetime", ascending: true)
            }else{
                results = try Realm.init().objects(CODMessageModel.self).filter("(msgType = 5 || msgType = 13) && (text CONTAINS 'cancel' || text CONTAINS 'busy' || text CONTAINS 'calltimeout' || text CONTAINS 'connectfailed') && !(fromWho CONTAINS %@) && (isDelete = false)",UserManager.sharedInstance.loginName!).sorted(byKeyPath: "datetime", ascending: true)
            }
            
            for message in results {
                
                if msgModel == nil {
                    let callModel = CallModel.init()
                    callModel.model = message
                    dataSource.insert(callModel, at: 0)
                    msgModel = message
                }else{
                    /* 如果是在十分钟内，相同的来电or相同的外拨，则归类到一条callmodel里面，callmodel的count加1 */
//                    CustomUtil.getTimeDiff(starTime: msgModel!.datetime as NSString, endTime: message.datetime as NSString) >= 600
                    /* 如果是在同一天内，相同的来电or相同的外拨，则归类到一条callmodel里面，callmodel的count加1 */
//                    CustomUtil.isSameDay(starTime: msgModel!.datetime as NSString, endTime: message.datetime as NSString)
                    if !CustomUtil.isSameDay(starTime: msgModel!.datetime as NSString, endTime: message.datetime as NSString) {
                        
                        let callModel = CallModel.init()
                        callModel.model = message
                        dataSource.insert(callModel, at: 0)
                        msgModel = message
                        
                    }else{
                        //判断当前语音通话跟上一个语音通话是不是同一个人
                        if message.msgType == msgModel?.msgType && message.fromJID == msgModel?.fromJID && message.toJID == msgModel?.toJID {
                            
                            //判断当前语音通话跟上一个语音通话是不是属于同一种类型（总共两种类型：1.来电 2.未接来电）
                            if CustomUtil.validate(model: message, otherModel: msgModel!){
                                let callModel = dataSource.firstObject as! CallModel
                                callModel.count += 1
                                callModel.model = message
                                
                            }else{
                                let callModel = CallModel.init()
                                callModel.model = message
                                dataSource.insert(callModel, at: 0)
                                msgModel = message
                            }
                            
                        }else{
                            let callModel = CallModel.init()
                            callModel.model = message
                            dataSource.insert(callModel, at: 0)
                            msgModel = message
                        }
                    }
                }
            }
            
        }catch{
            
        }
        
        self.backButton.isHidden = self.dataSource.count == 0
        
        self.listView.reloadSections(NSIndexSet.init(index: 0) as IndexSet, with: .fade)
        self.listView.reloadEmptyDataSet()
    }
    
    @IBAction func segementAction(_ sender: Any) {
        
        let segment = sender as! UISegmentedControl
        switch segment.selectedSegmentIndex {
        case 0:
            self.type = .normal
            break
        case 1:
            self.type = .missedCall
            break
        default:
            break
        }
        self.initData()
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

extension CODCallViewController : UITableViewDelegate,UITableViewDataSource,EmptyDataSetSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let callModel = dataSource[indexPath.row] as! CallModel
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CODCallCell", for: indexPath) as! CODCallCell
        cell.configCallModel(callModel: callModel)
        if indexPath.row == 0 {
            cell.isTop = true
        }else{
            cell.isTop = false
        }
        if dataSource.count-1 == indexPath.row {
            cell.isLast = nil
        }else{
            cell.isLast = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let callModel = dataSource[indexPath.row] as! CallModel
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.callObserver.calls.first != nil {
            let alert = UIAlertController.init(title: "正在通话", message: String.init(format: NSLocalizedString("您不能在电话通话时同时使用 %@ 通话。", comment: ""), kApp_Name), preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        if delegate.manager?.status == .notReachable {
            
            let alert = UIAlertController.init(title: "无法呼叫", message: "请检查您的互联网连接并重试。", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if UserDefaults.standard.bool(forKey: kIsVideoCall) {
            CODProgressHUD.showWarningWithStatus("当前无法发起语音通话")
            return
        }
        
        var dict:NSDictionary = [:]
        
        let toJid = callModel.model?.fromJID == UserManager.sharedInstance.jid ? callModel.model?.toJID : callModel.model?.fromJID
        dict = ["name":COD_request,
                "requester":UserManager.sharedInstance.jid,
                "memberList":[toJid],
                "chatType":"1",
                "roomID":"0",
                "msgType":callModel.model?.msgType == EMMessageBodyType.voiceCall.rawValue ? COD_call_type_voice : COD_call_type_video]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let callModel = dataSource[indexPath.row] as! CallModel
            for str in callModel.modelIDList {
                let msgID = str as! String
                do{
                    let realm = try Realm.init()
                    if let message = realm.object(ofType: CODMessageModel.self, forPrimaryKey: msgID) {
                    
                        try realm.write {
                            message.isDelete = true
                        }
                    }
                    
                }catch{
                    
                }
            }
            dataSource.removeObject(at: indexPath.row)
            
            if self.dataSource.count == 0 {
                self.listView.setEditing(false, animated: true)
                self.backButton.setTitle("编辑", for: .normal)
                self.backButton.isHidden = true
            }
            
            self.listView.deleteRows(at: [indexPath], with: .fade)
            if dataSource.count > 0 {
                self.listView.reloadSections(NSIndexSet.init(index: indexPath.section) as IndexSet, with: .fade)
            }
            
            self.listView.reloadEmptyDataSet()
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
        }
        
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        if self.type == .normal {
            return NSAttributedString.init(string: NSLocalizedString("您最近的通话将在此显示", comment: ""), attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.init(hexString: kEmptyTitleColorS)!])
        }else{
            return NSAttributedString.init(string: NSLocalizedString("您没有未接电话", comment: ""), attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.init(hexString: kEmptyTitleColorS)!])
        }
    }
}
