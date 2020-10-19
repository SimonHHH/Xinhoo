//
//  CODDiscoverHomeCellNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

class CODDiscoverHomeCellNode: CODCellNode, ASCellNodeDataSourcesType {
    
    var headerNode: CODImageNode!
    var nickNameNode: ASButtonNode!
    @_NodeLayout var contentNode: CODDiscoverHomeContextNode?
    
    var imageNode: CODDiscoverHomeGirdImageNode?
    
    var videoNode: CODDiscoverHomeVideoNode?
    
    var timeNode: ASTextNode2!
    
    var funcBtnNode: CODHitScaleButtonNode?
    
    var deleteBtnNode: ASButtonNode?
    
    var localNode: ASButtonNode?
    
    var showAllContentNode: ASButtonNode?
    
    var showAllTitle = "全文"
    
    var atTipNode: ASTextNode2?
    
    var checkLimitNode: ASButtonNode?
    
    var commentBg: ASDisplayNode!
    
    var resendBtn: ASButtonNode?
    
    var openTipTextNode: ASButtonNode?
    
    var presonalBtnNode: ASButtonNode?
    
    @_NodeLayout var commentListNode: CODDiscoverCommentListNode?
    
    lazy var moreMenu: DiscoverMoreMenuView = {
        
        let moreMenu = DiscoverMoreMenuView()
        
        moreMenu.clickLike = { [weak self] in
            
            guard let `self` = self else { return }
            self.onClickLike()
            
        }
        
        moreMenu.clickComment = { [weak self] in
            
            guard let `self` = self else { return }
            
            self.onClickComment()
            
        }
        
        return moreMenu
    }()
    
    var vm: CODDiscoverHomeCellVM {
        return self.cellVM as! CODDiscoverHomeCellVM
    }
    
    weak var pageVM: CODDiscoverHomePageVM?
    
    override init() {
        super.init()
    }
    
    func onClickLike() {
        
        guard let indexPath = self.indexPath else { return }
        
        if self.vm.isLike {
            self.pageVM?.dislike(indexPath: indexPath)
        } else {
            self.pageVM?.like(indexPath: indexPath)
        }
        
    }
    
    func onClickComment() {
        
        guard let indexPath = self.indexPath else { return }
        
        let rect = self.convert(self.bounds, to: nil)
        self.pageVM?.srcollOffset(offset: rect.maxY)
        self.pageVM?.comment(indexPath: indexPath, replayUser: "")
        
    }
    
    required init(_ cellVM: ASTableViewCellVM) {
        super.init(cellVM)
        
        selectionStyle = .none
        
        headerNode = CODImageHeaderNode(url: vm.headerUrl)
        headerNode.style.preferredSize = CGSize(width: 42, height: 42)
        
        
        nickNameNode = ASButtonNode(text: vm.nickName, font: UIFont.boldSystemFont(ofSize: 17), textColor: UIColor(hexString: "#007EE5"))
        nickNameNode.titleNode.maximumNumberOfLines = 1
        
        if let text = vm.text {
            
            contentNode = CODDiscoverHomeContextNode(text: text)
                .foregroundColor(UIColor(hexString: "#333333"))
                .font(UIFont.systemFont(ofSize: 17))
                .lineCount(count: 6)
            
            contentNode?.rx.observe(\.realLineCount)
                .distinct().filterNil()
                .bind(to: self.rx.realLineCountBinder)
                .disposed(by: self.rx.disposeBag)
            
        }
        
        if let atAttr = vm.atAttr {
            atTipNode = ASTextNode2(attributedText: atAttr)
        }
        
        if vm.showCheckLimit {
            checkLimitNode = ASButtonNode(image: UIImage(named: "circle_Roster"))
        }
        
        
        if let video = vm.model?.video?.detached() {
            videoNode = CODDiscoverHomeVideoNode(videoInfo: video)
            videoNode?.msgID = vm.msgId
        }
        
        timeNode = ASTextNode2(text: vm.createTime)
            .font(UIFont.systemFont(ofSize: 14))
            .foregroundColor(UIColor(hexString: "#B3B3B3"))
        
        if vm.model?.allowReviewAndLike ?? false && vm.model?.msgPrivacyTypeEnum != .Private {
            funcBtnNode = CODHitScaleButtonNode(image: UIImage(named: "circle_more"))
        }
        
        if vm.model?.allowReviewAndLikePublic ?? false {
            
            openTipTextNode = ASButtonNode()
            openTipTextNode?.contentSpacing = 2
            openTipTextNode?.setImage(UIImage(named: "can_public_comment_icon"), for: .normal)
            openTipTextNode?.setTitle(NSLocalizedString("评论公开", comment: ""), with: UIFont.systemFont(ofSize: 13), with: UIColor(hexString: "#496CB8"), for: .normal)
        }
        
        
        if vm.model?.msgPrivacyTypeEnum == .Private {
            
            presonalBtnNode = ASButtonNode()
            presonalBtnNode?.setImage(UIImage(named: "circle_personal_icon"), for: .normal)
            presonalBtnNode?.setTitle(NSLocalizedString("私密", comment: ""), with: UIFont.systemFont(ofSize: 13), with: UIColor(hexString: "#B3B3B3")!, for: .normal)
            presonalBtnNode?.imageAlignment = .beginning
            presonalBtnNode?.contentSpacing = 2
            
        }
        
        if vm.canDelete {
            deleteBtnNode = ASButtonNode(text: NSLocalizedString("删除", comment: ""), font: UIFont.systemFont(ofSize: 14), textColor: UIColor(hexString: "#496CB8"))
        }
        
        if vm.model?.imageList.count ?? 0 > 0 {
            imageNode = CODDiscoverHomeGirdImageNode(imageList: vm.model?.imageList.detached().toArray() ?? [])
            imageNode?.msgID = vm.msgId
        }
        
        if let locationInfo = vm.locationInfo {
            localNode = ASButtonNode(text: locationInfo.name, font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: UIColor(hexString: "#496CB8"))
            localNode?.contentHorizontalAlignment = .left
        }
        
        if vm.model?.statusEnum == .Failure {
            createResendBtn()
        }
        
        showAllContentNode = ASButtonNode(text: showAllTitle, font: UIFont.systemFont(ofSize: 17), textColor: UIColor(hexString: "#1D49A7"))
        
        
        
    }
    
