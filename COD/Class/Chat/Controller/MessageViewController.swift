//
//  MessageViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import XMPPFramework
import SwiftyJSON
//import JitsiMeet 
import RealmSwift
import QuickLook
import SVProgressHUD
import RxSwift
import RxCocoa

private let kChatLoadMoreOffset: CGFloat = 30
let MAXSHOWCOUNT: Int = 1

class MessageViewController: BaseViewController {
    ///个人会话的JID
    public var toJID: String = ""
    var isGroupChat: Bool {
        get {
            switch chatType {
            case .groupChat, .channel:
                return true
            case .privateChat:
                return false
            }
        }
    }
    public var chatType: CODMessageChatType = .privateChat
    public var newMessageCount = 0
    //    public var newScrollMessageCount = 0
    public var isBurn: Int = 0
    public var isMute: Bool = false
    public var showName: Bool = true
    public var isNeedScroll: Bool = true
    //是不是云盘
    public var isCloudDisk: Bool = false
    
    //是否为免打扰
    public var isDisturb: Bool = true
    public var isShowToolView: Bool = false
    public var isSearch:Bool = false
    var searchDatas: Array<CODMessageModel> = []
    public var photoBrowser:YBImageBrowser?
    //编辑
    public var editMessage: CODMessageModel = CODMessageModel()
    public var editVideoUrl: URL?
    
    //编辑文件类型的消息
    public var editFileMessage: CODMessageModel?
    //编辑文件类型的消息
    public var editingMessages: Array<CODMessageModel> = []
    //回复
    public var replyMessage: CODMessageModel = CODMessageModel()
    //转发
    public var transMessage: CODMessageModel = CODMessageModel()
    //收藏
    public var collectionMessage: CODMessageModel = CODMessageModel()
    public var isCollection: Bool = false
    
    //转发
    public var transMessages: Array<CODMessageModel> = []
    //置顶消息
    public var topMessage: CODMessageModel = CODMessageModel()
    
    public var transJid: String = ""
    
    var time: TimeInterval = 0.0
    //    var statubarWindow: UIWindow?
    //    var titleWindow: UIWindow?
    
    public var roomId: String? = nil
    //图片的数组
    var sourceImageView: UIImageView = UIImageView.init()
    var photoArrayDic: Array<String> = []
    var photoArray: NSMutableArray = []
    //文件的数组
    var sourceFileView: UIImageView = UIImageView.init()
    var fileImgArrayDic: Array<String> = []
    var fileImgArray: NSMutableArray = []
    //语音的数组
    var audioArrayDic: Array<String> = []
    var audioArray: Dictionary<String,CODMessageModel> = [:]
    var audioCellArray: Dictionary<String,UITableViewCell> = [:]
    
    var notificationToken: NotificationToken? = nil
    var inCallNotificationToken: NotificationToken? = nil
    var subNotificationToken: NotificationToken? = nil
    var memberNotificationToken: NotificationToken? = nil
    
    /// 单聊是用户ID，群组是群ID
    public var chatId: Int = 0
    
    
    public var chatListModel: CODChatListModel?
    public var chatHistoryModel = CODChatHistoryModel()
    public var channelModel: CODChannelModel?
    public var noticeModel: CODNoticeContentModel?
    
    private let CellIdentifier = "CellIdentifier"
    public var lastDateStr: String? = nil
    ///UI
    public var lastStatus: CODChatBarStatus?
    public var curStatus: CODChatBarStatus?
    public var isRecording = false
    
    public var isCompress = false
    
    
    //    var pipViewCoordinator: PiPViewCoordinator?
    //    var jitsiMeetView: JitsiMeetView?
    
    var isReloading: Bool = false               //UITableView 是否正在加载数据, 如果是，把当前发送的消息缓存起来后再进行发送
    var currentVoiceCell: CODAudioChatCell?     //现在正在播放的声音的 cell
    var currentVoiceModel: CODMessageModel?     //现在正在播放的声音的 model
    var lastVoiceModel: CODMessageModel?     //上次播放的声音的 model
    
    var isEndRefreshing: Bool = true
    
    var draftStr: String = ""
    
    var sendChatStateTimer: Timer!
    
    var isNeedSendComposing = true
    
    var currentSearchModel: CODGroupMemberModel?
    var currentSearchString: String = ""
    
    // 是否结束了下拉加载更多
    // 倒计时
    var isCounting = false {
        didSet{
            timeIsCounting(isBegin: isCounting)
        }
    }
    var countdownTimer: Timer?
    var remainingSeconds: Int = -1 {
        didSet{
            timerRemainingSeconds(seconds: remainingSeconds)
        }
    }
    var lastMessage: CODMessageModel?
    
    var searchResultMessage: CODMessageModel?
    var jumpMessage: CODMessageModel?
    
    var captionView: CODPictureCaptionView?
    
    lazy var navBarTitleView: NavBarTitleView = {
        let view = NavBarTitleView(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth-152, height: 44))
        if (self.chatListModel?.jid.contains("cod_60000000")) ?? false {
            view.titleLabel.attributedText = view.getAttributesTitle(CustomUtil.formatterStringWithAppName(str: "%@小助手"), isMute: self.isMute)
        }else{
            view.titleLabel.attributedText = view.getAttributesTitle(self.title, isMute: self.isMute)
        }
        
