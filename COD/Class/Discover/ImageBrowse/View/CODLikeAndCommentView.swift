//
//  CODLikeAndCommentView.swift
//  COD
//
//  Created by 1 on 2020/5/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

@objcMembers
@objc class CODLikeAndCommentView: UIView {
    
    var messageModel = CODDiscoverMessageModel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func setupView() {
        self.addSubviews([likeBtn,lineView,commetBtn,likeDetailBtn,commetDetailBtn])
        
        self.likeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(6)
            make.top.equalTo(self).offset(8)
            make.height.equalTo(30)
            make.width.lessThanOrEqualTo((KScreenWidth-30)/4)
        }
        
        self.lineView.snp.makeConstraints { (make) in
            make.left.equalTo(self.likeBtn.snp.right).offset(9)
            make.width.equalTo(0.5)
            make.height.equalTo(21.5)
            make.top.equalTo(self).offset(13)
        }
        
        self.commetBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.lineView.snp.right).offset(5)
            make.top.equalTo(self.likeBtn)
            make.height.equalTo(self.likeBtn)
            make.width.lessThanOrEqualTo((KScreenWidth-30)/4)
        }
        
        self.commetDetailBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-10)
            make.top.equalTo(self.likeBtn)
            make.height.equalTo(self.likeBtn)
            make.width.lessThanOrEqualTo((KScreenWidth-30)/4)
        }
        
        self.likeDetailBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.commetDetailBtn.snp.left).offset(2)
            make.top.equalTo(self.likeBtn)
            make.height.equalTo(self.likeBtn)
            make.width.lessThanOrEqualTo((KScreenWidth-30)/4)
        }
        
    }
    
    fileprivate lazy var likeBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "circle_image_like"), for: .normal)
        btn.CODButtonImageTitle(style: .left, titleImgSpace: 2)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle("赞", for: .normal)
        btn.setTitle("取消", for: .selected)
        btn.addTarget(self, action: #selector(likeAcion(btn:)), for: .touchUpInside)
        return btn;
    }()
    
    private lazy var lineView: UIView = {
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor(red: 0.33, green: 0.35, blue: 0.36, alpha: 1)
        return bgView
    }()
    
    fileprivate lazy var commetBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "circle_image_comment"), for: .normal)
        btn.CODButtonImageTitle(style: .left, titleImgSpace: 2)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle("评论", for: .normal)
        btn.addTarget(self, action: #selector(commentAcion(btn:)), for: .touchUpInside)

        return btn;
    }()
    
    fileprivate lazy var likeDetailBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "circle_image_like"), for: .normal)
        btn.CODButtonImageTitle(style: .left, titleImgSpace: 2)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle(" ", for: .normal)
        btn.addTarget(self, action: #selector(pushToDetailVC), for: .touchUpInside)
        return btn;
    }()
    
    fileprivate lazy var commetDetailBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "circle_image_comment"), for: .normal)
        btn.CODButtonImageTitle(style: .left, titleImgSpace: 2)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle(" ", for: .normal)
        btn.addTarget(self, action: #selector(pushToDetailVC), for: .touchUpInside)
        return btn;
    }()
    
    func setMessageMsgID(messageModel:CODDiscoverMessageModel){
        self.messageModel = messageModel
        getLikeStatus()
    }
    
}

extension CODLikeAndCommentView{

    
    @objc func likeAcion(btn: UIButton){
        btn.isSelected = !btn.isSelected
        
        if !btn.isSelected {
            //取消点赞
            if messageModel.statusEnum == .Succeed && messageModel.allowReviewAndLike {
                DiscoverHttpTools.dislike(momentsId: self.messageModel.serverMsgId, messageId: self.messageModel.likerId) { [weak self] (respones) in
                    
                    guard let `self` = self else { return }
                    
                    switch respones.result {
                    case .success(let data):
                        
                        if JSON(data)["data"]["flag"].boolValue {
                            self.getLikeStatus()

                        }

                    case .failure(_):
                        self.getLikeStatus()
//                        self.showErrorPR.accept(NSLocalizedString("暂无网络", comment: ""))
                        break
                    }
                }
            }
        }else{
            //点赞
            if messageModel.statusEnum == .Succeed && messageModel.allowReviewAndLike {
                DiscoverHttpTools.like(momentsId: self.messageModel.serverMsgId) { [weak self] (respones) in
                    guard let `self` = self else { return }
                    
                    switch respones.result {
                    case .success(let data):
                        
                        if JSON(data)["data"]["momentsId"].stringValue == self.messageModel.serverMsgId {
                            self.getLikeStatus()
                        }
                        
                    case .failure(_):
//                        self.getLikeStatus()
//                        self.showErrorPR.accept(NSLocalizedString("暂无网络", comment: ""))
                        break
                    }
                }
                
            }
        }
    }
    
    @objc func commentAcion(btn: UIButton){
        
        let commentVC = CODBrowseCommentsVC()

        commentVC.messageModel = self.messageModel
        commentVC.modalPresentationStyle = .overFullScreen
        CustomUtil.isPlayVideo(isPlay: false)

        commentVC.backBlock = { [weak self]  in
            guard let `self` = self else { return }
            self.getLikeStatus()
            CustomUtil.isPlayVideo(isPlay: true)
        }
        UIViewController.current()?.present(commentVC, animated: true, completion: {
            
        })
    }
    
    
    @objc func pushToDetailVC() {
       
        let detailVC = CODDiscoverDetailVC(pageType: .normal(momentsId: self.messageModel.msgId))
        CustomUtil.isPlayVideo(isPlay: false)

        detailVC.backBlock = { [weak self]  in
            guard let `self` = self else { return }
            self.getLikeStatus()
            CustomUtil.isPlayVideo(isPlay: true)
        }
        UIViewController.current()?.navigationController?.pushViewController(detailVC)

    }
    
    func getLikeStatus() {
       if let messageModel = CustomUtil.getCircleMessage(msgID: self.messageModel.msgId) {
        
        self.likeBtn.isHidden = (messageModel.msgPrivacyTypeEnum == .Private) ? true : false
        self.commetBtn.isHidden = (messageModel.msgPrivacyTypeEnum == .Private) ? true : false
        self.lineView.isHidden = (messageModel.msgPrivacyTypeEnum == .Private) ? true : false

        self.messageModel = messageModel
            if self.messageModel.likerList.firstIndex(where: {$0.jid == UserManager.sharedInstance.jid}) != nil {
                self.likeBtn.isSelected = true
            }else{
                self.likeBtn.isSelected = false
            }
            
            if (messageModel.likerList.count > 0) {
                self.likeDetailBtn.setTitle("\(messageModel.likerList.count)  ", for: .normal)

            }else{
                self.likeDetailBtn.setTitle("", for: .normal)
            }
            if (messageModel.replyList.count > 0) {
                self.commetDetailBtn.setTitle("\(messageModel.replyList.count)  ", for: .normal)
            }else{
                self.commetDetailBtn.setTitle("", for: .normal)
            }
            
        }

    }
}
