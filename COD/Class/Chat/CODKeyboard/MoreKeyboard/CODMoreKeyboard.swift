//
//  CODMoreKeyboard.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit


/// 更多键盘
var WIDTH_CELL:CGFloat = (KScreenWidth-60)/4 - 10
var SPACE_TOP:CGFloat = 15

class CODMoreKeyboard: CODBaseKeyboard {
    public var chatMoreKeyboardData:[CODMoreKeyboardItem]?{
        didSet{
            self.updataMoreKeyboardData()
        }
    }
    fileprivate let pageItemCount:Int = 8 ///一页的个数
    weak var delegate: CODMoreKeyboardDelegate?
    fileprivate  let  CODMoreKeyboardCell_identity = " CODMoreKeyboardCell_identity"
    fileprivate var photoPickerManger:CODPhotoPickerManger? = nil
    
    //显示视图
    fileprivate lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.white
        collectionView.scrollsToTop = false
        collectionView.register( CODMoreKeyboardCell.self, forCellWithReuseIdentifier: CODMoreKeyboardCell_identity)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.backgroundColor = UIColor.colorGrayForChatBar
        self.backgroundColor = UIColor.white
        self.addSubview(self.collectionView)
        self.addSnpKit()
        ///开始请求图片
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(0.5)
        context?.setStrokeColor(UIColor(white: 0.5, alpha: 0.3).cgColor)
        context?.beginPath()
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addLine(to: CGPoint(x: KScreenWidth, y: 0))
        context?.strokePath()
    }
    ///添加约束
    fileprivate func addSnpKit(){
        self.collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-30)

        }
    }
    fileprivate func updataMoreKeyboardData(){
        self.collectionView.reloadData()
    }
}

extension  CODMoreKeyboard:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func transformModel(row:Int,page:Int) -> Int {
        let x = row / 2 ///当前所在的列数
        let y = row % 2 ///当前所在的行数
        return (self.pageItemCount / 2) * y + x + page * self.pageItemCount ///这个是正确的通过行数和列数
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int{
        let page = (self.chatMoreKeyboardData?.count)! / self.pageItemCount +  ((self.chatMoreKeyboardData?.count)! %  self.pageItemCount == 0 ? 0:1)
        return page
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return pageItemCount
    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier:  CODMoreKeyboardCell_identity, for: indexPath) as?   CODMoreKeyboardCell
        if cell == nil {
            cell =  CODMoreKeyboardCell(frame: CGRect.zero)
        }
        let index = self.transformModel(row: indexPath.row, page: indexPath.section)
        if index < (self.chatMoreKeyboardData?.count)!{
            cell?.item = self.chatMoreKeyboardData![index]
        }else{
            cell?.item = nil
        }
        cell?.clickBlock = { [unowned self] (_ item: CODMoreKeyboardItem) in
            if self.delegate != nil {
                self.delegate?.moreKeyboardDidSelectedFunctionItem(keyboard: self, funcItem: item)
            }
        }
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: WIDTH_CELL, height: (collectionView.height - SPACE_TOP)/2 * 0.95)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return (collectionView.width - WIDTH_CELL * CGFloat(self.pageItemCount/2)) / CGFloat(self.pageItemCount/2 + 1)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return  (collectionView.height - SPACE_TOP)/2 * 0.05
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let spac = (collectionView.width - WIDTH_CELL * CGFloat(self.pageItemCount/2)) / CGFloat(self.pageItemCount/2 + 1)
        return UIEdgeInsets(top: 0, left: spac, bottom: SPACE_TOP, right: spac)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = self.transformModel(row: indexPath.row, page: indexPath.section)

        let model = self.chatMoreKeyboardData![index]
        if index < (self.chatMoreKeyboardData?.count)!{
            if self.delegate != nil {
                self.delegate?.moreKeyboardDidSelectedFunctionItem(keyboard: self, funcItem: model)
            }
        }
    }
}
//高度
extension CODMoreKeyboard{
    
    override func keyboardHeight() -> CGFloat {
        return HEIGHT_CHAT_KEYBOARD
    }
}

protocol  CODMoreKeyboardDelegate:NSObjectProtocol{
    
    /// 选中itme
    ///
    /// - Parameters:
    ///   - keyboard: 更多键盘
    ///   - funcItem: 类型
    func moreKeyboardDidSelectedFunctionItem(keyboard: CODMoreKeyboard,funcItem: CODMoreKeyboardItem)
    
    //进入拍照
    ///
    /// - Parameter keyboard: 更多键盘
    func moreKeyboardPushUIImagePickerController(keyboard: CODMoreKeyboard)
    
    /// 选中上面的图片
    ///
    /// - Parameters:
    ///   - keyboard: 更多键盘
    ///   - item: 图片
    func moreKeyboardDidSelectedPhotoAssetItem(keyboard: CODMoreKeyboard,item:CODPhotoAsset)
}

