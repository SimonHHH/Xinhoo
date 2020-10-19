//
//  CODCustomButton.swift
//  COD
//
//  Created by 1 on 2019/8/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODCustomButton: UIButton {
    let custom_button_titleLabel_height:CGFloat = 15
    let custom_button_title_color_normal = UIColor.red
    let custom_button_title_color_highlighted = UIColor.green
    let custom_button_titleLabel_font = UIFont.systemFont(ofSize: 10)  
    /**
     *  设置文字的frame
     **/
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleX : CGFloat = 0
        let titleY = contentRect.size.height - custom_button_titleLabel_height - 3
        let titleW = contentRect.size.width
        let titleH = custom_button_titleLabel_height
        return CGRect(x: titleX, y: titleY, width: titleW, height: titleH);
    }
    /**
     *  设置图标的frame
     **/
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageX : CGFloat = 0
        let imageY : CGFloat = 0
        let imageW = contentRect.size.width
        let imageH = contentRect.size.height - custom_button_titleLabel_height - 3
        return CGRect(x: imageX, y: imageY, width: imageW, height: imageH);
    }
   /**
    *   重写init方法
    **/
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupButtonSubViews()
    }
    /**
    *  实现init?(coder aDecoder: NSCoder)，required表示必须要实现的方法
     **/
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupButtonSubViews()
    }
     /**
     *    在setupButtonSubViews方法中，对图片、文字进行相关设置
     **/
    func setupButtonSubViews() {
        //        内部图片居中
        self.imageView?.contentMode = .center
        //        文字居中
        self.titleLabel?.textAlignment = .center
//        //        文字颜色-普通
//        self.setTitleColor(custom_button_title_color_normal, for: .normal)
//        //        文字颜色-高亮
//        self.setTitleColor(custom_button_title_color_highlighted, for: .highlighted)
        //        字体
        self.titleLabel?.font = custom_button_titleLabel_font
    }
}
