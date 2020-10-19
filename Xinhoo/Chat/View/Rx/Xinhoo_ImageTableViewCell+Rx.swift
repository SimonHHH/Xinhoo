//
//  Xinhoo_ImageTableViewCell+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


extension Reactive where Base: Xinhoo_ImageRightTableViewCell {
    var cellLocationBinder: Binder<LocationType> {
        return Binder(self.base) { (view, value) in
            guard let vm = view.viewModel else { return }
            view.configModel(lastModel: vm.lastModel, model: vm.messageModel, nextModel: vm.nextModel)
        }
    }
    
    var progressBinder: Binder<Float> {
        return Binder(self.base) { (view, value) in
            view.configProgress(value)
        }
    }
    
    var uploadStateBinder: Binder<UploadStateType> {
        
        return Binder(self.base) { (view, value) in
            view.configUploadState(value)
        }
        
        
    }
}

extension Reactive where Base: Xinhoo_ImageLeftTableViewCell {
    var cellLocationBinder: Binder<LocationType> {
        return Binder(self.base) { (view, value) in
            guard let vm = view.viewModel else { return }
            view.configModel(lastModel: vm.lastModel, model: vm.messageModel, nextModel: vm.nextModel)
        }
    }
    
    var progressBinder: Binder<Float> {
        return Binder(self.base) { (view, value) in
            
            view.configProgress(value)

        }
    }
    

    var uploadStateBinder: Binder<UploadStateType> {
        
        return Binder(self.base) { (view, value) in
            
            view.configUploadState(value)

        }
        
        
    }
}
