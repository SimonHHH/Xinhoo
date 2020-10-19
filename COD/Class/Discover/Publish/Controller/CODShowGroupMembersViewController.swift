//
//  CODShowGroupMembersViewController.swift
//  COD
//
//  Created by XinHoo on 5/19/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODShowGroupMembersViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var members = [CODGroupMemberModel]()
    
    var titleStr = "群里的朋友"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tabShadowImageView()?.isHidden = true
        
        self.setBackButton()
        self.navigationItem.titleView = titleLabView
        self.updateNavtitle(titleStr)
        
        collectionView.collectionViewLayout = self.groupMemberLayout
        collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        collectionView.register(UINib(nibName: "CODGroupMemberCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CODGroupMemberCollectionCell")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabShadowImageView()?.isHidden = false
    }
    
    func updateNavtitle(_ title: String) {
        self.navigationItem.title = NSLocalizedString(title, comment: "") + " " + "\(self.members.count)"
        let attriStr = NSAttributedString(string: NSLocalizedString(title, comment: ""), attributes: [NSAttributedString.Key.font : UIFont(name: "PingFang-SC-Medium", size: 17.0)!, NSAttributedString.Key.foregroundColor : UIColor(hexString: kNavTitleColorS)!])
        
        let attriCountStr = NSAttributedString(string: " \(self.members.count)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0), NSAttributedString.Key.foregroundColor : UIColor(hexString: kBtnDisenableColors)!])
        self.titleLabView.attributedText = attriStr + attriCountStr
    }
    
    lazy var groupMemberLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: 60.0, height: 79.0)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        return layout
    }()
    
    lazy var titleLabView: UILabel = {
        let lab = UILabel.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth-140, height: 22))
        lab.textAlignment = .center
        lab.text = NSLocalizedString(self.titleStr, comment: "")
        lab.textColor = UIColor(hexString: kNavTitleColorS)
        lab.font = UIFont(name: "PingFang-SC-Medium", size: 17.0)
        return lab
    }()

}


extension CODShowGroupMembersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CODGroupMemberCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CODGroupMemberCollectionCell", for: indexPath) as! CODGroupMemberCollectionCell
        let member = self.members[indexPath.row]
        cell.nickLab.text = member.getMemberNickName()
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: member.userpic) { (image) in
            cell.headBtn.setImage(image, for: .normal)
        }
        return cell
    }
    
    
}
