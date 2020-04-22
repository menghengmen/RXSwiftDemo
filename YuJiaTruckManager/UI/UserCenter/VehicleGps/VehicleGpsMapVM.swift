//
//  VehicleGpsMapVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/24.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// GPS-地图页
class VehicleGpsMapVM: BaseVM {
    
    // MARK: - Property
    
    // to view
    /// 当前所有车辆信息
    let allVehicles = Variable<[ReqQueryAllVehiclesGps.Data]>([])
    /// 当前选中查看车辆
    private let selectedVehicle = Variable<ReqQueryAllVehiclesGps.Data?>(nil)
    
    /// 是否显示详情
    let isShowVehcileDetail = Variable<Bool>(false)
    /// 当前车牌号
    let carLicence = Variable<String?>(nil)
    /// 当前机构名称
    let companyName = Variable<String?>(nil)
    /// 当前速度
    let speed = Variable<Int?>(nil)
    /// 当前位置
    let address = Variable<String?>(nil)
    /// 是否支持实时监控
    let isEnableMonitor = Variable<Bool>(false)
    
    // from view
    /// 点击过滤
    let clickFilter = PublishSubject<Void>()
    /// 点击搜索
    let clickSearch = PublishSubject<Void>()
    /// 点击车辆详情
    let clickVehcile = PublishSubject<ReqQueryAllVehiclesGps.Data?>()
    /// 点击实时监控
    let clickMonitor = PublishSubject<Void>()
    
    /// 过滤车辆选择完毕
    let didFilterCar = PublishSubject<Set<ReqGetGroups.CarData>>()
    /// 搜索车辆选择完毕
    let didSearchCar = PublishSubject<Set<ReqQueryAllVehiclesGps.Data>>()

    // MARK: - Method
    
    override init() {
        super.init()
        
        // 事件：
        
        clickFilter.asObservable()
            .map { [weak self] (_) -> RouterInfo in
                return (Router.UserCenter.vehicleFilter, ["callback": self?.didFilterCar])
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        clickSearch.asObservable()
            .map { [weak self] (_) -> RouterInfo in
                return (Router.UserCenter.vehicleSearch, ["callback": self?.didSearchCar])
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        clickVehcile.asObservable()
            .map({ [weak self] (value) -> ReqQueryAllVehiclesGps.Data? in
                if self?.selectedVehicle.value == value {
                    return nil
                }
                return value
            })
            .bind(to: selectedVehicle)
            .disposed(by: disposeBag)
        
        clickMonitor.asObservable()
            .filter { [weak self] (_) -> Bool in
                self?.isEnableMonitor.value == true
            }
            .map { [weak self] (_) -> RouterInfo in
                MobClick.event("monitor_from_gps")
                return (Router.UserCenter.moniter, ["vehicleId": self?.selectedVehicle.value?.vehicleId, "carLicense": self?.selectedVehicle.value?.carLicense, "stauts": self?.selectedVehicle.value?.status])
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        clickMonitor.asObservable()
            .filter { [weak self] (_) -> Bool in
                self?.isEnableMonitor.value == false
            }
            .map { (_) -> AlertMessage in
                MobClick.event("monitor_from_gps")
                return AlertMessage(message: Constants.Text.noMonitor, alertType: .toast)
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        
        selectedVehicle.asObservable()
            .map { $0 != nil }
            .bind(to: isShowVehcileDetail)
            .disposed(by: disposeBag)
        
        selectedVehicle.asObservable()
            .map { $0?.carLicense }
            .bind(to: carLicence)
            .disposed(by: disposeBag)
        
        selectedVehicle.asObservable()
            .map { $0?.speed.yd.int }
            .bind(to: speed)
            .disposed(by: disposeBag)
        
        selectedVehicle.asObservable()
            .map { $0?.groupName }
            .bind(to: companyName)
            .disposed(by: disposeBag)
        
        selectedVehicle.asObservable()
            .flatMap { (data) -> Observable<String?> in
                return Constants.Tools.reverseGeoCodeRx(coordinate: data?.getCoordinate())
            }
            .bind(to: address)
            .disposed(by: disposeBag)
        
        selectedVehicle.asObservable()
            .map { $0?.status == .normal || $0?.status == .alarming }
            .bind(to: isEnableMonitor)
            .disposed(by: disposeBag)
        
        viewDidLoad.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<[ReqQueryAllVehiclesGps.Data]> in
                return self?.reuqestAllVehicles() ?? .empty()
            }
            .bind(to: allVehicles)
            .disposed(by: disposeBag)
        
        didFilterCar.asObservable()
            .map { $0.map { $0.vehicleId } }
            .flatMapLatest { [weak self] (value) -> Observable<[ReqQueryAllVehiclesGps.Data]> in
                mLog("【回调】：\(value)")
                if value.count > 0 {
                    return self?.requestVehicles(by: value) ?? .empty()
                } else {
                    return self?.reuqestAllVehicles() ?? .empty()
                }
            }
            .bind(to: allVehicles)
            .disposed(by: disposeBag)
        
        didSearchCar.asObservable()
            .flatMapLatest { [weak self] (value) -> Observable<[ReqQueryAllVehiclesGps.Data]> in

                mLog("【回调】：\(value)")
                if value.count > 0 {
                    return Observable.just([ReqQueryAllVehiclesGps.Data](value))
                } else {
                    return self?.reuqestAllVehicles() ?? .empty()
                }
            }
            .bind(to: allVehicles)
            .disposed(by: disposeBag)
        
    }
    
    
    /// 请求所有车辆
    private func reuqestAllVehicles() -> Observable<[ReqQueryAllVehiclesGps.Data]> {
        
        let req = ReqQueryAllVehiclesGps(groupId: DataCenter.shared.userInfo.value?.groupId ?? "").toDataReuqest()
        
        req.isRequesting.asObservable()
            .map { (value) -> LoadingState in
                return LoadingState(isLoading: value, loadingText: nil)
            }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        req.responseRx.asObservable()
            .filter { $0.isSuccess() == false }
            .map { (rsp) -> AlertMessage in
                return AlertMessage(message: rsp.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast)
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        let result = req.responseRx.asObservable()
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqQueryAllVehiclesGps.Data] in
                return rsp.model?.dataList ?? []
            }
        
        #if DEBUG
        req.send()
        #else
        req.send()
        #endif
        
        
        return result
    }
    
    /// 通过id查询车辆
    private func requestVehicles(by ids: [String]) -> Observable<[ReqQueryAllVehiclesGps.Data]> {
        
//        let idsStr = ids.joined(separator: ",")
        
        let req = ReqQueryVehiclesGps(vehicleIdList: ids, groupId: DataCenter.shared.userInfo.value?.groupId ?? "").toDataReuqest()
        
        req.isRequesting.asObservable()
            .map { (value) -> LoadingState in
                return LoadingState(isLoading: value, loadingText: nil)
            }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        req.responseRx.asObservable()
            .filter { $0.isSuccess() == false }
            .map { (rsp) -> AlertMessage in
                return AlertMessage(message: rsp.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast)
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        let result = req.responseRx.asObservable()
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqQueryAllVehiclesGps.Data] in
                return rsp.model?.dataList ?? []
        }
        
        req.send()
        
        return result
        
    }
    
    
}
