//
//  CODTalkButton.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODTalkButton: UIView {
    
    var touchBegin:(() -> Void)?
    var touchMove:((_ cancel:Bool) -> Void)?
    var touchCancel:(() -> Void)?
    var touchEnd:(() -> Void)?
    
    var recordStatus:CODRecordBtnStatus = CODRecordBtnStatus.CODRecordInit{
        didSet{
            self.updateStatus()
        }
    }
    
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.text = "按住说话"
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    lazy var iconImageView:UIImageView = {
        let iconImageView = UIImageView(frame: CGRect.zero)
        iconImageView.isUserInteractionEnabled = true
        iconImageView.image = UIImage(named: "chat_record_recording")
        iconImageView.contentMode = .scaleAspectFit
        return iconImageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
        
        self.iconImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.iconImageView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func setTouchAction(touchBegin:@escaping (()->Void),touchMove:@escaping ((_ cancel:Bool)->Void),touchCancel:@escaping (()->Void),touchEnd:@escaping (()->Void)){
        self.touchBegin = touchBegin
        self.touchMove = touchMove
        self.touchCancel = touchCancel
        self.touchEnd = touchEnd
    }
    /// 按下
    ///
    /// - Parameters:
    ///   - touches: <#touches description#>
    ///   - event: <#event description#>
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touchBegin != nil{
            self.touchBegin!()
        }
    }
    
    /// 移动
    ///
    /// - Parameters:
    ///   - touches: <#touches description#>
    ///   - event: <#event description#>
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if self.touchMove != nil {
            let touch = ((touches as NSSet).anyObject() as AnyObject)     //进行类  型转化
            let curPoint = touch.location(in:self)     //获取当前点击位置
            let moveIn = curPoint.x >= 0 && curPoint.x <= RedImage_width && curPoint.y >= 0 && curPoint.y <= RedImage_width
            self.touchMove!(!moveIn)
        }
    }
    
    /// 结束
    ///
    /// - Parameters:
    ///   - touches: <#touches description#>
    ///   - event: <#event description#>
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.backgroundColor = UIColor.clear
        let touch = ((touches as NSSet).anyObject() as AnyObject)     //进行类  型转化
        let curPoint = touch.location(in:self)     //获取当前点击位置
        let moveIn = curPoint.x <= KScreenWidth && curPoint.y >= -30 && curPoint.y <= RedImage_width + kSafeArea_Bottom
        
        if self.touchEnd != nil && moveIn{///结束
            self.touchEnd!()
        }else if(!moveIn && self.touchCancel != nil){///移出范围内了就取消
            self.touchCancel!()
        }
    }
    
    /// 取消
    ///
    /// - Parameters:
    ///   - touches: <#touches description#>
    ///   - event: <#event description#>
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.backgroundColor = UIColor.clear
        if (self.touchCancel != nil){
            self.touchCancel!()
        }
    }
    func updateStatus() {
        
    }
}
