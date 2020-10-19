//
//  CODEmojiGroupDisplayView.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//


import UIKit

class CODEmojiGroupDisplayView: UIView {
    weak var delegate:CODEmojiGroupDisplayViewDelegate?
    fileprivate let CODEmojiFaceItemCell_identity = "CODEmojiFaceItemCell_identity"
    fileprivate let CODEmojiImageItemCell_identity = "CODEmojiImageItemCell_identity"
    fileprivate let CODEmojiHeader_identity = "CODEmojiHeader_identity"
    fileprivate var lastPosition:CGFloat = 0
    fileprivate var curPageIndex:Int = 0
    fileprivate var lastCell:UICollectionViewCell?
    fileprivate var lastEmoji:CODExpressionModel?
    fileprivate var isNeedScroll: Bool = true
    fileprivate let Header_height: CGFloat = 30

    fileprivate lazy var displayData:[CODExpressionModel] = {
        let displayData = [CODExpressionModel]()
        return displayData
    }()
    ///常用表情数组
    fileprivate lazy var commonlyEmojiArray:[CODExpressionModel] = {
        let commonlyEmojiArray = [CODExpressionModel]()
        return commonlyEmojiArray
    }()
    public var emojiGroupData:[CODExpressionGroupModel]? {
        didSet{
            ///更新数据
            ///注意在这里要对数据进行处理
            self.setUpeEmojiGroup()
        }
    }
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
//        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = UIColor.white
        collectionView.scrollsToTop = false
        collectionView.bounces = false
        ///注册单元格
//        collectionView.register(CODEmojiFaceItemCell.self, forCellWithReuseIdentifier: CODEmojiFaceItemCell_identity)
        collectionView.register(UINib(nibName: "CODFaceItemCell", bundle: nil), forCellWithReuseIdentifier: CODEmojiFaceItemCell_identity)
        collectionView.register(UINib(nibName: "CODFaceImageCell", bundle: nil), forCellWithReuseIdentifier: CODEmojiImageItemCell_identity)

        ///注册组头
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CODEmojiHeader_identity)
        return collectionView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
        setUpLayout()
        addGusture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setUpSubviews() {
        self.addSubview(self.collectionView)
    }
    fileprivate func setUpLayout(){
        self.collectionView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview().offset(0)
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self).offset(0)
        }
    }
    ///重组数据
    public func setUpeEmojiGroup(){
        if (self.emojiGroupData?.count ?? 0) > 0 {
            self.height = HEIGHT_CHAT_KEYBOARD - 57
            self.width = KScreenWidth
            let group  =  self.emojiGroupData![self.curPageIndex];
            var cellWidth:CGFloat = 0,cellHeight:CGFloat = 0,spaceX:CGFloat = 0,spaceYTop:CGFloat = 0,spaceYBottom:CGFloat = 0
            cellWidth = ((self.width - 24)/CGFloat(group.colNumber))///表情的宽度
            spaceX = (self.width - cellWidth * CGFloat(group.colNumber)) / 2.0
            if (group.type == .CODEmojiTypeEmoji || group.type == .CODEmojiTypeFace) {
//                cellHeight = (self.height - 10) / CGFloat(group.rowNumber) - 10
                spaceX = 6
                cellWidth = 40
                cellHeight = 40
                spaceYTop = 0            
                spaceYBottom  = 0
            }else if (group.type == .CODEmojiTypeImageWithTitle) {
//                cellHeight = (self.height - 10) / CGFloat(group.rowNumber)
//                spaceYTop = 5
//                spaceYBottom = (self.height - cellHeight * CGFloat(group.rowNumber)) - spaceYTop
                spaceX = 20
                cellWidth = 62
                cellHeight = 90
                spaceYTop = 4
                spaceYBottom  = 4

            }else{
                cellHeight = (self.height - 20) / CGFloat(group.rowNumber)
                spaceYTop = 10
                spaceYBottom = (self.height - cellHeight * CGFloat(group.rowNumber)) - spaceYTop
            }
            
            let cellSize = CGSize(width: cellWidth, height: cellHeight)
            let sectionInsets = UIEdgeInsets(top: spaceYTop, left: spaceX, bottom: spaceYBottom, right: spaceX)
            if group.data?.isEmpty == false{
                self.displayData.removeAll()
                ///遍历数组
                for model in  group.data! {
                    model.cellSize = cellSize
                    model.sectionInsets = sectionInsets
                    self.displayData.append(model)
                }
            }
            self.commonlyEmojiArray = CODExpressionModel.getAllCommmonLyEmoji(cellSize: cellSize, sectionInsets: sectionInsets)
            self.collectionView.reloadData()
            self.collectionView.scrollToTopWithAnimation(animation: false)
        }
    }
    /// 指定到一组表情对象
    ///
    /// - Parameter index: 下标
    public func scrollToEmojiGroupAtIndex(index:NSInteger){
        if index > (self.emojiGroupData?.count)! {
            return
        }
        self.curPageIndex = index ///表情组
        self.setUpeEmojiGroup()
        self.collectionView.reloadData()
        self.collectionView.scrollToTopWithAnimation(animation: false)
        if index == 0 {
           self.faceButtonDown()
        }
    }
}

