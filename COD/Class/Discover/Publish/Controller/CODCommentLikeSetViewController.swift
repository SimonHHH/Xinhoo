//
//  CODCommentLikeSetViewController.swift
//  COD
//
//  Created by xinhooo on 2020/6/2.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODCommentLikeSetViewController: BaseViewController {

    enum ViewType {
        case canCommentAndLike
        case visibleCommentAndLike
    }
    
    var vcType: ViewType = .canCommentAndLike
    var publishVM = CODCirclePublishVM()
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: Array<Dictionary<String, String>> {
        get{
            switch vcType {
            case .canCommentAndLike:
                
                /// 是否允许评论点赞 select 1\禁止 2\允许
                return [["title":"允许","desc":"允许朋友点赞和评论","select":"2"],
                        ["title":"禁止","desc":"禁止朋友点赞和评论","select":"1"]]
                
                
            case .visibleCommentAndLike:
                
                /// 是否公开评论点赞 select 1\公开 2\不公开
                return [["title":"禁止","desc":"查阅者只能看到其好友的点赞和评论","select":"2"],
                        ["title":"允许","desc":"查阅者能看到所有人的点赞评论","select":"1"]]
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        if vcType == .canCommentAndLike {
            self.navigationItem.title = NSLocalizedString("允许朋友点赞和评论", comment: "")
        }else{
            self.navigationItem.title = NSLocalizedString("允许点赞和评论公开", comment: "")
        }
        
        self.setBackButton()
        
        self.tableView.register(UINib(nibName: "CODCommentAndLikeSetCell", bundle: Bundle.main), forCellReuseIdentifier: "CODCommentAndLikeSetCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
    }

    func selectRow(index: Int) {
        
        var select = 2
        
        if index == 0 {
            select = 2
        }else{
            select = 1
        }
        
        if vcType == .canCommentAndLike {
            self.publishVM.updateCanCommentAndLike(selectInt: select)
        }else{
            self.publishVM.updatePublicCommentAndLike(selectInt: select)
        }
        
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

extension CODCommentLikeSetViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dic = dataSource[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CODCommentAndLikeSetCell", for: indexPath) as! CODCommentAndLikeSetCell
        cell.titleLab.text = dic["title"]
        cell.descLab.text = dic["desc"]
        cell.divLeadingCos.constant = (indexPath.row == 0) ? 16 : 0
        
        if vcType == .canCommentAndLike {
            
            cell.selectImageView.isHidden = (self.publishVM.publishModel.isCanCommentAndLike != dic["select"]?.int)
            
        }else{
            
            cell.selectImageView.isHidden = (self.publishVM.publishModel.isPublicCommentAndLike != dic["select"]?.int)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectRow(index: indexPath.row)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}
