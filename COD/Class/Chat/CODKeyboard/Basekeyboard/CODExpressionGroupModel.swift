//
//  CODExpressionGroupModel.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON

class CODExpressionGroupModel: HandyJSON {
    var type:CODEmojiType = .CODEmojiTypeEmoji
    var gId:String? = nil //表情包的id
    var name:String? = nil //表情包的名字
    var detail:String? = nil//表情包嗯嗯描述
    var iconPath:String? = nil//表情包icon的路径
    var iconURL:String? = nil//表情包icon的iconURL
    var count : Int  = 0
    ///列数
    var colNumber:Int {
        get{
            if type == .CODEmojiTypeEmoji||type == .CODEmojiTypeFace{
                return 8
            }else{
                return 4
            }
        }
    }
    ///行数
    var rowNumber:Int {
        get{
            if type == .CODEmojiTypeEmoji||type == .CODEmojiTypeFace{
                return 4
            }else{
                return 2
            }
        }
    }
    ///一页的数量
    var pageItemCount:Int{
        get{
            if type == .CODEmojiTypeEmoji||type == .CODEmojiTypeFace{
                return self.rowNumber * self.colNumber - 1
            }else{
                return self.rowNumber * self.colNumber
            }
        }
    }
    ///总页数
    var pageNumber:Int{
        get{
            if data?.isEmpty == false{
                self.count = self.data!.count
            }
            return self.count / self.pageItemCount + (self.count % self.pageItemCount == 0 ? 0 : 1)
        }
    }
    
    var data:[CODExpressionModel]? = nil///表情
    required init() {}
    
}
