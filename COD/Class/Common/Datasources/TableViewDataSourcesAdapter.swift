//
//  TableViewDataSourcesAdapter.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

//protocol SectionVMType: AnimatableSectionModelType where CellVM: Item {
//    associatedtype CellVM
//    var items: [CellVM] { get }
//}

protocol TableCellViewModelType: IdentifiableType, Equatable {
    
    var cellType: String { get }
    var cellHeight: CGFloat { get set }
    
}

class TableViewCellVM: NSObject, TableCellViewModelType {
    
    var identity: String {
        return self.cellType
    }
    
    static func == (lhs: TableViewCellVM, rhs: TableViewCellVM) -> Bool {
        return lhs.cellType == rhs.cellType && lhs.identity == rhs.identity
    }
    
    var cellType: String
    var cellHeight: CGFloat
    
    init(name: String, cellHeight: CGFloat = UITableView.automaticDimension) {
        self.cellType = name
        self.cellHeight = cellHeight
    }
    
    var selectAction: CellSelectType?
}

protocol SectionVMType: AnimatableSectionModelType where CellVM: TableCellViewModelType, SectionModelType: IdentifiableType {
    
    associatedtype CellVM
    associatedtype SectionModelType
    
    var items: [CellVM] { get set }
    var model: SectionModelType { get }
}

class TableViewSectionVM<Section: IdentifiableType, ItemType: TableCellViewModelType>  {
    
    var sectionFootViewType: String?
    var sectionHeadViewType: String?
    var items: [Item]
    var model: Section
    var title: String = ""
    var footViewHeight: CGFloat = UITableView.automaticDimension
    var headViewHeight: CGFloat = UITableView.automaticDimension
    
    init(model: Section, items: [ItemType], title: String = "",sectionFootViewType: String? = nil, sectionHeadViewType: String? = nil, footViewHeight: CGFloat = UITableView.automaticDimension, headViewHeight: CGFloat = UITableView.automaticDimension) {
        self.model = model
        self.items = items
        self.title = title
        self.sectionFootViewType = sectionFootViewType
        self.sectionHeadViewType = sectionHeadViewType
        self.footViewHeight = footViewHeight
        self.headViewHeight = headViewHeight
        
    }
    
    required public init(original: TableViewSectionVM, items: [Item]) {
        self.model = original.model
        self.items = items
    }
    
}

extension TableViewSectionVM: SectionVMType {
    
    public typealias Item = ItemType
    public typealias Identity = Section.Identity
    
    public var identity: Section.Identity {
        return model.identity
    }
    
    public var hashValue: Int {
        return self.model.identity.hashValue
    }
}


protocol TableViewDataSourcesAdapterDelegate: AnyObject  {
    
    var tableView: UITableView { get }
    var dataSources: [Any] { get }
    
    var pageVM: Any? { get }
    
}

extension TableViewDataSourcesAdapterDelegate {
    var pageVM: Any? { return nil }
}

class TableViewDataSourcesAdapter<Section: SectionVMType>: NSObject, UITableViewDelegate {
    
    weak var delegate: TableViewDataSourcesAdapterDelegate?
    var dataSources: BehaviorRelay<[Section]>
    var pageVM: Any?

    init(_ delegate: TableViewDataSourcesAdapterDelegate?) {
        
        self.delegate = delegate
        self.pageVM = delegate?.pageVM
        
        self.dataSources = BehaviorRelay(value: [])
        
        super.init()
        
        guard let tableView = self.delegate?.tableView else {
            return
        }
        

        let tvAnimatedDataSource = RxTableViewSectionedAnimatedDataSource<Section>(decideViewTransition: { (dataSources, tableView, change) -> ViewTransition in
            return .reload
        }, configureCell: self.configureCell, canEditRowAtIndexPath: self.canEditRowAtIndexPath)
                

        self.dataSources
            .bind(to: tableView.rx.items(dataSource: tvAnimatedDataSource))
            .disposed(by: self.rx.disposeBag)
        
        self.configTabelViewDelegate()
                
        tableView.rx.itemSelected.bind { [weak self, weak tableView] (indexPath) -> Void in
            
            guard let `self` = self, let tableView = tableView, let cell = tableView.cellForRow(at: indexPath) else { return }
            
            let cellVM = self.getSectionVMAndCellVM(indexPath: indexPath).cellVM
            
            cellVM.selectAction?.didSelected(view: cell, pageVM: self.pageVM, cellVM: cellVM, indexPath: indexPath)
            
        }
        .disposed(by: self.rx.disposeBag)
        
        
    }
    
