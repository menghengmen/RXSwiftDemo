//
//  HistoryVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/23.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
import DateToolsSwift

/// 历史数据类型
struct HistoryDataType: Hashable {
    
    /// 开始时间
    var startDate: Date
    /// 结束时间
    var endDate: Date
    
    /// 开始时间时间戳（毫秒）
    var startTimeIntervalMs: Int64 {
        return Int64(startDate.timeIntervalSince1970) * 1000
    }
    
    /// 结束时间时间戳（毫秒）
    var endTimeIntervalMs: Int64 {
        return Int64(endDate.timeIntervalSince1970) * 1000
    }
    
    /// 开始时间格式化
    var startTimeStr: String {
        return startDate.format(with: "yyyy-MM-dd HH:mm:ss")
    }
    
    /// 结束时间格式化
    var endTimeStr: String {
        return endDate.format(with: "yyyy-MM-dd HH:mm:ss")
    }
    
    /// 前缀
    var prefixName: String = ""
    
    /// 今日
    static var today: HistoryDataType {
        
        let now = Date()
        let nowZero = Date.init(year: now.year, month: now.month, day: now.day)
        let tomorrowZero = nowZero.add(1.days)
        
        var result = HistoryDataType(startDate: nowZero, endDate: tomorrowZero.add(-1.seconds))
        result.prefixName = "今日"
        return result
    }
    
    /// 昨天
    static var yestoday: HistoryDataType {
        
        let now = Date()
        let nowZero = Date(year: now.year, month: now.month, day: now.day)
        let yestodayZero = nowZero - 1.days
        
        var result = HistoryDataType(startDate: yestodayZero, endDate: nowZero.add(-1.seconds))
        result.prefixName = "昨日"
        return result
    }
    
    /// 昨日向前推迟一周
    static var yestodayOneWeek: HistoryDataType {
        let now = Date()
        let nowZero = Date(year: now.year, month: now.month, day: now.day)
        let yestodayZero = nowZero - 1.days
        
        var result = HistoryDataType(startDate: yestodayZero - 1.weeks, endDate: nowZero.add(-1.seconds))
        result.prefixName = "昨日"
        return result
        
    }
    
    /// 本月
    static var thisMonth: HistoryDataType {
        let now = Date()
        let nowZero = Date(year: now.year, month: now.month, day: now.day)
        let tomorrowZero = nowZero.add(1.days)
        let thisMonth1st = Date(year: now.year, month: now.month, day: 1)
        
        var result = HistoryDataType(startDate: thisMonth1st, endDate: tomorrowZero.add(-1.seconds))
        result.prefixName = "本月"
        return result
    }
    
    /// 上月
    static var lastMonth: HistoryDataType {
        let now = Date()
        let lastMonthDay = now - 1.months
        let lastMonthDay1st = Date(year: lastMonthDay.year, month: lastMonthDay.month, day: 1)
        let thisMonth1st = Date(year: now.year, month: now.month, day: 1)
        
        var result = HistoryDataType(startDate: lastMonthDay1st, endDate: thisMonth1st.add(-1.seconds))
        result.prefixName = "上月"
        return result
    }
    
    /// 初始化
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
}

/// 历史页
class HistoryVM: BaseTableVM {
    
    // to view
    /// 当前数据类型，默认昨天
    let currentType = Variable<HistoryDataType?>(nil)
    /// 是否展示智能语音
    let isShowSmartVoice = Variable<Bool>(false)
    
    // from view
    /// 切换了数据类型
    let didChangeType = PublishSubject<(HistoryDataType)>()
    
    override init() {
        super.init()
        
        /// 是否显示智能语音
        viewWillAppear.asObservable()
            .map { [weak ud = UserDefaultsManager.shared] (_) -> Bool in
                return ud?.isEnableOpenSmartVoice ?? false
            }
            .bind(to: isShowSmartVoice)
            .disposed(by: disposeBag)
        
        /// 下拉刷新
        isEnablePullRefresh.value = true
        
        didPullRefresh.asObservable()
            .map { [weak self] (_) -> HistoryDataType? in
                return self?.currentType.value
            }
            .bind(to: currentType)
            .disposed(by: disposeBag)
        
        didPullRefresh.asObservable()
            .delay(0.1, scheduler: MainScheduler.instance)
            .bind(to: callEndPullRefresh)
            .disposed(by: disposeBag)
        
        // cell加载
        let section = BaseSectionVM()
        
        /// 数据统计cell
        let statusCellVM = HistoryStateCellVM(type: nil)
        currentType.asObservable()
            .bind(to: statusCellVM.currentType)
            .disposed(by: disposeBag)
        
        section.cellViewModels.append(statusCellVM)
        
        /// 趋势cell
        let trendCellVM = HistoryTrendCellVM(type: nil)
        currentType.asObservable()
            .map { $0 == .yestoday ? .yestodayOneWeek : $0 } // 昨日显示推前一周
            .bind(to: trendCellVM.currentType)
            .disposed(by: disposeBag)
        
        section.cellViewModels.append(trendCellVM)
        dataSource.value = [section]
        
        /// 切换数据
        didChangeType.asObservable()
            .bind(to: currentType)
            .disposed(by: disposeBag)
        
        /// 获取用户数据后刷新
        DataCenter.shared.userInfo.asObservable()
            .map { value in
                return value == nil ? nil : HistoryDataType.yestoday
            }
            .bind(to: currentType)
            .disposed(by: disposeBag)
        
        /// 网络错误提示
        Observable<Bool>.zip(statusCellVM.didFinishLoad.asObservable(), trendCellVM.didFinishLoad.asObservable()) { $0 && $1 }
            .map { $0 ? AlertMessage.noMessage : AlertMessage(message: Constants.Text.statusDataNetErr, alertType: .toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
    }
    
    
}
