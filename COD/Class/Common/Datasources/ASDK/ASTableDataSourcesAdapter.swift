//
//  ASTableDataSourcesAdapter.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/11.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxDataSources
import RxDataSources_Texture
import RxSwift
import RxCocoa
import AsyncDisplayKit

protocol ASTableDataSourcesAdapterDelegate: AnyObject  {
    
    var tableNode: ASTableNode { get }
    var pageVM: Any? { get }
    
}

extension ASTableDataSourcesAdapterDelegate {
    var pageVM: Any? { return nil }
}




class ASTableViewSectionVM<Section: IdentifiableType, ItemType: ASTableCellViewModelType>  {
    
    var sectionFootViewType: UIView.Type?
    var sectionHeadViewType: UIView.Type?
    var items: [Item]
    var model: Section
    var title: String = ""
    var footViewHeight: CGFloat = UITableView.automaticDimension
    var headViewHeight: CGFloat = UITableView.automaticDimension
    
    init(model: Section, items: [ItemType], title: String = "", sectionFootViewType: UIView.Type? = nil, sectionHeadViewType: UIView.Type? = nil, footViewHeight: CGFloat = UITableView.automaticDimension, headViewHeight: CGFloat = UITableView.automaticDimension) {
        self.model = model
        self.items = items
        self.title = title
        self.sectionFootViewType = sectionFootViewType
        self.sectionHeadViewType = sectionHeadViewType
        self.footViewHeight = footViewHeight
        self.headViewHeight = headViewHeight
        
    }
    
    required public init(original: ASTableViewSectionVM, items: [Item]) {
        self.model = original.model
        self.items = items
    }
    
}

protocol ASSectionVMType: AnimatableSectionModelType where CellVM: ASTableCellViewModelType, SectionModelType: IdentifiableType {
    
    associatedtype CellVM
    associatedtype SectionModelType
    
    var items: [CellVM] { get set }
    var model: SectionModelType { get }
}

extension ASTableViewSectionVM: ASSectionVMType {
    
    public typealias Item = ItemType
    public typealias Identity = Section.Identity
    
    public var identity: Section.Identity {
        return model.identity
    }
    
    public var hashValue: Int {
        return self.model.identity.hashValue
    }
}





class ASTableDataSourcesAdapter<Section: ASSectionVMType>: NSObject, ASTableDelegate {
    
    weak var delegate: ASTableDataSourcesAdapterDelegate?
    var dataSources: BehaviorRelay<[Section]>
    var pageVM: Any?
    
    init(_ delegate: ASTableDataSourcesAdapterDelegate?) {
        
        self.delegate = delegate
        self.pageVM = delegate?.pageVM
        
        self.dataSources = BehaviorRelay(value: [])
        
        super.init()
        
        guard let tableNode = delegate?.tableNode  else {
            return
        }
        
        configDataSource()
        
        tableNode.delegate = self
        
    }
    
    
    func configDataSource() {
        
        guard let tableNode = delegate?.tableNode  else {
            return
        }
        
        let tvAnimatedDataSource = RxASTableSectionedReloadDataSource<Section>(configureCellBlock: configureCell)
        
        self.dataSources.throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .bind(to: tableNode.rx.items(dataSource: tvAnimatedDataSource))
            .disposed(by: self.rx.disposeBag)
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        guard let cellVM = self.getSectionVMAndCellVM(indexPath: indexPath)?.cellVM else {
            return
        }
        
        
        
        if let cell = tableNode.nodeForRow(at: indexPath) as? ASCellNodeDataSourcesType {
            
            cell.didSelected(pageVM: self.pageVM, cellVM: cellVM, indexPath: indexPath)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return getSectionVM(section: section)?.footViewHeight ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let sectionVM = getSectionVM(section: section) else {
            return UIView()
        }
        
        
        if let viewType = sectionVM.sectionFootViewType {
            return viewType.init()
        }
        
        return UIView()
        
    }
    

    func configureCell(dataSource: ASTableSectionedDataSource<Section> , tableView: ASTableNode, indexPath: IndexPath, item: Section.Item) -> ASCellNodeBlock {

        return { [weak self] in
            
            guard let `self` = self else { return CODCellNode() }
            
            guard let sectionVM = self.getSectionVMAndCellVM(indexPath: indexPath)?.sectionVM,
                let cellVM = self.getSectionVMAndCellVM(indexPath: indexPath)?.cellVM else {
                return CODCellNode()
            }
            
            let cell = cellVM.cellType.init(cellVM)
            
            if let cell = cell as? ASCellNodeDataSourcesType {
                
                cell.configPageVM(pageVM: self.pageVM, indexPath: indexPath)
                cell.configCellVM(cellVM: cellVM, indexPath: indexPath)
                
                var lastCellVM: ASTableViewCellVM? = nil
                var nextCellVM: ASTableViewCellVM? = nil
                let lastIndexPath = indexPath.row - 1
                if lastIndexPath >= 0 && lastIndexPath < sectionVM.items.count  {
                    lastCellVM = sectionVM.items[indexPath.row - 1] as? ASTableViewCellVM
                }
                
                if indexPath.row + 1 < sectionVM.items.count {
                    nextCellVM = sectionVM.items[indexPath.row + 1] as? ASTableViewCellVM
                }
                
                cell.configCellVM(pageVM: self.pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)
                
            }
            
            return cell
            
        }
        
    }
    
    func getSectionVM(section: Int) -> ASTableViewSectionVM<Section.SectionModelType, Section.CellVM>? {
        
        if self.dataSources.value.count >= section {
            return nil
        }
        
        guard let sectionVM = self.dataSources.value[section] as? ASTableViewSectionVM<Section.SectionModelType, Section.CellVM> else {
            fatalError("sectionVM 必须继承 TableViewSectionVM")
        }
        
        return sectionVM
        
    }
    
    
    func getSectionVMAndCellVM(indexPath: IndexPath) -> (sectionVM: ASTableViewSectionVM<Section.SectionModelType, Section.CellVM>, cellVM: ASTableViewCellVM)? {
        
        if self.dataSources.value.count <= indexPath.section {
            return nil
        }
        
        guard let sectionVM = self.dataSources.value[indexPath.section] as? ASTableViewSectionVM<Section.SectionModelType, Section.CellVM> else {
            return nil
        }
        
        if indexPath.row >= sectionVM.items.count {
            return (sectionVM: sectionVM, cellVM: ASTableViewCellVM(name: CODCellNode.self))
        }
        
        if sectionVM.items.count <= indexPath.row {
            return nil
        }
        
        guard let cellVM = sectionVM.items[indexPath.row] as? ASTableViewCellVM else {
            return nil
        }
        
        return (sectionVM: sectionVM, cellVM: cellVM)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    
}
