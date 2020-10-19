//
//  CODGroupNoticeContentCell.swift
//  COD
//
//  Created by 黄玺 on 2020/2/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

let NoticesMinHeight: CGFloat = 33
let NoticesMaxHeight: CGFloat = 400/667*KScreenHeight-63-52-30

class CODGroupNoticeContentCell: UITableViewCell {
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    var contentStr: String! {
        didSet {
            self.contentTextView.text = self.contentStr
            var bounds = self.contentTextView.bounds
            let size = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
            var newSize = self.contentTextView.sizeThatFits(size)
            if newSize.height > NoticesMaxHeight {
                newSize.height = NoticesMaxHeight
                self.contentTextView.isScrollEnabled = true
            }
            if newSize.height < NoticesMinHeight {
                newSize.height = NoticesMinHeight
            }
            bounds.size = newSize
            contentViewHeight.constant = newSize.height
            self.contentTextView.bounds = bounds
        }
    }

    @IBOutlet weak var contentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentTextView.layoutManager.allowsNonContiguousLayout = false
    }
    
    func getHeight() -> CGFloat {
        
        return contentViewHeight.constant+30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

