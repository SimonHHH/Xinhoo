//
//  CODGroupMembersVC.swift
//  COD
//
//  Created by XinHoo on 2019/7/9.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

private let topGap: CGFloat = 12.0
private let bottomGap: CGFloat = 12.0
private let itemSpace: CGFloat = 15

class CODGroupMembersVC: BaseViewController {
    
    var chatId = 0
    
    var isAdmin = false
    
    var notInvit = false
    
    var itemCount = 0
    
    var notificationToken: NotificationToken? = nil
    
    var members = Array<CODGroupMemberModel>()
    
    private let CollectionViewCellID = "CODGroupChatCellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupMember), name: NSNotification.Name.init(rawValue: kNotificationUpdateGroupMember), object: nil)
        
        self.navigationItem.title = NSLocalizedString("群成员", comment: "")
        self.setBackButton()
        
        setupUI()
        self.setMembers(members: self.members, isAdmin: self.isAdmin, notInvit: self.notInvit)

        // Do any additional setup after loading the view.
    }
    
    //MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.layout)
        collectionView.contentInset = UIEdgeInsets(top: itemSpace, left: itemSpace, bottom: 0, right: itemSpace)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentSize = CGSize.init(width: KScreenWidth, height: KScreenHeight)
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CODGroupChatCell.self, forCellWithReuseIdentifier: CollectionViewCellID)
        return collectionView
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = itemSpace
        layout.minimumInteritemSpacing = itemSpace
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 53, height: 72)
        return layout
    }()
    
    func setMembers(members: [CODGroupMemberModel], isAdmin: Bool, notInvit: Bool) {
        
        self.members = members
        self.isAdmin = isAdmin
        self.notInvit = notInvit
        
        var actionCount = 0
        if members.count <= 1 {
            actionCount = 2
        } else {
            if self.notInvit {
                if self.isAdmin {
                    actionCount = 2
                } else {
                    actionCount = 0
                }
            }else{
                if self.isAdmin {
                    actionCount = 2
                } else {
                    actionCount = 1
                }
            }
        }
        
        itemCount = members.count + actionCount
        collectionView.reloadData()
    }
    
    func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
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

extension CODGroupMembersVC: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellID, for: indexPath) as! CODGroupChatCell
        if indexPath.row == members.count {
            item.headerImage = UIImage.init(named: "add_person")
            item.nameString = ""
        }else if indexPath.row == members.count + 1 {
            item.headerImage = UIImage.init(named: "reduceicon")
            item.nameString = ""
        }else{
            let member = members[indexPath.row]
            if member.jid == UserManager.sharedInstance.jid {
                item.isUserInteractionEnabled = false
            }else{
                item.isUserInteractionEnabled = true
            }
            if member.userpic.contains(UIImage.getHelpIconName()) {
                item.headerImage = UIImage.helpIcon()
            }else{
                item.urlStr = member.userpic
            }
            item.nameString = member.getMemberNickName()
        }
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == members.count { //加号
            addMemberAction()
        }else if indexPath.row == members.count + 1 { //减号
            subtractMemberAction()
        }else{
            let member = members[indexPath.row]
            showMemberInformation(model: member)
        }
    }

    
}

extension CODGroupMembersVC {
    
    @objc func updateGroupMember() {
        dispatch_async_safely_to_main_queue {
            self.members.removeAll()
            let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId)
            if let members = groupModel?.member {
                let membersTemp = members.sorted(byKeyPath: "userpower", ascending: true)
                for member in membersTemp {
                    self.members.append(member)
                    // 判断自己是否群主
                    if member.userpower == 10 {
                        if member.username == UserManager.sharedInstance.loginName {
                            self.isAdmin = true
                        }
                    }
                }
            }
            self.setMembers(members: self.members, isAdmin: self.isAdmin, notInvit: groupModel?.notinvite ?? false)
        }
    }
    
    func addMemberAction() {
        
        guard let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId) else {
            return
        }
        
        let ctl = CreGroupChatViewController()
        ctl.ctlType = .addMember
        ctl.groupChatModel = groupModel
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
    func subtractMemberAction() {
        
        
        if self.members.count <= 1 {
            CODProgressHUD.showErrorWithStatus("没有可移除的群成员")
        }else{
            
            guard let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.chatId) else {
                return
            }
            
            let ctl = CreGroupChatViewController()
            ctl.ctlType = .subtractMember
            ctl.groupChatModel = groupModel
            self.navigationController?.pushViewController(ctl, animated: true)
        }
    }
    
    func showMemberInformation(model: CODGroupMemberModel) {
        if model.username.contains("cod_60000000") {
            self.navigationController?.pushViewController(CODLittleAssistantDetailVC())
            return
        }
        if model.jid == UserManager.sharedInstance.jid {
            return
        }
        if let contactModel = CODContactRealmTool.getContactByJID(by: model.jid), contactModel.isValid == true  {
            CustomUtil.pushToPersonVC(contactModel: contactModel, memberModel: model)
            
        }else{
            CustomUtil.pushToStrangerVC(type: .groupType, memberModel: model)
        }
    }
}
