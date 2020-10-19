//
//  Xinhoo_DiscoverViewController.swift
//  COD
//
//  Created by xinhooo on 2020/5/8.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: Xinhoo_DiscoverViewController {
    
    var spreadMessageCountBinder: Binder<Int> {
        return Binder(base) { (vc, value) in
            vc.friendCircleModel.reviewCount = value
        }
    }
    
    var circleFirstPicBinder: Binder<String> {
        return Binder(base) { (vc, value) in
            vc.friendCircleModel.contactPic = value
        }
    }
    
    
}

class Xinhoo_DiscoverViewController: BaseViewController {
    
    var iconModelArr = Array<[DiscoverCellModel]>()
    
    var friendCircleModel: DiscoverCellModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("发现", comment: "")
        
        self.initData()
        self.configView()
        self.setCircleRedPoint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tab = UIApplication.shared.delegate?.window??.rootViewController as? CODCustomTabbarViewController,tab.tabBar.isHidden  {
            tab.tabBar.isHidden = false
        }
        DiscoverHttpTools.getAndUpdateNewMoments()
        self.friendCircleModel.rxSendFailure.accept(self.isShowSendFailure())
    }
    
    func initData() {
        friendCircleModel = DiscoverCellModel(title: "朋友圈", imgName: "circle_friend_icon", type: .friendCircle, selector: { [weak self] in
            guard let `self` = self else { return }
            let vc = CODDiscoverHomeVC()
            self.navigationController?.pushViewController(vc)
        })
        
        iconModelArr = [
            [friendCircleModel]
            ,
            [DiscoverCellModel(title: "扫一扫", imgName: "discover_scan", type: .normal, selector: { [weak self] in
                guard let `self` = self else { return }
                
                let ctl = ScanViewController()
                self.navigationController?.pushViewController(ctl, animated: true)
            })]
            /*,
            [DiscoverCellModel(title: "表情商店", imgName: "stickers_store", type: .normal, selector: { [weak self] in
                ////提醒谁看
                guard let `self` = self else { return }
                let ctl = CreGroupChatViewController() ////提醒谁看
                ctl.ctlType = .friendsCcRemindRead
                ctl.maxSelectedCount = 10
                ctl.selectedRemindsSuccess = { [weak self] (contactList) in
                    self?.friendCircleModel.reviewCount = 999
                    self?.friendCircleModel.contactPic = "cc62fba4a19e43d898a0c1599c056400"
                }
                let nav = BaseNavigationController(rootViewController: ctl)
                nav.modalPresentationStyle = .overFullScreen
                self.present(nav, animated: true, completion: nil)
            })],
            [DiscoverCellModel(title: "谁可以看", imgName: "discover_scan", type: .normal, selector: { [weak self] in
                guard let `self` = self else { return }
                
                let ctl = CODCanReadViewController()
                let nav = BaseNavigationController(rootViewController: ctl)
                nav.modalPresentationStyle = .overFullScreen
                self.present(nav, animated: true, completion: nil)
            })]*/
        ]
    }

    func configView() {
        
        self.tableView.register(UINib(nibName: "DiscoverTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "discoverCell")
        
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.001))
        
        self.tableView.tableHeaderView = headView
    }
    
    func setCircleRedPoint() {
        
        UserManager.sharedInstance.rx.spreadMessageCount
            .bind(to: self.rx.spreadMessageCountBinder)
            .disposed(by: self.rx.disposeBag)
        
        UserManager.sharedInstance.rx.circleFirstPic
            .bind(to: self.rx.circleFirstPicBinder)
            .disposed(by: self.rx.disposeBag)

    }
    
    func isShowSendFailure() -> Bool {
        var count = 0
        count += CODDiscoverFailureAndSendingListModel.getFailureList().count
        count += CODDiscoverFailureAndSendingListModel.getMessageDeletedLikeFailList().count
        count += CODDiscoverFailureAndSendingListModel.getMessageDeletedCommentFailList().count
        return count > 0
    }
}

extension Xinhoo_DiscoverViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.iconModelArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.iconModelArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DiscoverTableViewCell = tableView.dequeueReusableCell(withIdentifier: "discoverCell", for: indexPath) as! DiscoverTableViewCell
        let model = self.iconModelArr[indexPath.section][indexPath.row]
        cell.titleLab.text = model.title
        cell.type = model.type
        cell.iconImageView.image = UIImage(named: model.imgName)
//        cell.contactPic = model.contactPic
        
        model.rxReviewCount.bind { (reviewCount) in
            cell.reviewCount = reviewCount
        }.disposed(by: cell.rx.prepareForReuseBag)
        
        model.rxContactPic.bind { [weak model] (conPic) in
            guard let model = model else { return }
            cell.setContactPicOrShowPromptIcon(contactPic: conPic, showPromptIcon: model.rxSendFailure.value)
        }.disposed(by: cell.rx.prepareForReuseBag)
        
        model.rxSendFailure.bind { [weak model] (isShowFailure) in
            guard let model = model else { return }
            cell.setContactPicOrShowPromptIcon(contactPic: model.rxContactPic.value, showPromptIcon: isShowFailure)
        }.disposed(by: cell.rx.prepareForReuseBag)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.iconModelArr[indexPath.section][indexPath.row].selectAction!()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 13.0
    }
    
}

import RxSwift
import RxCocoa
class DiscoverCellModel: NSObject {
    
    enum DiscoverCellType {
        case normal
        case friendCircle
    }
    
    typealias SelectAction = () -> Void
    
    var title = ""
    
    var imgName = ""
    
    let rxReviewCount: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    let rxContactPic: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let rxSendFailure = BehaviorRelay(value: false)
    
    var reviewCount = 0 {
        didSet {
            self.rxReviewCount.accept(self.reviewCount)
        }
    }
    
    var contactPic: String? = nil {
        didSet {
            self.rxContactPic.accept(self.contactPic)
        }
    }
    
    var type: DiscoverCellType = .normal
    
    var selectAction: SelectAction? = nil
    
    convenience init(title: String, imgName: String, type: DiscoverCellType, selector: @escaping SelectAction) {
        self.init()
        self.title = title
        self.imgName = imgName
        self.type = type
        self.selectAction = selector
    }
    
}
