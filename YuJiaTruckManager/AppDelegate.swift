//
//  AppDelegate.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import IQKeyboardManagerSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /// 百度地图
    var mapManager: BMKMapManager?
    
    
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        /// 设置UI
        setupUI()
        
        /// 注册路由
        registerAllRouters()
        
        /// 数据中心初始化
        _ = DataCenter.shared
        
        // 百度地图
        setupBaiduMap()
        
        /// 配置讯飞语音
        setupIFly()
        
        /// 初始化友盟统计
        setupUmeng()
        
        /// 加载完成
        MessageCenter.shared.didFinishLaunch.onNext(())
        
        /// 角标清0
        application.applicationIconBadgeNumber = 0
       
        mLog("【推送】：当前推送:\(UIApplication.shared.scheduledLocalNotifications ?? [])")
        
        return true
    }

    // MARK: - 路由
    
    func registerAllRouters() {
        
        // 内部页面跳转
        Router.Global.reigster()
        Router.Login.reigster()
        Router.UserCenter.reigster()
        Router.SmartVoice.reigster()
        
    }
    
    
    // MARK: - UI
    
    func setupUI() {
        
        /// 颜色
        window?.backgroundColor = .white
        UINavigationBar.appearance().barTintColor = Constants.Color.blue
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        /// 键盘处理
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    // MARK: - SDK
    
    func setupBaiduMap() {
        mapManager = BMKMapManager()
        let ret = mapManager?.start(Constants.AppKey.baiduMapApiKey, generalDelegate: self)
        
        if ret == false {
            mLog("【百度地图】启动失败!")
        }
        
    }
    
    func setupIFly() {
        IFlySpeechUtility.createUtility("appid=\(Constants.AppKey.iflyAppid)")
    }
    
    func setupUmeng() {
        if Constants.Config.env == .MARVAL {
            UMConfigure.initWithAppkey(Constants.AppKey.uMengKey, channel: "App Store")
            UMConfigure.setLogEnabled(true)
            UMConfigure.setEncryptEnabled(true)
        }
    }

    // MARK: - 推送回调
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        var remindInfo = RemindClockInfo()
        remindInfo.content = notification.alertBody
        remindInfo.fireDate = notification.fireDate
        remindInfo.id  = notification.userInfo?["id"] as? String
        
        MessageCenter.shared.needShowClock.onNext(remindInfo)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        /// 角标清0
        application.applicationIconBadgeNumber = 0
    }
    

}


// MARK: - BMKGeneralDelegate
extension AppDelegate: BMKGeneralDelegate {
    
    func onGetNetworkState(_ iError: Int32) {
        mLog("【百度地图】onGetNetworkState：\(iError)")
    }
    
    func onGetPermissionState(_ iError: Int32) {
        mLog("【百度地图】onGetPermissionState：\(iError)")
    }
    
}
