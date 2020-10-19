//
//  CODChatBar.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Lottie

@objc

/// 这个是下面的功能栏 用于文字输入和表情 语音的选择
class CODChatBar: UIView {
//    @[0-9a-zA-Z\\u4e00-\\u9fa5]+
    let kATRegular = "@\\S+[^@]+(?= ) "
    let kATRegular_space = "@\\S+\\s+[^@\\s]+(?= )"
    
    let kATFormat  = "@%@ "
    
    let kVoiceImage:UIImage = UIImage(named:"chat_toolbar_voice")!
    let kVoiceImageHL:UIImage = UIImage(named:"chat_toolbar_voice_HL")!
    let kEmojiImage:UIImage = UIImage(named:"chat_toolbar_emotion")!
    let kEmojiImageHL:UIImage = UIImage(named:"chat_toolbar_emotion_HL")!
    let kMoreImage:UIImage = UIImage(named:"chat_toolbar_more")!
    let kMoreImageHL:UIImage = UIImage(named:"chat_toolbar_more_HL")!
    let kMoreImageDis:UIImage = UIImage(named:"chat_toolbar_more_dis")!

//    #if MANGO
    let kMoreSendImage:UIImage = UIImage.sendIcon()
    let kMoreSendImageHL:UIImage = UIImage.sendIcon()
//    #elseif PRO
//    let kMoreSendImage:UIImage = UIImage(named:"send_icon")!
//    let kMoreSendImageHL:UIImage = UIImage(named:"send_icon")!
//    #else
//    let kMoreSendImage:UIImage = UIImage(named:"im_send_icon")!
//    let kMoreSendImageHL:UIImage = UIImage(named:"im_send_icon")!
//    #endif
    
    let kKeyboardImage:UIImage = UIImage(named:"chat_toolbar_keyboard")!
    let kKeyboardImageHL:UIImage = UIImage(named:"chat_toolbar_keyboard_HL")!
    
    var isSendVoice: Bool = false
    
    public var status:CODChatBarStatus = .CODChatBarStatusInit
    public var isEdit:Bool = false {
        didSet {
//            if isEdit {
                self.setVoiceButtonImage()
//            }else{
//                self.voiceButton.setImage(UIImage(named:"chat_toolbar_voice"), for: UIControl.State.normal)
//            }
            self.setMoreButtonIsEnabled()
            self.changeTextViewWithAnimation(animation: false)
        }
    }

    var typingAttributes: Dictionary<NSAttributedString.Key , Any> = [:]
    
