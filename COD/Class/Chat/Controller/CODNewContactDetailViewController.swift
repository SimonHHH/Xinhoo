//
//  CODNewContactDetailViewController.swift
//  COD
//
//  Created by XinHoo on 2019/6/14.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODNewContactDetailViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
        
        
    }
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
//        tv.delegate = self
//        tv.dataSource = self
        tv.isScrollEnabled = false
        tv.separatorStyle = UITableViewCell.SeparatorStyle.none
        return tv
    }()
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
