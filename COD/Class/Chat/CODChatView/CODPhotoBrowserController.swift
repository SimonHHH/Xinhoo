//
//  CODPhotoBrowserController.swift
//  COD
//
//  Created by 周波 on 2/20/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
class CODPhotoBrowserController: UIViewController,UIScrollViewDelegate {
    
    ///图片数组
    var recentImage = UIImage()
    var photoAsset = PHAsset()
    var isOriginal = false
    var imageData: Data? = Data()
    
    ///当前页码
    var currentPage = 0
    typealias SendImage = (_ image: UIImage, _ imageData: Data, _ isOriginal: Bool) -> Void ///选择文件
    public var sendImageBlock:SendImage?
 
    lazy var topToolBar: UIView = {
        let toolBarHeight: CGFloat = kNavBarHeight + kSafeArea_Top
        let topToolBar = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: toolBarHeight))
        topToolBar.backgroundColor =  UIColor.init(white: 0, alpha: 0.5)
//        topToolBar.alpha = 0.7
        return topToolBar
    }()
    
    lazy var bottomToolBar: UIView = {
        let toolBarHeight: CGFloat = 44 + kSafeArea_Bottom
        let bottomToolBar = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - toolBarHeight, width: UIScreen.main.bounds.size.width, height: toolBarHeight))
        bottomToolBar.backgroundColor =  UIColor.init(white: 0, alpha: 0.7)
        return bottomToolBar
    }()
    lazy var backButton: UIButton = {
        var backbtn = UIButton.init(type: UIButton.ButtonType.custom)
        backbtn.frame  = CGRect(x: 20, y: 0, width: 70, height: 40)
//        backbtn.setImage(UIImage(named: "button_nav_back"), for: UIControl.State.normal)
        backbtn.setTitle("取消", for: UIControl.State.normal)
        backbtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        backbtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        backbtn.addTarget(self, action: #selector(navBackClick), for: UIControl.Event.touchUpInside)
        backbtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        return backbtn
    }()
    lazy var eidtBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.backgroundColor = UIColor.clear
        btn.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        btn.setTitle("编辑", for: UIControl.State.normal)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        btn.isHidden = true
        return btn
    }()

    lazy var originalBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.backgroundColor = UIColor.clear
        btn.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        btn.setTitle(NSLocalizedString("原图", comment: ""), for: UIControl.State.normal)
        btn.setImage(UIImage.init(named: "original_select"), for: .normal)
        btn.setImage(UIImage.init(named: "original_selected"), for: .selected)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.CODButtonImageTitle(style: .left, titleImgSpace: 5)
