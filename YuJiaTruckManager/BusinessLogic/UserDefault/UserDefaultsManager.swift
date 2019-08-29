//
//  UserDefaultsManager.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import HandyJSON

/// 本地推送（闹钟）信息
struct RemindClockInfo: HandyJSON {
    
    /// id
    var id: String?
    /// 内容
    var content: String?
    /// 时间
    var fireDate: Date?
}

/// user defaults 管理
class UserDefaultsManager: NSObject {
    
    /// 单例
    static let shared = UserDefaultsManager()
    
    /// 清除所有用户信息
    func clearUp() {
        userInfo = nil
        userDetail = nil
        account = nil
        liveStartTime = nil
        lastLiveHeartBeatTime = nil
    }
    
    /// 动态配置
    var dynamicConfig: Constants.DynamicConfig? {
        set {
            let dic = newValue?.toJSON()
            saveDefaults(dic, forKey: .dynamicConfig)
        }
        get {
            let dic = getDefaults(fromKey: .dynamicConfig) as? [String: Any]
            return Constants.DynamicConfig.deserialize(from: dic)
        }
    }
   
    /// 验证码时间戳
    var timeStamp: Int?{
        set {
            saveDefaults(newValue, forKey: .timeStamp)
        }
        
        get {
            return getDefaults(fromKey: .timeStamp) as? Int
        }
    }
    /// 手机号（时间戳）
    var timestampPhone :String?{
        set {
            saveDefaults(newValue, forKey: .timestampPhone)
        }
        
        get {
            return getDefaults(fromKey: .timestampPhone) as? String
        }
        
        
    }
   
    ///账户
    var account :String?{
        set {
            saveDefaults(newValue, forKey: .account)
        }
        
        get {
            return getDefaults(fromKey: .account) as? String
        }
        
        
        
    }
    
    /// 用户信息
    var userInfo: [String: Any]? {
        set {
            mLog("【用户信息操作】save: \(newValue ?? [:])")
            saveDefaults(newValue, forKey: .userInfo)
        }
        get {
            mLog("【用户信息操作】get")
            return getDefaults(fromKey: .userInfo) as? [String: Any]
        }
    }
    
    /// 详细用户信息
    var userDetail: [String: Any]? {
        set {
            mLog("【用户信息操作】save: \(newValue ?? [:])")
            saveDefaults(newValue, forKey: .userDetail)
        }
        get {
            mLog("【用户信息操作】get")
            return getDefaults(fromKey: .userDetail) as? [String: Any]
        }
        
    }
    
    /// 开关智能语音
    var isEnableOpenSmartVoice: Bool {
        set {
            saveDefaults(newValue, forKey: .openSmartVoice)
        }
        get {
            return (getDefaults(fromKey: .openSmartVoice) as? Bool) ?? true
        }
    }
    
    /// 提醒信息（登出后需要保留）
    var remindClocks: [RemindClockInfo] {
        
        set {
            
            let ary = newValue.toJSON()
            saveDefaults(ary, forKey: .remindClock)
            setSystemClock(newValue)
        }
        get {
            var ary = [RemindClockInfo]()
            
            if let dataFromUd = getDefaults(fromKey: Constants.UserDefault.remindClock) as? [[String: Any]] {
                
                for aDic in dataFromUd {
                    if let infoData = RemindClockInfo.deserialize(from: aDic) {
                        ary.append(infoData)
                    }
                }
            }
            
            return ary
        }
        
    }
    
    /// 播放失败的时间
    var liveFailTime: Date? {
        set {
            saveDefaults(newValue, forKey: .liveFailTime)
        }
        get {
            return getDefaults(fromKey: .liveFailTime) as? Date
        }
        
    }
    
    
    /// 开始直播的时间戳
    var liveStartTime: Date? {
        set {
            saveDefaults(newValue, forKey: .liveStartTime)
        }
        get {
            return getDefaults(fromKey: .liveStartTime) as? Date
        }
    }
    
    /// 上次心跳时间
    var lastLiveHeartBeatTime: Date? {
        set {
            saveDefaults(newValue, forKey: .lastLiveHeartBeatTime)
        }
        get {
            return getDefaults(fromKey: .lastLiveHeartBeatTime) as? Date
        }
    }
    
    /// 存值
    private func saveDefaults(_ anyValue: Any?, forKey key: Constants.UserDefault) {
        UserDefaults.standard.set(anyValue, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    /// 取值
    private func getDefaults(fromKey key: Constants.UserDefault) -> Any? {
        
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
    
    /// 设置推送
    private func setSystemClock(_ infoAry: [RemindClockInfo]) {
        
        mLog("【设置推送】:\(infoAry)")
        
        // 删除之前的
        UIApplication.shared.cancelAllLocalNotifications()
        
        // 是否需要注册
        if infoAry.count > 0 {
            let currentSettings = UIApplication.shared.currentUserNotificationSettings
            
            if currentSettings?.types.contains(.alert) == false {
                // 如果当前没有，注册通知功能
                let settings = UIUserNotificationSettings(types: [.alert, .badge], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
            }
            
        }
        
        // 添加新的
        for aClockInfo in infoAry {
            
            guard aClockInfo.fireDate?.isLater(than: Date()) == true else {
                continue
            }
            
            let noti = UILocalNotification()
            
            noti.fireDate = aClockInfo.fireDate
            noti.alertBody = Constants.Text.remindPushPrefix + (aClockInfo.content ?? "")
            noti.userInfo = ["id": aClockInfo.id ?? ""]
            noti.applicationIconBadgeNumber = 1
            
            UIApplication.shared.scheduleLocalNotification(noti)
        }
        
    }
    
}
