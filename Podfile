platform :ios, '10.0'
use_frameworks!

def commanPod

          pod 'XMPPFramework/Swift', git: 'http://codtest.xinhoo.com:28889/COD_IM/XMPPFramework.git'
          pod 'BaiduMapKit', '~> 5.3.0'
          pod 'BMKLocationKit'
          pod 'Alamofire', '5.1.0'
          pod 'SwiftyJSON', '~> 4.2.0'
          pod 'HandyJSON', git: 'https://github.com/alibaba/HandyJSON.git'
          pod 'SnapKit', '~> 5.0.1'
          pod 'SDWebImage', '5.0.0-beta5'
          pod 'SwifterSwift', '~> 5.0.0'
          pod 'IQKeyboardManagerSwift', '~> 6.2.0'
          pod 'KeyboardMan', '~> 1.2.3'
          pod 'SVProgressHUD', '~> 2.2.5'
          pod 'RealmSwift', '5.3.2'
          pod 'TZImagePickerController', '~> 3.3.1'        # 图片选择
          pod 'SwipeCellKit', '~> 2.5.1'
          pod 'EmptyDataSet-Swift', '~> 4.2.0'
          pod 'ReactiveCocoa', '~> 9.0.0'
          pod 'pop', '~> 1.0.12'
          pod 'LPActionSheet', '~> 1.0'
          pod 'PopupKit', '~> 3.1.1'
          pod 'CYLTabBarController', '~> 1.28.3'
          pod 'YYText', '~> 1.0.7'
          pod 'GoogleWebRTC'
          pod 'MBProgressHUD'
          pod 'MJRefresh', '3.2.0'
          pod 'Bugly', '~> 2.5.0'
          pod 'FLAnimatedImage', git: 'https://github.com/Flipboard/FLAnimatedImage.git', tag: '1.0.14'
          pod 'RxSwift', '5.1.1'
          pod 'RxCocoa', '5.1.1'
          pod 'LGAlertView', '~> 2.4.0'
  	      pod 'RxRealm', '3.1.0'
          pod 'UIView+FDCollapsibleConstraints', '1.0'
          pod 'Aspects', '1.4.1'
          pod 'RxSwiftExt', '5.2.0'
          pod 'RxDataSources', '4.0.1'
          pod 'RxOptional', '4.1.0'
          pod 'SwiftDate', '6.1.0'
          pod 'NSObject+Rx'
          pod 'DoraemonKit'
          pod 'TextureSwiftSupport', :git => 'https://github.com/TextureCommunity/TextureSwiftSupport.git'
          pod 'MulticastDelegateSwift'
          pod 'AppCenter'
          pod 'NextGrowingTextView'
          pod 'RxDataSources-Texture'
          pod 'JXPhotoBrowser'
          pod 'CodableAlamofire'
          pod 'Texture'
          pod 'FDFullscreenPopGesture', '1.1'
          pod 'IGListKit', '4.0.0'
          pod 'SSZipArchive'
          pod 'PhoneNetSDK', :git => 'https://github.com/bay2/net-diagnosis.git'
          pod 'MZTimerLabel', '0.5.4'

end

target 'COD'  do

  commanPod

  pod 'EchoSDK', :git => 'https://github.com/didi/echo.git'
  pod 'Reveal-SDK', :configurations => ['Debug']
end

target 'COD_Pro'  do
  commanPod
end

target 'COD_Mango'  do
  commanPod
end

target 'CODUnitTests'  do
  commanPod
  
  pod 'Quick'
  pod 'Nimble'
end

post_install do |installer|

  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['OTHER_CFLAGS'] = '-Xclang -fcompatibility-qualified-id-block-type-checking'
    end
  end
end




