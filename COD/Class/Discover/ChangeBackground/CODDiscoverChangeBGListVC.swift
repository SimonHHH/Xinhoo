//
//  CODDiscoverChangeBGListVC.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/6.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODDiscoverChangeBGListVC: BaseViewController, TZImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectImageFormLibModel: CODCellModel!
    
    var takePhoto: CODCellModel!
    
    let greatWork = CODCellModel(title: NSLocalizedString("从优秀摄影作品中选择", comment: ""), titleColor: .black, ishiddenArrow: false, action: CODCellModel.Action(didSelected: {
        
        let vc = CODDiscoverGreatWorkChooceVC()
        
        UIViewController.current()?.navigationController?.pushViewController(vc)
        
        
    })
    )
    
    @CODBehaviorRelay var dataSources: [[CODCellModel]] = []
    
    let adapter = SimpleTableDataSourcesAdapter()
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        self.selectImageFormLibModel =  CODCellModel(title: NSLocalizedString("从手机相册选择", comment: ""), titleColor: .black, ishiddenArrow: false, action: CODCellModel.Action(didSelected: { [weak self] in
            
            
            
            CODImagePickerTools.defualt.showPhotoPicker { (image) in
                guard let `self` = self else { return }
                
                self.chooseImage(image)
                
            }
            
            
            
            
        })
        )
        
        takePhoto = CODCellModel(title: NSLocalizedString("拍一张", comment: ""), titleColor: .black, ishiddenArrow: false, action: CODCellModel.Action(didSelected: { [weak self] in
            
            
            CODImagePickerTools.defualt.showCameraPicker { (image) in
                guard let `self` = self else { return }
                
                self.chooseImage(image)
            }
            
        })
        )
        
        self.dataSources = [
            [
                selectImageFormLibModel,
                takePhoto,
                greatWork
            ]
        ]
        
        tableView = UITableView(frame: self.view.frame, style: .plain)
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(hexString: "#C8C7CC")
        
        
        adapter.bindDataSources(tableView, $dataSources)
        
        view.addSubview(tableView)
        
        
        
    }
    
    func chooseImage(_ image: UIImage) {
        

        CODProgressHUD.showWithStatus(NSLocalizedString("正在上传", comment: ""))
        UploadTool.upload(fileType: .imageObjest(image: image), progressHandle: nil) { (respone) in
            
            CODProgressHUD.dismiss()
            let json = JSON(respone.value)
            
            if let jsonData = json["data"].arrayValue.first {
                
                let serverImageId = jsonData["attId"].stringValue
                
                DiscoverHttpTools.setUserMomentsBackground(pic: serverImageId) { response in
                    
                    if response.result.isFailure != nil {
                        DiscoverTools.saveMomentBackground(image)
                        UserManager.sharedInstance.chooseGoodWork = nil
                        
                    } else {
                        CODProgressHUD.showErrorWithStatus(NSLocalizedString("网络异常", comment: ""))
                    }
                    
                }
                
                
            } else {
                CODProgressHUD.showErrorWithStatus(NSLocalizedString("网络异常", comment: ""))
            }
            
            UIViewController.current()?.navigationController?.popToViewController(to: CODDiscoverHomeVC.self)
            
        }
        
        
        
        
    }
    
    
}
