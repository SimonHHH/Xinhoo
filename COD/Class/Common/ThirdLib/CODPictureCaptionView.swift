//
//  CODPictureCaptionView.swift
//  COD
//
//  Created by 1 on 2020/8/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum CODPictureCaptionViewStatus:Int {
    case CaptionViewStatusInit = 0 ///初始化
    case CaptionViewStatusKeyboard ///正在输入 键盘弹起
    case CaptionViewStatusEdited   /// 输入完成 输入文本有文字
}

@objc class CODPictureCaptionView: UIView {

    weak var delegate:CODPictureCaptionViewDelegate?
    weak var textDelegate:CODPictureCaptionTextViewDelegate?
    static let share = CODPictureCaptionView()  // 创建单例

    //    @[0-9a-zA-Z\\u4e00-\\u9fa5]+
    let kATRegular = "@\\S+[^@]+(?= ) "
    let kATRegular_space = "@\\S+\\s+[^@\\s]+(?= )"
    
    let kATFormat  = "@%@ "
    var isCamera  = false
    var toolViewBag: Disposable?
    
    public var status:CODPictureCaptionViewStatus = .CaptionViewStatusInit {
        didSet {
            
            changeStutas()
        }
    }
    
    var memberNotificationArr:Array<CODGroupMemberModel> = Array()

    var toolView: UIView = UIView()
    var selectPersonView: CODSelectAtPersonView?
    var tapView: UIView = UIView()

    lazy var addButton:UIButton = {
        let addButton = UIButton(frame:CGRect.zero)
        addButton.setTitle("添加说明...", for: .normal)
        addButton.addTarget(self, action: #selector(addButtonDown), for: UIControl.Event.touchUpInside)
        addButton.alpha = 0.5
        return addButton
    }()
    
    lazy var textViewBg: UIView = {
        
        let bgView = UIView()
        bgView.backgroundColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.1)
        bgView.layer.cornerRadius = 17.0
        bgView.isHidden = true
        return bgView
    }()
    
    lazy var textView:CustomTextView = {
        let field = CustomTextView(frame: CGRect.zero)
        field.textColor = UIColor.white
        field.font = IMChatTextFont
        field.layer.masksToBounds = true
        field.placeholder = NSLocalizedString("添加说明...", comment: "")
        field.delegate = self
        field.placeholderColor = UIColor.init(white: 1, alpha: 0.5)
        field.scrollsToTop = false
        field.backgroundColor = UIColor.clear
        field.layer.cornerRadius = 0
        field.allowsEditingTextAttributes = true
        field.isHidden = true
        field.returnKeyType = .done
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.setUpSubViews()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameWillChange(_ :)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_ :)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

    }
    
    @objc func keyboardWillHide(_ notification:NSNotification){
        if self.superview != nil &&  self.toolView.superview != nil {
            var bottomH = IsiPhoneX ? 44 + (83 - 49) : 44
            if isCamera {
                bottomH = 50
            }
           self.snp.updateConstraints { (make) in
//               make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset( -bottomH )
//               make.bottom.equalTo(self.toolView.snp.top)
//               make.height.greaterThanOrEqualTo(45)
           }
            self.layoutIfNeeded()
        }
    }
    
    
    @objc func keyboardFrameWillChange(_ notification:NSNotification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationDuration: TimeInterval = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

        let keyboardAnimationCurve = (notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue


        if self.superview != nil {

            UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(keyboardAnimationCurve)).union(.beginFromCurrentState), animations: {
                self.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(-keyboardFrame.size.height)
                }
                self.superview?.layoutIfNeeded()

            }) { (finished) in
    
            }

        }

    }
    
    func createView(toolView: UIView) {
        
        toolViewBag = toolView.rx.observe(\.isHidden).filterNil()
            .bind { [weak self] (value)  in

                self?.isHiddenView(isHidden: value)
        }
    }
    
    func isHiddenView(isHidden: Bool) {

        self.isHidden = (self.status != .CaptionViewStatusKeyboard) ? isHidden : false

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setUpSubViews() {
                
        self.addSubviews([self.addButton,self.textViewBg,self.textView,])
     
        self.addButton.snp.makeConstraints { (make) in
            
            make.center.equalTo(self)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        self.textViewBg.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(4)
            make.bottom.equalTo(self.snp.bottom).offset(-7)
            make.left.equalTo(self.snp.left).offset(6)
            make.right.equalTo(self.snp.right).offset(-6)
        }
        
        self.textView.snp.makeConstraints { (make) in

            make.top.equalTo(self.textViewBg.snp.top).offset(4)
            make.bottom.equalTo(self.textViewBg.snp.bottom).offset(-7)
            make.left.equalTo(self.textViewBg.snp.left).offset(15)
            make.right.equalTo(self.textViewBg.snp.right).offset(-15)
            make.height.equalTo(22)
        }
        

    }
    
    func showCaptionView(showView: UIView) {
        IQKeyboardManager.shared.enable = false

        showView.addSubview(self)
        self.createView(toolView: self.toolView)
        self.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(self.toolView.frame.minY)
            make.height.greaterThanOrEqualTo(45)
        }
        self.status = .CaptionViewStatusInit
    }
    
    func dismissCaptionView() {
        
        self.memberNotificationArr = Array()
        self.toolView = UIView()
        self.textView.text = ""
        self.selectPersonView = nil
        self.remove()
    }
    
    func remove() {
        toolViewBag?.dispose()
    }
    
}