    weak var delegate:CODChatBarDelegate?
    weak var textDelegate:ChatBarTextViewDelegate?
    var memberNotificationArr:Array<CODGroupMemberModel> = Array()
    ///懒加载
//    lazy var modeButton:UIButton = {
//        let modeButton = UIButton(frame: CGRect.zero)
//        modeButton.setImage(UIImage(named:"chat_toolbar_texttolist"), for: UIControl.State.normal)
//        modeButton.setImage(UIImage(named:"chat_toolbar_texttolist_HL"), for: UIControl.State.highlighted)
//        modeButton.addTarget(self, action: #selector(modeButtonDown), for: .touchUpInside)
//        
//        return modeButton
//    }()
    lazy var voiceButton:UIButton = {
        let voiceButton = UIButton(frame:CGRect.zero)
        voiceButton.setImage(UIImage(named:"chat_toolbar_voice"), for: UIControl.State.normal)
        voiceButton.addTarget(self, action: #selector(voiceButtonDown), for: UIControl.Event.touchUpInside)
        voiceButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        return voiceButton
    }()
    
    lazy var sendVoiceView: CODSendVoiceView = {
        let voiceView = CODSendVoiceView(frame:CGRect.zero)
        voiceView.backgroundColor = UIColor.init(hexString: kNavBarBgColorS)
        voiceView.isHidden = true
        return voiceView
    }()
    
    var textString = ""
    
    lazy var textView:CustomTextView = {
        let field = CustomTextView(frame: CGRect.zero)
        field.textColor = UIColor.titleBlackColor
        field.font = IMChatTextFont
        //        field.returnKeyType = .send
        field.layer.masksToBounds = true
        field.placeholder = NSLocalizedString("请输入消息...", comment: "")
        self.typingAttributes = field.typingAttributes
        field.delegate = self
        field.scrollsToTop = false
        field.backgroundColor = UIColor.clear
        field.allowsEditingTextAttributes = true
        return field
    }()
    
    
    lazy var lineView: UIView = {
        let lineV = UIView.init()
       lineV.backgroundColor = UIColor.init(hexString: kDividingLineColorS)
        return lineV
    }()
    
    lazy var topLine: UIView = {
        let lineV = UIView.init()
        lineV.backgroundColor = UIColor.init(hexString: "#B2B2B2")
        return lineV
    }()
    
    lazy var emojiButton:UIButton = {
        let emojiButton = UIButton(type: UIButton.ButtonType.custom)
        emojiButton.setImage(UIImage(named:"chat_toolbar_emotion"), for: UIControl.State.normal)
        emojiButton.setImage(UIImage(named:"chat_toolbar_emotion_HL"), for: UIControl.State.highlighted)
        emojiButton.addTarget(self, action: #selector(emojiButtonDown), for: .touchUpInside)
        emojiButton.contentMode = UIView.ContentMode.scaleAspectFit
        return emojiButton
    }()
    
    fileprivate lazy var addLottieView: AnimationView = {
        let lottieView = AnimationView.init()
        let animation = Animation.filepath(Bundle.main.path(forResource: "add", ofType: "json")!, animationCache: nil)
        lottieView.animation = animation
        lottieView.loopMode = .playOnce
        lottieView.isUserInteractionEnabled = true
        lottieView.isHidden = true
        lottieView.animationSpeed = 1.5
       return lottieView
    }()

    lazy var moreButton: UIButton = {
        let moreButton = UIButton(type: UIButton.ButtonType.custom)
        moreButton.contentMode = .center
        moreButton.setImage(kMoreImage, for: UIControl.State.normal)
        moreButton.setImage(kMoreImageHL, for: UIControl.State.highlighted)
        moreButton.addTarget(self, action: #selector(moreButtonDown), for: .touchUpInside)
        moreButton.contentMode = UIView.ContentMode.scaleAspectFit
        return moreButton
    }()
    /// 划线
    ///
    /// - Parameter rect: 范围
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        let context = UIGraphicsGetCurrentContext()
//        context?.setLineWidth(0.5)
//        context?.setStrokeColor(UIColor.init(hexString: "#B2B2B2")!.cgColor)
//        context?.beginPath()
//        context?.move(to: CGPoint(x: 0, y: 0))
//        context?.addLine(to: CGPoint(x: KScreenWidth, y: 0))
//        context?.strokePath()
//    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
//        guard let view = super.hitTest(point, with: event) else {
//
//            return self.sendVoiceView.hitTest(point, with: event)
//        }
        
        return super.hitTest(point, with: event)
        
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) {
            return true
            
        }
        for subview in subviews {
            let subviewPoint = subview.convert(point, from: self)
            if subview.point(inside: subviewPoint, with: event) {
                
                return subview.alpha > 0.2 && !subview.isHidden && subview.isUserInteractionEnabled
                
            }
        }
        return false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpSubViews()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setUpSubViews() {
        ///添加视图
        self.backgroundColor = UIColor.init(hexString: kNavBarBgColorS)
        self.addSubview(self.voiceButton)
        self.addSubview(self.lineView)
        self.addSubview(self.textView)
        self.addSubview(self.emojiButton)
        self.addSubview(self.moreButton)
        self.moreButton.addSubview(self.addLottieView)
//        self.moreButton.addSubview(self.cancelLottieView)
        self.addSubview(self.topLine)
        
        self.addSubview(self.sendVoiceView)
        
        let long = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(long:)))
        self.addGestureRecognizer(long)
        
        setUpSnpkit()
    }
    