extension CODEmojiGroupDisplayView{

    func commonFaceButtonDown(){
        self.lastPosition = 0
        if self.curPageIndex != 0 {
            self.curPageIndex = 0 ///表情组
            self.setUpeEmojiGroup()
            self.collectionView.reloadData()
        }
        self.collectionView.scrollToTopWithAnimation(animation: false)
    }
    
    func faceButtonDown() {
      
        if(self.curPageIndex == 0 && self.commonlyEmojiArray.count > 0){
            //  滚动到指定的位置
            let selectedIndexPath = IndexPath(item:0 , section: 1)
            self.isNeedScroll = false
            if let attributes = collectionView.layoutAttributesForItem(at: selectedIndexPath){
                let rect = attributes.frame
                collectionView.setContentOffset(CGPoint(x: collectionView.frame.origin.x, y: rect.origin.y - Header_height), animated: false)
            }
        }else{
            self.isNeedScroll = false
            self.collectionView.scrollToTopWithAnimation(animation: false)
        }
    }
}

extension CODEmojiGroupDisplayView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func transformModel(rowCount:Int,colCount:Int,row:Int) -> Int {
        let x = row / rowCount ///当前所在的列数（这个是以前的那种错误的布局方法）
        let y = row % rowCount ///当前所在的行数（这个是以前的那种错误的布
        return colCount * y + x ///这个是正确的通过行数和列数
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int{
        if(self.curPageIndex == 0){
            return 2
        }else{
            return 1
        }
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if(self.curPageIndex == 0){
            if(section == 0){
                return self.commonlyEmojiArray.count
            }else{
                return self.displayData.count
            }
        }else{
            return self.displayData.count
        }
    }
    func getIndexItem(indexPath: IndexPath) -> CODExpressionModel{
        var emjikModel:CODExpressionModel;
        if(self.curPageIndex == 0){
            if(indexPath.section == 0 && self.commonlyEmojiArray.count > indexPath.row ){
                emjikModel = self.commonlyEmojiArray[indexPath.row]
            }else{
                emjikModel = self.displayData[indexPath.row]
            }
        }else{
            emjikModel = self.displayData[indexPath.row]
        }
        return emjikModel
    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let emjikModel = self.getIndexItem(indexPath: indexPath)

        if emjikModel.type == .CODEmojiTypeEmoji || emjikModel.type == .CODEmojiTypeFace{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CODEmojiFaceItemCell_identity, for: indexPath) as? CODFaceItemCell
            cell!.titleLable.text = emjikModel.name
            return cell!

        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CODEmojiImageItemCell_identity, for: indexPath) as? CODFaceImageCell
            if let bundlePath = Bundle.main.url(forResource: emjikModel.name, withExtension: "gif"),let fileData = NSData.init(contentsOf: bundlePath){
                cell?.iconImageView.animatedImage = FLAnimatedImage.init(animatedGIFData: fileData as Data)
                cell?.iconNameLabel.text = emjikModel.emojiName
            }
            return cell!
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emjikModel = self.getIndexItem(indexPath: indexPath)
        if(indexPath.section != 0 && self.curPageIndex == 0){
            self.commonlyEmojiArray = CODExpressionModel.saveEmojiCommmonLy(model: emjikModel, cellSize: emjikModel.cellSize ?? CGSize(width: 0, height: 0), sectionInsets: emjikModel.sectionInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            self.collectionView.reloadData()
        }
        if (self.delegate != nil){
            self.delegate?.emojiGroupDisplayViewDidClicked(displayView:self, didSelectEmoji: emjikModel)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let group = self.displayData[indexPath.row]
        ///这里取出来的时候要注意 这个
        return group.cellSize!
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        ///注意没有数据不要设置间隙
        if(self.curPageIndex == 0 && section == 0 && self.commonlyEmojiArray.count == 0){
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }else{
            let group = self.displayData[section]
            ///这里取出来的时候要注意 这个
            return group.sectionInsets!
        }
    }
    ///设置组头视图和高度
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //1.取出section的headerView
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CODEmojiHeader_identity, for: indexPath) as UICollectionReusableView
        headerView.removeSubviews()
        headerView.backgroundColor = UIColor.white
//        if(self.commonlyEmojiArray.count > 0){
            var cellY: CGFloat = 0
            if indexPath.section == 0 {
                cellY = 12
            }else{
                cellY = 5.5
            }
            let label = UILabel(frame: CGRect(x: 10, y: cellY, width: KScreenWidth - 20, height: 17))
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = RGBA(r: 200, g: 200, b: 200, a: 1)
        if self.curPageIndex == 0 {
            if(indexPath.section == 0){
                 if(self.commonlyEmojiArray.count > 0){
                     label.text = NSLocalizedString("常用", comment: "")
                 }else{
                     label.text = NSLocalizedString("表情符号与人物", comment: "")
                 }
             }else{
                 label.text = NSLocalizedString("表情符号与人物", comment: "")
             }
        }else{
            let group  =  self.emojiGroupData![self.curPageIndex];
            label.text = NSLocalizedString(group.name ?? "", comment: "")
        }
        headerView.addSubview(label)
        return headerView
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var sectionH: CGFloat = 30
        if section == 0 {
            sectionH = 34.5
        }
        if section == 0 {
            return CGSize(width: KScreenWidth, height: sectionH)
        }else{
            return self.commonlyEmojiArray.count > 0 ? CGSize(width: KScreenWidth, height: sectionH) : CGSize(width: 0, height: 0)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let emjikModel = self.getIndexItem(indexPath: indexPath)
         if emjikModel.type == .CODEmojiTypeEmoji || emjikModel.type == .CODEmojiTypeFace{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CODEmojiFaceItemCell_identity, for: indexPath) as? CODFaceItemCell
            cell!.titleLable.text = emjikModel.name
         }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CODEmojiImageItemCell_identity, for: indexPath) as? CODFaceImageCell
            cell?.iconImageView.setGifImage(identifier: emjikModel.name ?? "")
            cell?.iconNameLabel.text = emjikModel.emojiName
         }
    }
}

