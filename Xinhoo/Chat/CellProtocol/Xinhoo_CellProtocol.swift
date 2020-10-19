//
//  Xinhoo_CellProtocol.swift
//  COD
//
//  Created by xinhooo on 2019/12/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation

enum LocationType {
    case only
    case top
    case mid
    case bottom
}



protocol  Xinhoo_CellProtocol: class {
    var model: CODMessageModel { get }
    var lastModel: CODMessageModel? { get }
    var nextModel: CODMessageModel? { get }
    var dateTime: String { get }
    var sendTime: String { get }
    var isBurn: Bool { get }
    var headViewIsHidden: Bool { get }
    var adminStr: String { get }
    //MARK: 仿电报气泡样式
    var telegram_leftBubblesImage: UIImage { get }
    var telegram_rightBubblesImage: UIImage { get }
    var telegram_left_FlashingBubblesImage: UIImage { get }
    var telegram_right_FlashingBubblesImage: UIImage { get }
    
    var cellLocation: LocationType { set get }
    
    var leftImageLayer: CALayer { get }
//    var rightImageLayer: CALayer { get }
    
    func createRightImageLayer(imageSize: CGSize) -> CALayer
    func createRightImageLayer(size: CGSize) -> CALayer
}

extension Xinhoo_CellProtocol {
        
