//
//  CODEmojiKeyboard.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODEmojiKeyboard: CODBaseKeyboard {
    var curGroup:CODExpressionGroupModel?///当前的表情组
    weak var delegate:CODEmojiKeyboardDelegate?
    var emojiGroupData:[CODExpressionGroupModel]? {
        didSet{
            ///更新数据
            self.emojiDisplayView.emojiGroupData = emojiGroupData
            self.emjioGroupControl.emojiGroupData = emojiGroupData
        }
    }
    //表情显示视图
    lazy var emojiDisplayView:CODEmojiGroupDisplayView = {
        let emojiDisplay = CODEmojiGroupDisplayView(frame: CGRect.zero)
        emojiDisplay.clipsToBounds = false
        emojiDisplay.delegate = self
        return emojiDisplay
    }()
    //page
    lazy var pageControl:UIPageControl = {
        let pageControll = UIPageControl(frame: CGRect.zero)
        pageControll.centerX = self.centerX
        pageControll.pageIndicatorTintColor = UIColor(white: 0.5, alpha: 0.3)
        pageControll.currentPageIndicatorTintColor = UIColor.gray
        pageControll.isUserInteractionEnabled = false
        pageControll.addTarget(self, action: #selector(pageControllAction), for: .valueChanged)
        return pageControll
    }()
    ///下面的功能栏
    lazy var emjioGroupControl: CODEmojiGroupControl = { 
        let emjioGroupControl = CODEmojiGroupControl()
        emjioGroupControl.delegate = self
        return emjioGroupControl
    }()
    //单例
    static let emjiokeyboard = CODEmojiKeyboard(frame:.zero)
    class func keyboard() -> CODEmojiKeyboard{
        return emjiokeyboard
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.colorGrayForChatBar
        setUpSubviews()
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setUpSubviews(){
        self.addSubview(self.emojiDisplayView)
        self.addSubview(self.emjioGroupControl)
    }
    fileprivate func setUpLayout(){
        self.emojiDisplayView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.emjioGroupControl.snp.top).offset(0)
        }
        self.emjioGroupControl.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(groupControlHeight)
            make.bottom.equalToSuperview().offset(0)
        }
    }
    
}

/// MARK: - CODEmojiKeyboardDelegate
protocol CODEmojiKeyboardDelegate:NSObjectProtocol {
    
    /// 长按表情
    ///
    /// - Parameters:
    ///   - emojiKB: 表情键盘
    ///   - emoji: 表情模型
    ///   - atRect: 位置
    func emojiKeyboardDidTouchEmojiItem(emojiKB:CODEmojiKeyboard,emoji:CODExpressionModel,atRect:CGRect)
    
    /// 结束表情
    ///
    /// - Parameter emojiKB: 表情键盘
    func emojiKeyboardCancelTouchEmojiItem(emojiKB:CODEmojiKeyboard)
    
    /// 选中这个表情
    ///
    /// - Parameters:
    ///   - emojiKB: 表情
    ///   - emoji: 表情模型
    func emojiKeyboardDidSelectedEmojiItem(emojiKB:CODEmojiKeyboard,emoji:CODExpressionModel)
    
    /// 发送按钮
    func emojiKeyboardSendButtonDown()
    
    /// 删除
    func emojiKeyboardDeleteButtonDown()
    
    /// 切换表情类型
    ///
    /// - Parameters:
    ///   - emojiKB: 表情键盘
    ///   - type: 类型
    func emojiKeyboardSelectedEmojiGroupType(emojiKB:CODEmojiKeyboard,type:CODEmojiType)
    
    /// 上滑或者下滑
    ///
    /// - Parameters:
    ///   - emojiKB: 表情键盘
    ///   - isScrollUp: 是否上滑
    func emojiKeyboardScrollStatus(emojiKB:CODEmojiKeyboard,isScrollUp:Bool)
}
// MARK: - CODEmojiGroupControlDelegate
extension CODEmojiKeyboard:CODEmojiGroupControlDelegate{    
    
    /// 选中一组表情
    ///
    /// - Parameters:
    ///   - emojiGroupControl: 表情视图下面的功能栏
    ///   - group: 表情组
    func didSelectedGroup(emojiGroupControl:CODEmojiGroupControl,group:CODExpressionGroupModel,groupIndex:Int){
        self.curGroup = group
        self.emojiDisplayView.scrollToEmojiGroupAtIndex(index:groupIndex)
        self.pageControl.numberOfPages = group.pageNumber
        self.pageControl.currentPage = 0
        if self.delegate != nil {
            self.delegate?.emojiKeyboardSelectedEmojiGroupType(emojiKB: self, type: self.curGroup!.type)
        }
   
       
    }
    /// 添加表情组
    ///
    /// - Parameter emojiGroupControl: 表情视图下面的功能栏
   func emojiGroupControlCommonFaceButtonDown(emojiGroupControl: CODEmojiGroupControl) {
     //常用表情
    self.emojiDisplayView.commonFaceButtonDown()
   }
    
