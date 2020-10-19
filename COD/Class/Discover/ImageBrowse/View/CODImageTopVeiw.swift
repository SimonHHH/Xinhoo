//
//  CODImageTopVeiw.swift
//  COD
//
//  Created by 1 on 2020/5/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

@objcMembers
@objc class CODImageTopVeiw: UIView {
    
    var discoverModel: CODDiscoverMessageModel? {
        didSet{
            
        }
    }
    
    var isShowPage: Bool?
    
    @objc func setMessageMessageModel(messageModel:CODDiscoverMessageModel){
        self.isShowPage = (self.pageLabel.text?.removeAllSapce.count ?? 0 > 0 )
        self.timeLabel.snp.updateConstraints { (make) in
            make.height.equalTo((isShowPage ?? false ? 22 : 44))
        }
        self.pageLabel.isHidden = !(isShowPage ?? false)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        self.addSubviews([self.backBtn,self.moreBtn,self.timeLabel,self.pageLabel])
        self.backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(35)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
        
        self.moreBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.bottom.equalTo(self.backBtn)
            make.width.equalTo(37)
        }
        
        self.timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.backBtn.snp.right)
            make.top.equalTo(self.backBtn)
            make.height.equalTo(44)
            make.right.equalTo(self.moreBtn.snp.left)
        }
        
        self.pageLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.timeLabel)
            make.height.equalTo(14)
            make.top.equalTo(self.timeLabel.snp.bottom).offset(2)
        }
    }
    
    lazy var backBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "circle_image_back"), for: .normal)
        btn.imageView?.contentMode = .right
        return btn;
    }()
    
    lazy var timeLabel:UILabel = {
        let timeLb = UILabel(frame: CGRect.zero)
        timeLb.font = UIFont.systemFont(ofSize: 17)
        timeLb.textColor = UIColor.white
        timeLb.numberOfLines = 1
        timeLb.textAlignment = .center
        return timeLb;
    }()
    
    lazy var pageLabel:UILabel = {
        let pageLb = UILabel(frame: CGRect.zero)
        pageLb.font = UIFont.systemFont(ofSize: 10)
        pageLb.textColor = UIColor.white
        pageLb.numberOfLines = 1
        pageLb.textAlignment = .center
        return pageLb;
    }()
    
    lazy var moreBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "circle_image_more"), for: .normal)
        btn.imageView?.contentMode = .left
        return btn;
    }()
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if (CGRectContainsPoint(self.operationButton.frame, point)) {
//            return self.operationButton;
//        }
//        if (CGRectContainsPoint(self.cancelButton.frame, point)) {
//            return self.cancelButton;
//        }
//        return nil;
        if self.backBtn.frame.contains(point) {
            return self.backBtn
        }else if self.moreBtn.frame.contains(point) {
            return self.moreBtn
        }
        return nil
    }

}
