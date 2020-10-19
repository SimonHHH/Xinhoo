//
//  CODDiscoverLikeHeaderView.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright (c) 2020 XinHoo. All rights reserved.
//

import UIKit

@IBDesignable
class CODDiscoverLikerHeaderView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    

    var likerList: [CODPersonInfoModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    

    // Our custom view from the XIB file
    var view: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
//    var imageDownloadToken: SDWebImageDownloadToken?
    
    /**
     Initialiser method
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    /**
     Initialiser method
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    /**
     Sets up the view by loading it from the xib file and setting its frame
     */
    func setupView() {
        view = loadViewFromXibFile()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        collectionView.register(cellWithClass: CODLikerHeaderCell.self)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 35, height: 35)
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        
        collectionView.backgroundColor = .clear

    }

    /**
     Loads a view instance from the xib file
     - returns: loaded view
     */
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CODDiscoverLikerHeaderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: CODLikerHeaderCell.self, for: indexPath)
        
        _ = cell.imageView.cod_loadHeaderByCache(url: URL(string: likerList[indexPath.row].userpic.getHeaderImageFullPath(imageType: 0)))
                
        return cell
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        collectionView.size = CGSize(width: size.width, height: 10)
        collectionView.size = self.collectionView.contentSize
        
        return self.collectionView.contentSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CustomUtil.pushPersonInfoVC(jid: likerList[indexPath.row].jid)
    }
}
