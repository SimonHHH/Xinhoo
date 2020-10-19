    //
    //  CODPreviewViewController.swift
    //  COD
    //
    //  Created by xinhooo on 2019/5/21.
    //  Copyright © 2019 XinHoo. All rights reserved.
    //

    import UIKit
    import QuickLook
    class CODPreviewViewController: QLPreviewController {

        var filePath = ""
        var fileName = ""
        var backDelegate:UIGestureRecognizerDelegate?
        
        lazy var backButton: UIButton = {
            var backbtn = UIButton.init(type: UIButton.ButtonType.custom)
            backbtn.frame  = CGRect(x: 0, y: 0, width: 50, height: 40)
            backbtn.setImage(UIImage(named: "button_nav_back"), for: UIControl.State.normal)
            backbtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            backbtn.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: -30.0, bottom: 0.0, right: 0.0)
            backbtn.addTarget(self, action: #selector(navBackClick), for: UIControl.Event.touchUpInside)
            return backbtn
        }()
        
        @objc func navBackClick() {
            self.navigationController?.popViewController(animated: true)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            self.dataSource = self
            self.setBackButton()
            self.setRightButton()
            self.navigationItem.hidesBackButton = true
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.backDelegate = self.navigationController?.interactivePopGestureRecognizer?.delegate
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self.backDelegate
        }
        
        func setBackButton() {
            //设置返回按钮
            let backBarButton = UIBarButtonItem.init(customView: self.backButton)
            self.navigationItem.leftBarButtonItem = backBarButton
        }

        func setRightButton() {
            let backBarButton = UIBarButtonItem.init(image: nil, style: .plain, target: nil, action: nil)
            self.navigationItem.rightBarButtonItem = backBarButton
        }
        
        deinit {
            print("文件预览页面已经销毁")
        }
        /*
        // MARK: - Navigation

        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        */

    }
    extension CODPreviewViewController:UIGestureRecognizerDelegate{

    }

    extension CODPreviewViewController:QLPreviewControllerDataSource{
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            
            //处理txt格式内容显示有乱码的情况
            if self.filePath.pathExtension == "txt" {
                
                let fileData = NSData.init(contentsOfFile: self.filePath)
                        
                //判断是UNICODE编码
                let isUNICODE = NSString.init(data: fileData! as Data, encoding: String.Encoding.utf8.rawValue)
                //还是ANSI编码（-2147483623，-2147482591，-2147482062，-2147481296）encoding 任选一个就可以了
        //        NSStringEncoding enc=CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        //
        //        NSString * contentStr=[NSString stringWithContentsOfFile:teachFilePath encoding:enc error:&error];
                let isANSI = NSString.init(data: fileData! as Data, encoding: 0x80000632)
                
                if isUNICODE != nil {

                    let retStr = NSString.init(cString: isUNICODE!.utf8String!, encoding: String.Encoding.utf8.rawValue)
                    let data = retStr?.data(using: String.Encoding.utf16.rawValue)
                    try! data?.write(to: URL.init(fileURLWithPath: self.filePath))
                    
                }else if (isANSI != nil) {

                    let data = isANSI?.data(using: String.Encoding.utf16.rawValue)
                    try! data?.write(to: URL.init(fileURLWithPath: self.filePath))
                }
                
            }
            
            
            let item = CODQLPreviewItem.init()
            item.previewItemURL = NSURL.init(fileURLWithPath: self.filePath) as URL
            item.previewItemTitle = self.fileName
            
            return item
        }
    }

    class CODQLPreviewItem: NSObject,QLPreviewItem {
        var previewItemURL: URL?
        var previewItemTitle: String?
    }
