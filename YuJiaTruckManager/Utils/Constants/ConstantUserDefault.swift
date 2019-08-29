//
//  ConstantUserDefault.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation

extension Constants {
    
    /// UserDefault key
    enum UserDefault: String {
        
        /// 动态配置
        case dynamicConfig = "YuJiaTruckManager_dynamicConfig"
        
        /// token
        case token = "YuJiaTruckManager_token"
        /// 账户
        case account = "YuJiaTruckManager_account"
        
        /// 用户信息
        case userInfo = "YuJiaTruckManager_userInfo"
        /// 用户详情
        case userDetail = "YuJiaTruckManager_userDetail"
        /// 智能语音开关
        case openSmartVoice = "YuJiaTruckManager_openSmartVoice"
        
        ///时间戳
        case timeStamp = "YuJiaTruckManager_timeStamp"
        ///手机号（时间戳）
        case timestampPhone = "YuJiaTruckManager_timestampPhone"
        
        /// 闹钟提醒信息
        case remindClock = "YuJiaTruckManager_remindClock"
        /// 直播开始时间
        case liveStartTime = "YuJiaTruckManager_liveStartTime"
        /// 失败的时间
        case liveFailTime = "YuJiaTruckManager_liveFailTime"

        /// 上次心跳时间
        case lastLiveHeartBeatTime = "YuJiaTruckManager_lastLiveHeartBeatTime"
        
    }
    
}
