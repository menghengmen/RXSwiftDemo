//
//  AlarmListVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 告警等级
struct AlarmLevel: Hashable {
    
    /// 告警int值
    var intValue: Int?
    /// 中文描述
    var desc: String? {
        
        switch intValue {
        case nil:
            return "全部"
        case 1:
            return "二级"
        case 2:
            return "一级"
        case 3:
            return "三级"
        case 4:
            return "四级"
        default:
            return nil
        }
    }
    
    /// 全部告警
    static let all = AlarmLevel(intValue: nil)
    /// 一级告警
    static let one = AlarmLevel(intValue: 2)
    /// 二级告警
    static let two = AlarmLevel(intValue: 1)
    /// 三级告警
    static let three = AlarmLevel(intValue: 3)
    /// 四级告警
    static let four = AlarmLevel(intValue: 4)
    
    /// 可选告警类型
    static let allSelection: [AlarmLevel] = [.all, .one, .two, .three, .four]
}


/// 告警历史页面
class AlarmListVM: BaseTableVM {
    
    /// 加载数据类型
    enum LoadingType {
        /// 主动刷新所有
        case callLoading
        /// 用户下拉刷新
        case userPullRefresh
        /// 用户上拉更多
        case userPushLoadmore
    }
    
    // 当前页码
    var currentPage = 1
    // 分页大小
    var pageSize = 20
    /// 当前历史报警数据
    let alarmHistoryList = Variable<[ReqAlarmList.Data]>([])
    
    // from view
    let clickFilterBtn = PublishSubject<Void>()
    /// 保存过滤器
    let didSaveFilter = PublishSubject<AlarmListFilter>()
    
    // 私有事件
    /// 刷新数据（是否加载更多）
    let updateAlarmList = PublishSubject<LoadingType>()
    
