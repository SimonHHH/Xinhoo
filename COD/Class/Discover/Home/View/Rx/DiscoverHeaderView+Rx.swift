//
//  DiscoverHeaderView+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/23.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: DiscoverHeaderView {
    
    var nickNameBinder: Binder<String> {
        return Binder(base) { (view, value) in
            view.nickNameLab.text = value
        }
    }
    
    var headerUrlBinder: Binder<URL?> {
        return Binder(base) { (view, value) in
            view.headerImageView.cod_loadHeader(url: value)
        }
    }
    

}
