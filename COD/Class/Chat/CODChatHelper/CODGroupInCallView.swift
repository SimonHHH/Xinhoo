//
//  CODGroupInCallView.swift
//  COD
//
//  Created by 1 on 2020/9/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
protocol CODGroupInCallViewDelegate:NSObjectProtocol
{
    func inCallClick()
}
class CODGroupInCallView: UIView {

    weak var delegate:CODGroupInCallViewDelegate?

    private lazy var textLabel:UILabel = {
        let textLabel = UILabel(frame: CGRect.zero)
        textLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 15)
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 1
        textLabel.text = NSLocalizedString("正在多人语音通话", comment: "")
        return textLabel;
    }()
    
    private lazy var callImage:UIImageView = {
        let callImage = UIImageView.init()
        callImage.contentMode = .scaleAspectFill
        callImage.image = UIImage.init(named: "voice_calls")
        return callImage;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    
        self.addTap { [weak self] in

            guard let `self` = self else {
                return
            }
            
            if self.delegate != nil {
                self.delegate?.inCallClick()
            }
        }
    
        self.backgroundColor = UIColor(red: 0, green: 0.49, blue: 0.9, alpha: 1)
        self.setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView() {
        
        self.addSubviews([self.callImage,self.textLabel])
        
        callImage.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.callImage.snp.right).offset(10)
            make.right.equalTo(self).offset(-10)
            make.centerY.equalToSuperview()
        }
    }

}
