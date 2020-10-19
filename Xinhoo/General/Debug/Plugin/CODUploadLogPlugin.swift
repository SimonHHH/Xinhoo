//
//  CODUploadLog.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/9.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import DoraemonKit
import Social

class CODUploadLogPlugin: NSObject, DoraemonPluginProtocol {
    
    func pluginDidLoad() {
        
        CODProgressHUD.showWithStatus("日志收集中")
        
        DispatchQueue(label: "zip").async {
            
            
            
            DispatchQueue.main.async {
                
                
                

//                if MFMailComposeViewController.canSendMail() {
                    
                    DoraemonManager.shareInstance().hiddenHomeWindow()
                
                if let url = CODLoggerFileManger.default.zip() {
                    let documentController = UIDocumentInteractionController(url: url)
                    documentController.delegate = CODLoggerFileManger.default
                    documentController.presentPreview(animated: true)
                    
//                    UIViewController.rootViewControllerForKeyWindow().present(documentController, animated: true, completion: nil)
                }
                
                
//                
//                let activity = UIActivityViewController(activityItems: [], applicationActivities: [])
//                
//                activity.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
//                
                
                
//                if (popover) {
//                  popover.sourceView =
//                  popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
//                }
                    
//                    if let url = CODLoggerFileManger.default.zip(), let data = try? Data(contentsOf: url) {
//                        let mailVC = MFMailComposeViewController()
//                        mailVC.mailComposeDelegate = CODLoggerFileManger.default
//                        mailVC.addAttachmentData(data, mimeType: "application/zip", fileName: url.lastPathComponent)
//                        UIViewController.rootViewControllerForKeyWindow().present(mailVC, animated: true, completion: nil)
//                    }
//
//                }
                
                CODProgressHUD.dismiss()
                
                
                
            }
            
        }
        

    }
    

    
    
    


}
