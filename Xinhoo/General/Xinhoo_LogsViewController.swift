//
//  Xinhoo_LogsViewController.swift
//  COD
//
//  Created by xinhooo on 2020/1/3.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import DoraemonKit

class Xinhoo_LogsViewController: DoraemonBaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var listView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "日志平台"
        self.listView.rowHeight = UITableView.automaticDimension
        self.listView.estimatedRowHeight = 50
        self.listView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "logCell")
        // Do any additional setup after loading the view.
//        self.rightTextButton.setTitle(NSLocalizedString("复制", comment: ""), for: .normal)
//        self.rightTextButton.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: .normal)
//        self.rightTextButton.setImage(nil, for: .normal)
//        self.setRightTextButton()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("复制", comment: ""), style: .plain, target: self, action: #selector(navRightTextClick))
        

    }

    @objc func navRightTextClick() {
        
        var logs = ""
        for log in XinhooTool.xinhoo_Logs {
            logs = logs + log + "\n"
        }
        let pastboard = UIPasteboard.general
        pastboard.string = logs
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return XinhooTool.xinhoo_Logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let log = XinhooTool.xinhoo_Logs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath)
        cell.textLabel?.text = log
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