//        btn.isHidden = true
        return btn
    }()
    lazy var sendBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.backgroundColor = UIColor.clear
        btn.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        btn.setTitle("发送", for: UIControl.State.normal)
        btn.setTitleColor(UIColor.init(hexString: "#007EE5"), for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        return btn
    }()

    lazy var pageLabel: UILabel = {
        let lab = UILabel()
        lab.frame = CGRect(origin: CGPoint(), size: CGSize(width: 100, height: 30))
        lab.textColor = UIColor.white
        lab.textAlignment = .center
        lab.font = UIFont.boldSystemFont(ofSize: 17.0)

        return lab
    }()
    lazy var scrollView: UIScrollView = {
          let scroll = UIScrollView()
          scroll.minimumZoomScale = 1.0
          scroll.maximumZoomScale = 3.0 //不设置范围，缩放不起作用
          scroll.delegate = self
          return scroll
      }()
    lazy var imageView: UIImageView = {
          let iv = UIImageView()
          iv.isUserInteractionEnabled = true
          iv.contentMode = .scaleAspectFit
        iv.backgroundColor = UIColor.black
          
          //单击事件：用于显示或隐藏导航栏，或者退出图片浏览
          let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tapZoomScale(tap:)))
          doubleTap.numberOfTapsRequired = 2
          doubleTap.numberOfTouchesRequired = 1
          iv.addGestureRecognizer(doubleTap)
          //双击事件：用于图片放大显示
          let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapDismiss(tap:)))
          singleTap.numberOfTapsRequired = 1
          singleTap.numberOfTouchesRequired = 1
          singleTap.require(toFail: doubleTap)//单击事件需要双击事件失败才响应，不然优先响应双击
          iv.addGestureRecognizer(singleTap)
          //缩放：图片的放大或者缩小
          let pan = UIPinchGestureRecognizer(target: self, action: #selector(pinchZoonScale(pinch:)))
          iv.addGestureRecognizer(pan)
          //长按事件：弹出视图。类似保存到相册，分享等
          let longPress = UILongPressGestureRecognizer(target: self, action: #selector(pressAction(press:)))
          iv.addGestureRecognizer(longPress)
          return iv
      }()
      
    
    @objc func navBackClick() {
        
        
        self.navigationController?.popViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.scrollView.frame = self.view.bounds
        self.imageView.frame = self.scrollView.bounds
        self.scrollView.addSubview(self.imageView)
        self.view.addSubview(self.scrollView)
        self.navigationController?.navigationBar.isHidden = true
        self.configTopBar()
        
        self.imageView.image = recentImage
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
            CODProgressHUD.showWithStatus("正在处理..")
            _ = TZImageManager.default()?.getOriginalPhotoData(with: CODRecentPhotoView.recentPhoto.photoAsset, completion: { [weak self] (imageData, info, isDegraded) in
                CODProgressHUD.dismiss()
                guard let imageData = imageData else {
                        return
                }
                self?.imageData = imageData
                self?.imageView.image = UIImage.init(data: imageData)
                self?.reloadOriginalBtn()
            })
        }
        
        self.configToolBar()

    }
    
    func configTopBar() {

        topToolBar.addSubview(self.pageLabel)
        pageLabel.text = "1 / 1"
        
        topToolBar.addSubview(self.backButton)
        self.backButton.snp.makeConstraints { (make) in

            make.right.equalTo(topToolBar).offset(-10)
            make.height.equalTo(24)
            make.bottom.equalTo(self.topToolBar).offset(-8)
        }
        self.pageLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(topToolBar).offset(kSafeArea_Top)
//            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalTo(self.topToolBar).offset(-13)
            make.width.equalTo(100)
        }
        self.view.addSubview(topToolBar)
    }
    
    func reloadOriginalBtn() {
        bottomToolBar.addSubview(self.originalBtn)
        let imageText = NSLocalizedString("原图", comment: "") + "  (" + CODFileHelper.getFileSize(fileSize: CGFloat(self.imageData?.count ?? 0)) + ")"

        let imageW = imageText.getStringWidth(lineSpacing: 0, fixedWidth: KScreenWidth)
        self.originalBtn.setTitle(imageText, for: .normal)
        self.originalBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalTo(bottomToolBar).offset(0)
            make.height.equalTo(44)
            make.width.equalTo(30 + imageW)
        }
    }

    func configToolBar() {
        bottomToolBar.addSubview(self.eidtBtn)

        bottomToolBar.addSubview(self.sendBtn)
        self.eidtBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(bottomToolBar).offset(0)
            make.height.equalTo(44)
            make.width.equalTo(72)
        }

        self.sendBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalTo(bottomToolBar).offset(0)
            make.height.equalTo(44)
            make.width.equalTo(72)
        }
        
        self.sendBtn.addTarget(self, action: #selector(sendImage), for: .touchUpInside)
        self.originalBtn.addTarget(self, action: #selector(originalImage), for: .touchUpInside)
        self.eidtBtn.addTarget(self, action: #selector(editImage), for: .touchUpInside)

        //添加到视图上
        self.view.addSubview(bottomToolBar)
    }
    @objc func editImage() {

        if let editor = WBGImageEditor.init(image: self.recentImage, delegate: self, dataSource: self) {
            self.present(editor , animated: true, completion: nil)
        }
    }
    
    @objc func originalImage() {
        self.originalBtn.isSelected = !self.originalBtn.isSelected
    }


    @objc func sendImage() {
        self.sendImageBlock?(self.imageView.image!, self.imageData!, self.originalBtn.isSelected)
        self.navigationController?.popViewController(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    deinit {
//        print("PhotoBrowerController deinit")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - imageView gesture method
     @objc func tapDismiss(tap:UITapGestureRecognizer) {
          //收起
        self.topToolBar.isHidden = !self.topToolBar.isHidden
        self.bottomToolBar.isHidden = !self.bottomToolBar.isHidden

      }
      /// 缩放
      ///
      /// - Parameter tap: 双击
      @objc func tapZoomScale(tap:UITapGestureRecognizer) {
          //
          UIView.animate(withDuration: 0.3, animations: {
              if self.scrollView.zoomScale == 1.0 {
                  self.scrollView.zoomScale = 3.0
              }else {
                  self.scrollView.zoomScale = 1.0
              }
          }) { (finished) in
              //
          }
      }
      /// 缩放
      ///
      /// - Parameter pinch: pinch gesture
      @objc func pinchZoonScale(pinch:UIPinchGestureRecognizer) {
          var size = pinch.view?.frame.size
          size?.width *= pinch.scale
          size?.height *= pinch.scale
          self.scrollView.bounds.size = size!
      }
      /// 长按
      ///
      /// - Parameter press: press gesture
      @objc func pressAction(press:UILongPressGestureRecognizer) {
          //print("long press")
          switch press.state {
          case .began:
              print("long press begin")
          case .ended:
              print("long press ended")
             
          case .cancelled:
              print("long press cancelled")
          case .failed:
              print("long press failed")
          case .possible:
              print("long press possible")
          default://.changed 会调用多次
              break
          }
      }
      //MARK:- iamgeView zooming Scale
      /// 获取要缩放的视图
      ///
      /// - Parameter scrollView: scrollview
      /// - Returns: 要缩放的视图
      func viewForZooming(in scrollView: UIScrollView) -> UIView? {
          return self.imageView
      }
      func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
          
          var centerX = scrollView.center.x
          var centerY = scrollView.center.y
          centerX = scrollView.contentSize.width > scrollView.frame.size.width ?
              scrollView.contentSize.width/2:centerX
          centerY = scrollView.contentSize.height > scrollView.frame.size.height ?
              scrollView.contentSize.height/2:centerY
          print(centerX,centerY)
          self.imageView.center = CGPoint(x: centerX, y: centerY)
      }

}

extension CODPhotoBrowserController: WBGImageEditorDelegate,WBGImageEditorDataSource {
    func imageItemsEditor(_ editor: WBGImageEditor!) -> [WBGMoreKeyboardItem]! {
        return [WBGMoreKeyboardItem.create(byTitle: "", imagePath: "", image: UIImage())]
    }
    
    func imageEditor(_ editor: WBGImageEditor!, didFinishEdittingWith image: UIImage!) {
        self.recentImage = image
        self.imageData = image.pngData()
        self.imageView.image = self.recentImage
    }
    
    func imageEditorDidCancel(_ editor: WBGImageEditor!) {
        
    }
}
/// cell 图片视图，用于缩放和处理其他特殊事件
class PhotoImageView: UICollectionViewCell,UIScrollViewDelegate {

    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.minimumZoomScale = 1.0
        scroll.maximumZoomScale = 3.0 //不设置范围，缩放不起作用
        scroll.delegate = self
        return scroll
    }()
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFit
        
        //单击事件：用于显示或隐藏导航栏，或者退出图片浏览
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tapZoomScale(tap:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        iv.addGestureRecognizer(doubleTap)
        //双击事件：用于图片放大显示
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapDismiss(tap:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        singleTap.require(toFail: doubleTap)//单击事件需要双击事件失败才响应，不然优先响应双击
        iv.addGestureRecognizer(singleTap)
        //缩放：图片的放大或者缩小
        let pan = UIPinchGestureRecognizer(target: self, action: #selector(pinchZoonScale(pinch:)))
        iv.addGestureRecognizer(pan)
        //长按事件：弹出视图。类似保存到相册，分享等
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(pressAction(press:)))
        iv.addGestureRecognizer(longPress)
        return iv
    }()
    
    /// 关闭closure
    var closeBlock : (()->())?
    /// addtion closure
    var showAddtionBlock : (()->())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.scrollView.frame = self.contentView.bounds
        self.imageView.frame = self.scrollView.bounds
        
        self.scrollView.addSubview(self.imageView)
        self.contentView.addSubview(self.scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - imageView gesture method
   @objc func tapDismiss(tap:UITapGestureRecognizer) {
        //收起
        print("收起")
        if let block = closeBlock {
            block()
        }
    }
    /// 缩放
    ///
    /// - Parameter tap: 双击
    @objc func tapZoomScale(tap:UITapGestureRecognizer) {
        //
        UIView.animate(withDuration: 0.3, animations: {
            if self.scrollView.zoomScale == 1.0 {
                self.scrollView.zoomScale = 3.0
            }else {
                self.scrollView.zoomScale = 1.0
            }
        }) { (finished) in
            //
        }
    }
    /// 缩放
    ///
    /// - Parameter pinch: pinch gesture
    @objc func pinchZoonScale(pinch:UIPinchGestureRecognizer) {
        var size = pinch.view?.frame.size
        size?.width *= pinch.scale
        size?.height *= pinch.scale
        self.scrollView.bounds.size = size!
    }
    /// 长按
    ///
    /// - Parameter press: press gesture
    @objc func pressAction(press:UILongPressGestureRecognizer) {
        //print("long press")
        switch press.state {
        case .began:
            print("long press begin")
        case .ended:
            print("long press ended")
            if let block = showAddtionBlock {
                block()
            }
        case .cancelled:
            print("long press cancelled")
        case .failed:
            print("long press failed")
        case .possible:
            print("long press possible")
        default://.changed 会调用多次
            break
        }
    }
    //MARK:- iamgeView zooming Scale
    /// 获取要缩放的视图
    ///
    /// - Parameter scrollView: scrollview
    /// - Returns: 要缩放的视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        centerX = scrollView.contentSize.width > scrollView.frame.size.width ?
            scrollView.contentSize.width/2:centerX
        centerY = scrollView.contentSize.height > scrollView.frame.size.height ?
            scrollView.contentSize.height/2:centerY
        print(centerX,centerY)
        self.imageView.center = CGPoint(x: centerX, y: centerY)
    }
}
