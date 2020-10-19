//
//  CODGotoBottomView.swift
//  COD
//
//  Created by xinhooo on 2019/7/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGotoBottomView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    typealias ClickBlock = () -> Void
    var click:ClickBlock?
    
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLab: UILabel!
    @IBOutlet weak var btn: UIButton!

    
    func setBtnImage(image:UIImage) {
        self.btn.setImage(image, for: .normal)
    }
    
    func setCount(count:Int) {

        
        if count > 999 {
            self.countLab.text = "999+"
        } else {
            self.countLab.text = "\(count)"
        }
        

        self.countView.isHidden = (count == 0)
    }
    
    @IBAction func clickAction(_ sender: Any) {
        if self.click != nil {
            self.click!()
        }
    }
}