        return view
    }()
    
    lazy var searchBar: CODSearchBar = {
        let searchBar = CODSearchBar(frame: CGRect.zero)
        searchBar.backgroundColor = UIColor(hexString: kVCBgColorS)
        searchBar.placeholder = "搜索此会话"
        searchBar.isHidden = true
        searchBar.barTintColor = UIColor.init(hexString: kVCBgColorS)
        searchBar.tintColor = UIColor.init(hexString: kBlueTitleColorS)
        searchBar.customTextField?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
        searchBar.customTextField?.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControl.Event.editingChanged)
        let searchBarTF = searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 17)
        return searchBar
    }()
    
    lazy var countLab: UILabel = {
        var countLab = UILabel.init(frame: .zero)
        countLab.font = UIFont.init(name: "PingFangSC-Regular", size: 13)
        countLab.textColor = .white
        countLab.textAlignment = .center
        countLab.cornerRadius = 9
        countLab.backgroundColor = .red
        return countLab
    }()
    
    lazy var toolView: CODChatAidToolView = {
        
        let toolV = CODChatAidToolView.init(frame: CGRect.zero, isGroupChat: (chatType == .channel), isDisturb: self.isDisturb )
        toolV.backgroundColor =  UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        return toolV
    }()
    
    lazy var memberToolView: CODMemberDisplayView = {
        let memberV = CODMemberDisplayView.init(frame: CGRect.zero)
        memberV.backgroundColor = UIColor.clear
        memberV.isHidden = true
        return memberV
    }()
    
    lazy var searchToolView: CODMessageSearchResultView = {
        let toolV = CODMessageSearchResultView.init(frame: CGRect.zero)
        toolV.totalPage = 0
        toolV.backgroundColor = UIColor.colorGrayForChatBar
        toolV.isHidden = true
        toolV.memberBtn.isHidden = (self.isCloudDisk || !self.isGroupChat)
        return toolV
    }()
    
    lazy var recordLabel:UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.text = "松开发送，滑动取消"
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor.white
        titleLabel.isHidden = true
        return titleLabel
    }()
    
    
    
    lazy var leftSearchView: CODChatSearchLeftView = {
        let lb = CODChatSearchLeftView.init(frame: CGRect(x: 0, y: 0, width: 55, height: 20))
        return lb
    }()
    
    lazy var titleView: UIView = {
        let view = UIView.init(frame: CGRect(x: 70, y: 0, width: KScreenWidth-140, height: 44))
        return view
    }()
    
    
    ///录音
    lazy var recorderIndicatorView: CODChatVoiceIndicatorView = {
        let recorderIndicatorView = CODChatVoiceIndicatorView(frame: CGRect.zero)
        return recorderIndicatorView
    }()
    
    //消息
    lazy var messageView: CODChatMessageDisplayView = {
        
        let tableView = CODChatMessageDisplayView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor.clear
        return tableView
    }()
    //编辑
    lazy var editView: CODMessageEditView = {
        let editV = CODMessageEditView(frame: CGRect.zero)
        editV.isHidden = true
        return editV
    }()
    ///下面功能栏
    lazy var chatBar:CODChatBar = {
        let chatBar = CODChatBar(frame: CGRect.zero)
        //        chatBar.textView.attributedText = String.messageTextTranscode(text: self.chatListModel?.subTitle ?? "" ,fontSize: chatBar.textView.font ?? IMChatTextFont)
        if chatBar.textView.text.count > 0 {
            chatBar.setMoreButtonImage(normalImage: "send_icon", highImage: "send_icon")
        }
        
        return chatBar
    }()
    
    //频道下面普通成员的 关闭通知和开启通知
    lazy var channelBottomView: UIButton = {
        var bottomBtn = UIButton.init(type: UIButton.ButtonType.custom)
        bottomBtn.addTarget(self, action: #selector(bottomNoticeAction(button:)), for: UIControl.Event.touchUpInside)
        bottomBtn.contentMode = .scaleToFill
        bottomBtn.backgroundColor = UIColor.init(hexString: kVCBgColorS)
        bottomBtn.setTitle("关闭通知", for: .normal)
        //        bottomBtn.setTitle("开启通知", for: .selected)
        bottomBtn.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: .normal)
        bottomBtn.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: .selected)
        bottomBtn.isHidden = true
        return bottomBtn
    }()
    
    lazy var bottomView:UIView = {
        let bottomV = UIView(frame: CGRect.zero)
        bottomV.backgroundColor = UIColor.colorGrayForChatBar
        return bottomV
    }()
    
    /// 表情管理者
    lazy var emojiKBHelper:CODExpressionHelper = {
        let emojiKBHelper = CODExpressionHelper.sharedHelper()
        return emojiKBHelper
    }()
    /// 更多键盘管理者
    lazy var moreKBHelper:CODMoreKBHelper = {
        let moreKBHelper = CODMoreKBHelper()
        return moreKBHelper
    }()
    ///表情键盘
    lazy var emojiKeyboard: CODEmojiKeyboard = {
        let emojiKeyboard = CODEmojiKeyboard(frame: CGRect.zero)
        return emojiKeyboard
    }()
    ///更多键盘
    lazy var moreKeyboard:CODMoreKeyboard = {
        let moreKeyboard = CODMoreKeyboard(frame: CGRect.zero)
        //        moreKeyboard.tzImagePickerVc = self.imagePickerManager
        return moreKeyboard
    }()
    lazy var iCloudTool:CODICloudDriveTool = {
        let icloud = CODICloudDriveTool()
        return icloud
    }()
    //录音键盘
    lazy var recordKeyboared:CODRecordKeyboard = {
        let recordKeyboared = CODRecordKeyboard(frame: CGRect.zero)
        return recordKeyboared
    }()
    lazy var tipView: UILabel = {
        let tipLb = UILabel(frame: CGRect.zero)
        tipLb.backgroundColor = UIColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 1)
        tipLb.textColor = UIColor.black
        tipLb.font = UIFont.systemFont(ofSize: 15)
        tipLb.text = ""
        tipLb.isHidden = true
        tipLb.textAlignment = .center
        return tipLb
    }()
    
    lazy var topMessageView: CODChatTopView = {
        let topView = CODChatTopView.init()
        topView.isHidden = true
        return topView
    }()
    
    lazy var inCallView: CODGroupInCallView = {
        let inCallView = CODGroupInCallView.init()
        inCallView.isHidden = true
        return inCallView
    }()
    
    lazy var inviteCallView: CODGroupInviteInCallView = {
        let inviteCallView = CODGroupInviteInCallView.init()
        inviteCallView.isHidden = true
        return inviteCallView
    }()
    
    lazy var multipleSelectionView: CODMultipleSelectionView = {
        let selectionView = CODMultipleSelectionView.init()
        selectionView.isHidden = true
        return selectionView
    }()
    
    lazy var multipleTopView: CODMultipleSelectionView = {
        let selectionView = CODMultipleSelectionView.init()
        selectionView.backgroundColor = UIColor.init(red: 247, green: 247, blue: 247)
        return selectionView
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.isSearch && self.navigationController?.topViewController == self {
            self.navigationController?.navigationBar.isHidden = true
            var view_frame = self.view.frame
            view_frame.origin.y = CGFloat(KNAV_STATUSHEIGHT)
            view_frame.size.height = KScreenHeight - CGFloat(KNAV_STATUSHEIGHT)
            self.view.frame = view_frame
            //            self.view.setNeedsLayout()
            //            self.view.setNeedsUpdateConstraints()
        }
        
        
    }
    
    public func scrollToSearchMessage(message:CODMessageModel) {
        
        if let indexPath = self.messageView.messageDisplayViewVM.findIndexPath(messageId: message.msgID) {
            
            self.messageView.flashingCell(indexPath: indexPath)
            
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSLog("%@ 开始执行",#function)
        
        if self.toJID.contains(kCloudJid) { //是云盘
            self.isCloudDisk  = true
            editView.isCloudDisk = true
        }
        self.setBackButton()
        self.backButton.setTitle(NSLocalizedString("聊天", comment: ""), for: UIControl.State.normal)
        self.backButton.addSubview(self.countLab)
        self.sessionRedPoint()
        
        
        self.setRightButton_ZZS()
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: .messageQueue)
        self.addXMPPSendMsgSuccessBlock()
        self.addXMPPEditMsgBlock()
        if let chatListModel = try? Realm.init().object(ofType: CODChatListModel.self, forPrimaryKey: self.chatId) {
            
            self.chatListModel = chatListModel
            
            try! Realm.init().write { [weak self] in
                guard let self = self else {
                    return
                }
                
                guard let message =  self.chatListModel?.chatHistory?.messages.last else{
                    return
                }
                if self.chatListModel!.lastReadTimeOfMe < message.datetimeInt {
                    self.chatListModel!.lastReadTimeOfMe = message.datetimeInt
                }
            }
            
        }
        
        self.updateLastBurnTime()
        if let chatModel = self.chatListModel, let lestMessage = chatModel.chatHistory?.messages.filter("status != 15").sorted(byKeyPath: "datetimeInt", ascending: true).last {
            self.judgeIsSendHaveReadMsg(lastMessage: lestMessage, chatLastReadTime: chatModel.lastReadTime)
        }
        
        self.updatePendingMessage()
        CODUploadTool.default.toBeUploadArray.removeAll()
        
        switch chatType {
        case .privateChat:
            self.isDisturb = self.chatListModel?.contact?.mute  ?? false
        case .groupChat:
            self.isDisturb = self.chatListModel?.groupChat?.mute ?? false
        default:
            self.isDisturb = self.chatListModel?.channelChat?.mute ?? false
        }
        
        self.setUpAddViews()
        self.setUpKeyBord()
        self.setUpUIKeyboardNotifation()
        self.setUpOtherNotifation()
        
        self.h_snpKit()
        
        self.updateShowName(isUpdate: false)
        self.initData()
        self.view.backgroundColor = UIColor.colorGrayForChatBar
        self.receiveChatState()
        self.updateBurn()
        
        self.draftStr =  self.chatListModel?.subTitle ?? ""
        
        if self.transMessage.msgID != "0" || self.transMessages.count > 0{
            self.replyMessage = CODMessageModel()
            self.editMessage = CODMessageModel()
            if self.transMessage.msgID != "0"  {
                self.editView.setCellContent(self.transMessage,isTrans: true)
            }else{
                self.editView.setCellTransMessageContent(self.transMessages)
            }
            self.editView.isHidden = false
            self.chatBar.textView.becomeFirstResponder()
            self.chatBar.isEdit = true
            self.updateMessageView()
        }else if let editMessage = self.chatListModel?.editMessage {
            self.editMessage = editMessage
            self.editView.setCellContent(editMessage,isEdit: true)
            self.editView.isHidden = false
            if self.draftStr.count > 0 {
                self.chatBar.textView.text = self.draftStr
            }else{
                self.chatBar.textView.text = editMessage.text
            }
            
            self.chatBar.textView.becomeFirstResponder()
            self.chatBar.isEdit = true
            self.updateMessageView()
        }
        if self.transMessage.msgID == "0" && self.transMessages.count == 0{
            
            if let transMsgs = CODChatListRealmTool.getSaveTransMsgs(chatId: self.chatId) {
                if transMsgs.count == 1 {
                    self.transMessage = transMsgs.first!
                }else{
                    self.transMessages = transMsgs
                }
                if self.transMessage.msgID != "0" || self.transMessages.count > 0{
                    self.replyMessage = CODMessageModel()
                    self.editMessage = CODMessageModel()
                    if self.transMessage.msgID != "0"  {
                        self.editView.setCellContent(self.transMessage,isTrans: true)
                    }else{
                        self.editView.setCellTransMessageContent(self.transMessages)
                    }
                    self.editView.isHidden = false
                    self.chatBar.textView.becomeFirstResponder()
                    self.chatBar.isEdit = true
                    self.updateMessageView()

                }
            }
        }
        
        self.getGroupInfo()
        XMPPManager.shareXMPPManager.getTopMsg(roomId: self.chatId) { _ in
            self.updateTopMessage()
        }
        
        self.messageView.bindData()
        
        if let jumpMessage = self.jumpMessage {
            
            
            self.messageView.messageDisplayViewVM.getLocalHistoryList(beginTime: "\(jumpMessage.datetimeInt)", endTime: "0") { [weak self] (VMs) in
                
                
                guard let `self` = self else { return }
                
                self.messageView.messageDisplayViewVM.setChatCellVMs(cellVms: VMs)
                
                if self.messageView.tableView.mj_footer != nil {
                    self.messageView.tableView.mj_footer.beginRefreshing()
                }
                
                if let indexPath = self.messageView.messageDisplayViewVM.findIndexPath(messageId: jumpMessage.msgID) {
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        self.messageView.flashingCell(indexPath: indexPath)
                    }
                    
                }
                
                
                
                self.messageView.messageDisplayViewVM.loadMessageFormShowedMessage()
                
            }
            
        } else if let searchResultMessage = self.searchResultMessage {
            
            CODProgressHUD.showWithStatus(nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                
                self.messageView.messageDisplayViewVM.getHistoryList(beginTime: "\(searchResultMessage.datetimeInt - self.messageView.offsetBeginTime)", endTime: "0") { [weak self] (VMs) in
                    
                    CODProgressHUD.dismiss()
                    guard let `self` = self else { return }
                    self.messageView.messageDisplayViewVM.setChatCellVMs(cellVms: VMs)
                    
                    
                    if let indexPath = self.messageView.messageDisplayViewVM.findIndexPath(messageId: searchResultMessage.msgID) {
                        
                        self.messageView.flashingCell(indexPath: indexPath)
                    }
                }
                
            }
            
        } else {
            
            
            self.messageView.gotoNewView.isHidden = true
            self.messageView.messageDisplayViewVM.getLocalHistoryList(count: 20, insertShowNewMessageCell: false) { [weak self] cellVMs in
                guard let `self` = self else { return }
                
                UIView.setAnimationsEnabled(false)
                self.messageView.messageDisplayViewVM.setChatCellVMs(cellVms: cellVMs, showNewMessage: false)
                UIView.setAnimationsEnabled(true)
                
                let checkBurn = (XMPPManager.shareXMPPManager.xmppStream.myPresence != nil)
                
                DDLogInfo("进入会话页面 getHistoryList (\(self.chatListModel?.jid ?? "")) -  checkBurn = \(checkBurn)")
                
                self.messageView.messageDisplayViewVM.getHistoryList(count: 20, checkBurn: checkBurn, insertShowNewMessageCell: true) { [weak self] cellVMs in
                    
                    guard let `self` = self else { return }
                    
                    DispatchQueue.main.async {
                        
                        self.messageView.gotoNewView.isHidden = false
                        UIView.setAnimationsEnabled(false)
                        self.messageView.messageDisplayViewVM.setChatCellVMs(cellVms: cellVMs)
                        UIView.setAnimationsEnabled(true)
                        
                        if self.messageView.tableView.visibleCells.count >= self.newMessageCount {
                            self.messageView.gotoNewView.isHidden = true
                        }
                        
                        if let chatModel = self.chatListModel, let lestMessage = chatModel.chatHistory?.messages.filter("status != 15").sorted(byKeyPath: "datetimeInt", ascending: true).last {
                            self.judgeIsSendHaveReadMsg(lastMessage: lestMessage, chatLastReadTime: chatModel.lastReadTime)
                        }
                        
                    }
                    
                }
                
            }
    
        }
        
        if self.chatListModel?.id == RobotRosterID {
            try! Realm().safeWrite {
                self.chatListModel?.count = 0
            }
        }
        
        if self.chatListModel?.isInValid == true {
            try! Realm().safeWrite {
                self.chatListModel?.count = 0
            }
        }
        
        if self.chatListModel?.groupChat?.isValid == false {
            try! Realm().safeWrite {
                self.chatListModel?.count = 0
            }
        }
        
        
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
        
        self.updateGroupIsVaild()
        
        NSLog("%@ 结束执行",#function)
        
        self.bindData()
        
        self.updateInCallView()

        
        //        self.messageView.messageDisplayViewVM.removeAllMessage
    }
    
    func bindData() {
        
        self.messageView.messageDisplayViewVM
            .removeAllMessage
            .bind(to: self.rx.removeAllMessageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageView.messageDisplayViewVM.removeMeesage.mapTo(Void())
            .bind(to: self.rx.removeAllMessageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageView.messageDisplayViewVM
            .editMessage
            .bind(to: self.rx.editMessageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageView.messageDisplayViewVM
            .updateTopMsgBR.bind(to: self.rx.updateTopMsgBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageView.messageDisplayViewVM.removeMeesage.mapTo(Void())
            .bind(to: rx.removeMeesageBinder)
            .disposed(by: rx.disposeBag)
        
        self.messageView.messageDisplayViewVM.onClickImagePR
            .bind(to: self.rx.onClickImageBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageView.messageDisplayViewVM.cellSendMsgReationBR
            .bind(to: self.rx.cellSendMsgReationBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.messageView.messageDisplayViewVM.cellTapAtBR
            .bind(to: self.rx.cellTapAtBinder)
            .disposed(by: self.rx.disposeBag)
        
        switch self.chatListModel?.chatTypeEnum {
        case .groupChat:
            self.chatListModel?.groupChat?.rx.observe(\.isValid).filterNil().distinct()
                .bind(onNext: { [weak self] (_) in
                    guard let `self` = self else { return }
                    self.updateGroupIsVaild()
                })
                .disposed(by: rx.disposeBag)
            
            if let members = self.chatListModel?.groupChat?.member  {
                
                let roomID = self.chatListModel?.id ?? 0
                
                Observable.arrayWithChangeset(from: members)
                    .observeOn(SerialDispatchQueueScheduler(queue: .groupMembersOnlineTimeQueue, internalSerialQueueName: "GroupMembersOnlineTime"))
                    .bind { [weak self] (value) in
                        
                        guard let `self` = self else { return }
                        
                        guard let member = CODGroupChatRealmTool.getGroupChat(id: roomID)?.member else { return }
                        
                        let memberCount = member.count
                        let onlineCount = member.getOnlineMembers().count
                        dispatch_async_safely_to_main_queue {
                            self.navBarTitleView.setSubTitle(userDetail: CODGroupChatRealmTool.getGroupChat(id: roomID)?.isICanCheckUserInfo(), memberCount: memberCount, onlineCount: onlineCount)
                        }                        
                        
                }
                .disposed(by: rx.disposeBag)
                
            }
            

        default:
            break
        }
        
    }
    
    @objc func sessionRedPoint() {
        
        DispatchQueue.main.async {
            var count = 0
            let results = try! Realm.init().objects(CODChatListModel.self).filter("((contact.mute = false || groupChat.mute = false || channelChat.mute = false) && isInValid = false) || id = -999")
            
            for chatModel in results {
                count = count + chatModel.count
            }
            
            self.countLab.isHidden = false
            
            if count > 999 {
                let k = count / 1000
                self.countLab.text = "\(k)K"
                self.countLab.frame = CGRect.init(x: 6, y: 0, width: 30, height: 18)
            }else{
                
                self.countLab.text = "\(count)"
                
                if count >= 100 && count < 999 {
                    self.countLab.frame = CGRect.init(x: 6, y: 0, width: 30, height: 18)
                }
                
                if count >= 10 && count < 100 {
                    self.countLab.frame = CGRect.init(x: 6, y: 0, width: 22, height: 18)
                }
                
                if count < 10 {
                    self.countLab.frame = CGRect.init(x: 6, y: 0, width: 18, height: 18)
                }
                
                if count == 0{
                    self.countLab.isHidden = true
                }
            }
        }
    }
    
    func updateHeaderImage() {
        if let contectModel = CODContactRealmTool.getContactByJID(by: self.toJID) {
            let temp = contectModel.timestamp
            let todayTemp = Int64(Date.milliseconds)
            if todayTemp - temp > 60 * 60 * 24 * 1000 && HttpManager.share.isHaveNet() {
                CODContactRealmTool.updateContactModelTimeStamp(by: self.toJID, timeStamp: todayTemp)
                //                CustomUtil.removeHeaderImageCahch(picID: contectModel.userpic)
                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: contectModel.userpic) { (image) in
                    self.messageView.tableView.reloadData()
                }
            }
        }
    }
    
    func showNotices() {
        dispatch_async_safely_to_main_queue {
            
            switch self.chatType {
            case .groupChat:
                if let groupNotice = self.noticeModel, groupNotice.notice.count > 0 {
                    let memberId = CODGroupMemberModel.getMemberId(roomId: self.chatId, userName: UserManager.sharedInstance.loginName!)
                    let member = CODGroupMemberRealmTool.getMemberById(memberId)
                    self.dismisskeyboard()
                    self.initNotices(chatId: self.chatId, noticeModel: groupNotice, myPower: member?.userpower ?? 30)
                }
                break
            case .channel:
                break
            default:
                break
            }
            
        }
    }
    
    func initNotices(chatId: Int, noticeModel: CODNoticeContentModel, myPower:Int) {
        let groupNoticesView = CODGroupNoticesView()
        groupNoticesView.titleStr = "群公告"
        groupNoticesView.contentStr = noticeModel.notice
        groupNoticesView.cancelStr = "知道了"
        groupNoticesView.disappearCloser = {
            groupNoticesView.removeAllFromSuperView()
        }
        groupNoticesView.selectRowCloser = { [weak self] (row : NSInteger) in
            guard let self = self else {
                return
            }
            switch row {
            case 0:
                let vc = CODGroupAnnouncementVC()
                vc.groupChatId = chatId
                vc.noticeContent = noticeModel
                vc.myPower = myPower
                self.navigationController?.pushViewController(vc)
            default:
                break
            }
        }
        groupNoticesView.show(with: UIApplication.shared.keyWindow)
        
    }
    
    
    
    
    func deleteAllHistoryMessage() {
        
        self.messageView.messageDisplayViewVM.removeAllMessage.accept(Void())
        
    }
    
    
    fileprivate func updateAvatar() {
        if !self.isGroupChat {
            switch self.chatId {
            case -1:
                self.rightButton.setImage(UIImage(named: "search_history_record"), for: .normal)
            case 0:
                self.rightButton.setImage(UIImage.helpIcon(), for: .normal)
            default:
                if let contact = CODContactRealmTool.getContactById(by: self.chatId) {
                    //                    self.rightButton.setImage(UIImage(named: "default_header_80"), for: .normal)
                    CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: contact.userpic) { (image) in
                        DispatchQueue.main.async {
                            self.rightButton.setImage(image, for: .normal)
                        }
                    }
                }
            }
            
        } else {
            self.setGroupAvatar()
            switch chatType {
            case .groupChat:
                if let str = CustomUtil.judgeInGroupRoom(roomId: self.chatId), str.count > 0 {
                    self.titleView.isUserInteractionEnabled = false
                }else{
                    self.titleView.isUserInteractionEnabled = true
                }
                self.updateGroupIsVaild()
                
                break
            case .channel:
                self.updateGroupIsVaild()
                
            default:
                break
            }
            
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {   
        super.viewWillAppear(animated)
        
        CODFileManager.shareInstanceManger().getEMConversationFilePath(sessionID: String(format: "%@", self.toJID))
        self.navigationController?.navigationBar.isHidden = self.isSearch
        
        self.addXMPPRemoveMsgBlock()
        IQKeyboardManager.shared.enable = false
        
        updateAvatar()
        
        self.navigationController?.navigationBar.addSubview(self.titleView)
        let titleTap = UITapGestureRecognizer.init(target: self, action: #selector(titleBackGroupViewTap))
        self.titleView.addGestureRecognizer(titleTap)
        self.dismisskeyboard()
        NSLog("%@ 结束执行",#function)
        
        self.setNavBarTitle()
        self.addRealmNotificationToken()
        if !isGroupChat {
            self.requestContactLoginStatus()
        }else{
            self.updateMemberCount()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("%@ 开始执行",#function)
        
        
        AudioRecordInstance.delegate = self
        self.navigationController?.navigationBar.isHidden = self.isSearch
        
        if self.isSearch {
            //            self.navigationController?.navigationBar.isHidden = true
            var view_frame = self.view.frame
            view_frame.origin.y = CGFloat(KNAV_STATUSHEIGHT)
            view_frame.size.height = KScreenHeight - CGFloat(KNAV_STATUSHEIGHT)
            self.view.frame = view_frame
            self.view.setNeedsLayout()
            self.view.setNeedsUpdateConstraints()
            self.messageView.snp.updateConstraints { (make) in
                make.top.equalTo(self.view).offset(CGFloat(KNAV_STATUSHEIGHT))
            }
        }else{
            
        }
        
        XMPPManager.shareXMPPManager.currentChatFriend = toJID
        //        if kSystemVersion.hasPrefix("11") == true {
        //        }
        self.isNeedScroll = false
        self.searchResultMessage = nil
        NSLog("%@ 结束执行",#function)
        self.messageView.showTimeView.hide()
        
        if let drafts = self.chatListModel?.subTitle, drafts.count > 0 {
            self.chatBar.textView.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSendVoiceStopPlay), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.saveDraft()
        self.saveEditMessage()
        self.updateLastChatTime()
        if !self.multipleSelectionView.isHidden {
            self.cancel()
        }
        CODRecentPhotoView.recentPhoto.dismissRecentPhoto()
        IQKeyboardManager.shared.enable = true
        CustomUtil.stopAudioPlay()
        ///先暂停之前的播放
        CODAudioPlayerManager.sharedInstance.stop()
        
        if XMPPManager.shareXMPPManager.currentChatFriend == toJID {
            XMPPManager.shareXMPPManager.currentChatFriend = ""
        }
        //        guard let statubarWindow = self.statubarWindow else {
        //            return
        //        }
        //        statubarWindow.resignKey()
        //        statubarWindow.removeFromSuperview()
        //        statubarWindow.isHidden = true
        //        statubarWindow.rootViewController = nil
        //        self.statubarWindow = nil
        //        guard let titleWindow = self.titleWindow else {
        //            return
        //        }
        //        titleWindow.resignKey()
        //        titleWindow.removeFromSuperview()
        //        titleWindow.isHidden = true
        //        titleWindow.rootViewController = nil
        //        self.titleWindow = nil
        self.dismisskeyboard()
        
        //        _ = CODMessageRealmTool.burnMessage(messages: self.chatListModel?.chatHistory?.messages.toArray() ?? [])
        
        CODMessageRealmTool.burnMessage(chatID: self.chatId)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func navBackClick() {
        
        if self.chatBar.sendVoiceView.isRecording {
            
            self.showAlert(title: nil, message: NSLocalizedString("您确定要停止录音并丢弃您的语音消息吗？", comment: ""), buttonTitles: [NSLocalizedString("取消", comment: ""),NSLocalizedString("丢弃", comment: "")], highlightedButtonIndex: 1) { [weak self] (index) in
                
                guard let `self` = self else {
                    return
                }
                
                if index == 1 {
                    
                    self.navigationController?.popViewController()
                }
            }
            
        }
        
        if self.isRecording {
            return
        }
        if self.recorderIndicatorView.superview != nil {
            return
        }else{
            self.navigationController?.popViewController()
            //            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    func pustToMessageDetail() {
        if let model = CODGroupChatRealmTool.getGroupChat(id: self.chatId) {
            if model.isValid {
                let ctl = CODMessageDetailVC()
                ctl.detailType = .groupChat
                ctl.chatId = self.chatId
                //                ctl.updateGroupMemberBlock = { [weak self] in
                //                    self?.updateMemberCount()
                //                }
                ctl.updateGroupAvatarBlock = { [weak self] in
                    self?.setGroupAvatar()
                }
                ctl.deleteAllHistoryBlock = { [weak self] in
                    self?.deleteAllHistoryMessage()
                }
                self.navigationController?.pushViewController(ctl, animated: true)
            }
        }
    }
    
    override func navRightClick() {
        
        if self.isRecording {
            return
        }
        
        switch self.chatType {
        case .groupChat:
            
            pustToMessageDetail()
            
        case .channel:
            
            if let model = CODChannelModel.getChannel(by: self.chatId) {
                
                let ctl = CODChannelDetailViewController()
                ctl.channeModel = model
                self.navigationController?.pushViewController(ctl)
                
            }else{
                let ctl = CODChannelDetailViewController()
                ctl.channeModel = self.channelModel!
                self.navigationController?.pushViewController(ctl)
            }
            
            
        default:
            
            if chatId == 0 {
                self.navigationController?.pushViewController(CODLittleAssistantDetailVC(), animated: true)
                
            } else if chatId == CloudDiskRosterID{
                //搜索
                self.searchClick()
            } else {
                if let model = CODContactRealmTool.getContactById(by: chatId) {
                    if model.isValid {
                        
                        CustomUtil.pushToPersonVC(contactModel: model, deleteAllHistoryBlock: { [weak self] in
                            self?.deleteAllHistoryMessage()
                        })
                        
                    }else{
                        
                        CustomUtil.pushToStrangerVC(type: .cardType, contactModel: model, deleteAllHistoryBlock: { [weak self] in
                            self?.deleteAllHistoryMessage()
                        })
                    }
                    
                }
            }
            
        }
        
    }
    
    func updateGroupAvatar() {
        
        switch chatType {
        case .groupChat:
            if let group = CODGroupChatRealmTool.getGroupChat(id: self.chatId) {
                
                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: group.grouppic) { (image) in
                    DispatchQueue.main.async {
                        self.rightButton.setImage(image, for: .normal)
                    }
                }
            }
            break
        case .channel:
            if let channel = CODChannelModel.getChannel(by: self.chatId) {
                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: channel.grouppic) { (image) in
                    DispatchQueue.main.async {
                        self.rightButton.setImage(image, for: .normal)
                    }
                }
            }else{
                CODDownLoadManager.sharedInstance.updateAvatar(userPicID: self.channelModel!.grouppic) { (image) in
                    DispatchQueue.main.async {
                        self.rightButton.setImage(image, for: .normal)
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    func setGroupAvatar() {
        
        switch chatType {
        case .groupChat:
            if let group = CODGroupChatRealmTool.getGroupChat(id: self.chatId) {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: group.grouppic) { (image) in
                    DispatchQueue.main.async {
                        self.rightButton.setImage(image, for: .normal)
                    }
                }
            }
            break
        case .channel:
            if let channel = CODChannelModel.getChannel(by: self.chatId) {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: channel.grouppic) { (image) in
                    DispatchQueue.main.async {
                        self.rightButton.setImage(image, for: .normal)
                    }
                }
            }else{
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: self.channelModel!.grouppic) { (image) in
                    DispatchQueue.main.async {
                        self.rightButton.setImage(image, for: .normal)
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    //    func updateGroupAvatar() {
    //        if let group = CODGroupChatRealmTool.getGroupChat(id: self.chatId) {
    //            CODDownLoadManager.sharedInstance.updateAvatar(userPicID: group.grouppic) { (image) in
    //                DispatchQueue.main.async {
    //                    self.rightButton.setImage(image, for: .normal)
    //                }
    //            }
    //        }
    //    }
    
    override func navSubRightClick() {
        // 视频通话，区分单聊，群组
        //self.vioceCall(callType: COD_call_type_voice)
    }
    
    deinit {
        
        self.chatBar.sendVoiceView.stop()
        //        self.deleteBurnMessage()
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        //        CODFileManager.shareInstanceManger().getEMConversationFilePath(sessionID: String(format: "%@", self.toJID))
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self, delegateQueue: .messageQueue)
        //        if self.chatId != 0 && self.chatId != CloudDiskRosterID{
        titleView.removeFromSuperview()
        //        }
        //        self.clearXMPPCurrentChatFriend()
        //        XMPPManager.shareXMPPManager.currentChatFriend = ""
        
        NotificationCenter.default.removeObserver(self)
        notificationToken?.invalidate()
        subNotificationToken?.invalidate()
        memberNotificationToken?.invalidate()
        inCallNotificationToken?.invalidate()
        CODAudioPlayerManager.sharedInstance.stop()
        //        CODDownLoadManager.sharedInstance.request?.cancel()
        self.messageView.delegate = nil
        
        if self.sendChatStateTimer != nil {
            self.sendChatStateTimer.invalidate()
            self.sendChatStateTimer = nil
            XMPPManager.shareXMPPManager.sendChatStateTo(userName: self.toJID, chatState: XMPPMessage.ChatState.paused)
        }
        
        print("会话结束。。。。。。。。。")
    }
    
    //    func clearXMPPCurrentChatFriend() {
    //        let ctl = UIViewController.current() as? CODCustomTabbarViewController
    //        let baseNavCtl = ctl?.getViewControllerWith(index: 0) as? BaseNavigationController
    //        let currentCtl = baseNavCtl?.children.last
    //        let isMessageCtl = currentCtl?.description.contains("MessageViewController") ?? false
    //        if !isMessageCtl {
    //            XMPPManager.shareXMPPManager.currentChatFriend = ""
    //        }
    //    }
    
    //保存草稿
    func saveDraft() {
        guard let chatListModel = CODChatListRealmTool.getChatList(id: self.chatId) else {
            return
        }
        try! Realm.init().write {
            let textStr = self.chatBar.textView.attributedText.string.removeHeadAndTailSpacePro
            if textStr.count > 0 {
                chatListModel.subTitle = String.textString(attributedText: self.chatBar.textView.attributedText)
                
                CustomUtil.setChatDrafts(jid: self.toJID, value: self.chatBar.textView.attributedText.getAttributesWithArray(isSend: false))
            }else{
                chatListModel.subTitle = ""
                CustomUtil.setChatDrafts(jid: self.toJID, value: nil)
            }
        }
        
        if self.transMessage.msgID != "0" {
            CODChatListRealmTool.saveTransMsgs(chatId: self.chatId, msgs: [self.transMessage])
        }
        if self.transMessages.count > 0 {
            CODChatListRealmTool.saveTransMsgs(chatId: self.chatId, msgs: self.transMessages)
        }
    }
    
    func saveEditMessage() {
        if self.chatBar.isEdit {
            if  self.editMessage.msgID != "0" {
                if let chatListModel = CODChatListRealmTool.getChatList(id: self.chatId) {
                    try! Realm.init().write { [weak self] in
                        chatListModel.editMessage = self?.editMessage
                    }
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

private extension MessageViewController {
    
    /// 添加消息显示视图
    func setUpAddViews(){
                
        if let bgImageString = UserDefaults.standard.object(forKey: kChat_BGImg) as? String{
            
            let bgImgaeView:UIImageView?
            if CODDownLoadManager.sharedInstance.isCustomBgImg() {
                bgImgaeView = UIImageView.init(image: CODDownLoadManager.sharedInstance.getCustomBgImg())
            }else{
                bgImgaeView = UIImageView.init(image: UIImage.init(named: bgImageString))
            }
            
            bgImgaeView!.contentMode = .scaleAspectFill
            bgImgaeView!.clipsToBounds = true
            //            bgImgaeView!.frame = CGRect(x: 0, y: 0, width: KScreenWidth, heightO: kScreenHeight - CGFloat(TABBAR_HEIGHT) - CGFloat(kSafeArea_Bottom))
            self.view.addSubview(bgImgaeView!)
            bgImgaeView?.snp.makeConstraints({ (make) in
                make.right.left.top.equalToSuperview()
                make.bottom.equalTo(self.view).offset(-(CGFloat(TABBAR_HEIGHT) + CGFloat(kSafeArea_Bottom)))
            })
        }
        
        self.messageView.hiddenShareBtnBlock = { [weak self] (isHidden: Bool) in
            guard let self = self else {
                return
            }
            self.multipleSelectionView.shareBtn.isHidden = isHidden
        }
        self.messageView.delegate = self
        self.messageView.chatId = self.chatId
        self.messageView.chatType = self.chatType
        self.messageView.toJID = self.toJID
        self.editView.delegate = self
        self.toolView.delegate = self
        self.searchToolView.delegate = self
        self.searchBar.delegate = self
        self.messageView.delegate = self
        self.emojiKeyboard.delegate = self
        self.emojiKeyboard.delagate = self
        self.moreKeyboard.delagate = self
        self.moreKeyboard.delegate = self
        self.recordKeyboared.delegate = self
        self.recordKeyboared.delagate = self
        self.messageView.isCloudDisk = self.isCloudDisk
        self.view.addSubview(self.messageView)
        self.view.addSubview(self.recordLabel)
        self.view.addSubview(self.editView)
        self.multipleSelectionView.deleteBtn.addTarget(self, action: #selector(multipleSelectionDelete), for: .touchUpInside)
        self.multipleSelectionView.shareBtn.addTarget(self, action: #selector(multipleSelectionShare), for: .touchUpInside)
        if self.chatType == .channel {
            let channleResult = CustomUtil.judgeInChannelRoom(roomId: self.chatId)
            self.multipleSelectionView.deleteBtn.isHidden = !channleResult.isManager        
        }
        self.view.addSubview(self.multipleSelectionView)
        self.view.addSubview(self.chatBar)
        self.view.addSubview(self.channelBottomView)
        //        self.chatBar.textView.attributedText =  self.chatBar.textView.getEmojiText(self.chatListModel?.subTitle ?? "")
        
        
        self.setChatBar()
        

        self.view.addSubview(self.tipView)
        self.view.addSubview(self.topMessageView)
        self.topMessageView.delegate = self
        self.view.addSubview(self.searchBar)
        self.inCallView.delegate = self
        self.view.addSubview(self.inCallView)
        self.inviteCallView.delegate = self
        self.view.addSubview(self.inviteCallView)

        self.inCallView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        self.inviteCallView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(151)
        }
        
        self.updateTopMessageView()

        
        switch self.chatType {
        case .channel:
            self.toolView.aboutBtn.setTitle("频道信息", for: .normal)
        case .groupChat:
            self.toolView.aboutBtn.setTitle("群组信息", for: .normal)
        default:
            break
        }
        
        self.view.addSubview(self.toolView)
        if self.chatType == .groupChat {
            self.searchToolView.memberBtn.isHidden = false
        }else if self.chatType == .channel{
            self.searchToolView.memberBtn.isHidden = true
        }
        self.view.addSubview(self.searchToolView)
        
        if IsiPhoneX {
            self.view.addSubview(self.bottomView)
        }
        
    }
    
    func setChatBar() {
        self.chatBar.textView.font = IMChatTextFont
        self.chatBar.delegate = self
        self.chatBar.textDelegate = self
        
        // 读取草稿
        if let drafts = self.chatListModel?.subTitle, drafts.count > 0 {
            if let attributeArr = CustomUtil.getChatDrafts(jid: self.toJID), attributeArr.count > 0 {
                let list = List<CODAttributeTextModel>()
                for dic in attributeArr{
                    if let attributeModel = CODAttributeTextModel.deserialize(from: dic) {
                        list.append(attributeModel)
                    }
                }
                let attributeText = list.toAttributeText(text: drafts)
                self.chatBar.textView.attributedText = attributeText
            }else{
                self.chatBar.textView.attributedText = NSAttributedString(string: drafts).font(IMChatTextFont)
            }
        }
        
    }
    
    /// 添加约束
    func h_snpKit(){
        
        self.topMessageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(51)
        }
        
        self.searchBar.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        })
        
        self.chatBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom).offset(-kSafeArea_Bottom)
            make.height.greaterThanOrEqualTo(TABBAR_HEIGHT)
        }
        self.channelBottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom).offset(-kSafeArea_Bottom)
            make.height.greaterThanOrEqualTo(45)
        }
        self.chatBar.isHidden = false
        self.channelBottomView.isHidden = true
        self.editView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.chatBar.snp.top).offset(0)
            make.height.equalTo(48)
        }
        self.recordLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.chatBar.snp.top)
            make.height.equalTo(35)
        }
        self.multipleSelectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom).offset(CGFloat(-kSafeArea_Bottom))
            make.height.equalTo(CGFloat(TABBAR_HEIGHT))
        }
        self.tipView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom).offset(0)
            make.height.greaterThanOrEqualTo(CGFloat(TABBAR_HEIGHT) + CGFloat(kSafeArea_Bottom))
        }
        self.messageView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(self.chatBar.snp.top).offset(0)
        }
        
        if IsiPhoneX {
            self.bottomView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.equalTo(kSafeArea_Bottom)
            }
        }
        self.toolView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(-54)
            make.height.equalTo(54)
        }
        self.searchToolView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom).offset(-kSafeArea_Bottom)
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(TABBAR_HEIGHT)
        }
        if self.isGroupChat {
            self.memberToolView.delegate = self
            self.view.addSubview(self.memberToolView)
            self.memberToolView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(self.view).offset(44)
                make.bottom.equalTo(self.messageView.snp.bottom).offset(211)
            }
        }
    }
    
    ///表情键盘管理者
    func setUpKeyBord() {
        self.emojiKBHelper.emojiGroupData(userID:"") {[weak self] (dataArray) in
            self?.emojiKeyboard.emojiGroupData = dataArray
        }
        
        if var chatMoreKeyboardData = self.moreKBHelper.chatMoreKeyboardData {
            
            if self.isGroupChat {
                var voiceCallItem: CODMoreKeyboardItem? = nil
                var videoCallItem: CODMoreKeyboardItem? = nil
                for callItem in chatMoreKeyboardData {
                    if callItem.type == .CODMoreKeyboardItemTypeVoiceCall {
                        voiceCallItem = callItem
                    }else if callItem.type == .CODMoreKeyboardItemTypeVideoCall {
                        videoCallItem = callItem
                    }
                }
                var removeArr = Array<CODMoreKeyboardItem>()
                if let item = voiceCallItem, self.chatType == .channel {
                    removeArr.append(item)
                }
                if let item = videoCallItem {
                    removeArr.append(item)
                }
                if removeArr.count > 0 {
                    let arr = chatMoreKeyboardData.removeAll(removeArr)
                    self.moreKeyboard.chatMoreKeyboardData = arr
                }else{
                    self.moreKeyboard.chatMoreKeyboardData = chatMoreKeyboardData
                }
                
            }else{
                if self.chatId <= 0 {
                    var voiceCallItem: CODMoreKeyboardItem? = nil
                    var videoCallItem: CODMoreKeyboardItem? = nil
                    var cloudDiskItem: CODMoreKeyboardItem? = nil
                    for callItem in chatMoreKeyboardData {
                        if callItem.type == .CODMoreKeyboardItemTypeVoiceCall {
                            voiceCallItem = callItem
                        }else if callItem.type == .CODMoreKeyboardItemTypeVideoCall {
                            videoCallItem = callItem
                        }else if callItem.type == .CODMoreKeyboardItemTypeCloudDisk {
                            cloudDiskItem = callItem
                        }
                    }
                    var removeArr = Array<CODMoreKeyboardItem>()
                    if let item = voiceCallItem {
                        removeArr.append(item)
                    }
                    if let item = videoCallItem {
                        removeArr.append(item)
                    }
                    //                    if self.chatId == CloudDiskRosterID {
                    //                        if let item = cloudDiskItem {
                    //                            removeArr.append(item)
                    //                        }
                    //                    }
                    if removeArr.count > 0 {
                        let arr = chatMoreKeyboardData.removeAll(removeArr)
                        self.moreKeyboard.chatMoreKeyboardData = arr
                    }else{
                        self.moreKeyboard.chatMoreKeyboardData = chatMoreKeyboardData
                    }
                }
                self.moreKeyboard.chatMoreKeyboardData = chatMoreKeyboardData
            }
        }
    }
    
    ///添加键盘的通知
    func setUpUIKeyboardNotifation() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(_ :)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_ :)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_ :)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(_ :)),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameWillChange(_ :)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        
    }
    
    func setUpOtherNotifation() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateMemberCount),
                                               name: NSNotification.Name.init(rawValue: kUpdateGroupMemberCountNoti),
                                               object: nil)
        
        //        NotificationCenter.default.addObserver(self,
        //                                               selector: #selector(insertMessageToView(notification:)),
        //                                               name: NSNotification.Name.init(rawValue: kUpdataMessageView),
        //                                               object: nil)
        //        NotificationCenter.default.addObserver(self,
        //                                               selector: #selector(updateMessageToView(notification:)),
        //                                               name: NSNotification.Name.init(rawValue: kUpdataMessageStatueView),
        //                                               object: nil)
        //        NotificationCenter.default.addObserver(self,
        //                                               selector: #selector(updateMessageUploadProgress(notification:)),
        //                                               name: NSNotification.Name.init(rawValue: kUploadCellUpdateNoti),
        //                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideBrowser),
                                               name: NSNotification.Name.init(rawValue: "kHideBrowser"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRedPoint),
                                               name: NSNotification.Name.init(kReloadRedPoint),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(statusBarTouchedAction),
                                               name: NSNotification.Name.init("kStatusBarTappedNotification"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textFieldDidDeleteBackward),
                                               name: NSNotification.Name.WJTextFieldDidDeleteBackward,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cancelRecord),
                                               name: NSNotification.Name.init(kAudioCallBegin),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deleteMessageFromView(notification:)),
                                               name: NSNotification.Name.init(kDeleteMessageNoti),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imageBrowserHidden),
                                               name: NSNotification.Name.init("kImageBrowserHidden"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTopMessage),
                                               name: NSNotification.Name.init(kNotificationTopMessage),
                                               object: nil)
        //        NotificationCenter.default.addObserver(self,
        //                                               selector: #selector(updateAtMessage(notification:)),
        //                                               name: NSNotification.Name.init(kNotificationUpdateAtMessage),
        //                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showCollectionMessageSendSuccess(notification:)),
                                               name: NSNotification.Name.init(kCollectionMessageSuccess),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mulitShare(noti:)),
                                               name: NSNotification.Name.init(kMulitShare),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateGroupIsVaild),
                                               name: NSNotification.Name.init(kNotificationUpdateChannel),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAllMessage(noti:)), name: Notification.Name(rawValue: kNotificationReloadAllMessgae), object: nil)
        
    }
    
    @objc func reloadAllMessage(noti:NSNotification) {
        
        self.messageView.reloadTableView()
        
    }
    
    @objc func mulitShare(noti:NSNotification) {
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus(NSLocalizedString("网络异常，暂不支持转发", comment: ""))
        }else{
            let msgList = noti.object as! Array<CODMessageModel>
            self.retransionMessage(messages: msgList)
        }
    }
    
    @objc func applicationBecomeAvailable() {
        if self.isSearch {
            //            searchBar.endEditing(false)
            //            searchBar.becomeFirstResponder()
            //            self.searchBarTextDidBeginEditing(self.searchBar)
            self.navigationController?.navigationBar.isHidden = true
            UIView.animate(withDuration: 2, animations: {
            }) { (finished) in
                self.searchBar.becomeFirstResponder()
                
            }
        }
    }
    
    @objc func applicationBecomeUnavailable() {
        if self.isSearch {
            searchBar.endEditing(true)
            self.dismisskeyboard()
        }
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func imageBrowserHidden() {
        self.messageView.tableView.scrollsToTop = true
    }
    
    @objc func didEnterBackground() {
        //        if self.isSearch {
        //            self.searchBar.becomeFirstResponder()
        //        }
    }
    @objc func willEnterForeground() {
        //        if self.isSearch {
        //            self.searchBar.becomeFirstResponder()
        //        }
    }
    @objc func hideBrowser() {
        self.messageView.tableView.scrollsToTop = true
    }
}

