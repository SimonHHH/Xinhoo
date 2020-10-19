//
//  CODCallCell.swift
//  COD
//
//  Created by xinhooo on 2019/8/13.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODCallCell: UITableViewCell {

    @IBOutlet weak var headImgView: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var statuImgView: UIImageView!
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var imgCallType: UIImageView!
    
    @IBOutlet weak var bottomLine: UIView!
    
    @IBOutlet weak var bottomLineLeftContains: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addSubview(topLine)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private lazy var topLine: UIView = {
        let linev = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: KScreenWidth, height: 0.5))
        linev.backgroundColor = UIColor(hexString: kSepLineColorS)
        linev.isHidden = true
        return linev
    }()
    
    var isLast: Bool? = false {
        didSet {
            if let isLast = isLast {
                bottomLine.isHidden = false
                if isLast {
                    bottomLineLeftContains.constant = 0.0
                }else{
                    bottomLineLeftContains.constant = 70.0
                }
            }else{
                bottomLine.isHidden = true
            }
        }
    }
    
    var isTop: Bool = false {
        didSet {
            if isTop {
                topLine.isHidden = false
            }else{
                topLine.isHidden = true
            }
        }
    }
    
    
    func configCallModel(callModel:CallModel) {
        
        self.nameLab.textColor = .black
        if let message = callModel.model {
            
            if message.fromWho.contains((UserManager.sharedInstance.loginName!)) {
                
                let contact = CODContactRealmTool.getContactByJID(by: message.toJID)
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: contact?.userpic ?? "") { (image) in
                    self.headImgView.image = image
                }
                if callModel.count > 1 {
                    self.nameLab.text = (contact?.getContactNick())! + " (\(callModel.count))"
                }else{
                    self.nameLab.text = contact?.getContactNick()
                }
                
                self.statuImgView.image = UIImage.init(named: "call_msg_successfully_r")
                
            }else{
                if let contact = CODContactRealmTool.getContactByJID(by: message.fromJID) {
                    CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: contact.userpic) { (image) in
                        self.headImgView.image = image
                    }
                    if callModel.count > 1 {
                        self.nameLab.text = (contact.getContactNick()) + " (\(callModel.count))"
                    }else{
                        self.nameLab.text = contact.getContactNick()
                    }
                    
                    if CustomUtil.validateMissedCall(model: message) {
                        
                        self.statuImgView.image = UIImage.init(named: "call_msg_failed_left")
                        self.nameLab.textColor = UIColor.init(hexString: "EB4D3D")
                    }else{
                        self.statuImgView.image = UIImage.init(named: "call_msg_successfully_left")
                    }
                }
                
                
            }
            
            self.timeLab.text = TimeTool.getTimeStringAutoShort2(Date.init(timeIntervalSince1970:TimeInterval((callModel.lastTime)/1000)), mustIncludeTime: false, theOffSetMS: UserManager.sharedInstance.timeStamp)
            self.imgCallType.image = (message.msgType == 5 ? UIImage.init(named: "voice_call_icon") : UIImage.init(named: "video_call_icon"))
        }
        
    }

}
