//
//  Xinhoo_DownloadFileCellProtocol.swift
//  COD
//
//  Created by Sim Tsai on 2019/12/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Lottie

protocol Xinhoo_DownloadFileCellProtocol: CODBaseChatCell {
    
    
    var viewModel: Xinhoo_FileViewModel? { get }
    var lottieView: AnimationView { get }
    var progressView: UIProgressView! { get }
    
    
    func configDownloadProgress()
        
}


extension Xinhoo_DownloadFileCellProtocol {
    
    
    func configDownloadProgress() {
        
        self.viewModel?.downloadState.bind {
            switch $0 {
            case .ide:
                self.lottieView.stop()
                self.lottieView.currentProgress = 0.5
                self.lottieView.isHidden = false
                
            case .loading:
                self.lottieView.play()
                self.lottieView.isHidden = false
                
            case .finished:
                self.lottieView.stop()
                self.lottieView.isHidden = true
                
            }
        }
        .disposed(by: self.rx.prepareForReuseBag)
        
        self.viewModel?.downloadProgress
            .bind(to: self.progressView.rx.progress)
            .disposed(by: self.rx.prepareForReuseBag)
        
    }
    
}


