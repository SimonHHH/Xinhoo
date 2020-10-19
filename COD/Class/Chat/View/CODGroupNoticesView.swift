//
//  CODGroupNoticesView.swift
//  COD
//
//  Created by 黄玺 on 2020/2/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODGroupNoticesView: UIView {
    
    typealias DisappearCloser = () -> ()
    var disappearCloser : DisappearCloser!
    
    typealias SelectRowCloser = (_ row : NSInteger) -> ()
    var selectRowCloser : SelectRowCloser!
    
    var titleStr: String!
    var contentStr: String!
    var cancelStr: String!
    
    var viewHeight: CGFloat! {
        didSet {
            self.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(KScreenWidth-80)
                make.height.equalTo(self.viewHeight)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.alpha = 0.0
        
        self.clipsToBounds = false
        self.tableView.layer.cornerRadius = 12
        self.tableView.clipsToBounds = true
        self.tableView.isScrollEnabled = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.bounces = false
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.register(nib: UINib.init(nibName: "CODGroupNoticesTitleCell", bundle: nil), withCellClass: CODGroupNoticesTitleCell.self)
        tableView.register(nib: UINib.init(nibName: "CODGroupNoticeContentCell", bundle: nil), withCellClass: CODGroupNoticeContentCell.self)
        tableView.register(nib: UINib.init(nibName: "CODGroupNoticesCancelCell", bundle: nil), withCellClass: CODGroupNoticesCancelCell.self)

    }
    
    lazy var tableView: UITableView = {

        let tv = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.separatorStyle = UITableViewCell.SeparatorStyle.none
        tv.estimatedRowHeight = 52.0
        tv.delegate = self
        tv.dataSource = self
        tv.isScrollEnabled = false
        return tv
    }()
    
    lazy var backgroundView: ChatMoreOptionsBackgroundView = {
        let bg = ChatMoreOptionsBackgroundView(frame: UIScreen.main.bounds)
        bg.backgroundColor = UIColor.black
        bg.alpha = 0.4
        bg.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(disappear))
        bg.addGestureRecognizer(tap)
        return bg
    }()
    
    func show(with superView: UIView?) {
        superView?.addSubview(backgroundView)
        superView?.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(KScreenWidth-80)
            make.height.equalTo(52+52+63)
        }
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    class func removeFrom(view: UIView) {
        let subViews = view.subviews
        for view in subViews {
            if view.isKind(of:self.self) {
                view.removeFromSuperview()
            }
            if view.isKind(of: ChatMoreOptionsBackgroundView.self) {
                view.removeFromSuperview()
            }
        }
    }
    
    @objc func disappear() {
        disappearCloser()
    }
    
    func removeAllFromSuperView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }) { (bool) in
            self.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
        }
    }
    
}

extension CODGroupNoticesView :UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectRowCloser(indexPath.row)
        
        self.removeAllFromSuperView()
    }

}

extension CODGroupNoticesView :UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: CODGroupNoticesTitleCell = tableView.dequeueReusableCell(withIdentifier: "CODGroupNoticesTitleCell") as! CODGroupNoticesTitleCell
            cell.titleStr = self.titleStr
            return cell
        case 1:
            let cell: CODGroupNoticeContentCell = tableView.dequeueReusableCell(withIdentifier: "CODGroupNoticeContentCell") as! CODGroupNoticeContentCell
            cell.contentStr = self.contentStr
            cell.selectionStyle = .none
            self.viewHeight = cell.getHeight()+52+63
            return cell
        case 2:
            let cell: CODGroupNoticesCancelCell = tableView.dequeueReusableCell(withIdentifier: "CODGroupNoticesCancelCell") as! CODGroupNoticesCancelCell
            cell.cancelStr = self.cancelStr
            return cell
        default:
            let cell:UITableViewCell = UITableViewCell.init()
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let cell: CODGroupNoticeContentCell = cell as? CODGroupNoticeContentCell {
//            cell.contentTextView.isScrollEnabled = true
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let cell: CODGroupNoticeContentCell = cell as? CODGroupNoticeContentCell {
//            cell.contentTextView.isScrollEnabled = true
//        }
//    }
    
}
