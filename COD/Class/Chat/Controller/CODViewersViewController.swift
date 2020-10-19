//
//  CODViewersViewController.swift
//  COD
//
//  Created by XinHoo on 2020/3/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODViewersViewController: BaseViewController {
    
    var message: CODMessageModel?
    
    var unReadDataSource = [CODCellModel]()
    var readedDataSource = [CODCellModel]()
    
    var currentDataSource = [CODCellModel]()
    var showType: CODViewerHeaderView.SelectType! {
        didSet {
            switch showType {
            case .readed:
                currentDataSource = readedDataSource
                break
            case .unread:
                currentDataSource = unReadDataSource
                break
            default:
                break
            }
            self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: UITableView.RowAnimation.fade)
            self.tableView.reloadEmptyDataSet()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        // Do any additional setup after loading the view.
        self.getDataSouce()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabShadowImageView()?.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initUI() {
        self.title = NSLocalizedString("消息接收人列表", comment: "")
        self.setBackButton()
        self.tabShadowImageView()?.isHidden = true
        
        self.view.addSubview(headerView)
        headerView.segmentSelectIndex = { [weak self] (type :CODViewerHeaderView.SelectType) in
            self?.showType = type
        }
        
        self.view.addSubview(tableView)
        tableView.register(UINib.init(nibName: "CODGroupMemberAdvTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupMemberAdvTableViewCell")
        
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(39)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    func getDataSouce() {

        CODProgressHUD.showWithStatus(nil)
        XMPPManager.shareXMPPManager.getRoomUnReadList(roomID: message?.roomId ?? 0, sendTime: message?.datetime ?? "", success: { [weak self] (result, nameStr) in
            guard let self = self else {
                return
            }
            if nameStr == "getRoomUnReadList" {
                if result.code == 0 {
                    CODProgressHUD.dismiss()
                    if let data = result.data as? Dictionary<String, Any> {
                        if let readList = data["readList"] as? Array<String>, readList.count > 0 {
                            self.readedDataSource = self.analysisDataList(list: readList)
                        }
                        if let unreadList = data["unReadList"] as? Array<String>, unreadList.count > 0 {
                            self.unReadDataSource = self.analysisDataList(list: unreadList)
                        }
                        self.headerView.setViewersCount(unreadCount: self.unReadDataSource.count, readedCount: self.readedDataSource.count)
                        self.showType = .readed
                        
                    }
                }else{
                    CODProgressHUD.showErrorWithStatus(result.msg)
                }
                
            }
            
        }) { (errorModel) in
            CODProgressHUD.showErrorWithStatus(errorModel.msg)
        }
        
    }
    
    lazy var tableView: UITableView = {
        let tv = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.separatorStyle = UITableViewCell.SeparatorStyle.none
        tv.estimatedRowHeight = 52.0
        tv.delegate = self
        tv.dataSource = self
        tv.emptyDataSetDelegate = self
        tv.emptyDataSetSource = self
        tv.isScrollEnabled = false
        return tv
    }()
    
    lazy var headerView: CODViewerHeaderView = {
        let v = CODViewerHeaderView()
        v.backgroundColor = UIColor(hexString: kNavBarBgColorS)
        return v
    }()
    
    func analysisDataList(list: Array<String>) -> [CODCellModel]! {
        var arrayT = [CODCellModel]()
        for jid in list {
            let memberId = CODGroupMemberModel.getMemberId(roomId: self.message?.roomId ?? 0, userName: jid)
            guard let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) else {
                continue
            }
            let memberName = memberModel.getMemberNickName()
            let memberIcon = memberModel.userpic
            var model = CODCellModel.init(iconName: memberIcon, title: memberName, type: CODCellType.memberType, tip: jid, pinYin: memberModel.pinYin)
            model.action.didSelected = {
                //预留点击事件
            }
            arrayT.append(model)
        }
        arrayT = self.sortCellModelArr(arrayT)
        return arrayT
    }
    
    func sortCellModelArr(_ array: Array<CODCellModel>) -> Array<CODCellModel> {
        var array = array.sorted(by: \.pinYin, ascending: true)
        var symbolCellArr = Array<CODCellModel>()
        for i in 0..<array.count {
            let member = array[i]
            var pinYin = member.pinYin
            let pinYinFirstStr = pinYin.slice(from: 0, to: 1)
            if pinYinFirstStr != "#" {
                break
            }
            symbolCellArr.append(member)
        }
        if symbolCellArr.count > 0 {
            array.removeSubrange(0..<symbolCellArr.count)
            symbolCellArr = symbolCellArr.sorted(by: \.title, ascending: true)
            array.append(contentsOf: symbolCellArr)
        }
        return array
    }
}

extension CODViewersViewController: UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if headerView.segmentCtl.selectedSegmentIndex == 0 {
            return readedDataSource.count
        }else{
            return unReadDataSource.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CODGroupMemberAdvTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CODGroupMemberAdvTableViewCell") as! CODGroupMemberAdvTableViewCell
        let model = currentDataSource[indexPath.row]
        cell.isLast = false
        cell.isTop = false
        cell.titleStr = model.title
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.iconName!) { (image) in
            cell.imgView.image = image
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        if self.readedDataSource.count <= 0 && self.showType == .readed {
            scrollView.emptyDataSetView { [weak self] (emptyDataSetView) in
                guard let self = self else { return }
                // 计算y轴全屏居中
                emptyDataSetView.y = KScreenHeight/2-(kSafeArea_Top+kNavBarHeight+self.headerView.height)-emptyDataSetView.height/2
            }
            return true
        }else{
            return false
        }
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSMutableAttributedString(string: NSLocalizedString("全部成员未读", comment: ""), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor(hexString: kSubTitleColors8E8E92)!])
        
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView()
//    }
}
