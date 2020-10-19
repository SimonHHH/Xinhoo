//
//  CODDiscoverPersonalListVC.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/9.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport
import FDFullscreenPopGesture
import RxSwift
import RxCocoa
import RxRealm
import IGListKit


class CODDiscoverPersonalListVC: BaseViewController, CODDiscoverPersonalListLayoutDelegate, ListAdapterDataSource, UIScrollViewDelegate, YBImageBrowserDelegate {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.pageVM.dataSources
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return DiscoverPersonalSectionController(pageVM: self.pageVM)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    var discoverNavigationBar = CODDiscoverPersonalListNavigationBar()
    
    
    let pageVM: CODDiscoverPersonalListVCPageVM
    
    let discoverPersonalListLayout = CODDiscoverPersonalListLayout()
    
    var imageBrowser: YBImageBrowser?
    
    lazy var collectionView: UICollectionView = {
                
        let layout = self.discoverPersonalListLayout
        layout.scrollDirection = .vertical
        layout.delegate = self
        
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.pageNum = 1
        collectionView.pageSize = 10
        
        return collectionView
        
        
        
    }()
    

    
    init(jid: String = UserManager.sharedInstance.jid) {
        self.pageVM = CODDiscoverPersonalListVCPageVM(jid: jid)
        self.discoverNavigationBar = CODDiscoverPersonalListNavigationBar(jid: jid)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.pageVM = CODDiscoverPersonalListVCPageVM()
        self.discoverNavigationBar = CODDiscoverPersonalListNavigationBar()
        super.init(coder: coder)
    }
    
    func createImageBrowser () {
        
        let browser = YBImageBrowser()
        
        let toolHander = YBIBToolViewHandler()
        toolHander.topView.operationType = .more
        toolHander.fromType = FromCircle_Person
        browser.toolViewHandlers = [toolHander]
        browser.backgroundColor = UIColor.black
        browser.delegate = self
        
        imageBrowser = browser
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fd_prefersNavigationBarHidden = true
        
        collectionView.frame = self.view.bounds
        
        self.view.addSubview(collectionView)
        self.view.addSubview(discoverNavigationBar)
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        
        collectionView.contentInset = UIEdgeInsets(top: -(self.view.cod_safeAreaInsets.top + 30), left: 0, bottom: 10, right: 0)
        
        collectionView.register(cellWithClass: CODDiscoverPersonalListCell.self)
        
        pageVM.$loadingState.bind(to: self.rx.loadingState)
            .disposed(by: self.rx.disposeBag)
        
        pageVM.showImageBrowserPR.bind(to: self.rx.showImageBrowserBinder)
            .disposed(by: self.rx.disposeBag)
        
        
        pageVM.fetchData() { [weak self] vms in
            
            guard let `self` = self else { return }
            
            if vms.count > 0 {
                self.createRefreshFooter()
            }
            
        }
        
        
    }
    
    func createRefreshFooter() {
        
        let refreshFooter = DiscoverPersonalListRefreshFooter { [weak self] in
            
            guard let `self` = self else { return }
            self.pageVM.fetchData(isHeaderLoad: false, pageNum: self.collectionView.pageNum + 1, size: self.collectionView.pageSize)
            
        }
        
        
        refreshFooter?.setTitle(NSLocalizedString("正在加载", comment: ""), for: .refreshing)
        refreshFooter?.setTitle("", for: .idle)
        refreshFooter?.setTitle("", for: .noMoreData)
        refreshFooter?.stateLabel.textColor = UIColor(hexString: "#8E8E8E")
        
        
        refreshFooter?.triggerAutomaticallyRefreshPercent = 0.1
        
        self.collectionView.mj_footer = refreshFooter
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let headerBGHeight: CGFloat = 302.5 * kScreenScale
        let threshold: CGFloat = discoverNavigationBar.height - 50
        
        if headerBGHeight - threshold > scrollView.contentOffset.y {
            discoverNavigationBar.configAlpha(0)
            discoverNavigationBar.hiddenYear()
            return
        }
        
        if headerBGHeight > scrollView.contentOffset.y {
            
            let alpha = 1.0 - ((headerBGHeight - scrollView.contentOffset.y) / threshold)
            
            discoverNavigationBar.configAlpha(alpha)
        } else {
            discoverNavigationBar.configAlpha(1)
        }
        
        let dataSourece = self.pageVM.dataSources
        
        if collectionView.visibleCells.count > 1 {
            
            let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems.sorted(by: \.item)
            
            let indexPath = indexPathsForVisibleItems[1]
            
            if dataSourece[indexPath.section].cellType != .date && dataSourece[indexPath.section].cellType != .year {
                return
            }
            
            if let cellFrame =  collectionView.layoutAttributesForItem(at: indexPath)?.frame {
                
                if discoverNavigationBar.height + 5 >= (collectionView.convert(cellFrame, to: collectionView.superview)).origin.y {
                    
                    if let model = dataSourece[indexPath.section].model {
                        discoverNavigationBar.showYear(year: Date(milliseconds: model.createTime).year.string)
                    } else {
                        discoverNavigationBar.showYear(year: Date().year.string)
                    }
                    
                    
                } else if let firstIndexPath = indexPathsForVisibleItems.first, dataSourece[firstIndexPath.section].cellType != .hander {
                    
                    if let model = dataSourece[indexPath.section].model {
                        discoverNavigationBar.showYear(year: Date(milliseconds: model.createTime).year.string)
                    } else {
                        discoverNavigationBar.showYear(year: Date().year.string)
                    }
                    
                } else {
                    discoverNavigationBar.hiddenYear()
                }
                
            }
            
        }
        
        
    }
    
    func cellType(indexPath: IndexPath) -> CODDiscoverPersonalListCellVM.CODDiscoverPersonalListCellType? {
        
        if indexPath.section < self.pageVM.dataSources.count {
            return self.pageVM.dataSources[indexPath.section].cellType
        }
        
        return nil
    }
    
    func yb_imageBrowser(_ imageBrowser: YBImageBrowser, pageChanged page: Int, data: YBIBDataProtocol) {
        
        if page > imageBrowser.dataSourceArray.count - 2 {
            
//            if collectionView.mj_footer != nil {
//                collectionView.mj_footer.beginRefreshing()
//            }
            
            self.pageVM.fetchData(isHeaderLoad: false, pageNum: self.collectionView.pageNum + 1, size: self.collectionView.pageSize) { _ in
                
                self.reloadImageBrowserData()
                
                
            }
            
            
        }
        
    }
    
    
    func reloadImageBrowserData() {
        
        let dataSourceArray = pageVM.loadImageAndVideoData()
        
       
        if imageBrowser?.dataSourceArray.count != dataSourceArray.count {
            imageBrowser?.dataSourceArray = dataSourceArray
            imageBrowser?.reloadData()
        }
        

    }
    
    deinit {
        imageBrowser = nil
    }
    
    
}
