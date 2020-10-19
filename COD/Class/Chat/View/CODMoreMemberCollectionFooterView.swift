//
//  CODMoreMemberCollectionFooterView.swift
//  COD
//
//  Created by XinHoo on 2019/7/9.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODMoreMemberCollectionFooterView: UICollectionReusableView {
    
    typealias ShowMoreBlock = () -> Void
    
    var showMoreBlock: ShowMoreBlock? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(showMoreBtn)
        showMoreBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var showMoreBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.setTitle("查看更多群成员", for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        btn.setImage(UIImage(named: "next_step_icon"), for: UIControl.State.normal)
        btn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -17, bottom: 0, right: 0)
        btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 205, bottom: 0, right: 0)
        btn.setTitleColor(UIColor(hexString: kSubTitleColors), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(showMore), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    @objc func showMore() {
        if let showMoreBlock = showMoreBlock {
            showMoreBlock()
        }
    }
    
}
