//
//  CODVideoCallVC.swift
//  COD
//
//  Created by 1 on 2019/4/10.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
//import JitsiMeet

class CODVideoCallVC: BaseViewController {

    
    fileprivate var pipViewCoordinator: PiPViewCoordinator?
    fileprivate var jitsiMeetView: JitsiMeetView?
    
    var roomID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        cleanUp()
//        let meetView = JitsiMeetView.init(frame: self.view.bounds)
//        meetView.delegate = self
//        meetView.pictureInPictureEnabled = true
//        meetView.loadURLString("\(COD_VideoCall_Url)\(roomID)")
        //测试专用
//        meetView.loadURLString("https://cod.xinhoo.com:7443/codmeet/123")
//        self.view.addSubview(meetView)
        
        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL=URL.init(string: "https://\(XMPPDomain):7443/codmeet/")
            builder.room="123";
        }
        jitsiMeetView.join(options)
        
        
        // Enable jitsimeet view to be a view that can be displayed
        // on top of all the things, and let the coordinator to manage
        // the view state and interactions
        pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: view)
        
        // animate in
        jitsiMeetView.alpha = 0
        pipViewCoordinator?.show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        pipViewCoordinator?.resetBounds(bounds: rect)
    }
    
    fileprivate func cleanUp() {
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        pipViewCoordinator = nil
    }
}

//extension CODVideoCallVC : JitsiMeetViewDelegate{
//    func conferenceFailed(_ data: [AnyHashable : Any]!) {
//        print("error \(String(describing: data))")
//    }
//
//    func loadConfigError(_ data: [AnyHashable : Any]!) {
//        print("error \(String(describing: data))")
//    }
//
//    func enterPicture(inPicture data: [AnyHashable : Any]!) {
//        print("inPicture \(String(describing: data))")
//    }
//
//    func conferenceWillLeave(_ data: [AnyHashable : Any]!) {
//        print("conferenceWillLeave \(String(describing: data))")
//        self.navigationController?.popViewController()
//    }
//}

extension CODVideoCallVC: JitsiMeetViewDelegate {
    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.hide() { _ in
                self.cleanUp()
            }
        }
    }
    
    func enterPicture(inPicture data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.enterPictureInPicture()
        }
    }
}


