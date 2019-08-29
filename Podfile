platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs'
source 'http://192.168.40.200/iOS/YuDaoSpecs.git'   # 驭道私有库地址

target 'YuJiaTruckManager' do

  use_frameworks!
  inhibit_all_warnings!

    # Pods for YuJiaTruck

    # 底层相关
    pod 'Alamofire', '~> 4.7'               # 网络库
    pod 'HandyJSON', '~> 5.0.0'             # json转模型
    pod 'SwiftyJSON'                        # Json对象解析
    pod 'RxSwift',    '~> 4.0'              # RxSwift
    pod 'RxCocoa',    '~> 4.0'
    pod 'BlocksKit', '~> 2.2.5'             # block封装(OC)

    # UI
    pod 'SnapKit', '~> 4.0.0'               # 代码添加约束
    pod 'AlamofireImage', '~> 3.3'          # af提供的网络图片与缓存
    pod 'IQKeyboardManagerSwift', '~> 6.0'  # 键盘管理
    pod 'SimpleImageViewer', '~> 1.1.1'     # 查看图片框架
    pod 'MBProgressHUD', '~> 1.1.0'         # toast等待框(OC)
    pod 'VehicleKeyboard-swift'             # 输入车牌号的键盘
    
    # 工具
    pod 'DateToolsSwift'                    # 时间日期d封装
    pod 'WebViewJavascriptBridge', '~> 6.0' # js回调
    
    # 友盟统计
    pod 'UMCCommon'
    pod 'UMCAnalytics'
    pod 'UMCSecurityPlugins'
   
    # 私有
    # pod 'YuDaoComponents', '~> 1.4.0'       # 私有组件库(远端)
     pod 'YuDaoComponents', :path => '../YuDaoComponents'       # 私有组件库(本地)

  target 'YuJiaTruckManagerTests' do
    inherit! :search_paths
    # Pods for testing

  end

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'SimpleImageViewer'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.1'
            end
        end
    end
end
