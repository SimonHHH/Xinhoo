//
//  Xinhoo_DiscoverPublishViewController.swift
//  COD
//
//  Created by xinhooo on 2020/5/9.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import NextGrowingTextView
import RxSwift
import RxCocoa
import JXPhotoBrowser


extension Reactive where Base : Xinhoo_DiscoverPublishViewController{
    var setModelAttributeBinder: Binder<CODCirclePublishVM?> {
        return Binder(base) { (vc, publishVM) in
            vc.reloadView()
        }
    }
}

class Xinhoo_DiscoverPublishViewController: BaseViewController {
    
    var normalHeight = (KScreenWidth - 82) / 3
    
    @IBOutlet weak var textBackView: UIView!
    @IBOutlet weak var textBackViewHeightCos: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightCos: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var delViewBottomCos: NSLayoutConstraint!
    @IBOutlet weak var delView: UIView!
    @IBOutlet weak var delTipLab: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    var textView: NextGrowingTextView = NextGrowingTextView()
    var selectedCell: UICollectionViewCell?
    var snapImageView: UIView?
    var selectedIndexPath: IndexPath?
    
    var publishVM: CODCirclePublishVM = CODCirclePublishVM()
    
    enum MoveState {
        case none
        case move
        case delte
    }
    
    var state: MoveState = .none
    
    enum KeyboardType {
        case text
        case emoji
    }
    
    var keyType: KeyboardType = .text
    
    /// 表情管理者
    lazy var emojiKBHelper:CODExpressionHelper = {
        let emojiKBHelper = CODExpressionHelper.sharedHelper()
        return emojiKBHelper
    }()

    ///表情键盘
    lazy var emojiKeyboard: CODEmojiKeyboard = {
        let emojiKeyboard = CODEmojiKeyboard(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 300))
        emojiKeyboard.emjioGroupControl.isNeedSendBtn = false
        return emojiKeyboard
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = UserDefaults.standard.data(forKey: "CircleDraft") {
        
            do{
            
                if let publishModel = try? JSONDecoder().decode(CODCirlcePublishModel.self, from: data) {
                    self.publishVM.publishModel = publishModel
                }
                
            }
            
            
        }
        
        configView()
        configRx()
        self.textView.textView.text = self.publishVM.publishModel.content
        
        self.emojiKeyboard.delegate = self
        self.emojiKBHelper.emojiGroupData(userID:"",filterGif: true) {[weak self] (dataArray) in
            self?.emojiKeyboard.emojiGroupData = dataArray
        }
        