// MARK: - 键盘通知
extension MessageViewController{
    @objc func keyBoardWillShow(_ notification:NSNotification){
        if self.isSearch {return}
        if self.curStatus != .CODChatBarStatusKeyboard{///不是键盘
            return
        }
        //        self.messageView.scrollToBottomWithAnimation(animation: false)
    }
    
    @objc func keyboardDidShow(_ notification:NSNotification){
        if self.isSearch {return}
        ///键盘弹出
        if self.curStatus != .CODChatBarStatusKeyboard{///不是键盘
            return
        }
        if self.lastStatus  == .CODChatBarStatusMore{///前面是更多键盘
            self.moreKeyboard.dismissWithAnimation(animation: false)
        }
        if self.lastStatus  == .CODChatBarStatusVoice{///前面是更多键盘
            self.recordKeyboared.dismissWithAnimation(animation: false)
        }
        if self.lastStatus  == .CODChatBarStatusEmoji{///前面的表情键盘
            self.emojiKeyboard.dismissWithAnimation(animation: false)
        }
        //        self.messageView.scrollToBottomWithAnimation(animation: false)
    }
    @objc func keyboardWillHide(_ notification:NSNotification){
        if self.isSearch {
            self.searchToolView.snp.updateConstraints { (make) in
                make.bottom.equalTo(self.view.snp.bottom).offset(-kSafeArea_Bottom)
            }
            self.chatBar.snp.updateConstraints { (make) in
                make.bottom.equalTo(self.view.snp.bottom).offset(-kSafeArea_Bottom)
            }
            if isGroupChat {
                self.memberToolView.snp.updateConstraints { (make) in
                    make.bottom.equalTo(self.messageView.snp.bottom).offset(211)
                }
            }
            
            self.view.layoutIfNeeded()
        }else{
            if (self.curStatus != .CODChatBarStatusKeyboard && self.lastStatus != .CODChatBarStatusKeyboard) {
                return;
            }
            if (self.curStatus == .CODChatBarStatusMore || self.curStatus == .CODChatBarStatusEmoji || self.curStatus == .CODChatBarStatusVoice ) {
                return;
            }
            self.chatBar.snp.updateConstraints { (make) in
                make.bottom.equalTo(self.view.snp.bottom).offset(-kSafeArea_Bottom)
            }
            self.view.layoutIfNeeded()
        }
        
    }
    @objc func keyboardDidHide(_ notification:NSNotification){
        
    }
    
