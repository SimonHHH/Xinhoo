//
//  CODVoiceCallView.swift
//  COD
//
//  Created by 1 on 2019/3/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
enum CODVoiceCallViewType {
    case   waitingAcceptance  //等待对方接受
    case   requestCall        //请求通话
    case   inCall             //通话中

}

class CODVoiceCallView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    
    private lazy var iconImageView: UIImageView = {
        let iconv = UIImageView.init(image: UIImage.init(named: "default_header_110"))
        iconv.contentMode = .scaleAspectFit
        return iconv
    }()
    
    
    
    private lazy var nameLb: UILabel = {
        let lab = UILabel()
        lab.textAlignment = NSTextAlignment.center
        lab.font = UIFont.systemFont(ofSize: 30)
        lab.textColor = UIColor.white
        return lab
    }()
    
    private lazy var stateLb: UILabel = {
        let lab = UILabel()
        lab.textAlignment = NSTextAlignment.center
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor.white
        return lab
    }()
    private lazy var rangOffBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.CODButtonImageTitle(style: .top, titleImgSpace: 0)
        return btn
    }()
}

private extension CODVoiceCallView {
    
}
