//
//  FavoriteViewController.swift
//  COD
//
//  Created by XinHoo on 2019/3/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import SwipeCellKit

class FavoriteViewController: BaseViewController,EmptyDataSetDelegate,EmptyDataSetSource{
    
    let searchCtl = UISearchController(searchResultsController: nil)
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("收藏", comment: "")
        self.setBackButton()
        
        //防止UISearchBar跳动或偏移
        self.definesPresentationContext = true
        self.edgesForExtendedLayout = UIRectEdge.left
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.initUI()
        
        let  dict:NSDictionary = ["name":COD_getFavorite,
                                  "requester":UserManager.sharedInstance.jid,
                                  "pageSize":"10",
                                  "pageNum":"1"]
        
        
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_favorite, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        
    }
    
    func initUI() {
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 56))
        bgView.addSubview(searchCtl.searchBar)
        searchCtl.searchBar.placeholder = "搜索用户"
        searchCtl.delegate = self
        self.tableView.tableHeaderView = bgView
        //取掉上下两条黑线
        searchCtl.searchBar.backgroundImage = UIImage()
        
        let searchBarTF = searchCtl.searchBar.customTextField
        searchBarTF?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
        searchBarTF?.font = UIFont.systemFont(ofSize: 17)
    }

    lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.emptyDataSetSource = self
        table.emptyDataSetDelegate = self
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        table.backgroundColor = UIColor.clear
        table.register(CODFavoriteCell.classForCoder(), forCellReuseIdentifier: "CODFavoriteCell")
        return table
    }()

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString.init(string: "没有任何收藏", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.init(hexString: kEmptyTitleColorS)!])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString.init(string: "可以在聊天界面长按消息来收藏", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor:UIColor.init(hexString: kMainTitleColorS)!])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        return UIImage.init(named: "no_collect_img")
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}

extension FavoriteViewController :UITableViewDelegate{

//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "删除") { (action, indexPath) in
//        }
//        deleteAction.backgroundColor = UIColor(hexString: kVCBgColorS)
//
//        let shareAction = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: "转发") { (action, indexPath) in
//        }
//        shareAction.backgroundColor = UIColor(hexString: kVCBgColorS)
//
//        return [shareAction, deleteAction]
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//
//    }
}

extension FavoriteViewController :UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CODFavoriteCell = tableView.dequeueReusableCell(withIdentifier: "CODFavoriteCell") as! SwipeTableViewCell as! CODFavoriteCell
        cell.delegate = self
        switch indexPath.row {
        case 0:
            cell.contentType = ContentType.text
        case 1:
            cell.contentType = ContentType.image
        default:
            cell.contentType = ContentType.location
        }
        
        return cell
    }
}

extension FavoriteViewController : UISearchControllerDelegate{
    
}

extension FavoriteViewController :SwipeTableViewCellDelegate{

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            print("123")
        }
        deleteAction.image = UIImage(named: "collect_delete_img")
        deleteAction.backgroundColor = UIColor(hexString: kVCBgColorS)
        
        
        let transmitAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            print("123")
        }
        transmitAction.image = UIImage(named: "collect_transmit_img")
        transmitAction.backgroundColor = UIColor(hexString: kVCBgColorS)
        
        return [deleteAction,transmitAction]
    }
    
}

extension FavoriteViewController : XMPPStreamDelegate{
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            if (actionDict["name"] as? String == COD_getFavorite){
                if !(infoDict["success"] as! Bool) {
                    return
                }
                
                print("收藏")
                
            }
            
        }
        
        return true
    }
    
}
