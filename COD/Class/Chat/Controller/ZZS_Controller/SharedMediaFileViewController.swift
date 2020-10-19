//
//  SharedMediaFileViewController.swift
//  COD
//
//  Created by xinhooo on 2019/8/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

let kUpSelectListNoti:String = "kUpSelectListNoti"
let kMulitShare:String      = "kMulitShare"

class SharedMediaFileViewController: BaseViewController {
    public var chatId: Int = 0

    var chattype: CODMessageChatType = .privateChat
    
    var list:List<CODMessageModel>?
    var currentVC:UIViewController?
    var selectList:Array<CODMessageModel> = Array.init()
    typealias ChooseListCompeleteBlock = (_ selectList:Array<CODMessageModel>,_ vc: UIViewController) -> Void ///选择文件
    public var chooseListBlock:ChooseListCompeleteBlock?

    var isCloudDisk = false
    
    let imageVC = MediaImageViewController()
    let videoVC = MediaVideoViewController()
    let fileVC = MediaFileViewController()
    let linkVC = MediaLinkViewController()
    
    @IBOutlet weak var segmentBackView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sendBackView: UIView!
    @IBOutlet weak var sendBackHeightCos: NSLayoutConstraint!
    @IBOutlet weak var fileCountLab: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        self.navigationItem.title = "共享媒体"
        self.setBackButton()
        self.view.backgroundColor = .white
        var kMoreSendImage:UIImage? = nil
        #if MANGO
        kMoreSendImage = UIImage(named:"mango_send_icon")!
        #elseif PRO
        kMoreSendImage = UIImage(named:"send_icon")!
        #else
        kMoreSendImage = UIImage(named:"im_send_icon")!
        #endif
        self.sendBtn.setImage(kMoreSendImage, for: .normal)
        
        
        self.configData()
        
        if isCloudDisk {
            imageVC.isCloudDisk = true
            videoVC.isCloudDisk = true
            fileVC.isCloudDisk = true
            linkVC.isCloudDisk = true
        }
        imageVC.chatId = self.chatId
        videoVC.chatId = self.chatId
        
        imageVC.list = list
        videoVC.list = list
        
