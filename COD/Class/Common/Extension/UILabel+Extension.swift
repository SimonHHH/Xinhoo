//
//  UILabel+Extension.swift
//  COD
//
//  Created by 1 on 2019/3/6.
//  Copyright © 2019 XinHoo. All rigvts reserved.
//

import Foundation

public extension UILabel {
    
    func setFrameWithString(_ string: String, width: CGFloat) {
        self.numberOfLines = 0
        let attributes: [NSAttributedString.Key : AnyObject] = [
            .font: self.font,
            ]
        let resultSize: CGSize = string.boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
            ).size
        let resultHeight: CGFloat = resultSize.height
        let resultWidth: CGFloat = resultSize.width
        var frame: CGRect = self.frame
        frame.size.height = resultHeight
        frame.size.width = resultWidth
        self.frame = frame
    }
}
