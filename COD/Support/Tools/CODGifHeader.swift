//
//  CODGifHeader.swift
//  COD
//
//  Created by xinhooo on 2019/8/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGifHeader: MJRefreshGifHeader {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func prepare() {
        super.prepare()

        let idleImages = NSMutableArray.init()
        for i in 0...49 {
            let image = UIImage.init(named: "COD_Refresh_first_icon_\(i)")
            idleImages.add(image as Any)
        }
        
        let refreshingImages = NSMutableArray.init()
        for i in 0...49 {
            let image = UIImage.init(named: "COD_Refresh_second_icon_\(i)")
            refreshingImages.add(image as Any)
        }
        
        self.setImages((idleImages.subarray(with: NSRange.init(location: 0, length: 1))), for: .idle)
        self.setImages((idleImages as! [Any]), duration: 1, for: .pulling)
        self.setImages((refreshingImages as! [Any]), duration: 1, for: .refreshing)
    }
    
    override func placeSubviews() {
        
        self.lastUpdatedTimeLabel.isHidden = true
        self.stateLabel.isHidden = true
        super.placeSubviews()
    }
}
