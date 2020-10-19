//
//  Xinhoo_BaseCellProtocol.swift
//  COD
//
//  Created by xinhooo on 2020/1/2.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol Xinhoo_BaseLeftCellProtocol: CODBaseChatCell {
    var headImageView: UIImageView! { get }
    var downloadToken: SDWebImageDownloadToken? { get set }
    var messageModel: CODMessageModel { get }
    
    func downloadHeadImage()
    func cancelDownloadHeadImage()
    
    func configRefreshHeadImage()
    
    
}

extension Reactive where Base: Xinhoo_BaseLeftCellProtocol {
    
    var refreshHeaderBinder: Binder<String> {
        
        return Binder(base) { (cell, value) in
            
            cell.downloadHeadImage()

        }
        
    }
    
    
    
}

extension Xinhoo_BaseLeftCellProtocol {
    
    func downloadHeadImage() {
        
        if self.messageModel.userPic.count <= 0 {
            
            var userJid = self.messageModel.fromJID
            
            if self.messageModel.isCloudDiskMessage {
                userJid = self.messageModel.fw
            }
            
            if userJid.contains("cod_60000000") {
                self.headImageView.image = UIImage(named: UIImage.getHelpIconName())
            } else {
                
                XMPPManager.shareXMPPManager.requestUserInfo(userJid: userJid, success: { [weak self] (model) in
                    
                    guard let `self` = self else { return }
                    
                    let users = model.dataJson?["users"]
                    
                    if let jid = users?["jid"].stringValue, let name = users?["name"].stringValue, let userpic = users?["userpic"].stringValue {
                        
                        DispatchQueue.realmWriteQueue.async {
                            CODPersonInfoModel.createModel(jid: jid, name: name, userpic: userpic).addToDB()
                        }
                        
                        
                        //// 反正重用后下载
                        var userJid = self.messageModel.fromJID
                        
                        if self.messageModel.isCloudDiskMessage {
                            userJid = self.messageModel.fw
                        }
                        
                        if userJid == jid {
                            self.downloadToken = self.headImageView.cod_loadHeaderByCache(url: URL(string: userpic.getHeaderImageFullPath(imageType: 1)))
                        }
                        

                    }

                }) {
                    
                }
                
            }
            
            
            
        } else {
            downloadToken = self.headImageView.cod_loadHeaderByCache(url: URL(string: self.messageModel.userPic.getHeaderImageFullPath(imageType: 1)))
        }
        
        
        
        
    }
    
    func cancelDownloadHeadImage() {
        downloadToken?.cancel()
    }
    
    func configRefreshHeadImage() {
        
//        NotificationCenter.default.rx.notification(Notification.Name(rawValue: kRefreshHeaderNoti))
//            .map { $0.userInfo?["userPic"] as? String }
//            .filterNil()
//            .filter{ [weak self] (value) -> Bool in
//                guard let `self` = self else { return false }
//                
//                if self.messageModel.isInvalidated { return false }
//                
//                return value == self.messageModel.userPic
//        }
//        .bind (to: self.rx.refreshHeaderBinder)
//        .disposed(by: self.rx.prepareForReuseBag)
        
    }
    
}

protocol Xinhoo_BaseCellProtocol: CODBaseChatCell {
    
    
    
}

protocol Xinhoo_TextCellProtocol:Xinhoo_BaseCellProtocol {
}



extension Xinhoo_TextCellProtocol {
    func clickAtAction(jidStr:String?,model:CODMessageModel) {
        
        guard let jid = jidStr else {
            return
        }
        
        self.pageVM?.cellTapAt(jidStr: jid, model: model, cell: self)
    }
    func getAttributeText() -> NSMutableAttributedString {
        
        var text = self.messageModel.text
        
        let modelType = self.messageModel.type
        
        if modelType == .text {
            text = self.messageModel.text
        }else if modelType == .image{ 
            text = self.messageModel.photoModel?.descriptionImage ?? ""
        }else if modelType == .video{
            text = self.messageModel.videoModel?.descriptionVideo ?? ""
        }else if modelType == .audio{
            text = self.messageModel.audioModel?.descriptionAudio ?? ""
        }else if modelType == .file{
            text = self.messageModel.fileModel?.descriptionFile ?? ""
        }
        
        let attText = self.messageModel.entities.toAttributeText(text: text, onClickTextLink: { [weak self] (url) in
            guard let `self` = self else { return }
            self.chatDelegate?.cellDidTapedLink(self, linkString: url)
            }, onClickMention: { [weak self] (username) in
                guard let `self` = self else { return }
//                if self.messageModel.isGroupChat {
                    self.clickAtAction(jidStr: username, model: self.messageModel)
                
//                }
        }) { [weak self] (phone) in
            guard let `self` = self else { return }
            self.chatDelegate?.cellDidTapedPhone(self, phoneString: phone)
            
        }
        
        if self.messageModel.entities.count <= 0 {
            
            //            let text = self.messageModel.text
            
            let pattern_url = kRegexURL
            let regex_url = try! NSRegularExpression(pattern: pattern_url, options: NSRegularExpression.Options(rawValue:0))
            let res_url = regex_url.matches(in: attText.string, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, (attText.length)))
            
            let pattern_phone = "(1[3-9])\\d{9}"
            let regex_phone = try! NSRegularExpression(pattern: pattern_phone, options: NSRegularExpression.Options(rawValue:0))
            let res_phone = regex_phone.matches(in: attText.string, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, (attText.length)))
            
