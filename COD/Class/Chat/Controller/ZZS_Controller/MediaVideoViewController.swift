//
//  MediaVideoViewController.swift
//  COD
//
//  Created by xinhooo on 2019/8/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Lottie
class MediaVideoViewController: BaseViewController , XMPPManagerDelegate{
    public var chatId: Int = 0
    var data:NSMutableDictionary?
    var keys = Array<Any>()
    public var photoBrowser:YBImageBrowser?
    var list:List<CODMessageModel>?
    //是不是云盘
    var isCloudDisk = false
    @IBOutlet weak var listView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.configView()
        self.configData()
        XMPPManager.shareXMPPManager.addDelegate(self)

    }
    
    deinit {
        XMPPManager.shareXMPPManager.removeDeleagte(self)
    }
    
    func deleteMessage(message: CODMessageHJsonModel) {
        self.configData()
        self.photoBrowser?.reloadData()
    }
    
    
    func configData() {
        
        self.listView.allowsMultipleSelection = XinhooTool.isMultiSelect_ShareMedia
        
        let imageData = list?.filter("msgType = 4 && status = 10 && isDelete = false").sorted(byKeyPath: "datetime", ascending: false)
        if imageData != nil {
            
            let mubDic:NSMutableDictionary = NSMutableDictionary.init()
            let formatter:DateFormatter = DateFormatter.init()
            formatter.dateFormat = NSLocalizedString("yyyy年MM月", comment: "")
            
            for model in imageData! {
                if model.isInvalidated {
                    break
                }
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
            self.data = mubDic
        }
        
        self.keys = self.data?.allKeys.sorted(by: { (dateStr1, dateStr2) -> Bool in
            
            return (dateStr1 as! String) > (dateStr2 as! String)
        }) ?? Array<Any>()
        
        self.listView.reloadData()
    }
    
    func configView() {
        let flowLayot = CollectionViewFlowlayout.init()
        flowLayot.minimumLineSpacing = 3
        flowLayot.minimumInteritemSpacing = 3
        self.listView.collectionViewLayout = flowLayot
        
        self.listView.register(UINib.init(nibName: "CODMediaCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CODMediaCollectionViewCell")
        self.listView.register(UINib.init(nibName: "MediaCollectionReusableView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MediaCollectionReusableView")
        self.listView.delegate = self
        self.listView.dataSource = self
        self.listView.emptyDataSetSource = self
        self.listView.emptyDataSetDelegate = self
        
//        self.listView.allowsMultipleSelection = XinhooTool.isMultiSelect_ShareMedia
//        self.listView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MediaVideoViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,EmptyDataSetSource,EmptyDataSetDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let arr = data?.object(forKey: keys[section]) as? NSMutableArray
        return arr?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
        let model = arr![indexPath.row] as! CODMessageModel
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CODMediaCollectionViewCell", for: indexPath) as! CODMediaCollectionViewCell
        
        if let url = URL(string: model.videoModel?.firstpicId.getImageFullPath(imageType: 1,isCloudDisk: self.isCloudDisk) ?? "") {
            
            CustomUtil.imageVeiwDownLoad(picUrl: url, imageView: cell.imgView, placeholderImage: CustomUtil.getPlaceholderImage(), filePath: "") { (image, error, type, url) in
                if error != nil{
                    cell.imgView.image = CustomUtil.getPictureLoadFailImage()
                }
            }
            
        }
        
        
        cell.durationBtn.isHidden = false
        cell.durationBtn.setTitle(CustomUtil.transToHourMinSec(time:Float(round(model.videoModel?.videoDuration ?? 0))), for: .normal)
        cell.selectImageView.image = (collectionView.indexPathsForSelectedItems?.contains(indexPath))! ? UIImage.init(named: "person_selected") : UIImage.init(named: "person_select")
        cell.selectImageView.isHidden = !XinhooTool.isMultiSelect_ShareMedia
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if XinhooTool.isMultiSelect_ShareMedia {
            let cell = collectionView.cellForItem(at: indexPath) as! CODMediaCollectionViewCell
            cell.selectImageView.image = cell.isSelected ? UIImage.init(named: "person_selected") : UIImage.init(named: "person_select")
            let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
            let model = arr![indexPath.row] as! CODMessageModel
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpSelectListNoti), object: model)
        }else{
            let sourceData = NSMutableArray.init()
            let allModels = NSMutableArray.init()
            for dateString in self.keys {
                 
                let arr = data?.object(forKey: dateString) as? NSMutableArray
                arr?.enumerateObjects({ (obj, index, stop) in
                    
                    let model = obj as! CODMessageModel
                    
                    allModels.add(model)
                    
                    let imageData = YBIBVideoData()
                    imageData.videoURL = self.getVideoURL(message: model)
                    imageData.thumbURL = URL.init(string:model.videoModel?.firstpicId.getImageFullPath(imageType: 3,isCloudDisk: self.isCloudDisk) ?? "")
                    imageData.seconds = Int(model.videoModel?.videoDuration ?? 0)
                    if let thumbImage =  CODImageCache.default.smallImageCache?.imageFromCache(forKey: model.videoModel?.videoId) {
                        imageData.thumbImage = thumbImage
                    }
                    
                    //                imageData.imageData = model.videoModel?.firstpicData
                    
                    //                imageData.videoWidth = model.imageWidth
                    //                imageData.videoHeight = model.imageHeight
                    imageData.msgID = model.msgID
                    sourceData.add(imageData)
                })
            }
            
            let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
            let model = arr![indexPath.row] as! CODMessageModel
            
            let photoIndex: Int = allModels.index(of: model)
            
            let imageData: YBIBVideoData = YBIBVideoData()
            imageData.autoPlayCount = 1
            let videoUrl = self.getVideoURL(message: model)
//            imageData.projectiveView = collectionView.cellForItem(at: indexPath)
            imageData.videoURL = videoUrl
            imageData.msgID = model.msgID
            imageData.thumbURL = URL.init(string: model.videoModel?.firstpicId.getImageFullPath(imageType: 3) ?? "")
            if let thumbImage = CODImageCache.default.smallImageCache?.imageFromCache(forKey: model.videoModel?.videoId ?? "") {
                imageData.thumbImage = thumbImage
            }
            imageData.seconds = Int(model.videoModel?.videoDuration ?? 0)
            //        imageData.videoWidth = model.imageWidth
            //        imageData.videoHeight = model.imageHeight
            sourceData[photoIndex] = imageData
            let browser:YBImageBrowser =  YBImageBrowser()
            let toolHander = YBIBToolViewHandler()
            toolHander.delegate = self
            browser.toolViewHandlers = [toolHander]
            browser.dataSourceArray = sourceData as! [YBIBDataProtocol]
            browser.currentPage = photoIndex
            browser.show()
            self.photoBrowser = browser
        }
    }
    
    func getVideoURL(message: CODMessageModel) -> URL? {
        return CustomUtil.getVideoURL(message: message, isCloudDisk: self.isCloudDisk)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if XinhooTool.isMultiSelect_ShareMedia {
            let cell = collectionView.cellForItem(at: indexPath) as! CODMediaCollectionViewCell
            cell.selectImageView.image = cell.isSelected ? UIImage.init(named: "person_selected") : UIImage.init(named: "person_select")
            let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
            let model = arr![indexPath.row] as! CODMessageModel
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpSelectListNoti), object: model)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: (KScreenWidth - 9)/4, height: (KScreenWidth - 9)/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let title = keys[indexPath.section] as! String
        let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MediaCollectionReusableView", for: indexPath) as! MediaCollectionReusableView
        view.titleLab.text = title
        view.contentLab.text = String(format: NSLocalizedString("%ld 个视频", comment: ""), arr?.count ?? 0)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.init(width: KScreenWidth, height: 0.01)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: KScreenWidth, height: 35)
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 100+kNavBarHeight+kSafeArea_Top+40))
        
        let lottieView = AnimationView.init()
        let animation = Animation.filepath(Bundle.main.path(forResource: "404", ofType: "json")!, animationCache: nil)
        lottieView.animation = animation
        lottieView.loopMode = .loop
        lottieView.play()
        view.addSubview(lottieView)
        lottieView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 55, height: 65))
            make.centerX.equalToSuperview()
        }
        
        let lab = UILabel.init(frame: .zero)
        lab.text = NSLocalizedString("暂无聊天视频", comment: "")
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = UIColor.init(hexString: kEmptyTitleColorS)
        view.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.top.equalTo(lottieView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        
        return view
    }
}
extension MediaVideoViewController:YBToolViewClickHandlerDelegate{
    
