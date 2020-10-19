//
//  CODPublishPositionViewController.swift
//  COD
//
//  Created by xinhooo on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODPublishPositionViewController: BaseViewController {

    var publishVM = CODCirclePublishVM()
    var poiList:[BMKPoiInfo] = []
    var pageNum: Int32 = 1
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var searchCtl: UISearchController = {
        
        let positionSearchVC = CODPositionSearchViewController(nibName: "CODPositionSearchViewController", bundle: Bundle.main)
        positionSearchVC.publishVM = self.publishVM
        positionSearchVC.selectSearchResultBlock = { [weak self] (poiInfo) in
            guard let `self` = self else {
                return
            }
            let location = CODCirlcePublishModel.Location(longitude: poiInfo.pt.longitude, latitude: poiInfo.pt.latitude, name: poiInfo.name, address:poiInfo.address, uid: poiInfo.uid)
            self.publishVM.updateLocation(location: location)
            self.searchCtl.isActive = false
            self.searchCtl.dismiss(animated: false) {
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
        let searchCtl = UISearchController(searchResultsController: positionSearchVC)
        searchCtl.searchBar.placeholder = NSLocalizedString("搜索附近位置", comment: "")
        searchCtl.definesPresentationContext = false
        searchCtl.hidesNavigationBarDuringPresentation = false
        searchCtl.searchResultsUpdater = positionSearchVC
        searchCtl.delegate = self
        searchCtl.searchBar.backgroundImage = UIImage()
        
        searchCtl.searchBar.customTextField?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)

        let searchBarTF = searchCtl.searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 14)
        
        return searchCtl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("所在位置", comment: "")
        self.setBackButton()
        if let position = self.publishVM.publishModel.position ,position.uid != CODLocationTool.share.location?.rgcData?.cityCode {
            let poiInfo = BMKPoiInfo()
            poiInfo.name = position.name
            poiInfo.uid = position.uid
            poiInfo.address = position.address
            poiInfo.pt = CLLocationCoordinate2DMake(position.latitude ?? 0.0, position.longitude ?? 0.0)
            self.poiList.append(poiInfo)
        }
        
        self.tableView.tableFooterView = UIView()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchCtl
            self.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // Fallback on earlier versions
        }
        
        CODLocationTool.share.searchResult = { [weak self] (result) in
            guard let `self` = self else {
                return
            }
            
            var result = result
            
            if result.count == 0 {
                self.tableView.mj_footer = nil
            }else{
                
                result.removeFirst { (poiInfo) -> Bool in
                    return poiInfo.uid == self.publishVM.publishModel.position?.uid
                }
                
                self.poiList.append(contentsOf: result)
                
                self.tableView.reloadData()
                self.tableView.mj_footer.endRefreshing()
            }
            
        }
        CODLocationTool.share.starLocation()
        
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            
            guard let `self` = self else { return }
            
            self.pageNum += 1
            CODLocationTool.share.getPoiList(pageNum: self.pageNum)
            
        })
        
        footer?.setTitle("", for: .idle)
        footer?.setTitle("", for: .pulling)
        footer?.setTitle("", for: .willRefresh)
        footer?.setTitle("", for: .refreshing)
        footer?.setTitle("", for: .noMoreData)
        footer?.labelLeftInset = -5
        footer?.activityIndicatorViewStyle = .white
        
        footer?.triggerAutomaticallyRefreshPercent = 0.01
        
        
        
        self.tableView.mj_footer = footer
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


extension CODPublishPositionViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else{
            return self.poiList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "normalCell")
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "normalCell")
            }
            
            if indexPath.row == 0 {
                
                cell?.textLabel?.text = NSLocalizedString("不显示位置", comment: "")
                cell?.textLabel?.textColor = UIColor(hexString: "047EF5")
                
                if self.publishVM.publishModel.position == nil {
                
                    cell?.accessoryView = UIImageView(image: UIImage(named: "selectlanguage_icon"))
                }else{
                    cell?.accessoryView = nil
                }
                
            }else{
                
                if self.publishVM.publishModel.position?.uid == CODLocationTool.share.location?.rgcData?.cityCode && CODLocationTool.share.location?.rgcData?.city != nil {
                
                    cell?.accessoryView = UIImageView(image: UIImage(named: "selectlanguage_icon"))
                }else{
                    cell?.accessoryView = nil
                }
                
                cell?.textLabel?.text = CODLocationTool.share.location?.rgcData?.city
                cell?.textLabel?.textColor = UIColor(hexString: "000000")
            }
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            
            
            
            return cell!
            
        }else{
            
            let poiInfo = self.poiList[indexPath.row]
            
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
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                self.publishVM.updateLocation(location: nil)
            }
            
            if indexPath.row == 1 {
                let location = CODCirlcePublishModel.Location(longitude: CODLocationTool.share.coordinate?.longitude, latitude: CODLocationTool.share.coordinate?.latitude, name: CODLocationTool.share.location?.rgcData?.city ?? "", address:"", uid: CODLocationTool.share.location?.rgcData?.cityCode ?? "")
                self.publishVM.updateLocation(location: location)
            }
        }
        
        if indexPath.section == 1 {
            let poiInfo = self.poiList[indexPath.row]
            
            let location = CODCirlcePublishModel.Location(longitude: poiInfo.pt.longitude, latitude: poiInfo.pt.latitude, name: poiInfo.name, address:poiInfo.address, uid: poiInfo.uid)
            self.publishVM.updateLocation(location: location)
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

extension CODPublishPositionViewController: UISearchControllerDelegate {
    
}
