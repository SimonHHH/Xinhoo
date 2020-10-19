//
//  CODCanReadCellModel.swift
//  COD
//
//  Created by XinHoo on 5/22/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CODCanReadCellModel: NSObject {
    
    enum ArrowType {
        case up
        case down
    }
    
    var title: String = ""
    
    var isSelected: Bool? = nil
    
    var readType: CODCanReadViewModel.CanReadType? = nil
        
    var subTitle: String? {
        set {
            self.subTitleBR.accept(newValue)
        }
        get {
            return subTitleBR.value
        }
    }
    
    var subTitleBR: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    var arrowType: ArrowType? = nil
    
    typealias SelectAction = (_ cellVM: CODCanReadCellModel) -> Void
    
    var selectAction: SelectAction?
    
    var cellType: String = ""
    
    convenience init(cellType: String, title: String, subTitle: String? = nil, isSelected: Bool? = nil, readType: CODCanReadViewModel.CanReadType? = nil, arrowType:ArrowType? = nil ,selectAction: @escaping SelectAction) {
        self.init()
        self.cellType = cellType
        self.readType = readType
        self.title = title
        self.subTitle = subTitle
        self.isSelected = isSelected
        self.arrowType = arrowType
        self.selectAction = selectAction
    }
}

extension Reactive where Base :CODCanReadCellModel{
    var subTitle: Observable<String?> {
        return self.base.subTitleBR.asObservable()
    }
}
