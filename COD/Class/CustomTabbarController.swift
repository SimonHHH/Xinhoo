//
//  CustomTabbarController.swift
//  COD
//
//  Created by XinHoo on 2019/2/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RDVTabBarControllerSwift

class CustomTabbarController: RDVTabBarController {
    
//    var token : NotificationToken? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(hexString: kTabBarBackgroundColorS)
        self.tabBar.backgroundView.backgroundColor = UIColor(hexString: kTabBarBackgroundColorS)

        //解决tabbar SafeArea颜色不一致
//        self.tabBar.translucent = false
        delegate = self
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 1.0))
        lineView.backgroundColor = UIColor(hexString: kDividingLineColorS)
        self.tabBar.addSubview(lineView)
        
        self.addNewsChildViewController()
        CODFileManager.shareInstanceManger().pathUserPath()
        self.sessionRedPoint()
        
//        token = try! Realm.init().objects(CODChatListModel.self).observe({ (changes) in
//            switch changes{
//            case .initial(_):
//                break
//            case .update(_,_,_,_):
//                self.sessionRedPoint()
//            case .error(_):
//                break
//            }
//        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRedPoint), name: NSNotification.Name.init(kReloadRedPoint), object: nil)
        
        let newFriend = UserDefaults.cod_floatForKey(HAVE_NEWFRIEND_NOTICATION).int
        self.tabBar.items?[0].badgeValue = Int(String(format: "%ld", newFriend)) == 0 ? "" : String(format: "%ld", newFriend)
        self.selectedIndex = 1
    }
    
    @objc func sessionRedPoint() {
        
        DispatchQueue.main.async {
            var count = 0
            let results = try! Realm.init().objects(CODChatListModel.self).filter("(contact.mute = false || groupChat.mute = false || channelChat.mute = false) && isInValid = false")
            
            for chatModel in results {
                count = count + chatModel.count
            }
            
            if count > 999 {
                self.tabBar.items?[1].badgeValue = "999+"
            }else{
                
                self.tabBar.items?[1].badgeValue = count.string
                if count == 0{
                    self.tabBar.items?[1].badgeValue = ""
                }
            }
        }
    }
    
    func addNewsChildViewController() {
        let chatCtl = ChatViewController()
        let nav1 = BaseNavigationController(rootViewController: chatCtl)
        let contactCtl = ContactsViewController()
        let nav2 = BaseNavigationController(rootViewController: contactCtl)
        let meCtl = MeViewController()
        let nav3 = BaseNavigationController(rootViewController: meCtl)
        self.viewControllers = [nav2,nav1,nav3]
        self.addTabbarItems()
    }
    
    func addTabbarItems() {
        let titleArr = ["联系人","聊天","我"]
        let imageArr = ["tab_contacts","tab_chat","tab_me"]
        var index :NSInteger = 0
        for item: RDVTabBarItem in (self.tabBar.items)!{
            item.backgroundColor = UIColor(hexString: kTabBarBackgroundColorS)
            item.title = titleArr[index]
            item.unselectedTitleAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue) : UIColor(hexString: kTabItemUnselectedColorS)] as! [NSAttributedString.Key : NSObject]
            item.selectedTitleAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue) : UIColor(hexString: kTabItemSelectedColorS)] as! [NSAttributedString.Key : NSObject]
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 3)
            let normalImg = UIImage(named: imageArr[index])
            let selectedImg = UIImage(named: "\(imageArr[index])_selected")
            selectedImg?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            item.setFinishedSelectedImage(selectedImg, unselectedImage: normalImg)
            index += 1
        }
    }
    
    func getViewControllerWith(index: Int) -> UIViewController {
        if self.children.count > index  {
            return self.children[index]
        }else{
            if self.children.count > 0 {
                return self.children[self.children.count-1]
            }else{
                return UIViewController()
            }

        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 为了messageViewController正常接收xmpp发来的消息显示 ，因为messageViewController,POP出来，不会及时销毁
        /// self.tabBar.setHeight(IsiPhoneX ? 84:49)
        print("tabbar viewWillAppear")
    }
    
    //StatusBar
    override var childForStatusBarStyle: UIViewController? {
        return self.selectedViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        return self.selectedViewController
    }
    
    //Orientations
    override var shouldAutorotate: Bool{
        return self.selectedViewController?.shouldAutorotate ?? false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return self.selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return self.selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}

extension CustomTabbarController :RDVTabBarControllerDelegate{
    func tabBarController(_ tabBarController: RDVTabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        return true
    }
    
    func tabBarController(_ tabBarController: RDVTabBarController, didSelectViewController viewController: UIViewController) {
        
    }
    
}
extension CustomTabbarController: BonsaiControllerDelegate {
    
    // return the frame of your Bonsai View Controller
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: containerViewFrame.width, height: containerViewFrame.height))
    }
    
    // return a Bonsai Controller with SlideIn or Bubble transition animator
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        // Slide animation from .left, .right, .top, .bottom
        return BonsaiController(fromDirection: .bottom, blurEffectStyle: .extraLight, presentedViewController: presented, delegate: self)
        
        // or Bubble animation initiated from a view
        //return BonsaiController(fromView: yourOriginView, blurEffectStyle: .dark,  presentedViewController: presented, delegate: self)
    }
}