// MARK: - UIScrollViewDelegate
extension CODEmojiGroupDisplayView:UIScrollViewDelegate{
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if !isNeedScroll {
//            isNeedScroll = true
//            return
//        }
//        let currentPostion = scrollView.contentOffset.y;
//        if (currentPostion - self.lastPosition > 10) {
//            self.lastPosition = currentPostion;
//            ///ScrollUp now
//            if self.delegate != nil{
//                self.delegate?.emojiDisplayViewScrollStatus(displayView: self, isScrollUp: true)
//            }
//        }else if(self.lastPosition - currentPostion > 10){
//            self.lastPosition = currentPostion;
//            //ScrollDown now
//            if self.delegate != nil{
//                self.delegate?.emojiDisplayViewScrollStatus(displayView: self, isScrollUp: false)
//            }
//        }else{
//            self.lastPosition = currentPostion;
//        }
//    }
}
// MARK: - LongPress
extension CODEmojiGroupDisplayView{
    fileprivate func addGusture(){
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        self.collectionView.addGestureRecognizer(longPressGR)
    }
    /// 长按手势
    ///
    /// - Parameter sender: 长按
    @objc func longPressAction(_ sender : UILongPressGestureRecognizer){
        //        let group = self.displayData[self.curPageIndex] ///当前的表情页
        //        let point = sender.location(in: self.collectionView)
        //        if sender.state == .ended || sender.state == .cancelled {
        //            self.lastCell = nil
        //            self.cancelLongPressEmoji()
        //        }else if sender.state == .began{
        //            let visableCells = self.collectionView.visibleCells
        //            for cell in visableCells{
        //                if cell.x <= point.x && cell.y <= point.y && cell.x + group.cellSize!.width >= point.x && cell.y + group.cellSize!.height >= point.y {
        //                    let indexPath = self.collectionView.indexPath(for: cell)
        //                    let emjikModel = self.displayData[indexPath?.row ?? 0]
        //                    if ((emjikModel.type  == .CODEmojiTypeFace || emjikModel.type == .CODEmojiTypeEmoji) &&  emjikModel.eid == "-1"){
        //                        return
        //                    }else{
        //                        var rect = cell.frame
        //                        rect.origin.x = rect.origin.x - self.width * floor(rect.origin.x/self.width)
        //                        self.startLongPressEmoji(emjikModel: emjikModel, rect: rect)
        //                    }
        //                }
        //            }
        //            ///开始长按的cell
        //            lastCell = nil;
        //        }else{
        //            let visableCells = self.collectionView.visibleCells
        //            for cell in visableCells{
        //                if cell.x <= point.x && cell.y <= point.y && cell.x + group.cellSize!.width >= point.x && cell.y + group.cellSize!.height >= point.y {
        //                    if (cell == lastCell) {///相同的
        //                        return;
        //                    }
        //                    let indexPath = self.collectionView.indexPath(for: cell)
        //                    let emjikModel = self.displayData[indexPath?.row ?? 0]
        //                    if emjikModel.name == ""{///没有表情是空的
        //                        self.cancelLongPressEmoji()///取消
        //                        lastCell = cell;
        //                        return
        //                    }
        //                    if emjikModel.type  == .CODEmojiTypeFace || emjikModel.type == .CODEmojiTypeEmoji &&  emjikModel.eid == "-1"{///取消
        //                        self.cancelLongPressEmoji()
        //                    }else{
        //                        var rect = cell.frame
        //                        rect.origin.x = rect.origin.x - self.width * floor(rect.origin.x/self.width)
        //                        self.startLongPressEmoji(emjikModel: emjikModel, rect: rect)
        //                    }
        //                    lastCell = cell;
        //                    return;
        //                }
        //            }
        //            // 超出界限
        //            if ((self.lastCell) != nil) {
        //                self.cancelLongPressEmoji()
        //                self.lastCell = nil
        //            }
        //        }
    }
    fileprivate func startLongPressEmoji(emjikModel:CODExpressionModel,rect:CGRect){
        if self.delegate != nil{
            self.delegate?.emojiGroupDisplayViewdDidLongPressEmoji(displayView: self, emoji: emjikModel, atRect: rect)
        }
        
    }
    fileprivate func cancelLongPressEmoji(){
        if (self.lastEmoji != nil) {
            self.lastEmoji = nil
            if self.delegate != nil{
                self.delegate?.emojiGroupDisplayViewdEndLongPressEmoji(displayView: self)
            }
        }
    }
}
/// MARK: - CODEmojiGroupDisplayViewDelegate
protocol CODEmojiGroupDisplayViewDelegate:NSObjectProtocol
{
    
