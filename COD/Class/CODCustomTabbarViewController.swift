//
//  CODCustomTabbarViewController.swift
//  COD
//
//  Created by xinhooo on 2019/7/16.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Lottie
import RxSwift
import RxCocoa

class CODCustomTabbarViewController: CYLTabBarController {

    //默认选中的tab
    var currentIndex = 2
    
    //设置tab的index
    var setIndex = 4
    
    //聊天tab的index
    var chatIndex = 2
    
    //发现tab的index
    var discoverIndex = 3
    
    var lastDate = Date()
    
    var nav1:BaseNavigationController?
    var nav2:BaseNavigationController?
    var nav3:BaseNavigationController?
    var callNav:BaseNavigationController?
    var discoverNav:BaseNavigationController?
    
    var contactDic = [CYLTabBarItemTitle:"联系人",
                      CYLTabBarItemImage:"tab_contacts",
                      CYLTabBarItemSelectedImage:"tab_contacts_selected",
                      CYLTabBarLottieURL:NSURL.init(fileURLWithPath: Bundle.main.path(forResource: "contact", ofType: "json")!),
                      CYLTabBarLottieSize:NSValue.init(cgSize: CGSize.init(width: 24, height: 24))] as [String : Any]
    
    var callDic = [CYLTabBarItemTitle:"呼叫",
                   CYLTabBarItemImage:"tab_call",
                   CYLTabBarItemSelectedImage:"tab_call_selected",
                   CYLTabBarLottieURL:NSURL.init(fileURLWithPath: Bundle.main.path(forResource: "call", ofType: "json")!),
                   CYLTabBarLottieSize:NSValue.init(cgSize: CGSize.init(width: 24, height: 24))] as [String : Any]
    
    var chatDic = [CYLTabBarItemTitle:"聊天",
                   CYLTabBarItemImage:"tab_chat",
                   CYLTabBarItemSelectedImage:"tab_chat_selected",
                   CYLTabBarLottieURL:NSURL.init(fileURLWithPath: Bundle.main.path(forResource: "chat", ofType: "json")!),
                   CYLTabBarLottieSize:NSValue.init(cgSize: CGSize.init(width: 24, height: 24))] as [String : Any]
    
    var discoverDic = [CYLTabBarItemTitle:"发现",
                       CYLTabBarItemImage:"tab_discover",
                       CYLTabBarItemSelectedImage:"tab_discover_selected",
                       CYLTabBarLottieURL:NSURL.init(fileURLWithPath: Bundle.main.path(forResource: "discover", ofType: "json")!),
                       CYLTabBarLottieSize:NSValue.init(cgSize: CGSize.init(width: 24, height: 24))] as [String : Any]
    