        let toolView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 45))
        toolView.backgroundColor = UIColor(hexString: "F8F8F8")
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "emoji_input_icon"), for: .normal)
        button.addTarget(self, action: #selector(changeKeyboardAction(_:)), for: .touchUpInside)
        
        toolView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        self.textView.textView.inputAccessoryView = toolView
        
        self.reloadView()
        
    }
    
    @objc func changeKeyboardAction(_ sender: UIButton) {
        
        
        if !self.textView.textView.isFirstResponder {
            self.textView.textView.becomeFirstResponder()
        }
        
        if keyType == .text {
        
            sender.setImage(UIImage(named: "text_input_icon"), for: .normal)
            keyType = .emoji
            
            textView.textView.inputView = self.emojiKeyboard
            
        }else{
            sender.setImage(UIImage(named: "emoji_input_icon"), for: .normal)
            keyType = .text
            textView.textView.inputView = nil
        }
        
        textView.textView.reloadInputViews()
    }
    
    func configRx() {
        publishVM.setModelAttribute?
            .bind(to: self.rx.setModelAttributeBinder)
            .disposed(by: self.rx.disposeBag)
    }
    
    override func navBackClick() {
        
        if self.rightTextButton.isEnabled {
            
            let alert = UIAlertController.init(title: nil, message: NSLocalizedString("将此次编辑保留？", comment: ""), preferredStyle: .alert)
            
            alert.addAction(title: NSLocalizedString("不保留", comment: ""), style: .default, isEnabled: true) { [weak self] (action) in
                
                guard let `self` = self else {
                    return
                }
                
                UserDefaults.standard.set(nil, forKey: "CircleDraft")
                self.dismiss(animated: true) {
                    IQKeyboardManager.shared.enable = false
                }
            }
            
            alert.addAction(title: NSLocalizedString("保留", comment: ""), style: .default, isEnabled: true) { [weak self] (action) in
                
                guard let `self` = self else {
                    return
                }
                let encoder = JSONEncoder()
                let data = try! encoder.encode(self.publishVM.publishModel)
                UserDefaults.standard.set(data, forKey: "CircleDraft")
                self.dismiss(animated: true) {
                    IQKeyboardManager.shared.enable = false
                }
            }
            
            self.present(alert, animated: true, completion: nil)

        }else{
            
            UserDefaults.standard.set(nil, forKey: "CircleDraft")
            self.dismiss(animated: true) {
                IQKeyboardManager.shared.enable = false
            }
        }
        
        
    }
    
    func configView() {
        
        self.backButton.setImage(UIImage(named: "circle_back_publish"), for: .normal)
        self.backButton.setTitle("  ", for: .normal)
        self.setBackButton()
        
        self.setRightTextButton()
        self.rightTextButton.setTitle("发布 ", for: .normal)
        self.rightTextButton.setTitleColor(UIColor(hexString: "047EF5"), for: .normal)
        self.rightTextButton.setTitleColor(UIColor(hexString: "787878")?.withAlphaComponent(0.4), for: .disabled)
        self.rightTextButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        
        textView.textView.placeholder = NSLocalizedString("这一刻的想法...", comment: "")
        textView.textView.font = UIFont.systemFont(ofSize: 17)
        textBackView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        textView.maxNumberOfLines = 7
        textView.minNumberOfLines = 3
        
        // 监控文本输入框的高度，动态改变约束
        textView.delegates.didChangeHeight = { [weak self] (height) in
            
            guard let `self` = self else {
                return
            }
            self.textBackViewHeightCos.constant = height
        }
        textView.textView.delegate = self
        
        collectionViewHeightCos.constant = normalHeight * 3 + 10
        collectionView.register(UINib(nibName: "CODCirclePublishCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "imageCell")
        
        // 为collectionView添加长按手势。
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(reorderCollectionView(longPressGesture:)))
        longPressGesture.minimumPressDuration = 0.2
        collectionView.addGestureRecognizer(longPressGesture)
        
        tableView.register(UINib(nibName: "CODCirclePublishTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "setCell")
        
        delTipLab.text = NSLocalizedString("拖动到此处删除", comment: "")
    }
    
    func reloadView() {
        
        let publishModel = self.publishVM.publishModel
                
        if publishModel.circleType == .video {
            
            normalHeight = 225
            
        }else{
            
            normalHeight = (KScreenWidth - 82) / 3
        }
        
        if publishModel.circleType == .text {
            
            if self.textView.textView.text.removeAllSapce.count == 0 {
            
                self.rightTextButton.isEnabled = false
            }else{
                self.rightTextButton.isEnabled = true
            }
            
        }else{
            
            self.rightTextButton.isEnabled = true
        }
        
        
        
        self.tableView.reloadData()
        self.collectionView.reloadData()
        
        // 监控集合数据变化，动态改变collectionView的高度
        if self.publishVM.publishModel.itemList.count >=  6 {
            
            collectionViewHeightCos.constant = normalHeight * 3 + 10
            
        }else if self.publishVM.publishModel.itemList.count >= 3 {
            
            collectionViewHeightCos.constant = normalHeight * 2 + 5
            
        }else{
            collectionViewHeightCos.constant = normalHeight
        }
        
    }
    
    @objc func reorderCollectionView(longPressGesture:UILongPressGestureRecognizer) {
        
        switch longPressGesture.state {
        case .began:
            
            let touchPoint = longPressGesture.location(in: collectionView)
            
            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                
                
                // 开始执行移动操作
                
                
                if self.publishVM.publishModel.itemList.count != indexPath.item {
                    
                    // 记录当前长按选中的cell的indexPath
                    selectedIndexPath = indexPath
                    
                    // 显示删除视图
                    self.showDelView()
                    
                    // 获取选中的cell 并映射到snapImageView上
                    let targetCell = collectionView.cellForItem(at: selectedIndexPath!)
                    let cellView = targetCell?.snapshotView(afterScreenUpdates: true)
                    snapImageView = cellView
                    snapImageView?.frame = cellView!.frame
                    targetCell?.isHidden = true
                    
                    self.view.addSubview(snapImageView!)
                    
                    let center = collectionView.convert(targetCell!.center, to: self.view)
                    cellView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    cellView?.center = center
                    
                    collectionView.beginInteractiveMovementForItem(at: selectedIndexPath!)
                }
                
                
            }
            break
        case .changed:
            
            guard let snapV = snapImageView else {
                return
            }
            
            guard let _ = selectedIndexPath else {
                return
            }
            
            let touchPoint = longPressGesture.location(in: collectionView)
            snapV.center = longPressGesture.location(in: self.view)
            
            if let moveToIndexPath = collectionView.indexPathForItem(at: touchPoint) {
                state = .move
                
                
                if self.publishVM.publishModel.itemList.count != moveToIndexPath.item {
                    
                    collectionView.updateInteractiveMovementTargetPosition(touchPoint)
                }
                
                
            }else{
                
                let delFrame = self.delView.frame
                
                if delFrame.intersects(snapV.frame) {
                    state = .delte
                    self.moveInDelArea()
                }else{
                    state = .none
                    self.leaveDelArea()
                }
                
            }
            break
        case .ended:
            
            guard let selectedIndexPath = selectedIndexPath else {
                return
            }
            
            if state == .delte {
                
                collectionView.endInteractiveMovement()
                
                self.publishVM.publishModel.itemList.remove(at: selectedIndexPath.item)
                
                if self.publishVM.publishModel.itemList.count == 0 {
                    self.publishVM.updateType(type: .text)
                    self.publishVM.publishModel.video = nil
                }else{
                    self.publishVM.updateType(type: self.publishVM.publishModel.circleType)
                }
                
                self.snapImageView?.removeFromSuperview()
                
            }else{
                let cell = collectionView.cellForItem(at: selectedIndexPath)
                let center = collectionView.convert(cell!.center, to: self.view)
                UIView.animate(withDuration: 0.1, animations: {
                    self.snapImageView?.center = center
                }) { (finished) in
                    self.snapImageView?.removeFromSuperview()
                    cell?.isHidden = false
                    self.collectionView.endInteractiveMovement()
                }
            }
            
            self.hideDelView()
            break
        default:
            collectionView.cancelInteractiveMovement()
            self.hideDelView()
            break
        }
    }
    
    /// 显示删除视图
    func showDelView() {
        if let pop = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant) {
            pop.toValue = 0
            pop.duration = 0.25
            self.delViewBottomCos.pop_add(pop, forKey: "")
        }
    }
    
    /// 隐藏删除视图
    func hideDelView() {
        if let pop = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant) {
            pop.toValue = -80
            pop.duration = 0.25
            self.delViewBottomCos.pop_add(pop, forKey: "")
        }
    }
    
    /// 进入删除视图的范围
    func moveInDelArea() {
        delTipLab.text = NSLocalizedString("松手即可删除", comment: "")
        delView.backgroundColor = UIColor(hexString: "EC473E")
    }
    
    /// 离开删除视图的范围
    func leaveDelArea() {
        delTipLab.text = NSLocalizedString("拖动到此处删除", comment: "")
        delView.backgroundColor = UIColor(hexString: "FE4B41")
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true) {
            IQKeyboardManager.shared.enable = false
        }
    }
    //MARK: 发布朋友圈
    override func navRightTextClick() {
        
        UserDefaults.standard.set(nil, forKey: "CircleDraft")

        self.rightTextButton.isUserInteractionEnabled = false
        self.textView.textView.resignFirstResponder()
        
        CirclePublishTool.share.publishCircle(publishVM: self.publishVM)
        self.dismiss(animated: true) {
            IQKeyboardManager.shared.enable = false
        }
    }