    override init() {
        super.init()
        
        // 上拉
        isEnablePullRefresh.value = true
        // 下拉
        dataSource.asObservable()
            .map { $0?.count > 0 }
            .bind(to: isEnablePushLoadmore)
            .disposed(by: disposeBag)
        
        /// 点击筛选
        clickFilterBtn.asObservable()
            .map { [weak self] (_) -> RouterInfo in
                return (Router.UserCenter.filterVC,["didSaveFilter": self?.didSaveFilter ])
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        
        /// 首次加载数据
        viewDidLoad.asObservable()
            .map { return LoadingType.callLoading }
            .bind(to: updateAlarmList)
            .disposed(by: disposeBag)
        
        /// 下拉刷新
        didPullRefresh.asObservable()
            .map { return LoadingType.userPullRefresh }
            .bind(to: updateAlarmList)
            .disposed(by: disposeBag)
        
        /// 上拉加载
        didPushLoadMore.asObservable()
            .map { return LoadingType.userPushLoadmore }
            .bind(to: updateAlarmList)
            .disposed(by: disposeBag)
        
        /// 筛选完毕
        didSaveFilter.asObservable()
            .bind(to: DataCenter.shared.currnetFilter)
            .disposed(by: disposeBag)
        
        didSaveFilter.asObservable()
            .map { _ in return LoadingType.callLoading }
            .bind(to: updateAlarmList)
            .disposed(by: disposeBag)
        
        /// 加载数据
        let updateFinish = updateAlarmList.asObservable()
            .flatMapLatest { [weak self] (type) -> Observable<(LoadingType, Bool)> in
                return self?.alarmListReq(type: type, filter: DataCenter.shared.currnetFilter.value) ?? .empty()
            }
            .share(replay: 1, scope: .whileConnected)
        
        updateAlarmList.asObservable()
            .filter { $0 == .callLoading }
            .map { _ in LoadingState(isLoading: true) }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        updateFinish
            .filter { $0.0 == .callLoading }
            .map { _ in LoadingState.noLoading }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        updateFinish
            .filter { $0.0 == .userPullRefresh }
            .map { _ in }
            .bind(to: callEndPullRefresh)
            .disposed(by: disposeBag)
        
        updateFinish
            .filter { $0.0 == .userPushLoadmore }
            .map { $0.1 }
            .bind(to: callEndPushLoadMore)
            .disposed(by: disposeBag)
        
        updateFinish
            .filter({ [weak self] (value) -> Bool in
                return self?.dataSource.value?.count > 0 && value.0 != .userPushLoadmore
            })
            .map { _ in IndexPath(row: NSNotFound, section: 0) }
            .bind(to: callScrollToRow)
            .disposed(by: disposeBag)
        
        /// 数据转vm
        alarmHistoryList.asObservable()
            .map { [weak self] (dataArray) -> [BaseSectionVM]? in
                return  self?.viewModel(from: dataArray)
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        /// 跳转
        didSelectRow.asObservable()
            .map { [weak self] (indexP) -> RouterInfo in
                
                if let vm = self?.fetchCellViewModel(by: indexP) as? AlarmListCellVM {
                    var dic = [String: Any]()
                    dic["alarmId"] = vm.alarmId
                    dic["address"] = vm.address.value
                    if vm.address.value == nil {
                        dic["coordinate"] = vm.coordinate
                    }
                    
                    return (Router.UserCenter.goDetail, dic)
                } else {
                    return (nil,nil)
                }
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        
    }
    
    ///请求历史报警数据，返回成功事件（加载类型，是否有数据）
    private func alarmListReq(type: LoadingType ,filter: AlarmListFilter) -> Observable<(LoadingType, Bool)>{
        
        let pageNumber = type == .userPushLoadmore ? currentPage + 1 : 1
        
        /// 开始和结束时间        
        let startTime = filter.startTime.yd.timeIntevaleSince1970msString
        let endTime = filter.endTime.yd.timeIntevaleSince1970msString
        
        var level  = ""
        for selectItem in filter.level {
            if let levelInt = AlarmLevel.allSelection.yd.element(of: selectItem)?.intValue {
                level = "\(levelInt)"
            }
        }
        
        var isHandle :Int = -1
        for selectItem in filter.handleStatus {
            if selectItem > 0 {
                isHandle =  selectItem  == 1 ? 1 : 0
                // isHandle.append((isHandle.isEmpty ? "" : ",") + (selectItem == 1 ? 1 : 0))
            }
        }
        
        var alarmTypes = ""
        for selectItem in filter.selectItem {
            alarmTypes.append((alarmTypes.isEmpty ? "" : ",") + selectItem.alarmId)
        }
        
        let reqParams = ReqAlarmList(
            groupId: DataCenter.shared.userInfo.value?.groupId ?? "",
            pageNo: pageNumber,
            pageSize: pageSize,
            startTime: startTime,
            endTime: endTime,
            carLicense:filter.carLicense  ,
            driverName:filter.driverName ,
            isHandle: isHandle,
            level: level,
            alarmTypes: alarmTypes)
        
        let req = reqParams.toDataReuqest()
        let finish = req.responseRx.asObservable()
        
        finish.asObservable()   // 错误提示
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        let success = finish
            .filter { $0.isSuccess() }
            .map { $0.model?.dataList ?? []}
        
        success
            .filter { ($0.isEmpty && type == .userPushLoadmore) == false } // 加载更多，没有数据时不刷新
            .map({ [weak self] (value) -> [ReqAlarmList.Data] in
                
                var currentData = self?.alarmHistoryList.value ?? []
                
                if type != .userPushLoadmore { // 全量加载
                    currentData.removeAll()
                }
                self?.currentPage = pageNumber
                currentData.append(contentsOf: value)
                
                return currentData
            })
            .bind(to: alarmHistoryList)
            .disposed(by: disposeBag)
        
        success
            .map { (rsp) -> ErrViewInfo? in
                if rsp.count == 0 && type != .userPushLoadmore  {
                    return ErrViewInfo(type: .nodata)
                } else {
                    return nil
                }
            }
            .bind(to: errView)
            .disposed(by: disposeBag)
        
        success
            .filter { $0.count == 0 && type == .userPushLoadmore }
            .map { _ in AlertMessage(message: "没有更多数据", alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        #if DEBUG
        req.send()
        #else
        req.send()
        #endif
        
        return finish.map({ (rsp) -> (LoadingType, Bool) in
            return (type, rsp.model?.dataList.count > 0)
        })
        
    }
    /// 数据转化为view model
    private func viewModel(from dataAry: [ReqAlarmList.Data]?) -> [BaseSectionVM]? {
        
        guard dataAry?.count > 0 else {
            return nil
        }
        
        let section = BaseSectionVM()
        
        section.cellViewModels.append(BigTitleCellVM(title: "报警事件"))
        
        for aData in dataAry ?? [] {
            
            let cellVM = AlarmListCellVM(data: aData)
            section.cellViewModels.append(cellVM)
        }
        
        return [section]
    }
}