        self.addChild(imageVC)
        self.addChild(videoVC)
        self.addChild(fileVC)
        self.addChild(linkVC)
        self.view.addSubview(imageVC.view)
        currentVC = imageVC
        imageVC.view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.sendBackView.snp.topMargin).offset(0)
            make.top.equalTo(self.segmentBackView.snp.bottom).offset(0)
        }
        self.addXMPPRemoveMsgBlock()
        NotificationCenter.default.addObserver(self, selector: #selector(updateSelectList(noti:)), name: NSNotification.Name.init(kUpSelectListNoti), object: nil)
        
        self.rightTextButton.setTitle(NSLocalizedString("选择", comment: ""), for: .normal)
        self.rightTextButton.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: .normal)
        self.rightTextButton.setImage(nil, for: .normal)
        self.setRightTextButton()
        
    }

    override func navRightTextClick() {
        
        XinhooTool.isMultiSelect_ShareMedia  = !XinhooTool.isMultiSelect_ShareMedia
        self.rightTextButton.setTitle(XinhooTool.isMultiSelect_ShareMedia ? NSLocalizedString("取消", comment: "") : NSLocalizedString("选择", comment: ""), for: .normal)
        
        if imageVC.listView != nil {
            imageVC.configData()
        }
        
        if videoVC.listView != nil {
            videoVC.configData()
        }
        
        if fileVC.listView != nil {
            fileVC.configData()
        }
        
        if linkVC.listView != nil {
            linkVC.configData()
        }
        
        if !XinhooTool.isMultiSelect_ShareMedia {
            self.removeAllSelect()
        }
        
    }
    
    @objc func updateSelectList(noti:NSNotification) {
        
        let model = noti.object as! CODMessageModel
        
        var index = 0
        
        var isContains: Bool!
        
        if model.type == .image {
            isContains = selectList.contains { (messageModel) -> Bool in
                
                if messageModel.photoModel?.photoId == model.photoModel?.photoId {
                    index = selectList.firstIndex(of: messageModel) ?? 0
                }
                
                return messageModel.photoModel?.photoId == model.photoModel?.photoId
            }
        }else{
            isContains = selectList.contains(model)
            index = selectList.firstIndex(of: model) ?? 0
        }
        
        
        if isContains {
            selectList.remove(at: index)
        }else{
            selectList.append(model)
        }
        
        if selectList.count > 0 {
            self.sendBackHeightCos.constant = 50
        }else{
            self.sendBackHeightCos.constant = 0
        }
        
        let text: NSString = NSString(format: NSLocalizedString("%ld 个文件", comment: "") as NSString, self.selectList.count)
        let attributeStr = NSMutableAttributedString.init(string: text as String)
        attributeStr.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "4C9BF0") as Any], range: text.range(of: "\(self.selectList.count)"))
        self.fileCountLab.attributedText = attributeStr
    }
    
    func removeAllSelect() {
        selectList.removeAll()
        self.sendBackHeightCos.constant = 0
        let text: NSString = NSString(format: NSLocalizedString("%ld 个文件", comment: "") as NSString, self.selectList.count)
        let attributeStr = NSMutableAttributedString.init(string: text as String)
        attributeStr.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "4C9BF0") as Any], range: text.range(of: "\(self.selectList.count)"))
        self.fileCountLab.attributedText = attributeStr
    }
    
    func configData() {
        
//        let imageData = list?.filter("msgType = 2 && status = 10").sorted(byKeyPath: "datetime", ascending: true)
//        if imageData != nil {
//
//            let mubDic:NSMutableDictionary = NSMutableDictionary.init()
//            let formatter:DateFormatter = DateFormatter.init()
//            formatter.dateFormat = NSLocalizedString("yyyy年M月", comment: "")
//
//            for model in imageData! {
//                let dateStr = formatter.string(from: Date.init(timeIntervalSince1970: (model.datetime.double() ?? 0)/1000))
//                if (mubDic.object(forKey: dateStr) != nil) {
//                    let mubArr = mubDic.object(forKey: dateStr) as! NSMutableArray
//                    mubArr.add(model)
//                }else{
//                    let mubArr = NSMutableArray.init()
//                    mubArr.add(model)
//                    mubDic.setValue(mubArr, forKey: dateStr)
//                }
//            }
//            imageVC.data = mubDic
//        }
        
//        let videoData = list?.filter("msgType = 4 && status = 10").sorted(byKeyPath: "datetime", ascending: true)
//        if videoData != nil {
//
//            let mubDic:NSMutableDictionary = NSMutableDictionary.init()
//            let formatter:DateFormatter = DateFormatter.init()
//            formatter.dateFormat = NSLocalizedString("yyyy年M月", comment: "")
//
//            for model in videoData! {
//                let dateStr = formatter.string(from: Date.init(timeIntervalSince1970: (model.datetime.double() ?? 0)/1000))
//                if (mubDic.object(forKey: dateStr) != nil) {
//                    let mubArr = mubDic.object(forKey: dateStr) as! NSMutableArray
//                    mubArr.add(model)
//                }else{
//                    let mubArr = NSMutableArray.init()
//                    mubArr.add(model)
//                    mubDic.setValue(mubArr, forKey: dateStr)
//                }
//            }
//            videoVC.data = mubDic
//        }
        
        let fileData = list?.filter("msgType = 7 && status = 10 && isDelete = false").sorted(byKeyPath: "datetime", ascending: false)
        if fileData != nil {
            
            let mubDic:NSMutableDictionary = NSMutableDictionary.init()
            let formatter:DateFormatter = DateFormatter.init()
            formatter.dateFormat = NSLocalizedString("yyyy年MM月", comment: "")
            
            for model in fileData! {
                let dateStr = formatter.string(from: Date.init(timeIntervalSince1970: (model.datetime.double() ?? 0)/1000))
                if (mubDic.object(forKey: dateStr) != nil) {
                    let mubArr = mubDic.object(forKey: dateStr) as! NSMutableArray
                    mubArr.add(model)
                }else{
                    let mubArr = NSMutableArray.init()
                    mubArr.add(model)
                    mubDic.setValue(mubArr, forKey: dateStr)
                }
            }
            fileVC.data = mubDic
        }
        
        let linkData = list?.filter("msgType = 1 && l = 1 && isDelete = false").sorted(byKeyPath: "datetime", ascending: false)
        if linkData != nil {
            
            let mubDic:NSMutableDictionary = NSMutableDictionary.init()
            let formatter:DateFormatter = DateFormatter.init()
            formatter.dateFormat = NSLocalizedString("yyyy年MM月", comment: "")
            
            for model in linkData! {
                let dateStr = formatter.string(from: Date.init(timeIntervalSince1970: (model.datetime.double() ?? 0)/1000))
                if (mubDic.object(forKey: dateStr) != nil) {
                    let mubArr = mubDic.object(forKey: dateStr) as! NSMutableArray
                    mubArr.add(model)
                }else{
                    let mubArr = NSMutableArray.init()
                    mubArr.add(model)
                    mubDic.setValue(mubArr, forKey: dateStr)
                }
            }
            linkVC.data = mubDic
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.subviews[0].subviews[0].isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.subviews[0].subviews[0].isHidden = false
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            
            self.transition(from: currentVC!, to: imageVC, duration: 0, options: .curveLinear, animations: nil) { (finish) in
                self.currentVC = self.imageVC
                self.imageVC.view.snp.makeConstraints({ (make) in
                    make.left.right.equalToSuperview()
                    make.bottom.equalTo(self.sendBackView.snp.topMargin).offset(0)
                    make.top.equalTo(self.segmentBackView.snp.bottom).offset(0)
                })
            }
            
            break
        case 1:
            self.transition(from: currentVC!, to: videoVC, duration: 0, options: .curveLinear, animations: nil) { (finish) in
                self.currentVC = self.videoVC
                self.videoVC.view.snp.makeConstraints({ (make) in
                    make.left.right.equalToSuperview()
                    make.bottom.equalTo(self.sendBackView.snp.topMargin).offset(0)
                    make.top.equalTo(self.segmentBackView.snp.bottom).offset(0)
                })
            }
            break
        case 2:
            self.transition(from: currentVC!, to: fileVC, duration: 0, options: .curveLinear, animations: nil) { (finish) in
                self.currentVC = self.fileVC
                self.fileVC.view.snp.makeConstraints({ (make) in
                    make.left.right.equalToSuperview()
                    make.bottom.equalTo(self.sendBackView.snp.topMargin).offset(0)
                    make.top.equalTo(self.segmentBackView.snp.bottom).offset(0)
                })
            }
            break
        case 3:
            self.transition(from: currentVC!, to: linkVC, duration: 0, options: .curveLinear, animations: nil) { (finish) in
                self.currentVC = self.linkVC
                self.linkVC.view.snp.makeConstraints({ (make) in
                    make.left.right.equalToSuperview()
                    make.bottom.equalTo(self.sendBackView.snp.topMargin).offset(0)
                    make.top.equalTo(self.segmentBackView.snp.bottom).offset(0)
                })
            }
            break
        default:
            break
        }
    }
    
    @IBAction func sendFileAction(_ sender: Any) {
        if self.chooseListBlock != nil {
            self.chooseListBlock!(self.selectList,self)
        }else {
            self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: false)
            NotificationCenter.default.post(name: NSNotification.Name(kMulitShare), object: self.selectList)
        }
        print(self.selectList)
    }
    
    //iq 回调
    func addXMPPRemoveMsgBlock() {
        XMPPManager.shareXMPPManager.removeMsgBlock = { [weak self] (_ msgId: String) in
            guard let self = self else {
                return
            }
            dispatch_async_safely_to_main_queue({ [weak self] in
                guard let `self` = self else { return }
                if let messageModel = CODMessageRealmTool.getMessageByMsgId(msgId) {
                     let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: messageModel.msgType) ?? .text
                    NotificationCenter.default.post(name: NSNotification.Name.init(kDeleteMessageNoti), object: nil, userInfo: ["id":msgId])
                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kNotificationTopMessage), object: nil)
                    switch modelType {
                    case .image:
                        self.imageVC.removeMessageFromView(messageID: msgId)
                    case .video:
                        self.videoVC.removeMessageFromView(messageID: msgId)
                    default: break
                    }
                 }

            })
        }
    }
    
    deinit {
        XinhooTool.isMultiSelect_ShareMedia = false
    }
    

}

class PhotoPreviewViewController: UIViewController {
    private let imageName: String
    private let imageView = UIImageView()

    init(imageName: String) {
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationItem.title = imageName.capitalized

        imageView.sd_setImage(with: URL(string: imageName)) { [weak self] (image, error, type, url) in

            guard let image = image else {
                return
            }
            
            guard let `self` = self else {
                return
            }
            
            var width: CGFloat
            var height: CGFloat

            if image.size.width > image.size.height {
                width = self.view.frame.width - 50
                height = image.size.height * (width / image.size.width)
            } else {
                height = self.view.frame.height
                width = image.size.width * (height / image.size.height)
                
                if width > self.view.frame.width {
                    width = self.view.frame.width - 50
                    height = width / image.size.width * image.size.height
                }
                
            }

            self.preferredContentSize = CGSize(width: width, height: height)
        }
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = view.bounds
        view.addSubview(imageView)

        // The preview will size to the preferredContentSize, which can be useful
        // for displaying a preview with the dimension of an image, for example.
        // Unlike peek and pop, it doesn't automatically scale down for you.

        
    }
    
}
