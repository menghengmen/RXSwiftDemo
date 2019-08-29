//
//  RankListVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/24.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import DateToolsSwift

/// 排名统计页
class RankListVM: BaseTableVM {
    
    /// 排行类型
    enum RankType {
        /// 司机
        case driver
        /// 车辆
        case vehicle
    }
    
    /// 类型
    let currentType = Variable<RankType>(.driver)
    /// 开始时间
    let startTime = Variable<Date>(Date())
    /// 结束时间
    let endTime = Variable<Date>(Date())
    
    /// 重新请求数据
    private let requestData = PublishSubject<Void>()
    /// 当前页码
    private var page = 1
    
    override init() {
        super.init()
        
        isEnablePullRefresh.value = true
        isEnablePushLoadmore.value = true

        navTitle.value = "排名统计"
        
        let timeDefault = getLastWeakStartAndEndDate()
        startTime.value = timeDefault.0
        endTime.value = timeDefault.1
        
        /// viewDidAppear刷新数据
        viewDidAppear.asObserver()
            .bind(to: requestData)
            .disposed(by: disposeBag)
        
        /// 切换type或更新时间刷新数据
        Observable<Void>.merge(
            currentType.asObservable().map { _ in },
            startTime.asObservable().map { _ in },
            endTime.asObservable().map { _ in })
            .skipUntil(viewDidAppear)
            .bind(to: requestData)
            .disposed(by: disposeBag)
        
        /// 刷新数据绑定在统一处理中，有间隔
        requestData.asObservable()
            .debounce(0.1, scheduler: MainScheduler.instance)
            .bind(to: callReloadData)
            .disposed(by: disposeBag)
        
        /// 切换后回到顶
        currentType.asObservable()
            .map { _ in }
            .bind(to: callScrollToTop)
            .disposed(by: disposeBag)
    }
    
    override func processReloadData(type: BaseTableViewControllerViewModel.ReloadDataType) -> Observable<(BaseTableViewControllerViewModel.ReloadDataType, Bool)> {
        
        /// 当前页码
        let reuqestPage = type == .userPushLoadmore ? page + 1 : 1
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd"
        
        if currentType.value == .driver {
            
            let reqParam = ReqQueryRankingOfDrive()
            reqParam.pageNo = "\(reuqestPage)"
            reqParam.groupId = DataCenter.shared.userInfo.value?.groupId ?? ""
            reqParam.startTime = startTime.value.yd.timeString(with: "yyyyMMdd") ?? ""
            reqParam.endTime = endTime.value.yd.timeString(with: "yyyyMMdd") ?? ""
            
            let req = reqParam.toDataReuqest()
            
            req.isRequesting.asObservable()
                .filter { _ in type == .callReload }
                .map { LoadingState(isLoading: $0, loadingText: nil) }
                .bind(to: isShowLoading)
                .disposed(by: disposeBag)
            
            req.responseRx.asObservable()
                .filter { $0.isSuccess() == false }
                .map { (rsp) -> AlertMessage in
                    return AlertMessage(message: rsp.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast)
                }
                .bind(to: showMessage)
                .disposed(by: disposeBag)
            
            req.responseRx.asObservable()
                .filter { $0.isSuccess() && type != .userPushLoadmore }
                .map { (rsp) -> ErrViewInfo? in
                    if (rsp.model?.dataList ?? []).count == 0 {
                        return .noDataFromRank
                    } else {
                        return nil
                    }
                }
                .bind(to: errView)
                .disposed(by: disposeBag)
            
            req.responseRx.asObservable()
                .filter { $0.isSuccess() }
                .map { [weak self] (rsp) -> [RankListSection]? in
                    self?.page = reuqestPage
                    return self?.driverViewModel(type: type, data:  rsp.model?.dataList)
                }
                .bind(to: dataSource)
                .disposed(by: disposeBag)
            
            req.send()
            
            let result = req.responseRx.asObservable()
                .map { (type, $0.model?.dataList.count > 0) }
            
            return result
            
        } else {
            
            let reqParam = ReqQueryRankingOfVehicle()
            reqParam.pageNo = "\(reuqestPage)"
            reqParam.groupId = DataCenter.shared.userInfo.value?.groupId ?? ""
            reqParam.startTime = startTime.value.yd.timeString(with: "yyyyMMdd") ?? ""
            reqParam.endTime = endTime.value.yd.timeString(with: "yyyyMMdd") ?? ""
            
            let req = reqParam.toDataReuqest()
            
            req.isRequesting.asObservable()
                .filter { _ in type == .callReload }
                .map { LoadingState(isLoading: $0, loadingText: nil) }
                .bind(to: isShowLoading)
                .disposed(by: disposeBag)
            
            req.responseRx.asObservable()
                .filter { $0.isSuccess() == false }
                .map { (rsp) -> AlertMessage in
                    return AlertMessage(message: rsp.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast)
                }
                .bind(to: showMessage)
                .disposed(by: disposeBag)
            
            req.responseRx.asObservable()
                .filter { $0.isSuccess() && type != .userPushLoadmore }
                .map { (rsp) -> ErrViewInfo? in
                    if (rsp.model?.dataList ?? []).count == 0 {
                        return .noDataFromRank
                    } else {
                        return nil
                    }
                }
                .bind(to: errView)
                .disposed(by: disposeBag)
            
            req.responseRx.asObservable()
                .filter { $0.isSuccess() }
                .map { [weak self] (rsp) -> [BaseSectionVM]? in
                    self?.page = reuqestPage
                    return self?.vehicleViewModel(type: type, data: rsp.model?.dataList)
                }
                .bind(to: dataSource)
                .disposed(by: disposeBag)
            
            req.send()
            
            let result = req.responseRx.asObservable()
                .map { (type, $0.model?.dataList.count > 0) }
            
            return result
            
        }
    }
    
