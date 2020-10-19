//
//  CODDiscoverGreatWorkChooceVC.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/6.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODDiscoverGreatWorkChooceVC: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("更换相册封面", comment: "")
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        
        let itemSize = 108 * kScreenScale
        
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.height -= (view.cod_safeAreaInsets.top + 44 + UIApplication.shared.statusBarFrame.height)
        
        self.view.addSubview(collectionView)
        

        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(nibWithCellClass: CODGoodWorkCell.self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 32
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        

        let cell = collectionView.dequeueReusableCell(withClass: CODGoodWorkCell.self, for: indexPath)
        
        cell.imageView.image = UIImage(named: "cover_\(String(format: "%03d", indexPath.item + 1))")
        
        if let chooseGoodWork = UserManager.sharedInstance.chooseGoodWork, chooseGoodWork == indexPath.item + 1 {
            cell.selectedImageView.isHidden = false
        } else {
            cell.selectedImageView.isHidden = true
        }
        

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let imageName = "cover_\(String(format: "%03d", indexPath.item + 1))"
        
        if let image = UIImage(named: imageName) {
            
            DiscoverHttpTools.setUserMomentsBackground(pic: imageName) { response in
                
                if response.result.isFailure != true {
                    UserManager.sharedInstance.chooseGoodWork = indexPath.item + 1
                    
                    DiscoverTools.saveMomentBackground(image)
                } else {
                    CODProgressHUD.showErrorWithStatus(NSLocalizedString("网络异常", comment: ""))
                }

            }
            
            self.navigationController?.popToViewController(to: CODDiscoverHomeVC.self)
            

        }
        
        
        
    }
    

}
