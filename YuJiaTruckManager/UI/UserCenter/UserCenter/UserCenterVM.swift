//
//  UserCenterVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/23.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxCocoa
import RxSwift

/// 用户中心页
class UserCenterVM: BaseTableVM {
    
    /// 是否展示智能语音
    let isShowSmartVoice = Variable<Bool>(false)
    
    // cell缓存
    /// 用户信息
    let userCellVM = UserCenterUserCellVM()
    /// 用户管理
    let userManageCellVM = UserCenterRowCellVM(rowType: .userManage)
    /// 告警
    let alarmCellVM = UserCenterRowCellVM(rowType: .alarm)
    /// 关于我们
    let aboutCellVM = UserCenterRowCellVM(rowType: .about)
    /// 实时监控
    let moniterVM = UserCenterRowCellVM(rowType: .moniter)
    /// 我的司机
    let myDriverVM = UserCenterRowCellVM(rowType: .myDriver)
    /// 管车助手
    let reminderVM = UserCenterRowCellVM(rowType: .reminder)
    /// GPS 位置
    let vehicleGpsVM = UserCenterRowCellVM(rowType: .vehicleGps)
    /// 排名统计
    let rankListVM = UserCenterRowCellVM(rowType: .rankList)
    /// 我的运单
    let myWaybillVM = UserCenterRowCellVM(rowType: .myWaybill)
    /// 用户管理
    let logoutCellVM = UserCenterLogoutCellVM()
    
    
    // from view
    /// 退出
    let clickLogout = PublishSubject<Void>()
    /// 点击设置
    let clickSettings = PublishSubject<Void>()
    
    override init() {
        super.init()
        
        /// 是否显示智能语音
        viewWillAppear.asObservable()
            .map { [weak ud = UserDefaultsManager.shared] (_) -> Bool in
                return ud?.isEnableOpenSmartVoice ?? false
            }
            .bind(to: isShowSmartVoice)
            .disposed(by: disposeBag)
        
        ///赋值
        DataCenter.shared.userDetail.asObservable()
            .map { (userDetail) -> String? in
                return userDetail?.groupName
          }
           .bind(to: userCellVM.company)
           .disposed(by: disposeBag)

        DataCenter.shared.userDetail.asObservable()
            .map { [weak ud = UserDefaultsManager.shared] (userDetail) -> String? in
                return userDetail?.userName.count > 0 ? ud?.account : nil
            }
           .bind(to: userCellVM.phone)
           .disposed(by: disposeBag)
        
        DataCenter.shared.userDetail.asObservable()
            .map { [weak ud = UserDefaultsManager.shared] (userDetail) -> String? in
                return userDetail?.userName.count > 0 ? userDetail?.userName : ud?.account
         }
           .bind(to: userCellVM.name)
           .disposed(by: disposeBag)
        
        /// 重新组装cell
        DataCenter.shared.userInfo.asObservable()
            .subscribe(onNext: { [weak self] (data) in
                self?.reloadCells(userInfo: data)
            })
            .disposed(by: disposeBag)
        
        /// 退出登录
        logoutCellVM.clickLogout.asObservable()
            .map { _ in
                MobClick.event("logout")
                return AlertMessage.twoButtonAlert(with: "是否退出登录")
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        didConfirmAlert.asObservable()
            .filter ({ (type) -> Bool in
                type.1 == 1
            })
            .map { _ in }
            .bind(to: MessageCenter.shared.didLogout)
            .disposed(by: disposeBag)
        
        /// 点击设置
        clickSettings.asObservable()
            .map { _ in
                MobClick.event("setting")
               return (Router.UserCenter.settings,nil)
             }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 跳转
        didSelecCell.asObservable()
            .map { (vm) -> RouterInfo in
                MobClick.event(((vm as? UserCenterRowCellVM)?.rowType.value).map { $0.rawValue })

                switch (vm as? UserCenterRowCellVM)?.rowType.value {
                case .userManage?:
                    return (Router.UserCenter.userManager,nil)
                case .alarm?:
                    return (Router.UserCenter.alarmList,nil)
                case .about?:
                    return (Router.UserCenter.aboutUs,nil)
                case .moniter?:
                    return (Router.UserCenter.moniter,nil)
                case .myDriver?:
                    return (Router.UserCenter.myDriver,["type" :MyDriversListVM.MyDriverListType.lookDriver])
                case .reminder?:
                    return (Router.UserCenter.reminder,nil)
                case .vehicleGps?:
                    return (Router.UserCenter.vehicleGps,nil)
                case .rankList?:
                    return (Router.UserCenter.rankList,nil)
                case .myWaybill?:
                    return (Router.UserCenter.myWaybill,nil)
                default:
                    return (nil,nil)
                }
                
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
    }
    
    private func reloadCells(userInfo: ReqLogin.Data?) {
        
        // cells
        
        let setcion = BaseSectionVM()
        
        // 用户
        setcion.cellViewModels.append(userCellVM)
        
        // 行
        if userInfo?.isAdmin() == true {
            setcion.cellViewModels.append(userManageCellVM)
        }
        setcion.cellViewModels.append(alarmCellVM)
        setcion.cellViewModels.append(aboutCellVM)
        setcion.cellViewModels.append(moniterVM)
        setcion.cellViewModels.append(myDriverVM)
        setcion.cellViewModels.append(vehicleGpsVM)
        setcion.cellViewModels.append(reminderVM)
        setcion.cellViewModels.append(rankListVM)
        setcion.cellViewModels.append(myWaybillVM)

        // 登出
        if userInfo != nil {
            setcion.cellViewModels.append(logoutCellVM)
        }
        
        dataSource.value = [setcion]
    }
    
    
}