    func configTabelViewDelegate() {
        
        guard let tableView = self.delegate?.tableView else {
            return
        }
        
        tableView.rx.setDelegate(self)
        .disposed(by: self.rx.disposeBag)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.getSectionVM(section: section).headViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewType = self.getSectionVM(section: section).sectionHeadViewType else {
            return UIView()
        }
        
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: viewType)
        
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.getSectionVM(section: section).footViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let vm = self.getSectionVM(section: section)
        
        guard let viewType = vm.sectionFootViewType else {
            return UIView()
        }
        
        let footView = tableView.dequeueReusableHeaderFooterView(withIdentifier: viewType)
        
        if let footView = footView as? TableViewHeaderFooterDataSourceType {
            
            footView.configHeaderFooterVM(sectionVM: vm, section: section)
        }
        
        return footView
        
    }
    
    func canEditRowAtIndexPath(dataSource: TableViewSectionedDataSource<Section>, indexPath: IndexPath) -> Bool {
        return true
    }
    
    func configureCell(dataSource: TableViewSectionedDataSource<Section> , tableView: UITableView, indexPath: IndexPath, item: Section.Item) -> UITableViewCell {
        let sectionVM = self.getSectionVMAndCellVM(indexPath: indexPath).sectionVM
        let cellVM = self.getSectionVMAndCellVM(indexPath: indexPath).cellVM
        
        let cell = tableView.dequeueReusableCell(withClass: stringClassFromString(cellVM.cellType) as! UITableViewCell.Type)
        
        if let cell = cell as? TableViewCellDataSourcesType {
            
            cell.configPageVM(pageVM: self.pageVM, indexPath: indexPath)
            cell.configCellVM(cellVM: cellVM, indexPath: indexPath)
            
            var lastCellVM: TableViewCellVM? = nil
            var nextCellVM: TableViewCellVM? = nil
            if indexPath.row - 1 >= 0 {
                lastCellVM = sectionVM.items[indexPath.row - 1] as? TableViewCellVM
            }
            
            if indexPath.row + 1 < sectionVM.items.count {
                nextCellVM = sectionVM.items[indexPath.row + 1] as? TableViewCellVM
            }
            
            cell.configCellVM(pageVM: self.pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)
        }
        
        
        
        return cell
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int { return dataSources.value.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSources.value[section].items.count
    }
    
    func getSectionVM(section: Int) -> TableViewSectionVM<Section.SectionModelType, Section.CellVM> {
        
        guard let sectionVM = self.dataSources.value[section] as? TableViewSectionVM<Section.SectionModelType, Section.CellVM> else {
            fatalError("sectionVM 必须继承 TableViewSectionVM")
        }

        return sectionVM
        
    }
    
    
    func getSectionVMAndCellVM(indexPath: IndexPath) -> (sectionVM: TableViewSectionVM<Section.SectionModelType, Section.CellVM>, cellVM: TableViewCellVM) {
        
        guard let sectionVM = self.dataSources.value[indexPath.section] as? TableViewSectionVM<Section.SectionModelType, Section.CellVM> else {
            fatalError("sectionVM 必须继承 TableViewSectionVM")
        }
        
        guard let cellVM = sectionVM.items[indexPath.row] as? TableViewCellVM else {
            fatalError("cellVM 必须继承 TableViewSectionVM")
        }
        
        return (sectionVM: sectionVM, cellVM: cellVM)
        
    }
    
    
    
    @objc(tableView:estimatedHeightForRowAtIndexPath:) func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return getSectionVMAndCellVM(indexPath: indexPath).cellVM.cellHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { return true }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

protocol CellSelectType {
    func didSelected(view: UIView, pageVM: Any?, cellVM: TableViewCellVM, indexPath: IndexPath)
}

protocol TableViewCellDataSourcesType {
    func configCellVM(cellVM: TableViewCellVM, indexPath: IndexPath)
    func configPageVM(pageVM: Any?, indexPath: IndexPath)
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath)
}

extension TableViewCellDataSourcesType {
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {}
    func configCellVM(cellVM: TableViewCellVM, indexPath: IndexPath) {}
    func configPageVM(pageVM: Any?, indexPath: IndexPath) {}
}

protocol TableViewHeaderFooterDataSourceType {

    func configHeaderFooterVM(sectionVM: Any, section: Int)
}

extension TableViewSectionedDataSource {
    func configHeaderFooterVM(sectionVM: Any, section: Int) {}
}
