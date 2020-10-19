//
//  CODUIViewController+Extension.swift
//  COD
//
//  Created by XinHoo on 2019/4/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension UIViewController {
    class func current(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return current(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return current(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return current(base: presented)
        }
        return base
    }
    
    class func pushToCtl(_ vc: UIViewController, animated: Bool) {
        if let ctl = UIViewController.current() as? CODCustomTabbarViewController {
            let baseNavCtl = ctl.getViewControllerWith(index: 0) as? BaseNavigationController
            let chatCtl = baseNavCtl?.children[0]
            chatCtl?.navigationController?.pushViewController(vc, animated: animated)
        } else {
            let ctl = UIViewController.current()
            ctl?.navigationController?.pushViewController(vc, animated: animated)
        }
    }
}
