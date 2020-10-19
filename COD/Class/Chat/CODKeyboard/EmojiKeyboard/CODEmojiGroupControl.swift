//
//  CODEmojiGroupControl.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

/// 表情键盘下面的功能栏
class CODEmojiGroupControl: UIView {
    fileprivate let WIDTH_EMOJIGROUP_CELL:CGFloat = 50
    fileprivate let CODEmojiGroupCell_identity = "CODEmojiGroupCell_identity"
    weak var delegate:CODEmojiGroupControlDelegate?
    var emojiGroupData:[CODExpressionGroupModel]? {
        didSet{
            ///更新数据
            self.collectionView.reloadData()
            self.layoutIfNeeded()
            self.collectionView.selectItem(at: self.curIndexPath as IndexPath, animated: false, scrollPosition: .init(rawValue:0))
            if self.delegate != nil{
                let group = emojiGroupData![0]
                self.delegate?.didSelectedGroup(emojiGroupControl: self, group: group, groupIndex: 0)
            }
        }
    }

    //是否需要发送按钮，默认为聊天里面是不需要的
    var isNeedSendBtn = false {
        didSet{
            self.updateIfNeedSendBtn()
        }
    }
    
    ///当前选中的curIndexPath
    fileprivate lazy var curIndexPath:IndexPath = {
        let curIndexPath = IndexPath(item: 0, section: 0)
        return curIndexPath
    }()
    fileprivate lazy var commonFaceButton:UIButton = {
        let addBtn = UIButton(frame: CGRect.zero)
        addBtn.setImage(UIImage(named:"emojiKB_groupControl_Common"), for: .normal)
        addBtn.addTarget(self, action: #selector(emojiCommonFaceButtonDown(button:)), for: .touchUpInside)
        return addBtn
    }()
//    fileprivate lazy var settingBtn:UIButton = {
//        let settingBtn = UIButton(frame: CGRect.zero)
//        settingBtn.setImage(UIImage(named:"emojiKB_emoji"), for: .normal)
//        settingBtn.addTarget(self, action: #selector(emojicommonFaceButtonDown), for: .touchUpInside)
//        return settingBtn
//    }()
    fileprivate lazy var delBtn:UIImageView = {
        let delBtn = UIImageView.init()
        delBtn.isUserInteractionEnabled = true
        delBtn.contentMode = .scaleAspectFill
        return delBtn
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CODEmojiGroupCell.self, forCellWithReuseIdentifier: CODEmojiGroupCell_identity)
        return collectionView
    }()
    lazy var lineView: UIView = {
        let lineV = UIView()
        lineV.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        return lineV
    }()
    lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .custom)
        sendButton.setImage(UIImage.sendIcon(), for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonDown), for:  .touchUpInside)
        return sendButton
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setUpSubviews()
        setUpLayout()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setUpSubviews(){
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(emojiDelButtonDown))
        self.delBtn.addGestureRecognizer(tap)
        self.delBtn.isUserInteractionEnabled = true
        
        self.addSubview(self.commonFaceButton)
        self.addSubview(self.delBtn)
        self.addSubview(self.collectionView)
