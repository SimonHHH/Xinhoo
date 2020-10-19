//
//  BalloonActionViewController.swift
//  Balloon
//
//  Created by Gaétan Zanella on 11/02/2019.
//  Copyright © 2019 Gaétan Zanella. All rights reserved.
//

import UIKit

protocol BalloonActionViewControllerDelegate: class {
    func viewControllerDidRequestToDismiss(_ viewController: BalloonActionViewController)
    func viewController(_ viewController: BalloonActionViewController,
                        willDisplayBalloon balloon: UICoordinateSpace,
                        coordinator: UIViewControllerTransitionCoordinator?)
    func menuCopy()
    func menuDelete()
    func retransionMessage()
    func editNewMessage()
    func replyMessage()
    func topMessage()
    func more()
    func collectionMessage()
    func menuSave()
    func cancalSend(message: CODMessageModel)
    
    func other(reportType: BalloonActionViewController.ReportType)
}

class BalloonActionModel:NSObject {
    
    enum Style {
        case none
        case highlighted
    }
    
    var title: String = ""
    var image: String = ""
    var action: Selector? = nil
    var style: Style = .none
    
    init(title:String,image:String,action:Selector?,style:Style) {
        self.title = title
        self.image = image
        self.action = action
        self.style = style
        super.init()
    }
    
}

class BalloonActionViewController: UIViewController {
    
    weak var delegate: BalloonActionViewControllerDelegate?
    
    let fromBalloonCoordinateSpace: UICoordinateSpace
    let image : UIImage?
    let model : ChatCellVM
    let aView : UIView
    
    let scrollView = UIScrollView(frame: .zero)
    
    private lazy var actionButton = RoundedButton()
    private lazy var balloonView = UIImageView()
    private var tableViewHeight:CGFloat = 0.0
    private let BalloonCell = "BalloonCell"
    
    var dataArr:Array<[BalloonActionModel]> = []
    
    enum ReportType: Int {
        case spamMessage = 1        // 垃圾消息
        case fraud = 4              // 诈骗
        case violence = 2           // 暴力
        case porn = 3               // 色情
//        case childAbuse         // 儿童虐待
//        case copyright          // 侵犯版权
        case other = 5              // 其他
    }
    
    
    lazy var tableView:UITableView = {
        
        let view = UITableView.init(frame: .zero, style: UITableView.Style.plain)
        view.delegate = self
        view.dataSource = self
        view.isScrollEnabled = false
        view.bounces = false
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.register(UITableViewCell.self, forCellReuseIdentifier: BalloonCell)
        return view
    }()
    
    // MARK: - Life Cycle
    
    init(model:ChatCellVM,image:UIImage, fromBalloonCoordinateSpace: UICoordinateSpace,view:UIView) {
        self.fromBalloonCoordinateSpace = fromBalloonCoordinateSpace
        self.image = image
        self.model = model
        self.aView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
        
        actionButton.isHidden = true
        initDataArr()
        
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.0)
        