    func shareYBImageData(_ data: YBIBImageData) {
        
        let shareView = CODShareImagePicker(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        shareView.imageData = data
        shareView.contactListArr = CODGlobalDataSource.getContactGroupChannelModelData(isHeadCloudDisk: true, ignoreIDs: [NewFriendRosterID])
        shareView.msgID = data.msgID ?? ""
        
        if data.isKind(of: YBIBVideoData.self) {
            shareView.msgUrl = (data as? YBIBVideoData)?.videoURL?.absoluteString ?? ""
        } else {
            shareView.msgUrl = data.imageURL?.absoluteString ?? ""
        }
        
        
        if self.isCloudDisk {
            shareView.fromType = .CloudDisk
        } else {
            shareView.fromType = .Chat
        }
        
        shareView.show()
        
    }
    
    func deleteYBImageData(_ data: YBIBImageData, superView: UIView, currentPage: Int) {
        
        self.deleteMessage(msgID: data.msgID ?? "",superView: superView,currentPage: currentPage)
        
    }
    
    //删除
    func deleteMessage(msgID: String,superView: UIView, currentPage: Int){
        print("shanchu \(currentPage)")
        
        if let  messageModel = CODMessageRealmTool.getMessageByMsgId(msgID) {
           
            let chatType = CODMessageChatType(rawValue: messageModel.chatType) ?? .privateChat
            let fromMe: Bool = messageModel.fromWho.contains(UserManager.sharedInstance.loginName!)
            CustomUtil.removeMessage(messageModel: messageModel, chatType: chatType, chatId: self.chatId, superView: superView) { [weak self] (index) in
                guard let self = self else {
                    return
                }
                if index >= 1 {
                    if currentPage == 0 || (self.photoBrowser?.dataSourceArray.count)! - CustomUtil.getMessageImageCount(msgID: messageModel.msgID) <= 0 {
                        if (self.photoBrowser?.dataSourceArray.count)! - CustomUtil.getMessageImageCount(msgID: messageModel.msgID) <= 0 || (self.photoBrowser?.dataSourceArray.count)! == 1 {
                            NotificationCenter.default.post(name: NSNotification.Name.init("kHideBrowser"), object: nil, userInfo: nil)
                        }
                    }
                    self.removeMessageFromView(messageID: messageModel.msgID)
                    //通知去聊天列表中更新数据
//                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                }
            }
        }
    }

    //删除某一个cell
    func removeMessageFromView(messageID: String) {
        self.configData()
        var index = 0
        for dataProtocol in self.photoBrowser?.dataSourceArray ?? [] {
            if let imageData = dataProtocol as? YBIBImageData {
                if imageData.msgID == messageID {
                    self.photoBrowser?.dataSourceArray.remove(at: index)
                    self.photoBrowser?.currentPage = index
                }
            }
            if let imageData = dataProtocol as? YBIBVideoData {
                if imageData.msgID == messageID {
                    self.photoBrowser?.dataSourceArray.remove(at: index)
                    self.photoBrowser?.currentPage = index
                }
            }
            index = index + 1
        }
        CustomUtil.isPlayVideo(isPlay: false,isDelete: true)
        self.photoBrowser?.reloadData()
    }
    
}
