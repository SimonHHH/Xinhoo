//
//  CODMessageSearchResultView.swift
//  COD
//
//  Created by 1 on 2019/8/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
protocol CODMessageSearchResultViewDelegate:class {
    
    func nextPage(currentPage: Int)
    
    func previousPage(currentPage: Int)
    
    func dateAction()
    
    func groupMemberAction()
    
}
class CODMessageSearchResultView: UIView {
    
    weak var delegate: CODMessageSearchResultViewDelegate?

    var totalPage = 0 {
        didSet {
            if totalPage > 0{
                self.currentPage = 1
                self.dateBtn.isHidden = true
                self.pageLabel.isHidden = false
            }else{
                self.nextPageBtn.isEnabled = false
                self.previousPageBtn.isEnabled = false
                self.dateBtn.isHidden = false
                self.pageLabel.isHidden = true
            }
        }
    }
    
    var pageLabelString = "" {
        didSet {
            self.pageLabel.isHidden = false
            self.pageLabel.text = pageLabelString
        }
    }
    
    var currentPage = 0 {
        didSet {
            if totalPage  == 1  || currentPage == totalPage{
                self.previousPageBtn.isEnabled = false
            }else{
                self.previousPageBtn.isEnabled = true
            }
            if currentPage == 1 {
                self.nextPageBtn.isEnabled = false
            }else{
                self.nextPageBtn.isEnabled = true
            }
            self.pageLabel.text = String(format: "%ld / %ld", currentPage,totalPage)
        }
    }
    
    lazy var nextPageBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "nextPage_arrow_down"), for: .normal)
        btn.setImage(UIImage.init(named: "disabled_arrow_down"), for: .disabled)
        btn.contentMode = .center
        btn.addTarget(self, action: #selector(nextPageAction(button:)), for: UIControl.Event.touchUpInside)
        return btn
    }()

    lazy var previousPageBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "previouspage_arrow_up"), for: .normal)
        btn.setImage(UIImage.init(named: "disabled_arrow_up"), for: .disabled)
        btn.contentMode = .center
        btn.addTarget(self, action: #selector(previousPageAction(button:)), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor(hexString: "#020202")
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        return label
    }()
    
    lazy var dateBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "date_search"), for: .normal)
        btn.addTarget(self, action: #selector(dateAction), for: UIControl.Event.touchUpInside)
        btn.contentMode = .center
        return btn
    }()
    
    lazy var memberBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "groupMember_search"), for: .normal)
        btn.addTarget(self, action: #selector(groupMemberAction), for: UIControl.Event.touchUpInside)
        btn.contentMode = .center
        return btn
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        self.addSubviews([self.nextPageBtn,self.previousPageBtn,self.dateBtn,self.memberBtn,self.pageLabel])
        let buttonW = 44
        self.nextPageBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.width.height.equalTo(buttonW)
            make.centerY.equalTo(self)
        }
      
        self.previousPageBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.nextPageBtn.snp.right)
            make.height.width.equalTo(buttonW)
            make.top.equalTo(self.nextPageBtn)
        }
        
        self.dateBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-16)
            make.width.height.equalTo(32)
            make.centerY.equalTo(self)
        }
        
        self.memberBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.dateBtn.snp.left).offset(-27)
            make.width.height.equalTo(32)
            make.centerY.equalTo(self)
        }

        self.pageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.previousPageBtn.snp.right).offset(10)
            make.right.equalTo(self.dateBtn.snp.left).offset(-10)
            make.centerY.equalTo(self)
        }
    }

}

extension CODMessageSearchResultView{
    
    func dismiss() {
        
    }
}

extension CODMessageSearchResultView{
    
    @objc func nextPageAction(button: UIButton) {
       self.currentPage = self.currentPage - 1
        if self.delegate != nil {
            self.delegate?.nextPage(currentPage: currentPage)
        }
    }
    
    @objc func previousPageAction(button: UIButton) {
        self.currentPage = self.currentPage + 1
        if self.delegate != nil {
            self.delegate?.previousPage(currentPage: currentPage)
        }
    }
    
    @objc func dateAction() {
        if self.delegate != nil {
            self.delegate?.dateAction()
        }
    }
    @objc func groupMemberAction() {
        if self.delegate != nil {
            self.delegate?.groupMemberAction()
        }
    }
}
