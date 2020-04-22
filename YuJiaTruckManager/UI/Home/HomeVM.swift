//
//  HomeVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/22.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift

/// 首页
class HomeVM: BaseTableVM {
    
    // to view
    /// 当前数据类型，默认昨天
    let currentType = Variable<HistoryDataType?>(nil)
    /// 是否展示智能语音
    let isShowSmartVoice = Variable<Bool>(false)
    
    // from view
    /// 点击智能语音
    let clickSmartVoice = PublishSubject<Void>()
    
    override init() {
        super.init()
        
        /// 是否显示智能语音
        viewWillAppear.asObservable()
            .map { [weak ud = UserDefaultsManager.shared] (_) -> Bool in
                return ud?.isEnableOpenSmartVoice ?? false
            }
            .bind(to: isShowSmartVoice)
            .disposed(by: disposeBag)
        
        /// 点击智能语音
        clickSmartVoice.asObservable()
            .map { ()  -> RouterInfo in
                return (Router.SmartVoice.open,nil)
            }
            .bind(to: openRouter)
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

        /// 创建cell
        let section = BaseSectionVM()
        
        /// 数据统计cell(今日数据)
        let statusCellVM = HistoryStateCellVM(type: nil)
        currentType.asObservable()
            .bind(to: statusCellVM.currentType)
            .disposed(by: disposeBag)
        section.cellViewModels.append(statusCellVM)
  
        /// 报警趋势cell
        let trendCellVM = HistoryTrendCellVM(type: nil, isEnableSwipe: true)
        currentType.asObservable()
            .filter { $0 != nil }
            .map { (value) in
                return value == nil ? nil : .thisMonth
            }
            .bind(to: trendCellVM.currentType)
            .disposed(by: disposeBag)
        section.cellViewModels.append(trendCellVM)
        dataSource.value = [section]
        
        /// 获取用户数据后刷新
        DataCenter.shared.userInfo.asObservable()
            .map { (value) in
                return value == nil ? nil : .today
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
