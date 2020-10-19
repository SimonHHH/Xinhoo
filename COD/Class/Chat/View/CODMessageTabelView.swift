//
//  CODMessageTabelView.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODMessageTabelView: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var contentOffsetForRestore: CGPoint = CGPoint.zero
    
    func reloadDataWithoutScrollToTop() {
        
        
//        [self reloadData];
//        [self setContentOffset:self.contentOffsetForRestore];
        
        self.reloadData()
        
        

        
    }

    override var contentSize: CGSize {
        
        willSet {
            
            let previousContentHeight = self.contentSize.height
//            CGFloat previousContentHeight = self.contentSize.height;
//               [super setContentSize:contentSize];
            let currentContentHeight = newValue.height
            self.contentOffsetForRestore = CGPoint(x: 0, y: (currentContentHeight - previousContentHeight - self.contentInset.top))
//               self.contentOffsetForRestore = CGPointMake(0, (currentContentHeight - previousContentHeight - self.contentInset.top));
            
//            if newValue != CGSize.zero {
//
//                if newValue.height >  self.newContentSize.height {
//                    var offset = self.contentOffset;
//                    offset.y += (newValue.height - self.newContentSize.height);
//                    self.contentOffset = offset;
//                }
//
//            }
            
//            self.contentSize = newValue
            
        }
        
        
    }
    

}
