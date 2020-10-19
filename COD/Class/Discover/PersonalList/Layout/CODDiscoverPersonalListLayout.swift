//
//  CODDiscoverPersonalListLayout.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

protocol CODDiscoverPersonalListLayoutDelegate: NSObject {
    func cellType(indexPath: IndexPath) -> CODDiscoverPersonalListCellVM.CODDiscoverPersonalListCellType?
}

class CODDiscoverPersonalListLayout: UICollectionViewFlowLayout {
    
    var attrs: [UICollectionViewLayoutAttributes] = []
    
    weak var delegate: CODDiscoverPersonalListLayoutDelegate?
    
    
    var dateWidth: CGFloat {
        return CODDiscoverPersonalListCellVM.CODDiscoverPersonalListCellType.date.itemSize.width
    }
    
    
    override func prepare() {
        
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        attrs.removeAll()
        
        for section in 0..<collectionView.numberOfSections {
            
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                
                let indexPath = IndexPath(item: item, section: section)
                
                if let layout = self.layoutAttributesForItem(at: indexPath) {
                    attrs.append(layout)
                }
                
            }
            
        }
        
        
        super.prepare()
        
        
        
        
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let layout = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        guard let cellType = delegate?.cellType(indexPath: indexPath) else {
            return layout
        }
        
        var lastIndexPath: IndexPath?
        var lastType: CODDiscoverPersonalListCellVM.CODDiscoverPersonalListCellType?
        var lastLayoutAttr: UICollectionViewLayoutAttributes?
        
        let newLine = cellType.newLine
        var firstLine = false
        let cellItemSize = cellType.itemSize
        

        if indexPath.section == 0 {
            firstLine = true
        } else {
            
            lastIndexPath = IndexPath(item: indexPath.item, section: indexPath.section  - 1)
            lastType = delegate?.cellType(indexPath: lastIndexPath!)
            lastLayoutAttr = attrs[lastIndexPath!.section]
            
        }
        
//        if lastType == .date && cellType == .text {
//            cellItemSize.height = 47 * kScreenScale
//        }
        
        
        func getNewLinewPoint() -> CGPoint {
            
            guard let lastLayoutAttr = lastLayoutAttr else {
                return .zero
            }
            
            if dateWidth == lastLayoutAttr.frame.maxX {
                return getNextPoint()
            }
            
            if cellType == .date {
                return CGPoint(x: 0, y: lastLayoutAttr.frame.maxY + 20)
            } else if cellType == .year {
                return CGPoint(x: 0, y: lastLayoutAttr.frame.maxY + 60)
            } else {
                return CGPoint(x: dateWidth + 5, y: lastLayoutAttr.frame.maxY + 5)
            }
            
        }
        
        func getNextPoint() -> CGPoint {
            
            guard let lastLayoutAttr = lastLayoutAttr else {
                return .zero
            }
            
            return CGPoint(x: lastLayoutAttr.frame.maxX + 5, y: lastLayoutAttr.frame.origin.y)
            
        }

        
        if firstLine {
            layout.frame = CGRect(origin: CGPoint.zero, size: cellItemSize)
        } else if newLine == true || lastType?.nextNewLine ?? false {
            
            layout.frame = CGRect(origin: getNewLinewPoint(), size: cellItemSize)
            
        } else {
            
            layout.frame = CGRect(origin: getNextPoint(), size: cellItemSize)
            
            if layout.frame.maxX > kScreenWidth {
                layout.frame = CGRect(origin: getNewLinewPoint(), size: cellItemSize)
            }
            
        }
        
        return layout
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return attrs
        
    }
    
    
    override var collectionViewContentSize: CGSize {
        
        if let height = attrs.last?.frame.maxY {
            return CGSize(width: kScreenWidth, height: height)
        }
        
        return CGSize(width: kScreenWidth, height: KScreenHeight)
    }
    
}