    /// 发送表情按钮
    ///
    /// - Parameter emojiGroupControl:表情视图下面的功能栏
    func emojiGroupControlSendButtonDown(emojiGroupControl:CODEmojiGroupControl){
        if self.delegate != nil {
            self.delegate?.emojiKeyboardSendButtonDown()
        }
    }
    /// 表情删除按钮
    ///
    /// - Parameter emojiGroupControl:表情视图下面的功能栏
    func emojiGroupControlDelButtonDown(emojiGroupControl:CODEmojiGroupControl){
        if self.delegate != nil {
            self.delegate?.emojiKeyboardDeleteButtonDown()
        }
    }
    
}

// MARK: - CODEmojiGroupDisplayViewDelegate
extension CODEmojiKeyboard:CODEmojiGroupDisplayViewDelegate{
    
    @objc func pageControllAction()  {
        //        self.emojiDisplayView.scrollToEmojiGroupAtIndex(index: self.pageControl.currentPage - 1)
        //        scrollToEmojiGroupAtIndex(index:groupIndex)
    }
    
    /// 滚动的方向
    ///
    /// - Parameter displayView: 显示的视图
    func emojiDisplayViewScrollStatus(displayView:CODEmojiGroupDisplayView,isScrollUp:Bool){
        
        if  self.delegate != nil{
            self.delegate?.emojiKeyboardScrollStatus(emojiKB: self, isScrollUp: isScrollUp)
        }
    }
    
    /// 删除按钮
    ///
    /// - Parameter displayView: 显示视图
    func emojiGroupDisplayViewDeleteButtonPressed(displayView:CODEmojiGroupDisplayView){
        if self.delegate != nil {
            self.delegate?.emojiKeyboardDeleteButtonDown()
        }
    }
    
    /// 选中的表情
    ///
    /// - Parameters:
    ///   - displayView: 显示视图
    ///   - didSelectEmoji: 点击的表情
    func emojiGroupDisplayViewDidClicked(displayView:CODEmojiGroupDisplayView,didSelectEmoji:CODExpressionModel){
        if self.delegate != nil {
            self.delegate?.emojiKeyboardDidSelectedEmojiItem(emojiKB: self, emoji: didSelectEmoji)
        }
    }
    
    /// 翻页
    ///
    /// - Parameters:
    ///   - displayView: xians
    ///   - pageIndex: 当前表情组页数
    ///   - forGroupIndex: 当前表情组
    func emojiGroupDisplayViewDidScrollToPageIndex(displayView:CODEmojiGroupDisplayView,pageIndex:NSInteger){
        let group = self.emojiGroupData![pageIndex] ///表情组
        ///注意这里要判断是否相等 相同的组不要走这里了
        
        self.curGroup = group
        self.pageControl.isHidden = group.pageNumber < 1
        self.pageControl.numberOfPages = group.pageNumber
        self.emjioGroupControl.selectEmojiGroupAtIndex(index: pageIndex)
        if self.delegate != nil{
            self.delegate?.emojiKeyboardSelectedEmojiGroupType(emojiKB: self, type: self.curGroup!.type)
        }
        self.pageControl.currentPage = pageIndex
    }
    
    /// 表情长按
    ///
    /// - Parameters:
    ///   - displayView: 显示的视图
    ///   - emoji: 表情
    ///   - atRect: 位置
    func emojiGroupDisplayViewdDidLongPressEmoji(displayView:CODEmojiGroupDisplayView,emoji:CODExpressionModel,atRect:CGRect){
        if self.delegate != nil {
            self.delegate?.emojiKeyboardDidTouchEmojiItem(emojiKB: self, emoji: emoji, atRect: atRect)
        }
    }
    
    /// 结束表情长按
    ///
    /// - Parameter displayView: 显示的视图
    func emojiGroupDisplayViewdEndLongPressEmoji(displayView:CODEmojiGroupDisplayView){
        if self.delegate != nil {
            self.delegate?.emojiKeyboardCancelTouchEmojiItem(emojiKB: self)
        }
    }
    
}


