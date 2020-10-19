//
//  ChatMoreOptionsView.swift
//  COD
//
//  Created by XinHoo on 2019/2/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class ChatMoreOptionsView: UIView {
    
    typealias DisappearCloser = () -> ()
    var disappearCloser : DisappearCloser!
    
    typealias SelectRowCloser = (_ row : NSInteger) -> ()
    var selectRowCloser : SelectRowCloser!
    
    let titleArr = NSArray(array: [NSLocalizedString("新建群组", comment: ""), NSLocalizedString("添加联系人", comment: ""), NSLocalizedString("新建频道", comment: ""), NSLocalizedString("扫一扫",comment: "")])
    let imgArr = NSArray(array: ["group_chat","add_contact","create_channel","scan_scan"])
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.alpha = 0.0
        let bgImageView = UIImageView.init()
        guard let img = UIImage.init(named: "drop-down_list") else {
            return
        }
        let bubbleImage = img.resizableImage(withCapInsets: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), resizingMode: .stretch)
        bgImageView.image = bubbleImage
        self.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        self.tableView.layer.cornerRadius = 2.5
        self.tableView.clipsToBounds = true
        self.tableView.isScrollEnabled = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.bounces = false
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0.5)
            make.right.equalToSuperview().offset(-1)
            make.bottom.equalToSuperview().offset(-1)
            make.top.equalTo(self).offset(10.5)
        }
        tableView.register(CODChatMoreOptionsCell.self, forCellReuseIdentifier: "CODChatMoreOptionsCell")
    }
    
    lazy var tableView: UITableView = {

        let tv = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.separatorStyle = UITableViewCell.SeparatorStyle.none
        tv.delegate = self
        tv.dataSource = self
        tv.isScrollEnabled = false
        return tv
    }()
    
    lazy var backgroundView: ChatMoreOptionsBackgroundView = {
        let bg = ChatMoreOptionsBackgroundView(frame: UIScreen.main.bounds)
        bg.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(disappear))
        bg.addGestureRecognizer(tap)
        return bg
    }()
    
    func show(with superView: UIView?) {
        superView?.addSubview(backgroundView)
        superView?.addSubview(self)
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
    
    class func getWidth() -> CGFloat {
        let titleArr: Array<String> = NSArray(array: [NSLocalizedString("新建群组", comment: ""), NSLocalizedString("添加联系人", comment: ""), NSLocalizedString("新建频道", comment: ""), NSLocalizedString("扫一扫",comment: "")]) as! Array<String>
        var maxWidth: CGFloat = 0.0
        for title in titleArr {
            let size = title.getLabelStringSize(font: UIFont(name: "PingFang SC", size: 15)!, lineSpacing: 0.0, fixedWidth: KScreenWidth)
            if size.width > maxWidth {
                maxWidth = size.width
            }
        }
        return maxWidth + 70
    }
    
    class func getHeight() -> CGFloat {
        let cellHeight: CGFloat = 4.0 * 44.0
        return cellHeight + 10.5 + 1.0
    }
    
}

extension ChatMoreOptionsView :UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectRowCloser(indexPath.row)
        
        self.removeFromSuperview()
        self.backgroundView.removeFromSuperview()
    }

}

extension ChatMoreOptionsView :UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CODChatMoreOptionsCell? = tableView.dequeueReusableCell(withIdentifier: "CODChatMoreOptionsCell") as? CODChatMoreOptionsCell
        cell?.selectionStyle = UITableViewCell.SelectionStyle.gray
        cell?.title = self.titleArr[indexPath.row] as? String
        cell?.iconImage = UIImage(named: self.imgArr[indexPath.row] as! String)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}



class ChatMoreOptionsBackgroundView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
