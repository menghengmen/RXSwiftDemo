//
//  ConstantConfig.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import HandyJSON

/// 常量空间
struct Constants {}


extension Constants {
    
    /// 测试环境
    enum Environment {
        /// 开发
        case DEV
        /// 测试
        case QA
        /// 预发布
        case DEMO
        /// 正式
        case MARVAL
    }
    
    /// 配置信息
    struct Config {
        
        /// 测试环境
        static var env = Environment.QA
        
        /// 验证码倒计时
        static var countTime: Int { return 60 }
        /// 看直播时间
        static var playTime: TimeInterval { return 60 }
        /// 直播心跳间隔
        static var playHeartBeatInterval: TimeInterval { return 5 }
        /// 直播重试间隔
        static var playRetrytInterval: TimeInterval { return 1 }
    }
    
    /// 动态配置（通过接口获得）
    struct DynamicConfig: HandyJSON {
        
        /// 接口协议（http/https）
        var serverProtocol = ""
        /// 域名
        var serverHost = ""
        /// 端口
        var serverPort = ""
        /// 路径
        var serverPath = ""
        /// 我的运单url
        var h5PageWayBillUrl = ""
        /// 隐私协议url
        var privacyPolicyUrl = ""
        /// ios商店地址
        var iosAppStoreUrl = ""
        
        init() {
            
        }
        
        init(from serverData: [ReqGetDynamicConfig.Data]) {
            
            self.init()
            
            for aData in serverData {
                
                switch aData.key {
                case "serverProtocol":
                    serverProtocol = aData.key
                case "serverHost":
                    serverHost = aData.key
                case "serverPort":
                    serverPort = aData.key
                case "serverPath":
                    serverPath = aData.key
                case "h5PageWayBillUrl":
                    h5PageWayBillUrl = aData.key
                case "privacyPolicyUrl":
                    privacyPolicyUrl = aData.key
                case "iosAppStoreUrl":
                    iosAppStoreUrl = aData.key
                default:
                    break
                }
            }
        }
        
        /// 拼接请求地址
        func getBaseUrl() -> String? {
            
            guard serverProtocol.count > 0 && serverHost.count > 0 &&  serverPort.count > 0 else {
                return nil
            }
            
            var fullUrl = serverProtocol + serverHost + ":" + serverHost
            
            if serverPath.count > 0 {
                fullUrl += "/" + serverPath
            }
            
            return fullUrl
        }
    }
    
    /// appkey等信息
    struct AppKey {
        
        /// 百度地图授权Key
        static var baiduMapApiKey: String { return "YN2GN1D7TGhl6dpKER5rfYulnKtNldc0" }
        /// 讯飞语音
        static var iflyAppid: String { return "5c3c5d62" }
        /// umeng统计 key
        static var uMengKey: String { return "5c3c57dab465f5bc05000611" }
        
    }
    
    /// 演示账号信息
    struct DemoAccount {
        /// 手机号 或管理员登录的账号
        static var phoneNumber: String { return "12300000009" }
        /// 验证码 管理员登录账号的密码
        static var verifyCode: String { return "888888" }
        /// 账号类型
        static var accountType: String { return "1" }
       /// 公司名
        static var companyName: String { return "南京顺君运输有限公司" }
        /// 姓名i
        static var name: String { return "杨裕兴" }
        /// 组织id
        static var groupId: String { return "DEMO_GroupId" }

        /// token
        static var token: String { return "DEMO_SDsdnSANDosasDsnn?SDkasdlaODsaod" }
    }
    
}
