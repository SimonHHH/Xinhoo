//
//  Xinhoo_ShowDateTimeView.swift
//  COD
//
//  Created by xinhooo on 2019/12/10.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class Xinhoo_ShowDateTimeView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var timeBtn:UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0.0
        self.addSubview(timeBtn)
        timeBtn.titleLabel?.font = UIFont.init(name: "PingFang-SC-Medium", size: 13)
        timeBtn.layer.masksToBounds = true
        timeBtn.setTitleColor(.white, for: .normal)
        timeBtn.setTitle("", for: .normal)
        timeBtn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 4, right: 10)
        timeBtn.layer.cornerRadius = 10
        timeBtn.backgroundColor = UIColor.init(hexString: "#555555")?.withAlphaComponent(0.5)
        timeBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTime(time:String) {
        timeBtn.setTitle(TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double(time))!/1000), format: NSLocalizedString("MM 月 dd 日", comment: "")), for: .normal)
    }
    
    func show() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        }
    }
}
