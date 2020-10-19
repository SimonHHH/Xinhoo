//
//  MediaImageViewController.swift
//  COD
//
//  Created by xinhooo on 2019/8/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Lottie
class MediaImageViewController: BaseViewController, YBImageBrowserDelegate, XMPPManagerDelegate {
    
    var data: Dictionary<String, Array<YBIBImageData>> = [:]
    public var chatId: Int = 0
    var list:List<CODMessageModel>?
    public var photoBrowser:YBImageBrowser?
    var keys = Array<String>()
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
//        self.removeMessageFromView(messageID: messageModel.msgID)
    }
    
    func configData() {
        
        data = [:]
        
        self.listView.allowsMultipleSelection = XinhooTool.isMultiSelect_ShareMedia
        
        let imageData = HistoryMessageManger.default.getLocatImageList(chatId: chatId)
        
        for model in imageData {
            if model.isInvalidated {
                break
            }
            let dateStr = Date(timeIntervalSince1970: (model.datetime.double() ?? 0)/1000).toFormat("yyyy年MM月")
            
            if data.has(key: dateStr) {
                
                if model.type == .multipleImage {
                    
                } else {
                    
                }
                
                if let images = CustomUtil.messageToImageDataArray(model: model, isCloudDisk: self.isCloudDisk) as? [YBIBImageData] {
                    data[dateStr]?.append(contentsOf: images)
                }
                
            } else {
                
                if let images = CustomUtil.messageToImageDataArray(model: model, isCloudDisk: self.isCloudDisk) as? [YBIBImageData] {
                    data[dateStr] = images
                }
                
            }

        }
 
        self.keys = self.data.keys.sorted(by: { (dateStr1, dateStr2) -> Bool in
            return dateStr1 > dateStr2
        })
        
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

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
}

extension MediaImageViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,EmptyDataSetSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let arr = data?.object(forKey: keys[section]) as? NSMutableArray
        return data[keys[section]]?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let arr = data[keys[indexPath.section]]!
        let model = arr[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CODMediaCollectionViewCell", for: indexPath) as! CODMediaCollectionViewCell
                
        cell.imgView.sd_setImage(with: model.thumbURL, placeholderImage: CustomUtil.getPlaceholderImage(), options: []) { [weak cell] (image, _, _, _) in
            
            guard let cell = cell else { return }
            
            if image == nil {
                cell.imgView.image = CustomUtil.getPictureLoadFailImage()
            }
        }
        
        cell.durationBtn.isHidden = true
        cell.selectImageView.image = (collectionView.indexPathsForSelectedItems?.contains(indexPath))! ? UIImage.init(named: "person_selected") : UIImage.init(named: "person_select")
        cell.selectImageView.isHidden = !XinhooTool.isMultiSelect_ShareMedia
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let arr = data[keys[indexPath.section]]!
        let model = arr[indexPath.row]
        
        guard let messageModel = CODMessageRealmTool.generateNewMessage(by: model.msgID ?? "") else {
            return
        }
        messageModel.smsgID = model.msgID
        if XinhooTool.isMultiSelect_ShareMedia {
            let cell = collectionView.cellForItem(at: indexPath) as! CODMediaCollectionViewCell
            cell.selectImageView.image = cell.isSelected ? UIImage.init(named: "person_selected") : UIImage.init(named: "person_select")
            messageModel.toImageModel(photoId: model.photoId)

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpSelectListNoti), object: messageModel)
        }else{

            var sourceData = self.keys.map { (key) -> [YBIBImageData] in
                return data[key]!
            }.flatMap { $0 }

            let photoIndex: Int = sourceData.firstIndex(of: model) ?? 0
            let browser:YBImageBrowser =  YBImageBrowser()
            let toolHander = YBIBToolViewHandler()
            toolHander.delegate = self
            browser.toolViewHandlers = [toolHander]
            let imageData: YBIBImageData = model
            
            imageData.msgID = model.msgID
//            imageData.projectiveView = collectionView.cellForItem(at: indexPath)
            sourceData[photoIndex] = imageData
            browser.dataSourceArray = sourceData
            browser.currentPage = photoIndex
            
            browser.delegate = self
            browser.show()
            self.photoBrowser = browser
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if XinhooTool.isMultiSelect_ShareMedia {
            
            let arr = data[keys[indexPath.section]]!
            let model = arr[indexPath.row]
            
            guard let messageModel = CODMessageRealmTool.generateNewMessage(by: model.msgID ?? "") else {
                return
            }
            messageModel.smsgID = model.msgID
            messageModel.toImageModel(photoId: model.photoId)
            
            let cell = collectionView.cellForItem(at: indexPath) as! CODMediaCollectionViewCell
            cell.selectImageView.image = cell.isSelected ? UIImage.init(named: "person_selected") : UIImage.init(named: "person_select")
            

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpSelectListNoti), object: messageModel)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: (KScreenWidth - 9)/4, height: (KScreenWidth - 9)/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let title = keys[indexPath.section]
        let arr = data[keys[indexPath.section]]!
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MediaCollectionReusableView", for: indexPath) as! MediaCollectionReusableView
        view.titleLab.text = title
        view.contentLab.text = String(format: NSLocalizedString("%ld 张图片", comment: ""), arr.count)
        
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
        lab.text = NSLocalizedString("暂无聊天图片", comment: "")
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