    @objc func keyboardFrameWillChange(_ notification:NSNotification){
        if self.isSearch {
            let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            self.searchToolView.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().offset(-keyboardFrame.size.height)
                //                make.left.right.equalToSuperview()
                //                make.height.greaterThanOrEqualTo(TABBAR_HEIGHT)
            }
            self.chatBar.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().offset(-keyboardFrame.size.height)
            }
            if isGroupChat {
                self.memberToolView.snp.updateConstraints { (make) in
                    make.bottom.equalTo(self.messageView.snp.bottom).offset(81)
                }
            }
            self.view.layoutIfNeeded()
        }else{
            ///如果这次还有上次的模式都不是键盘模式
            if (curStatus != .CODChatBarStatusKeyboard) {
                return
            }
            let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            if (lastStatus == .CODChatBarStatusMore || lastStatus == .CODChatBarStatusEmoji || lastStatus == .CODChatBarStatusVoice) {
                if (keyboardFrame.size.height <= HEIGHT_CHAT_KEYBOARD) {
                    return
                }
            } else if (curStatus == .CODChatBarStatusEmoji || curStatus == .CODChatBarStatusMore || lastStatus == .CODChatBarStatusVoice) {
                return
            }
            
            self.chatBar.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().offset(-keyboardFrame.size.height)
            }
            self.emojiKeyboard.snp.updateConstraints({ (make) in
                make.height.equalTo(HEIGHT_CHAT_KEYBOARD+CGFloat(kSafeArea_Bottom))
            })
            self.view.layoutIfNeeded()
            //            self.messageView.scrollToBottomWithAnimation(animation: false)
        }
        
    }
    
    /// 发送文字
    ///
    /// - Parameters:
    ///   - chatBar: ChatBar
    ///   - text: 发送文字内容
    func sendText(chatBar: CODChatBar, text: NSAttributedString) {
        ///发送消息
        if !self.isGroupChat {
            XMPPManager.shareXMPPManager.sendChatStateTo(userName: self.toJID, chatState: XMPPMessage.ChatState.paused)
        }
        self.sendTextMessage(text: text.string,attributeStr: text, toJID: self.toJID, memberArr: chatBar.memberNotificationArr)
        chatBar.memberNotificationArr.removeAll()
    }
    
    func chatBar(chatBar: CODChatBar, textDidChange text: NSAttributedString) {
        //        let textStr = text
        //        self.draftStr = textStr
    }
}

