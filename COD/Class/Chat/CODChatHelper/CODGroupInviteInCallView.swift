//
//  CODGroupInviteInCallView.swift
//  COD
//
//  Created by 1 on 2020/9/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
protocol CODGroupInviteInCallViewDelegate:NSObjectProtocol
{
    func cancelCallClick()
    func joinCallClick()
}
class CODGroupInviteInCallView: UIView {
    
    weak var delegate:CODGroupInviteInCallViewDelegate?

    fileprivate lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("是否加入语音通话？", comment: "")
        return titleLabel;
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CODGroupInviteInCallCell.self, forCellWithReuseIdentifier: "CODGroupInviteInCallCell_identity")
        return collectionView
    }()
    
    fileprivate lazy var cancelButton: UIButton = {
        var cancelBtn = UIButton.init(type: UIButton.ButtonType.custom)
        cancelBtn.frame  = CGRect(x: 0, y: 0, width: 70, height: 40)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelBtn.setTitle(NSLocalizedString("取消", comment: ""), for: UIControl.State.normal)
        cancelBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        cancelBtn.addTarget(self, action: #selector(cancelClick), for: UIControl.Event.touchUpInside)
        return cancelBtn
    }()

    fileprivate lazy var joinButton: UIButton = {
        var joinBtn = UIButton.init(type: UIButton.ButtonType.custom)
        joinBtn.frame  = CGRect(x: 0, y: 0, width: 70, height: 40)
        joinBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        joinBtn.setTitle(NSLocalizedString("加入", comment: ""), for: UIControl.State.normal)
        joinBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        joinBtn.addTarget(self, action: #selector(joinClick), for: UIControl.Event.touchUpInside)
        return joinBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        self.setUpView()
    }
      
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
    func setUpView() {
        
        let topLine = self.createLineView()
        let centerLine = self.createLineView()
        let bottomLine = self.createLineView()
      
        self.addSubviews([self.titleLabel,self.collectionView,topLine,centerLine,bottomLine,self.cancelButton,self.joinButton])
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(19)
            make.right.left.equalToSuperview()
            make.height.equalTo(24)
        }
        
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(KScreenWidth - 20)
            make.width.equalTo(190)
            make.height.greaterThanOrEqualTo(30)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.bottom.equalToSuperview()
            make.width.equalTo((KScreenWidth-0.5)/2)
            make.height.equalTo(49)
        }
        
        joinButton.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.width.equalTo((KScreenWidth-0.5)/2)
            make.bottom.equalToSuperview()
            make.height.equalTo(49)
        }
        
        topLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(self.cancelButton.snp.top)
        }
                
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        centerLine.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(0.5)
            make.top.equalTo(topLine.snp.bottom)
            make.bottom.equalTo(bottomLine.snp.top)
        }
    }
    
    func createLineView() -> UIView{
        let lineView = UIView()
        lineView.backgroundColor = UIColor(hexString: "#B2B2B2")
        return lineView
    }
    
    @objc func cancelClick() {
        
        if self.delegate != nil {
            self.delegate?.cancelCallClick()
        }
        
    }
    
    @objc func joinClick() {
        if self.delegate != nil {
            self.delegate?.joinCallClick()
        }
        
    }

}

extension CODGroupInviteInCallView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{

        return 5
    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CODGroupInviteInCallCell_identity", for: indexPath) as? CODGroupInviteInCallCell
        if cell == nil {
            cell = CODGroupInviteInCallCell(frame: .zero)
        }

        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:30, height: 30)
    }
    
}