    @objc func longPressAction(long:UILongPressGestureRecognizer) {
        
        
        if self.voiceButton.frame.contains(long.location(in: long.view)) && long.state == .began {
            
            
            self.isSendVoice = true
        }
        
        if self.isSendVoice  {
            
            NotificationCenter.default.post(name: NSNotification.Name(kSendVoiceMoveTouch), object: nil, userInfo: [
                "point": long.location(in: long.view),
                "state": long.state
            ])
            
        }
        
        
    }
    
    fileprivate func setUpSnpkit() {
        let buttonWH =  36
        self.moreButton.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.left.equalTo(self).offset(12)
            make.size.equalTo(CGSize(width: buttonWH, height: buttonWH))
//            make.bottom.equalTo(self).offset(-11)
            make.centerY.equalTo(self)
        }
        self.emojiButton.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.left.equalTo(self.moreButton.snp.right).offset(6)
            make.bottom.equalTo(self.moreButton.snp.bottom).offset(0)
            make.size.equalTo(CGSize(width: buttonWH, height: buttonWH))
        }
        self.voiceButton.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.bottom.equalTo(self.moreButton).offset(0)
            make.right.equalTo(self).offset(0)
            make.size.equalTo(CGSize(width: buttonWH+16, height: buttonWH))
        }
        
        self.sendVoiceView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.textView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.snp.top).offset(7)
            make.bottom.equalTo(self.snp.bottom).offset(-7)
            make.left.equalTo(self.emojiButton.snp.right).offset(8)
            make.right.equalTo(self.voiceButton.snp.left).offset(-5)
            make.height.equalTo(HEIGHT_CHATBAR_TEXTVIEW)
        }
      
        self.lineView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.left.right.equalTo(self.textView)
            make.height.equalTo(1)
            make.top.equalTo(self.textView.snp.bottom)
        }
        self.topLine.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        self.addLottieView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.left.top.equalTo(self.moreButton).offset(3.5)
            make.right.bottom.equalTo(self.moreButton).offset(-3.5)
        }

    }
    public func initialization(){
        self.status = .CODChatBarStatusInit
        self.lineView.backgroundColor = UIColor.init(hexString: kDividingLineColorS)
        self.moreButton.setImage(kMoreImage, for: UIControl.State.normal)
//        self.setMoreButtonImage(normalImage: "chat_toolbar_more", highImage: "chat_toolbar_more_HL")
        self.emojiButton.setImage(UIImage(named:"chat_toolbar_emotion"), for: UIControl.State.normal)
        self.emojiButton.setImage(UIImage(named:"chat_toolbar_emotion_HL"), for: UIControl.State.highlighted)
        self.setVoiceButtonImage()
        self.textView.snp.updateConstraints({ (make) in
            make.height.equalTo(HEIGHT_CHATBAR_TEXTVIEW)
        })
    }
    
    func setMoreButtonImage(normalImage: String,highImage: String) {
        self.moreButton.setImage(UIImage.init(), for: UIControl.State.normal)
        self.moreButton.setImage(UIImage.init(), for: UIControl.State.highlighted)
        
        if normalImage == "chat_toolbar_more" {
//            self.cancelLottieView.isHidden = true
            self.addLottieView.isHidden = false
            self.addLottieView.animationSpeed = -3
            self.addLottieView.play { [weak self](isPlay) in
                self?.moreButton.setImage(UIImage(named:normalImage), for: UIControl.State.normal)
                self?.moreButton.setImage(UIImage(named:highImage), for: UIControl.State.highlighted)
                self?.addLottieView.isHidden = true
            }
        }else{
            self.addLottieView.isHidden = false
            self.addLottieView.animationSpeed = 1.5
            self.addLottieView.play { [weak self](isPlay) in
               self?.moreButton.setImage(UIImage(named:normalImage), for: UIControl.State.normal)
               self?.moreButton.setImage(UIImage(named:highImage), for: UIControl.State.highlighted)
               self?.addLottieView.isHidden = true
           }
//            self.cancelLottieView.isHidden = false
//            self.cancelLottieView.play { [weak self](isPlay) in
//                self?.cancelLottieView.isHidden = true
//                self?.moreButton.setImage(UIImage(named:normalImage), for: UIControl.State.normal)
//                self?.moreButton.setImage(UIImage(named:highImage), for: UIControl.State.highlighted)
//            }
        }
         
    }
    func setVoiceButtonImage() {
        if self.isEdit {
            self.voiceButton.setImage(kMoreSendImage, for: UIControl.State.normal)
        }else{
            if textView.text.count > 0 {
                self.voiceButton.setImage(kMoreSendImage, for: UIControl.State.normal)
            }else{
                self.voiceButton.setImage(UIImage(named:"chat_toolbar_voice"), for: UIControl.State.normal)
            }
        }
     
    }
    
    func setMoreButtonIsEnabled() {
        self.moreButton.isEnabled = !self.isEdit
    }
    
    @objc fileprivate func voiceButtonDown(){

        if self.isEdit {
//            if self.textView.text.count > 0 {
                self.sendCurrentText()
//            }
            return
        }
        
        self.lineView.backgroundColor = UIColor.init(hexString: kDividingLineColorS)

        if self.textView.text.count > 0 {
            self.sendCurrentText()
            return
        }
        
        if UserDefaults.standard.bool(forKey: kIsVideoCall) {
            CODProgressHUD.showWarningWithStatus("您正在语音通话,无法使用此功能")
            return
        }
        
            if self.delegate != nil{
                AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: {granted in
                    dispatch_async_safely_to_main_queue({
                        if !granted {
                            CODAlertViewToSetting_show("无法访问您的麦克风", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 麦克风 -> 打开访问权限") )
                            return
                        }else{
//                            self.delegate?.chatBarChange(chatBar: self, fromStatus: self.status, toStatus: .CODChatBarStatusVoice)
//                            self.changeVoiceButton()
                            CODToast.showToast(message: NSLocalizedString("按住开始录音", comment: "") , aLocationView: self.voiceButton, aShowTime: 3)
//                            CODProgressHUD.showWarningWithStatus("长按开始录音")
                        }
                    })
                })
            }
       
    }
    
    func changeVoiceButton()  {
        self.textView.resignFirstResponder()
        
        //其他按钮初始化
        if (self.status == .CODChatBarStatusMore){
            //                self.moreButton.setImage(kMoreImage, for: UIControl.State.normal)
            //                self.moreButton.setImage(kMoreImageHL, for: UIControl.State.highlighted)
            self.setMoreButtonImage(normalImage: "chat_toolbar_more", highImage: "chat_toolbar_more_HL")
        }else if(self.status == .CODChatBarStatusEmoji){
            self.emojiButton.setImage(kEmojiImage, for: UIControl.State.normal)
            self.emojiButton.setImage(kEmojiImageHL, for: UIControl.State.highlighted)
        }
        ///自己按钮的改变
        self.status = .CODChatBarStatusVoice
        self.voiceButton.setImage(kVoiceImageHL, for: UIControl.State.normal)
    }
    
    @objc fileprivate func emojiButtonDown() {
        self.changeTextViewWithAnimation(animation: false)
        if self.status == .CODChatBarStatusEmoji {///取消表情 开始键盘输入
            if self.delegate != nil{
                self.delegate?.chatBarChange(chatBar: self, fromStatus: self.status, toStatus: .CODChatBarStatusKeyboard)
            }
            self.status = .CODChatBarStatusKeyboard
            ///编辑开始
            self.textView.becomeFirstResponder()
            self.emojiButton.setImage(kEmojiImage, for: UIControl.State.normal)
            self.emojiButton.setImage(kEmojiImageHL, for: UIControl.State.highlighted)
        }else{///开始表情
//            self.textView.becomeFirstResponder()
            if self.delegate != nil{
                self.delegate?.chatBarChange(chatBar: self, fromStatus: self.status, toStatus: .CODChatBarStatusEmoji)
            }
            if (self.status == .CODChatBarStatusMore){
                self.setMoreButtonImage(normalImage: "chat_toolbar_more", highImage: "chat_toolbar_more_HL")
            }else if(self.status == .CODChatBarStatusVoice){
                self.changeVoiceImage()
            }
            self.emojiButton.setImage(kKeyboardImage, for: UIControl.State.normal)
            self.emojiButton.setImage(kKeyboardImageHL, for: UIControl.State.highlighted)
            //            self.talkButton.isHidden = true
            //            self.textView.isHidden = false
            self.textView.resignFirstResponder()
            self.status = .CODChatBarStatusEmoji
        }
    }
    
    @objc fileprivate func moreButtonDown(){
     if self.status == .CODChatBarStatusMore{///取消表情
        self.textView.snp.updateConstraints({ (make) in
            make.height.equalTo(HEIGHT_CHATBAR_TEXTVIEW)
        })
        self.setMoreButtonImage(normalImage: "chat_toolbar_more", highImage: "chat_toolbar_more_HL")
        if self.delegate != nil{
            self.delegate?.chatBarChange(chatBar: self, fromStatus: self.status, toStatus: .CODChatBarStatusInit)
            self.status = .CODChatBarStatusInit
        }
      }else{
        self.changeTextViewWithAnimation(animation: false)
        self.setMoreButtonImage(normalImage: "pressed_Toggle_button", highImage: "pressed_Toggle_button")
        if self.delegate != nil{
            self.delegate?.chatBarChange(chatBar: self, fromStatus: self.status, toStatus: .CODChatBarStatusMore)
        }
        if (self.status == .CODChatBarStatusEmoji){
            self.emojiButton.setImage(kEmojiImage, for: UIControl.State.normal)
            self.emojiButton.setImage(kEmojiImageHL, for: UIControl.State.highlighted)
        }else if(self.status == .CODChatBarStatusVoice){
            self.setVoiceButtonImage()
        }
        
        self.textView.resignFirstResponder()
        self.status = .CODChatBarStatusMore
      
     }
    }

    
    ///Public Method 公共方法
    public func sendCurrentText() {
        
//        if self.textView.typingAttributes.keys.contains(.strikethroughStyle) {
//            self.textView.typingAttributes.removeValue(forKey: .strikethroughStyle)
//        }
//
//        if self.textView.typingAttributes.keys.contains(.underlineStyle) {
//            self.textView.typingAttributes.removeValue(forKey: .underlineStyle)
//        }
        
//        self.typingAttributes = self.textView.typingAttributes
        
        if self.textView.text.count > 0 || self.isEdit {
            if self.delegate != nil{
                self.delegate?.sendText(chatBar: self, text:  self.textView.attributedText)
            }
        }
        self.textView.text = "";
        self.textView.attributedText = nil
        self.textView.typingAttributes = self.typingAttributes
        self.textView.font = IMChatTextFont
        self.changeVoiceImage()
        
        self.changeTextViewWithAnimation(animation: true)
    }
    ///添加表情文字
    public func addEmojiString(emojiString:String?) {
        if emojiString != nil {
            //自定义的表情
//            self.addEmojiImage(emojiString: emojiString!);
            
            if self.textView.attributedText.length > 0 {
            
                let attribute = NSMutableAttributedString(attributedString: self.textView.attributedText)
                attribute.insert(NSAttributedString(string: emojiString ?? "", attributes: [.font:IMChatTextFont]), at: attribute.length)
                self.textView.attributedText = attribute
                
            }else{
                self.textView.text = self.textView.text + (emojiString ?? "")
            }
            
            changeTextViewWithAnimation(animation: true)
            self.changeVoiceImage()
        }
    }
    
    
    ///添加一个表情
    func addEmojiImage(emojiString:String) {
        CODEmojiHelper.insertEmoji(for: self.textView, defaultEmojiImageName: emojiString, desc: emojiString)
        
        changeTextViewWithAnimation(animation: true)
    }
    
    /// 删除输入框的字符
    public func deleteCharacter(){
        if self.textView(self.textView, shouldChangeTextIn:NSRange(location: self.textView.text.count - 1, length: 1), replacementText: "") {
            self.textView.deleteBackward()
            if self.textView.text.count == 0{
                
            }
        }
    }
     @objc  public func changeVoiceImage (){
        self.setVoiceButtonImage()
    }
}