extension MessageViewController:CODChatMessageDisplayViewDelegate{
    
    /// 举报
    /// - Parameters:
    ///   - message: 被举报的消息
    ///   - reportType: 举报类型
    func reportOther(message: CODMessageModel, reportType: BalloonActionViewController.ReportType) {
        
        if reportType == .other {
            
            let vc = CODReportViewController(nibName: "CODReportViewController", bundle: Bundle.main)
            vc.message = message
            let nav = BaseNavigationController(rootViewController: vc)
            self.present(nav, animated: true)
            
        } else {
            
            CustomUtil.reportMessage(message: message, reportType: reportType)
            
        }
    }
    
    func newMessageHaveCreate() {
        
    }
    
    
    func tapAtAll() {
        self.navRightClick()
    }
    
    
    func collectionMessage(message: CODMessageModel) {
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus(NSLocalizedString("网络异常，收藏失败", comment: ""))
        }else{
            let fileIDs = CustomUtil.getMessageFileIDS(messages: [message])
            self.vaildTranfile(fileIDs: CustomUtil.getPictureID(fileIDs: fileIDs), type: .ChatToCloudDisk, messages: [message])
            if let contactModel = CODContactRealmTool.getContactById(by: CloudDiskRosterID) {
                let getCopyModel = self.getTransCopyModel(model: message, isGroupChat: false)
                getCopyModel.msgID = UserManager.sharedInstance.getCloudDiskMessageId()
                getCopyModel.toJID = contactModel.jid
                getCopyModel.toWho = contactModel.jid
                getCopyModel.burn = contactModel.burn
                getCopyModel.chatTypeEnum = .privateChat
                getCopyModel.userPic = message.userPic
                if self.chatType == .channel {
                    getCopyModel.userPic = self.channelModel?.grouppic ?? ""
                }
                self.collectionMessage = getCopyModel
                self.copyMediaFile(messageModel: getCopyModel,toPathJid: kCloudJid + XMPPSuffix,fromPathJid: self.toJID)
                CODChatListRealmTool.addChatListMessages(id: contactModel.rosterID, messages: [getCopyModel])
                
                //通知去聊天列表中更新数据
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                
                if getCopyModel.type == .multipleImage {
                    CODMessageSendTool.default.sendMessage(by: getCopyModel)
                } else {
                    CODMessageSendTool.default.sendMessage(messageModel: getCopyModel, sender: getCopyModel.fromWho)
                }
                CODMessageSendTool.default.postAddMessageToView(messageID: getCopyModel.msgID)
            }
        }
    }
    
    @objc func showCollectionMessageSendSuccess(notification: NSNotification) {
        if let msgID = notification.userInfo?["msgID"] as? String,msgID == self.collectionMessage.msgID{
            let alertView = UIAlertView.init(title: "", message: NSLocalizedString("已收藏至云盘", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("好", comment: ""))
            alertView.show()
            self.isCollection = true
            self.collectionMessage = CODMessageModel()
        }
        
    }
    
    func transMessage(message: CODMessageModel) {
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus(NSLocalizedString("网络异常，暂不支持转发", comment: ""))
        }else{
            self.retransionMessage(messages: [message])
        }
    }
    
    func topMessage(message: CODMessageModel) {
        if message.msgID == self.chatListModel?.groupChat?.topmsg || message.msgID == self.chatListModel?.channelChat?.topmsg {
            self.cancelTopMessage()
            return
        }
        self.topMessage = message
        
        
        let alertView = UIAlertView.init(title: "", message: NSLocalizedString("您确定要置顶此消息吗？", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("取消", comment: ""))
        alertView.addButton(withTitle: NSLocalizedString("置顶", comment: ""))
        alertView.show()
    }
    
    func topMessageSettingSuccess(messageID: String) {
        
        
        if let message = CODMessageRealmTool.getExistMessage(messageID){
            
            self.topMessageView.isHidden = false
            self.topMessageView.model = message
            
            //            var textHeight = self.topMessageView.desLabel.text?.getStringHeight(font: self.topMessageView.desLabel.font, lineSpacing: 0, fixedWidth: KScreenWidth - 84 - (self.topMessageView.checkMsgImageType(message) ? 35 : 0)) ?? 0
            //            if textHeight > 30 {
            //                textHeight = 40
            //            }else{
            let textHeight = 22
            //            }
            self.topMessageView.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                if self.inCallView.isHidden {
                    make.top.equalToSuperview()
                }else{
                    make.top.equalTo(self.inCallView.snp.bottom)
                }
                make.height.equalTo(30 + textHeight)
            }
            self.updateMessageView()
        }else{
            self.topMessageView.isHidden = true
            self.topMessageView.model = nil
            self.topMessage = CODMessageModel()
            
        }
        self.updateMessageView()
    }
    
    func replyMessage(message: CODMessageModel) {
        if message.statusType != .Succeed {
            return
        }
        if !CustomUtil.judgeInGroupRoomCanSpeak(roomId: self.chatId) {
            return
        }
        self.hideSearchToolView()
        if self.chatType == .groupChat {//群组
            
            if let tipString = CustomUtil.judgeInGroupRoom(roomId: self.chatId),tipString.removeAllSapce.count > 0{
                return
            }
            
        } else  if self.chatType == .channel {//频道
            
            let channelPower = CustomUtil.judgeInChannelRoom(roomId: self.chatId)
            if  !channelPower.isManager {
                return
            }
        }else{//单聊的时候记录是不是自己的好友
            //            if let tipString = CustomUtil.judgeInMyFriendByJID(jid: self.toJID),tipString.removeAllSapce.count > 0{
            //                return
            //            }
        }
        self.replyMessage = message
        self.editMessage = CODMessageModel()
        self.transMessage = CODMessageModel()
        if !self.isGroupChat {
            message.nick = self.title ?? ""
        }
        self.editView.setCellContent(message,isReply: true)
        self.editView.isHidden = false
        //        self.chatBar.textView.text = ""
        self.chatBar.textView.becomeFirstResponder()
        self.chatBar.isEdit = false
        self.updateMessageView()

        self.view.layoutIfNeeded()
        //        self.messageView.scrollToBottomWithAnimation(animation: false)
    }
    
    func more() {
        self.hiddenMultipleSelectionView(isHidden: self.messageView.tableView.isEditing)
        self.messageView.tableView.setEditing(!self.messageView.tableView.isEditing, animated: false)
        XinhooTool.isEdit_MessageView = self.messageView.tableView.isEditing
        NotificationCenter.default.post(name: NSNotification.Name.init("kCellMoreAction"), object: self.messageView.tableView.isEditing)
        self.messageView.tableView.reloadData()
    }
    
    func editMessage(message: CODMessageModel) {
        if !CustomUtil.judgeInGroupRoomCanSpeak(roomId: self.chatId) {
            self.channelBottomView.isHidden = false
            self.channelBottomView.setTitle(NSLocalizedString("全员禁言中", comment: ""), for: .normal)
            self.channelBottomView.setTitleColor(UIColor.init(hexString: "#8E8E92"), for: .normal)
            self.dismisskeyboard()
            return
        }
        self.isCompress = false
        self.hideSearchToolView()
        self.replyMessage = CODMessageModel()
        self.editMessage = message
        self.transMessage = CODMessageModel()
        self.editView.setCellContent(message,isEdit: true)
        self.editView.isHidden = false
        let typingAttributes = self.chatBar.textView.typingAttributes
        self.chatBar.textView.attributedText = message.attrText
        self.chatBar.textView.typingAttributes = typingAttributes
        self.chatBar.textView.becomeFirstResponder()
        self.chatBar.isEdit = true
        var referToArr = Array<CODGroupMemberModel>()
        for referToString in message.referTo {
            
            if referToString == kAtAll {
                let allMember = CODGroupMemberModel.init()
                allMember.nickname = NSLocalizedString("all", comment: "")
                allMember.jid = kAtAll
                referToArr.append(allMember)
            }else{
                let memberId = CODGroupMemberModel.getMemberId(roomId: self.chatId, userName: referToString)
                if let member = CODGroupMemberRealmTool.getMemberById(memberId){
                    referToArr.append(member)
                }
            }
        }
        
        self.chatBar.memberNotificationArr = referToArr
        self.updateMessageView()

        self.view.layoutIfNeeded()
        //        self.messageView.scrollToBottomWithAnimation(animation: false)
    }
    
    func deleteMessage(message: CODMessageModel) {
        //        self.hideSearchToolView()
    }
    
    func fileMessage(message: CODMessageModel, imageView: UIImageView) {
        
        self.searchBar.resignFirstResponder()
        let browser:YBImageBrowser =  YBImageBrowser()
        
        self.messageView.messageDisplayViewVM.fetchFileImageData()
        
        let photoIndex: Int = self.messageView.messageDisplayViewVM.findFileImageIndex(messageModel: message) ?? 0
        let toolHander = YBIBToolViewHandler()
        toolHander.delegate = self
        browser.toolViewHandlers = [toolHander]
        browser.dataSourceArray = self.messageView.messageDisplayViewVM.fileImageData
        browser.currentPage = photoIndex
        self.photoBrowser = browser
        self.messageView.tableView.scrollsToTop = false
        browser.show()
    }
    
    //视频的点击方式
    func voideClick(message: CODMessageModel, imageView: UIImageView) {
        
        self.searchBar.resignFirstResponder()
        self.messageView.messageDisplayViewVM.fetchImageData()
        let photoIndex: Int = self.getPhotoMessageIndex(photoModel: message) ?? 0
        let browser:YBImageBrowser =  YBImageBrowser()
        let toolHander = YBIBToolViewHandler()
        toolHander.delegate = self
        browser.toolViewHandlers = [toolHander]
        browser.dataSourceArray = self.messageView.messageDisplayViewVM.imageData
        browser.currentPage = photoIndex
        self.photoBrowser = browser
        self.messageView.tableView.scrollsToTop = false
        browser.show()
    }
    
    func videoCall(message: CODMessageModel, fromMe: Bool) {
        //        if fromMe {
        self.vioceCall(callType: message.msgType == EMMessageBodyType.voiceCall.rawValue ? COD_call_type_voice : COD_call_type_video)
        //        }
    }
    
    
    //聊天列表的点击事件
    func audioClick(message: CODMessageModel, showCell: CODAudioChatCell) {
        //点击当前的cell
        if currentVoiceModel?.msgID == message.msgID {
            self.currentVoiceModel = CODMessageModel()
            if(AudioPlayManager.sharedInstance.isPlaying == true){ ///正在播放
                AudioPlayManager.sharedInstance.stopPlayer()
                ///判断播放的地址是不是一样的 不一样当前这个showCell要开始播放这个新的 并且暂停前面cell的播放
                if(AudioPlayManager.sharedInstance.playURL != message.audioModel?.audioURL ?? ""){
                    showCell.voiceImageView.startPlayingAnimation()
                    AudioPlayManager.sharedInstance.startPlaying(message) { (type, error) in
                        showCell.voiceImageView.stopPlayingAnimation()
                        if type == CODPlayerStatusType.CODPlayerStatusSuccess{
                        }else{
                        }
                    }
                }else{
                    showCell.voiceImageView.stopPlayingAnimation()
                }
            }
        }else{
            self.palyAudio(message: message, showCell: showCell)
        }
        
    }
    
    //自动播放
    func autoPlayMessage(message: CODMessageModel){
        
        let messageArray:ArraySlice<String> = self.getAudioMessages(audioModel: message) 
        if messageArray.count > 0 {
            
            if let audioMsgID = messageArray.first  {
                
                if let playCell = self.audioCellArray[audioMsgID] as? CODAudioChatCell,let audioMessage = self.audioArray[audioMsgID] {
                    self.palyAudio(message: audioMessage, showCell: playCell)
                }
                
            }
        }
        self.deleteFromAudioArray(audioModel: message)
        
    }
    
    func  palyNext() {
        
        //获取最新的cell的位置
        if let cellRow = self.getMessageCellRow(message: self.lastVoiceModel ?? CODMessageModel()) {
            
            if let lastCell = self.messageView.tableView.cellForRow(at: IndexPath(row: cellRow, section: 0)) as? CODAudioChatCell {
                lastCell.voiceImageView.stopPlayingAnimation()
                lastCell.unPlayVeiw.isHidden = true
            }
        }
        
    }
    
    func palyAudio(message: CODMessageModel, showCell: CODAudioChatCell) {
        //把之前的动画给停止
        self.palyNext()
        self.currentVoiceCell?.voiceImageView.stopPlayingAnimation()
        self.lastVoiceModel = self.currentVoiceModel
        //重新赋值新的
        self.currentVoiceCell = showCell
        self.currentVoiceModel = message
        showCell.unPlayVeiw.isHidden = true
        ///先暂停之前的播放
        AudioPlayManager.sharedInstance.stopPlayer()
        AudioPlayManager.sharedInstance.delegate = self
        //开始新的播放
        //        showCell.voiceImageView.startPlayingAnimation()
        AudioPlayManager.sharedInstance.startPlaying(message) { (type, error) in
            
            if type == CODPlayerStatusType.CODPlayerStatusSuccess{
                print("")
            }else{
                print("")
                ///显示错误信息
                //                CODProgressHUD.showErrorWithStatus(error ?? "")
            }
        }
        if !(message.audioModel?.isPlayed ?? false){
            CODMessageRealmTool.updateMessageIsPlayByMsgId(message.msgID, isPlay: true)
            self.messageView.replaceMessageListSomeOneMessage(message: message)
            //            self.messageView.updateMeassage = message
        }
    }
    
    
    //聊天列表的图片的点击事件
    func photoClick(message: CODMessageModel, imageView: UIImageView) {
        photoClick(message: message, imageView: imageView, imageIndex: 0)
    }
    
    func photoClick(message: CODMessageModel, imageView: UIImageView, imageIndex: Int) {
        
        self.messageView.messageDisplayViewVM.fetchImageData()
        self.searchBar.resignFirstResponder()
        let photoIndex: Int = self.getPhotoMessageIndex(photoModel: message, imageIndex: imageIndex) ?? 0
        let browser:YBImageBrowser =  YBImageBrowser()
        let toolHander = YBIBToolViewHandler()
        toolHander.delegate = self
        browser.toolViewHandlers = [toolHander]
        browser.dataSourceArray = self.messageView.messageDisplayViewVM.imageData
        self.photoBrowser = browser
        browser.currentPage = photoIndex
        self.messageView.tableView.scrollsToTop = false
        browser.show()
    }
    
    //长按头像
    func longTapHeadImageView(model: CODGroupMemberModel) {
        
        if self.chatType == .groupChat {
            
            if !CustomUtil.judgeInGroupRoomCanSpeak(roomId: self.chatId) {
                return
            }
        }
        
        if !self.chatBar.memberNotificationArr.contains(model) {
            //需要记住当前textView的selectedRange的location，因为在textView调用becomeFirstResponder()之后，selectRange的location就会变成当前文本的长度
            let location = self.chatBar.textView.selectedRange.location
            
            let str = "@\(model.zzs_getMemberNickName()) " as NSString
            
            let mutableAttStr = NSMutableAttributedString.init(attributedString: self.chatBar.textView.attributedText)
            
            let mutableNameAttribute = NSMutableAttributedString(string: "@\(model.zzs_getMemberNickName()) ",attributes: [.font:IMChatTextFont])
            mutableNameAttribute.addAttributes([.foregroundColor : UIColor.init(hexString: "#1D49A7") as Any], range: NSRange(location: 0, length: mutableNameAttribute.length - 1))
            
            mutableAttStr.insert(mutableNameAttribute, at: self.chatBar.textView.selectedRange.location)
            
            let attachment = YYTextAttachment.init(content:nil)
            attachment.userInfo = ["jid":model.jid]
            
            //            mutableAttStr.yy_setFont(IMChatTextFont, range: NSRange.init(location: 0, length: mutableAttStr.length))
            //location + 1 是为了去掉@，str.length - 2 是为了去掉@跟后面的空格
            mutableAttStr.yy_setTextAttachment(attachment, range: NSRange.init(location: location, length: str.length - 1))
            
            self.chatBar.textView.attributedText = mutableAttStr
            
            self.chatBar.textView.becomeFirstResponder()
            self.chatBar.textView.selectedRange = NSMakeRange(location + str.length , 0)
            self.chatBar.addEmojiString(emojiString: nil)
            self.chatBar.memberNotificationArr.append(model)
            self.chatBar.changeVoiceImage()
            self.chatBar.changeTextViewWithAnimation(animation: false)
        }
    }
    
    //加载更多的消息
    func loadMoreMessage() {
        if self.isEndRefreshing {
            //            self.pullToLoadMore()
        }
    }
    
    /*界面的点击事件 用于收起键盘*/
    func chatMessageDisplayViewDidTouched(chatTVC: CODChatMessageDisplayView) {
        self.dismisskeyboard()
        self.searchBar.resignFirstResponder()
    }
    
}

