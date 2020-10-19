//
//  CODJitsiMeetView.swift
//  COD
//
//  Created by 1 on 2019/4/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import JitsiMeet

class CODJitsiMeetView: NSObject {
    static var `default`: CODJitsiMeetView  = CODJitsiMeetView()
    
    private var pipViewCoordinator: PiPViewCoordinator?
    private var jitsiMeetView: JitsiMeetView?
    private var presentVC: UIViewController?
    //代理
    weak var delegate:CODJitsiMeetViewDelegate?

    func showMeetView(roomID: String, presentVC: UIViewController) {
        
        self.cleanUp()
        
        self.jitsiMeetView = JitsiMeetView()
        self.jitsiMeetView?.delegate = self
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL.init(string: "https://\(XMPPDomain):7443/codmeet/")
            builder.room = roomID
            builder.audioOnly = true
        }
        self.jitsiMeetView?.join(options)
        pipViewCoordinator = PiPViewCoordinator(withView: self.jitsiMeetView!)
        pipViewCoordinator?.configureAsStickyView(withParentView: UIApplication.shared.keyWindow)
        pipViewCoordinator?.delegate  = self
        self.jitsiMeetView?.alpha = 0
        pipViewCoordinator?.show()
    }

}
extension CODJitsiMeetView: JitsiMeetViewDelegate {
    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.hide() { _ in
                self.cleanUp()
                UIApplication.shared.setStatusBarHidden(false, with: .fade)
            }
        }
    }
    
    //大屏到小屏
    func enterPicture(inPicture data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.enterPictureInPicture()
//            UIApplication.shared.setStatusBarHidden(false, with: .fade)
        }
    }
    
    func conferenceWillJoin(_ data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
//            UIApplication.shared.setStatusBarHidden(true, with: .fade)
        }
    }
    
    fileprivate func cleanUp() {
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        pipViewCoordinator = nil
    }
}
extension CODJitsiMeetView: PiPViewCoordinatorDelegate {
    //小屏到大屏
    public func exitPictureInPicture() {
        UIApplication.shared.setStatusBarHidden(true, with: .fade)

    }
}


protocol CODJitsiMeetViewDelegate:NSObjectProtocol{
    
   
}
