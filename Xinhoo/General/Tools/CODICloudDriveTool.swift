//
//  CODICloudDriveTool.swift
//  COD
//
//  Created by XinHoo on 9/27/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit


class CODICloudDriveTool: NSObject, UIDocumentPickerDelegate {
    
    let fileTypes = ["public.data",
                     "public.text",
                     "public.source-code",
                     "public.image",
                     "public.movie",
                     "public.audiovisual-content",
                     "public.audio",
                     "com.adobe.pdf",
                     "com.apple.keynote.key",
                     "com.apple.package",
                     "com.microsoft.word.doc",
                     "com.microsoft.excel.xls",
                     "com.microsoft.powerpoint.ppt"]
    
    typealias DidPickFiles = (_ pickerVC: UIDocumentPickerViewController, _ urls: [URL]) -> Void
    var didPickFiles: DidPickFiles?
    
    var picker: UIDocumentPickerViewController!
    
    override init() {
        super.init()
        
        picker = UIDocumentPickerViewController(documentTypes: fileTypes, in: .open)
        picker.delegate = self
        if #available(iOS 11.0, *) {
            picker.allowsMultipleSelection = true
        }
        
    }
    
    func setDidPickBlock(didPickBlock: @escaping DidPickFiles) {
        self.didPickFiles = didPickBlock
    }

    
    func present() {
        UIViewController.current()?.present(self.picker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if self.didPickFiles != nil {
            self.didPickFiles!(controller, urls)
        }
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if self.didPickFiles != nil {
            self.didPickFiles!(controller, [url])
        }
    }
}

