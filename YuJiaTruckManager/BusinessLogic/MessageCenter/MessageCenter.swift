//
//  MessageCenter.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// app全局消息中心
class MessageCenter: NSObject {

    /// 单例
    static let shared = MessageCenter()
    
    // MARK: - 需要弹框或UI处理：
    
    /// 是否需要显示登录页
    let needLogin = PublishSubject<Bool>()
    /// 需要弹出版本更新页面
    let needUpdateVersion = PublishSubject<ReqGetNewVersion.Data>()
    /// 需要显示在其他设备上登录
    let needTokenInvalid = PublishSubject<Void>()
    /// 需要跳转appStore
    let needGoAppStore = PublishSubject<Void>()
    /// 闹钟到时间
    let needShowClock = PublishSubject<RemindClockInfo>()
    
    // MARK: - 事件通知：
    
    /// 更新配置
    let didUpdateDynamicConfig = PublishSubject<Constants.DynamicConfig?>()
    
    /// app加载完成事件
    let didFinishLaunch = PublishSubject<Void>()
    /// 根页面（Tab）加载完成
    let didLoadRootPage = PublishSubject<Void>()
    
    /// 登录
    let didLogin = PublishSubject<ReqLogin.Data>()
    /// 个人信息
    let didGetUserInfo = PublishSubject<ReqUserInfo.Data>()
    /// 已登出
    let didLogout = PublishSubject<Void>()
    
    /// 打电话
    let needCallTelephone = PublishSubject<String>()
    /// 需要发短信
    let needSendMessage   = PublishSubject<String>()
    
    /// 图片选择器
    let needShowImagePick = PublishSubject<Void>()
    /// 选择图片结束
    let didFinishPickImage = PublishSubject<(UIImage?)>()
    

}
