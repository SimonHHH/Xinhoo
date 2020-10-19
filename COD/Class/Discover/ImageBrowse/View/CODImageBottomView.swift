//
//  CODImageBottomView.swift
//  COD
//
//  Created by 1 on 2020/5/22.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

@objc class CODImageBottomView: UIView {
    
    var messageModel = CODDiscoverMessageModel()


    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.addSubviews([self.titleView,self.likeView])

        
        self.likeView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(44 + kSafeArea_Bottom)
        }

        self.titleView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(likeView.snp.top)
            make.height.equalTo(120)
        }
        
    }
    
    @objc func isHiddenLikeView(isHidden: Bool) {
        if isHidden {
            self.likeView.snp.updateConstraints { (make) in
                make.height.equalTo(isHidden ? 0 : 44 + kSafeArea_Bottom)
            }
        }else{
            
//            let show = (self.messageModel.allowReviewAndLike && messageModel.msgPrivacyTypeEnum != .Private)
            
            self.likeView.snp.updateConstraints { (make) in
                make.height.equalTo(self.messageModel.allowReviewAndLike ? 44 + kSafeArea_Bottom : 0)
            }
            
        }

    }
    
    @objc func setMessageModel(messageModel:CODDiscoverMessageModel){
        self.messageModel = messageModel

        self.titleView.imageTitle = messageModel.text
        if messageModel.msgPrivacyTypeEnum == .Private && messageModel.senderJid == UserManager.sharedInstance.jid {
            self.titleView.circleStaute  = .Private
        }else{
            self.titleView.circleStaute  = .Open
        }
        if messageModel.text.count == 0 && self.titleView.circleStaute != .Private{
            self.titleView.isHidden = true
        }else{
            self.titleView.isHidden = false
        }
        self.likeView.setMessageMsgID(messageModel:messageModel)
        
        self.isHiddenLikeView(isHidden: false)
    }
    
    @objc func setMessagePrivacyType(msgID: String){
        
        if let messageModel = CustomUtil.getCircleMessage(msgID: msgID) {
            
            if messageModel.msgPrivacyTypeEnum == .Private {
                //设置为公开
                
            }else{
                //设置为私密
                
            }
        }
        
    }
    
    lazy var titleView: CODPicTitleDetailView = {
        let titleV = CODPicTitleDetailView()
        return titleV;
    }()
    
    lazy var likeView: CODLikeAndCommentView = {
        let likeV = CODLikeAndCommentView()
        return likeV;
    }()
}
