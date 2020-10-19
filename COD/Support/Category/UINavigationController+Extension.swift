//
//  UINavigationController+Extension.swift
//  COD
//
//  Created by Xinhoo on 2019/8/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation

extension UINavigationController {
    //StatusBar
    override open var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }

    override open var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    //Orientations
    override open var shouldAutorotate: Bool{
        return self.topViewController?.shouldAutorotate ?? false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return self.topViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return self.topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
    func popToViewController(to vcType: UIViewController.Type) {
        
        var vc: UIViewController?
        
        for value in self.viewControllers {
            
            if value.isKind(of: vcType) {
                vc = value
                break
            }
            
        }
        
        if let vc = vc {
            self.popToViewController(vc, animated: true)
        } else {
            self.popViewController()
        }

    }
}