            let textRange = NSRange(location: 0, length: attText.length)
            
            for range in res_url {
                
                if NSIntersectionRange(textRange, range.range).length != range.range.length {
                    continue
                }
                
                attText.yy_setTextHighlight(range.range, color: UIColor.init(hexString: "#1D49A7"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3), tapAction: { [weak self] (containerView, text, range, rect) in
                    guard let `self` = self else { return }
                    
                    if self.chatDelegate != nil{
                        let str:NSString = text.string as NSString
                        let targetStr = (str.substring(with: range) as String).removeHeadAndTailSpacePro
                        self.chatDelegate?.cellDidTapedLink(self, linkString: URL.init(string: targetStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
                    }
                })
                
            }
            
            for range in res_phone {
                
                for urlRange in res_url {
                    if range.range.intersection(urlRange.range) == nil{
                        
                        if NSIntersectionRange(textRange, range.range).length != range.range.length {
                            continue
                        }
                        
                        attText.yy_setTextHighlight(range.range, color: UIColor.init(hexString: "#1D49A7"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3)) { [weak self] (containerView, text, range, rect) in
                            
                            guard let `self` = self else { return }
                            
                            if self.chatDelegate != nil{
                                let str:NSString = text.string as NSString
                                let targetStr = str.substring(with: range) as String
                                self.chatDelegate?.cellDidTapedPhone(self, phoneString: targetStr)
                            }
                        }
                    }
                }
            }
            
            if self.messageModel.chatTypeEnum == .groupChat {
                for jid in self.messageModel.referTo {
                    
                    if jid == kAtAll {
                        let str = NSString.init(string: attText.string)
                        attText.yy_setTextHighlight(str.range(of: NSLocalizedString("all", comment: "") + " "), color: UIColor.init(hexString: "#1D49A7"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3)) { [weak self] (containerView, text, range, rect) in
                            
                            guard let `self` = self else { return }
                            self.clickAtAction(jidStr: jid,model: self.messageModel)
                        }
                        
                    }else{
                        let memberId = CODGroupMemberModel.getMemberId(roomId: self.messageModel.roomId, userName:jid)
                        let groupMemberModel = CODGroupMemberRealmTool.getMemberById(memberId)
                        let str = NSString.init(string: attText.string)
                        let nameStr = groupMemberModel?.zzs_getMemberNickName() ?? ""
                        attText.yy_setTextHighlight(str.range(of: nameStr + " "), color: UIColor.init(hexString: "#1D49A7"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3)) { [weak self] (containerView, text, range, rect) in
                            
                            guard let `self` = self else { return }
                            self.clickAtAction(jidStr: jid,model: self.messageModel)
                        }
                    }
                    
                    
                    
                }
            }
            
            
            
        }
        
        return attText
        
    }
}


protocol Xinhoo_RightCellProtocol: Xinhoo_BaseCellProtocol {
    var messageModel: CODMessageModel { get }
    var activityView: UIActivityIndicatorView! { get }
    var sendFailBtn_zzs: UIButton! { get }
    var backViewTrailingCos: NSLayoutConstraint! { get }
    
    var viewerImageView: UIImageView! { get }
    
    func messageStatus()
}

extension Xinhoo_RightCellProtocol {
    func messageStatus() {

        self.sendFailBtn_zzs.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        let messageStatus: CODMessageStatus = CODMessageStatus(rawValue: messageModel.status) ?? .Pending
        if messageStatus == .Pending {
            self.activityView.isHidden = false
            self.activityView.startAnimating()
            self.sendFailBtn_zzs.isHidden = true
            self.backViewTrailingCos.constant = 3
            self.viewerImageView.isHidden = true
        }else{
            ///是成功还是失败
            if messageStatus == .Succeed {///发送成功
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                self.sendFailBtn_zzs.isHidden = true
                self.backViewTrailingCos.constant = 3
                if self.messageModel.chatTypeEnum == .privateChat {
                    self.viewerImageView.isHidden = true
                }else{
                    
                    if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.messageModel.roomId) {
                        if groupModel.userdetail == true {
                            self.viewerImageView.isHidden = false
                        }else{
                            self.viewerImageView.isHidden = !(groupModel.isAdmin(jid: UserManager.sharedInstance.jid) || groupModel.isOwner(jid: UserManager.sharedInstance.jid))
                        }
                    }
                }
                
            }else if(messageStatus == .Failed){///发送失败
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                self.sendFailBtn_zzs.isHidden = false
                self.backViewTrailingCos.constant = 30
                self.viewerImageView.isHidden = true
            }else{
                self.activityView.isHidden = false
                self.activityView.startAnimating()
                self.sendFailBtn_zzs.isHidden = true
                self.backViewTrailingCos.constant = 3
                self.viewerImageView.isHidden = false
            }
        }
        
