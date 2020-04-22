//
//  ConstantNetwork.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import HandyJSON

extension Constants {
    
    /// 网络状况
    enum NetworkStatusType {
        /// 未知
        case unknow
        /// 断网
        case notReachable
        /// 有网
        case reachable
    }
    
    /// 接口错误码
    enum StatusCode: Int, HandyJSONEnum {
        
        /// 未知（本地）
        case unknow = -90001
        
        /// 取消（URLError）
        case cancelled = -999
        /// 超时（URLError）
        case timedOut = -1001
        /// 无网络（URLError）
        case noNetwork = -1009
        
        /// 成功
        case success = 0
        
        /// 请求失败
        case requestFailed = 20001
        /// 参数错误
        case paramIncorrect = 20002
        /// 登录手机号不存在(如果该手机号不存在或者用户角色不为游客或者企业用户     返回  401  Unauthorized)
        case loginTelErr = 20003
        /// 验证码错误 或者失效
        case loginVerifyCodeErr = 20004
        /// 企业信息不匹配
        case identifyActiveNoMatch = 20006
        /// 当该驾驶员绑定手机号大于等于3个时
        case identifyActiveTooPhone  = 20007
        /// 该微信已经被绑定
        case wechatBeenBound = 20008
        /// 验证码发送过于频繁，请稍后再试
        case senderCodeTooMuch  = 20009
        /// 低于当前强制更新版本
        case lowerMandatoryVersion = 20010
        
        /// 账号在其他终端登录
        case tokenInvalid = 401
        /// 从服务器获取数据错误
        case serverGetDataFailed = -102
        /// 账号或密码错误
        case accountOrPasswordError = 20011
        /// 用户已存在（管理员新增成员）
        case telBeenAdded =  20012
        /// 驭驾车队长App二期新增,需从新登陆
        case useridIsIsNil  = 20013
        /// 分组名创建重复
        case groupNameAlredyExist = 20016
        
        /// 服务器异常
        case serverException_403 = 403
        /// 服务器异常
        case serverException_404 = 404
        /// 服务器异常
        case serverException_500 = 500
        /// 服务器异常
        case serverException_502 = 502
        
        /// 网络连接错误
        case serverConnectionError_101 = -101
        /// 网络连接错误
        case serverConnectionError_503 = 503
        /// 网络连接错误
        case serverConnectionError_504 = 504
        
        
    }
    
    /// url地址
    struct Url {
        
        /// 基础地址
        static var baseUrl: String {
            switch Config.env {
            case .DEV:
                return "http://192.168.40.236:15908"
            case .QA:
                return "http://192.168.40.1:9703/captain"
            case .DEMO:
                return "https://api-demo.yudaodata.com/captain"
            case .MARVAL:
                return DataCenter.shared.dynamicConfig.value?.getBaseUrl() ?? "https://api.yudaodata.com/captain"
            }
        }
        
        /// 动态配置地址
        static var dynamicConfigUrl = "http://192.168.40.236:15908/mobile/config/query"
        
        /// 隐私政策地址
        static var privacyPolicyUrl = DataCenter.shared.dynamicConfig.value?.privacyPolicyUrl ?? "http://119.3.38.104:8088/sample/privacyPolicy.html"
        
        /// 地址解析
        static var  reverseGeoCode :String {
            return  "http://api.map.baidu.com/geocoder/v2/?ak=VXzGVxtAHNMXt3rc7BxpfjF4AhT1vNIT&callback=renderReverse&output=json&pois=0"
        }
        
        /// 我的运单地址
        static var myWayBillUrl = DataCenter.shared.dynamicConfig.value?.h5PageWayBillUrl ?? "http://4npzh9.natappfree.cc/login1"
        
        /// app 跳转地址
        static var appStoreUrl: String { return DataCenter.shared.dynamicConfig.value?.iosAppStoreUrl ?? "itms-apps://itunes.apple.com/cn/app/id1443690047?mt=8" }
        
        // MARK: - 接口路径：
        
        /// 检测新版本
        static var checkNewVersion: String { return baseUrl + "/appversion/getLatestModuleVersion" }
        
        /// 手机号是否注册
        static var checkUserExists: String { return baseUrl + "/captain/checkUserExist" }
        /// 管理员登录
        static var adminLoginUrl: String { return baseUrl + "/checkUserExists" }
        /// 验证码登录
        static var codeLoginUrl: String { return baseUrl + "/captain/login" }
        /// 注册接口
        static var registerUrl: String { return baseUrl + "/captain/register" }
       /// 发送验证码
        static var sendCodeUrl: String { return baseUrl + "/verifyCode/sendCaptainAppVerifyCode" }
       /// 用户信息
        static var userInfoUrl: String { return baseUrl + "/usermanagement/getUserInfo" }

