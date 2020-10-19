//
//  RosterRequestVM.swift
//  COD
//
//  Created by xinhooo on 2020/3/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RosterRequestVM : NSObject {
    
    enum `Type` {
        case unknown    //未知状态
        case normal     //未过期的待处理状态（显示通过，忽略按钮）
        case friend     //已添加
        case ignore     //忽略
        case deadline   //过期
    }
    
    private var requestModel:RosterRequestModel? = nil
    
    var reloadUI:BehaviorRelay<Int>? = nil
    var deleteModel:PublishRelay<RosterRequestVM?> = PublishRelay<RosterRequestVM?>()
    
    var sender: String{
        return requestModel?.sender ?? ""
    }
    
    var desc: String {
        return requestModel?.desc ?? ""
    }
    
    var senderPic: String {
        return requestModel?.senderPic ?? ""
    }
    
    var senderNickName: String {
        return requestModel?.senderNickName ?? ""
    }
    
    var requestTime: String {
        return requestModel?.requestTime ?? ""
    }
    
    init(model:RosterRequestModel) {
        super.init()
        requestModel = model
        reloadUI = BehaviorRelay<Int>(value: requestModel?.status ?? 0)
    }
    
    override init() {
        super.init()
    }
    
    var type: Type {
           
        switch requestModel?.status {
           case 0:
               return .friend
           case 1:
               //请求超过7天，已过期
            if (CustomUtil.getTimeDiff(starTime: (requestModel?.requestTime as NSString?) ?? "", endTime: "\(Date.milliseconds + Double(UserManager.sharedInstance.timeStamp))" as NSString) > 604800) {
                   return .deadline
               }else{
                   return .normal
               }
           case 2:
               return .ignore
           default:
               return .unknown
           }
       }
    
    func updateStatus(status:Int) {
        
        XMPPManager.shareXMPPManager.requestAcceptRoster(tojid: requestModel?.sender ?? "", status: "\(status)") { [weak self] (result) in
            switch result {

            case .success(_):
                
                if status == 1 {
                
                    self?.requestModel?.status = 0
                    self?.reloadUI?.accept(0)
                    CODProgressHUD.showSuccessWithStatus("已接受")
                }
                
                if status == 2 {
                    self?.requestModel?.status = 2
                    self?.reloadUI?.accept(2)
                    CODProgressHUD.showSuccessWithStatus("已忽略")
                }
                
                if status == 3{
                    self?.deleteModel.accept(self)
                    CODProgressHUD.showSuccessWithStatus("已删除")
                }
                
 
            case .failure(.iqReturnError(let code, let msg)):
                switch code {
                    
                case 30001:
                    CODProgressHUD.showErrorWithStatus("未知错误")
                    break
                case 30008:
                    CODProgressHUD.showErrorWithStatus("此好友申请已失效")
                    break
                default:
                    CODProgressHUD.showErrorWithStatus(msg)
                    break
                }
            default:
                CODProgressHUD.showErrorWithStatus("请求失败，请重新请求")
            }
        }
    }
}
