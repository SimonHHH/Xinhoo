//
//  CODMoreKBHelper.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODMoreKBHelper: NSObject {
    var chatMoreKeyboardData:[CODMoreKeyboardItem]?
    override init() {
        super.init()
        ///设置数据
        self.initTestData()
    }
    fileprivate func initTestData(){
        let imageItem = CODMoreKeyboardItem.createMoreItem(type: .CODMoreKeyboardItemTypeImage, title: "相册", imagePath: "moreKB_image")
        let cameraItem = CODMoreKeyboardItem.createMoreItem(type: .CODMoreKeyboardItemTypeCamera, title: "拍摄", imagePath: "moreKB_camera")
        let voiceCallItem = CODMoreKeyboardItem.createMoreItem(type: .CODMoreKeyboardItemTypeVoiceCall, title: "语音通话", imagePath: "moreKB_voice_call")
        let positionItem = CODMoreKeyboardItem.createMoreItem(type: .CODMoreKeyboardItemTypePosition, title: "位置", imagePath: "moreKB_location")
        //let favoriteItem = CODMoreKeyboardItem.createMoreItem(type: .CODMoreKeyboardItemTypeFavorite, title: "收藏", imagePath: "moreKB_favorite")
        let cardsItem = CODMoreKeyboardItem.createMoreItem(type: .CODMoreKeyboardItemTypeCards, title: "名片", imagePath: "moreKB_wallet")
        let cloudDiskItem = CODMoreKeyboardItem.createMoreItem(type: .CODMoreKeyboardItemTypeCloudDisk, title: "我的云盘", imagePath: "moreKB_clouddisk")
//        let videoCallItem = CODMoreKeyboardItem.createMoreItem(type: .CODMoreKeyboardItemTypeVideoCall, title: "视频通话", imagePath: "moreKB_video_call")
//        self.chatMoreKeyboardData = [imageItem,cameraItem,voiceCallItem,videoCallItem,positionItem,cardsItem,fileItem,cloudDiskItem]
        let fileItem = CODMoreKeyboardItem.createMoreItem(type: .CODMoreKeyboardItemTypeFile, title: "文件", imagePath: "moreKB_file")
        self.chatMoreKeyboardData = [imageItem,cameraItem,voiceCallItem,positionItem,cardsItem,cloudDiskItem,fileItem]
    }
}
