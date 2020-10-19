//
//  CODTakePhotoBottomView.swift
//  COD
//
//  Created by 1 on 2020/8/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODTakePhotoBottomView: UIView {
    
    /// 单聊是用户ID，群组是群ID
    @objc public var chatId: Int = 0
    @objc var isGroupChat: Bool = false
    @objc lazy var captionView: CODPictureCaptionView =  {
        
        let addV = CODPictureCaptionView.share
//        addV.createView(toolView: toolV)
        addV.delegate = self
        addV.isCamera = true
        addV.textDelegate = self
        return addV
    }()
    
    @objc lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setImage(self.getConfirmImage(), for: UIButton.State.normal)
//        button.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return button
    }()

    
    @objc lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancle_take_photo"), for: UIButton.State.normal)
//        button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        
        self.addSubviews([self.captionView,self.confirmButton,self.cancelButton])
        self.captionView.showCaptionView(showView: self)
        self.captionView.toolView = self.confirmButton

        self.confirmButton.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-0)
            make.bottom.equalTo(self).offset(-0)
            make.width.height.equalTo(50)
        }
        self.cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(-0)
            make.width.height.equalTo(50)
        }

        self.captionView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalToSuperview().offset(-50)
            make.height.greaterThanOrEqualTo(45)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getConfirmImage() -> UIImage? {
        
        #if MANGO
        let imageName = "confirm_take_photo_mango"
        #elseif PRO
        let imageName = "confirm_take_photo_fly"
        #else
        let imageName = "confirm_take_photo_im"
        #endif
        
        return UIImage.init(named: imageName)
    }
    
    @objc func initTextView() {
        
        self.captionView.textView.text = ""
        self.captionView.status = .CaptionViewStatusInit
    }
    
    @objc func getCaptionView() -> CODPictureCaptionView {
        return self.captionView
    }
}

extension CODTakePhotoBottomView:CODPictureCaptionViewDelegate{
    
    func chatBarChange(captionView: CODPictureCaptionView, fromStatus: CODPictureCaptionViewStatus, toStatus: CODPictureCaptionViewStatus) {

    }
    
    func changeTextViewHeight(captionView: CODPictureCaptionView, height: CGFloat) {
//        captionView.snp.updateConstraints { (make) in
//            make.height.equalTo(45)
//        }
    }

    func presentPictureCaptionViewGroupMember(captionView: CODPictureCaptionView) {
        if self.isGroupChat {
            
            if let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId){
                
                if groupModel.isICanCheckUserInfo() == false {
                    return
                }
                
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
                selectPersonView.location = captionView.textView.selectedRange.location
            
                selectPersonView.tag = 300
                self.superview?.addSubview(selectPersonView)
                selectPersonView.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.bottom.equalTo(captionView.snp.top)
                    make.height.greaterThanOrEqualTo(0)
                }
                captionView.selectPersonView = selectPersonView


            }
        }
    }
    
    func deleteAtString(captionView: CODPictureCaptionView) {
        if let selectPersonView = captionView.superview?.viewWithTag(300) {
            
            selectPersonView.removeFromSuperview()
        }
    }

}

extension CODTakePhotoBottomView:CODPictureCaptionTextViewDelegate{
    
    func pictureCaptionTextViewDidChangeEdit(captionView: CODPictureCaptionView) {
    }
    
    func pictureCaptionTextViewDidEndEdit(captionView: CODPictureCaptionView) {
    }
}

extension CODTakePhotoBottomView:CODSelectAtPersonViewDelegate{
    func selectAtPersonclickCell(model: CODGroupMemberModel, location: Int) {
//        let subStr = self.captionView.textView.text ?? ""
////        guard location <= subStr.count  else {
////            return
////        }
//        self.captionView.textView.text = subStr.subStringToIndex(location)

        let mutableAttStr = NSMutableAttributedString.init(attributedString: self.captionView.textView.attributedText ?? NSAttributedString.init(string: ""))
        if self.captionView.textView.text.count >= location {
            mutableAttStr.replaceCharacters(in: NSRange.init(location: location, length: (self.captionView.textView.text.count ) - location), with: NSAttributedString.init(string: ""))
        }
        let nameAttribute = NSAttributedString.init(string: "\(model.zzs_getMemberNickName())", attributes: [.font : IMChatTextFont,.foregroundColor : UIColor.init(hexString: "#1D49A7") as Any])
        
        mutableAttStr.insert(nameAttribute, at: location)
        mutableAttStr.insert(NSAttributedString.init(string: " ", attributes: [.font : IMChatTextFont,.foregroundColor: UIColor.white]), at: location + nameAttribute.length)
        
        let str = "\(model.zzs_getMemberNickName()) " as NSString
        
        let attachment = YYTextAttachment.init(content:nil)
        attachment.userInfo = ["jid":model.jid]
        
        mutableAttStr.yy_setTextAttachment(attachment, range: NSRange.init(location: location - 1, length: str.length))
        
        self.captionView.textView.attributedText = mutableAttStr
        
        self.captionView.textView.selectedRange = NSMakeRange(location+str.length, 0)
        self.captionView.memberNotificationArr.append(model)
        
    }
}

