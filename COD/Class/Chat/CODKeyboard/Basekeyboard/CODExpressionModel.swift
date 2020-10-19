//
//  CODExpressionModel.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON
private let COMMONTLY_STR:String = "commonlyEmoji"
class CODExpressionModel: HandyJSON {
    var eid:String? = nil
    var type:CODEmojiType = .CODEmojiTypeEmoji
    var emojiGroupIndex:Int = 0 ///表情组的下标
    var name:String? = nil
    var emojiName:String? = nil
    var cellSize:CGSize?
    var sectionInsets:UIEdgeInsets?
    
    required init() {}
    func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &name, name: "credentialName")
    }
    
    ///json数组转模型数组
    class func jsonArrayToModel(jsonArrayData:NSData?) -> [CODExpressionModel] {
        if jsonArrayData == nil {
            return []
        }
        var modelArray:[CODExpressionModel] = [CODExpressionModel]()
        let peoplesArray = try! JSONSerialization.jsonObject(with:jsonArrayData! as Data, options: JSONSerialization.ReadingOptions()) as? [AnyObject]
        for people:AnyObject in peoplesArray! {
            modelArray.append(CODExpressionModel.deserialize(from: (people as! NSDictionary))!)
        }
        return modelArray
    }
    
    ///获取常用表情数组 最大为32个
    class func getAllCommmonLyEmoji(cellSize:CGSize,sectionInsets:UIEdgeInsets) -> [CODExpressionModel]{
        
        let jsonArray = UserDefaults.standard.object(forKey: COMMONTLY_STR) as? [AnyObject];
        var modelArray:[CODExpressionModel] = [CODExpressionModel]()
        if(jsonArray != nil){
            for model:AnyObject in jsonArray! {
                let itemModel = CODExpressionModel.deserialize(from: (model as! NSDictionary))!
                itemModel.cellSize = cellSize
                itemModel.sectionInsets = sectionInsets
                modelArray.append(itemModel)
            }
            return modelArray
        }else{
            return modelArray
        }
    }
    
    ///保存表情
    class func saveEmojiCommmonLy(model:CODExpressionModel,cellSize:CGSize,sectionInsets:UIEdgeInsets) -> [CODExpressionModel]{
        ///无法保存
        model.cellSize = nil
        model.sectionInsets = nil
        let jsonElement = model.toJSON()
        model.cellSize = cellSize
        model.sectionInsets = sectionInsets
        var jsonArray = UserDefaults.standard.object(forKey: COMMONTLY_STR) as? [AnyObject];
        if(jsonArray == nil){
            jsonArray = [AnyObject]()
        }
        var isSame = false
        ///遍历是否有相同的 有相同的不然添加进去
        for jsonItem:AnyObject in jsonArray! {
            let jsonModel =  CODExpressionModel.deserialize(from: (jsonItem as! NSDictionary))!
            if(model.name == jsonModel.name){
                isSame = true
                break
            }
        }
        ///是否超过数量
        if(jsonArray!.count >= 32 && isSame == false){
            jsonArray?.removeFirst()
        }
        //保存
        if(isSame == false){
            jsonArray!.append(jsonElement as AnyObject)
            ///保存成data
            UserDefaults.standard.set(jsonArray, forKey: COMMONTLY_STR)
        }
        ///返回最新的数组
        var modelArray:[CODExpressionModel] = [CODExpressionModel]()
        for item:AnyObject in jsonArray! {
            let itemModle = CODExpressionModel.deserialize(from: (item as! NSDictionary))!
            itemModle.cellSize = cellSize
            itemModle.sectionInsets = sectionInsets
            modelArray.append(itemModle)
        }
        return modelArray
    }
}