// MARK: - UITextViewDelegate
extension CODChatBar:UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        textView.becomeFirstResponder()
        return false
    }
    
    ///修改TextView的高度 做动画改变
    @objc func changeTextViewWithAnimation(animation:Bool) {
        
        var textWidth = self.textView.width
        
        if self.textView.width == 0 {
            textWidth = KScreenWidth - 155
        }
        let textHeight = self.textView.sizeThatFits(CGSize(width: textWidth, height: CGFloat(MAXFLOAT))).height
        var height = textHeight > HEIGHT_CHATBAR_TEXTVIEW ? textHeight:HEIGHT_CHATBAR_TEXTVIEW
        height = textHeight <= HEIGHT_MAX_CHATBAR_TEXTVIEW ? textHeight:HEIGHT_MAX_CHATBAR_TEXTVIEW
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
                        self.delegate?.changeTextViewHeight(chatBar:self, height: height)
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
                    self.delegate?.changeTextViewHeight(chatBar:self, height: height)
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
        self.lineView.backgroundColor = UIColor.init(hexString: "#007EE5")
        self.changeTextViewWithAnimation(animation: true)

        if self.status != .CODChatBarStatusKeyboard {
            if self.delegate != nil{
                self.delegate?.chatBarChange(chatBar: self, fromStatus: self.status, toStatus: .CODChatBarStatusKeyboard)
            }
            if (self.status == .CODChatBarStatusMore){
                self.setMoreButtonImage(normalImage: "chat_toolbar_more", highImage: "chat_toolbar_more_HL")
            }else if(self.status == .CODChatBarStatusEmoji){
                self.emojiButton.setImage(kEmojiImage, for: UIControl.State.normal)
                self.emojiButton.setImage(kEmojiImageHL, for: UIControl.State.highlighted)
            }else{
                self.setVoiceButtonImage()
            }
            self.status = .CODChatBarStatusKeyboard
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.removeAllSapce.count > 0 {
//            self.lineView.backgroundColor = UIColor.init(hexString: "#007EE5")
//        }else{
            self.lineView.backgroundColor = UIColor.init(hexString: kDividingLineColorS)
//        }
        if self.textDelegate != nil {
            self.textDelegate?.chatBarTextViewDidEndEdit(textView: textView)
        }
        changeTextViewWithAnimation(animation: true)
        
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.removeAllSapce.count > 0 {
            self.lineView.backgroundColor = UIColor.init(hexString: "#007EE5")
        }else{
            self.lineView.backgroundColor = UIColor.init(hexString: kDividingLineColorS)
        }
        if self.textDelegate != nil {
            self.textDelegate?.chatBarTextViewDidChangeEdit(textView: textView)
        }
        
        changeTextViewWithAnimation(animation: true)
        self.textView.scrollRangeToVisible(self.textView.selectedRange)
        self.setVoiceButtonImage()
        self.textString = textView.text
        
        if self.textView.text.count == 0 {
            self.textView.typingAttributes = self.typingAttributes
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        self.textView.typingAttributes = self.typingAttributes
        if text == "@" {
            
            if range.length > 0 {
                return true
            } else {
             
                let mutableAttStr = NSMutableAttributedString.init(attributedString: textView.attributedText)
                mutableAttStr.insert(NSAttributedString.init(string: "@",attributes: [.font : IMChatTextFont]), at: range.location)
                textView.attributedText = mutableAttStr
                textView.selectedRange = NSMakeRange(range.location+1, range.length)
                if self.delegate != nil{
                    self.delegate!.presentGroupMember()
                }
                
                return false
            }
            
        }
        
        ///这里要监听换行的字符来进行发送
        if text == "\n" {
            return true
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
                self.changeTextViewWithAnimation(animation: true)
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

protocol ChatBarTextViewDelegate: NSObjectProtocol {
    func chatBarTextViewDidChangeEdit(textView: UITextView)
    func chatBarTextViewDidEndEdit(textView: UITextView)
}

