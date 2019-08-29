//
//  VehicleGpsFilterVM.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/28.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// gps-过滤界面
class VehicleGpsFilterVM: BaseTableVM {
    
    /// 回调
    let callback = PublishSubject<Set<ReqGetGroups.CarData>>()
    /// 当前选择的
    private var currentSelectItem = Set<ReqGetGroups.CarData>()
    
    // from view
    /// 关闭
    let closeFilter = PublishSubject<Void>()
    
    /// 点击重置按钮
    let didClickResetBtn = PublishSubject<Void>()
    /// 点击确认按钮
    let didClickConfirmBtn = PublishSubject<Void>()
    
    
    override init() {
        super.init()
        
        
        viewWillAppear.asObservable()
            .flatMapLatest { [weak self](_) -> Observable<[ReqGetGroups.Data]> in
                return self?.getGpsGroupList() ?? .empty()
            }
            .map({ [weak self] (data) -> [BaseSectionVM]? in
                return self?.viewModel(from: data)
            })
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        /// 关闭
        closeFilter.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.popBack,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 点击确定
        didClickConfirmBtn.asObservable()
            .map { [weak self] (_) -> Set<ReqGetGroups.CarData> in
                MobClick.event("gps_pos_by_cast")
                return self?.currentSelectItem ?? []
            }
            .bind(to: callback)
            .disposed(by: disposeBag)
        
        didClickConfirmBtn.asObservable()
            .bind(to: closeFilter)
            .disposed(by: disposeBag)
        
    }
    
    /// 网络请求gps分组
    private func getGpsGroupList() ->Observable<[ReqGetGroups.Data]>{
        let reqParam = ReqGetGroups(groupId :DataCenter.shared.userInfo.value?.groupId ?? "", userId: DataCenter.shared.userInfo.value?.userId ?? "")
        let req = reqParam.toDataReuqest()
        
        req.isRequesting.asObservable()
            .map { (value) -> LoadingState in
                return LoadingState(isLoading: value, loadingText: nil)
            }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        let result = req.responseRx.asObservable()
        
        result
            .map { (rsp) -> ErrViewInfo? in
                if rsp.model?.dataList.count > 0 {
                    return nil
                } else {
                    return .noDataFromGpsGroup
                }
            }
            .bind(to: errView)
            .disposed(by: disposeBag)
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqGetGroups.Data]? in
                return (rsp.model?.dataList ?? [])
            }
            .filter { $0 != nil }
            .map { $0! }
        #if DEBUG
        req.send()
        #else
        req.send()
        #endif
        
        return  success
        
    }
    
    /// 数据转为view model
    private func viewModel(from dataAry: [ReqGetGroups.Data]) -> [BaseSectionVM]? {
        let section = BaseSectionVM()
        let bigTitleVM = BigTitleCellVM(title: "分组筛选")
        bigTitleVM.rightTitle.value = "管理分组"
        bigTitleVM.showRightItem.value = true
        section.cellViewModels.append(bigTitleVM)
        
        bigTitleVM.clickRightItem.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.groupManager,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        for gpsGroupData in dataAry {
            
            /// 没有数据的不显示
            if gpsGroupData.vehicleDtoList.count == 0 {
                continue
            }
            
            /// 头部
            let cellHeadVM = VehicleGpsHeadCellVM()
            cellHeadVM.groupTitle.value = gpsGroupData.gpsGropName +  "("+"\(gpsGroupData.vehicleDtoList.count)" + ")"
            section.cellViewModels.append(cellHeadVM)
            
            /// 流式
            let cellVM = VehicleGpsFilterCellVM()
            cellVM.flowViewMode.value = .multiSelectItem
            section.cellViewModels.append(cellVM)
            
            /// 重置
            didClickResetBtn.asObservable()
                .map { return Set<Int>() }
                .bind(to: cellVM.selection)
                .disposed(by: disposeBag)
            
            /// 该分组下的车辆号
            let allGroupCar = Set<ReqGetGroups.CarData>(gpsGroupData.vehicleDtoList)
            var disabledIndx = Set<Int>()
            for (idx, aCar) in allGroupCar.enumerated() {
                if aCar.status == 0 {
                    disabledIndx.insert(idx)
                }
            }
            
            cellVM.allItems.value = allGroupCar.map { $0.carLicense }
            cellVM.disableIndexs.value = disabledIndx
            
            /// 选择/取消选择
            cellVM.selection.asObservable()
                .subscribe(onNext: { [weak self] (selectionIndexs) in
                    for (idx,aCar) in allGroupCar.enumerated() {
                        if selectionIndexs.contains(idx) {
                            self?.currentSelectItem.insert(aCar)
                        } else {
                            self?.currentSelectItem.remove(aCar)
                        }
                    }
                })
                .disposed(by: disposeBag)
            
            /// 全选，反选
            cellHeadVM.didClickAllSelect.asObservable()
                .map({ (value) -> Set<Int> in
                    if value && allGroupCar.count > 0 {
                        return Set<Int>(0..<allGroupCar.count)
                    } else {
                        return []
                    }
                })
                .bind(to: cellVM.selection)
                .disposed(by: disposeBag)
            
            cellVM.selection.asObservable()
                .map { $0.count == allGroupCar.count && allGroupCar.count > 0}
                .bind(to: cellHeadVM.isAllSelected)
                .disposed(by: disposeBag)

            /// 展开(折叠)
            cellHeadVM.isOpen.asObservable()
                .bind(to: cellVM.cellIsOpen)
                .disposed(by: disposeBag)
            
            /// 是否可以展开(折叠)
            cellVM.didComputeCellFullLine.asObservable()
                .map { $0 > 2 }
                .bind(to: cellHeadVM.isEnableOpen)
                .disposed(by: disposeBag)
        }
        
        return [section]
        
    }
}