//    
    //MARK: 提醒的人
    func pushAtContact() {
        
        
        let ctl = CreGroupChatViewController() ////提醒谁看
        ctl.ctlType = .friendsCcRemindRead
        ctl.maxSelectedCount = 10
        ctl.selectedRemindsSuccess = { [weak self] (contactList) in
            
            guard let `self` = self else {
                return
            }
            
            let jidList = contactList.map { (model) -> String in
                return model.jid
            }
            self.publishVM.updateAtList(contactList: jidList)
            
            print(contactList)
        }
        
        var contactList: [CODContactModel] = []
        for jid in self.publishVM.publishModel.atList {
            if let contactModel = CODContactRealmTool.getContactByJID(by: jid) {
                contactList.append(contactModel)
            }
        }

        ctl.selectedArray = contactList
        
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
    //MARK: 评论点赞设置
    func pushCommentAndLikeSet(isOpen:Bool) {
        let vc = CODCommentLikeSetViewController(nibName: "CODCommentLikeSetViewController", bundle: Bundle.main)
        vc.vcType = isOpen ? .visibleCommentAndLike : .canCommentAndLike
        vc.publishVM = self.publishVM
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    //MARK: 可见
    func pushCanReadSet() {
        let ctl = CODCanReadViewController()
        
        var typeRowValue: Int = 1
        typeRowValue = self.publishVM.publishModel.canLook.permissions.rawValue
        ctl.type = CODCanReadViewModel.CanReadType.init(rawValue: typeRowValue)!
        ctl.canReadContacts = self.publishVM.publishModel.canLook.contactList
        ctl.canReadGroups = self.publishVM.publishModel.canLook.groupList
        ctl.canReadSelectComplete = { [weak self] (canReadType, groupJids, contactJids) in
            
            guard let `self` = self else {
                return
            }
            self.updateCanReadSet(canReadType: canReadType, canReadGroups: groupJids, canReadContacts: contactJids)
            
        }
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
    func updateCanReadSet(canReadType: CODCanReadViewModel.CanReadType, canReadGroups: [String]?, canReadContacts: [String]?) {
        
        var type: CODCirlcePublishModel.CanLook.Permissions = .publicity
        
        switch canReadType {
            
        case .public:
            type = .publicity
            break
            
        case .private:
            type = .onlySelf
            break
            
        case .partialCanRead:
            type = .somePeople_canSee
            break
            
        case .partialNotRead:
            type = .somePeople_notSee
            break
        }
        
        if type == .onlySelf && self.publishVM.publishModel.atList.count != 0{
            self.showOnlySelfAlert { [weak self] in
                
                guard let `self` = self else {
                    return
                }
                
                self.publishVM.updateCanLook(canLookType: type, groupJids: canReadGroups, contactJids: canReadContacts)
            }
        }else{
            self.publishVM.updateCanLook(canLookType: type, groupJids: canReadGroups, contactJids: canReadContacts)
        }
        
        
    }
        
        
    func showOnlySelfAlert(compelet:(() -> ())? = nil) {
        let alert = UIAlertController(title: NSLocalizedString("可见范围选择私密时，“提醒谁看”此功能不可使用", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(title: NSLocalizedString("确定", comment: ""), style: .default, isEnabled: true) { (action) in
            compelet?()
        }
        self.present(alert, animated: true, completion: nil)
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

extension Xinhoo_DiscoverPublishViewController {
    
    func showPhotoWay() {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "拍照", style: UIAlertAction.Style.default){ [weak self] (action:UIAlertAction)in
            self?.initCameraPicker()
        }
        let photoAction = UIAlertAction(title: "从相册中选择", style: UIAlertAction.Style.default){ [weak self] (action:UIAlertAction)in
            self?.initPhotoPicker()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel){ (action:UIAlertAction)in
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    /// 从相册选择
    func initPhotoPicker(){
        let tzImgPicker = CustomUtil.getImagePickController(maxImagesCount: 9 - self.publishVM.publishModel.itemList.count, delegate: self)
        tzImgPicker?.isSelectOriginalPhoto = true
        tzImgPicker?.allowTakeVideo  = false
        tzImgPicker?.allowTakePicture  = false
        tzImgPicker?.allowPickingVideo = (self.publishVM.publishModel.circleType != .image)
        tzImgPicker?.allowPickingGif = false
        tzImgPicker?.allowPickingImage = true
        tzImgPicker?.isSelectOriginalPhoto = false
        tzImgPicker?.allowPickingOriginalPhoto = false
        tzImgPicker?.photoPickerPageDidRefreshStateBlock = { (_, _, _, _, _, doneButton, _, _, _) in
            doneButton?.hitWidthScale = 3
        }
        self.present(tzImgPicker!, animated: true, completion: nil)
        
    }
    
    ///  拍照
    func initCameraPicker() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if authStatus == .denied || authStatus == .restricted {
            
            CODAlertViewToSetting_show("无法访问您的相机", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 相机 -> 打开访问权限"), showVC: self )
            
        }else{
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                
                let cameraController = TXCameraController.default()
                // 拍照完成后回调
                cameraController.takePhotosCompletionBlock = {[weak self](_ image:UIImage,error:Error,capView: CODPictureCaptionView) in
                    if image.bytesSize > 0 {
                        
                        guard let `self` = self else {
                            return
                        }
                        
                            
                        self.publishVM.publishModel.itemList.append(CODCirlcePublishModel.CircleImage(image: image))
                        self.publishVM.updateType(type: .image)
                        

                    }else{
                        CODProgressHUD.showErrorWithStatus(NSLocalizedString("照片保存失败", comment: ""))
                    }
                }
                
                cameraController.shootCompletionBlock = {[weak self,weak cameraController](_ videoUrl:URL, videoTimeLength:CGFloat, thumbnailImage:UIImage?, error:Error?,capView: CODPictureCaptionView) in
                    if let thumbnailImage = thumbnailImage, videoTimeLength > 0 {
                        
                        guard let `self` = self else {
                            return
                        }
                        
                        
                        
                        self.publishVM.publishModel.itemList.append(CODCirlcePublishModel.CircleImage(image: thumbnailImage))
                        
                        if let data: Data = try? Data.init(contentsOf: videoUrl) {
                            
                            let video = CODCirlcePublishModel.VideoInfo(firstImage: thumbnailImage, videoData: data, duration: Double(videoTimeLength), localURL: videoUrl.path)
                            self.publishVM.publishModel.video = video
                            
                            
                        }
                        
                        
                        self.publishVM.updateType(type: .video)
                        cameraController?.navigationController?.popViewController()
                        
                    }else{
                        CODProgressHUD.showErrorWithStatus(NSLocalizedString("视频保存失败", comment: ""))
                    }
                    
                }
                
                
                self.navigationController?.pushViewController(cameraController)
            }else{
                ///没有相机权限
                CODAlertVcPresent(confirmBtn: nil, message: "提示", title: "当前的设备不支持！", cancelBtn: "确定", handler: { (actin) in
                    
                }, viewController: self)
            }
        }
    }
    
}

extension Xinhoo_DiscoverPublishViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.publishVM.publishModel.circleType == .video {
            
            return 1
            
        }else{
        
            return (self.publishVM.publishModel.itemList.count < 9) ? (self.publishVM.publishModel.itemList.count + 1) : self.publishVM.publishModel.itemList.count
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CODCirclePublishCollectionViewCell
        
        var isAddCell = false
        
        if self.publishVM.publishModel.itemList.count  == indexPath.item{
            isAddCell = true
        }
        
        cell.playImgView.isHidden = !(self.publishVM.publishModel.circleType == .video)
        
        if isAddCell {
            
            cell.imgView.image = UIImage(named: "circle_add_publish")
            cell.playImgView.isHidden = true
            
        }else{
            
            let circleImage = self.publishVM.publishModel.itemList[indexPath.item]
            cell.imgView.image = circleImage.image
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var isAddCell = false
        
        if self.publishVM.publishModel.itemList.count == indexPath.item{
            isAddCell = true
        }
        
        if isAddCell {

            if self.publishVM.publishModel.circleType == .image {
    
                self.initPhotoPicker()
            }else{
                
                self.showPhotoWay()
            }
            
        }else {
            
            var dataSource:[YBIBDataProtocol] = []
            var imageDataSource:[UIImage] = []

            let publishModel = publishVM.publishModel
            
            if publishModel.circleType == .video {
                
                let videoData = YBIBVideoData()
                videoData.thumbImage = publishModel.video?.firstImage
                videoData.videoURL = URL(fileURLWithPath: publishModel.video?.localURL ?? "")
                videoData.isHiddenPlayBtn = true
                videoData.autoPlayCount = 1
                videoData.singleTouchBlock = { (data) in
                }
                dataSource.append(videoData)
    
                let browser:YBImageBrowser =  YBImageBrowser()
                let toolHander = YBIBToolViewHandler()
                toolHander.fromType = FromCircle_Publish
                toolHander.delegate = self
                browser.toolViewHandlers = [toolHander]
                browser.dataSourceArray = dataSource
                browser.currentPage = indexPath.item
                browser.show()
            }else{
                for circleImage in publishModel.itemList {
                    imageDataSource.append(circleImage.image)
                }
                
                let browser = JXPhotoBrowser()
                browser.numberOfItems = {
                    imageDataSource.count
                }
                browser.reloadCellAtIndex = { context in
                    
                    let browserCell = context.cell as? JXPhotoBrowserImageCell
                    browserCell?.index = context.index
                    browserCell?.imageView.image =  imageDataSource[context.index]
                }
                browser.transitionAnimator = JXPhotoBrowserZoomAnimator(previousView: { [weak self] index -> UIView? in
                    
                    let path = IndexPath(item: index, section: indexPath.section)
                    let cell = collectionView.cellForItem(at: path) as? CODCirclePublishCollectionViewCell
                    return cell?.imgView

                })
                // UIPageIndicator样式的页码指示器
                browser.pageIndicator = JXPhotoBrowserDefaultPageIndicator()
                browser.pageIndex = indexPath.section + indexPath.row
                browser.show()
            }
            
        }
                
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.publishVM.publishModel.circleType == .video {
            return CGSize(width: 168, height: normalHeight)
        }else{
        
            return CGSize(width: normalHeight, height: normalHeight)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        if indexPath.item == self.publishVM.publishModel.itemList.count {
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if state == .delte {
            return
        }
        let targetObject = self.publishVM.publishModel.itemList[sourceIndexPath.item]
        self.publishVM.publishModel.itemList.remove(at: sourceIndexPath.item)
        self.publishVM.publishModel.itemList.insert(targetObject, at: destinationIndexPath.item)
    }
}

extension Xinhoo_DiscoverPublishViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.publishVM.publishModel.canLook.permissions == .onlySelf {
            
            return 3
        }else{
        
            //如果不允许点赞评论，则隐藏是否公开点赞评论设置项
            if self.publishVM.publishModel.isCanCommentAndLike == 2 {
            
                return 5
            }else{
                return 4
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath) as! CODCirclePublishTableViewCell
        cell.selectionStyle = .none
        let cellInfo = self.publishVM.getCellInfo(index: indexPath.row)
        cell.configView(cellInfo: cellInfo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            
            let status = CLLocationManager.authorizationStatus()
             if status == .authorizedAlways || status == .authorizedWhenInUse || status == .notDetermined {

                let vc = CODPublishPositionViewController(nibName: "CODPublishPositionViewController", bundle: Bundle.main)
                vc.publishVM = self.publishVM
                self.navigationController?.pushViewController(vc, animated: true)
                 
            }else{
                ///提示用户
                CODAlertViewToSetting_show("无法访问您的位置", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 位置 -> 打开访问权限"), showVC: self)
            }
            
            
            break
            
        case 1:
            
            if self.publishVM.publishModel.canLook.permissions == .onlySelf {

                self.showOnlySelfAlert()
            }else{
            
                self.pushAtContact()
            }            
            
            break
        case 2:
            self.pushCanReadSet()
        case 3,4:
            let isOpen = (indexPath.row == 4)
            self.pushCommentAndLikeSet(isOpen: isOpen)
            break
        default:
            break
        }
        
        
    }
}

extension Xinhoo_DiscoverPublishViewController: TZImagePickerControllerDelegate {
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
            
        let circleImageList = photos.map { (image) -> CODCirlcePublishModel.CircleImage in
            return CODCirlcePublishModel.CircleImage(image: image)
        }
        
        self.publishVM.publishModel.itemList.append(contentsOf: circleImageList)
        self.publishVM.updateType(type: .image)
        
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: PHAsset!) {
        
        
        if asset.duration >= 60.5 {
            
            CODProgressHUD.showErrorWithStatus(NSLocalizedString("只支持60秒以内的视频发布哦", comment: ""))
            
            return
        }
        
        CODProgressHUD.showWithStatus(NSLocalizedString("  视频处理中...  ", comment: ""))
        
        TZImageManager.default()?.getVideoOutputPath(with: asset, presetName: AVAssetExportPreset1280x720, success: { (videoPath) in
        
            CODProgressHUD.dismiss()
            self.publishVM.publishModel.itemList.append(CODCirlcePublishModel.CircleImage(image: coverImage))
            
            
            if let data: Data = FileManager.default.contents(atPath: videoPath ?? "") {
            
                let video = CODCirlcePublishModel.VideoInfo(firstImage: coverImage, videoData: data, duration: asset.duration, localURL: videoPath ?? "")
                self.publishVM.publishModel.video = video
                
                
            }
            
            
            self.publishVM.updateType(type: .video)
        }, failure: nil)
        
        
        
    }
}

extension Xinhoo_DiscoverPublishViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.publishVM.updateContent(content: textView.text)
    }
}

extension Xinhoo_DiscoverPublishViewController: YBToolViewClickHandlerDelegate{
    func shareYBImageData(_ data: YBIBImageData) {
        
    }
    
    func deleteYBImageData(_ data: YBIBImageData, superView: UIView, currentPage: Int) {
        
    }
    
    
}

extension Xinhoo_DiscoverPublishViewController: CODEmojiKeyboardDelegate {
    func emojiKeyboardDidTouchEmojiItem(emojiKB: CODEmojiKeyboard, emoji: CODExpressionModel, atRect: CGRect) {
        print(#line,#function)
    }
    
    func emojiKeyboardCancelTouchEmojiItem(emojiKB: CODEmojiKeyboard) {
        print(#line,#function)
    }
    
    func emojiKeyboardDidSelectedEmojiItem(emojiKB: CODEmojiKeyboard, emoji: CODExpressionModel) {
        print(#line,#function)
        
        self.textView.textView.insertText(emoji.name ?? "")
        
    }
    
    func emojiKeyboardSendButtonDown() {
        print(#line,#function)
//        if textView.textView.text.removeAllSapce.count != 0 {
//            self.publishComment()
//        }
        
    }
    
    func emojiKeyboardDeleteButtonDown() {
        print(#line,#function)
        self.textView.textView.deleteBackward()
    }
    
    func emojiKeyboardSelectedEmojiGroupType(emojiKB: CODEmojiKeyboard, type: CODEmojiType) {
        print(#line,#function)
    }
    
    func emojiKeyboardScrollStatus(emojiKB: CODEmojiKeyboard, isScrollUp: Bool) {
        print(#line,#function)
    }
    
    
}
