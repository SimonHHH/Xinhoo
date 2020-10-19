//
//  CODPlayerVC.swift
//  COD
//
//  Created by 1 on 2019/4/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import AVKit

class CODPlayerVC: BaseViewController {

    var urlString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.navigationItem.title = NSLocalizedString("视频播放", comment: "")
        
        let playerViewController = AVPlayerViewController()
//        let url = self.urlString.hasPrefix("http") ? URL.init(string: urlString)! : URL.init(fileURLWithPath: urlString)
        let url = URL.init(string: urlString)!
        playerViewController.player = AVPlayer.init(url: url)
        //添加view播放的模式
        playerViewController.view.frame = self.view.bounds
        playerViewController.showsPlaybackControls = true
        self.addChild(playerViewController)
        self.view.addSubview(playerViewController.view)
        if playerViewController.isReadyForDisplay {
            playerViewController.player?.play()
        }
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
