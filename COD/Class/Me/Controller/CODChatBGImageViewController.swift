//
//  CODChatBGImageViewController.swift
//  COD
//
//  Created by xinhooo on 2019/4/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import MobileCoreServices

class CODChatBGImageViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var heightCos: NSLayoutConstraint!
    
    @IBOutlet weak var alab: UILabel!
    @IBOutlet weak var selectPhotoBtn: UIButton!
    var  pickImageController:UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alab.text = NSLocalizedString("主题", comment: "")
        self.setBackButton()
        self.navigationItem.title = NSLocalizedString("聊天背景", comment: "")
        self.collectionView.register(UINib.init(nibName: "CODChatBGImageCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CODChatBGImageCollectionViewCell")
        // Do any additional setup after loading the view.
        let w : CGFloat = (KScreenWidth-16-26)/3
        let h : CGFloat = w*180/110
        self.heightCos.constant = 2 * h + 40
        
        selectPhotoBtn.setBackgroundImage(UIImage(color: UIColor.gray, size: CGSize.init(width: KScreenWidth, height: 43)), for: .highlighted)
    }

    
    /// 从手机相册选择背景图片
    ///
    /// - Parameter sender: 点击按钮
    @IBAction func gotoPhotoAlbumAction(_ sender: Any) {
        self.openAblum()
    }

    
    func openAblum(){
        weak var weakSelf=self
        
        pickImageController=UIImagePickerController.init()
        //savedPhotosAlbum是根据日期排列，photoLibrary是所有相册
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            CODPermissions.authorizePhotoWith { [weak self] (granted) in
                
                if granted {
                    let tzImgPicker = CustomUtil.getImagePickController(maxImagesCount: 1, delegate: self)
                    tzImgPicker?.isSelectOriginalPhoto = false
                    tzImgPicker?.allowPickingOriginalPhoto = false
                    tzImgPicker?.allowTakePicture = false
                    tzImgPicker?.allowTakeVideo  = false
                    tzImgPicker?.allowCameraLocation = false
                    tzImgPicker?.allowPickingVideo = false
                    tzImgPicker?.delegate = self
                    self?.present(tzImgPicker ?? UIViewController.init(), animated: true, completion: nil)
                }else{
                    let alert = UIAlertController.init(title: "请授权访问", message: String.init(format: "%@ 需要访问照片才能发送图片或视频，\n\n请前往「设置-隐私-照片」中打开%@ 的开关。", kApp_Name,kApp_Name), preferredStyle: .alert)
                    alert.addAction(title: "好", style: .default, isEnabled: true, handler: { (action) in
                        
                    })
                    alert.addAction(title: "设置", style: .default, isEnabled: true, handler: { (action) in
                        
                        let url = URL.init(string: UIApplication.openSettingsURLString)
                        if UIApplication.shared.canOpenURL(url!) {
                            UIApplication.shared.open(url!, options: [:], completionHandler: { (success) in
                            })
                        }
                        
                    })
                    self?.present(alert, animated: true, completion: nil)
                }

            }
        }
    }
    
    deinit {
        print("页面销毁")
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

extension CODChatBGImageViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        

        let collectionCell:CODChatBGImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CODChatBGImageCollectionViewCell", for: indexPath) as! CODChatBGImageCollectionViewCell
        
        collectionCell.bgImageView.image = UIImage.init(named: String.init(format: "bg_img_%ld.jpg", indexPath.row))
        let chatBGStr = UserDefaults.standard.object(forKey: kChat_BGImg) as! String
        
        if CODDownLoadManager.sharedInstance.isCustomBgImg() {
            collectionCell.selectImageView.isHidden = true
        }else{
            collectionCell.selectImageView.isHidden = (chatBGStr != String.init(format: "bg_img_%ld.jpg", indexPath.row))
        }
        
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if CODDownLoadManager.sharedInstance.isCustomBgImg() {
            CODDownLoadManager.sharedInstance.removeBgImg()
        }
        
        UserDefaults.standard.set(String.init(format: "bg_img_%ld.jpg", indexPath.row), forKey: kChat_BGImg)
        UserDefaults.standard.synchronize()
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w : CGFloat = (KScreenWidth-16-26)/3
        let h : CGFloat = w*180/110
        return CGSize.init(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 15, left: 8, bottom: 15, right: 8)
    }
}

extension CODChatBGImageViewController:UINavigationControllerDelegate,TZImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        print("\(String(describing: photos))")
        if photos.count > 0 {
            for image in photos {
                CODDownLoadManager.sharedInstance.saveBgImg(bgImage: image)
            }
        }
        UserDefaults.standard.set(String.init(format: "bg_img_%ld.jpg", 0), forKey: kChat_BGImg)
        UserDefaults.standard.synchronize()
        self.collectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