//        self.addSubview(self.settingBtn)
    }
    fileprivate func setUpLayout(){
        self.commonFaceButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalTo(self).offset(-kSafeArea_Bottom)
            make.height.width.equalTo(36)
//            make.centerY.equalToSuperview()
            make.left.equalTo(self).offset(4)
        }
        let line = UIView.init()
        line.backgroundColor =  UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 0.5)
        self.addSubview(line)
        
        line.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(1)
        }
        
        self.delBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-kSafeArea_Bottom)
            make.right.top.equalToSuperview()
            make.width.equalTo(WIDTH_EMOJIGROUP_CELL)
        }
        
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalTo(self).offset(-kSafeArea_Bottom)
            make.left.equalTo(self.commonFaceButton.snp.right).offset(0)
            make.right.equalTo(self.delBtn.snp.left).offset(0)
        }
        
        let buttonImage = UIImage(named:"emojiKB_emoji_delete")
        let resizeImage = buttonImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8), resizingMode: .stretch)
        delBtn.image = resizeImage
    }
    
    func updateIfNeedSendBtn() {
        if isNeedSendBtn {
             self.addSubview(self.sendButton)
             self.addSubview(self.lineView)
            
            self.sendButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(self).offset(-kSafeArea_Bottom)
                make.right.top.equalToSuperview()
                make.width.equalTo(WIDTH_EMOJIGROUP_CELL)
            }
            
            self.lineView.snp.makeConstraints { (make) in
                make.right.equalTo(self.sendButton.snp.left)
                make.centerY.equalTo(self.sendButton)
                make.height.equalTo(33)
                make.width.equalTo(1)
            }
            
            self.delBtn.snp.remakeConstraints { (make) in
                make.bottom.equalTo(self).offset(-kSafeArea_Bottom)
                make.right.equalTo(self.lineView.snp.left)
                make.width.equalTo(WIDTH_EMOJIGROUP_CELL)
            }
        }
    }
    
    @objc fileprivate func emojiCommonFaceButtonDown(button: UIButton){
        button.isSelected = !button.isSelected
        self.collectionView.reloadData()
        if delegate != nil{
            self.delegate?.emojiGroupControlCommonFaceButtonDown(emojiGroupControl: self)
        }
    }
    @objc fileprivate func sendButtonDown(){
        if delegate != nil{
            self.delegate?.emojiGroupControlSendButtonDown(emojiGroupControl: self)
        }
    }
    @objc fileprivate func emojiDelButtonDown(){
        if self.delegate != nil{
            self.delegate?.emojiGroupControlDelButtonDown(emojiGroupControl: self)
        }
    }
    
    /// 设置选中的下标
    ///
    /// - Parameter index: 当前的下标
    public func selectEmojiGroupAtIndex(index:Int){
        if self.emojiGroupData?.isEmpty == false{
            if index < (self.emojiGroupData?.count)! {
                self.curIndexPath = IndexPath(row: index, section: 0)
                ///选中
                self.collectionView.selectItem(at: self.curIndexPath as IndexPath, animated: false, scrollPosition: .init(rawValue:0))
                ///看是否要偏移
                let x = WIDTH_EMOJIGROUP_CELL * CGFloat(index)
                if x < self.collectionView.contentOffset.x{///这是向左移动
                    self.collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
                }else if (x > self.collectionView.contentOffset.x + self.collectionView.width){///这个全部超过了 要向右移动
                    self.collectionView.setContentOffset(CGPoint(x: x - self.collectionView.width, y: 0), animated: true)
                }
            }
        }
    }
}

extension CODEmojiGroupControl:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.emojiGroupData?.isEmpty == false{
            return self.emojiGroupData!.count
        }else{
            return 0
        }
    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: CODEmojiGroupCell_identity, for: indexPath) as? CODEmojiGroupCell
        if cell == nil {
            cell = CODEmojiGroupCell(frame: .zero)
        }
        //        if indexPath.row == 1{
        //            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
        //        }
        let group = self.emojiGroupData![indexPath.row]
        cell!.emojiGroup = group
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.emojiGroupData![indexPath.row]
        if self.delegate != nil{
            self.delegate?.didSelectedGroup(emojiGroupControl: self, group: model, groupIndex: indexPath.row)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:WIDTH_EMOJIGROUP_CELL, height: groupControlHeight)
    }
    
}

///协议
protocol CODEmojiGroupControlDelegate:NSObjectProtocol
{
    
    /// 选中一组表情
    ///
    /// - Parameters:
    ///   - emojiGroupControl: 表情视图下面的功能栏
    ///   - group: 表情组
    func didSelectedGroup(emojiGroupControl:CODEmojiGroupControl,group:CODExpressionGroupModel,groupIndex:Int)
    
    /// 添加表情组
    ///
    /// - Parameter emojiGroupControl: 表情视图下面的功能栏
    func emojiGroupControlCommonFaceButtonDown(emojiGroupControl:CODEmojiGroupControl)
    
    /// 发送表情按钮
    ///
    /// - Parameter emojiGroupControl:表情视图下面的功能栏
    func emojiGroupControlSendButtonDown(emojiGroupControl:CODEmojiGroupControl)
    
    /// 表情删除按钮
    ///
    /// - Parameter emojiGroupControl:表情视图下面的功能栏
    func emojiGroupControlDelButtonDown(emojiGroupControl:CODEmojiGroupControl)
    
}