extension MessageViewController:CODKeyboardDelegate{
    /// 键盘显示
    ///
    /// - Parameters:
    ///   - keyboard: keyboard
    ///   - animated: 动画
    func chatKeyboardWillShow(keyboard:CODBaseKeyboard,animated:Bool){
        self.messageView.scrollToLastMessage(animated: true)
        //        self.messageView.scrollToBottomWithAnimation(animation: false)
    }
    /// 键盘已经显示
    ///
    /// - Parameters:
    ///   - keyboard: keyboard
    ///   - animated: 动画
    func chatKeyboardDidShow(keyboard:CODBaseKeyboard,animated:Bool){
        if (curStatus == .CODChatBarStatusMore && lastStatus == .CODChatBarStatusEmoji) {
            self.emojiKeyboard.dismissWithAnimation(animation: false)
        }else if (curStatus == .CODChatBarStatusEmoji && lastStatus == .CODChatBarStatusMore) {
            self.moreKeyboard.dismissWithAnimation(animation: false)
        }else if(curStatus == .CODChatBarStatusKeyboard && lastStatus == .CODChatBarStatusEmoji){
            self.emojiKeyboard.dismissWithAnimation(animation: false)
        }else if(curStatus == .CODChatBarStatusVoice && lastStatus == .CODChatBarStatusEmoji){
            self.emojiKeyboard.dismissWithAnimation(animation: false)
        }else if(curStatus == .CODChatBarStatusMore && lastStatus == .CODChatBarStatusVoice){
            self.recordKeyboared.dismissWithAnimation(animation: false)
        }else if(curStatus == .CODChatBarStatusEmoji && lastStatus == .CODChatBarStatusVoice){
            self.recordKeyboared.dismissWithAnimation(animation: false)
        }else if(curStatus == .CODChatBarStatusEmoji && lastStatus == .CODChatBarStatusMore){
            self.moreKeyboard.dismissWithAnimation(animation: false)
        }else if(curStatus == .CODChatBarStatusKeyboard && lastStatus == .CODChatBarStatusVoice){
            self.recordKeyboared.dismissWithAnimation(animation: false)
        }else if(curStatus == .CODChatBarStatusKeyboard && lastStatus == .CODChatBarStatusMore){
            self.moreKeyboard.dismissWithAnimation(animation: false)
        }else if(curStatus == .CODChatBarStatusVoice && lastStatus == .CODChatBarStatusMore){
            self.moreKeyboard.dismissWithAnimation(animation: false)
        }
        //        self.messageView.scrollToBottomWithAnimation(animation: false)
        self.messageView.scrollToLastMessage(animated: true)
    }
    //    func chatKeyboardDidShow(keyboard:CODBaseKeyboard,animated:Bool){
    //        if (curStatus == .CODChatBarStatusMore && lastStatus == .CODChatBarStatusEmoji) {
    //            self.emojiKeyboard.dismissWithAnimation(animation: false)
    //        }else if (curStatus == .CODChatBarStatusEmoji && lastStatus == .CODChatBarStatusMore) {
    //            self.moreKeyboard.dismissWithAnimation(animation: false)
    //        }else if(curStatus == .CODChatBarStatusKeyboard && lastStatus == .CODChatBarStatusEmoji){
    //            self.emojiKeyboard.dismissWithAnimation(animation: false)
    //        }
    //        self.messageView.scrollToBottomWithAnimation(animation: false)
    //    }
    /// 键盘消失
    ///
    /// - Parameters:
    ///   - keyboard: keyboard
    ///   - animated: 动画
    func chatKeyboardWillDismiss(keyboard:CODBaseKeyboard,animated:Bool){
        
        
    }
    /// 键盘已经消失
    ///
    /// - Parameters:
    ///   - keyboard: keyboard
    ///   - animated: 动画
    func chatKeyboardDidDismiss(keyboard:CODBaseKeyboard,animated:Bool){
        
    }
    