    /// 删除按钮
    ///
    /// - Parameter displayView: 显示视图
    func emojiGroupDisplayViewDeleteButtonPressed(displayView:CODEmojiGroupDisplayView)
    
    /// 选中的表情
    ///
    /// - Parameters:
    ///   - displayView: 显示视图
    ///   - didSelectEmoji: 点击的表情
    func emojiGroupDisplayViewDidClicked(displayView:CODEmojiGroupDisplayView,didSelectEmoji:CODExpressionModel)
    
    /// 翻页
    ///
    /// - Parameters:
    ///   - displayView: xians
    ///   - pageIndex: 当前表情组页数
    ///   - forGroupIndex: 当前表情组
    func emojiGroupDisplayViewDidScrollToPageIndex(displayView:CODEmojiGroupDisplayView,pageIndex:NSInteger)
    
    
    /// 表情长按
    ///
    /// - Parameters:
    ///   - displayView: 显示的视图
    ///   - emoji: 表情
    ///   - atRect: 位置
    func emojiGroupDisplayViewdDidLongPressEmoji(displayView:CODEmojiGroupDisplayView,emoji:CODExpressionModel,atRect:CGRect)
    
    /// 结束表情长按
    ///
    /// - Parameter displayView: 显示的视图
    func emojiGroupDisplayViewdEndLongPressEmoji(displayView:CODEmojiGroupDisplayView)
    
    /// 滚动的方向
    ///
    /// - Parameter displayView: 显示的视图
    func emojiDisplayViewScrollStatus(displayView:CODEmojiGroupDisplayView,isScrollUp:Bool)
    
}

