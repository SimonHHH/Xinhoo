//
//  CODRepairView.swift
//  COD
//
//  Created by xinhooo on 2020/7/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODRepairView: UIView {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var versionLab: UILabel!
    @IBOutlet weak var tipLab: UILabel!
    
    class func initRepairView() -> UIView{
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 200))
        
        let view = Bundle.main.loadNibNamed("CODRepairView", owner: self, options: nil)!.last as! CODRepairView
        view.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: 200)
        #if MANGO
        let img = UIImage(named: "mango_logo_gray")
        #elseif PRO
        let img = UIImage(named: "flygram_logo_gray")
        #else
        let img = UIImage(named: "xinhoo_logo_gray")
        #endif
        
        view.logoImageView.image = img
        
        if let infoDictionary = Bundle.main.infoDictionary {
            if let majorVersion = infoDictionary["CFBundleShortVersionString"] as? String{
                view.versionLab.text = "\(kApp_Name) \(majorVersion)"
            }
        }
         
        view.tipLab.text = NSLocalizedString("以下功能请在技术或客服团队指导下使用，修复过程中请确保网络正常", comment: "")
        
        backView.addSubview(view)
        
        return backView
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
