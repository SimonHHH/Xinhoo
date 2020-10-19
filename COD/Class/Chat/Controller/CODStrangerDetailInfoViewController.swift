//
//  CODStrangerDetailInfoViewController.swift
//  COD
//
//  Created by xinhooo on 2019/4/23.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODStrangerDetailInfoViewController: BaseViewController {

    enum From:Int {
        case Unknow = 0
        case Group  ///群组
        case QRScan ///二维码搜索
        case Search ///用户搜索
        case Card   ///名片

    }
    
    var jid = ""
    var name = ""
    var userName = ""
    var gender = ""
    var userPic = ""
    var from:From = CODStrangerDetailInfoViewController.From(rawValue: 0)!
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var remarkNameLab: UILabel!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var nickNameLab: UILabel!
    @IBOutlet weak var fromLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("详细资料", comment: "")
        self.setBackButton()
        self.configView()
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapMessageView(gestureRecognizer:)))
        self.headImageView.addGestureRecognizer(tap)
        self.headImageView.isUserInteractionEnabled = true
        
//        CustomUtil.removeHeaderImageCahch(picID: self.userPic)
        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: self.userPic ) { (image) in
            self.headImageView.image = image
        }
    }

    @objc public func tapMessageView(gestureRecognizer:UITapGestureRecognizer){
        let url =  URL.init(string: (self.userPic.getHeaderImageFullPath(imageType: 2)))
        let tumbUrl =  URL.init(string: (self.userPic.getHeaderImageFullPath(imageType: 1)))
        CustomUtil.removeImageCahch(imageUrl: self.userPic.getHeaderImageFullPath(imageType: 2))

//        let photoIndex: Int = 0
        let imageData: YBIBImageData = YBIBImageData()
//        imageData.projectiveView = self.headImageView
        imageData.imageURL = url
        imageData.thumbURL = tumbUrl
        let browser:YBImageBrowser =  YBImageBrowser()
        browser.dataSourceArray = [imageData]
//        browser.currentPage = photoIndex
        browser.show()
    }
    
    func configView() {
        
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: self.userPic) { (image) in
            self.headImageView.image = image
        }
        self.remarkNameLab.text = self.name
        self.nickNameLab.text = NSLocalizedString("用户名：", comment: "") + self.userName
        
        switch self.from {
        case .Unknow:
            self.fromLab.text = NSLocalizedString("未知", comment: "")
        case .Group:
            self.fromLab.text = NSLocalizedString("群组", comment: "")
        case .QRScan:
            self.fromLab.text = NSLocalizedString("二维码", comment: "")
        case .Search:
            self.fromLab.text = NSLocalizedString("用户搜索", comment: "")
        case .Card:
            self.fromLab.text = NSLocalizedString("名片", comment: "")
        default:
            self.fromLab.text = NSLocalizedString("", comment: "")
            break
        }
        
    }

    @IBAction func addFriendsAction(_ sender: Any) {
        
        let model = CODChatPersonModel()
        model.username = self.userName
        model.name = self.name
        
        let verificationVC = CODVerificationApplicationVC()
        verificationVC.model =  model
        self.navigationController?.pushViewController(verificationVC)
        
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