    /// 司机数据模型
    private func driverViewModel(type: ReloadDataType, data: [ReqQueryRankingOfDrive.Data]?) -> [RankListSection]? {
        
        var currnetNumber = dataSource.value?.first?.cellViewModels.count ?? 0
        if type != .userPushLoadmore {
            currnetNumber = 0
        }
        
        let section = type == .userPushLoadmore ? (dataSource.value?.first as? RankListSection ?? RankListSection()) : RankListSection()
        section.nameTitle.value = "司机姓名"
        
        for (idx, aData) in (data ?? []).enumerated() {
            
            let cellVM = RankListCellVM()
            cellVM.order.value = currnetNumber + idx + 1
            cellVM.name.value = aData.driverName
            cellVM.alarmNumber.value = aData.alarmCount?.yd.roundInt
            section.cellViewModels.append(cellVM)
        }
        
        return [section]
    }
    
    /// 车辆数据模型
    private func vehicleViewModel(type: ReloadDataType, data: [ReqQueryRankingOfVehicle.Data]?) -> [RankListSection]? {
        
        var currnetNumber = dataSource.value?.first?.cellViewModels.count ?? 0
        if type != .userPushLoadmore {
            currnetNumber = 0
        }
        
        let section = type == .userPushLoadmore ? (dataSource.value?.first as? RankListSection ?? RankListSection()) : RankListSection()
        section.nameTitle.value = "车牌号"
        
        for (idx, aData) in (data ?? []).enumerated() {
            
            let cellVM = RankListCellVM()
            cellVM.order.value = currnetNumber + idx + 1
            cellVM.name.value = aData.carLicense
            cellVM.alarmNumber.value = aData.alarmCount?.yd.roundInt
            section.cellViewModels.append(cellVM)
        }
        
        return [section]
    }
    
    /// 获取上周开始和结束(最后一秒)的时间
    private func getLastWeakStartAndEndDate() -> (Date, Date) {
        let lastWeekToday = Date().add(-7.days)
        let dayFromMon = lastWeekToday.weekday - 2
        let dayToNextMon = 9 - lastWeekToday.weekday
        let lastMon = lastWeekToday.subtract(dayFromMon.days)
        let nextMon = lastWeekToday.add(dayToNextMon.days)
        
        let lastMonZero = Date(year: lastMon.year, month: lastMon.month, day: lastMon.day)
        let nextMonZero = Date(year: nextMon.year, month: nextMon.month, day: nextMon.day)
        
        return (lastMonZero, nextMonZero.subtract(1.seconds))
    }
    
}
