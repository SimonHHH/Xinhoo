//
//  CODChatImageCellImageNicknameable.swift
//  COD
//
//  Created by Sim Tsai on 2020/1/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import UIView_FDCollapsibleConstraints

protocol CODChatGetSenderInfoable {
    
    var messageModel: CODMessageModel { get }
    
    func getMessageSenderNickName() -> String
}

extension CODChatGetSenderInfoable {
    
    func getMessageSenderNickName() -> String {
        return self.messageModel.getMessageSenderNickName()
    }
    
}

extension Xinhoo_ImageLeftTableViewCell: CODChatImageCellImageNicknameable {}
extension Xinhoo_ImageRightTableViewCell: CODChatGetSenderInfoable {}


protocol CODChatImageCellImageNicknameable where Self: CODChatGetSenderInfoable, AnimatedImageView: SDAnimatedImageView {
    
    associatedtype AnimatedImageView
    
    var viewModel: Xinhoo_ImageViewModel? { get }
    var messageModel: CODMessageModel { get }
    var timeView: XinhooTimeAndReadView! { get }
    var lblEditTime: UILabel! { get }
    var imgPic: AnimatedImageView! { get }
    var nickNameLab: UILabel! { get }
    var nickNameView: UIView! { get }
    var isShowName: Bool { get }
    var adminLab: UILabel! { get }
    var imageViewLeadingCos: NSLayoutConstraint! { get }
    var blurView: UIView! { get }
    var lblDescWidthCos: NSLayoutConstraint! { get }
    
    func configPicCornerRaidus(imageSize: CGSize)
    func configShowName(showName: Bool)
    func isRpOrFw() -> Bool
    func hasDesc() -> Bool
    func needImageMaskLayer() -> Bool
    

}

extension CODChatImageCellImageNicknameable {
    
    
    func isRpOrFw() -> Bool {
        return (self.messageModel.rp.count > 0 && self.messageModel.rp != "0") || (CustomUtil.getIsShowFwView(messageModel: self.messageModel))
    }
    
    func hasDesc() -> Bool {
        
        if self.messageModel.type == .video && self.messageModel.videoModel?.descriptionVideo.count ?? 0 > 0 {
            return true
        } else if self.messageModel.type == .image && self.messageModel.photoModel?.descriptionImage.count ?? 0 > 0 {
            return true
        } else {
            return false
        }
        
    }
    
    func needImageMaskLayer() -> Bool {
                
        if self.isRpOrFw() || self.isShowName || self.hasDesc() {
            return false
        } else {
            return true
        }
        
    }
    
    func configPicCornerRaidus(imageSize: CGSize) {
        
        let bigRadius:CGFloat = 16
        let smallRadius:CGFloat = 5
        
        var topLeft: CGFloat = bigRadius
        var topRight: CGFloat = bigRadius
        var bottomLeft: CGFloat = smallRadius
        var bottomRight: CGFloat = smallRadius
        
        if self.isShowName || self.isRpOrFw() {
            topLeft = smallRadius
            topRight = smallRadius
        } else if self.viewModel?.cellLocation == .mid {
            topLeft = smallRadius
        }

        if self.hasDesc() {
            bottomLeft = smallRadius
            self.timeView.isHidden = true
            self.lblEditTime.isHidden = false
        } else {
            self.timeView.isHidden = false
            self.lblEditTime.isHidden = true
            
            if self.viewModel?.cellLocation == .mid {
                bottomRight = bigRadius
            }
            
        }
        
        self.imgPic.setCustomCornerRaidus(CornerRadius(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight), size: CGSize(width: self.lblDescWidthCos.constant + 16, height: imageSize.height))
        self.blurView.setCustomCornerRaidus(CornerRadius(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight), size: CGSize(width: self.lblDescWidthCos.constant + 16, height: imageSize.height))
        
        if self.needImageMaskLayer() {
            self.imageViewLeadingCos.constant = 1
            self.imgPic.layer.mask = self.viewModel?.leftImageLayer
            self.blurView.layer.mask = self.viewModel?.leftImageLayer
        } else {
            self.imageViewLeadingCos.constant = 7
        }
        
        self.imgPic.layer.masksToBounds = true
        self.blurView.layer.masksToBounds = true
    }
    
    

    func setNickName() {
            
        nickNameLab.text = self.getMessageSenderNickName()
        self.nickNameLab.textColor = messageModel.getNickNameColor()
    }
    
    func setCouldName() {
            
        nickNameLab.text = CustomUtil.getMessageModelNickName(messageModel: self.messageModel)
        self.nickNameLab.textColor = CustomUtil.getMessageModelTextColor(messageModel: self.messageModel)
    }
    
    func setChannelName() {
        if let channel = CODChannelModel.getChannel(by: self.messageModel.roomId) {
            self.nickNameLab.text = channel.descriptions
        }else{
            self.nickNameLab.text = NSLocalizedString("频道", comment: "")
        }
        
        self.nickNameLab.textColor = UIColor(hexString: kChannelNameColorS)
    }
    
    func configShowName(showName: Bool) {
        
        if showName == false || self.messageModel.type == .gifMessage {
            self.nickNameView.isHidden = true
            self.nickNameView.fd_collapsed = true
            self.adminLab.text = ""
            self.nickNameLab.text = ""
            return
        }
        
        
        self.nickNameView.isHidden = false
        self.nickNameView.fd_collapsed = false
        if self.messageModel.chatTypeEnum == .channel {
            setChannelName()
            self.adminLab.text = ""
        }else if CustomUtil.getIsCloudMessage(messageModel: self.messageModel){
            setCouldName()
            self.adminLab.text = ""
        } else {
            setNickName()
            self.adminLab.text = self.viewModel?.adminStr
        }
        
    }

}

