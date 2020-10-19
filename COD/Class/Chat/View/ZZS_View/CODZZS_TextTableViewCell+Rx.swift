//
//  CODZZS_TextTableViewCell+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/19.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: CODZZS_TextLeftTableViewCell {
    
    var cellLocationBinder: Binder<LocationType> {
        return Binder(self.base) { (view, value) in

            guard let vm = view.viewModel else { return }
            
            view.configModel(lastModel: vm.lastModel, model: vm.messageModel, nextModel: vm.nextModel)
        }
    }
    


    
    
}

extension Reactive where Base: CODZZS_TextRightTableViewCell {
    
    var cellLocationBinder: Binder<LocationType> {
        return Binder(self.base) { (view, value) in

            guard let vm = view.viewModel else { return }
            
            view.showName(showName: view.isShowName)
            view.configModel(lastModel: vm.lastModel, model: vm.messageModel, nextModel: vm.nextModel)
        }
    }
    
}
