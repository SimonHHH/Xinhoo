//
//  MessageViewController+CODPictureCaptionViewDelegate.swift
//  COD
//
//  Created by 1 on 2020/8/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

extension MessageViewController:CODPictureCaptionViewDelegate{
    
    func chatBarChange(captionView: CODPictureCaptionView, fromStatus: CODPictureCaptionViewStatus, toStatus: CODPictureCaptionViewStatus) {
    }
    
    func changeTextViewHeight(captionView: CODPictureCaptionView, height: CGFloat) {
    }

    func presentPictureCaptionViewGroupMember(captionView: CODPictureCaptionView) {
        if self.isGroupChat {
            
            if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId){
                
                if groupModel.isICanCheckUserInfo() == false {
                    return
                }
                if captionView.superview?.viewWithTag(300) == nil{
                    let selectPersonView = CODSelectAtPersonView()

                    let memberId = CODGroupMemberModel.getMemberId(roomId: self.chatId, userName: UserManager.sharedInstance.jid)
                    let member = CODGroupMemberRealmTool.getMemberById(memberId)
                    var isAdmin = false
                    if member!.userpower < 30 {
                        isAdmin = true
                    }else {
                        isAdmin = false
                    }
                    selectPersonView.chatId = groupModel.chatId
                    selectPersonView.isAdmin = isAdmin
                    selectPersonView.userpic = groupModel.grouppic
                    selectPersonView.memberArr = groupModel.member
                    selectPersonView.delegate = self
                    selectPersonView.tag = 300
                    
                    selectPersonView.location = captionView.textView.selectedRange.location
                    captionView.superview?.addSubview(selectPersonView)
                    captionView.superview?.bringSubviewToFront(selectPersonView)
                    selectPersonView.snp.makeConstraints { (make) in
                        make.left.right.equalToSuperview()
                        make.bottom.equalTo(captionView.snp.top)
                        make.height.greaterThanOrEqualTo(0)
                    }
                    
                    captionView.selectPersonView = selectPersonView
                    
                }else{
                    if let selectPersonView: CODSelectAtPersonView = captionView.superview?.viewWithTag(300) as? CODSelectAtPersonView {
                        
                        selectPersonView.location = captionView.textView.selectedRange.location
                        selectPersonView.setData()
                    }
                    
                    
                }
            }
        }
    }
    
    func deleteAtString(captionView: CODPictureCaptionView){
        
        if let selectPersonView = captionView.superview?.viewWithTag(300) {
            
            selectPersonView.removeFromSuperview()
        }
    }

}

extension MessageViewController:CODPictureCaptionTextViewDelegate{
    
    func pictureCaptionTextViewDidChangeEdit(captionView: CODPictureCaptionView) {

    }
    
    func pictureCaptionTextViewDidEndEdit(captionView: CODPictureCaptionView) {

    }
    
}

extension MessageViewController:CODSelectAtPersonViewDelegate{
    func selectAtPersonclickCell(model: CODGroupMemberModel, location: Int) {
        let originAttStr = self.captionView?.textView.attributedText ?? NSAttributedString.init(string: "")

        let mutableAttStr = NSMutableAttributedString.init(attributedString: originAttStr)
        if self.captionView?.textView.text.count ?? 0 >= location {
            mutableAttStr.replaceCharacters(in: NSRange.init(location: location, length: (self.captionView?.textView.text.count ?? 0) - location), with: NSAttributedString.init(string: ""))
        }
        let nameAttribute = NSAttributedString.init(string: "\(model.zzs_getMemberNickName())", attributes: [.font : IMChatTextFont,.foregroundColor : UIColor.init(hexString: "#1D49A7") as Any])
        mutableAttStr.insert(nameAttribute, at: location)
        mutableAttStr.insert(NSAttributedString.init(string: " ", attributes: [.font : IMChatTextFont,.foregroundColor: UIColor.white]), at: location + nameAttribute.length)

        let str = "\(model.zzs_getMemberNickName()) " as NSString
        
        let attachment = YYTextAttachment.init(content:nil)
        attachment.userInfo = ["jid":model.jid]
        
        mutableAttStr.yy_setTextAttachment(attachment, range: NSRange.init(location: location - 1, length: str.length))
        
        self.captionView?.textView.attributedText = mutableAttStr
        
        self.captionView?.textView.selectedRange = NSMakeRange(location+str.length, 0)
        self.captionView?.memberNotificationArr.append(model)
        self.captionView?.textView.becomeFirstResponder()
        
    }
}
