//
//  NavigationBarLoadingView.swift
//  COD
//
//  Created by xinhooo on 2019/5/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class NavigationBarLoadingView: UIView {

    @IBOutlet weak var midCos: NSLayoutConstraint!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var titleLab: UILabel!
    
    var titleString: String {
        get {
            return titleLab.text ?? ""
        }
        set {
            let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue) : UIColor(hexString: kNavTitleColorS)!,
                                                              NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont(name: "PingFang-SC-Medium", size: 17.0)!]
            let title = NSMutableAttributedString.init(string: NSLocalizedString(newValue, comment: ""))
            title.addAttributes(attributes, range: NSRange.init(location: 0, length: title.length))
            titleLab.attributedText = title
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