class CollectionViewFlowlayout: UICollectionViewFlowLayout {
    var naviHeight:CGFloat=0.0//默认分组停放高度
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //UICollectionViewLayoutAttributes：我称它为collectionView中的item（包括cell和header、footer这些）的结构信息
        //截取到父类所返回的数组（里面放的是当前屏幕所能展示的item的结构信息），并转化成不可变数组
        var superArray = super.layoutAttributesForElements(in: rect)
        //创建存索引的数组，无符号（正整数），无序（不能通过下标取值），不可重复（重复的话会自动过滤）
        let noneHeaderSections=NSMutableIndexSet();
        for  attributes:UICollectionViewLayoutAttributes in superArray! {
            //如果当前的元素分类是一个cell，将cell所在的分区section加入数组，重复的话会自动过滤
            if attributes.representedElementCategory == .cell{
                noneHeaderSections.add(attributes.indexPath.section)
            }
        }
        //遍历superArray，将当前屏幕中拥有的header的section从数组中移除，得到一个当前屏幕中没有header的section数组
        //正常情况下，随着手指往上移，header脱离屏幕会被系统回收而cell尚在，也会触发该方法
        for attributes:UICollectionViewLayoutAttributes in superArray! {
            //如果当前的元素是一个header，将header所在的section从数组中移除
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                noneHeaderSections.remove(attributes.indexPath.section)
            }
        }
        //遍历当前屏幕中没有header的section数组
        noneHeaderSections .enumerate({ (idx, obj) -> Void in
            //取到当前section中第一个item的indexPath
            let indexPath = NSIndexPath(item: 0, section: idx)
            let attributes=self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath as IndexPath)
            //如果当前分区确实有因为离开屏幕而被系统回收的header
            if attributes != nil {
                //将该header结构信息重新加入到superArray中去
                superArray?.append(attributes!)
            }
        })
        //遍历superArray，改变header结构信息中的参数，使它可以在当前section还没完全离开屏幕的时候一直显示
        for  attributes:UICollectionViewLayoutAttributes in superArray! {
            //如果当前item是header
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                //得到当前header所在分区的cell的数量
                let numberOfItemsInSection=self.collectionView!.numberOfItems(inSection: attributes.indexPath.section)
                //取到当前section中第一个item的indexPath
                let firstItemIndexPath = NSIndexPath(item: 0, section: attributes.indexPath.section)
                //得到最后一个item的indexPath
                let lastItemIndexPath = NSIndexPath(item: max(0, numberOfItemsInSection-1), section: attributes.indexPath.section)
                //得到第一个item和最后一个item的结构信息
                var firstItemAttributes, lastItemAttributes:UICollectionViewLayoutAttributes
                if numberOfItemsInSection>0 {
                    //cell有值，则获取第一个cell和最后一个cell的结构信息
                    firstItemAttributes=self.layoutAttributesForItem(at: firstItemIndexPath as IndexPath)!
                    lastItemAttributes=self.layoutAttributesForItem(at: lastItemIndexPath as IndexPath)!
                }else{
                    //cell没值,就新建一个UICollectionViewLayoutAttributes
                    firstItemAttributes=UICollectionViewLayoutAttributes()
                    //然后模拟出在当前分区中的唯一一个cell，cell在header的下面，高度为0，还与header隔着可能存在的sectionInset的top
                    let y=attributes.frame.maxY + sectionInset.top
                    firstItemAttributes.frame=CGRect(x: 0, y: y, width: 0, height: 0)
                    //因为只有一个cell，所以最后一个cell等于第一个cell
                    lastItemAttributes=firstItemAttributes;
                }
                //获取当前header的frame
                var rect=attributes.frame;
                //当前的滑动距离 + 因为导航栏产生的偏移量，默认为0（如果app需求不同，需自己设置）
                let offset=(self.collectionView?.contentOffset.y)! + naviHeight
                //第一个cell的y值 - 当前header的高度 - 可能存在的sectionInset的top
                let headerY=firstItemAttributes.frame.origin.y-rect.size.height-sectionInset.top
                //哪个大取哪个，保证header悬停
                //针对当前header基本上都是offset更加大，针对下一个header则会是headerY大，各自处理
                let maxY=max(offset, headerY)
                //最后一个cell的y值 + 最后一个cell的高度 + 可能存在的sectionInset的bottom - 当前header的高度
                //当当前section的footer或者下一个section的header接触到当前header的底部，计算出的headerMissingY即为有效值
                let headerMissingY = lastItemAttributes.frame.maxY + sectionInset.bottom - rect.size.height;
                //给rect的y赋新值，因为在最后消失的临界点要跟谁消失，所以取小
                rect.origin.y=min(maxY, headerMissingY)
                //给header的结构信息的frame重新赋值
                attributes.frame=rect
                //如果按照正常情况下,header离开屏幕被系统回收，而header的层次关系又与cell相等，如果不去理会，会出现cell在header上面的情况
                //通过打印可以知道cell的层次关系zIndex数值为0，我们可以将header的zIndex设置成1，如果不放心，也可以将它设置成非常大，这里随便填了个7
                attributes.zIndex=7
                
            }
        }
        return superArray
    }
    //return true;表示一旦滑动就实时调用上面这个layoutAttributesForElementsInRect:方法
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let arr =       ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1597655455127&di=596fa5a7f5edc2b33888410dc9fb3cc4&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201611%2F04%2F20161104110413_XzVAk.thumb.700_0.gif",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1597655588354&di=dc36544810d771bc3dfcacdfe711a380&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20170621%2F067783d7cd7249908a82cd42b3c69e94.gif",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1597654989600&di=d31d8d2f16bc1dc41199ec9f077c7412&imgtype=0&src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201410%2F14%2F20141014171627_ssXRa.gif",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1597654989599&di=0dc6f8f49ed495b84b76ae20dc645f94&imgtype=0&src=http%3A%2F%2Fwww.flybridal.com%2Fhuangse%2FaHR0cDovL2ltZy5wY29ubGluZS5jb20uY24vaW1hZ2VzL3VwbG9hZC91cGMvdHgvcGNkbGMvMTcwNi8wNy9jMjAvNDkyODMyMzhfMTQ5NjgzNDcyNjc4OS5naWY%3D.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1597654989598&di=4ee40e1e92b4a90c04cd0ee1e7f57913&imgtype=0&src=http%3A%2F%2Fww3.sinaimg.cn%2Fmw690%2F4a46b55djw1dyxtn488ugg.gif",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1597655192938&di=c553a36308a880232c1d1c4e411bfddb&imgtype=0&src=http%3A%2F%2Fhbimg.b0.upaiyun.com%2F357d23d074c2954d568d1a6f86a5be09d190a45116e95-0jh9Pg_fw658",
        "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3531761125,3665413676&fm=26&gp=0.jpg",
        "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1674760321,2881373110&fm=26&gp=0.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1597655221010&di=b0504429ece2299583c593d4760f5655&imgtype=0&src=http%3A%2F%2Fa.hiphotos.baidu.com%2Fexp%2Fw%3D500%2Fsign%3Df5dea38f0af41bd5da53e8f461db81a0%2F0b55b319ebc4b745cb69f3b2cbfc1e178b821590.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1597655264041&di=6eb14fb862b960b8aed1a7317d71d028&imgtype=0&src=http%3A%2F%2Fs6.sinaimg.cn%2Forignal%2F49b83b33b95c7dae11f65"]
        
        let configuration = UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: {
            
            return PhotoPreviewViewController(imageName: arr[indexPath.row])
            
        }) { (element) -> UIMenu? in

            let sendAction = UIAction(title: "发送", image: nil, identifier: UIAction.Identifier("send"), discoverabilityTitle: nil, attributes: UIAction.Attributes(), state: .off) { (action) in
                
            }
            
            let deleteAction = UIAction(title: "删除", image: nil, identifier: UIAction.Identifier("delete"), discoverabilityTitle: nil, attributes: .destructive, state: .off) { (action) in
                
            }
            
            let menu = UIMenu(title: "", image: nil, identifier: UIMenu.Identifier("menu"), options: .displayInline, children: [sendAction,deleteAction])
            return menu
        }

        return configuration
    }
    
}
extension MediaImageViewController:YBToolViewClickHandlerDelegate{
    
    func shareYBImageData(_ data: YBIBImageData) {
        
        let shareView = CODShareImagePicker(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        shareView.imageData = data
        shareView.contactListArr = CODGlobalDataSource.getContactGroupChannelModelData(isHeadCloudDisk: true, ignoreIDs: [NewFriendRosterID])
        shareView.msgID = data.msgID ?? ""
        shareView.msgUrl = data.imageURL?.absoluteString ?? ""
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
//        var index = 0
        
        var dataSource = self.photoBrowser?.dataSourceArray ?? []
        
        dataSource.removeAll { (dataProtocol) -> Bool in
            if let imageData = dataProtocol as? YBIBImageData {
                if imageData.msgID == messageID {
                    return true
                }
            }
            if let imageData = dataProtocol as? YBIBVideoData {
                if imageData.msgID == messageID {
                    return true
                }
            }
            
            return false
        }

   
        
        self.photoBrowser?.dataSourceArray = dataSource
        CustomUtil.isPlayVideo(isPlay: false,isDelete: true)
        self.photoBrowser?.reloadData()
    }
    
    
}
