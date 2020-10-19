//
//  CODViewerHeaderView.swift
//  COD
//
//  Created by XinHoo on 2020/3/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CODViewerHeaderView: UIView {
    
    enum SelectType: Int {
        case readed = 0
        case unread
    }
    
    typealias SegmentSelectIndex = (_ type: SelectType) -> (Void)
    var segmentSelectIndex: SegmentSelectIndex?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    func initUI() {
        self.addSubview(segmentCtl)
        self.addSubview(bottomLine)
        segmentCtl.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(90)
            make.trailing.equalToSuperview().offset(-90)
            make.height.equalTo(29)
        }
        segmentCtl.addTarget(self, action: #selector(segmentAction), for: UIControl.Event.valueChanged)
        segmentCtl.tintColor = UIColor(hexString: "4D9BF1")
        
        bottomLine.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    @objc func segmentAction(sender: UISegmentedControl) {
        if self.segmentSelectIndex != nil {
            self.segmentSelectIndex!(CODViewerHeaderView.SelectType.init(rawValue: sender.selectedSegmentIndex)!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewersCount(unreadCount :Int, readedCount :Int) {
        let str1 = String.init(format: NSLocalizedString("已读%@", comment: ""), "(\(readedCount))")
        let str2 = String.init(format: NSLocalizedString("未读%@", comment: ""), "(\(unreadCount))")
        self.segmentCtl.setTitle(str1, forSegmentAt: 0)
        self.segmentCtl.setTitle(str2, forSegmentAt: 1)
    }
    
    lazy var segmentCtl: UISegmentedControl = {
        let seg = UISegmentedControl.init()
        seg.segmentTitles = ["已读(0)", "未读(0)"]
        seg.selectedSegmentIndex = 0
        seg.isMomentary = false
        return seg
    }()
    
    lazy var bottomLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexString: kSepLineColorS)
        return v
    }()
    
}
