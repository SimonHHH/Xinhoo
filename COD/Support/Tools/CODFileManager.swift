//
//  CODFileManager.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
/// 这个是文件的管理 注意进来的时候要先判断当前用户的文件是否创建了 没有创建要创建
//1.每个用户有一个文件夹(里面包含多个会话文件夹)
//2.每一个会话有一个文件（图片、语音、视频等等）
//3.其他的文件夹暂时不用管理
class CODFileManager: NSObject {
    
    static let fileManger:CODFileManager = CODFileManager()
    class func shareInstanceManger() -> CODFileManager{
        return fileManger
    }
//    private let USER_NAME:String = UserManager.sharedInstance.loginName ?? "user"
    ///注意每次进来的时候要清空
    var documentPath:String? = nil
    //每次进入新的会话重置会话文件
    var eMConversationFilePath:String? = nil
    ///会话图片文件
    var conversationImagesPath:String? = nil
    ///会话音频文件
    var conversationVoicesPath:String? = nil
    ///会话视频文件
    var conversationVideosPath:String? = nil
    ///文件
    var conversationFilesPath:String? = nil
    ///个人信息 上次头像
    var personDetailPath:String? = nil
    /// 每次登录成功的时候调用
    ///
    /// - Returns: 整个用户的缓存文件
    func pathUserPath() -> String{
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documnetPath = documentPaths[0]
        var userDocumnetPath = documnetPath + "/" + UserManager.sharedInstance.loginName!
        //判断是否有文件存在
        if(!FileManager.default.fileExists(atPath: userDocumnetPath)){
            do{
                try FileManager.default.createDirectory(atPath: userDocumnetPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                CCLog("创建用户文件失败!")
                userDocumnetPath = ""
            }
        }
        self.documentPath = userDocumnetPath
        return self.documentPath!
    }
    
    func getPersonFilePath(userPath: String,fileName:String,formatString: String) -> String {
        
        if userPath.count == 0 {
            return ""
        }
        if self.documentPath == nil {
            self.documentPath = self.pathUserPath()
        }
        var personDetailPath = self.documentPath! + "/personDetail" + "/" + userPath
        //判断是否有文件存在
        if(!FileManager.default.fileExists(atPath: personDetailPath)){
            do{
                try FileManager.default.createDirectory(atPath: personDetailPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                CCLog("创建personDetail文件失败!")
                personDetailPath = ""
            }
        }
        return personDetailPath + "/" + fileName + formatString
    }
    
    func getGroupFilePath(userPath: String,fileName:String,formatString: String) -> String {
        
        if userPath.count == 0 {
            return ""
        }
        if self.documentPath == nil {
            self.documentPath = self.pathUserPath()
        }
        var groupDetailPath = self.documentPath! + "/groupChat" + "/" + userPath
        //判断是否有文件存在
        if(!FileManager.default.fileExists(atPath: groupDetailPath)){
            do{
                try FileManager.default.createDirectory(atPath: groupDetailPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                CCLog("创建groupChat文件失败!")
                groupDetailPath = ""
            }
        }
        return groupDetailPath + "/" + fileName + formatString
    }
    
    
    /// 删除（每个会话的文件夹）
    ///
    /// - Parameter sessionID: 会话id
    /// 移除
    func getEMConversationFilePath(sessionID:String){
        if sessionID.removeAllSapce.count == 0 {
            return
        }
        if self.documentPath == nil {
            self.documentPath = self.pathUserPath()
        }
        var conversationPath = self.documentPath! + "/message" + "/" + sessionID
        //判断是否有文件存在
        if(!FileManager.default.fileExists(atPath: conversationPath)){
            do{
                try FileManager.default.createDirectory(atPath: conversationPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                CCLog("创建会话文件失败!")
                conversationPath = ""
            }
        }
        self.eMConversationFilePath = conversationPath
        ///初始化文件
        self.initializationEMConversationFilePath()
    }
    
    func  deleteEMConversationFilePath(sessionID:String){
        if sessionID.removeAllSapce.count == 0 {
            return
        }
        if self.documentPath == nil {
            self.documentPath = self.pathUserPath()
        }
        var conversationPath = self.documentPath! + "/message" + "/" + sessionID
        //判断是否有文件存在
        if(FileManager.default.fileExists(atPath: conversationPath)){
            
            do{
                try FileManager.default.removeItem(atPath: conversationPath)
            }catch{
                CCLog("删除groupChat文件失败!")
                conversationPath = ""
            }
        }
    }
    
    func  deleteEMConversationFilePathWithFilesAndImagesAndVideos(sessionID:String){
        if sessionID.removeAllSapce.count == 0 {
            return
        }
        if self.documentPath == nil {
            self.documentPath = self.pathUserPath()
        }
        var conversationPath_Files = self.documentPath! + "/message" + "/" + sessionID + "/Files"
        var conversationPath_Images = self.documentPath! + "/message" + "/" + sessionID + "/Images"
        var conversationPath_Videos = self.documentPath! + "/message" + "/" + sessionID + "/Videos"
        //判断是否有文件存在
        if(FileManager.default.fileExists(atPath: conversationPath_Files)){
            
            do{
                try FileManager.default.removeItem(atPath: conversationPath_Files)
            }catch{
                CCLog("删除groupChat文件失败!")
                conversationPath_Files = ""
            }
        }
        
        if(FileManager.default.fileExists(atPath: conversationPath_Images)){
            
            do{
                try FileManager.default.removeItem(atPath: conversationPath_Images)
            }catch{
                CCLog("删除groupChat文件失败!")
                conversationPath_Images = ""
            }
        }
        
        if(FileManager.default.fileExists(atPath: conversationPath_Videos)){
            
            do{
                try FileManager.default.removeItem(atPath: conversationPath_Videos)
            }catch{
                CCLog("删除groupChat文件失败!")
                conversationPath_Videos = ""
            }
        }
    }
    
    
    func  deleteEMConversationAllFilePath(){

        if self.documentPath == nil {
            self.documentPath = self.pathUserPath()
        }
        var conversationPath = self.documentPath! + "/message"
        //判断是否有文件存在
        if(FileManager.default.fileExists(atPath: conversationPath)){
            
            do{
                try FileManager.default.removeItem(atPath: conversationPath)
            }catch{
                CCLog("删除groupChat文件失败!")
                conversationPath = ""
            }
        }
    }
    
    func getMessageCachePath() -> String {
        if self.documentPath == nil {
            self.documentPath = self.pathUserPath()
        }
        var conversationPath = self.documentPath! + "/message"
        return conversationPath
    }
    
    func initializationEMConversationFilePath() {
        if self.eMConversationFilePath != nil {
            //1.判断图片存储文件是否创建
            var imagePath = self.eMConversationFilePath! + "/Images"
            if(!FileManager.default.fileExists(atPath: imagePath)){
                do{
                    try FileManager.default.createDirectory(atPath: imagePath, withIntermediateDirectories: true, attributes: nil)
                }catch{
                    CCLog("创建会话图片文件失败!")
                    imagePath = ""
                }
            }
            self.conversationImagesPath = imagePath
            //2.判断语音存储文件是否创建
            var voicesPath = self.eMConversationFilePath! + "/Voices"
            if(!FileManager.default.fileExists(atPath: voicesPath)){
                do{
                    try FileManager.default.createDirectory(atPath: voicesPath, withIntermediateDirectories: true, attributes: nil)
                }catch{
                    CCLog("创建会话语音文件失败!")
                    voicesPath = ""
                }
            }
            self.conversationVoicesPath = voicesPath
            
            ///3.判断会话的视频文件是否创建
            let VideosPath = self.eMConversationFilePath! + "/Videos"
            if(!FileManager.default.fileExists(atPath: VideosPath)){
                do{
                    try FileManager.default.createDirectory(atPath: VideosPath, withIntermediateDirectories: true, attributes: nil)
                }catch{
                    CCLog("创建会话视频文件失败!")
                }
            }
            self.conversationVideosPath = VideosPath
            //2.判断文件路径是否创建
            var filesPath = self.eMConversationFilePath! + "/Files"
            if(!FileManager.default.fileExists(atPath: filesPath)){
                do{
                    try FileManager.default.createDirectory(atPath: filesPath, withIntermediateDirectories: true, attributes: nil)
                }catch{
                    CCLog("创建会话文件失败!")
                    voicesPath = ""
                }
            }
            self.conversationFilesPath = filesPath
        }
    }
    /// 保存会话的图片
    ///
    /// - Parameters:
    ///   - imageData: 保存图片数据
    ///   - imageName: 保存图片名字
    ///   - eMConversation: 会话
    /// - Returns: 已经保存的名字
    //    func saveConversationImages(imageData:Data,imageName:String,eMConversation:EMConversation) -> String {
    //        if self.conversationImagesPath == nil {
    //            self.getEMConversationFilePath(eMConversation: eMConversation)
    //        }
    //        let saveImagePath = self.conversationImagesPath! + "/" + imageName
    //        if  !FileManager.default.fileExists(atPath: saveImagePath) {///已经有数据 不要重复添加
    //            FileManager.default.createFile(atPath: saveImagePath, contents: imageData, attributes: nil)
    //        }
    //        return saveImagePath
    //    }
    
    //录音文件临时路径dat(录音临时文件)
    func temporaryDatPathWithName() -> String{
        let temporaryDatPath = self.conversationVideosPath! + "/" + "temporary.dat"
        if FileManager.default.fileExists(atPath: temporaryDatPath) {
            FileManager.default.isDeletableFile(atPath: temporaryDatPath)
        }
        return temporaryDatPath
    }
    
    //录音文件临时路径MP3(转码生成的MP3文件)
    func temporaryMp3PathWithName() -> String{
        let temporaryMp3Path = self.conversationVoicesPath! + "/" + "audioFileSavePath.mp3"
        if FileManager.default.fileExists(atPath: temporaryMp3Path) {
            FileManager.default.isDeletableFile(atPath: temporaryMp3Path)
        }
        return temporaryMp3Path
    }
    /// 生成语音文件路径
    ///
    /// - Returns: 文件路径
    func imagePathWithName(fileName:String) -> String {
        if self.conversationImagesPath == nil {
            return ""
        }
        let mp3PathName = self.conversationImagesPath!  + "/" + fileName + ".png"
        return mp3PathName
    }
    
    /// 生成语音文件路径
    ///
    /// - Returns: 文件路径
    func mp3PathWithName(fileName:String) -> String {
        if self.conversationVoicesPath == nil {
            return ""
        }
        let mp3PathName = (self.conversationVoicesPath ?? "")  + "/" + fileName + ".mp3"
        return mp3PathName
    }
    
    /// 生成视频文件路径
    ///
    /// - Returns: 文件路径
    func mp4PathWithName(fileName:String) -> String {
        if self.conversationVideosPath == nil {
            return ""
        }
        let mp3PathName = self.conversationVideosPath!  + "/" + fileName + ".mp4"
        return mp3PathName
    }
    
    /// 生成视频文件路径
    ///
    /// - Returns: 文件路径
    func mp4TempPathWithName(fileName:String) -> String {
        if self.conversationVideosPath == nil {
            return ""
        }
        let mp3PathName = self.conversationVideosPath!  + "/" + fileName + "_temp" + ".mp4"
        return mp3PathName
    }
    
    /// 生成视频文件路径
    ///
    /// - Returns: 文件路径
    func mp4PathWithName(sessionID: String, fileName:String) -> String {

        
        let conversationPath = self.documentPath! + "/message" + "/" + sessionID + "/Videos"
        
        initPath(path: conversationPath)

        let mp4PathName = conversationPath  + "/" + fileName + ".mp4"
        
        return mp4PathName
    }
    /// 生成音频文件路径
    ///
    /// - Returns: 文件路径
    func mp3PathWithName(sessionID: String, fileName:String) -> String {

        
        let conversationPath = self.documentPath! + "/message" + "/" + sessionID + "/Voices"
        
        initPath(path: conversationPath)

        let mp4PathName = conversationPath  + "/" + fileName + ".mp3"
        
        return mp4PathName
    }
    /// 生成图片文件路径
    ///
    /// - Returns: 文件路径
    func imagePathWithName(sessionID: String, fileName:String) -> String {

        
        let conversationPath = self.documentPath! + "/message" + "/" + sessionID + "/Images"
        
        initPath(path: conversationPath)

        let imagePathName = conversationPath  + "/" + fileName + ".png"
        
        return imagePathName
    }
    
    /// 生成图片文件路径
    ///
    /// - Returns: 文件路径
    func filePathWithName(sessionID: String, fileName:String) -> String {

        
        let conversationPath = self.documentPath! + "/message" + "/" + sessionID + "/Files"
        
        initPath(path: conversationPath)

        let imagePathName = conversationPath  + "/" + fileName
        
        return imagePathName
    }
    func initPath(path: String) {
        
        //判断是否有文件存在
        if(!FileManager.default.fileExists(atPath: path)){
            do{
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }catch{
                CCLog("创建用户文件失败!")
            }
        }
        
    }
    
    /// 生成视频文件路径
    ///
    /// - Returns: 文件路径
    func filePathWithName(fileName:String) -> String {
        if self.conversationFilesPath == nil {
            return ""
        }
        let filePathName = self.conversationFilesPath!  + "/" + fileName
        return filePathName
    }
    
    func fileSize(filePath:String) -> Double {
        
        do {
            let dict = try FileManager.default.attributesOfItem(atPath: filePath)
            return dict[FileAttributeKey.size] as! Double
        }catch{
            return 0
        }
    }
    
//    
//    func deleteFileFromJID(<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }
}
