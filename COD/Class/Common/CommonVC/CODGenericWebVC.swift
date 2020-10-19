//
//  CODGenericWebVC.swift
//  COD
//
//  Created by 1 on 2019/3/14.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation
import WebKit

class CODGenericWebVC: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
        setupUI()
        loadRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: kProgress)
        webView.removeObserver(self, forKeyPath: kTitle)
    }
    
    public var urlString: String?
    
    private var errorUrl: NSURL?
    private let kTitle = "title"
    private let kProgress = "estimatedProgress"
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
//        config.mediaPlaybackRequiresUserAction = true
        config.allowsInlineMediaPlayback = true
//        config.mediaPlaybackAllowsAirPlay = true
        
        let webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self as? WKUIDelegate
        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: kProgress, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: kTitle, options: .new, context: nil)
        
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = UIColor.init(hexString: "#007EE5") ?? UIColor.blue
        progress.progressTintColor = UIColor.init(hexString: "#007EE5") ?? UIColor.blue
        progress.transform = CGAffineTransform(scaleX: 1, y: 1)
        progress.isHidden = true
        return progress
    }()
    
    // 退出界面的回调
    var didMoveBlock:((_ vc:CODGenericWebVC)->())?
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if !(parent != nil) {
            if (didMoveBlock != nil) {
                didMoveBlock!(self)
            }
        }
    }
    
    override func navBackClick() {
        if self.webView.canGoBack {
            self.webView.goBack()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }

}

//MARK: - Pirvate
extension CODGenericWebVC {
    private func setupUI() {
        view.addSubview(webView)
        view.addSubview(progressView)
        
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(view.snp.topMargin)
            make.height.equalTo(3)
        }
    }
    
    private func loadRequest() {
        if let urlStr = urlString {
            var getUrl = urlStr
            if !urlStr.hasPrefix("http") {
                getUrl = "http://\(urlStr)"
            }
            let url = URL.init(string: getUrl)
            if url != nil {
                judgeAndAddHttpHeader(loadUrl: url!)
            }
        }
    }
    
    private func judgeAndAddHttpHeader(loadUrl: URL){
        
        if self.urlString != nil {
            var headerField = ""
            var headerValue = ""
            
            let request = URLRequest.init(url: loadUrl)
                webView.load(request)
        }
    }
}

//MARK: - 代理
extension CODGenericWebVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        view.bringSubviewToFront(progressView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        switch error._code {
            
        case -1009:
            print("没有连接到网络")
            if let str = webView.url {
                if UIApplication.shared.canOpenURL(str) {
                    errorUrl = str as NSURL
                }
            }
            break
        case -1003:
            CODProgressHUD.showErrorWithStatus("服务器连接错误")
            break
        default:
            CODProgressHUD.showErrorWithStatus("错误码: \(error._code)")
        }
    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        
//        if navigationAction.navigationType == .linkActivated {
//            decisionHandler(.cancel)
//            return
//        } else {
//            decisionHandler(.allow)
//            return
//            
//        }
//    }
}

//MARK: - KVO
extension CODGenericWebVC {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == kProgress, object as! WKWebView == webView {
            progressView.progress = Float(webView.estimatedProgress)
            if progressView.progress == 1 {
                /*
                 *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
                 *动画时长0.25s，延时0.3s后开始动画
                 *动画结束后将progressView隐藏
                 */
                UIView.animate(withDuration: 0.25, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.4)
                }) { (finish) in
                }
            }
        } else if keyPath == kTitle {
            navigationItem.title = webView.title;
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
