//
//  CODShareSession_ZZS_CollectionViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/10/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODShareSession_ZZS_CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var averImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    public var urlStr :String? {
        didSet {
            averImageView.sd_setImage(with: URL.init(string: urlStr ?? ""), placeholderImage: UIImage.init(named: "default_header_110"), options: [])
        }
    }
    
    public var title: String? {
        didSet {
            if let con = title {
                nameLabel.text = con
            }
            
            if title == "\(kApp_Name)小助手", let title = title {
                let attriStr = NSMutableAttributedString.init(string: NSLocalizedString(title, comment: ""))
                let textAttachment = NSTextAttachment.init()
                let img = UIImage(named: "cod_helper_sign")
                textAttachment.image = img
                textAttachment.bounds = CGRect.init(x: 0, y: 0, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
                let attributedString = NSAttributedString.init(attachment: textAttachment)
                attriStr.append(attributedString)
                nameLabel.attributedText = attriStr
            }else{
                nameLabel.text = title
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
