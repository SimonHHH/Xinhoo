//
//  CODChatAidToolView.swift
//  COD
//
//  Created by 1 on 2019/8/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
protocol CODChatAidToolViewDelegate:class {
    
    func searchClick()
    
    func donotdisturClick(button: UIButton)
    
    func callClick()
    
    func aboutClick()
}
class CODChatAidToolView: UIView {
    weak var delegate: CODChatAidToolViewDelegate?

    lazy var searchBtn: CODCustomButton = {
        let btn = CODCustomButton.init(type: .custom)
        btn.setTitle("搜索", for: UIControl.State.normal)
        btn.setImage(UIImage.init(named: "search_aid_tool"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
        btn.setTitleColor(UIColor.init(hexString: "#0C7EE6"), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(searchAction), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var donotdisturbBtn: CODCustomButton = {
        let btn = CODCustomButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "donotdisturb_aid_tool"), for: .normal)
        btn.setImage(UIImage.init(named: "turn_off_donotdisturb"), for: .selected)
        btn.setTitle("关闭通知", for: UIControl.State.normal)
        btn.setTitle("开启通知", for: UIControl.State.selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
        btn.setTitleColor(UIColor.init(hexString: "#0C7EE6"), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(donotdisturAction(button:)), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var callBtn: CODCustomButton = {
        let btn = CODCustomButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "call_aid_tool"), for: .normal)
        btn.setTitle("呼叫", for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
        btn.setTitleColor(UIColor.init(hexString: "#0C7EE6"), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(callAction), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var aboutBtn: CODCustomButton = {
        let btn = CODCustomButton.init(type: .custom)
        btn.setTitle("联系人信息", for: UIControl.State.normal)
        btn.setImage(UIImage.init(named: "about_aid_tool"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
        btn.setTitleColor(UIColor.init(hexString: "#0C7EE6"), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(aboutAction), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    init(frame: CGRect,isGroupChat: Bool,isDisturb: Bool) {
        super.init(frame: frame)
        self.initUI(isGroupChat: isGroupChat, isDisturb: isDisturb)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(isGroupChat: Bool,isDisturb: Bool) {
        var viewArray: Array<UIView> = []
        
        self.donotdisturbBtn.isSelected = isDisturb

        if isGroupChat {
            viewArray = [self.searchBtn,self.donotdisturbBtn,self.aboutBtn]
        }else{
            viewArray = [self.searchBtn,self.donotdisturbBtn,self.callBtn,self.aboutBtn]
        }
        self.addSubviews(viewArray)
        let buttonWidth = KScreenWidth / CGFloat(viewArray.count)
//        var buttonX: CGFloat = 0
//        for button in viewArray {
//            self.addSubview(button)
//            button.snp.makeConstraints { (make) in
//                make.left.equalTo(self).offset(buttonX)
//                make.width.equalTo(buttonWidth)
//                make.top.bottom.equalTo(self)
//            }
////            button.frame = CGRect(x: buttonX, y: 0, width: buttonWidth, height: self.frame.size.height)
////            button.backgroundColor = UIColor.gray
//            buttonX = buttonX + buttonWidth
//        }
        
      
        self.searchBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.top.bottom.equalTo(self)
            make.width.equalTo(buttonWidth)
        }
        self.donotdisturbBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.width.equalTo(buttonWidth)
            if isGroupChat {
                make.centerX.equalTo(self)
            }else{
                make.centerX.equalTo(self).offset(-buttonWidth/2)
            }
        }
        if !isGroupChat{
            self.callBtn.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(self)
                make.width.equalTo(buttonWidth)
                make.centerX.equalTo(self).offset(buttonWidth/2)
            }
        }
        
        self.aboutBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.width.equalTo(buttonWidth)
            make.right.equalTo(self.right)
        }
      
    }

}

extension CODChatAidToolView{
    @objc func searchAction() {
        if self.delegate != nil {
            self.delegate?.searchClick()
        }
    }
    @objc func donotdisturAction(button :CODCustomButton) {
        button.isSelected = !button.isSelected
        if self.delegate != nil {
            self.delegate?.donotdisturClick(button: button)
        }
    }
    @objc func callAction() {
        if self.delegate != nil {
            self.delegate?.callClick()
        }
    }
    @objc func aboutAction() {
        if self.delegate != nil {
            self.delegate?.aboutClick()
        }
    }
}
