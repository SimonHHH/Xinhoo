//
//  ScanViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/21.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import XMPPFramework

public protocol CODScanViewControllerDelegate: class {
    func scanFinished(scanResult: CODScanResult, error: String?)
}

public protocol QRRectDelegate: class {
    func drawwed()
}
class ScanViewController: BaseViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //返回扫码结果，也可以通过继承本控制器，改写该handleCodeResult方法即可
    open weak var scanResultDelegate: CODScanViewControllerDelegate?
    
    open weak var delegate: QRRectDelegate?
    
    open var scanObj: CODScanWrapper?
    
    open var scanStyle: CODScanViewStyle? = CODScanViewStyle()
    
    open var qRScanView: CODScanView?
    //启动区域识别功能
    open var isOpenInterestRect = false
    
    //识别码的类型
    public var arrayCodeType:[AVMetadataObject.ObjectType]?
    
    //是否需要识别后的当前图像
    public  var isNeedCodeImage = false
    
    //相机启动提示文字
//    public var readyString:String! = "请稍后..."
    lazy var imagePickerManager : TZImagePickerController = {
        let tzImgPicker = CustomUtil.getImagePickController(maxImagesCount: 1, delegate: self)
        tzImgPicker?.isSelectOriginalPhoto = true
        tzImgPicker?.allowTakeVideo  = false
        tzImgPicker?.allowTakePicture  = false
        tzImgPicker?.allowPickingVideo = false
        tzImgPicker?.allowPickingGif = false
        return tzImgPicker ?? TZImagePickerController()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.blockRotation = true
        DeviceTool.interfaceOrientation(.portrait)
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        CODPermissions.authorizeCameraWith { [weak self] (granted) in
            if !granted {
                CODAlertViewToSetting_show("无法访问您的相机", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 相机 -> 打开访问权限") )
            }else{
            }
        }
        self.navigationItem.title = NSLocalizedString("扫一扫", comment: "")
        self.initQRScanStyle()
        self.setBackButton()
        self.rightTextButton.setTitle("  相册  ", for: .normal)
        self.rightTextButton.setTitleColor(UIColor.init(hexString: "#007DE7"), for: .normal)
        self.setRightTextButton()
        self.view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }
    
    open func initQRScanStyle(){
        var style = CODScanViewStyle()
        style.photoframeLineW = 4
        style.isNeedShowRetangle = true
        style.colorAngle = UIColor(red: 10.0/255, green: 101.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        style.animationImage = UIImage(named: "qrcode_Scan_Line")
        self.scanStyle = style
    }
    open func setNeedCodeImage(needCodeImg:Bool)
    {
        isNeedCodeImage = needCodeImg;
    }
    //设置框内识别
    open func setOpenInterestRect(isOpen:Bool){
        isOpenInterestRect = isOpen
    }
    
    
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.blockRotation = true
        DeviceTool.interfaceOrientation(.portrait)
        CODPermissions.authorizeCameraWith { [weak self] (granted) in
            if granted {
                self?.changeAuthorizeCamera()
            }
        }
      
    }
    func changeAuthorizeCamera() {
        drawScanView()
        perform(#selector(ScanViewController.startScan), with: nil, afterDelay: 0.3)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.blockRotation = false
    }
    
    @objc open func startScan()
    {
        
        if (scanObj == nil)
        {
            var cropRect = CGRect.zero
            if isOpenInterestRect
            {
                cropRect = CODScanView.getScanRectWithPreView(preView: self.view, style:scanStyle! )
            }
            
            //指定识别几种码
            if arrayCodeType == nil
            {
                arrayCodeType = [AVMetadataObject.ObjectType.qr as NSString ,AVMetadataObject.ObjectType.ean13 as NSString ,AVMetadataObject.ObjectType.code128 as NSString] as [AVMetadataObject.ObjectType]
            }
            
            scanObj = CODScanWrapper(videoPreView: self.view,objType:arrayCodeType!, isCaptureImg: isNeedCodeImage,cropRect:cropRect, success: { [weak self] (arrayResult) -> Void in
                
                if let strongSelf = self
                {
                    //停止扫描动画
                    strongSelf.qRScanView?.stopScanAnimation()
                    
                    strongSelf.handleCodeResult(arrayResult: arrayResult)
                }
            })
        }
        
        //结束相机等待提示
        qRScanView?.deviceStopReadying()
        
        //开始扫描动画
        qRScanView?.startScanAnimation()
        
        //相机运行
        scanObj?.start()
    }
    
    open func drawScanView()
    {
        if qRScanView == nil
        {
            qRScanView = CODScanView(frame: self.view.frame,vstyle:scanStyle! )
            self.view.addSubview(qRScanView!)
            delegate?.drawwed()
            qRScanView?.addMyQRBtn()
            qRScanView?.QRBtn?.addTarget(self, action: #selector(pushToMyQRVC), for:.touchUpInside )
        }
//        qRScanView?.deviceStartReadying(readyStr: readyString)
        
    }
    
    /**
     处理扫码结果，如果是继承本控制器的，可以重写该方法,作出相应地处理，或者设置delegate作出相应处理
     */
    open func handleCodeResult(arrayResult:[CODScanResult])
    {
        if let delegate = scanResultDelegate  {
            
            self.navigationController? .popViewController(animated: true)
            let result:CODScanResult = arrayResult[0]
            delegate.scanFinished(scanResult: result, error: nil)
        }else{
            
            for result:CODScanResult in arrayResult
            {
                print("%@",result.strScanned ?? "")
            }
            let result:CODScanResult = arrayResult[0]
            showMsg(title: result.strBarCodeType, message: result.strScanned)
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        qRScanView?.stopScanAnimation()
        
        scanObj?.stop()
    }
    
    open func openPhotoAlbum()
    {
        CODPermissions.authorizePhotoWith { [weak self] (granted) in
            
            let picker = UIImagePickerController()
            
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            picker.delegate = self;
            
            picker.allowsEditing = true
            
            self?.present(picker, animated: true, completion: nil)
        }
    }
    
    //MARK: -----相册选择图片识别二维码 （条形码没有找到系统方法）
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var image:UIImage? = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if (image == nil )
        {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        if(image != nil)
        {
            let arrayResult = CODScanWrapper.recognizeQRImage(image: image!)
            if arrayResult.count > 0
            {
                handleCodeResult(arrayResult: arrayResult)
                return
            }
        }
        
        showMsg(title: nil, message: NSLocalizedString("未找到二维码", comment: ""))
    }
   
    
    func showMsg(title:String?,message:String?)
    {
        let qrStr:String = self.isFromAddfriend(scanString: message ?? "")
        if qrStr.count > 0 {
            
            self.requestNewFriendMessage(qrStr: qrStr)
        }else {
            let alertController = UIAlertController(title: nil, message:message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: NSLocalizedString("好的", comment: ""), style: UIAlertAction.Style.default) {[weak self] (alertAction) in
                self?.drawScanView()
                self?.perform(#selector(ScanViewController.startScan), with: nil, afterDelay: 0.3)
                
            }
            
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
    
    }
    
    func isFromAddfriend(scanString: String) -> String {
        
        if scanString.hasPrefix(QR_ParsingURL) {
            var stringArray:Array<String> = scanString.components(separatedBy: "?")
            if stringArray.count >= 2 {
                stringArray.remove(at: 0)
                var qrString = ""
                for subString in stringArray {
                    qrString = qrString + subString
                }
                return qrString
            }
        }
        return ""
        
    }
    
    func requestNewFriendMessage(qrStr: String) {
        
        CODProgressHUD.showWithStatus(nil)
        HttpManager.share.postWithUserInfo(url: HttpConfig.COD_QRcode_ValidQRcodeUrl, param: ["qrCode":qrStr], successBlock: {[weak self] (success, json) in
            CODProgressHUD.dismiss()
            if let successDic = success as? Dictionary<String, Any>,let action = successDic["action"] as? String{
                
                if action == COD_QRcode_SearchUser {//添加好友
                    
                    if let username = successDic["jid"] as? String,username.count > 0 {
                        self?.pushToPersonDetailVC(successDic: successDic)
                    }
                }else if action == COD_QRcode_JoinRoom {//加入房间
//                    if let data = successDic["jid"] as? Dictionary<String, String>, let roomID = successDic["roomID"] as? Int {
//                        if let node = data["node"], let domain = data["domain"] {
//                            let jid = node + "@" + domain
//                            self?.requestJoinGroup(roomID: roomID, password: "", inviter: jid)
//                        }
//                    }

                    if let roomID = successDic["roomID"] as? Int {
                        self?.requestJoinGroup(roomID: roomID, password: "", qrcode: qrStr)
                    }
                }else if action == COD_QRcode_Pending {//待绑定
                    
                    self?.drawScanView()
                    self?.perform(#selector(ScanViewController.startScan), with: nil, afterDelay: 0.3)
                }else if action == COD_QRcode_Wconf {////待确认登录(移动端扫描后)
                    
                    self?.loginComputer(successDic: successDic, qrCode: qrStr)
                }else if action == COD_QRcode_Login {//登录

                      self?.havedLoginComputer(successDic: successDic, qrCode: qrStr)
                }

            }else{
                self?.drawScanView()
                self?.perform(#selector(ScanViewController.startScan), with: nil, afterDelay: 0.3)
            }
            
        }) { [weak self](error) in
            CODProgressHUD.dismiss()

            var errorString = ""
            if error.code == 10026 {
                //关闭扫码进群
//                errorString = "O"
                errorString = "群管理员已关闭扫码入群"
            }else if error.code == 10027 {
                //关闭二维码加好友
                errorString = "对方已在隐私设置修改添加方式，你无法通过二维码扫描添加对方"
            }else if error.code == 10028 {
                //黑名单
                errorString = "对方已将你加入黑名单，无法添加好友"
            }else if error.code == 10013 {
                //二维码失效
//                errorString = "二维码已失效，请刷新二维码重新扫描"
                errorString = "无效的二维码"
            }
            if errorString.removeAllSapce.count > 0 {
                
                let alertController = UIAlertController(title: nil, message:errorString, preferredStyle: UIAlertController.Style.alert)
//                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) {[weak self] (alertAction) in
//                    self?.drawScanView()
//                    self?.perform(#selector(ScanViewController.startScan), with: nil, afterDelay: 0.3)
//
//                }
                let alertAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) {[weak self] (alertAction) in
                    self?.drawScanView()
                    self?.perform(#selector(ScanViewController.startScan), with: nil, afterDelay: 0.3)
                    
                }
//                alertController.addAction(cancelAction)
                alertController.addAction(alertAction)
                self?.present(alertController, animated: true, completion: nil)
            }else{
                
//                CODProgressHUD.showErrorWithStatus("\(error.message)")
                self?.drawScanView()
                self?.perform(#selector(ScanViewController.startScan), with: nil, afterDelay: 0.3)
                
            }
         
        }
        
    }
    
    func loginComputer(successDic: Dictionary<String, Any>,qrCode: String) {
        
        self.navigationController?.popViewController(animated: false)
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController as? CODCustomTabbarViewController {
            let pcVC = PCLoginViewController()
            pcVC.qrCode = qrCode
//            pcVC.transitioningDelegate = rootVC
            pcVC.modalPresentationStyle = .custom
            rootVC.present(pcVC, animated: true) {
            }
        }
    }
    
    func havedLoginComputer(successDic: Dictionary<String, Any>,qrCode: String) {
        self.navigationController?.popViewController(animated: false)
        
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController as? CODCustomTabbarViewController {
            let pcVC = PCLoginoutViewController()
//            pcVC.qrCode = qrCode
//            pcVC.transitioningDelegate = rootVC
            pcVC.modalPresentationStyle = .custom
            rootVC.present(pcVC, animated: true) {
            }
        }
//        let pcVC = PCLoginoutViewController()
//        pcVC.transitioningDelegate = self
//        pcVC.modalPresentationStyle = .custom
//        self.present(pcVC, animated: true) {
//        }
//        self.navigationController?.popViewController(animated: false)

    }
    
    func requestJoinGroup(roomID: Int, password: String, qrcode: String) {
        if let model = CODGroupChatRealmTool.getGroupChat(id: roomID) {
            try! Realm.init().write {
                model.isValid = true
            }
        }else{
            let groupChatModel = CODGroupChatModel()
            groupChatModel.roomID = roomID
            groupChatModel.isValid = true
            CODChatListModel.insertOrUpdateGroupChatListModel(by: groupChatModel, message: nil)
        }
        let  dict:NSDictionary = ["name": COD_MemberJoin,
                                  "requester": UserManager.sharedInstance.jid,
                                  "roomID": roomID,
                                  "password": password,
                                  "qrcode": qrcode]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns:COD_com_xinhoo_groupChat , actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
    }
    
    func pushToPersonDetailVC(successDic: Dictionary<String, Any>)  {
        
        if let jidString = successDic["jid"] as? String {
            
            if jidString == UserManager.sharedInstance.jid  || jidString == UserManager.sharedInstance.loginName{
                let msgCtl = MessageViewController()
                msgCtl.chatType = .privateChat
                msgCtl.toJID = kCloudJid + XMPPSuffix
                msgCtl.chatId = CloudDiskRosterID
                msgCtl.title = NSLocalizedString("我的云盘", comment: "")
                self.jumpToMessageVC(msgCtl: msgCtl)
                return
            }
            
            if let contactModel = CODContactRealmTool.getContactByJID(by: jidString), contactModel.isValid == true {
                let personVC = CODPersonDetailVC()
                personVC.rosterId = contactModel.rosterID
                self.navigationController?.setViewControllers([(self.navigationController?.viewControllers.first)!,personVC], animated: true)
                
            }else{
                let personVC = CODStrangerDetailVC()
                if let name = successDic["name"] as? String{
                    personVC.name = name
                }
                if let username = successDic["username"] as? String{
                    personVC.userName = username
                }
                if let userpic = successDic["userpic"] as? String{
                    personVC.userPic = userpic
                }
                if let gender = successDic["gender"] as? String{
                    personVC.gender = gender
                }
                if let userDesc = successDic["userdesc"] as? String{
                    personVC.userDesc = userDesc
                }
                
                personVC.jid = jidString
                personVC.type = .qrcodeType
                self.navigationController?.setViewControllers([(self.navigationController?.viewControllers.first)!,personVC], animated: true)
                
            }
        }
       
        
    }
    
    @objc func pushToMyQRVC() {
        
        self.navigationController?.pushViewController(CODMyQRcodeController())
    }
    deinit
    {
    }
    
    override func navRightTextClick() {
        
        let tzImgPicker = CustomUtil.getImagePickController(maxImagesCount: 1, delegate: self)
        tzImgPicker?.isSelectOriginalPhoto = true
        tzImgPicker?.allowTakeVideo  = false
        tzImgPicker?.allowTakePicture  = false
        tzImgPicker?.allowPickingVideo = false
        tzImgPicker?.allowPickingGif = false
        tzImgPicker?.allowPickingOriginalPhoto = false
        self.present(tzImgPicker ?? UIViewController.init(), animated: true, completion: nil)
    }
    
}
extension ScanViewController: TZImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {
        if photos.count > 0 {
            for image in photos {

                let arrayResult = CODScanWrapper.recognizeQRImage(image: image)
                  if arrayResult.count > 0
                  {
                      handleCodeResult(arrayResult: arrayResult)
                      return
                  }

            }
            showMsg(title: nil, message: NSLocalizedString("未找到二维码", comment: ""))
        }
    }
    
}

extension ScanViewController: BonsaiControllerDelegate {
    
    // return the frame of your Bonsai View Controller
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: containerViewFrame.width, height: containerViewFrame.height))
    }
    
    // return a Bonsai Controller with SlideIn or Bubble transition animator
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        // Slide animation from .left, .right, .top, .bottom
        return BonsaiController(fromDirection: .bottom, blurEffectStyle: .extraLight, presentedViewController: presented, delegate: self)

        // or Bubble animation initiated from a view
        //return BonsaiController(fromView: yourOriginView, blurEffectStyle: .dark,  presentedViewController: presented, delegate: self)
    }
}

extension ScanViewController: XMPPStreamDelegate {
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        CustomUtil.analyticxXML(iq: iq) {[weak self] (actionDic, infoDic) in
            guard let self = self else {
                return
            }
            
            guard let infoDic = infoDic else {
                return
            }
            
            guard let name = actionDic["name"] as? String, name == COD_MemberJoin else {
                return
            }
            
            if let success = infoDic["success"] as? Bool {
                if !success {
                    
                    if let code = infoDic["code"] as? Int {
                        switch code {
                        case 30046:
                            CODProgressHUD.showErrorWithStatus("群管理员已关闭扫码入群")
                            break
                        case 30047:
                            CODProgressHUD.showErrorWithStatus("无效的二维码")
                            break
                        default:
                            if let msg = infoDic["msg"] as? String {
                                CODProgressHUD.showErrorWithStatus(msg)
                            } else {
                                CODProgressHUD.showErrorWithStatus("未知错误")
                            }
                            break
                        }
                    }
                    
                    
                    self.navigationController?.popViewController(animated: true, nil)
                    return
                }
            }
            
            if let iqNameStr = actionDic["name"] as? String {
                if iqNameStr.compareNoCaseForString(COD_MemberJoin) {
                    let groupChatModel = CODGroupChatModel()
                    if let dataDic = infoDic["data"] as? Dictionary<String, Any> {
                        groupChatModel.jsonModel = CODGroupChatHJsonModel.deserialize(from: dataDic)
                        groupChatModel.isValid = true
                        if let memberArr = dataDic["member"] as! [Dictionary<String,Any>]? {
                            for member in memberArr {
                                let memberTemp = CODGroupMemberModel()
                                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                                memberTemp.memberId = String(format: "%d%@", groupChatModel.roomID, memberTemp.username)
                                groupChatModel.member.append(memberTemp)
                            }
                        }
                        if let noticeContent = dataDic["noticecontent"] as? Dictionary<String, Any> {
                            if let notice = noticeContent["notice"] as? String {
                                groupChatModel.notice = notice
                            }
                        }
                        groupChatModel.customName = CODGroupChatModel.getCustomGroupName(memberList: groupChatModel.member)
                    }else{
                        // data为空则已在群里
                        if let roomID = actionDic["roomID"] as? Int {
                            self.joinExistGroup(roomID: roomID)
                        }
                        return
                    }
                    groupChatModel.createDate = String(format: "%.0f", Date.milliseconds)
                    CODChatListModel.insertOrUpdateGroupChatListModel(by: groupChatModel, message: nil)
                    
                    //创建成功加入聊天室
                    XMPPManager.shareXMPPManager.joinGroupChatWith(groupJid: groupChatModel.jid)
                    
                    let msgCtl = MessageViewController()
                    msgCtl.chatType = .groupChat
                    msgCtl.roomId = "\(groupChatModel.roomID)"
                    if groupChatModel.descriptions.count <= 0 {
                        msgCtl.title = NSLocalizedString("群组", comment: "")
                    }else{
                        msgCtl.title = groupChatModel.descriptions
                    }
                    
                    msgCtl.toJID = String(groupChatModel.jid)
                    msgCtl.chatId = groupChatModel.roomID
                    msgCtl.isMute = groupChatModel.mute
                    self.jumpToMessageVC(msgCtl: msgCtl)
                    
//                    CustomUtil.getHistoryMessage(lastMessageTime: "", roomID: "\(groupChatModel.roomID)")
                }
            }
        }
        return true
    }
    
    func joinExistGroup(roomID: Int) {
        guard let listModel = CODChatListRealmTool.getChatList(id: roomID) else {
            print("扫二维码返回已在群里，但是查找不到指定群组")
            
            guard let groupChatModel = CODGroupChatRealmTool.getGroupChat(id: roomID) else {
                return
            }
            let msgCtl = MessageViewController()
            msgCtl.chatType = .groupChat
            msgCtl.roomId = "\(groupChatModel.roomID)"
            let groupName = groupChatModel.descriptions
            if groupName.count > 0 {
                msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
            }else{
                msgCtl.title = NSLocalizedString("群组", comment: "")
            }
            msgCtl.toJID = String(groupChatModel.jid)
            msgCtl.chatId = groupChatModel.roomID
            msgCtl.isMute = groupChatModel.mute
            self.jumpToMessageVC(msgCtl: msgCtl)

            return
        }
        let msgCtl = MessageViewController()
        
        msgCtl.chatType = .groupChat
        msgCtl.roomId = String(format: "%d", (listModel.groupChat?.roomID) ?? 0)
        
        if (listModel.groupChat?.descriptions) != nil {
            let groupName = listModel.groupChat?.descriptions
            if let groupName = groupName, groupName.count > 0 {
                msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
            }else{
                msgCtl.title = NSLocalizedString("群组", comment: "")
            }
        }else{
            msgCtl.title = NSLocalizedString("群组", comment: "")
        }
        
        if let groupChatTemp = listModel.groupChat {
            msgCtl.toJID = String(groupChatTemp.jid)
            msgCtl.isMute = groupChatTemp.mute
        }
        msgCtl.chatId = listModel.id
        self.jumpToMessageVC(msgCtl: msgCtl)

    }
    
    func jumpToMessageVC(msgCtl: MessageViewController) {
        if let first = UIViewController.current()?.navigationController?.viewControllers.first {
            UIViewController.current()?.navigationController?.setViewControllers([first, msgCtl], animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
            self.navigationController?.pushViewController(msgCtl, animated: true)
        }
    }
}
extension ScanViewController{
//    //运行页面随设备转动
//    override var shouldAutorotate : Bool {
//        return false
//    }
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
//        //        return UIInterfaceOrientationIsPortrait
//        return .portrait
//    }
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return [.landscape, .portrait]
//    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//    //下面方法是处理navgation相关的逻辑，如果控制器没有nav，省略
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animate(alongsideTransition: { [weak self] (context) in
//            let orient = UIApplication.shared.statusBarOrientation
//            switch orient {
//            case .landscapeLeft, .landscapeRight:
//                //横屏时禁止左拽滑出
//                self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//                self?.navigationController?.setNavigationBarHidden(true, animated: false)
//            default:
//                //竖屏时允许左拽滑出
//                self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//                self?.navigationController?.setNavigationBarHidden(false, animated: false)
//            }
//        })
//        super.viewWillTransition(to: size, with: coordinator)
//    }
 
}