extension CODPictureCaptionView {
    
    @objc func addButtonDown(){

        self.status = .CaptionViewStatusKeyboard
    }
    
    func changeStutas() {
        
        self.addButton.isHidden = (self.status == .CaptionViewStatusInit) ? false : true
        self.textView.isHidden = (self.status == .CaptionViewStatusInit) ? true : false
        
        if self.textView.text.count > 0 {
            self.addButton.isHidden = true
            self.textView.isHidden = false
        }else{
            if self.status == .CaptionViewStatusEdited{
                self.addButton.isHidden = false
                self.textView.isHidden = true
            }
        }

        if self.status == .CaptionViewStatusKeyboard {
            if self.textDelegate != nil {
                self.textDelegate?.pictureCaptionTextViewDidChangeEdit(captionView: self)
            }
            if tapView.tag != 50 {
                self.tapView = UIView()
                self.tapView.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight)
                self.tapView.backgroundColor = .clear
                self.tapView.tag = 50
                self.tapView.addTap { [weak self] in
                    
                    guard let `self` = self else { return }
                    self.tapView.removeFromSuperview()
                    self.changeStutas()
                    self.status = .CaptionViewStatusEdited
                }
            }

            self.superview?.addSubview(self.tapView)
            self.superview?.bringSubviewToFront(self)
            self.textView.becomeFirstResponder()
            if self.textView.text.count > 0 {
                self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.count, 1))
            }

        }else {

            self.delegate?.changeTextViewHeight(captionView:self, height: 33)
            self.textView.resignFirstResponder()
            self.superview?.resignFirstResponder()
            self.textView.snp.updateConstraints({ (make) in
                make.height.equalTo(33)
            })
        }
        
        self.textViewBg.isHidden = self.textView.isHidden
                
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.status == .CaptionViewStatusKeyboard && self.textView.frame.contains(point){
            return self.textView
        }

        return super.hitTest(point, with: event)
    }
    
}
extension CODPictureCaptionView:UITextViewDelegate{

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        textView.becomeFirstResponder()
        return false
    }
    
    ///修改TextView的高度 做动画改变
    @objc func changeTextViewWithAnimation(animation:Bool) {
        
        var textWidth = self.textView.width
        
        if self.textView.width == 0 {
            textWidth = KScreenWidth - 42
        }
        let textHeight = self.textView.sizeThatFits(CGSize(width: textWidth, height: CGFloat(MAXFLOAT))).height
        var height = textHeight > HEIGHT_PICCAP_TEXTVIEW ? textHeight:HEIGHT_PICCAP_TEXTVIEW
        height = textHeight <= HEIGHT_MAX_PICCAP_TEXTVIEW ? textHeight:HEIGHT_MAX_PICCAP_TEXTVIEW

        ///设置是否可以滑动 要注意 仅仅当 height < textHeight
        self.textView.isScrollEnabled = textHeight > height
        if height != self.textView.height {///这个时候要修改文字
            if animation{
                UIView.animate(withDuration: 0.01, animations: {
                    self.textView.snp.updateConstraints({ (make) in
                        make.height.equalTo(height)
                    })
                    if (self.superview != nil){///设置重新布局 马上刷新界面
                        self.superview?.layoutIfNeeded()
                    }
                    if self.delegate != nil{
                        self.delegate?.changeTextViewHeight(captionView:self, height: height)
                    }
                }) { (finished) in
                    if textHeight > height{
                        self.textView.setContentOffset(CGPoint(x: 0, y: textHeight-height), animated:true)
                    }
                }
            }else{
                self.textView.snp.updateConstraints({ (make) in
                    make.height.equalTo(height)
                })
                if (self.superview != nil){///设置重新布局 马上刷新界面
                    self.superview?.layoutIfNeeded()
                }
                if self.delegate != nil{
                    self.delegate?.changeTextViewHeight(captionView:self, height: height)
                }
                if textHeight > height{
                    self.textView.setContentOffset(CGPoint(x: 0, y: textHeight-height), animated:true)
                }
            }
        }else {
            self.textView.setContentOffset(CGPoint(x: 0, y: textHeight-height), animated:true)
        }
    }
    
    ///开始编辑
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        CODRecentPhotoView.recentPhoto.dismissRecentPhoto()
        self.changeTextViewWithAnimation(animation: true)

        if self.status != .CaptionViewStatusKeyboard {
            if self.delegate != nil{
                self.delegate?.chatBarChange(captionView: self, fromStatus: self.status, toStatus: .CaptionViewStatusKeyboard)
            }
            self.status = .CaptionViewStatusKeyboard
//            if (self.status == .CaptionViewStatusInit){
//                changeStutas()
//            }else if(self.status == .CaptionViewStatusEdited){
//                changeStutas()
//            }
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {

        if self.textDelegate != nil {
            self.textDelegate?.pictureCaptionTextViewDidEndEdit(captionView: self)
        }
        changeTextViewWithAnimation(animation: true)
        
    }
    func textViewDidChange(_ textView: UITextView) {

        if self.textDelegate != nil {
            self.textDelegate?.pictureCaptionTextViewDidChangeEdit(captionView: self)
        }
        if self.selectPersonView != nil && textView.text.contains("@") {
            let index1 = String.Index.init(encodedOffset: self.selectPersonView?.location ?? 0)
            let index2 = String.Index.init(encodedOffset: self.textView.text.count - 1)
            if self.selectPersonView?.location ?? 0 < self.textView.text.count {
                let range1:ClosedRange = index1 ... index2
                let subStr = textView.text
                self.selectPersonView?.memberName = String(subStr?[range1] ?? "")
            }
        }
        if !textView.text.contains("@") {
            if self.delegate != nil{
                self.delegate!.deleteAtString(captionView: self)
            }
        }
        changeTextViewWithAnimation(animation: true)
        self.textView.scrollRangeToVisible(self.textView.selectedRange)
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" && range.location+range.length == self.selectPersonView?.location {
            if self.delegate != nil{
                self.delegate!.deleteAtString(captionView: self)
            }
        }
        if text == "@" {
            
            if range.length > 0 {
                return true
            } else {
             
                let mutableAttStr = NSMutableAttributedString.init(attributedString: textView.attributedText)
                mutableAttStr.insert(NSAttributedString.init(string: "@",attributes: [.font : IMChatTextFont,.foregroundColor: UIColor.white]), at: range.location)
                textView.attributedText = mutableAttStr
                textView.selectedRange = NSMakeRange(range.location+1, range.length)
                if self.delegate != nil{
                    self.delegate!.presentPictureCaptionViewGroupMember(captionView: self)
                }
                
                return false
            }
            
        }
        
        ///这里要监听换行的字符来进行发送
        if text == "\n" {
            
            if self.tapView.tag == 50 {
                self.tapView.removeFromSuperview()
            }
            self.changeStutas()
            self.textView.endEditing(true)
            self.status = .CaptionViewStatusEdited
            return false
            
        }else if(textView.text.count > 0 && text == ""){
            
            
            let selectRange = textView.selectedRange
            //用户长按选择文本时不处理
            if selectRange.length > 0{ return true }
            
            // 判断删除的是一个@中间的字符就整体删除
            let string = NSMutableString.init(string: textView.text)
            let attString = NSMutableAttributedString.init(attributedString: textView.attributedText)
            let matches = self.findAllAt()
            
            var inAt = false
            var index = range.location
            for match in matches {
                
                let newRange = NSMakeRange(match.range.location + 1, match.range.length - 1)
                
                if (NSLocationInRange(range.location, newRange)){
                    
                    
                    if !self.isMember(name: string.substring(with: NSMakeRange(match.range.location+1, match.range.length-2)),isDel: true){
                        
                        return true
                    }else{
                        inAt = true
                        index = match.range.location
                        string.replaceCharacters(in: match.range, with: "")
                        attString.replaceCharacters(in: match.range, with: "")
                    }
                    break
                }
            }
            
            if inAt {
                textView.text = string as String
                textView.attributedText = attString
                textView.selectedRange = NSMakeRange(index, 0)
                return false
            }
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        // 光标不能点落在@词中间
        let range = textView.selectedRange
        if range.length > 0 {
            
            return
        }
        let matches = self.findAllAt()
        for match in matches {
            
            let string = NSMutableString.init(string: textView.text)
            
            if self.isMember(name: string.substring(with: NSMakeRange(match.range.location+1, match.range.length-2)), isDel: false) {
                let newRange = NSMakeRange(match.range.location + 1, match.range.length - 1)
                if NSLocationInRange(range.location, newRange){
                    textView.selectedRange = NSMakeRange(match.range.location + match.range.length, 0)
                    break
                }
            }
        }
    }
    
    func findAllAt() -> [NSTextCheckingResult]{
        
        // 找到文本中所有的@
        let string = self.textView.text as NSString
        let regex = try! NSRegularExpression.init(pattern: self.kATRegular, options: .caseInsensitive)
        return regex.matches(in: string as String, options: .reportProgress, range: NSMakeRange(0, string.length))
    }
    
    func findAllAtWithSpace() -> [NSTextCheckingResult] {
        // 找到文本中所有名称带空格的@
        let string = self.textView.text as NSString
        let regex = try! NSRegularExpression.init(pattern: self.kATRegular_space, options: .caseInsensitive)
        return regex.matches(in: string as String, options: .reportProgress, range: NSMakeRange(0, string.length))
    }
    
    func isMember(name:String,isDel:Bool) -> Bool {
        
        for model in self.memberNotificationArr {
            if model.nickname == name  || model.name == name {
                if isDel {
                    self.memberNotificationArr.remove(at: self.memberNotificationArr.firstIndex(of: model)!)
                }
                return true
            }
        }
        return false
    }
}


protocol CODPictureCaptionTextViewDelegate: NSObjectProtocol {
    
    func pictureCaptionTextViewDidChangeEdit(captionView:CODPictureCaptionView)
    
    func pictureCaptionTextViewDidEndEdit(captionView:CODPictureCaptionView)
}

protocol CODPictureCaptionViewDelegate:NSObjectProtocol{
    
    /// ChatBar状态的改变
    ///
    /// - Parameters:
    ///   - chatBar: ChatBar
    ///   - fromStatus: 开始的状态
    ///   - toStatus: 要改变的状态
    func chatBarChange(captionView:CODPictureCaptionView,fromStatus:CODPictureCaptionViewStatus,toStatus:CODPictureCaptionViewStatus)
    
    /// ChatBar的输入框改变
    ///
    /// - Parameters:
    ///   - chatBar: ChatBar
    ///   - height: 输入框的高度
    func changeTextViewHeight(captionView:CODPictureCaptionView,height:CGFloat)
    
    /// 推出群成员列表
    func presentPictureCaptionViewGroupMember(captionView:CODPictureCaptionView)
    
    //
    func deleteAtString(captionView: CODPictureCaptionView)
}


