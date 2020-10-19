//
//  CODFileHelper.swift
//  COD
//
//  Created by 1 on 2019/5/22.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import MobileCoreServices
enum CODFileType {
    case PdfType ///pdf
    case WordType ///word
    case ZipType ///文件zip
    case ExcelType //Excel
    case ImageType //图片
    case VideoType // 视频
    case UnKnowType ///未知类型
}
class CODFileHelper: NSObject {
    
    
    
    class func getFileType(fileName:String) -> CODFileType{
        let mimetypeStr = fileName.pathExtension.lowercased()
        
        switch mimetypeStr {
        case "pdf":
            return CODFileType.PdfType
        case "word":
            return CODFileType.WordType
        case "zip":
            return CODFileType.ZipType
        case "xlsx":
            return CODFileType.ExcelType
        case "gif", "jpeg", "jpg", "bmp", "png","jfif","tif","pcx","tga","exif","fpx","svg","cdr","pcd","dxf","ufo","eps","ai","raw","WMF","webp", "heic":
            return CODFileType.ImageType
        case "wmv", "asf", "asx", "rm", "rmvb", "mp4", "3pg", "mov", "m4v", "avi", "dat", "mkv", "flv", "vob":
            return CODFileType.VideoType
        default:
            return CODFileType.UnKnowType
        }

    }
    
    class func getFileSizeByPath(filePath:String) -> String {
        
        let fileSize = self.fileSizeAtPath(filePath: filePath)
        
        return self.getFileSize(fileSize: CGFloat(fileSize))
    }
    
    class func fileSizeAtPath(filePath:String) -> Float {
        let manager = FileManager.init()
        var fileSize:Float = 0.0
        if manager.fileExists(atPath: filePath) {
            do {
                
                let attr = try manager.attributesOfItem(atPath: filePath)
                fileSize = attr[.size] as! Float

            } catch {
            }
        }
        return fileSize;
    }

    //获取文件大小
    class func getFileSize(fileSize: CGFloat) -> String{
//        if(fileSize < 1000){
//            return String(format:"%.0f",fileSize) + "字节"
//        }else if(fileSize < 1000 * 1000){
//            let bytes:CGFloat = CGFloat(fileSize / 1024.00)
//            return String(format:"%.0f",bytes) + "KB"
//        }else if(fileSize >= 1000 * 1000 && fileSize < 1024 * 1024 * 1024.00){
//            let bytes:CGFloat = CGFloat(fileSize / 1024)
//            return String(format:"%.0f",bytes) + "MB"
//        }else{
//            let bytes:CGFloat = CGFloat(fileSize / (1024 * 1024 * 1024.00))
//            return String(format:"%.0f",bytes) + "GB"
//        }
        
        if fileSize > 1000*1000 {
            return String.init(format:"%.2fM",fileSize/1024.0/1024.0)
        }else if fileSize > 1000.0{
            return String.init(format:"%.0fKB",fileSize/1024)
        }else{
            return String(format:"%.0f",fileSize) + "B"
        }
    }
    
    //获取文件大小
    class func getFileSizeAndFileText(fileSize:CGFloat) -> (fileSize:CGFloat, fileText:String){
        var newSize: CGFloat = 0
        var fileText: String = ""
                if(fileSize < 1024){
                    newSize = fileSize
                    fileText = "字节"
//                    return String(format:"%.0f",fileSize) + "字节"
                }else if(fileSize < 1024 * 1024){
                    let bytes:CGFloat = CGFloat(fileSize / 1024.00)
                    newSize = bytes
                    fileText = "KB"
//                    return String(format:"%.0f",bytes) + "KB"
                }else if(fileSize >= 1024 * 1024 && fileSize < 1024 * 1024 * 1024.00){
                    let bytes:CGFloat = CGFloat(fileSize / (1024 * 1024.00))
                    newSize = bytes
                    fileText = "MB"
//                    return String(format:"%.0f",bytes) + "MB"
                }else{
                    let bytes:CGFloat = CGFloat(fileSize / (1024 * 1024 * 1024.00))
                    newSize = bytes
                    fileText = "GB"
//                    return String(format:"%.0f",bytes) + "GB"
                }
        return (newSize,fileText)
    }
}