    /// 键盘高度变化 这个就是
    ///
    /// - Parameters:
    ///   - height: 高度
    ///   - keyboard: keyboard
    func chatKeyboardDidChangeHeight(height:CGFloat,keyboard:CODBaseKeyboard){
        var boardHeight:CGFloat = 0
        
        if height == 0 {
            boardHeight = CGFloat(kSafeArea_Bottom)
        }else{
            boardHeight = height
        }
        self.chatBar.snp.updateConstraints{ (make) in
            make.bottom.equalToSuperview().offset(-(boardHeight))
        }
        self.messageView.snp.remakeConstraints{ (make) in
            make.left.top.right.equalToSuperview()
            if !self.editView.isHidden {
                make.bottom.equalTo(self.editView.snp.top).offset(0)
            }else{
                make.bottom.equalTo(self.chatBar.snp.top).offset(0)
            }
        }
        self.view.layoutIfNeeded()
        self.messageView.scrollToBottomWithAnimation(animation: false)
    }
}


// MARK: - 成功发送的msg回调
extension MessageViewController: XMPPStreamDelegate{ //XMPPSendMsgSuccess
    
    func addXMPPSendMsgSuccessBlock() {
        XMPPManager.shareXMPPManager.sendMsgSuccess = { [weak self] (_ message: XMPPMessage) in
            guard let self = self else {
                return
            }
            
            if let messageModel = XMPPManager.shareXMPPManager.getMessageWithXMPPMsg(message: message) {
                dispatch_async_safely_to_main_queue({ [weak self] in
                    guard let strongSelf = self else { return }
                    messageModel.status = CODMessageStatus.Succeed.rawValue
                    
                    
                    
                    if self?.isCloudDisk ?? false || self?.toJID.contains("cod_60000000") ?? false{
                        CODMessageRealmTool.updateMessageHaveReadedByMsgId(messageModel.msgID, isReaded: true)
                    }
                    if self?.chatId == 0 {  //如果是小助手，默认已读
                        CODMessageRealmTool.updateMessageHaveReadedByMsgId(messageModel.msgID, isReaded: true)
                    }
                    CODMessageRealmTool.updateMessageStyleByMsgId(messageModel.msgID, status: CODMessageStatus.Succeed.rawValue, sendTime: messageModel.datetimeInt)
                    
                    if let contactModel = CODContactRealmTool.getContactByJID(by: messageModel.toWho) {
                        if contactModel.rosterID != self?.chatId {
                            return
                        }
                    }
                    
                    
                    //                    if let listModel = CODChatListRealmTool.getChatList(id: strongSelf.chatId) {
                    //                        try! Realm.init().write {
                    //                            listModel.lastDateTime = "\(messageModel.datetimeInt)"
                    //                        }
                    //                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo:nil)
                    //                    }
                    //                    CODMessageRealmTool.updateMessageVideoUrl(messageModel.msgID, videoURL: messageModel.videoModel?.videoURL ?? "", firstpicUrl: messageModel.videoModel?.firstpicUrl ?? "",picID: messageModel.photoModel?.serverImageId ?? "",audioURL:messageModel.audioModel?.audioURL ?? "", fileID: messageModel.fileModel?.fileID ?? "", locationString: messageModel.location?.locationImageString ?? "", sendTime: messageModel.datetimeInt)
                    strongSelf.messageView.updateMeassage = messageModel
                    //                    if messageModel.toJID == self?.toJID {
                    //                        CODChatListRealmTool.updateLastDateTime(id: self?.chatId ?? 0, lastDateTime: "\(messageModel.datetimeInt)")
                    //                        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                    //                    }
                    
                })
            }
        }
    }
    
    func addXMPPRemoveMsgBlock() {
        XMPPManager.shareXMPPManager.removeMsgBlock = { [weak self] (_ msgId: String) in
            guard let self = self else {
                return
            }
            dispatch_async_safely_to_main_queue({ [weak self] in
                guard let strongSelf = self else { return }
                
                if CODAudioPlayerManager.sharedInstance.isPlaying() {
                    if CODAudioPlayerManager.sharedInstance.playModel?.msgID == msgId {
                        CODAudioPlayerManager.sharedInstance.stop()
                    }
                }
                strongSelf.messageView.messageDisplayViewVM.cellDeleteMessage(msgIDs: [msgId])
                
                strongSelf.updateTopMessage()
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
            })
        }
    }
    
    func addXMPPEditMsgBlock() {
        XMPPManager.shareXMPPManager.editMsgBlock = { [weak self] (_ message: CODMessageModel) in
            guard let self = self else {
                return
            }
            
            if self.isGroupChat{
                if let messageID = self.chatListModel?.groupChat?.topmsg ,messageID == message.msgID{
                    self.topMessageSettingSuccess(messageID: messageID)
                }
                if let messageID = self.chatListModel?.channelChat?.topmsg ,messageID == message.msgID{
                    self.topMessageSettingSuccess(messageID: messageID)
                }
            }
            self.messageView.updateMeassage = message
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
        }
        
        XMPPManager.shareXMPPManager.editFailMsgBlock = { [weak self] (_ messageID: String, _ errorString: String) in
            guard let self = self else {
                return
            }
            
            if let messageModel = CODMessageRealmTool.getMessageByMsgId(messageID) {
                
                if let indexPath = self.messageView.messageDisplayViewVM.findIndexPath(messageId: messageID) {
                    
                    messageModel.editMessage(model: nil, status: .Cancal)
                    self.messageView.messageDisplayViewVM.reloadTableViewBR.accept(indexPath)
                    
                }
                
                
                
            }
            
            //            let predicate = NSPredicate.init(format: "msgID == %@", messageID)
            //            let resultArray = self.messageView.messageList.filtered(using: predicate)
            //            if resultArray.count > 0,let _ = resultArray[0] as? CODMessageModel {
            CODAlertView_show(NSLocalizedString(errorString, comment: ""))
            //            }
        }
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        self.updateGroupAvatar()
    }
    
    //    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
    //        print("******消息发送成功")
    //        if let messageModel = XMPPManager.shareXMPPManager.getMessageWithXMPPMsg(message: message) {
    //            dispatch_async_safely_to_main_queue({[weak self] in
    //                guard let strongSelf = self else { return }
    //                messageModel.status = CODMessageStatus.Succeed.rawValue
    //                CODMessageRealmTool.updateMessageStyleByMsgId(messageModel.msgID, status: CODMessageStatus.Succeed.rawValue)
    //                CODMessageRealmTool.updateMessageVideoUrl(messageModel.msgID, videoURL: messageModel.videoModel?.videoURL ?? "")
    //                strongSelf.messageView.updateMeassage = messageModel
    //            })
    //        }
    //    }
    
    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        print("******消息发送失败 ： \(message)")
        
        if let messageModel = XMPPManager.shareXMPPManager.getMessageWithXMPPMsg(message: message) {
            if  let newMessage = CODMessageRealmTool.getMessageByMsgId(messageModel.msgID) , newMessage.status ==  CODMessageStatus.Pending.rawValue {
                messageModel.status = CODMessageStatus.Failed.rawValue
                //                CODMessageRealmTool.updateMessageStyleByMsgId(messageModel.msgID, status: CODMessageStatus.Failed.rawValue, sendTime: messageModel.datetimeInt)
                //                CODMessageRealmTool.updateMessageVideoUrl(messageModel.msgID, videoURL: messageModel.videoModel?.videoURL ?? "", firstpicUrl: messageModel.videoModel?.firstpicUrl ?? "",picID: messageModel.photoModel?.serverImageId ?? "", audioURL: messageModel.audioModel?.audioURL ?? "", fileID: messageModel.fileModel?.fileID ?? "", locationString: messageModel.location?.locationImageString ?? "", sendTime: messageModel.datetimeInt)
                self.messageView.updateMeassage = messageModel
            }
        }
    }
    
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { [weak self] (actionDict, infoDict) in
            
            dispatch_sync_safely_to_main_queue {
                
                guard let infoDict = infoDict else {
                    return
                }
                guard let self = self else {
                    return
                }
                
                
                if ((actionDict["name"] as? String == COD_accept) || (actionDict["name"] as? String == COD_request)) {
                    
                    if let success = infoDict["success"] as? Bool, let code = infoDict["code"] as? Int{
                        if !success {
                            
                            switch code {
                            case 30061:
                                CODAlertView_show(NSLocalizedString("您已在语音通话中", comment: ""))
                            case 30062:
                                CODAlertView_show(NSLocalizedString("加入人数已达上限", comment: ""))
                            default:
                                break
                            }
                            return
                        }
                    }
                }
                
                if (actionDict["name"] as? String == COD_changeGroup){ //群组设置
                    if let itemID = actionDict["itemID"] as? Int {
                        if itemID != self.chatId {
                            return
                        }
                    }
                    if let success = infoDict["success"] as? Bool{
                        if !success{
                            
                            CODProgressHUD.showErrorWithStatus("设置失败")
                            return
                        }
                        
                    }
                    
                    let dict = actionDict["setting"] as! NSDictionary
                    if let result = dict["mute"] as? Bool{
                        self.toolView.donotdisturbBtn.isSelected = result
                        if let model = self.chatListModel?.groupChat {
                            try! Realm.init().write {
                                model.mute =  result
                            }
                        }
                    }
                    if let result = dict["topmsg"] as? String{
                        
                        self.topMessageSettingSuccess(messageID: result)
                        if let model = self.chatListModel?.groupChat {
                            try! Realm.init().write {
                                model.topmsg = result
                            }
                        }
                        
                        if let model = self.chatListModel?.channelChat {
                            try! Realm.init().write {
                                model.topmsg = result
                            }
                        }
                    }
                }
                if (actionDict["name"] as? String == COD_changeChat){ //单聊设置
                    if let itemID = actionDict["itemID"] as? Int {
                        if itemID != self.chatId {
                            return
                        }
                    }
                    if !(infoDict["success"] as! Bool) {
                        CODProgressHUD.showErrorWithStatus("设置失败")
                        return
                    }
                    let dict = actionDict["setting"] as! NSDictionary
                    if let result = dict["mute"] as? Bool{
                        self.toolView.donotdisturbBtn.isSelected = result
                        if let model = self.chatListModel?.contact {
                            try! Realm.init().write {
                                model.mute =  result
                            }
                        }
                    }
                    
                }
//                if actionDict["name"] as? String == COD_GroupMembersOnlineTime {
//                    
//                    
//                    DispatchQueue.groupMembersOnlineTimeQueue.async {
//                        
//                        if let roomId = actionDict["roomID"] as? Int {
//                            if roomId != self.chatId {
//                                return
//                            }
//                        }
//                        
//                        var onlineCount = 0
//                        var memberCount = 0
//                        var tempMemberArr: Array<CODGroupMemberModel> = []
//                        guard let data = infoDict["data"] as? NSArray else {
//                            return
//                        }
//                        memberCount = data.count
//                        for object in data {
//                            guard let jsonStr = object as? NSString else {
//                                return
//                            }
//                            let item = CustomUtil.dictionaryWithString(jsonStr: jsonStr)
//                            guard let obj = CODGroupMemberOnlineModel.deserialize(from: item) else {
//                                return
//                            }
//                            let memberId = CODGroupMemberModel.getMemberId(roomId: self.chatId, userName: obj.userName)
//                            if let member = CODGroupMemberRealmTool.getMemberById(memberId) {
//                                var newMember = CODGroupMemberModel()
//                                newMember = member.mutableCopy() as! CODGroupMemberModel
//                                newMember.loginStatus = obj.active
//                                newMember.lastLoginTimeVisible = obj.lastLoginTimeVisible
//                                newMember.lastlogintime = obj.lastlogintime
//                                if obj.active == "ONLINE" {
//                                    onlineCount += 1
//                                    newMember.lastlogintime = Int(Date.milliseconds)
//                                }
//                                if !obj.lastLoginTimeVisible {
//                                    newMember.lastlogintime = 0
//                                }
//                                tempMemberArr.append(newMember)
//                            }
//                            
//                        }
//                        if onlineCount > 0 {
//                            dispatch_async_safely_to_main_queue {
//                                self.navBarTitleView.setSubTitle(memberCount: memberCount, onlineCount: onlineCount)
//                            }
//                            
//                        }
//                        
//                        try! Realm.init().write {
//                            try! Realm.init().add(tempMemberArr, update: .modified)
//                        }
//                    }
//                    
//                }
                
                if (actionDict["name"] as? String == COD_GetStatus){
                    if let isSuccess = infoDict["success"] as? Bool {
                        guard isSuccess else {
                            return
                        }
                        if let dataDic = infoDict.object(forKey: "data") as? NSDictionary,
                            let lastloginTime = dataDic.object(forKey: "lastloginTime") as? Int,
                            let status = dataDic.object(forKey: "status") as? String,
                            let lastLoginTimeVisible = dataDic.object(forKey: "lastLoginTimeVisible") as? Bool,
                            let jid = dataDic.object(forKey: "jid") as? String
                        {
                            if jid != self.toJID {
                                return
                            }
                            if let contact = CODContactRealmTool.getContactByJID(by: jid) {
                                try! Realm.init().write {
                                    contact.lastlogintime = lastloginTime
                                    contact.loginStatus = status
                                    contact.lastLoginTimeVisible = lastLoginTimeVisible
                                }
                            }
                            
                            self.updateLoginStatus()
                        }
                    }
                }
                
                
            }
            
            
        }
        
        return true
        
    }
    
}

