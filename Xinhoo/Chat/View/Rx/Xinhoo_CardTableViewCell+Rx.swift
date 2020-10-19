//
//  Xinhoo_CardTableViewCell+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


extension Reactive where Base: Xinhoo_CardRightTableViewCell {
    var cellLocationBinder: Binder<LocationType> {
        return Binder(self.base) { (view, value) in
            guard let vm = view.viewModel else { return }
            view.configModel(lastModel: vm.lastModel, model: vm.messageModel, nextModel: vm.nextModel)
        }
    }
}

extension Reactive where Base: Xinhoo_CardLeftTableViewCell {
    var cellLocationBinder: Binder<LocationType> {
        return Binder(self.base) { (view, value) in
            guard let vm = view.viewModel else { return }
            view.configModel(lastModel: vm.lastModel, model: vm.messageModel, nextModel: vm.nextModel)
        }
    }
}

