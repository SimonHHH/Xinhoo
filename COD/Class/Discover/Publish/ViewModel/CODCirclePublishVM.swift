//
//  CODCirclePublishVM.swift
//  COD
//
//  Created by xinhooo on 2020/5/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxCocoa
class CODCirclePublishVM: NSObject {

    private let black = UIColor.black
    private let blue = UIColor(hexString: "047EF5") ?? .black
    private let red = UIColor(hexString: "FF3B30") ?? .black
    
    struct CellInfo {
        var imgName = ""
        var title = ""
        var subTitle = ""
        var color:UIColor = .black
    }
    
    var publishModel: CODCirlcePublishModel = CODCirlcePublishModel()
    
    var setModelAttribute:BehaviorRelay<CODCirclePublishVM?>?      = nil
    
    override init() {
        super.init()
        setModelAttribute      = BehaviorRelay<CODCirclePublishVM?>(value: self)
    }
    
    
    func getCellInfo(index:Int) -> CellInfo {
        
        switch index {
        case 0:
            
            /// 位置信息
            if let position = publishModel.position {
                return CellInfo(imgName: "circle_position_publish_blue", title: position.name, subTitle: "",color: blue)
                
            }else{
                return CellInfo(imgName: "circle_position_publish", title: NSLocalizedString("所在位置", comment: ""), subTitle: "",color: black)
            }
            
        case 1:
            
            if publishModel.atList.count > 0 {
                
                let nickList = publishModel.atList.map { (jid) -> String? in
                    if let model = CODContactRealmTool.getContactByJID(by: jid) {
                        return model.getContactNick()
                    }else{
                        return nil
                    }
                }.compactMap { $0 }
                
                return CellInfo(imgName: "circle_at_publish_blue", title: NSLocalizedString("提醒谁看", comment: ""), subTitle: nickList.joined(separator: "、"), color: blue)
                
            }else{
                return CellInfo(imgName: "circle_at_publish", title: NSLocalizedString("提醒谁看", comment: ""), subTitle: "", color: black)
            }
            
            
        case 2:
            
            let nickList = publishModel.canLook.somePeopleList.map { (jid) -> String? in
                if let model = CODContactRealmTool.getContactByJID(by: jid) {
                    
                    return model.getContactNick()
                    
                }else if let model = CODGroupChatRealmTool.getGroupChatByJID(by: jid) {
                    
                    return model.getGroupName()
                    
                } else{
                    
                    return nil
                }
            }.compactMap{ $0 }
            
                
            switch publishModel.canLook.permissions {
                
            case .publicity:
                return CellInfo(imgName: "circle_isLook_publish", title: NSLocalizedString("谁可以看", comment: ""), subTitle: NSLocalizedString("公开", comment: ""),color: black)
                
            case .onlySelf:
                return CellInfo(imgName: "circle_isLook_publish_blue", title: NSLocalizedString("谁可以看", comment: ""), subTitle: NSLocalizedString("私密", comment: ""),color: blue)
                
            case .somePeople_canSee:
                return CellInfo(imgName: "circle_isLook_publish_blue", title: NSLocalizedString("谁可以看", comment: ""), subTitle: nickList.joined(separator: "、"),color: blue)
                
            case .somePeople_notSee:
                return CellInfo(imgName: "circle_isLook_publish_red", title: NSLocalizedString("谁不可看", comment: ""), subTitle: nickList.joined(separator: "、"),color: red)

            }
                
        case 3:
            
            if publishModel.isCanCommentAndLike == 2 {
                
                return CellInfo(imgName: "circle_comment_publish", title: NSLocalizedString("允许朋友点赞、评论", comment: ""), subTitle: NSLocalizedString("允许", comment: ""), color: black)
            }else{
                
                return CellInfo(imgName: "circle_comment_publish_red", title: NSLocalizedString("允许朋友点赞、评论", comment: ""), subTitle: NSLocalizedString("禁止", comment: ""), color: red)
            }
            
        case 4:
            
            if publishModel.isPublicCommentAndLike == 1 {
                return CellInfo(imgName: "circle_isLike_publish_blue", title: NSLocalizedString("允许点赞、评论公开", comment: ""), subTitle: NSLocalizedString("允许", comment: ""), color: blue)
            }else{
                return CellInfo(imgName: "circle_isLike_publish", title: NSLocalizedString("允许点赞、评论公开", comment: ""), subTitle: NSLocalizedString("禁止", comment: ""), color: black)
            }
            
        default:
            return CellInfo(imgName: "", title: "", subTitle: "")
        }
        
    }
    
    /// 更新位置信息
    /// - Parameter location: 位置结构体
    func updateLocation(location:CODCirlcePublishModel.Location?) {
        
        self.publishModel.position = location
        self.setModelAttribute?.accept(self)
    }
    
    /// 更新model类型
    /// - Parameter type: type
    func updateType(type:CODCirlcePublishModel.CircleType) {
        
        self.publishModel.circleType = type
        self.setModelAttribute?.accept(self)
    }
    
    /// 更新文本内容
    /// - Parameter content: 文本内容
    func updateContent(content:String) {
        self.publishModel.content = content
        self.setModelAttribute?.accept(self)
    }
    
    /// 更新被@的人集合
    /// - Parameter contactList: @集合
    func updateAtList(contactList: [String]) {
        self.publishModel.atList = contactList
        self.setModelAttribute?.accept(self)
    }
    
    /// 更新 是否可以评论、点赞
    /// - Parameter selectInt: 1禁止，2允许
    func updateCanCommentAndLike(selectInt: Int) {
        self.publishModel.isCanCommentAndLike = selectInt
        self.setModelAttribute?.accept(self)
    }
    
    /// 更新 是否公开评论、点赞
    /// - Parameter selectInt: 1允许，2禁止
    func updatePublicCommentAndLike(selectInt: Int) {
        self.publishModel.isPublicCommentAndLike = selectInt
        self.setModelAttribute?.accept(self)
    }
    
    /// 更新 可见权限
    /// - Parameters:
    ///   - canLookType: 可见类型
    ///   - jids: 部分可见/不可见 人的jid集合
    func updateCanLook(canLookType: CODCirlcePublishModel.CanLook.Permissions , groupJids: [String]? , contactJids: [String]?) {
        
        self.publishModel.canLook.permissions = canLookType
        self.publishModel.canLook.groupList = groupJids
        self.publishModel.canLook.contactList = contactJids
        self.publishModel.canLook.somePeopleList = (groupJids ?? []) + (contactJids ?? [])
        
        if canLookType == .onlySelf {
            self.publishModel.atList = []
            self.publishModel.isCanCommentAndLike = 2
            self.publishModel.isPublicCommentAndLike = 2
        }
        
        self.setModelAttribute?.accept(self)
    }
}
