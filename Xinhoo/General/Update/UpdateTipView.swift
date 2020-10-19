//
//  UpdateTipView.swift
//  COD
//
//  Created by xinhooo on 2020/4/9.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class UpdateTipView: UIView,CODPopupViewType {

    @IBOutlet weak var versionButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var ignoreBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    var versionDict: Dictionary<String, Any> = [:]
    
    func configView(versionDict:Dictionary<String, Any>) {
        
        self.versionButton.setTitle("v" + (versionDict["appVersion"] as? String ?? ""), for: .normal)
        self.contentTextView.text = versionDict["content"] as? String
        
        self.versionDict = versionDict
        
        self.ignoreBtn.setTitle(NSLocalizedString("忽略", comment: ""), for: .normal)
        self.updateBtn.setTitle(NSLocalizedString("立即更新", comment: ""), for: .normal)
    }
    
    @IBAction func ignoreAction(_ sender: Any) {
        let forcedUpdate = versionDict["forcedUpdate"] as! Bool
        if forcedUpdate {
            UIView.animate(withDuration: 1.0, animations: {
                self.window?.alpha = 0
            }, completion: { (completion) in
                exit(0)
            })
        }else{
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func updateNowAction(_ sender: Any) {
        
        #if MANGO || XINHOO
        if versionDict["outsiteUpdate"] as! Int == 0 {
            UIApplication.shared.open(NSURL.init(string: "itms-services://?action=download-manifest&url=\(versionDict["plistUrl"] as! String)")! as URL, options: [:]) { (b) in
                UIView.animate(withDuration: 1.0, animations: {
                    self.window?.alpha = 0
                }, completion: { (completion) in
                    exit(0)
                })
            }
        }else{
            UIApplication.shared.open(URL.init(string: versionDict["appUrl"] as! String)!, options: [:], completionHandler: { (b) in
                UIView.animate(withDuration: 1.0, animations: {
                    self.window?.alpha = 0
                }, completion: { (completion) in
                    exit(0)
                })
            })
        }
        
        #else
        if let url = URL(string: "https://apps.apple.com/cn/app/flygram/id1483902185") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        
        #endif
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
