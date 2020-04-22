//
//  RouterFactory.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

extension Router {
    
    /// 路由工厂方法
    class Factory {
        
        /// 登录页
        class func loginPage(isShowClose: Bool) -> LoginVC {
            
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            vc.viewModel = LoginVM(isShowClose: isShowClose)
            
            return vc
        }
        /// 发送验证码页面
        class func  verifyCodePage(tel: String,registered: Bool) ->VerifyCodeVC {
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "VerifyCodeVC") as! VerifyCodeVC
            vc.viewModel = VerifyCodeVM(tel: tel ,registered:registered)
            return vc
        }
        /// 管理员登录
        class func  adminLoginPage() ->AdminLoginVC {
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "AdminLoginVC") as! AdminLoginVC
            vc.viewModel = AdminLoginVM(isShowClose: true)
            return vc
        }
        
        /// 隐私政策
        class func privacyPolicyPage() -> PrivacyPolicyVC {
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
            vc.viewModel = PrivacyPolicyVM()
            return vc
        }
        
        class func storeDetail() -> StoreDetailVC {
            let vc =  StoreDetailVC()
             vc.viewModel = StoreDetailVM()
            return vc
        }
        
        
        
        /// 用户管理
        class func  userManagerPage() ->UserListVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "UserListVC") as! UserListVC
            vc.viewModel = UserListVM()
            return vc
        }
        
        ///编辑用户
        class func  editUserPage(name:String,tel:String,isCreateUser:Bool ) ->UserEditVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "UserEditVC") as! UserEditVC
            vc.viewModel = UserEditVM(isCreateUser:isCreateUser ,name:name ,phone:tel)
            
            return vc
        }
        
        
        /// 报警事件
        class func  alarmPage() ->AlarmListVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "AlarmListVC") as! AlarmListVC
            vc.viewModel = AlarmListVM()
            return vc
        }
        /// 报警详情页面
        class func alarmDetailPage(alarmId: String, address: String?, coordinate: CLLocationCoordinate2D?) -> AlarmDetailVC {
            
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "AlarmDetailVC") as! AlarmDetailVC
            vc.viewModel = AlarmDetailVM(alarmId: alarmId, address: address, coordinate: coordinate)
            return vc
            
        }
        /// 筛选界面
        class func filterVCPage(callback: PublishSubject<AlarmListFilter>?) -> AlarmFilterVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "AlarmFilterVC") as! AlarmFilterVC
            let vm = AlarmFilterVM()
            vc.viewModel = vm
            ///
            if let callbackValue = callback {
                vm.saveFilter.asObservable()
                    .bind(to: callbackValue)
                    .disposed(by: vm.disposeBag)
            }
            
            return vc
        }
        
        /// 附件（图片/视频）列表页
        class func alarmImageListPage(type: ReqAlarmDetail.AttachType, files: [ReqAlarmDetail.File]) -> AlarmImageListVC {
            
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "AlarmImageListVC") as! AlarmImageListVC
            vc.viewModel = AlarmImageListVM(type: type, dataAry: files)
            return vc
            
        }
        
        /// 轨迹回放页
        class func trackReplayPage(data: ReqAlarmDetail.Data) -> TrackReplayVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "TrackReplayVC") as! TrackReplayVC
            vc.viewModel = TrackReplayVM(alarmInfo: data)
            return vc
        }
        
        /// 关于我们
        class func  aboutUsPage() ->AboutVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "AboutVC") as! AboutVC
            return vc
        }
        /// 实时监控
        class func moniterPage(vehicleId: String? = nil, carLicense: String? = nil, status: ReqQueryAllVehiclesGps.VehicleStatus? = nil) -> MonitorDetailVC{
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "MonitorDetailVC") as! MonitorDetailVC
            let vm = MonitorDetailVM()
            
            if vehicleId?.count > 0 && carLicense?.count > 0 {
                vm.isEnableSearchCar.value = false
                vm.currentCarInfo.vehicleId.value = vehicleId
                vm.currentCarInfo.carLicense.value = carLicense
                vm.currentCarInfo.carStatus.value = status
            }
            
            vc.viewModel = vm
            return vc
    
        }
        
        /// 实时监控车两列表
        class func moniterCarPage(finish: PublishSubject<(String,String)>) ->MonitorCarListVC{
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "MonitorCarListVC") as! MonitorCarListVC
             let vm =  MonitorCarListVM()
             vm.didSelectCar.asObservable()
               .bind(to: finish)
               .disposed(by: vm.disposeBag)
             vc.viewModel = vm
            
            
            return vc
            
            
        }
        /// 我的司机
        class func  myDriverPage(type :MyDriversListVM.MyDriverListType) ->MyDriversListVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "MyDriversListVC") as! MyDriversListVC
            vc.viewModel = MyDriversListVM(type :type)
            return vc
        }
        /// 编辑司机
        class func  editDriverPage(name:String,tel:String,isCreateDriver:Bool,id :String) ->MyDriversEditVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "MyDriversEditVC") as! MyDriversEditVC
            vc.viewModel = MyDriversEditVM(isCreateDriver:isCreateDriver ,name:name ,phone:tel, id: id)
            return vc
        }
        
        /// 管车助手
        class func reminderPage() ->ReminderListVC{
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "ReminderListVC") as! ReminderListVC
            vc.viewModel = ReminderListVM()
            return vc
        }
        
        /// 备忘录
        class func menosPage(
            type :ReminderDetailVM.RemindDetailType,
            menosId :String,
            isStar :Bool,
            createTime:Date? ,
            remindTime : Date?,
            expireTime : Date?,
            content:String ,
            picture:String) ->ReminderDetailVC{
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "ReminderDetailVC") as! ReminderDetailVC
            vc.viewModel = ReminderDetailVM(type: type, menosId :menosId, isStar: isStar, createTime:createTime, remindTime: remindTime, expireTime: expireTime,content:content, picture :picture )
            return vc
        }
        
        /// GPS 位置
        class func vehicleGpsPage() ->VehicleGpsMapVC{
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "VehicleGpsMapVC") as! VehicleGpsMapVC
            vc.viewModel = VehicleGpsMapVM()
            return vc
        }

        /// gps 筛选车辆界面
        class func filterVehicleVCPage(callback: PublishSubject<Set<ReqGetGroups.CarData>>?) -> VehicleGpsFilterVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "VehicleGpsFilterVC") as! VehicleGpsFilterVC
            
            let vm = VehicleGpsFilterVM()
            if let callbackValue = callback {
                vm.callback.asObservable()
                    .bind(to: callbackValue)
                    .disposed(by: vm.disposeBag)
            }
            
            vc.viewModel = vm

            return vc
        }
        /// gps search界面
        class func searchVehicleVCPage(callback: PublishSubject<Set<ReqQueryAllVehiclesGps.Data>>?) -> VehicleGpsSearchVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "VehicleGpsSearchVC") as! VehicleGpsSearchVC
            let vm = VehicleGpsSearchVM()
            if let callbackValue = callback {
                vm.callback.asObservable()
                    .bind(to: callbackValue)
                    .disposed(by: vm.disposeBag)
            }
            vc.viewModel = vm

            return vc
        }
       
        /// gps 分组管理界面
        class func groupManagerVCPage() -> VehicleGpsGroupManagerVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "VehicleGpsGroupManagerVC") as! VehicleGpsGroupManagerVC
            let vm = VehicleGpsGroupManagerVM()
            vc.viewModel = vm
            
            return vc
        }
        
        /// gps 分组编辑界面
        class func groupEditVCPage(groups: ReqGetGroups.Data) -> VehicleGpsGroupEditVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "VehicleGpsGroupEditVC") as! VehicleGpsGroupEditVC
            let vm = VehicleGpsGroupEditVM(groupArray: groups)
            vc.viewModel = vm
            
            return vc
        }
        
        /// gps 分组添加车辆界面
        class func groupAVehicleVCPage(callback: PublishSubject<Set<ReqGetAllVehiclesGroup.Data>>?) -> VehicleGpsAddVehicleVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "VehicleGpsAddVehicleVC") as! VehicleGpsAddVehicleVC
            let vm = VehicleGpsAddVehicleVM()
            vc.viewModel = vm
            ///
            if let callbackValue = callback {
                vm.callback.asObservable()
                    .bind(to: callbackValue)
                    .disposed(by: vm.disposeBag)
            }
            
            
            return vc
        }
        
        /// gps 分组添加分组界面
        class func groupAddGroupVCPage() -> VehicleGpsAddGroupVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "VehicleGpsAddGroupVC") as! VehicleGpsAddGroupVC
            let vm = VehicleGpsAddGroupVM()
            vc.viewModel = vm
            
            return vc
        }
        
        /// 排名统计
        class func rankListVCPage() -> RankListVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "RankListVC") as! RankListVC
            let vm = RankListVM()
            vc.viewModel = vm
            
            return vc
        }
      
        
        /// 智能语音
        class func smartVoicePage() ->SmartVoiceVC{
            let vc = UIStoryboard(name: "SmartVoice", bundle: nil).instantiateViewController(withIdentifier: "SmartVoiceVC") as! SmartVoiceVC
            vc.viewModel = SmartVoiceVM()
            return vc
        }
        
        /// 我的运单
        class func myWaybillPage() -> MyWaybillVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "MyWaybillVC") as! MyWaybillVC
            vc.viewModel = MyWaybillVM()
            return vc
        }
        
        /// 我的设置
        class func settingsPage() -> SettingsVC {
            let vc = UIStoryboard(name: "UserCenter", bundle: nil).instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            vc.viewModel = SettingsVM()
            return vc
        }
        
    }
    
}
