//
//  Xinhoo_GifCellProtocol.swift
//  COD
//
//  Created by Sim Tsai on 2019/12/24.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation

protocol Xinhoo_GifCellProtocol where Self: CODBaseChatCell, LableType: YYLabel, AnimatedImageView: SDAnimatedImageView {
    
    associatedtype LableType
    associatedtype AnimatedImageView
    

    var imgPic: AnimatedImageView! { set get }
    var viewEditTime: UIView! { get }
    var lblDesc: LableType! { get }
    var lblDescHeightCos: NSLayoutConstraint! { get }
    var imgPicBottomCos: NSLayoutConstraint! { get }
    var fwContentView:CODZZS_ForwardingView { get }
//    var contentTopCos: NSLayoutConstraint! { get }
    var imgPicHeightCos: NSLayoutConstraint! { get }
    var lblDescWidthCos: NSLayoutConstraint! { get }
    var bubblesImageView: UIImageView! { get }
    var timeViewBottomCos: NSLayoutConstraint! { get }
    var backViewBottomCos: NSLayoutConstraint! { get }
    var videoImageView: CODVideoCancleView { get }
    var timeDisplayView: UIView { get }
    func configGifModel(lastModel:CODMessageModel?, model:CODMessageModel, nextModel:CODMessageModel?)
    
}

extension Xinhoo_ImageLeftTableViewCell: Xinhoo_GifCellProtocol {
    var timeDisplayView: UIView {
        return self.timeView
    }
}

extension Xinhoo_ImageRightTableViewCell: Xinhoo_GifCellProtocol {
    var timeDisplayView: UIView {
        return self.timeView
    }
}

extension Xinhoo_GifCellProtocol {
    
    
    func configGifModel(lastModel:CODMessageModel?, model:CODMessageModel, nextModel:CODMessageModel?) {
        
        
        self.bubblesImageView.isHidden = true
        self.viewEditTime.isHidden = true
        self.lblDesc.isHidden = true
        self.lblDescHeightCos.constant = 19
        self.imgPicBottomCos.constant = 1
        
        self.fwContentView.clear()
        
        self.timeDisplayView.isHidden = false

//        self.imgPicWidthCos.constant = 148
        self.lblDescWidthCos.constant = 148 - 16
        self.imgPicHeightCos.constant = 148
        self.timeViewBottomCos.constant = 21
        self.backViewBottomCos.constant = 30
        
        self.imgPic.setGifImage(identifier: model.text)
        self.imgPic.setCustomCornerRaidus(CornerRadiusMake(5, 5, 5, 5), size: CGSize(width: 148, height: 148))
        
        self.videoImageView.hide()
        self.timeDisplayView.backgroundColor = UIColor(hexString: "#879EAE", transparency: 0.5)
        
    }
    
}



