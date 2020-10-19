//
//  CODExpressionGroupDisplayModel.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON

class CODExpressionGroupDisplayModel: HandyJSON {
    required init() {}
    
    var type:CODEmojiType = .CODEmojiTypeEmoji
    var groupID:String?
    var groupName:String?
    var groupIconPath:String?
    var count:String?
    
    var data:[CODExpressionModel] = [CODExpressionModel]()
    var emojiGroupIndex:Int = 0 ///表情组的下标
    var pageIndex:Int = 0 ///页数
    
    var pageItemCount:Int = 0
    var pageNumber:Int = 0
    var rowNumber:Int = 0
    var colNumber:Int = 0
    
    var cellSize:CGSize?
    var sectionInsets:UIEdgeInsets?
    
    
    /// 显示模型
    ///
    /// - Parameters:
    ///   - emojiGroup: 表情组
    ///   - pageNumber: 当前页数
    ///   - pageCount: 每一页表情个数
    
    func initWithEmojiGroup(emojiGroup:CODExpressionGroupModel,pageNumber:Int,pageCount:Int) -> CODExpressionGroupDisplayModel{
        self.groupID = emojiGroup.gId
        self.groupIconPath = emojiGroup.name
        self.type = emojiGroup.type
        
        self.rowNumber = emojiGroup.rowNumber
        self.colNumber = emojiGroup.colNumber
        self.pageItemCount = emojiGroup.pageItemCount
        
        ///分组的数据到现在这个data上面
        let start = pageNumber * pageCount ///此页开始的表情
        if (emojiGroup.data?.count)! > start{
            let len = pageCount < ((emojiGroup.data?.count)! - start) ? pageCount:((emojiGroup.data?.count)! - start)
            for index in pageNumber * pageCount..<(pageNumber * pageCount + len){
                self.data.append(emojiGroup.data![index])
            }
        }
        return self
    }
    
    func objectAtIndex(index:Int) ->CODExpressionModel{
        return index < self.data.count ? self.data[index]:CODExpressionModel()
    }
}
