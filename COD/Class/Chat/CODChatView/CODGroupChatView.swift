//
//  CODGroupChatView.swift
//  COD
//
//  Created by 1 on 2019/3/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit


private let topGap: CGFloat = 12.0
private let bottomGap: CGFloat = 12.0
private let sectionFooterGap: CGFloat = 31.0

private let itemSpace: CGFloat = 15

protocol CODGroupChatViewDelegate:class {
    func reloadHeight(height: CGFloat)
//    func reloadHeight(height: CGFloat,isNeedReload:Bool)

    
    func addMemberAction()
    
    func subtractMemberAction()
    
    func showMemberInformation(model: CODGroupMemberModel)
    
    func showMoreMembers()
}

class CODGroupChatView: UIView {
    
    private var viewHeight = 96
    
    var isAdmin = false
    
    var notInvit = false
    
    var itemCount = 0
    
    var isShowFooterView = false
    
    var type :CODMessageDetailVCType?
    
    weak var delegate: CODGroupChatViewDelegate?
    
    var notificationToken: NotificationToken? = nil
    
    deinit {
        print("CODGroupChatView -> release")
        notificationToken?.invalidate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        let realm = try! Realm.init()
        notificationToken = realm.objects(CODContactModel.self).observe({ (changes: RealmCollectionChange) in
            
            switch changes{
            
            case .initial(_):
                break
            case .update(_, _, _, let modifications):
                print(modifications)
                if let index = modifications.first {
                    self.updateMembers(index: index)
                }
                
                break
            case .error(_):
                break
            @unknown default:
                break
            }
        })
        
    }
    
    public var members = Array<CODGroupMemberModel>()

    
    private var lastCount = 1
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let CollectionViewCellID = "CODGroupChatCellID"
    
    //MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {[weak self] in
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: itemSpace, left: itemSpace, bottom: 0, right: itemSpace)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CODGroupChatCell.self, forCellWithReuseIdentifier: CollectionViewCellID)
        
        layout.footerReferenceSize = CGSize.init(width: KScreenWidth, height: 31.0)
        
        collectionView.register(CODMoreMemberCollectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterView")
        collectionView.setCollectionViewLayout(layout, animated: false)
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
    
    func setMembers(members: [CODGroupMemberModel], isAdmin: Bool, notInvit: Bool, type: CODMessageDetailVCType) {
        var membersTemp = Array<CODGroupMemberModel>()
        self.isAdmin = isAdmin
        self.type = type
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
        
        if itemCount > 20 {
            isShowFooterView = true
            layout.footerReferenceSize = CGSize.init(width: KScreenWidth, height: 31.0)
            
            for i in 0..<20-actionCount {
                let member = members[i]
                membersTemp.append(member)
            }
            
        }else{
            isShowFooterView = false
            layout.footerReferenceSize = CGSize.zero
            membersTemp = members
        }
        self.members = membersTemp
        
        collectionView.reloadData()
        self.reloadViewHeight()
    }
    
    func updateMembers(index: Int) {
        let results = try! Realm.init().objects(CODContactModel.self)
        let contact = results[index]
        
        if let typeTemp = self.type {
            if typeTemp == .commonChat {
                if let model = self.members.first {
                    model.nickname = contact.nick
                }
            }
        }
        
        collectionView.reloadData()
    }
}

private extension CODGroupChatView {
    
    func setupUI() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        collectionView.reloadData()
    }
    
    func reloadViewHeight() {
        
        var height = 96.0
        let viewhH = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        height = Double(viewhH + topGap + bottomGap)
        if self.delegate != nil{
            self.delegate?.reloadHeight(height:CGFloat(height))
        }
    }
    
}

extension CODGroupChatView: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if itemCount > 20 {
            return 20
        }else{
            return itemCount
        }
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
            if (self.delegate != nil) {
                self.delegate?.addMemberAction()
            }
        }else if indexPath.row == members.count + 1 { //减号
            if (self.delegate != nil) {
                self.delegate?.subtractMemberAction()
            }
        }else{
            if (self.delegate != nil) {
                let member = members[indexPath.row]
                self.delegate?.showMemberInformation(model: member)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let footerView: CODMoreMemberCollectionFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterView", for: indexPath) as! CODMoreMemberCollectionFooterView
        
        footerView.showMoreBlock = { [weak self] in
            if self?.delegate != nil {
                self?.delegate?.showMoreMembers()
            }
        }
        
        return footerView
    }
    
    

    
}