    func createResendBtn() {
        
        resendBtn = DiscoverUITools.createResendTipButton()
        
        createCommentbackground()
        
    }
    
    @objc func resendMessage() {
        
        guard let model = vm.model else {
            return
        }
        
        if !CODWebRTCManager.whetherConnectedNetwork() {
            return
        }
        
        CirclePublishTool.share.publishCircleWithDiscoverMessageModel(model: model)
        
    }
    
    func createCommentbackground() {
        
        commentBg = ASDisplayNode()
        commentBg.backgroundColor = UIColor(hexString: kVCBgColorS)
        
    }
    
    func reloadLikerNode(indexPath: IndexPath? = nil) {
        
        guard let model = vm.model, let pageVM = self.pageVM else {
            return
        }
        
        commentListNode = nil
        
        if model.likerList.count <= 0 && model.replyList.count <= 0 {
            return
        }
        
        
        var newIndexPath: IndexPath? = indexPath
        
        if newIndexPath == nil {
            newIndexPath = self.indexPath
        }
        
        createCommentbackground()
        
        commentListNode = CODDiscoverCommentListNode(likerList: model.likerList.detached().toArray(), commentList:model.replyList.detached().toArray(), pageVM: pageVM, indexPath: newIndexPath)
        
    }
    
    func configPageVM(pageVM: Any?, indexPath: IndexPath) {
        
        guard let pageVM = pageVM as? CODDiscoverHomePageVM else {
            return
        }
        
        
        self.pageVM = pageVM
        
        self.pageVM?.likePR.bind(to: self.rx.likeBinder)
            .disposed(by: self.rx.disposeBag)
        
        self.reloadLikerNode(indexPath: indexPath)
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        
        return LayoutSpec {
            
            HStackLayout(alignItems: .start) {
                
                /// 头像
                headerNode
                    .padding(.right, 10)
                
                VStackLayout() {
                    
                    /// 昵称
                    nickNameNode
                        .flexShrink(1)
                        .padding(.bottom, 10)
                        .alignSelf(.start)
                    
                    /// 文本
                    contentNode?
                        .padding(.top, -2)
                        .padding(.bottom, 10)
                    
                    /// 全文/收起
                    if contentNode?.realLineCount ?? 0 > 6 {
                        
                        showAllContentNode?
                            .title(title: showAllTitle)
                            .padding(.bottom, 10)
                            .alignSelf(.start)
                        
                    }
                    
                    /// 图片
                    imageNode?
                        .padding(.bottom, 10)
                        .alignSelf(.start)
                    
                    /// 视频
                    videoNode?
                        .padding(.bottom, 10)
                        .alignSelf(.start)
                    
                    
                    /// 提到我
                    atTipNode?
                        .flexShrink(1)
                        .padding(.bottom, 10)
                    
                    HStackLayout(justifyContent: .spaceBetween) {
                        
                        VStackLayout() {
                            
                            /// 定位地址
                            localNode?.padding(.bottom, 6).alignSelf(.start)
                            
                            HStackLayout(spacing: 24, justifyContent: .spaceBetween) {
                                
                                /// 发布时间
                                timeNode
                                
                                /// 限制谁可见
                                checkLimitNode
                                
                                /// 删除
                                deleteBtnNode
                                
                            }
                            
                            
                        }
                        .alignSelf(.center)
                        
                        
                        HStackLayout(alignItems: .center) {
                            
                            HSpacerLayout(minLength: 0)
                            
                            /// 私密
                            presonalBtnNode
                            
                            /// 公开提示
                            openTipTextNode?
                                .padding(.right, 8)
                            
                            
                            /// 更多功能按钮（点赞/评论）
                            funcBtnNode
                        }
                        .alignSelf(.start)
                        
                        
                        
                    }
                    .padding(.bottom, 10)
                    
                    
                    // 评论
                    commentListNode?
                        .background(commentBg)
                        .padding(.top, 5)
                        .padding(.bottom, 15)
                    
                    // 重发按钮
                    resendBtn?
                        .height(30)
                        .padding(.left, 10)
                        .background(commentBg)
                        .padding(.top, 5)
                        .padding(.bottom, 15)
                    
                    
                    
                    
                    
                }
                .flexShrink(1)
                .flexGrow(1)
                
            }
            .padding(.top, 15)
            .padding(.left, 12)
            .padding(.right, 15)
            .width(kScreenWidth)
            
            
            
        }
        
    }
    
