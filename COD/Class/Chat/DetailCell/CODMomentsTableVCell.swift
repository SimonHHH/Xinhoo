//
//  CODMomentsTableVCell.swift
//  COD
//
//  Created by XinHoo on 7/13/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CODMomentsTableVCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
        
    var dataSourceBR :BehaviorRelay<[CODMomentsPicModel]> = BehaviorRelay(value: [])
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.minimumLineSpacing = 4
        return flowLayout
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.collectionViewLayout = flowLayout
        collectionView.contentInset = UIEdgeInsets(top: 10.5, left: 0.0, bottom: 10.5, right: 0.0)
        collectionView.register(UINib(nibName: "CODMomentsCollectionVCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CODMomentsCollectionVCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceBR.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: CODMomentsCollectionVCell.self, for: indexPath)
        let model = dataSourceBR.value[indexPath.row]
        cell.imageView.sd_setImage(with: URL(string: ServerUrlTools.getMomentsServerUrl(fileType: .Image(model.picId, .small))), placeholderImage: nil)
        if model.type == 0 {
            cell.videoIcon.isHidden = true
        }else{
            cell.videoIcon.isHidden = false
        }
        return cell
    }
    
}

extension Reactive where Base: CODMomentsTableVCell {
    var dataSourceBind: Binder<[CODMomentsPicModel]> {
        return Binder(base) { (view, datas) in
            view.dataSourceBR.accept(datas)
            view.collectionView.reloadData()
        }
    }
}
