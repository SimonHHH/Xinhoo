//
//  CODVoiceImageView.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODVoiceImageView: UIImageView {
    
    fileprivate  var normalImage:UIImage? ///正常的图片
    fileprivate  var imageArray:[UIImage] = [UIImage]() ///图片数组
    public var forMe:Bool?{
        didSet{
            updateNormalImage()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.forMe = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///设置显示的图片
    fileprivate func updateNormalImage() {
        if forMe == true{
            self.imageArray = [UIImage(named: "right_voice"),UIImage(named: "message_voice_sender_playing_2"),UIImage(named: "message_voice_sender_normal")] as! [UIImage]
            self.normalImage = UIImage(named: "message_voice_sender_normal")
        }else{
            self.imageArray = [UIImage(named: "message_voice_sender_playing_1"),UIImage(named: "message_voice_receiver_playing_2"),UIImage(named: "message_voice_receiver_normal")] as! [UIImage]
            self.normalImage = UIImage(named: "message_voice_receiver_normal")

        }
        self.image = self.normalImage
    }
    
    public func startPlayingAnimation() {
        self.animationImages = self.imageArray
        self.animationRepeatCount = 0;
        self.animationDuration = 1.0;
        self.startAnimating()
    }
    
    public func stopPlayingAnimation(){
        self.stopAnimating()
    }
    

    
}
