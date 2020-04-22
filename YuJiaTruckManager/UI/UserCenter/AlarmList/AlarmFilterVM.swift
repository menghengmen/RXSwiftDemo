//
//  AlarmFilterVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 过滤器
struct AlarmListFilter {
    
    /// 等级(空，1,2,3,4)
    var level = Set<Int>(arrayLiteral: 0)
    /// 处理状态（空，0，1）
    var handleStatus = Set<Int>(arrayLiteral: 0)
    /// 车牌号
    var carLicense = ""
    /// 驾驶员姓名
    var driverName = ""
    
    /// 开始日期(默认今天开始)
    var startTime: Date = {
        let now = Date()
        return  Date(year: now.year, month: now.month, day: now.day)
    }()
    
    /// 结束日期(默认当前时间结束)
    var endTime = Date()
    
    /// 其他条件
    var selectItem = Set<ReqGetAlarmType.AlarmTypeListes>()
}

/// 告警过滤器页面
class AlarmFilterVM: BaseTableVM {
    
    // 属性
    /// call back
    let saveFilter = PublishSubject<AlarmListFilter>()
    
    /// 当前的过滤器
    var currentFilter: AlarmListFilter {
        var filter = AlarmListFilter()
        
        filter.level = level.value
        filter.handleStatus = handleStatus.value
        filter.carLicense = carLicense.value
        filter.driverName = driverName.value
        filter.selectItem = selectItem
        filter.startTime = startTime.value
        filter.endTime = endTime.value
        
        return filter
    }
    
    // to view
    
    /// 等级
    let level = Variable<Set<Int>>([])
    /// 处理状态
    let handleStatus = Variable<Set<Int>>([])
    /// 车牌号
    let carLicense = Variable<String>("")
    /// 驾驶员姓名
    let driverName = Variable<String>("")
    /// 开始时间
    let startTime = Variable<Date>(Date())
    /// 结束时间
    let endTime = Variable<Date>(Date())
    /// 其他选择条件
    var selectItem = Set<ReqGetAlarmType.AlarmTypeListes>()

    // from view
    /// 点击重置
    let didClickReset = PublishSubject<Void>()
    /// 点击确认
    let didClickConfirm = PublishSubject<Void>()
    /// 点击关闭
    let didClickClose = PublishSubject<Void>()
    /// 点击选择日期
    let didClickSelectDate = PublishSubject<Void>()
    /// 点击选择日期(开始日期，结束日期)
    let didFinishSelectDate = PublishSubject<(Date,Date)>()
    
    override init() {
        super.init()
        
        /// 初始化
        let filter = DataCenter.shared.currnetFilter.value
        
        level.value = filter.level
        handleStatus.value = filter.handleStatus
        carLicense.value = filter.carLicense
        driverName.value = filter.driverName
        selectItem = filter.selectItem
        startTime.value = filter.startTime
        endTime.value = filter.endTime
        
        viewWillAppear.asObservable()
            .flatMapLatest { [weak self](_) -> Observable<[ReqGetAlarmType.Data]> in
                return self?.getAlarmTypeList() ?? .empty()
            }
            .map({ [weak self] (data) -> [BaseSectionVM]? in
                return self?.viewModel(from: data)
            })
            .bind(to: dataSource)
            .disposed(by: disposeBag)
     
        /// 确定
        didClickConfirm.asObservable()
            .map { [weak self] (_) -> AlarmListFilter in
                return self?.currentFilter ?? AlarmListFilter()
            }
            .bind(to: saveFilter)
            .disposed(by: disposeBag)
        
        didClickConfirm.asObservable()
            .map { [weak self] (_) -> AlarmListFilter in
                return self?.currentFilter ?? AlarmListFilter()
            }
            .bind(to: DataCenter.shared.currnetFilter)
            .disposed(by: disposeBag)
        
        didClickConfirm.asObservable()
          .map { return (Router.UserCenter.closeFilterVC,nil) }
          .bind(to: openRouter)
          .disposed(by: disposeBag)
        
        didClickClose.asObservable()
            .map { return (Router.UserCenter.closeFilterVC,nil) }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        didFinishSelectDate.asObservable()
            .map { $0.0 }
            .bind(to: startTime)
            .disposed(by: disposeBag)
        
        didFinishSelectDate.asObservable()
            .map { $0.1 }
            .bind(to: endTime)
            .disposed(by: disposeBag)
        
        
        /// 初始化
        dataSource.value = viewModel(from: [])
    }
    
