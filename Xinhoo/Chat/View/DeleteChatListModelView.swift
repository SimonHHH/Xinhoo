//
//  DeleteChatListModelView.swift
//  COD
//
//  Created by xinhooo on 2020/1/6.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class DeleteChatListModelView: UIView {

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var descLab: UILabel!
    @IBOutlet weak var descBottomCos: NSLayoutConstraint!
    @IBOutlet weak var subDescLab: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    class func initWitXib(imgID:Any?,desc:String?,subDesc:String?) -> DeleteChatListModelView {
        let view = Bundle.main.loadNibNamed("DeleteChatListModelView", owner: self, options: nil)?.last as! DeleteChatListModelView
        view.descLab.preferredMaxLayoutWidth = 300
        view.descLab.text = desc
        
        view.subDescLab.preferredMaxLayoutWidth = 300
        view.subDescLab.text = subDesc
        if subDesc == nil {
            view.descBottomCos.constant = 0
        }
        
        if let imgIDString = imgID as? String {
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: imgIDString) { (image) in
                view.headImageView.image = image
            }
        }
        
        if let imgIDImage = imgID as? UIImage {
            view.headImageView.image = imgIDImage
        }
        
        
        view.size = view.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        return view
    }
    
}
