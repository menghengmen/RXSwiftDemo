//
//  RouterDefine.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift

/// 路由命名空间
struct Router {}

/// 驭驾路由跳转
protocol YuJiaPage: RouterPageProtocol {
    /// 来自驭驾内部的基础路径
    static var baseUrlByYuJia: Router.BaseUrl { get }
}

extension YuJiaPage {
    /// baseUrl的自动实现
    static var baseUrl: String { return baseUrlByYuJia.rawValue }
}

extension Router {
    
    // MARK: - 基础URL
    enum BaseUrl: String {
        
        /// 空
        case none = ""
        
        /// 跳转appstore
        case appStore = "itms-apps://"
        
        ///  全局
        case global = "yujiaappinsidepage://global/:type"
        /// 登录
        case login = "yujiaappinsidepage://login/:type"
        /// 首页
        case home = "yujiaappinsidepage://home/:type"
        /// 用户中心
        case userCenter = "yujiaappinsidepage://userCenter/:type"
        /// 智能语音
        case smartVoice = "yujiaappinsidepage://smartVoice/:type"

        
    }
    
    // MARK: - 全局页面路由
    enum Global: String, YuJiaPage {
        
        static var baseUrlByYuJia: Router.BaseUrl { return .global }
        
        /// 需要登录，参数：isShowCloseBtn
        case needLogin = "needLogin"
        
        static func reigster() {
            
            RouterManager.shared.registerRouter(Global.self) { (type, param) -> RouterCompletionObject in
                
                let completion = RouterCompletionObject()
                
                switch type {
                case .needLogin:
                    // 默认不显示关闭
                    let isShowClose = (param?["isShowCloseBtn"] as? Bool) ?? false
                    let loginVC = Factory.loginPage(isShowClose: isShowClose)
                    let nav = BaseNAV(rootViewController: loginVC)
                    
                    completion.controller = nav
                    completion.jumpType = .modal
                }
                
                return completion
            }
            
        }
        
    }
    
    // MARK: - 登录/注册
    enum Login: String, YuJiaPage {
        
        static var baseUrlByYuJia: Router.BaseUrl { return .login }
        
        /// 关闭
        case close = "close"
        /// 发送验证码
        case verifyCode = "verifyCode"
        /// 调转到管理员登录j界面
        case adminLogin = "adminLogin"
        /// 跳转隐私政策页面
        case goPrivacyPolicy = "goPrivacyPolicy"
       
        case goStoreDetail = "goStoreDetail"

        
        static func reigster() {
            
            RouterManager.shared.registerRouter(Login.self) { (type, param) -> RouterCompletionObject in
                
                let completion = RouterCompletionObject()
                
                switch type {
                case .close:
                    completion.jumpType = .dismiss
                
                case .adminLogin:
                    completion.jumpType = .push
                    let adminLoginVC = Factory.adminLoginPage()
                    completion.controller = adminLoginVC
                case .verifyCode:
                    completion.jumpType = .push
                    let verifyCodeVC = Factory.verifyCodePage(tel: param?["tel"] as? String ?? "",registered :param?["registered"] as? Bool ?? false)
                    completion.controller = verifyCodeVC
                case .goPrivacyPolicy:
                    completion.jumpType = .push
                    let vc = Factory.privacyPolicyPage()
                    vc.hidesBottomBarWhenPushed = true
                    completion.controller = vc
                case .goStoreDetail:
                    completion.jumpType = .push
                    let vc = Factory.storeDetail()
                    vc.hidesBottomBarWhenPushed = true
                    completion.controller = vc
                }
                
                return completion
            }
            
        }
    }
    
    // MARK: - 用户中心
    enum UserCenter: String, YuJiaPage {
        
        static var baseUrlByYuJia: Router.BaseUrl { return .userCenter }
        
        /// 用户管理
        case userManager = "userManager"
        /// 编辑用户
        case editUser = "editUser"
        ///pop到上一个界面
        case popBack = "popBack"
        