    /// 数据转为view model
    private func viewModel(from dataAry: [ReqGetAlarmType.Data]) -> [BaseSectionVM]? {

        let section = BaseSectionVM()
        var sectionAry = [BaseSectionVM]()
        
        section.cellViewModels.append(BigTitleCellVM(title: "筛选"))
       
        /// 报警级别
        let levelCell = AlarmFilterSelectCellVM()
        levelCell.title.value = "保险级别"
        levelCell.allItems.value = AlarmLevel.allSelection.map { $0.desc ?? "--" }
        levelCell.selection.value = level.value
        
        levelCell.selection.asObservable()
            .bind(to: level)
            .disposed(by: disposeBag)
        
        didClickReset.asObservable()
            .map { Set<Int>() }
            .bind(to: levelCell.selection)
            .disposed(by: disposeBag)
        
        section.cellViewModels.append(levelCell)

        /// 处理状态
        let handleStatusCell = AlarmFilterSelectCellVM()
        handleStatusCell.title.value = "处理状态"
        handleStatusCell.allItems.value = Constants.Text.handleStateArr
        handleStatusCell.selection.value = handleStatus.value
        
        handleStatusCell.selection.asObservable()
            .distinctUntilChanged()
            .bind(to: handleStatus)
            .disposed(by: disposeBag)
        
        didClickReset.asObservable()
            .map { Set<Int>() }
            .bind(to: handleStatusCell.selection)
            .disposed(by: disposeBag)
        
        section.cellViewModels.append(handleStatusCell)

        /// 车牌号
        let carLicenseCell = AlarmFilterInputCellVM()
        carLicenseCell.title.value = "车牌号"
        carLicenseCell.placeHolder.value = "车牌号"
        carLicenseCell.isOpenCarKeyBoard.value = true
        carLicenseCell.searchText.value = carLicense.value
        
        carLicenseCell.searchText.asObservable()
            .distinctUntilChanged()
            .bind(to: carLicense)
            .disposed(by: disposeBag)
        
        didClickReset.asObservable()
            .map { "" }
            .bind(to: carLicenseCell.searchText)
            .disposed(by: disposeBag)
        
        section.cellViewModels.append(carLicenseCell)
       
        /// 驾驶员姓名
        let driverNameCell = AlarmFilterInputCellVM()
        driverNameCell.title.value = "驾驶员姓名"
        driverNameCell.placeHolder.value = "驾驶员姓名"
        driverNameCell.searchText.value = driverName.value
        
        driverNameCell.searchText.asObservable()
            .distinctUntilChanged()
            .bind(to: driverName)
            .disposed(by: disposeBag)
        
        didClickReset.asObservable()
            .map { "" }
            .bind(to: driverNameCell.searchText)
            .disposed(by: disposeBag)
        
        section.cellViewModels.append(driverNameCell)
        
        
        /// 开始和结束时间
        let timeCell = AlarmFilterTimeCellVM()
        
        startTime.asObservable()
            .bind(to: timeCell.startDate)
            .disposed(by: disposeBag)
        
        endTime.asObservable()
            .bind(to: timeCell.endDate)
            .disposed(by: disposeBag)
        
        timeCell.didClickSelectDate.asObservable()
            .bind(to: didClickSelectDate)
            .disposed(by: disposeBag)
        section.cellViewModels.append(timeCell)
        
        sectionAry.append(section)
        
        /// 动态类别
        for aData in dataAry {
            let sectionVM = BaseSectionVM()
            
            let cellVM = AlarmFilterSelectCellVM()
            cellVM.flowViewMode.value = .multiSelectItem
            cellVM.title.value = aData.alarmTypeName
            
            var titleItems = [String]()
            var selection = Set<Int>()
            
            for (idx, aType) in aData.alarmTypeList.enumerated() {
                
                titleItems.append(aType.alarmName)
                if selectItem.contains(aType) {
                    selection.insert(idx)
                }
                
                cellVM.selection.asObservable()
                    .filter { $0.contains(idx) }
                    .subscribe(onNext: { [weak self] (_) in
                        self?.selectItem.insert(aType)
                    })
                    .disposed(by: disposeBag)
                
                cellVM.selection.asObservable()
                    .filter { $0.contains(idx) == false }
                    .subscribe(onNext: { [weak self] (_) in
                        self?.selectItem.remove(aType)
                    })
                    .disposed(by: disposeBag)
                
                didClickReset.asObservable()
                    .map { Set<Int>() }
                    .bind(to: cellVM.selection)
                    .disposed(by: disposeBag)
            }
            
            cellVM.allItems.value = titleItems
            cellVM.selection.value = selection
            
            sectionVM.cellViewModels.append(cellVM)
            sectionAry.append(sectionVM)
        }
        
        return sectionAry
    }
    
    /// 网络请求报警类型
    private func getAlarmTypeList() ->Observable<[ReqGetAlarmType.Data]>{
        let reqParam = ReqGetAlarmType(groupId :"")
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqGetAlarmType.Data]? in
                return (rsp.model?.dataList ?? [])
            }
            .filter { $0 != nil }
            .map { $0! }
        req.send()
        return  success
        
    }

}

