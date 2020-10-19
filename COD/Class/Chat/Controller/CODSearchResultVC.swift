//
//  CODSearchResultVC.swift
//  COD
//
//  Created by 1 on 2019/3/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSearchResultVC: BaseViewController {
    
    private  lazy var searchCtl:UISearchController = {
       let searchVC = UISearchController(searchResultsController: nil)
        searchVC.searchBar.placeholder = "搜索好友"
        //取掉上下两条黑线
        searchVC.searchBar.backgroundImage = UIImage()
        searchVC.dimsBackgroundDuringPresentation = false
        searchVC.hidesNavigationBarDuringPresentation = true
        searchVC.searchBar.frame = CGRect(x: 0, y: 0, width: kScreenWidth-100, height: 44)
        searchVC.searchBar.showsCancelButton = true

        return searchVC
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelBtn : UIButton = searchCtl.searchBar.value(forKey: "cancelButton") as! UIButton
        cancelBtn.setTitle("取消", for: UIControl.State.normal)
        cancelBtn.addTarget(self, action: #selector(cancelSearchVcActivity), for: UIControl.Event.touchUpInside)
//        self.searchCtl.searchBar.intrinsicContentSize = CGSize(width: 200, height: 40)
//        let bgView = UIView(frame: CGRect(x: 0.0, y: 64, width: Double(kScreenWidth), height:44+kSafeArea_Top))
//        bgView.backgroundColor = UIColor.black
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.isHidden = true
//        self.navigationItem.titleView = self.searchCtl.searchBar
        self.navigationItem.hidesBackButton = true
        self.definesPresentationContext = true
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchCtl
        } else {
            // Fallback on earlier versions
        }
//        self.automaticallyAdjustsScrollViewInsets = true
//        self.view.addSubview(bgView)
//        bgView.addSubview(searchCtl.searchBar)

    }
    
    @objc func cancelSearchVcActivity(sender : UIButton) {
        if self.searchCtl.isActive {
            self.searchCtl.isActive = false
            self.view.endEditing(true)
            self.searchCtl.searchBar.removeFromSuperview()
        }
        self.searchCtl.dismiss(animated: true) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
