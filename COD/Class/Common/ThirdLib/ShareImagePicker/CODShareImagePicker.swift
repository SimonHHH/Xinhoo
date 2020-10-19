//
//  CODShareImagePicker.swift
//  COD
//
//  Created by 1 on 2019/8/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import SnapKit
private let CANCLE_HEIGHT:CGFloat = 57
private let RADIUS:CGFloat = 10

enum CODShareImagePickerFromType {
    case Chat
    case CloudDisk
    case Moments
    case HomeMoments
}
class CODShareImagePicker: UIView {
    var msgID:String = ""
    var msgUrl:String = ""
    var shareText: String = ""
    var contactListArr :Array = [AnyObject]()
    var imageData: YBIBDataProtocol?
    fileprivate var isUpdateUI:Bool = false
    fileprivate var currentHeight:CGFloat = KScreenHeight/2
    

    var fromType: CODShareImagePickerFromType = .Chat
    var messageModel :CODMessageModel?

    ///这个是内容视图 全部的视图都放这个上面
    lazy var contentView:UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.clear
        return view
    }()
    ///上面的视图
    lazy var topView:UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        view.cornerRadius = RADIUS
        return view
    }()
    lazy var shareSessionView: CODShareSessionView = {
        let shareSessionView = CODShareSessionView(frame: CGRect.zero)
        shareSessionView.delegate = self
        return shareSessionView
    }()
    ///取消按钮
    lazy var cancleBtn:UIButton = {
        let cancleBtn = UIButton(type: UIButton.ButtonType.custom)
        cancleBtn.backgroundColor = UIColor.white
        cancleBtn.setTitle("取消", for: UIControl.State.normal)
        cancleBtn.setTitleColor(UIColor.init(hexString: "#367CDE"), for: UIControl.State.normal)
        cancleBtn.cornerRadius = RADIUS
        cancleBtn.addTarget(self, action: #selector(dismiss), for: UIControl.Event.touchUpInside)
        cancleBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        return cancleBtn
    }()
    lazy var lineView:UIView = {
        let lineView = UIView(frame: CGRect.zero)
        lineView.backgroundColor =  UIColor.init(white: 0.8, alpha: 1)
        return lineView
    }()
    ///保存到相册按钮
    lazy var savePhotoBtn:UIButton = {
        let savePhotoBtn = UIButton(type: UIButton.ButtonType.custom)
        savePhotoBtn.backgroundColor = UIColor.white
        savePhotoBtn.setTitle("保存到相册", for: UIControl.State.normal)
        savePhotoBtn.setTitleColor(UIColor.init(hexString: "#367CDE"), for: UIControl.State.normal)
        savePhotoBtn.addTarget(self, action: #selector(savePhotoAction), for: UIControl.Event.touchUpInside)
        savePhotoBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        return savePhotoBtn
    }()
    ///搜索按钮
    lazy var searchBtn:UIButton = {
        let searchBtn = UIButton(type: UIButton.ButtonType.custom)
        searchBtn.setImage(UIImage(named:"seach_blue"), for: UIControl.State.normal)
        searchBtn.addTarget(self, action: #selector(searchAction), for: UIControl.Event.touchUpInside)
        searchBtn.isHidden = true
        return searchBtn
    }()
    ///分享
    lazy var shareBtn:UIButton = {
        let shareBtn = UIButton(type: UIButton.ButtonType.custom)
        shareBtn.setImage(UIImage(named:"share_blue"), for: UIControl.State.normal)
        shareBtn.isHidden = true
        shareBtn.addTarget(self, action: #selector(shareAction), for: UIControl.Event.touchUpInside)
        return shareBtn
    }()
    ///标题
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.text = NSLocalizedString("分享到", comment: "")
        return titleLabel
    }()
    ///详情
    lazy var messageLabel:UILabel = {
        let messageLabel = UILabel(frame: CGRect.zero)
        messageLabel.textColor = UIColor.init(hexString:"#8E8E92")
        messageLabel.font = UIFont.boldSystemFont(ofSize: 11)
        messageLabel.text = "选择会话"
        return messageLabel
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        self.addSubViews()
        NotificationCenter.default.addObserver(self, selector: #selector(dismiss), name: NSNotification.Name.init("kTransmessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismiss), name: NSNotification.Name.init("kSavemessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismiss), name: NSNotification.Name.init("kSendmessage"), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func addSubViews() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.cancleBtn)
        self.contentView.addSubview(self.topView)
        self.topView.addSubview(self.savePhotoBtn)
        self.topView.addSubview(self.lineView)
        self.topView.addSubview(self.searchBtn)
        self.topView.addSubview(self.shareBtn)
        self.topView.addSubview(self.titleLabel)
        self.topView.addSubview(self.messageLabel)
        self.topView.addSubview(self.shareSessionView)
    
        self.contentView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(self.currentHeight)
            make.height.equalTo(self.currentHeight)
        }
        self.cancleBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.bottom.right.equalToSuperview().offset(-10)
            make.height.equalTo(CANCLE_HEIGHT)
        }
        self.topView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.right.equalToSuperview()
            make.bottom.equalTo(self.cancleBtn.snp.top).offset(-10)
        }
        self.savePhotoBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(CANCLE_HEIGHT)
        }
        self.lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.savePhotoBtn.snp.top)
            make.height.equalTo(0.5)
        }
        self.searchBtn.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        self.shareBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.topView.snp.centerX).offset(0)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(25)
        }
        self.messageLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.topView.snp.centerX).offset(0)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(0)
            make.height.equalTo(20)
        }
        self.shareSessionView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.lineView.snp.top)
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }
    }
   
    func show() {
        self.shareSessionView.contactListArr = self.contactListArr
        self.shareSessionView.msgUrl = self.msgUrl
        self.shareSessionView.fromType = self.fromType
        if let  messageModel = CODMessageRealmTool.getMessageByMsgId(self.msgID) {
            
          self.shareSessionView.messageModel = messageModel
          self.savePhotoBtn.isHidden = false
          self.savePhotoBtn.setTitle("保存到相册", for: UIControl.State.normal)

        }else if self.fromType == .Moments || self.fromType == .HomeMoments{
            
            self.shareSessionView.messageModel = self.messageModel
             self.savePhotoBtn.isHidden = false
             self.savePhotoBtn.setTitle("保存到相册", for: UIControl.State.normal)
            
        }else{
            
            self.savePhotoBtn.isHidden = false
            self.savePhotoBtn.setTitle("拷贝链接", for: UIControl.State.normal)

        }
        self.shareSessionView.shareText = self.shareText
        self.shareSessionView.collectionView.reloadData()
        //获取delegate
        let delegate  = UIApplication.shared.delegate as! AppDelegate
        //添加视图
        delegate.window?.addSubview(self)
        ///延时动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ///移动
            self.contentView.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview()
            }
            self.setNeedsUpdateConstraints()
            //更新动画
            UIView.animate(withDuration:0.3, animations: {
                self.layoutIfNeeded()
            })
        }
    }
  
}
extension CODShareImagePicker{
    @objc public func dismiss(){
        ///动画移动
        self.contentView.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().offset(self.currentHeight)
        }
        self.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }, completion: { (finshed) in
            if(finshed){
                ///删除视图
                self.removeFromSuperview()
            }
        })
    }
    //保存到相机胶装
    @objc func savePhotoAction(){
        if self.fromType == .HomeMoments {
            
        }
         if CODMessageRealmTool.getMessageByMsgId(self.msgID) != nil {
          NotificationCenter.default.post(name: NSNotification.Name.init("kSavemessage"), object: nil)

        }else{
            self.dismiss()
             let pastboard = UIPasteboard.general
             pastboard.string = self.shareText
             CODProgressHUD.showSuccessWithStatus("链接拷贝成功")
        }
    }
    ///搜索
    @objc func searchAction(){
        
    }
    ///分享
    @objc func shareAction(){
        self.dismiss()
        NotificationCenter.default.post(name: NSNotification.Name.init("kIphoneShareMessage"), object: nil)
    }
}
extension CODShareImagePicker:CODShareSessionViewDelegate{
    /// 上滑或者下滑
    ///
    /// - Parameters:
    ///   - shareSessionView: 数据显示视图
    ///   - isScrollUp: 是否上滑 true为上滑
    func shareSessionViewScrollStatus(shareSessionView:CODShareSessionView,isScrollUp:Bool){
        if(isScrollUp){
            self.currentHeight = KScreenHeight/2 + 100
            self.contentView.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview()
                make.height.equalTo(self.currentHeight)
            }
        }else{
            self.currentHeight = KScreenHeight/2
            self.contentView.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview()
                make.height.equalTo(self.currentHeight)
            }
        }
        self.setNeedsUpdateConstraints()
        //更新动画
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }) { (finshed) in
        }
    }
    /// 滑动到底部
    ///
    /// - Parameters:
    ///   - shareSessionView: 数据显示视图
    ///   - bottomHeight: 超出底部的距离 做动画效果
    func shareSessionViewScrollBottom(shareSessionView:CODShareSessionView,bottomHeight:CGFloat){
        self.contentView.snp.updateConstraints { (make) in
            var offset:CGFloat = bottomHeight/5
            offset = offset > 10 ? 10 : offset
            offset = offset < 0 ? 0 : offset
            make.bottom.equalToSuperview().offset(-offset)
        }
    }
    
}
