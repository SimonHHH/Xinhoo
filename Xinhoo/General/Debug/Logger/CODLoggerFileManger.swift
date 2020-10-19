//
//  CODLoggerFileManger.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SSZipArchive

class CODLoggerFileManger: NSObject, UIDocumentInteractionControllerDelegate {
    
    static let `default` = CODLoggerFileManger()
    
    let fileLogger: DDFileLogger = DDFileLogger() // File Logger
    
    func setup() {
                
        fileLogger.rollingFrequency = 60 * 60 * 24 * 7 // 7 days
        fileLogger.logFileManager.maximumNumberOfLogFiles = 70
        DDLog.add(fileLogger)

    }
    
    func zip() -> URL? {
        
        let zipPath = self.tempZipPath()
        
        let result = SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory: fileLogger.logFileManager.logsDirectory, keepParentDirectory: true, compressionLevel: -1, password: "Xinhoo1234", aes: false, progressHandler: nil)
        
        if result {
            return URL(fileURLWithPath: zipPath)
        }
        
        return nil
        
    }
    
    func tempZipPath() -> String {
        
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/\(UserManager.sharedInstance.loginName ?? "")-\(Date().toFormat("yyyy-mm-dd hh-MM-ss")).zip"
        return path
    }

    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
       return UIViewController.rootViewControllerForKeyWindow()
    }
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return UIViewController.rootViewControllerForKeyWindow().view
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return UIViewController.rootViewControllerForKeyWindow().view.bounds
    }
    
    
}