    /// cell顶部显示时间
    var dateTime: String {
        
        var datetime = "0"
        if self.model.datetime != "" {
            datetime = self.model.datetime
        }
        
        return TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double(datetime))!/1000), format: NSLocalizedString("MM 月 dd 日", comment: ""))
    }
    
    /// cell右下角显示时间
    var sendTime: String {
        let timeString = TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double((self.model.datetime.int == nil ? "\(Date.milliseconds)":self.model.datetime)))!/1000), format: XinhooTool.is12Hour ? "h:mm a" : "h:mm")
        return  self.model.edited == 0 ? timeString : ("\(NSLocalizedString("已编辑", comment: ""))  " + timeString)
    }
    
    /// 是否显示阅后即焚
    var isBurn: Bool {
        return !(self.model.burn > 0)
    }
    
    //MARK:telegram气泡样式
    /// 左边气泡图片
    var telegram_leftBubblesImage: UIImage {
        
        switch cellLocation {
        case .top:
            return XinhooTool.telegram_left_top_image
        case .mid:
            return XinhooTool.telegram_left_mid_image
        case .bottom:
            return XinhooTool.telegram_left_bottom_image
        case .only:
            return XinhooTool.telegram_left_normal_image
        }
    }
    
    /// 右边气泡图片
    var telegram_rightBubblesImage: UIImage {
        
        switch cellLocation {
        case .top:
            return XinhooTool.telegram_right_top_image
        case .mid:
            return XinhooTool.telegram_right_mid_image
        case .bottom:
            return XinhooTool.telegram_right_bottom_image
        case .only:
            return XinhooTool.telegram_right_normal_image
        }
    }
    
    /// 左边闪烁气泡图片
    var telegram_left_FlashingBubblesImage: UIImage {
        
       switch cellLocation {
        case .top:
            return XinhooTool.telegram_left_top_flash_image
        case .mid:
            return XinhooTool.telegram_left_mid_flash_image
        case .bottom:
            return XinhooTool.telegram_left_bottom_flash_image
        case .only:
            return XinhooTool.telegram_left_normal_flash_image
        }
    }
    
    /// 右边闪烁气泡图片
    var telegram_right_FlashingBubblesImage: UIImage {
        
        switch cellLocation {
        case .top:
            return XinhooTool.telegram_right_top_flash_image
        case .mid:
            return XinhooTool.telegram_right_mid_flash_image
        case .bottom:
            return XinhooTool.telegram_right_bottom_flash_image
        case .only:
            return XinhooTool.telegram_right_normal_flash_image
        }
    }
    
    func getCellLocation() -> LocationType {
        
        var lastModel = self.lastModel
        var nextModel = self.nextModel
        let model = self.model
        
//        let lastIsCloudDisk = CustomUtil.getIsCloudMessage(messageModel: lastModel)
//        let nextIsCloudDisk = CustomUtil.getIsCloudMessage(messageModel: nextModel)
        
//        if isCloudDisk {
//            return .bottom
//        }
        
        
        let lastDiff = (CustomUtil.getTimeDiff(starTime: (lastModel?.datetime ?? "\(Date.milliseconds)") as NSString, endTime: model.datetime as NSString) > 600)
        let nextDiff = (CustomUtil.getTimeDiff(starTime: model.datetime as NSString, endTime: (nextModel?.datetime ?? "\(Date.milliseconds)") as NSString) > 600)
                
        var currentShowdate: Bool = false
        var nextShowdate: Bool = false
        
        if lastModel == nil {
            currentShowdate = true
        }else{
            currentShowdate = !CustomUtil.isSameDay(starTime: (lastModel?.datetime ?? "\(Date.milliseconds)") as NSString, endTime: model.datetime as NSString)
        }
        
        if nextModel == nil {
            nextShowdate = true
        }else{
            nextShowdate = !CustomUtil.isSameDay(starTime: model.datetime as NSString, endTime: (nextModel?.datetime ?? "\(Date.milliseconds)") as NSString)
        }
        
        if lastModel?.msgType == 8 || lastDiff{
            lastModel = nil
        }
        
        if nextModel?.msgType == 8 || nextDiff{
            nextModel = nil
        }
        
        if (lastModel?.fw != model.fw) {
            lastModel = nil
        }
        
        if (nextModel?.fw != model.fw) {
            nextModel = nil
        }
        
        
        if (lastModel == nil && nextModel == nil) || (lastModel?.fromWho != model.fromWho && nextModel?.fromWho != model.fromWho) || (currentShowdate && nextModel?.fromWho != model.fromWho) || (lastModel?.fromWho != model.fromWho && nextShowdate ) {
            return .only
        }else if (lastModel?.fromWho != model.fromWho && model.fromWho == nextModel?.fromWho) || currentShowdate {
            return .top
        }else if lastModel?.fromWho == model.fromWho && model.fromWho == nextModel?.fromWho && !(nextShowdate ){
            return .mid
        }else{
            return .bottom
        }
    }
    
    /// 是否显示群头像
    var headViewIsHidden: Bool {
        if self.model.chatTypeEnum == .groupChat || CustomUtil.getIsCloudMessage(messageModel: self.model) {
            return self.cellLocation == .mid || self.cellLocation == .top
        }else{
            return true
        }
    }
    
    var leftImageLayer: CALayer {
        var imageSize = CGSize.zero
        if self.model.imageHeight > 0 && self.model.imageWidth > 0 {
            imageSize.width = self.model.imageWidth.cgFloat
            imageSize.height = self.model.imageHeight.cgFloat
        }
        
        let isRpOrFw = (self.model.rp.count > 0 && self.model.rp != "0") || (self.model.fw.count > 0 && self.model.fw != "0") 
        let imgLayer = isRpOrFw ? UIImage.init(named: "left_img_layer")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch) : self.telegram_leftBubblesImage
        
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue:  self.model.msgType ) ?? .text
        if modelType == .video {
            imageSize = CODChatConfig.getThumbImageSize(CGSize(width: self.model.videoModel?.w.cgFloat ?? 0, height: self.model.videoModel?.h.cgFloat ?? 0))
        } else {
            imageSize = CODChatConfig.getThumbImageSize(CGSize(width: self.model.photoModel?.w.cgFloat ?? 0, height: self.model.photoModel?.h.cgFloat ?? 0))
        }
        // 新建一个图层
        let layer = CALayer()
        // 设置图层显示的内容为拉伸过的MaskImgae
        layer.contents = imgLayer.cgImage
        // 设置拉伸范围(注意：这里contentsCenter的CGRect是比例（不是绝对坐标）)
        layer.contentsCenter = self.CGRectCenterRectForResizableImage(imgLayer)
        // 设置图层大小与chatImgView相同
        layer.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        // 设置比例
        layer.contentsScale = UIScreen.main.scale
        // 设置不透明度
        layer.opacity = 1
        // 设置裁剪范围
        return layer
    }
    
    func createRightImageLayer(imageSize: CGSize) -> CALayer {
        var imageSize = imageSize
        
        let isRpOrFw = (self.model.rp.count > 0 && self.model.rp != "0") || (self.model.fw.count > 0 && self.model.fw != "0")
        let imgLayer = isRpOrFw ?  UIImage.init(named: "right_img_layer")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch) : self.telegram_rightBubblesImage
        
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue:  self.model.msgType ) ?? .text
        if modelType == .video {
            imageSize = CODChatConfig.getThumbImageSize(CGSize(width: imageSize.width, height: imageSize.height))
        } else {
            imageSize = CODChatConfig.getThumbImageSize(CGSize(width: imageSize.width, height: imageSize.height))
        }
        // 新建一个图层
        let layer = CALayer()
        // 设置图层显示的内容为拉伸过的MaskImgae
        layer.contents = imgLayer.cgImage
        // 设置拉伸范围(注意：这里contentsCenter的CGRect是比例（不是绝对坐标）)
        layer.contentsCenter = self.CGRectCenterRectForResizableImage(imgLayer)
        // 设置图层大小与chatImgView相同
        layer.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        // 设置比例
        layer.contentsScale = UIScreen.main.scale
        // 设置不透明度
        layer.opacity = 1
        // 设置裁剪范围
        return layer
    }
    
    func createLeftImageLayer(size: CGSize) -> CALayer {

        let imgLayer = self.model.isRpOrFw ? UIImage.init(named: "left_img_layer")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch) : self.telegram_leftBubblesImage
        

        // 新建一个图层
        let layer = CALayer()
        // 设置图层显示的内容为拉伸过的MaskImgae
        layer.contents = imgLayer.cgImage
        // 设置拉伸范围(注意：这里contentsCenter的CGRect是比例（不是绝对坐标）)
        layer.contentsCenter = self.CGRectCenterRectForResizableImage(imgLayer)
        // 设置图层大小与chatImgView相同
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        // 设置比例
        layer.contentsScale = UIScreen.main.scale
        // 设置不透明度
        layer.opacity = 1
        // 设置裁剪范围
        return layer
        
    }
    
    func createRightImageLayer(size: CGSize) -> CALayer {

        let isRpOrFw = (self.model.rp.count > 0 && self.model.rp != "0") || (self.model.fw.count > 0 && self.model.fw != "0")
        let imgLayer = isRpOrFw ?  UIImage.init(named: "right_img_layer")!.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left:20, bottom: 16, right: 20), resizingMode: .stretch) : self.telegram_rightBubblesImage

        // 新建一个图层
        let layer = CALayer()
        // 设置图层显示的内容为拉伸过的MaskImgae
        layer.contents = imgLayer.cgImage
        // 设置拉伸范围(注意：这里contentsCenter的CGRect是比例（不是绝对坐标）)
        layer.contentsCenter = self.CGRectCenterRectForResizableImage(imgLayer)
        // 设置图层大小与chatImgView相同
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        // 设置比例
        layer.contentsScale = UIScreen.main.scale
        // 设置不透明度
        layer.opacity = 1
        // 设置裁剪范围
        return layer
    }
    
    
    func CGRectCenterRectForResizableImage(_ image: UIImage) -> CGRect {
        // LXFLog("\(image.capInsets)")
        // 这里的image.capInsets就是UIEdgeInsetsMake(30, 28, 23, 28)
        return CGRect(
            x: image.capInsets.left / image.size.width,
            y: image.capInsets.top / image.size.height,
            width: (image.size.width - image.capInsets.right - image.capInsets.left) / image.size.width,
            height: (image.size.height - image.capInsets.bottom - image.capInsets.top) / image.size.height
        )
    }
    
    /// cell右下角显示时间
    var adminStr: String {
        if self.model.chatTypeEnum == .groupChat {
            let member = CODGroupMemberRealmTool.getMemberById(CODGroupMemberModel.getMemberId(roomId: self.model.roomId, userName: self.model.fromJID))
            if (member?.userpower ?? 30) < 30 {
                 return NSLocalizedString("管理员", comment: "")
            }else{
                return ""
            }
            
        }else{
            return ""
        }
    }
    
}

extension ChatCellVM: Xinhoo_CellProtocol {
    var model: CODMessageModel {
        return self.messageModel
    }
}