        /// 添加用户
        static var addUserUrl: String { return baseUrl + "/usermanagement/addUserCaptain" }
        /// 删除用户
        static var deleteUserUrl: String { return baseUrl + "/usermanagement/deleteUserCaptainByTel" }
        /// 编辑用户
         static var editUserUrl: String { return baseUrl + "/usermanagement/updateUserCaptain" }
        
        /// 用户列表
        static var userListUrl: String { return baseUrl + "/usermanagement/getUserCaptainList" }
        /// 获取告警类型
        static var alarmTypeUrl: String { return baseUrl + "/alarmMobile/getAlarmType" }
        
        /// 报警历史列表
        static var alarmListUrl: String { return baseUrl + "/alarmMobile/getMobileAlarmList" }
        /// 报警详情
         static var alarmDetailUrl: String { return baseUrl + "/alarmMobile/detailAlarm" }
        /// 报警数总计
        static var alarmCountUrl: String { return baseUrl + "/alarmMobile/getAlarmTotalCount" }
        /// 在线数总计
        static var onlineCountUrl: String { return baseUrl + "/alarmMobile/getOnlineVehicleCountAndDriverIcLog" }
        /// 报警各类型数总计
        static var alarmTypeCountUrl: String { return baseUrl + "/alarmMobile/getAlarmTypesTotalCount" }
        /// 报警趋势
        static var alarmTrendUrl: String { return baseUrl + "/alarmMobile/alarmTrend" }
        /// 司机列表
        static var driverListUrl: String { return baseUrl + "/addressbook/queryAddressBooks" }
    
        /// 添加司机
        static var addDriverUrl: String {return baseUrl + "/addressbook/addAddressBook"}
        
        /// 编辑s司机
        static var editDriverUrl: String {return baseUrl + "/addressbook/updateAddressBook"}
        /// 删除司机
        static var deleteDriverUrl: String {return baseUrl + "/addressbook/deleteAddressBook"}
        /// 待办事项列表
        static var expireMemosUrl: String {return baseUrl + "/memo/queryExpireMemos"}
        /// 更新待办事项
        static var updateMemosUrl: String {return baseUrl + "/memo/updateMemo"}
        /// 删除待办事项
        static var deleteMenosUrl: String {return baseUrl + "/memo/deleteMemo"}
        /// 新增待办事项
        static var addMemosUrl: String {return baseUrl + "/memo/addMemo"}
        /// 模糊查询待办事项
        static var queryMemosUrl: String {return baseUrl + "/memo/queryMemo"}
        /// 上传图片
        static var uploadMenosImageUrl: String {return baseUrl + "/memo/uploadPicture"}
        /// 获取车辆通道
        static var getVehicleChannelUrl: String {return baseUrl + "/vehicle/getVehicleChannel"}
        /// 获取车辆gps
        static var getVehicleGpsUrl: String {return baseUrl + "/vehicle/lastGpsByVehicleId"}
        /// 开始播放
        static var startVideoUrl: String {return baseUrl + "/video/startVideo"}
        /// 视频播放心跳
        static var heartbeatUrl: String {return baseUrl + "/video/heartbeat"}
        /// 查看实时监控的车
        static var getCanSendCommandVehiclesUrl: String {return baseUrl + "/vehicle/getCanSendCommandVehiclesTop"}
        /// 搜车辆
        static var searchCanSendCommandVehiclesUrl: String {return baseUrl + "/vehicle/getCanSendCommandVehiclesByCarLicense"}
        
        /// 查看gps分组
        static var getGroupsListUrl: String {return baseUrl + "/gps/getGroups"}
        /// 添加gps分组
        static var addGroupUrl: String {return baseUrl + "/gps/addGroup"}
        /// 删除gps分组
        static var deleteGroupUrl: String {return baseUrl + "/gps/removeGroup"}
        /// 编辑gps分组
        static var editGroupUrl: String {return baseUrl + "/gps/updateVehicleInfoGroup"}
        /// 查询某企业下所有的车辆列表
        static var queryAllVehicleGroupUrl: String {return baseUrl + "/gps/getAllVehicles"}
        /// 查询所有车辆gps信息
        static var queryAllVehicleGpsUrl: String {return baseUrl + "/gps/queryAllVehiclesLastGps"}
        /// 查询某些车辆gps信息
        static var queryVehicleGpsUrl: String {return baseUrl + "/gps/queryVehiclesLastGps"}
        /// 轨迹回放
        static var vehiclePlaybackUrl: String {return baseUrl + "/gps/playback"}



        /// 司机百公里报警排名
        static var queryRankingOfDrive: String {return baseUrl + "/alarm/queryRankingOfDrive"}
        /// 车辆百公里报警排名
        static var queryRankingOfVehicle: String {return baseUrl + "/alarm/queryRankingOfVehicle"}

    }
    
}
