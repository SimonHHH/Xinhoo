//
//  CODGuidePageViewController.swift
//  COD
//
//  Created by xinhooo on 2019/6/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Lottie
typealias complete = () -> Void
class CODGuidePageViewController: UIViewController {

    var completeBlock : complete?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var animationView: UIView!
    
    var lottieView = AnimationView.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        #if MANGO
        let page_0 = "Mango_page_0"
        #elseif PRO
        let page_0 = "page_0"
        #else
        let page_0 = "IM_page_0"
        #endif
        
        let animation = Animation.filepath(Bundle.main.path(forResource: page_0, ofType: "json")!, animationCache: nil)
        lottieView.animation = animation
        lottieView.animationSpeed = 1.5
        animationView.addSubview(lottieView)
        lottieView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.animationView)
        }
        lottieView.play()
        self.configScrollView()
        
    }

    func configScrollView() {
        
        let titleArr:Array<String> = [kApp_Name,NSLocalizedString("效率", comment: ""),NSLocalizedString("惊喜", comment: ""),NSLocalizedString("无限", comment: ""),NSLocalizedString("安全", comment: ""),NSLocalizedString("云端", comment: "")]
        let descArr:Array<String> = [NSLocalizedString("企业级精品聊天工具\n安全又及时", comment: ""),
                                     String.init(format: NSLocalizedString("%@ 以同类软件中高效的速度\n为您传递消息", comment: ""), kApp_Name),
                                     String.init(format: NSLocalizedString("%@ 从每一个细节入手\n为您追求良好的用户体验", comment: ""), kApp_Name),
                                     String.init(format: NSLocalizedString("%@ 无论您的朋友在世界何地\n交流畅通无阻", comment: ""), kApp_Name),
                                     String.init(format: NSLocalizedString("%@ 保证您的消息安全\n不受黑客侵扰", comment: ""), kApp_Name),
                                     String.init(format: NSLocalizedString("%@ 允许您通过多端设备访问\n您的聊天记录", comment: ""), kApp_Name)]

        for i in 0...5 {
            let guidePageView = Bundle.main.loadNibNamed("CODGuidePageView", owner: self, options: nil)?.last as! CODGuidePageView
            guidePageView.titleLab.text = titleArr[i]
            guidePageView.descLab.text = descArr[i]
            scrollView.addSubview(guidePageView)
            guidePageView.snp.makeConstraints { (make) in
                make.top.equalTo(0)
                make.height.equalTo(KScreenHeight)
                make.width.equalTo(KScreenWidth)
                make.left.equalTo(KScreenWidth * CGFloat(i))
            }
            
            
        }
        
        scrollView.contentSize = CGSize.init(width: KScreenWidth * CGFloat(titleArr.count), height: 0)
        pageControl.numberOfPages = titleArr.count
        
    }
    
    @IBAction func beginUseAction(_ sender: Any) {
        if self.completeBlock != nil {
            self.completeBlock!()
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

extension CODGuidePageViewController:UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        var page = Int(scrollView.contentOffset.x/KScreenWidth)
        
        if self.pageControl.currentPage != page {
            
            self.pageControl.currentPage = page
            if page > 5 {
                page = 5
            }
            
            var page_Str = ""
            
            if page == 0{
                #if MANGO
                page_Str = "Mango_page_0"
                #elseif PRO
                page_Str = "page_0"
                #else
                page_Str = "IM_page_0"
                #endif
            }else{
                page_Str = "page_\(page)"
            }
            
            let animation = Animation.filepath(Bundle.main.path(forResource: page_Str, ofType: "json")!, animationCache: nil)
            lottieView.animation = animation
            
            if page == 2{
            
                lottieView.animationSpeed = 0.5
            }else{
                lottieView.animationSpeed = 1.5
            }
            
            lottieView.play()
        }
    }
}
