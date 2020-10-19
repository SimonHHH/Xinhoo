//
//  CODExpressionHelper.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODExpressionHelper: NSObject {
    ///单例的实现
    fileprivate var userID:String = ""
    static let helper = CODExpressionHelper()
    class func sharedHelper() -> CODExpressionHelper{
        return helper
    }
    ///设置默认的表情
    lazy var defaultFaceGroup: CODExpressionGroupModel = {
        let defaultFaceGroup = CODExpressionGroupModel()
        defaultFaceGroup.type = .CODEmojiTypeFace
        defaultFaceGroup.iconPath = "emojiKB_group_face"
        let path = Bundle.main.path(forResource: "CODEmoji", ofType: "json")
        var data = NSData(contentsOfFile: path!)
        let dataArray = CODExpressionModel.jsonArrayToModel(jsonArrayData: (data))
        defaultFaceGroup.data = dataArray
        for model in dataArray {
            model.type = .CODEmojiTypeFace
        }
        defaultFaceGroup.data = dataArray
        return defaultFaceGroup
    }()
    /// 默认系统Emoji
    lazy var defaultSystemEmojiGroup: CODExpressionGroupModel = {
        let defaultSystemEmojiGroup = CODExpressionGroupModel()
        defaultSystemEmojiGroup.type = .CODEmojiTypeEmoji
        defaultSystemEmojiGroup.iconPath = "emojiKB_group_face"
        let path = Bundle.main.path(forResource: "SystemEmoji", ofType: "json")
        var data = NSData(contentsOfFile: path!)
        let dataArray = CODExpressionModel.jsonArrayToModel(jsonArrayData: (data))
        for model in dataArray {
            model.type = .CODEmojiTypeEmoji
        }
        defaultSystemEmojiGroup.data = dataArray
        return defaultSystemEmojiGroup
    }()
     
     lazy var ybbEmojiGroup: CODExpressionGroupModel = {
         let defaultSystemEmojiGroup = CODExpressionGroupModel()
         defaultSystemEmojiGroup.type = .CODEmojiTypeImageWithTitle
         defaultSystemEmojiGroup.iconPath = "yyb_gif_emoji"
         defaultSystemEmojiGroup.name = "羊宝宝"
         let path = Bundle.main.path(forResource: "YYBEmoji", ofType: "json")
         var data = NSData(contentsOfFile: path!)
         let dataArray = CODExpressionModel.jsonArrayToModel(jsonArrayData: (data))
         for model in dataArray {
             model.type = .CODEmojiTypeImageWithTitle
         }
         defaultSystemEmojiGroup.data = dataArray
         return defaultSystemEmojiGroup
     }()
     
     lazy var xzmmEmojiGroup: CODExpressionGroupModel = {
         let defaultSystemEmojiGroup = CODExpressionGroupModel()
         defaultSystemEmojiGroup.type = .CODEmojiTypeImageWithTitle
         defaultSystemEmojiGroup.iconPath = "xzmm_gif_emoji"
         defaultSystemEmojiGroup.name = "小猪萌萌"
         let path = Bundle.main.path(forResource: "XZMMEmoji", ofType: "json")
         var data = NSData(contentsOfFile: path!)
         let dataArray = CODExpressionModel.jsonArrayToModel(jsonArrayData: (data))
         for model in dataArray {
             model.type = .CODEmojiTypeImageWithTitle
         }
         defaultSystemEmojiGroup.data = dataArray
         return defaultSystemEmojiGroup
     }()
     
     lazy var mtmEmojiGroup: CODExpressionGroupModel = {
         let defaultSystemEmojiGroup = CODExpressionGroupModel()
         defaultSystemEmojiGroup.type = .CODEmojiTypeImageWithTitle
         defaultSystemEmojiGroup.iconPath = "mtm_gif_emoji"
         let path = Bundle.main.path(forResource: "MTMEmoji", ofType: "json")
          defaultSystemEmojiGroup.name = "蜜桃猫"
         var data = NSData(contentsOfFile: path!)
         let dataArray = CODExpressionModel.jsonArrayToModel(jsonArrayData: (data))
         for model in dataArray {
             model.type = .CODEmojiTypeImageWithTitle
         }
         defaultSystemEmojiGroup.data = dataArray
         return defaultSystemEmojiGroup
     }()
     
     lazy var simaoEmojiGroup: CODExpressionGroupModel = {
         let defaultSystemEmojiGroup = CODExpressionGroupModel()
         defaultSystemEmojiGroup.type = .CODEmojiTypeImageWithTitle
         defaultSystemEmojiGroup.iconPath = "simao_gif_emoji"
         defaultSystemEmojiGroup.name = "四毛"
         let path = Bundle.main.path(forResource: "SIMAOEmoji", ofType: "json")
         var data = NSData(contentsOfFile: path!)
         let dataArray = CODExpressionModel.jsonArrayToModel(jsonArrayData: (data))
         for model in dataArray {
             model.type = .CODEmojiTypeImageWithTitle
         }
         defaultSystemEmojiGroup.data = dataArray
         return defaultSystemEmojiGroup
     }()
    
    ///通过用户的id 获取表情数据
     public func emojiGroupData(userID:String,filterGif: Bool = false,complete:((_ dataArray:[CODExpressionGroupModel])->Void)?){
        self.userID = userID
        if complete != nil {
          var emojiGroupData = [CODExpressionGroupModel]()
          // 默认表情包
          
          if filterGif {
               
               emojiGroupData.append(self.defaultSystemEmojiGroup)
               
          }else{
          
               emojiGroupData.append(self.defaultSystemEmojiGroup)
               emojiGroupData.append(self.mtmEmojiGroup)
               emojiGroupData.append(self.simaoEmojiGroup)
               emojiGroupData.append(self.xzmmEmojiGroup)
               emojiGroupData.append(self.ybbEmojiGroup)
          }
          
          
          complete!(emojiGroupData)
        }
    }
    
    func stringFromImage(image: UIImage) -> String {
        let face = self.getAllImagePaths()
        let imageD = image.pngData()
        var imageName = ""
        for faceDic in face {
            if let dic = faceDic as? Dictionary<String, Any> {
               if let image = UIImage.init(named: dic["credentialName"] as? String ?? "" ){
                    let data = image.pngData()
                    if imageD == data{
                        if let nameString = dic["credentialName"] as? String{
                            imageName = nameString
                        }
                    }
                }
            }
        }
        
        return imageName
    }
    
    func getAllImagePaths() -> Array<Any>{
        let path = Bundle.main.path(forResource: "CODEmoji", ofType: "json")
//        let face = NSArray.init(contentsOfFile: path!)
        let data = NSData(contentsOfFile: path!)
        let peoplesArray = try! JSONSerialization.jsonObject(with:data! as Data, options: JSONSerialization.ReadingOptions()) as? [AnyObject]

        return peoplesArray ?? []

    }
}