        let blur = UIBlurEffect.init(style: .light)
        let effectView = UIVisualEffectView.init(effect: blur)
        effectView.frame = view.bounds
        self.view.addSubview(effectView)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickDismiss))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        let fromBalloonFrame = fromBalloonCoordinateSpace.convert(fromBalloonCoordinateSpace.bounds, to: view)
        
        balloonView.image = self.image
        balloonView.frame = fromBalloonFrame
        
        scrollView.addSubview(balloonView)
        scrollView.addSubview(self.tableView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        //        actionButton.topAnchor.constraint(greaterThanOrEqualTo: balloonView.bottomAnchor, constant: 20).isActive = true
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.view.layoutIfNeeded()
            self.delegate?.viewController(self, willDisplayBalloon: self.balloonView, coordinator: self.transitionCoordinator)
        }, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        self.setNeedsStatusBarAppearanceUpdate()
        let fromBalloonFrame = fromBalloonCoordinateSpace.convert(fromBalloonCoordinateSpace.bounds, to: view)
        setUpController(fromBalloonFrame: fromBalloonFrame)
    }
    
    func initDataArr() {
        
        let collectItem = BalloonActionModel(title: "收藏", image: "message_favorite_icon", action: #selector(collectionMessage), style: .none)
        let replyItem = BalloonActionModel(title: "回复", image: "message_reply_icon", action: #selector(replyMessage), style: .none)
        let copyItem = BalloonActionModel(title: "拷贝", image: "message_copy_icon", action: #selector(menuCopy), style: .none)
        let saveItem =  BalloonActionModel(title: "保存到相机胶卷", image: "message_save_icon", action: #selector(menuSave), style: .none)
        let editItem = BalloonActionModel(title: "编辑", image: "message_edit_icon", action: #selector(editNewMessage), style: .none)
        var topTitle = "置顶"
        var topImage = "message_pin_icon"
        let isICanCheckUserInfo = CODChatListRealmTool.getChatList(id: model.messageModel.roomId)?.groupChat?.isICanCheckUserInfo() ?? true
        
        switch self.model.messageModel.chatTypeEnum {
        case .groupChat:
            if let groupChatModel = CODGroupChatRealmTool.getGroupChatByJID(by: model.messageModel.toJID),groupChatModel.topmsg == self.model.messageModel.msgID{
                topTitle = "取消置顶"
                topImage = "message_unpin_icon"
            }
            break
        case .channel:
            
            if let channel = CODChannelModel.getChannel(by: model.messageModel.roomId),channel.topmsg == self.model.messageModel.msgID{
                topTitle = "取消置顶"
                topImage = "message_unpin_icon"
            }
            break
        default:
            break
        }
        let transItem = BalloonActionModel(title: "转发", image: "message_forward_icon", action: #selector(retransionMessage), style: .none)
        let deleteItem = BalloonActionModel(title: "删除", image: "message_delete_icon", action: #selector(menuDelete), style: .highlighted)
        let canSendItem = BalloonActionModel(title: "取消发送", image: "message_cancel_icon", action: #selector(cancalSend), style: .highlighted)
        let topItem = BalloonActionModel(title: topTitle, image: topImage, action: #selector(topMessage), style: .none)
        
        let reportItem = BalloonActionModel(title: "举报", image: "message_report_icon", action: #selector(reportMessage), style: .none)
        
        let moreItem = BalloonActionModel(title: "更多", image: "message_more_icon", action: #selector(more), style: .none)
        
        var isManager = false
        let chatType = CODMessageChatType(rawValue: self.model.messageModel.chatType) ?? .privateChat
        
        if chatType == .channel  {
            let channleResult = CustomUtil.judgeInChannelRoom(roomId: model.messageModel.roomId)
            isManager = channleResult.isManager
        }
        
        var arr:Array<BalloonActionModel> = []
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: (self.model.messageModel.msgType)) ?? .text
        
        
        
        if  modelType != .voiceCall && self.model.messageModel.status == CODMessageStatus.Succeed.rawValue {
            if chatType == .privateChat{
                arr.append(replyItem)
            }
            if chatType == .groupChat && CustomUtil.judgeInGroupRoomCanSpeak(roomId: self.model.messageModel.roomId) {
                arr.append(replyItem)
            }
        }
        
        if modelType == .text || self.model.messageModel.audioModel?.descriptionAudio.removeAllSapce.count ?? 0 > 0 || self.model.messageModel.videoModel?.descriptionVideo.removeAllSapce.count ?? 0 > 0 || self.model.messageModel.photoModel?.descriptionImage.removeAllSapce.count ?? 0 > 0 || self.model.messageModel.fileModel?.descriptionFile.removeAllSapce.count ?? 0 > 0 {

            if isICanCheckUserInfo {
                
                arr.append(copyItem)
            }
        }
        
        if modelType == .multipleImage && self.model.messageModel.text.isEmpty == false {
            
            if isICanCheckUserInfo {
                
                arr.append(copyItem)
            }
        }
        
        if modelType == .image || modelType == .multipleImage {
            arr.append(saveItem)
        }
        
        if (modelType == .text || modelType == .image || modelType == .video || modelType == .file || modelType == .audio || modelType == .multipleImage) && self.model.messageModel.status == CODMessageStatus.Succeed.rawValue{
            
            //允许编辑条件：该消息发送时间不超过10分钟，并且该条消息不是转发消息，并且消息是自己发的
            
            if (self.isCanEditTimeout() && (model.messageModel.fromWho.contains(UserManager.sharedInstance.loginName!)) && !CustomUtil.getIsCloudMessage(messageModel: self.model.messageModel)) {
                
                if chatType == .privateChat || chatType == .groupChat{
                    arr.append(editItem)
                }else if chatType == .channel && isManager{
                    arr.append(editItem)
                }
            }
        }
        
        if CustomUtil.getIsManager(roomId: self.model.messageModel.roomId, userName: UserManager.sharedInstance.jid) && self.model.messageModel.status == CODMessageStatus.Succeed.rawValue && !self.model.messageModel.toJID.contains(kCloudJid){
            if chatType == .privateChat || chatType == .groupChat{
                arr.append(topItem)
            }else if chatType == .channel && isManager{
                arr.append(topItem)
            }
        }
        
        if isICanCheckUserInfo {
            if self.model.messageModel.status == CODMessageStatus.Succeed.rawValue && (!self.model.messageModel.fromJID.contains(kCloudJid) && !self.model.messageModel.toJID.contains(kCloudJid)) && modelType != .voiceCall {
                arr.append(collectItem)
            }
        }
        
        if isICanCheckUserInfo {
            
            if modelType == .text && self.model.messageModel.status == CODMessageStatus.Succeed.rawValue{
                arr.append(transItem)
            }else{
                if modelType == .file || modelType == .image ||  modelType == .video || modelType == .location || modelType == .businessCard || modelType == .audio || modelType == .gifMessage || modelType == .multipleImage{
                    if self.model.messageModel.status == CODMessageStatus.Succeed.rawValue {
                        arr.append(transItem)
                    }
                }
            }
        }
        
        var moreArr:Array<BalloonActionModel> = []
        if model.messageModel.type == .unknown {
            
            if chatType == .privateChat || chatType == .groupChat{
                
                arr = [deleteItem]
                moreArr.append(moreItem)
                dataArr.append(contentsOf: [arr, moreArr])
            }else if chatType == .channel && isManager{ 
                
                arr = [deleteItem]
                dataArr.append(contentsOf: [arr])
            }else{
                
            }
        } else {
            
            if model.messageModel.statusType == .Succeed && (!model.messageModel.isMeSend) {
                if arr.count > 0 {
                    arr.append(reportItem)
                }
            }
            
            if chatType == .privateChat || chatType == .groupChat{
                
                arr.append(deleteItem)
                dataArr.append(arr)
                moreArr.append(moreItem)
                dataArr.append(moreArr)
            }else if chatType == .channel && isManager{
                
                arr.append(deleteItem)
                dataArr.append(arr)
                moreArr.append(moreItem)
                dataArr.append(moreArr)
            }else{
                
                dataArr.append(arr)
                moreArr.append(moreItem)
                dataArr.append(moreArr)
            }
        }
        
        if model.messageModel.type == .image || model.messageModel.type == .video {
            
            if model.messageModel.statusType != .Succeed {
                dataArr.removeAll(arr)
                arr.removeAll()
                arr.append(canSendItem)
                dataArr.append(arr)
            }
            
            
        }
        
//        if model.messageModel.type == .multipleImage {
//
//            dataArr.removeAll()
//
//            arr = [replyItem, copyItem, editItem, topItem, collectItem, transItem, deleteItem]
//
//            if self.isCanEditTimeout() == false {
//                arr.removeAll(editItem)
//            }
//
//            if model.messageModel.isMeSend == false {
//                arr.removeAll(editItem)
//            }
//
//            if model.messageModel.chatTypeEnum == .groupChat || model.messageModel.chatTypeEnum == .channel {
//
//                if CustomUtil.getIsManager(roomId: self.model.messageModel.roomId, userName: UserManager.sharedInstance.jid) == false {
//                    arr.removeAll(topItem)
//                }
//
//            }
//
//            dataArr.append(arr)
//
//            dataArr.append(moreArr)
//
//        }
        
        
        tableViewHeight = CGFloat(Double(arr.count) * 44.0) + CGFloat(Double(moreArr.count) * 44.0) + 8.0
    }
    
    func initReportDataArr() {
        
        dataArr.removeAll()
        
        let spamMessageItem = BalloonActionModel(title: "垃圾信息", image: "", action: #selector(spamMessage), style: .none)
        let fraudItem = BalloonActionModel(title: "诈骗", image: "", action: #selector(fraud), style: .none)
        let violenceItem = BalloonActionModel(title: "暴力", image: "", action: #selector(violence), style: .none)
        let pornItem = BalloonActionModel(title: "色情", image: "", action: #selector(porn), style: .none)
//        let childAbuseItem =  BalloonActionModel(title: "儿童虐待", image: "", action: #selector(childAbuse), style: .none)
//        let copyrightItem = BalloonActionModel(title: "侵犯版权", image: "", action: #selector(copyright), style: .none)
        let otherItem = BalloonActionModel(title: "其他", image: "", action: #selector(other), style: .none)
        
        var arr = Array<BalloonActionModel>()
        arr.append(contentsOf: [spamMessageItem,fraudItem,violenceItem,pornItem,otherItem])
        dataArr.append(arr)
        
        tableViewHeight = CGFloat(Double(arr.count) * 44.0) - 2
        
        let fromBalloonFrame = fromBalloonCoordinateSpace.convert(fromBalloonCoordinateSpace.bounds, to: view)
        setUpController(fromBalloonFrame: fromBalloonFrame)
    }
    
    func isCanEditTimeout() -> Bool {
        
        let todayTemp = Int(Date.milliseconds)
        
        //允许编辑条件：该消息发送时间不超过10分钟，并且该条消息不是转发消息，并且消息是自己发的
        
        var time = 0
        
        #if MANGO
        time = 172800 * 1000
        #elseif PRO
        time = 86400 * 1000
        #else
        time = 600 * 1000
        #endif
        
        return ((todayTemp - Int(self.model.messageModel.datetimeInt )) < time)
        
    }
    
    //    @objc func dismissMenu(){
    //        GMenuController.shared().setMenuVisible(false, animated: true)
    //    }
    
    @objc func cancalSend() {
        self.delegate?.cancalSend(message: self.model.messageModel)
        self.clickDismiss()
    }
    
    @objc func menuCopy() {
        self.delegate?.menuCopy()
        self.clickDismiss()
    }
    
    @objc func menuSave() {
        self.delegate?.menuSave()
        self.clickDismiss()
    }
    
    @objc func menuDelete() {
        self.delegate?.menuDelete()
        self.clickDismiss()
    }
    
    @objc func retransionMessage() {
        self.delegate?.retransionMessage()
        self.clickDismiss()
    }
    
    @objc func editNewMessage() {
        self.delegate?.editNewMessage()
        self.clickDismiss()
    }
    @objc func replyMessage() {
        self.delegate?.replyMessage()
        self.clickDismiss()
    }
    @objc func topMessage() {
        self.delegate?.topMessage()
        self.clickDismiss()
    }
    @objc func more() {
        self.delegate?.more()
        self.clickDismiss()
    }
    @objc func collectionMessage() {
        self.delegate?.collectionMessage()
        self.clickDismiss()
    }
    
    
    //MARK: 举报
    @objc func reportMessage() {
        self.initReportDataArr()
    }
    
    //MARK: 垃圾消息
    @objc func spamMessage() {
        
        self.clickDismiss()
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5 , execute: {
            
            self.delegate?.other(reportType: .spamMessage)
        })
    }
    
    
    //MARK: 诈骗
    @objc func fraud() {
        
        self.clickDismiss()
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5 , execute: {
            
            self.delegate?.other(reportType: .fraud)
        })
    }
    
    //MARK: 暴力
    @objc func violence() {
        
        self.clickDismiss()
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5 , execute: {
            
            self.delegate?.other(reportType: .violence)
        })
    }
    
    //MARK: 色情
    @objc func porn() {
        
        self.clickDismiss()
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5 , execute: {
            
            self.delegate?.other(reportType: .porn)
        })
    }
    
//    //MARK: 儿童虐待
//    @objc func childAbuse() {
//
//        self.clickDismiss()
//
//        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5 , execute: {
//
//            self.delegate?.other(reportType: .childAbuse)
//        })
//    }
//
//    //MARK: 侵犯版权
//    @objc func copyright() {
//
//        self.clickDismiss()
//
//        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5 , execute: {
//
//            self.delegate?.other(reportType: .copyright)
//        })
//    }
    
    //MARK: 其他
    @objc func other() {
        
        self.clickDismiss()
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5 , execute: {
            
            self.delegate?.other(reportType: .other)
        })
    }
    
    
    private func setUpController(fromBalloonFrame: CGRect) {
        
        var rect : CGRect
        
        if fromBalloonFrame.height + tableViewHeight + 30 + 25 > KScreenHeight {
            
            rect = CGRect(x: 0, y: 30, width: fromBalloonFrame.width, height: fromBalloonFrame.height)
            scrollView.contentSize = CGSize(width: KScreenWidth, height: fromBalloonFrame.height + tableViewHeight + 30 + 30)
            scrollView.setOffsetY(offsetY: fromBalloonFrame.height + tableViewHeight + 30 + 25 - KScreenHeight, animation: false)
        }else{
            
            if fromBalloonFrame.minY < 30 {
                rect = CGRect(x: 0, y: 30, width: fromBalloonFrame.width, height: fromBalloonFrame.height)
            }else{
                if fromBalloonFrame.maxY + tableViewHeight + 25 > KScreenHeight {
                    rect = CGRect(x: 0, y: KScreenHeight - (tableViewHeight + 25) - fromBalloonFrame.height, width: fromBalloonFrame.width, height: fromBalloonFrame.height)
                }else{
                    rect = CGRect(x: 0, y: fromBalloonFrame.minY, width: fromBalloonFrame.width, height: fromBalloonFrame.height)
                }
            }
            scrollView.contentSize = CGSize(width: KScreenWidth, height: KScreenHeight)
        }
        
        
        let animation = POPBasicAnimation.init(propertyNamed: kPOPViewFrame)
        animation?.toValue = rect
        animation?.duration = 0.25
        animation?.completionBlock = { [weak self] (_,_) in
            guard let self = self else {
                return
            }
            self.tableView.snp.makeConstraints { (make) in
                make.top.equalTo(self.balloonView.snp_bottomMargin).offset(10)
                make.width.equalTo(250)
                make.height.equalTo(self.tableViewHeight)
                if self.model.messageModel.fromWho.contains(UserManager.sharedInstance.loginName ?? "") && self.model.messageModel.chatTypeEnum != .channel{
                    make.right.equalTo(self.balloonView.snp_rightMargin).offset(-5)
                }else{
                    
                    if self.model.messageModel.chatTypeEnum == .groupChat {
                        make.left.equalTo(self.balloonView.snp_leftMargin).offset(43)
                    }else{
                        make.left.equalTo(self.balloonView.snp_leftMargin).offset(5)
                    }
                }
            }
            
            self.tableView.reloadData()
        }
        balloonView.pop_add(animation, forKey: "")
        
    }
    
    @objc func clickDismiss() {
        
        let animation = POPBasicAnimation.init(propertyNamed: kPOPViewFrame)
        animation?.toValue = fromBalloonCoordinateSpace.convert(fromBalloonCoordinateSpace.bounds, to: view)
        animation?.duration = 0.25
        animation?.completionBlock = { (_,_) in
            self.delegate?.viewControllerDidRequestToDismiss(self)
        }
        balloonView.pop_add(animation, forKey: "")
        
        //        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        delegate?.viewControllerDidRequestToDismiss(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
}

extension BalloonActionViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = self.dataArr[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BalloonCell)
        cell?.textLabel?.text = model.title
        let imageView = UIImageView.init(image: UIImage(named: model.image))
        cell?.accessoryView = imageView
        cell?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 17)
        if model.style == .highlighted {
            cell?.textLabel?.textColor = UIColor.init(hexString: "FF3B30")
        }else{
            cell?.textLabel?.textColor = .black
        }
        
        cell?.backgroundColor = .clear
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = self.dataArr[indexPath.section][indexPath.row]
        self.perform(model.action)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 10
        }else{
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 10
//        }else{
            return 0.01
//        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 10))
            view.backgroundColor = UIColor.init(hexString: "D5D6D9")
            view.alpha = 0.7
            return view
        }else{
            return nil
        }
    }
    
}

extension BalloonActionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if self.tableView.frame.contains(touch.location(in: self.tableView.superview)) {
            return false
        }else{
            return true
        }
    }
}
