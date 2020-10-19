//
//  CGSizeExt.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

extension CGSize {
    func screenScale() -> CGSize {
        return CGSize(width: self.width * kScreenScale, height: self.height * kScreenScale)
    }
}