    var meDic = [CYLTabBarItemTitle:"设置",
                 CYLTabBarItemImage:"tab_me",
                 CYLTabBarItemSelectedImage:"tab_me_selected",
                 CYLTabBarLottieURL:NSURL.init(fileURLWithPath: Bundle.main.path(forResource: "more", ofType: "json")!),
                 CYLTabBarLottieSize:NSValue.init(cgSize: CGSize.init(width: 24, height: 24))] as [String : Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let bgView = UIView.init(frame: self.tabBar.bounds)
        bgView.backgroundColor = UIColor(hexString: kTabBarBackgroundColorS)
        self.tabBar.insertSubview(bgView, at: 0)
        self.sessionRedPoint()
        self.updateCircleRedPoint() // 获取本地数据
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRedPoint), name: NSNotification.Name.init(kReloadRedPoint), object: nil)

        
        Observable.merge(
            [UserManager.sharedInstance.rx.circleFirstPic.mapTo(Void()),
            UserManager.sharedInstance.rx.spreadMessageCount.mapTo(Void()),
            UserManager.sharedInstance.rx.spreadMessagePic.mapTo(Void())]
        )
        .bind { [weak self] (_) in
            guard let `self` = self else { return }
            self.updateCircleRedPoint()
        }
        .disposed(by: self.rx.disposeBag)


        self.delegate = self
        self.view.backgroundColor = UIColor(hexString: kTabBarBackgroundColorS)
        
    }

    func configCall() {
        let chatCtl = ChatViewController()
        nav1 = BaseNavigationController(rootViewController: chatCtl)
        
        let callStoryboard = UIStoryboard.init(name: "Call", bundle: Bundle.main)
        let callVC = callStoryboard.instantiateViewController(withIdentifier: "CODCallViewController") as! CODCallViewController
        callNav = BaseNavigationController(rootViewController: callVC)
        
        let contactCtl = ContactsViewController()
        nav2 = BaseNavigationController(rootViewController: contactCtl)
        
        let discoverCtl = Xinhoo_DiscoverViewController(nibName: "Xinhoo_DiscoverViewController", bundle: Bundle.main)
        discoverNav = BaseNavigationController(rootViewController: discoverCtl)
        
        let meCtl = MeViewController()
        nav3 = BaseNavigationController(rootViewController: meCtl)
        
        if UserDefaults.standard.string(forKey: kShowCallTab) == "true" {
            self.tabBarItemsAttributes = [contactDic,callDic,chatDic,discoverDic,meDic] as [[AnyHashable : Any]]
            self.viewControllers = [nav2,callNav,nav1,discoverNav,nav3] as! [UIViewController]
            currentIndex = 2
            setIndex = 4
            chatIndex = 2
            discoverIndex = 3
        }else{
            self.tabBarItemsAttributes = [contactDic,chatDic,discoverDic,meDic] as [[AnyHashable : Any]]
            self.viewControllers = [nav2,nav1,discoverNav,nav3] as! [UIViewController]
            currentIndex = 1
            setIndex = 3
            chatIndex = 1
            discoverIndex = 2
        }
        
        self.selectedIndex = currentIndex
        
//        let newFriend = UserManager.sharedInstance.haveNewFriend
//        self.tabBar.items?[0].badgeValue = newFriend <= 0 ? nil : String(format: "%ld", newFriend)
        let isShowRed: Bool = CODUserDefaults.bool(forKey: AccountAndSecurity_Red_Point)
        
        if isShowRed == true{
            self.tabBar.items?[setIndex].cyl_badgeFrame = CGRect.init(x: 0, y: 0, width: 8, height: 8)
            self.tabBar.items?[setIndex].cyl_badgeRadius = 4
            self.tabBar.items?[setIndex].cyl_badgeBackgroundColor = .red
            self.tabBar.items?[setIndex].cyl_showBadge()
        }
//        self.tabBar.barTintColor = .white
    }

    
    func switchCallConfig() {
        let chatCtl = ChatViewController()
        nav1 = BaseNavigationController(rootViewController: chatCtl)
        
        let callStoryboard = UIStoryboard.init(name: "Call", bundle: Bundle.main)
        let callVC = callStoryboard.instantiateViewController(withIdentifier: "CODCallViewController") as! CODCallViewController
        callNav = BaseNavigationController(rootViewController: callVC)
        
        let contactCtl = ContactsViewController()
        nav2 = BaseNavigationController(rootViewController: contactCtl)
        
        let discoverCtl = Xinhoo_DiscoverViewController(nibName: "Xinhoo_DiscoverViewController", bundle: Bundle.main)
        discoverNav = BaseNavigationController(rootViewController: discoverCtl)
        
        let meCtl = MeViewController()
        nav3 = BaseNavigationController(rootViewController: meCtl)
        
        if UserDefaults.standard.string(forKey: kShowCallTab) == "true" {
            currentIndex = 2
            setIndex = 4
            chatIndex = 2
            discoverIndex = 3
        }else{
            currentIndex = 1
            setIndex = 3
            chatIndex = 1
            discoverIndex = 2
        }
        
        
        let newFriend = UserManager.sharedInstance.haveNewFriend
        self.tabBar.items?[0].badgeValue = newFriend == 0 ? nil : String(format: "%ld", newFriend)
        
        let spreadMessageCount = UserManager.sharedInstance.spreadMessageCount
        self.tabBar.items?[discoverIndex].badgeValue = spreadMessageCount == 0 ? nil : String(format: "%ld", spreadMessageCount)
        
        let isShowRed: Bool = CODUserDefaults.bool(forKey: AccountAndSecurity_Red_Point)
        if isShowRed == true{
            self.tabBar.items?[setIndex].cyl_badgeFrame = CGRect.init(x: 0, y: 0, width: 8, height: 8)
            self.tabBar.items?[setIndex].cyl_badgeRadius = 4
            self.tabBar.items?[setIndex].cyl_badgeBackgroundColor = .red
            self.tabBar.items?[setIndex].cyl_showBadge()
        }
//        self.tabBar.barTintColor = .white
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
    
    @objc func sessionRedPoint() {
        
        DispatchQueue.main.async {
            var count = 0
            let results = try! Realm.init().objects(CODChatListModel.self).filter("((contact.mute = false || groupChat.mute = false || channelChat.mute = false) && isInValid = false) || id = -999")
            
            for chatModel in results {
                count = count + chatModel.count
            }
            
            if count > 999 {
                
                let k = count / 1000
                self.tabBar.items?[self.chatIndex].badgeValue = "\(k)K"
            }else{
                
                self.tabBar.items?[self.chatIndex].badgeValue = count.string
                if count == 0{
                    self.tabBar.items?[self.chatIndex].badgeValue = nil
                }
            }
        }
    }
    
    @objc func updateCircleRedPoint() {
        
        DispatchQueue.main.async {
            let count = UserManager.sharedInstance.spreadMessageCount
            let firstPic = UserManager.sharedInstance.circleFirstPic
            if count > 0 {
                self.setCircleCountBadgeValue()
            }else{
                if firstPic.count > 0 {
                    self.setCircleTabbarRedPoint()
                }else{
                    self.tabBar.items?[self.discoverIndex].badgeValue = nil
                }
            }
        }
        
    }
    
    private func setCircleCountBadgeValue() {
        let count = UserManager.sharedInstance.spreadMessageCount
        if count > 999 {
            let k = count / 1000
            self.tabBar.items?[self.discoverIndex].badgeValue = "\(k)K"
        }else{
            self.tabBar.items?[self.discoverIndex].badgeValue = count.string
        }
    }
    
    private func setCircleTabbarRedPoint() {
        self.tabBar.items?[self.discoverIndex].cyl_badgeFrame = CGRect.init(x: 20, y: 0, width: 8, height: 8)
        self.tabBar.items?[self.discoverIndex].cyl_badgeRadius = 4
        self.tabBar.items?[self.discoverIndex].cyl_badgeBackgroundColor = .red
        self.tabBar.items?[self.discoverIndex].cyl_showBadge()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func doubleClick() -> Bool {
        let date = Date()
        if date.timeIntervalSince1970 - self.lastDate.timeIntervalSince1970 < 0.5 {
            self.lastDate = Date(timeIntervalSince1970: 0)
            return true
        }
        self.lastDate = date
        return false
    }
    
}

extension CODCustomTabbarViewController{
    
    override func tabBarController(_ tabBarController: UITabBarController, didSelect control: UIControl) {
        
        var animationView:UIView = UIView.init()
        
        var lottieJsonName = ""
        
        var isShowLottieAnimation = false
        
        for subView in control.subviews {
            if subView.isKind(of: NSClassFromString("UITabBarSwappableImageView")!){
                animationView = subView
                
                if animationView.frame.size == CGSize.init(width: 0, height: 0) || animationView.frame.origin == CGPoint.init(x: 0, y: 0){
                    animationView.isHidden = false
                }else{
                    animationView.isHidden = true
                    isShowLottieAnimation = true
                }
            }
            
            if subView.isKind(of: NSClassFromString("UITabBarButtonLabel")!){
                let lab = subView as! UILabel
                switch lab.text {
                case NSLocalizedString("联系人", comment: ""):
                    lottieJsonName = "contact"
                    break
                case NSLocalizedString("呼叫", comment: ""):
                    lottieJsonName = "call"
                    break
                case NSLocalizedString("聊天", comment: ""):
                    lottieJsonName = "chat"
                    break
                case NSLocalizedString("发现", comment: ""):
                    lottieJsonName = "discover"
                    break
                case NSLocalizedString("设置", comment: ""):
                    lottieJsonName = "more"
                    break
                default:
                    break
                }
            }
        }
        
        if isShowLottieAnimation == false {
            return
        }
        
        let animation = Animation.filepath(Bundle.main.path(forResource: lottieJsonName, ofType: "json")!, animationCache: nil)
        let lottieView = AnimationView.init()
        lottieView.frame = CGRect.init(x: animationView.frame.minX-2.5, y: animationView.frame.minY-2.5, width: animationView.frame.width+5, height: animationView.frame.height+5)
//        lottieView.frame = animationView.frame
        lottieView.animation = animation
        lottieView.animationSpeed = 1.0
        animationView.superview!.addSubview(lottieView)
        lottieView.play { (animationFinished) in
            animationView.isHidden = false
            lottieView.stop()
            lottieView.removeFromSuperview()
        }
//        lottieView.play()
        
//        let animation = CAKeyframeAnimation.init()
//        animation.keyPath = "transform.scale"
//        animation.values = [1,1.2,0.9,1.15,0.95,1.02,1.0]
//        animation.duration = 1
//        animation.calculationMode = .cubic
//        animationView.layer.add(animation, forKey: nil)
        
    }
    
    override func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
//        // 判断哪个界面要需要再次点击刷新，这里以第一个VC为例
//        if ([tabBarController.selectedViewController isEqual:[tabBarController.viewControllers firstObject]]) {
//            // 判断再次选中的是否为当前的控制器
//            if ([viewController isEqual:tabBarController.selectedViewController]) {
//                // 执行操作
//                NSLog(@"刷新界面");
//
//                return NO;
//            }
//
//        }
//
//        return YES;
        
        //点击了第一个tabbar
        if (tabBarController.selectedViewController?.isEqual(tabBarController.viewControllers?[0]))! {
            //判断当前点击是否已选中的控制器
            if viewController.isEqual(tabBarController.selectedViewController) {
                
                NotificationCenter.default.post(name: NSNotification.Name.init(kClickTabbarItemNoti), object: NSNumber.init(value: 0))
                return false
            }
        }
        //点击了第二个tabbar
        if (tabBarController.selectedViewController?.isEqual(tabBarController.viewControllers?[1]))! {
            if viewController.isEqual(tabBarController.selectedViewController) {
                if self.doubleClick() {
                    NotificationCenter.default.post(name: NSNotification.Name.init(kClickTabbarItemNoti), object: NSNumber.init(value: 1))
                }
                return false
            }
        }
        //点击了第三个tabbar
        if (tabBarController.selectedViewController?.isEqual(tabBarController.viewControllers?[2]))! {
            if viewController.isEqual(tabBarController.selectedViewController) {
                
                if self.doubleClick() {
                    NotificationCenter.default.post(name: NSNotification.Name.init(kClickTabbarItemNoti), object: NSNumber.init(value: 2))
                }
                
                return false
            }
        }
        
        return true
    }
    
}
