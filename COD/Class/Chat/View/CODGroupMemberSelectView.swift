//
//  CODGroupMemberSelectView.swift
//  COD
//
//  Created by XinHoo on 2019/3/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON
import RxSwift
import RxCocoa
import RxDataSources

class CODGroupMemberSelectView: UIView{
        
    var scrollPointOfX = 0
    
    var placeholder: String? {
        didSet {
            placeholderLab.text = placeholder
        }
    }
    
    var searchCell: CODSelectViewSearchCell!
    
    lazy var searchCellVM: SelectedCellVM = {
        let vm = SelectedCellVM()
        vm.cellType = "CODSelectViewSearchCell"
        return vm
    }()
    
    var dataSource: BehaviorRelay<[SectionModel<String, SelectedCellVM>]> = BehaviorRelay(value: [SectionModel(model: "", items: [])])
    let disposeBag = DisposeBag()
    
    weak var delegate: CODGroupMemberSelectDelegate?
    
    weak var searchDelegate :CODGroupMemberSearchCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        self.addSubview(self.placeholderLab)
        
        self.placeholderLab.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(20)
        }
        
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(KScreenWidth)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(addSearchItem))
        tap.delegate = self
        self.collectionView.addGestureRecognizer(tap)
        
        self.addSubview(self.bottomLine)
        self.bottomLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        dataSource.accept([SectionModel(model: "", items: [self.searchCellVM])])
        
        self.configCollectionViewRxDataSource()
        
    }
    
    func configCollectionViewRxDataSource() {
        
        let dataSourceRx = RxCollectionViewSectionedReloadDataSource<SectionModel<String, SelectedCellVM>>(configureCell: { [weak self] (dataSources, collectionView, indexPath, model) -> UICollectionViewCell in
            guard let `self` = self else { return UICollectionViewCell() }
            if indexPath.row == self.collectionSource.count {
                var cell: CODSelectViewSearchCell!
                if self.searchCell == nil {
                    cell = collectionView.dequeueReusableCell(withClass: CODSelectViewSearchCell.self, for: indexPath)
                }else{
                    cell = self.searchCell
                }

                cell.delegate = self
                if self.searchCell == nil {
                    self.searchCell = cell
                }
                return cell
            }else{
                let cell:CODSelectViewNornalCell = collectionView.dequeueReusableCell(withClass: CODSelectViewNornalCell.self, for: indexPath)
                
                cell.memberText = model.text
                cell.isUserInteractionEnabled = model.isEnable

                return cell
            }
            
            
        })
        self.dataSource
            .bind(to: self.collectionView.rx.items(dataSource: dataSourceRx))
            .disposed(by: disposeBag)
        
        
    }
    
    // 传入的数据源
    var collectionSource:Array<AnyObject> = [] {
        didSet {
            
            var items = collectionSource.map { [weak self] (model) -> SelectedCellVM in
                guard let `self` = self else { return SelectedCellVM() }
                let selectedModel = SelectedCellVM()
                selectedModel.cellType = "CODSelectViewNornalCell"
                if let contactModel = model as? CODContactModel {
                    let text = contactModel.getContactNick()+","
                    selectedModel.text = text
                    selectedModel.jid = contactModel.jid
                    selectedModel.width = self.getTextSizeForSelectItem(text: text)
                    if contactModel.isUnableClick {
                        selectedModel.isEnable = false
                    }else{
                        selectedModel.isEnable = true
                    }
                }
                
                if let contactModel = model as? CODSearchResultContact {
                    let text = contactModel.name+","
                    selectedModel.text = text
                    selectedModel.userId = contactModel.userid
                    selectedModel.width = self.getTextSizeForSelectItem(text: text)
                }
                
                if let memberModel = model as? CODGroupMemberModel {
                    let text = memberModel.getMemberNickName()+","
                    selectedModel.text = text
                    selectedModel.jid = memberModel.jid
                    selectedModel.width = self.getTextSizeForSelectItem(text: text)
                }
                
                if let groupModel = model as? CODGroupChatModel {
                    let text = groupModel.getGroupName()+","
                    selectedModel.text = text
                    selectedModel.jid = groupModel.jid
                    selectedModel.width = self.getTextSizeForSelectItem(text: text)
                }
                return selectedModel
            }
            
            items.append(self.searchCellVM)
            
            self.dataSource.accept([SectionModel(model: "", items: items)])
        }
    }
    
    func setDataSource(objs: [AnyObject]) {
        guard objs.count > 0 else {
            return
        }
        self.collectionSource = objs
        self.collectionView.layoutIfNeeded()
        
        let height = getCollectionViewHeight()
        self.snp.updateConstraints { (make) in
            make.height.equalTo(height < 110 ? height : 83)
        }

        self.collectionView.scrollToItem(at: IndexPath.init(item: self.collectionSource.count-1, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
        updatePlaceholderLabWidth()
    }
    
    func addDataSource(obj: AnyObject) {
        self.collectionSource.append(obj)
        self.collectionView.layoutIfNeeded()
        updatePlaceholderLabWidth()
        let height = getCollectionViewHeight()
        if height > 0 && height <= 110 {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(height)
            }
        }else{
            self.collectionView.scrollToItem(at: IndexPath.init(item: self.collectionSource.count-1, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
        }
        
        
    }
    
    func deleteDataSource(object: AnyObject) {
        let index = self.collectionSource.firstIndex { (objectT) -> Bool in
            if let _ = object as? CODContactModel, let _ = objectT as? CODContactModel {
                let jid = object.value(forKey: "jid") as? String
                let jid2 = objectT.value(forKey: "jid") as? String
                return jid == jid2
            }
            if let _ = object as? CODSearchResultContact, let _ = objectT as? CODSearchResultContact{
                let userId = object.value(forKey: "userid") as? String
                let userId2 = objectT.value(forKey: "userid") as? String
                return userId == userId2
            }
            return false
        }
        self.collectionSource.remove(at: index ?? 0)
        self.collectionView.layoutIfNeeded()
        updatePlaceholderLabWidth()
        
        let height = getCollectionViewHeight()
        if height > 0 && height <= 110 {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(height)
            }
        }
    }
    
    func deleteDataSource(index: Int) {
        guard index >= 0 else {
            return
        }
        self.collectionSource.remove(at: index)
        self.collectionView.layoutIfNeeded()
        updatePlaceholderLabWidth()
        
        let height = getCollectionViewHeight()
        if height > 0 && height <= 110 {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(height)
            }
        }
    }
    
    func updatePlaceholderLabWidth() {
        if collectionSource.count > 0 || self.searchCell.textField.text?.count ?? 0 > 0 {
            self.placeholderLab.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
        }else{
            self.placeholderLab.snp.updateConstraints { (make) in
                make.width.equalTo(300)
            }
        }
    }
    
    func getCollectionViewHeight(isAdditionEdit: Bool = false) -> CGFloat {
        var width:CGFloat = 5+5
        var height:CGFloat = 5+34+5
        if isAdditionEdit {
            width = width + 80
        }

        for model in self.dataSource.value[0].items {
            let textSize = model.width
            width = width+textSize+5
            if width > KScreenWidth {
                width = 5+textSize+5
                height += 39
            }
            if height > 110 {
                break
            }
        }
        return height
    }
    
    func getSelectSearchCellWidth() -> CGFloat {
        var width:CGFloat = 5+5
        
        for model in self.dataSource.value[0].items {
            let textSize = model.width
            width = width+textSize+5
            if width > KScreenWidth {
                width = textSize+5+5
            }
        }
        width = KScreenWidth - width - 20  //(额外减掉20)否则计算不准确
        if width <= 80 {
            width = KScreenWidth - 20
        }
        return width
    }
    
    
    private  lazy var flowLayout: CODEqualSpaceFlowLayout = {
        let flowLayout = CODEqualSpaceFlowLayout()
        flowLayout.estimatedItemSize = CGSize.init(width: 42, height: 34)
        return flowLayout
    }()
    
    lazy var placeholderLab: UILabel = {
        let lab = UILabel()
        lab.text = "请选择联系人"
        lab.font = UIFont.systemFont(ofSize: 15.0)
        lab.textColor = UIColor.init(hexString: kSubTitleColors)
        return lab
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(nibWithCellClass: CODSelectViewNornalCell.self)
        collectionView.register(nibWithCellClass: CODSelectViewSearchCell.self)
        return collectionView
    }()
    
    lazy var bottomLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexString: kSepLineColorS)
        return v
    }()
    
    @objc func addSearchItem(tap:UITapGestureRecognizer) {
        let height = getCollectionViewHeight(isAdditionEdit: true)
        if height > 0 && height <= 110 {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(height)
            }
            self.collectionView.reloadData {
                
                self.searchCell.textField.becomeFirstResponder()
            }
        }else{
            self.searchCell.textField.becomeFirstResponder()
        }
        
        
    }
    
    func getTextSizeForSelectItem(text: String) -> CGFloat {
        return text.getStringWidth(font: UIFont.systemFont(ofSize: 15.0), lineSpacing: 0, fixedWidth: KScreenWidth-10)
    }
    
    func textFieldTextIsEmpty() -> Bool {
        if searchCell.textField.text?.count ?? 0 > 0 {
            return false
        }else{
            return true
        }
    }
    
    func clearTextField() {
        searchCell.textField.text = ""
    }
    
}

