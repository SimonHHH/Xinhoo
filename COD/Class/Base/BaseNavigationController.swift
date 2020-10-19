//
//  BaseNavigationController.swift
//  COD
//
//  Created by XinHoo on 2019/2/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override func loadView() {
        super.loadView()
        self.setUp()
    }
    
    func setUp() {
        
        let bar = UINavigationBar.appearance()
        bar.barTintColor = UIColor(hexString: kNavBarBgColorS)
        
//        bar.setBackgroundImage(UIImage(), for: .default)
//        bar.shadowImage = UIImage()
        
        bar.isTranslucent = false
        let attributes = NSDictionary(dictionary: [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue) : UIColor(hexString: kNavTitleColorS)!,
                                                   NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont(name: "PingFang-SC-Medium", size: 17.0)!]) as? [NSAttributedString.Key : Any]
        bar.titleTextAttributes = attributes
        self.view.backgroundColor = UIColor(hexString: kVCBgColorS)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let navigationController = navigationController {  //避免重复push一个VC
            guard navigationController.topViewController == self else {
                return
            }
        }
        
        if (self.children.count == 1) {
            viewController.hidesBottomBarWhenPushed = true; //viewController是将要被push的控制器
        }
        
        super.pushViewController(viewController, animated: animated)
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        
        
        if viewControllers.count > 1 {
            for a in 2...viewControllers.count {
                viewControllers[a-1].hidesBottomBarWhenPushed = true
            }
        }
        
        super.setViewControllers(viewControllers, animated: animated)
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