        self.viewerImageView.isHidden = true

        
    }
    
    func addOperation() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapViewerImageView(gestureRecognizer:)))
        self.viewerImageView.addGestureRecognizer(tap)
    }
    
}

extension Xinhoo_CardRightTableViewCell: Xinhoo_RightCellProtocol {
    
    
}


extension Xinhoo_ImageRightTableViewCell: Xinhoo_RightCellProtocol,Xinhoo_TextCellProtocol {}

extension Xinhoo_LocationRightTableViewCell: Xinhoo_RightCellProtocol {
    func messageStatus() {

        self.sendFailBtn_zzs.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        let messageStatus: CODMessageStatus = CODMessageStatus(rawValue: messageModel.status) ?? .Pending
        if messageStatus == .Pending {
            self.activityView.isHidden = false
            self.activityView.startAnimating()
            self.sendFailBtn_zzs.isHidden = true
            self.backViewTrailingCos.constant = 3
            self.viewerImageView.isHidden = true
        }else{
            ///是成功还是失败
            if messageStatus == .Succeed {///发送成功
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                self.sendFailBtn_zzs.isHidden = true
                self.backViewTrailingCos.constant = 3
                if self.messageModel.chatTypeEnum == .privateChat {
                    self.viewerImageView.isHidden = true
                }else{
                    
                    if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.messageModel.roomId) {
                        if groupModel.userdetail == true {
                            self.viewerImageView.isHidden = false
                        }else{
                            self.viewerImageView.isHidden = !(groupModel.isAdmin(jid: UserManager.sharedInstance.jid) || groupModel.isOwner(jid: UserManager.sharedInstance.jid))
                        }
                    }
                }
                
            }else if(messageStatus == .Failed){///发送失败
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                self.sendFailBtn_zzs.isHidden = false
                self.backViewTrailingCos.constant = 30
                self.viewerImageView.isHidden = true
            }else{
                self.activityView.isHidden = false
                self.activityView.startAnimating()
                self.sendFailBtn_zzs.isHidden = true
                self.backViewTrailingCos.constant = 3
                self.viewerImageView.isHidden = false
            }
        }
        
        self.viewerImageView.isHidden = true

        
    }
    
    func addOperation() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapViewerImageView(gestureRecognizer:)))
        self.viewerImageView.addGestureRecognizer(tap)
    }
    
}

extension CODZZS_AudioRightTableViewCell: Xinhoo_RightCellProtocol,Xinhoo_TextCellProtocol {}

extension CODZZS_TextRightTableViewCell: Xinhoo_RightCellProtocol,Xinhoo_TextCellProtocol {}


protocol Xinhoo_LeftCellProtocol:Xinhoo_BaseCellProtocol {
    var fwdImageView: UIImageView! { get }
}

extension Xinhoo_LeftCellProtocol {
    
    func fwdImageStatus() {
        
        let fwdImage = UIImage(named: "left_share_icon")
        let sendImage = UIImage(named: "chat_send_failure")
        
        let messageStatus: CODMessageStatus = CODMessageStatus(rawValue: messageModel.status) ?? .Pending
        if messageStatus == .Pending {
            self.fwdImageView.isHidden = true
            self.fwdImageView.image = fwdImage
        }else{
            ///是成功还是失败
            if messageStatus == .Succeed {///发送成功
                self.fwdImageView.isHidden = false
                self.fwdImageView.image = fwdImage
            }else if(messageStatus == .Failed){///发送失败
                self.fwdImageView.isHidden = false
                self.fwdImageView.image = sendImage
            }else{
                self.fwdImageView.isHidden = false
                self.fwdImageView.image = fwdImage
            }
        }
        
        self.fwdImageView.isHidden = (self.messageModel.chatTypeEnum != .channel)
    }
}

extension Xinhoo_CardLeftTableViewCell: Xinhoo_LeftCellProtocol {}

extension Xinhoo_ImageLeftTableViewCell: Xinhoo_LeftCellProtocol,Xinhoo_TextCellProtocol {}

extension Xinhoo_LocationLeftTableViewCell: Xinhoo_LeftCellProtocol {}

extension CODZZS_AudioLeftTableViewCell: Xinhoo_LeftCellProtocol,Xinhoo_TextCellProtocol {}

extension CODZZS_TextLeftTableViewCell: Xinhoo_LeftCellProtocol,Xinhoo_TextCellProtocol {}