        /// 报警事件
        case alarmList = "alarmList"
        /// 报警详情页，参数：alarmId,address(可空)，
        case goDetail = "goDetail"
        /// 跳转到图片/视频附件列表页，参数：attachType, files
        case goImageList = "goImageList"
        /// 跳转轨迹回放页，参数：alarmDetail
        case goTrackReplay = "goTrackReplay"
        /// 筛选界面
        case filterVC = "filterVC"
        /// 关闭筛选界面
        case closeFilterVC = "closeFilterVC"
        
        /// 关于我们
        case aboutUs = "aboutUs"
        /// 实时监控，字段：vehicleId（单选车辆），carLicense（单选车辆），status（单选车辆）
        case moniter = "moniter"
        /// 搜车
        case searchCar = "searchCar"
        /// 我的司机
        case myDriver = "myDriver"
        /// 编辑司机
        case editDriver = "editDriver"
        /// 管车助手
        case reminder = "reminder"
        /// 备忘录
        case menos = "menos"
        /// 排名统计
        case rankList = "rankList"
        /// 我的运单
        case myWaybill = "myWaybill"
        /// 设置
        case settings = "settings"
        
        /// GPS 位置
        case vehicleGps = "vehicleGps"
        /// gps 筛选车辆，字段：callback
        case vehicleFilter = "vehicleFilter"
        /// gps 搜索车辆，字段：callback
        case vehicleSearch = "vehicleSearch"
        /// gps 分组管理
        case groupManager = "groupManager"
        /// gps 分组编辑
        case groupEdit = "groupEdit"
        /// gps 添加车辆
        case groupAddVehicle = "groupAddVehicle"
        /// gps 添加分组
        case addGroup = "addGroup"

        


        
        static func reigster() {
            
            RouterManager.shared.registerRouter(UserCenter.self) { (type, param) -> RouterCompletionObject in
                
                let completion = RouterCompletionObject()
                
                switch type {
               
                    
                case .userManager:
                    completion.jumpType = .push
                    let managerUserVC = Factory.userManagerPage()
                    managerUserVC.hidesBottomBarWhenPushed = true
                    completion.controller = managerUserVC
                case .alarmList:
                    completion.jumpType = .push
                    let alarmListVC = Factory.alarmPage()
                    alarmListVC.hidesBottomBarWhenPushed = true
                    completion.controller = alarmListVC
                case .aboutUs:
                    completion.jumpType = .push
                    
                    let aboutUsVC = Factory.aboutUsPage()
                    aboutUsVC.hidesBottomBarWhenPushed = true
                    completion.controller = aboutUsVC
                case .editUser:
                    completion.jumpType = .push
                    let editUserVC = Factory.editUserPage(name: param?["name"] as? String ?? "",tel: param?["tel"] as? String ?? "",isCreateUser:param?["isCreateUser"] as? Bool ?? false)
                    editUserVC.hidesBottomBarWhenPushed = true

                    completion.controller = editUserVC
                case .popBack:
                    completion.jumpType = .pop
                case .filterVC:
                     let filterVC = Factory.filterVCPage(callback: param?["didSaveFilter"] as? PublishSubject<AlarmListFilter>)
                     let nav = BaseNAV(rootViewController: filterVC)
                     completion.controller = nav
                     completion.jumpType = .modal
                case .closeFilterVC:
                    completion.jumpType = .dismiss

                case .goDetail:
                    let detailVC = Factory.alarmDetailPage(alarmId: param?["alarmId"] as? String ?? "", address: param?["address"] as? String, coordinate: param?["coordinate"] as? CLLocationCoordinate2D)
                    completion.controller = detailVC
                    completion.jumpType = .push
                case .goImageList:
                    let detailVC = Factory.alarmImageListPage(type: param?["attachType"]  as? ReqAlarmDetail.AttachType ?? .image, files: param?["files"] as? [ReqAlarmDetail.File] ?? [])
                    detailVC.hidesBottomBarWhenPushed = true
                    completion.controller = detailVC
                    completion.jumpType = .push
                    
                case .goTrackReplay:
                    if let data = param?["alarmDetail"] as? ReqAlarmDetail.Data {
                        let trackVC = Factory.trackReplayPage(data: data)
                        trackVC.hidesBottomBarWhenPushed = true
                        completion.controller = trackVC
                        completion.jumpType = .push
                    }
                    
                case .myDriver:
                    completion.jumpType = .push
                    let myDriverVC = Factory.myDriverPage(type: param?["type"] as! MyDriversListVM.MyDriverListType)
                    myDriverVC.hidesBottomBarWhenPushed = true
                    completion.controller = myDriverVC
                case .editDriver:
                    completion.jumpType = .push
                    let editDriverVC = Factory.editDriverPage(name: param?["name"] as? String ?? "",tel: param?["tel"] as? String ?? "",isCreateDriver :param?["isCreateDriver"] as? Bool ?? false, id : param?["id"] as? String ?? "")
                    editDriverVC.hidesBottomBarWhenPushed = true
                    completion.controller = editDriverVC
                case .moniter:
                    completion.jumpType = .push
                    let moniterVC = Factory.moniterPage(vehicleId: param?["vehicleId"] as? String, carLicense: param?["carLicense"] as? String, status: param?["stauts"] as? ReqQueryAllVehiclesGps.VehicleStatus)
                    moniterVC.hidesBottomBarWhenPushed = true
                    completion.controller = moniterVC
                case .reminder:
                    completion.jumpType = .push
                    let reminderVC = Factory.reminderPage()
                    reminderVC.hidesBottomBarWhenPushed = true
                    completion.controller = reminderVC
                case  .menos:
                   completion.jumpType = .push
                   let menosVC = Factory.menosPage(type: param?["type"] as! ReminderDetailVM.RemindDetailType,menosId : param?["menosId"] as? String ?? "", isStar: param?["isStar"] as? Bool ?? false,createTime :param?["createTime"] as? Date,remindTime :param?["remindTime"] as? Date, expireTime :param?["expireTime"] as? Date, content : param?["content"] as? String ?? "",picture : param?["picture"] as? String ?? "")
                   menosVC.hidesBottomBarWhenPushed = true
                   completion.controller = menosVC
                    
                case .searchCar:
                    completion.jumpType = .push
                    let moniterVC = Factory.moniterCarPage(finish: param?["didSelectCarFinish"] as? PublishSubject<(String,String)> ?? PublishSubject<(String,String)>())
                    moniterVC.hidesBottomBarWhenPushed = true
                    completion.controller = moniterVC

                case .vehicleGps:
                    completion.jumpType = .push
                    let reminderVC = Factory.vehicleGpsPage()
                    reminderVC.hidesBottomBarWhenPushed = true
                    completion.controller = reminderVC
                case .vehicleFilter:
                    let filterVC = Factory.filterVehicleVCPage(callback: param?["callback"] as? PublishSubject<Set<ReqGetGroups.CarData>>)
                   /// let nav = BaseNAV(rootViewController: filterVC)
                    completion.controller = filterVC
                    completion.jumpType = .push
                case .vehicleSearch:
                    completion.jumpType = .push
                    let searchVehicleVC = Factory.searchVehicleVCPage(callback: param?["callback"] as? PublishSubject<Set<ReqQueryAllVehiclesGps.Data>>)
                    searchVehicleVC.hidesBottomBarWhenPushed = true
                    completion.controller = searchVehicleVC
                case .groupManager:
                    completion.jumpType = .push
                    let groupManagerVC = Factory.groupManagerVCPage()
                    groupManagerVC.hidesBottomBarWhenPushed = true
                    completion.controller = groupManagerVC
                case .groupEdit:
                    completion.jumpType = .push
                    let groupEditVC = Factory.groupEditVCPage(groups:  (param?["groups"] as? ReqGetGroups.Data)! )
                    groupEditVC.hidesBottomBarWhenPushed = true
                    completion.controller = groupEditVC
                case .groupAddVehicle:
                    let addVehicleVC = Factory.groupAVehicleVCPage(callback: param?["callback"] as? PublishSubject<Set<ReqGetAllVehiclesGroup.Data>>)
                    let nav = BaseNAV(rootViewController: addVehicleVC)
                    completion.controller = nav
                    completion.jumpType = .modal
                case .addGroup:
                    completion.jumpType = .push
                    let addGroupVC = Factory.groupAddGroupVCPage()
                    addGroupVC.hidesBottomBarWhenPushed = true
                    completion.controller = addGroupVC
                case .rankList:
                    completion.jumpType = .push
                    
                    let rankListVC = Factory.rankListVCPage()
                    rankListVC.hidesBottomBarWhenPushed = true
                    completion.controller = rankListVC
                case .myWaybill:
                    completion.jumpType = .push
                    let vc = Factory.myWaybillPage()
                    vc.hidesBottomBarWhenPushed = true
                    completion.controller = vc
                    
                case .settings:
                    completion.jumpType = .push
                    let vc = Factory.settingsPage()
                    vc.hidesBottomBarWhenPushed = true
                    completion.controller = vc
                }
                
                return completion
            }
            
        }
    }
    
