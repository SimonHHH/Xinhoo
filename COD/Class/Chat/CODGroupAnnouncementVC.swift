//
//  CODGroupAnnouncementVC.swift
//  COD
//
//  Created by XinHoo on 2019/4/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupAnnouncementVC: BaseViewController {
    
    typealias UpdateGroupAnnounceBlock = (_ announceStr: String) -> Void
    
    var announceBlock: UpdateGroupAnnounceBlock?
    
    var groupChatId: Int!
    var myPower :Int!
    var noticeContent: CODNoticeContentModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("群公告", comment: "")
        self.view.backgroundColor = UIColor.white
        self.setBackButton()
        
        if myPower < 30{
            self.setRightTextButton()
            self.rightTextButton.setTitle(NSLocalizedString("编辑", comment: ""), for: UIControl.State.normal)
        }
        
        self.createDataSource()
        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    override func navRightTextClick() {
        //编辑
        let ctl = CODGroupAnnounceEditVC()
        ctl.groupChatId = self.groupChatId
        ctl.myPower = self.myPower
        ctl.delegate = self
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
    func createDataSource() {
        
        guard let noticeModel = noticeContent else {
            self.backGroundView.isHidden = false
            self.noticeBackGroundView.isHidden = true
            return
        }
        
        if noticeModel.notice.count <= 0 {
            self.backGroundView.isHidden = false
            self.noticeBackGroundView.isHidden = true
            return
        }

        self.backGroundView.isHidden = true
        self.noticeBackGroundView.isHidden = false
        self.textView.text = noticeModel.notice
//        self.iconImageView.sd_setImage(with: URL.init(string: noticeModel.userpic.getImageFullPath(imageType: 0)), placeholderImage: UIImage.init(named: "default_header_80"))
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: noticeModel.userpic) { (image) in
            self.iconImageView.image = image
        }
        self.titleLab.text = noticeModel.nameResult
        self.dateLab.text = Date.getTimeStrForTimeInterval(noticeModel.pulishdate)
    }
    
    func setUpUI() {
        self.view.addSubview(noticeBackGroundView)
        noticeBackGroundView.addSubview(iconImageView)
        noticeBackGroundView.addSubview(titleLab)
        noticeBackGroundView.addSubview(dateLab)
        noticeBackGroundView.addSubview(line)
        noticeBackGroundView.addSubview(textView)
        
        self.view.addSubview(backGroundView)
        backGroundView.addSubview(noneNoticeView)
        backGroundView.addSubview(tipsLab)
        
        noticeBackGroundView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(40)
        }
        titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.top.equalTo(iconImageView.snp.top).offset(7)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(16)
        }
        dateLab.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(4)
            make.width.equalTo(titleLab)
            make.height.equalTo(12)
        }
        line.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(0.5)
        }
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(21)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalToSuperview().offset(-83)
        }
        
        backGroundView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        tipsLab.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        noneNoticeView.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLab.snp.top).offset(-107)
            make.centerX.equalToSuperview()
        }
        
        
    }

    lazy var noticeBackGroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "default_header_80")
        icon.clipsToBounds = true
        icon.layer.cornerRadius = 20
        return icon
    }()
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 16.0)
        return lab
    }()
    
    lazy var dateLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12.0)
        lab.textColor = UIColor(hexString: kSubTitleColors)
        return lab
    }()
    
    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return line
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.isEditable = false
        return textView
    }()
    
    
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var noneNoticeView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "notice_none")
        return icon
    }()
    
    lazy var tipsLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 16.0)
        lab.numberOfLines = 0
        lab.textAlignment = .center
        lab.text = "管理员还没有发布群公告"
        lab.textColor = UIColor(hexString: kSubTitleColors)
        return lab
    }()
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CODGroupAnnouncementVC: GroupAnnounceDelegate {
    func setGroupAnnounceComplete(announceStr: String) {
        
        if announceStr.count > 0 {
            self.noticeBackGroundView.isHidden = false
            self.backGroundView.isHidden = true
            
            self.iconImageView.sd_setImage(with: URL.init(string: UserManager.sharedInstance.avatar!), placeholderImage: UIImage(named: "default_header_94"), options: [], completed: nil)
            
            self.titleLab.text = UserManager.sharedInstance.nickname
            self.textView.text = announceStr
            self.dateLab.text = Date.getTimeStrForNow()

        }else{
            self.backGroundView.isHidden = false
            self.noticeBackGroundView.isHidden = true
        }

        if let block = self.announceBlock {
            block(announceStr)
        }
    }
}