    @objc func onClickShowMore(button: ASButtonNode) {
        
        self.moreMenu.isLike = vm.isLike
        
        if vm.model?.statusEnum == CODDiscoverMessageModel.StatusType.Succeed {
            self.moreMenu.commentBtn.isEnabled = true
            self.moreMenu.likeBtn.isEnabled = true
        } else {
            self.moreMenu.commentBtn.isEnabled = false
            self.moreMenu.likeBtn.isEnabled = false
        }
        
        
        self.moreMenu.show(form: button.view)
        
    }
    
    @objc func onClickShowAll() {
        
        ///收起
        if contentNode?.realLineCount == contentNode?.numberOfLines {
            
            showAllTitle = NSLocalizedString("全文", comment: "")
            _ = contentNode?.lineCount(count: 6)
            
        } else {
            
            showAllTitle = NSLocalizedString("收起", comment: "")
            _ = contentNode?.lineCount(count: contentNode?.realLineCount ?? 0)
            
        }
        
        setNeedsLayout()
        
    }
    
    
    @objc func deleteMessage() {
        
        guard let indexPath = self.indexPath else {
            return
        }
        
        pageVM?.deleteMessage(indexPath: indexPath)
        
        
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        if commentBg != nil {
            commentBg.view.cornerRadius = 4
        }
        
        guard let indexPath = self.indexPath else {
            return
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return
        }
        
        self.view.addBorder(toSide: .top, withColor: UIColor(hexString: "#E5E5E5")!)
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        headerNode.view.cornerRadius = 21
        
        deleteBtnNode?.addTarget(self, action: #selector(deleteMessage), forControlEvents: .touchUpInside)
        funcBtnNode?.addTarget(self, action: #selector(onClickShowMore(button:)), forControlEvents: .touchUpInside)
        headerNode.addTarget(self, action: #selector(onClickHeader), forControlEvents: .touchUpInside)
        nickNameNode.addTarget(self, action: #selector(onClickHeader), forControlEvents: .touchUpInside)
        showAllContentNode?.addTarget(self, action: #selector(onClickShowAll), forControlEvents: .touchUpInside)
        resendBtn?.addTarget(self, action: #selector(resendMessage), forControlEvents: .touchUpInside)
        checkLimitNode?.addTarget(self, action: #selector(gotoCanReadList), forControlEvents: .touchUpInside)
        localNode?.addTarget(self, action: #selector(gotoLocalVC), forControlEvents: .touchUpInside)
        
        
        if let model = vm.model {
            
            model.rx.observe(\.status).skip(1).filterNil()
                .distinct()
                .map { CODDiscoverMessageModel.StatusType(rawValue: $0) ?? CODDiscoverMessageModel.StatusType.Succeed }
                .bind(to: self.rx.failureBinder)
                .disposed(by: self.rx.disposeBag)
            
            
            Observable.merge([
                Observable.arrayWithChangeset(from: model.replyList).mapTo(Void()),
                Observable.arrayWithChangeset(from: model.likerList).mapTo(Void())
            ])
                .skip(1)
                .bind { [weak self] (_) in
                    guard let `self` = self else { return }
                    self.reloadLikerNode()
                    self.setNeedsLayout()
            }
            .disposed(by: self.rx.disposeBag)
            
        }
        
        
    }
    
    @objc func onClickHeader() {
        
        
        self.pageVM?.goToPersonInfo(jid: vm.model?.senderJid ?? "")
        
    }
    
    @objc func gotoLocalVC() {
        
        guard let localInfo = self.vm.model?.localInfo else {
            return
        }
        
        let locationVC = CODLocationDetailVC()
        locationVC.locationModel = localInfo
        
        UIViewController.current()?.navigationController?.pushViewController(locationVC)
        
    }
    
    @objc func gotoCanReadList() {
        
        guard let model = vm.model else {
            return
        }
        
        var readType: CODCanReadListViewModel.CanReadType = .read
        
        switch model.msgPrivacyTypeEnum {
        case .LimitVisible:
            readType = .read
        case .LimitInVisible:
            readType = .unread
        default:
            return
        }
        
        let vc = CODCanReadListViewController(readType: readType, jids: vm.model?.somePeople.toArray() ?? [])
        
        UIViewController.current()?.navigationController?.pushViewController(vc)
        
    }
    
}
