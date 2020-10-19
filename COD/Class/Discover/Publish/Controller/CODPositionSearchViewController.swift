//
//  CODPositionSearchViewController.swift
//  COD
//
//  Created by xinhooo on 2020/5/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODPositionSearchViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchResult:[BMKPoiInfo] = []
    var publishVM = CODCirclePublishVM()
    
    var selectSearchResultBlock: ((BMKPoiInfo) -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension CODPositionSearchViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let poiInfo = self.searchResult[indexPath.row]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
        }
        
        cell?.textLabel?.text = poiInfo.name
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cell?.textLabel?.textColor = UIColor(hexString: "000000")
        
        cell?.detailTextLabel?.text = poiInfo.address
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        cell?.detailTextLabel?.textColor = UIColor(hexString: "787878")
        
        if self.publishVM.publishModel.position?.uid == poiInfo.uid {
        
            cell?.accessoryView = UIImageView(image: UIImage(named: "selectlanguage_icon"))
        }else{
            cell?.accessoryView = nil
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let poiInfo = self.searchResult[indexPath.row]
        if let block = self.selectSearchResultBlock {
            block(poiInfo)
        }
    }
    
}

extension CODPositionSearchViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        print(#line,#function)
//        if searchController.searchBar.text == "123321" {
//            if let vc = searchController.delegate as? CODPublishPositionViewController{
//                if let block = vc.selectSearchResultBlock {
//                    block("123")
//                }
//            }
//        }
        CODLocationTool.share.searchPoiWithKeyword(keyword:searchController.searchBar.text ?? "") { [weak self] (result) in
            guard let `self` = self else{
                return
            }
            self.searchResult.removeAll()
            self.searchResult.append(contentsOf: result)
            self.tableView.reloadData()
            
        }
    }
    
    
}