extension MessageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < kChatLoadMoreOffset) {
            //            if self.isEndRefreshing {
            let time: TimeInterval = 3.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                //code
                dispatch_async_safely_to_main_queue({[weak self] in
                    guard let strongSelf = self else { return }
                    //                    strongSelf.pullToLoadMore()
                    
                })
            }
        }
        
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //        self.hideAllKeyboard()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y - scrollView.contentInset.top < kChatLoadMoreOffset) {
            if self.isEndRefreshing {
                //                self.pullToLoadMore()
            }
        }
    }
}
extension MessageViewController{
    ///点击事件
    @objc public func tapView(gestureRecognizer:UITapGestureRecognizer){
        
        
        if self.newMessageCount >= 0 {
            self.messageView.scrollToMessage(index: self.newMessageCount - 1, animated: true)
        }
        
        self.newMessageCount = 0
        
        
    }
    
}

extension MessageViewController:PlayAudioDelegate{
    
    func audioPlayStart() {
        self.palyNext()
        if self.getMessageIndexPath(message: self.currentVoiceModel ?? CODMessageModel()) {
            self.currentVoiceCell?.unPlayVeiw.isHidden = true
            self.currentVoiceCell?.voiceImageView.startPlayingAnimation()
        }
    }
    
    func audioPlayFinished() {
        self.palyNext()
        
        if self.getMessageIndexPath(message: self.currentVoiceModel ?? CODMessageModel()) {
            //            self.currentVoiceCell?.unPlayVeiw.isHidden = true
            self.currentVoiceCell?.voiceImageView.stopPlayingAnimation()
        }
        
        self.autoPlayMessage(message: self.currentVoiceModel ?? CODMessageModel())
    }
    
    func audioPlayFailed() {
        self.palyNext()
        
        if self.getMessageIndexPath(message: self.currentVoiceModel ?? CODMessageModel()) {
            //            self.currentVoiceCell?.unPlayVeiw.isHidden = true
            self.currentVoiceCell?.voiceImageView.stopPlayingAnimation()
        }
    }
    
    func audioPlayInterruption() {
        self.palyNext()
        
        if self.getMessageIndexPath(message: self.currentVoiceModel ?? CODMessageModel()) {
            self.currentVoiceCell?.unPlayVeiw.isHidden = true
            self.currentVoiceCell?.voiceImageView.stopPlayingAnimation()
        }
    }
    
    @objc func statusBarTouchedAction() {
        
        let touchOffSet = KScreenHeight*4
        let currentOff = self.messageView.tableView.contentOffset
        
        if currentOff.y > touchOffSet {
            //            [UIView animateWithDuration:durationInSeconds animations:^(void){
            //                [tableView setContentOffset:offset animated:NO];
            //                }];
            UIView.animate(withDuration: 0.25) {
                //                self.messageView.tableView.setContentOffset(CGPoint.init(x: 0, y: currentOff.y - touchOffSet), animated: false)
                self.messageView.tableView.contentOffset = CGPoint.init(x: 0, y: currentOff.y - touchOffSet)
            }
            
        }else{
            self.messageView.tableView.scrollToTop()
        }
    }
    @objc func cancelRecord() {
        //        CODActionSheet.di
        AudioRecordManager.sharedInstance.cancelRrcord()
        self.recordKeyboared.recordStatus = .CODRecordInit
        self.isRecording = false
        self.recordKeyboared.isHidden = true
        self.recordLabel.isHidden = true
        self.messageView.snp.remakeConstraints{ (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(self.chatBar.snp.top)
        }
        self.messageView.scrollToBottomWithAnimation(animation: false)
        self.messageView.tableView.isUserInteractionEnabled = true
        self.chatBar.isUserInteractionEnabled = true
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil, userInfo:nil)
        self.dismisskeyboard()
    }
    
}

extension MessageViewController:CODMessageEditViewDelegate{
    func cancelMessageEidt() {
        
        self.editMessage = CODMessageModel()
        self.replyMessage = CODMessageModel()
        self.transMessage = CODMessageModel()
        self.transMessages = []
        CODChatListRealmTool.deleteSavedTransMsgs(chatId: self.chatId)
        self.editView.isHidden = true
        //        self.chatBar.textView.text = ""
        self.chatBar.isEdit = false
        try! Realm.init().write {
            self.chatListModel?.editMessage = nil
        }
        try! Realm.init().write {
            self.chatListModel?.replyMessage = nil
        }
        self.updateMessageView()

        self.view.layoutIfNeeded()
    }
    
    func reloadImageMessageEidt() {
        self.dismisskeyboard()
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let openAction = UIAlertAction.init(title: NSLocalizedString("相机", comment: ""), style: .default) { (action) in
            self.pushEidtUIImagePickerController()
        }
        
        let copyAction = UIAlertAction.init(title: NSLocalizedString("从相册中选择", comment: ""), style: .default) { (action) in
            
            self.pushEidtTZImagePickerController()
        }
        
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .cancel) { (action) in
            
        }
        
        alert.addAction(openAction)
        alert.addAction(copyAction)
        alert.addAction(cancelAction)
        
        UIViewController.current()?.present(alert, animated: true, completion: nil)
        
    }
    
    func clickEditView() {
        
        if self.replyMessage.msgID != "0" {
            self.messageView.messageDisplayViewVM.jumpToMessage(msgID: self.replyMessage.msgID)
        }
    }
    
}
extension MessageViewController:CODChatTopViewDelegate{
    func topViewAction(model: CODMessageModel) {
        //获取到回复消息在聊天列表数据源中的index
        
        if let indexPath = self.messageView.messageDisplayViewVM.findIndexPath(messageId: model.msgID) {
            
            if (self.messageView.tableView.indexPathsForVisibleRows?.contains(indexPath))! {
                
                if let cell = self.messageView.tableView.cellForRow(at: indexPath) as? CODBaseChatCell{
                    cell.flashingCell()
                }
                
            }else{
                self.messageView.messageDisplayViewVM.rpIndexPath.accept(indexPath)
                self.messageView.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
            
        } else {
            
            CODProgressHUD.showWithStatus(nil)
            
            var messgaId: String? = nil
            
            if self.chatListModel?.chatTypeEnum == .groupChat {
                messgaId = self.chatListModel?.groupChat?.topmsg
            } else if self.chatListModel?.chatTypeEnum == .channel {
                messgaId = self.chatListModel?.channelChat?.topmsg
            }
            
            if let messgaId = messgaId {
                CODMessageRealmTool.getRemoteMessageByMsgId(msgId: messgaId) { [weak self] (messageModel) in
                    
                    guard let `self` = self, let messageModel = messageModel else { return }
                    
                    self.messageView.messageDisplayViewVM.getHistoryList(beginTime: (messageModel.datetimeInt - self.messageView.offsetBeginTime).string, endTime: "\(self.messageView.messageDisplayViewVM.lastMessageDataTime - 1)") { [weak self] (VMs) in
                        
                        guard let `self` = self else { return }
                        
                        self.messageView.messageDisplayViewVM.appendChatCellVMs(cellVms: VMs)
                        CODProgressHUD.dismiss()
                        self.topViewAction(model: model)
                        
                    }
                }
            }
            
        }
        
        
    }
    
    func cancelTopMessage() {
        self.topMessage = CODMessageModel()
        
        let alertView = UIAlertView.init(title: "", message: NSLocalizedString("您确定要取消置顶此消息吗？", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("取消", comment: ""))
        alertView.addButton(withTitle: NSLocalizedString("取消置顶", comment: ""))
        alertView.show()
        
    }
}

extension MessageViewController:YBToolViewClickHandlerDelegate{
    
    func shareYBImageData(_ data: YBIBImageData) {
        if let  messageModel = CODMessageRealmTool.getMessageByMsgId(data.msgID ?? "") {
            let messageStatus: CODMessageStatus =  CODMessageStatus(rawValue: messageModel.status) ?? .Succeed
            if messageStatus == .Succeed {
                let shareView = CODShareImagePicker(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
                shareView.imageData = data
                shareView.contactListArr = CODGlobalDataSource.getContactGroupChannelModelData(isHeadCloudDisk: true, ignoreIDs: [NewFriendRosterID])
                shareView.msgID = data.msgID ?? ""
                
                if data.isKind(of: YBIBImageData.self) {
                    shareView.msgUrl = data.imageURL?.absoluteString ?? ""
                }
                
                if data.isKind(of: YBIBVideoData.self) {
                    shareView.msgUrl = data.thumbURL?.absoluteString ?? ""
                }
                
                if self.isCloudDisk {
                    shareView.fromType = .CloudDisk
                } else {
                    shareView.fromType = .Chat
                }
                
                shareView.show()
            }
        }
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
                    if currentPage == 0 || self.messageView.messageDisplayViewVM.imageData.count - CustomUtil.getMessageImageCount(msgID: messageModel.msgID)  <= 0 {
                        if self.messageView.messageDisplayViewVM.imageData.count - CustomUtil.getMessageImageCount(msgID: messageModel.msgID)  <= 0 || self.messageView.messageDisplayViewVM.imageData.count == 1  {
                            NotificationCenter.default.post(name: NSNotification.Name.init("kHideBrowser"), object: nil, userInfo: nil)
                        }
                    }
                }
            }
        }
    }
    
    func clickAtAction(jidStr:String?,model:CODMessageModel, cell: CODBaseChatCell) {
        
        guard let jid = jidStr else {
            return
        }
        
        if jid == UserManager.sharedInstance.jid || jid == UserManager.sharedInstance.loginName {
            let msgCtl = MessageViewController()
            msgCtl.chatType = .privateChat
            msgCtl.toJID = kCloudJid + XMPPSuffix
            msgCtl.chatId = CloudDiskRosterID
            msgCtl.title = NSLocalizedString("我的云盘", comment: "")
            UIViewController.current()?.navigationController?.pushViewController(msgCtl, animated: true)
            return
        }
        
        if jid == kAtAll {
            self.messageView.messageDisplayViewVM.cellTapAtAll(message: model, cell: cell)
        }else{
            
            let memberId = CODGroupMemberModel.getMemberId(roomId: model.roomId, userName: jid)
            if let contactModel = CODContactRealmTool.getContactByJID(by: jid) {
                
                if contactModel.isValid == true {
                    
                    CustomUtil.pushToPersonVC(contactModel: contactModel, messageModel: model)
                    
                }else{
                    
                    if CODChatListRealmTool.getChatList(id: model.roomId)?.groupChat?.isICanCheckUserInfo() ?? true == false  {
                        CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
                        return
                    }
                    
                    if let member = CODGroupMemberRealmTool.getMemberById(memberId){
                        CustomUtil.pushToStrangerVC(type: .groupType, memberModel: member)
                    }else{
                        
                        CustomUtil.pushToStrangerVC(type: .cardType, contactModel: contactModel)
                    }
                }
            }else{
                
                if CODChatListRealmTool.getChatList(id: model.roomId)?.groupChat?.isICanCheckUserInfo() ?? true == false  {
                    CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
                    return
                }
                
                CustomUtil.pushMemberInfoVC(memberId: memberId, jid: jid)
            }
        }
    }
    
}

extension MessageViewController: UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        
        if self.isCollection {
            self.isCollection = false
            return
        }
        
        if buttonIndex == 1{
            
            
            
            if self.chatType == .channel {
                //                let  dict:NSDictionary = ["name":COD_Setchannelsetting,
                //                                          "requester":UserManager.sharedInstance.jid,
                //                                          "itemID":self.roomId!,
                //                                          "setting":["topmsg":self.topMessage.msgID]]
                //
                //                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict)
                //                XMPPManager.shareXMPPManager.xmppStream.send(iq)
                XMPPManager.shareXMPPManager.channelSetting(roomID: self.roomId!.int!,topmsg:self.topMessage.msgID)
            }
            
            if self.chatType == .groupChat {
                let  dict:NSDictionary = ["name":COD_changeGroup,
                                          "requester":UserManager.sharedInstance.jid,
                                          "itemID":self.roomId!,
                                          "setting":["topmsg":self.topMessage.msgID]]
                
                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict)
                XMPPManager.shareXMPPManager.xmppStream.send(iq)
            }
            
            
        }else{
            self.updateTopMessage()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        CODRecentPhotoView.recentPhoto.dismissRecentPhoto()
    }
    
    class func pushVC(roomID: Int, type: CODMessageChatType) {
        
        
        if type == .groupChat {
            
            if let group = CODGroupChatRealmTool.getGroupChat(id: roomID) {
                
                let msgCtl = MessageViewController()
                msgCtl.title = group.getGroupName()
                msgCtl.chatId = group.roomID
                msgCtl.roomId = group.roomID.string
                msgCtl.chatType = .groupChat
                msgCtl.toJID = group.jid
                
                
                if let viewControllers = curViewController?.navigationController?.viewControllers {
                    
                    
                    var vcs: [UIViewController]  = Array()
                    
                    for i in 1...viewControllers.count {
                        let vc = viewControllers[i-1]
                        if vc.isKind(of: MessageViewController.self) {
                            break
                        }else{
                            vcs.append(vc)
                        }
                    }
                    vcs.append(msgCtl)
                    curViewController?.navigationController?.setViewControllers(vcs, animated: true)
                    
                }
            }
            
        }
    }
}