extension CODGroupMemberSelectView : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == self.collectionSource.count {
            return CGSize(width: self.getSelectSearchCellWidth(), height: 34.0)
        }
        let model = self.dataSource.value[0].items[indexPath.row]
        return CGSize(width: model.width, height: 34.0)
    }
}

extension CODGroupMemberSelectView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.collectionSource.count {
            return
        }
        let object = collectionSource[indexPath.row]
        deleteDataSource(index: indexPath.row)
        if let _ = object as? CODContactModel {
            let contactArr = self.collectionSource.filter { (object) -> Bool in
                return !object.isKind(of: CODSearchResultContact.self)
            }
            if delegate != nil{
                delegate?.didSelectDeleteMember(modelArr: contactArr)
            }
        }
        if let _ = object as? CODGroupMemberModel {
            if delegate != nil{
                delegate?.didSelectDeleteMember(modelArr: self.collectionSource)
            }
        }
        if let contactModel = object as? CODSearchResultContact {
            delegate?.didSelectDeleteSearchContact(searchUser: contactModel)
        }
        
        if let _ = object as? CODGroupChatModel {
            delegate?.didSelectDeleteMember(modelArr: self.collectionSource)
        }
        
    }
}

extension CODGroupMemberSelectView: CODSelectViewSearchDelegate{
    func searchFieldShouldBeginEditing(_ field: UITextField) -> Bool {
        self.collectionView.reloadItems(at: [IndexPath.init(row: self.collectionSource.count, section: 0)])
        self.collectionView.scrollToItem(at: IndexPath.init(row: self.collectionSource.count, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
        
        return true
    }
    
    func searchFieldDidEndEditing(_ field: UITextField) {
        if self.collectionSource.count > 0 && field.text?.count ?? 0 <= 0 {
            
            self.collectionView.scrollToItem(at: IndexPath.init(row: self.collectionSource.count-1, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
        }
    }
    
    
    func searchTextDidEditChange(field: UITextField) {
        if field.text?.count ?? 0 > 0 || self.collectionSource.count > 0 {
            self.placeholderLab.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
        }else{
            self.placeholderLab.snp.updateConstraints { (make) in
                make.width.equalTo(300)
            }
        }
        
        if self.searchDelegate != nil {
            self.searchDelegate!.selectViewSearchTextDidEditChange(field: field)
        }
        
    }
    
    func deleteMember() {
        if self.collectionSource.count > 0 {
            let model = self.collectionSource[self.collectionSource.count-1]
            if let contactModel = model as? CODContactModel {
                if contactModel.isUnableClick {
                    return
                }
            }
            self.deleteDataSource(index: self.collectionSource.count-1)
            if self.searchDelegate != nil {
                self.searchDelegate!.selectViewDeleteMember()
            }
        }
    }
    
    
}



protocol CODGroupMemberSelectDelegate : NSObjectProtocol {
    
    /// 将每个model传出去，然后在返回 url
    func didSelectDeleteMember(modelArr:Array<AnyObject>)
    
    /// 将每个model传出去，然后在返回 url
    func didSelectDeleteSearchContact(searchUser: CODSearchResultContact)
    
    /// 将CollectionView的contentSize传出去，以便移动GroupMemberSearchView
    func collectionViewsContentSizeDidChange(height:CGFloat)
    
}

@objc protocol CODGroupMemberSearchCellDelegate : NSObjectProtocol {
    func selectViewSearchTextDidEditChange(field: UITextField)
    func selectViewDeleteMember()
}

extension CODGroupMemberSelectView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.size.width) ?? 0 < KScreenWidth {  //因为获取不了touch.view的类名，所以只能通过它的宽度来判断，
            return false
        }
        return true
    }
}



protocol SelectedCellType: IdentifiableType, Equatable {
    
    var cellType: String { get }
    var cellHeight: CGFloat { get set }
    
}

class SelectedCellVM: NSObject, SelectedCellType {
    
    var text: String = ""
    var width: CGFloat = 0.0
    var jid: String = ""
    var userId: String = ""
    var isEnable: Bool = true
    
    
    var cellType: String = ""
    var identity: String {
        return self.cellType
    }
    
    var cellHeight: CGFloat = 0.0
    
    static func == (lhs: SelectedCellVM, rhs: SelectedCellVM) -> Bool {
        return lhs.cellType == rhs.cellType && lhs.identity == rhs.identity
    }
    
}

