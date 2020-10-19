//
//  CODChatVoiceIndicatorView.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODChatVoiceIndicatorView: UIView {
    let STR_RECORDING  = "手指上滑,取消发送"
    let STR_CANCEL = "手指松开,取消发送"
    let STR_REC_SHORT = "录制时间太短"
    public var countDown:Int = 0

    var status:CODRecordStatus = .CODRecorderStatusRecording {
       
        didSet{

            updateStatus()
        }
    }
    ///设置音量大小
    var volume:CGFloat = 0.0  {
        didSet{
            updateVolume()
        }
    }
    fileprivate lazy var backgroundView: UIView = {
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = 5
        return backgroundView
    }()
    fileprivate lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.font = FONT14
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = UIColor.white
        titleLabel.text = STR_RECORDING
        return titleLabel
    }()
    fileprivate lazy var centerCountDownLabel: UILabel = {
        let centerCountDownLabel = UILabel(frame: CGRect.zero)
        centerCountDownLabel.font = UIFont.systemFont(ofSize: 65)
        centerCountDownLabel.textAlignment = NSTextAlignment.center
        centerCountDownLabel.textColor = UIColor.white
        centerCountDownLabel.text = STR_RECORDING
        return centerCountDownLabel
    }()
    fileprivate lazy var titleBackgroundView:UIView = {
        let titleBackgroundView = UIView(frame: CGRect.zero)
        titleBackgroundView.isHidden = true
        titleBackgroundView.backgroundColor = UIColor.clear
        titleBackgroundView.layer.masksToBounds = true
        titleBackgroundView.layer.cornerRadius = 2
        return titleBackgroundView
    }()
    ///音量图像
    fileprivate lazy var volumeImageView:UIImageView = {
        let volumeImageView = UIImageView()
        volumeImageView.image = UIImage(named: "chat_record_signal_1")
        volumeImageView.contentMode = .bottomLeft
        return volumeImageView
    }()
    ///中间图像
    fileprivate lazy var centerImageView:UIImageView = {
        let centerImageView = UIImageView(frame: .zero)
        centerImageView.isHidden = true
        return centerImageView
    }()
    ///左边图像
    fileprivate lazy var recImageView:UIImageView = {
        let recImageView = UIImageView(frame: .zero)
        recImageView.image = UIImage(named: "chat_record_recording")
        return recImageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubViews()
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置视图
    fileprivate func setUpSubViews(){
        self.addSubview(self.backgroundView)
        self.addSubview(self.titleBackgroundView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.volumeImageView)
        self.addSubview(self.centerImageView)
        self.addSubview(self.recImageView)
        self.addSubview(self.centerCountDownLabel)
    }
    
    /// 设置约束
    fileprivate func setUpLayout(){
        self.backgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        self.recImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(35)
            make.left.equalToSuperview().offset(42)
        }
        
        self.volumeImageView.snp.makeConstraints { (make) in
            make.bottom.height.equalTo(self.recImageView)
            make.width.equalTo(30)
            make.right.equalToSuperview().offset(-32)
        }
        self.centerImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(15)
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(-15)
        }
        self.titleBackgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel.snp.left).offset(-5)
            make.right.equalTo(self.titleLabel.snp.right).offset(5)
            make.top.equalTo(self.titleLabel.snp.top).offset(-2)
            make.bottom.equalTo(self.titleLabel.snp.bottom).offset(2)
        }
        self.centerCountDownLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(35)

        }
    }
    
    /// 更新状态
    fileprivate func updateStatus(){
        if self.status == .CODRecorderStatusRecording {///开始录音
            
            if self.countDown <= 0{
                self.centerImageView.isHidden = true
                self.titleBackgroundView.isHidden = true
                self.recImageView.isHidden = false
                self.volumeImageView.isHidden = false
                self.titleLabel.isHidden = false
                self.titleLabel.text = STR_RECORDING
                self.titleLabel.textColor = UIColor.white
                self.centerCountDownLabel.isHidden = true
            }

        }else if self.status == .CODRecorderStatusWillCancel{//要取消
            self.centerImageView.isHidden = false
            self.centerImageView.image = UIImage(named: "chat_record_cancel")
            self.titleBackgroundView.isHidden = false
            self.recImageView.isHidden = true
            self.volumeImageView.isHidden = true
            self.titleLabel.isHidden = false
            self.titleLabel.text = STR_CANCEL
            self.titleLabel.textColor = UIColor.red
            self.centerCountDownLabel.isHidden = true

        }else if self.status == .CODRecorderStatusTooShort{///太短了
            self.centerImageView.isHidden = false
            self.centerImageView.image = UIImage(named: "chat_record_tooShort")
            self.titleBackgroundView.isHidden = false
            self.recImageView.isHidden = true
            self.volumeImageView.isHidden = true
            self.titleLabel.isHidden = false
            self.titleLabel.text = STR_REC_SHORT
            self.titleLabel.textColor = UIColor.white
            self.centerCountDownLabel.isHidden = true

        }else if(self.status == .CODRecorderStatusCountDown){///倒计时时间
            DispatchQueue.main.sync {
                self.centerCountDownLabel.isHidden = false
                self.centerImageView.isHidden = true
                self.titleBackgroundView.isHidden = true
                self.recImageView.isHidden = true
                self.volumeImageView.isHidden = true
                self.titleLabel.isHidden = false
                self.centerCountDownLabel.text = "\(self.countDown)"
            }
         
        }
        
    }
    /// 更新音量图像
    fileprivate func updateVolume(){

        var picID =  10 * (volume < 0 ? 0 : (volume > 1.0 ? 1.0 : volume))
        picID = picID > 8 ? 8 : picID
        print("音量----------23 \(picID)")
        self.volumeImageView.image = UIImage(named: "chat_record_signal_\(Int(picID))")

    }
    
  
}
