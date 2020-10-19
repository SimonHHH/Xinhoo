//
//  CODEditRemarksVC.swift
//  COD
//
//  Created by 1 on 2019/11/13.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODEditRemarksVC: BaseViewController {
    
    var model:CODContactModel?
    typealias  block = () -> ()
    var callBack : block?

    lazy var headerView: UIImageView = {
        let headerV = UIImageView.init()
        headerV.contentMode = .scaleAspectFill
        headerV.layer.cornerRadius = 33.0
        headerV.clipsToBounds = true
        return headerV
    }()
    
    lazy var remarkTF: CODLimitInputNumberTextField = {
        let remarkT = CODLimitInputNumberTextField.init()
        remarkT.font = UIFont.systemFont(ofSize: 20)
        remarkT.placeholder = "请输入用户备注"
        remarkT.setInputNumber(number: 64)
        return remarkT
    }()
    
    lazy var line1: UIView = {
        let line = UIView.init()
        line.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        return line
    }()
    
    lazy var line2: UIView = {
        let line = UIView.init()
        line.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        return line
    }()
    
    lazy var line3: UIView = {
        let line = UIView.init()
        line.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        return line
    }()
    
    lazy var line4: UIView = {
        let line = UIView.init()
        line.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        return line
    }()

    lazy var line5: UIView = {
        let line = UIView.init()
        line.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        return line
    }()
    
    lazy var textView: YZInputView = {
        let textView : YZInputView = YZInputView.init(frame: .zero)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.init(hexString: kMainTitleColorS)
        textView.textContainerInset = UIEdgeInsets.init(top: 11.5, left: 15, bottom: 11.5, right: 15)
        textView.placeholder = NSLocalizedString("添加更多备注信息", comment: "")
        return textView
    }()
    
    lazy var desLabel: UILabel = {
        let desLb = UILabel.init()
        desLb.font = UIFont.systemFont(ofSize: 13)
        desLb.textColor = UIColor.init(hexString: "#BEBEBE")
        desLb.text = "描述"
        return desLb
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackButton()
        self.rightTextButton.setTitle("完成", for: .normal)
        self.rightTextButton.setTitleColor(UIColor.init(hexString: kBlueTitleColorS), for: .normal)
        self.setRightTextButton()
        self.navigationItem.title = NSLocalizedString("编辑备注", comment: "")
        self.setUpAddViews()
        
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model!.userpic) { (image) in
            self.headerView.image = image
        }

        self.textView.yz_textHeightChangeBlock = { [weak self] (text, textHeight) in
            self?.textView.snp.updateConstraints({ (make) in
                make.height.equalTo(textHeight)
            })
        }
        
        self.remarkTF.text = self.model?.nick
        self.textView.text = self.model?.descriptions
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)

    }
    
    func setUpAddViews() {
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor.white
        self.view.addSubview(bgView)
        
        self.view.addSubviews([bgView,desLabel,textView,line1,line2,line3,line4,line5])
        bgView.addSubviews([headerView,remarkTF])
        
        bgView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.height.equalTo(93)
        }
        
        headerView.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(15)
            make.top.equalTo(bgView).offset(10)
            make.height.width.equalTo(66)
        }
        
        remarkTF.snp.makeConstraints { (make) in
            make.left.equalTo(headerView.snp.right).offset(11)
            make.centerY.equalTo(headerView)
            make.height.equalTo(28)
            make.right.equalTo(bgView.snp.right).offset(-15)
        }
        
        line1.snp.makeConstraints { (make) in
            make.left.equalTo(remarkTF)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(remarkTF.snp.bottom).offset(5)
        }
        
        line2.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(bgView)
            make.height.equalTo(0.5)
        }
        
        desLabel.snp.makeConstraints { (make) in
            make.left.equalTo(14)
            make.top.equalTo(bgView.snp.bottom).offset(13)
            make.height.equalTo(18)
        }
        
        line3.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(desLabel.snp.bottom).offset(4)
        }
        
        textView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(43)
            make.top.equalTo(line3.snp.bottom)
        }
        
        line4.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(textView.snp.bottom)
        }
    }
    
    override func navRightTextClick() {
        guard CODWebRTCManager.whetherConnectedNetwork() else {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        guard var editText = self.remarkTF.text, var destription = self.textView.text else {
            return
        }
        editText = editText.removeHeadAndTailSpacePro
        destription = destription.removeHeadAndTailSpacePro
        
        let  dict:NSDictionary = ["name":COD_changeChat,
                                  "requester":UserManager.sharedInstance.jid,
                                  "itemID":self.model?.rosterID as Any,
                                  "setting":["nick":editText as Any,"description":destription as Any,"tels":[]]]
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
}
extension CODEditRemarksVC:XMPPStreamDelegate{
        
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { [weak self] (actionDic, infoDic) in
            guard let infoDic = infoDic, let `self` = self else {
                return
            }
            if (actionDic["name"] as? String == COD_changeChat){
                if !(infoDic["success"] as! Bool) {
                    CODProgressHUD.showErrorWithStatus("设置失败")
                    return
                }
                
                guard let setting = actionDic["setting"] as? Dictionary<String, Any> else {
                    return
                }
                
                if let model = self.model {
                    try! Realm.init().write {
                        
                        model.nick = setting["nick"] as? String ?? ""
                        model.descriptions = setting["description"] as? String ?? ""
                        model.pinYin = ChineseString.getPinyinBy(model.getContactNick())
                        
                    }
                    
                    CODChatListRealmTool.updateChatListTitleByChatId(chatId: model.rosterID, andTitle: model.getContactNick())
                    
                    if let members = CODGroupMemberRealmTool.getMembersByJid(model.jid) {
                        try! Realm.init().write {
                            for member in members {
                                member.pinYin = ChineseString.getPinyinBy(member.getMemberNickName())
                            }
                        }
                    }
                    
                    NotificationCenter.default.post(Notification(name: .init(kNotificationReloadAllMessgae)))

                }
                
                if self.callBack != nil{
                    self.callBack!()
                }
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        
        return true
    }
}
