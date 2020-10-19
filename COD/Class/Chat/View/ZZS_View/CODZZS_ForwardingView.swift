//
//  CODZZS_ForwardingView.swift
//  COD
//
//  Created by xinhooo on 2019/8/2.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import LGAlertView
class CODZZS_ForwardingView: UIView {

    @IBOutlet weak var fwNameLab: YYLabel!
    @IBOutlet weak var descLab: YYLabel!
    
    var jid = ""
    var msgModel:CODMessageModel? = nil
    override func awakeFromNib() {
        
        fwNameLab.lineBreakMode = .byTruncatingTail
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(pushPersonInfoVC))
        self.addGestureRecognizer(tap)
        
        super.awakeFromNib()
    }
    
    func configModel(model:CODMessageModel) {
        
        self.fwNameLab.lineBreakMode = .byCharWrapping
        msgModel = model
        jid = model.fw
        
        let textColor = (model.fromWho.contains(UserManager.sharedInstance.loginName!) && model.chatTypeEnum != .channel) ? UIColor.init(hexString: "54A044") : UIColor.init(hexString: kBlueTitleColorS)
        
        var name = ""
        
        if model.fwf == "C" {
            name = model.fwn
        }else{
            if  model.fw.contains(UserManager.sharedInstance.loginName!) {
                name = UserManager.sharedInstance.nickname ?? ""
            }else{
                if let contact = CODContactRealmTool.getContactByJID(by: model.fw) ,contact.isValid == true{
                    
                    name = contact.getContactNick()
                }else{
                    if let personModel = CODPersonInfoModel.getPersonInfoModel(jid: model.fw) {
                        name = personModel.name
                    }else{
                        let person = CODPersonInfoModel.init()
                        person.jid = model.fw
                        person.name = model.fwn
                        try! Realm.init().write {
                            try! Realm.init().add(person, update: .all)
                        }
                        name = model.fwn
                    }
                }
            }
        }
        
        
        let from = NSLocalizedString("来自", comment: "")
        
        let mubAttStr = NSMutableAttributedString.init(string: from + name)
        mubAttStr.addAttributes([NSAttributedString.Key.font : UIFont.init(name: "PingFangSC-Regular", size: 14) as Any], range: NSRange.init(location: 0, length: ((from + name) as NSString).length))
        mubAttStr.addAttributes([NSAttributedString.Key.font : UIFont.init(name: "PingFang-SC-Medium", size: 14) as Any], range: NSRange.init(location: (from as NSString).length, length: (name as NSString).length))

        self.fwNameLab.attributedText = mubAttStr
        
        self.fwNameLab.textColor = textColor
        self.descLab.textColor = textColor
        self.descLab.text = NSLocalizedString("转发的消息", comment: "")
    }
    
    func clear() {
        self.fwNameLab.text = ""
        self.descLab.text = ""
    }
    
    @objc func pushPersonInfoVC() {
        if jid == UserManager.sharedInstance.jid || jid == UserManager.sharedInstance.loginName{
            let msgCtl = MessageViewController()
            msgCtl.chatType = .privateChat
            msgCtl.toJID = kCloudJid + XMPPSuffix
            msgCtl.chatId = CloudDiskRosterID
            msgCtl.title = NSLocalizedString("我的云盘", comment: "")
            UIViewController.current()?.navigationController?.pushViewController(msgCtl, animated: true)
            return
        }
        
        if msgModel?.fwf == "C" {
            self.pushChannel()
        }else{
            if let contactModel = CODContactRealmTool.getContactByJID(by: jid), contactModel.isValid == true {
                CustomUtil.pushToPersonVC(contactModel: contactModel)
            }else{
                
                if let roomID = msgModel?.roomId,
                    let groupChat = CODChatListRealmTool.getChatList(id: roomID)?.groupChat,
                    groupChat.isICanCheckUserInfo() == false {
                    
                    CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
                    
                    return
                }
                
                CustomUtil.searchUserBID(jid: jid, pushToVCWithSourceType: .groupType)
                
//                XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
//                var dict:NSDictionary? = [:]
//                dict = ["name":COD_searchUserBID,
//                        "requester":UserManager.sharedInstance.jid,
//                        "search":[["content":jid]]]
//                
//                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_contacts, actionDic: dict!)
//                XMPPManager.shareXMPPManager.xmppStream.send(iq)
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func pushChannel() {
        
        if let msgModel = msgModel {
        
            CustomUtil.pushChannel(messageModel: msgModel)
        }
    }

}

extension CODZZS_ForwardingView : XMPPStreamDelegate {
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
        
        CustomUtil.analyticxXML(iq: iq) { (actionDic, infoDic) in
//            if (actionDic["name"] as? String == COD_searchUserBID){
//                if (infoDic!["success"] as! Bool) {
//
//                    if let usersDic = infoDic!["users"] as? NSDictionary {
//                        CustomUtil.pushToStrangerVCWith(json: JSON(usersDic), sourceType: .groupType)
//
//                    }
//                }
//            }
        }
        
        return true
    }
}
