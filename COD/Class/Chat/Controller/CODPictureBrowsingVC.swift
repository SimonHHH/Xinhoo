//
//  CODPictureBrowsingVC.swift
//  COD
//
//  Created by 1 on 2019/4/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODPictureBrowsingVC: BaseViewController {
    
    var pictureImage: UIImage?
    var imageURL: String?
    
    private lazy var pictureImageView:UIImageView = {
        let imgView = UIImageView(frame: CGRect.zero)
        imgView.contentMode =  .scaleAspectFit
        imgView.backgroundColor = UIColor.clear
        return imgView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("图片浏览", comment: "")
        self.view.backgroundColor = UIColor.black
        self.setBackButton()
        
        self.view.addSubview(pictureImageView)
        pictureImageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }

        if self.pictureImage != nil {
            pictureImageView.image = self.pictureImage
        }else{
            pictureImageView.sd_setImage(with: URL.init(string: imageURL ?? ""), completed: nil)
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