    // MARK: - 智能语音
    enum SmartVoice: String, YuJiaPage {
        
        static var baseUrlByYuJia: Router.BaseUrl { return .smartVoice }
        
        /// 打开智能语音
        case open = "open"
        /// 点击实时监控
        case monitor = "monitor"
        /// 点击管车助手
        case reminder = "reminder"
        /// 点击我的司机
        case myDriver = "myDriver"
        /// 点击报警事件
        case alarm = "alarm"
        /// 点击排名统计
        case rank = "rank"
        /// 点击gps位置
        case gps = "gps"
        /// 点击我的运单
        case myWaybill = "myWaybill"
        
       
        static func reigster() {
            
            RouterManager.shared.registerRouter(SmartVoice.self) { (type, param) -> RouterCompletionObject in
                
                let completion = RouterCompletionObject()
                
                switch type {
                case .open:
                    completion.jumpType = .push
                    let vc = Factory.smartVoicePage()
                    vc.hidesBottomBarWhenPushed = true
                    completion.controller = vc
                    
                case .monitor:
                    completion.jumpType = .push
                    let vc = Factory.moniterPage()
                    vc.hidesBottomBarWhenPushed = true
                    completion.controller = vc
                    
                case .reminder:
                    completion.jumpType = .push
                    let vc = Factory.reminderPage()
                    vc.hidesBottomBarWhenPushed = true
                    completion.controller = vc
                    
                case .myDriver:
                    completion.jumpType = .push
                    let myDriverVC = Factory.myDriverPage(type: .lookDriver)
                    myDriverVC.hidesBottomBarWhenPushed = true
                    completion.controller = myDriverVC
                    
                case .alarm:
                    completion.jumpType = .push
                    let alarmListVC = Factory.alarmPage()
                    alarmListVC.hidesBottomBarWhenPushed = true
                    completion.controller = alarmListVC
                    
                case .rank:
                    completion.jumpType = .push
                    let rankListVC = Factory.rankListVCPage()
                    rankListVC.hidesBottomBarWhenPushed = true
                    completion.controller = rankListVC
                    
                case .gps:
                    completion.jumpType = .push
                    let vc = Factory.vehicleGpsPage()
                    vc.hidesBottomBarWhenPushed = true
                    completion.controller = vc
                    
                case .myWaybill:
                    completion.jumpType = .push
                    let vc = Factory.myWaybillPage()
                    vc.hidesBottomBarWhenPushed = true
                    completion.controller = vc
            
                }
                
                return completion
                
            }
            
        }
        
    }
    
}
