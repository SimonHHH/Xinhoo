//
//  CODDiscoverPersonalListCellVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import IGListKit


class CODDiscoverPersonalListCellVM: ListDiffable {
    
    var identifier: String {
        return ("\(self.cellType.hashValue)" + "\((self.model?.msgId.hashValue ?? 0))")
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self.identifier.nsString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        
        guard let object = object as? CODDiscoverPersonalListCellVM else {
            return false
        }
        
        return self.identifier == object.identifier
    }
    
    
    enum CODDiscoverPersonalListCellType {
        case hander
        case date
        case year
        case camera
        case image
        case groupImage
        case imageText
        case text
        case video

    }
    
    let cellType: CODDiscoverPersonalListCellType
    var model: CODDiscoverMessageModel? {
        return CODDiscoverMessageModel.getModel(id: self.mesId)
    }
    let mesId: String
    
    init(cellType: CODDiscoverPersonalListCellType, model: CODDiscoverMessageModel? = nil) {
        self.cellType = cellType
        self.mesId = model?.msgId ?? ""
    }
    
    var dateAttr: NSAttributedString {
        
        if cellType != .date {
            return NSAttributedString()
        }
        
        guard let model = self.model else {
            return DiscoverUITools.createDayAndMonthAttr(Date.milliseconds.int)
        }
        
        return DiscoverUITools.createDayAndMonthAttr(model.createTime)
        
    }
    
    var yearAttr: NSAttributedString {
        
        if cellType != .year {
            return NSAttributedString()
        }
        
        guard let model = self.model else {
            return NSAttributedString()
        }
        
        let str = NSMutableAttributedString(string: Date(milliseconds: model.createTime).year.string)
        str.yy_color = UIColor(hexString: "#1A1A1A")
        str.yy_font = UIFont.boldSystemFont(ofSize: 28)
        
        return str
        
    }
    
    var imageUrl: URL? {
        
        switch cellType {
        case .video:
            return model?.video?.getMomentFirstpic()
        case .image, .imageText:
            return model?.imageList.first?.getImageSmallURL()
        default:
            return nil
        }

    }
    
    var imageUrlList: [URL?] {
        
        if cellType != .groupImage {
            return []
        }
        
        guard let model = self.model else {
            return []
        }
        
        return model.imageList.getImageSmallURL()
    }
    
    var groupImageCountAttr: NSAttributedString {
        
        if cellType != .groupImage {
            return NSAttributedString()
        }
        
        guard let model = self.model else {
            return NSAttributedString()
        }
        
        let str = NSMutableAttributedString(string: NSLocalizedString(String(format: "共%ld张", model.imageList.count), comment: ""))
        str.yy_color = UIColor(hexString: "#808080")
        str.yy_font = UIFont.boldSystemFont(ofSize: 12)
        
        return str
        
    }
    
    var textAttr: NSAttributedString {
        
        if cellType != .groupImage && cellType != .video && cellType != .imageText && cellType != .text {
            return NSAttributedString()
        }
        
        guard let model  = self.model else {
            return NSAttributedString()
        }
        
        let str = NSMutableAttributedString(string: model.text)
        str.yy_color = UIColor(hexString: "#333333")
        str.yy_font = UIFont.systemFont(ofSize: 16)
        
        if cellType != .text {
            str.yy_lineSpacing = 1
        } else {
            str.yy_lineSpacing = 0
        }
        
        return str
        
    }
    

}

extension CODDiscoverPersonalListCellVM.CODDiscoverPersonalListCellType {
    
    var dateWidth: CGFloat {
        return CODDiscoverPersonalListCellVM.CODDiscoverPersonalListCellType.date.itemSize.width
    }

    var itemSize: CGSize {
        switch self {
        case .camera, .image:
            return CGSize(width: 75, height: 75).screenScale()
        case .text:
            return CGSize(width: (kScreenWidth - dateWidth - 12), height: 29)
        case .hander:
            return CGSize(width: 375, height: 397.5).screenScale()
        case .date:
            return CGSize(width: 80, height: 80).screenScale()
        case .groupImage, .imageText, .video:
            return CGSize(width: (kScreenWidth - dateWidth - 12), height: 75 * kScreenScale)
        case .year:
            return CGSize(width: (kScreenWidth - dateWidth - 12), height: 40 * kScreenScale)
        }
    }
    
    var nodeType: CODDiscoverPersonalListCellNode.Type {
        switch self {
        case .camera:
            return CODDiscoverPersonalListCameraNode.self
        case .date:
            return CODDiscoverPersonalListDateNode.self
        case .image:
            return CODDiscoverPersonalListImageNode.self
        case .groupImage:
            return CODDiscoverPersonalListImageGroupNode.self
        case .text:
            return CODDiscoverPersonalTextNode.self
        case .hander:
            return CODDiscoverPersonalListHeaderNode.self
        case .video:
            return CODDiscoverPersonalVideoNode.self
        case .imageText:
            return CODDiscoverPersonalImageTextNode.self
        case .year:
            return CODDiscoverPersonalListYearNode.self
        }
        
    }
    
    var newLine: Bool {
        switch self {
        case .image, .camera:
            return false
        default:
            return true
        }
    }
    
    var nextNewLine: Bool {
        
        switch self {
        case .camera, .video, .imageText, .groupImage, .hander, .year, .text:
            return true
        default:
            return false
        }
        
    }
    
}

