//
//  VehicleGpsSearchVM.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/29.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// gps-搜索界面
class VehicleGpsSearchVM: BaseTableVM {
    
    /// 回调
    var callback = PublishSubject<Set<ReqQueryAllVehiclesGps.Data>>()
    
    ///数据源
    var dataArray = [ReqQueryAllVehiclesGps.Data]()
    /// 当前选择的
    private var currentSelectItem = Set<ReqQueryAllVehiclesGps.Data>()
    
    // to view
    /// 搜索字符(双向绑定)
    let searchText = Variable<String>("")
    
    /// 关闭
    let closeFilter = PublishSubject<Void>()
    /// 点击重置按钮
    let didClickResetBtn = PublishSubject<Void>()
    /// 点击确认按钮
    let didClickConfirmBtn = PublishSubject<Void>()
    
    /// 网络请求刷新数据
    private let updateDataFromServer = PublishSubject<Void>()
    
    override init() {
        super.init()
        
        viewWillAppear.asObserver()
            .bind(to: updateDataFromServer)
            .disposed(by: disposeBag)
        
        /// 网络请求的数据
        updateDataFromServer.asObservable()
            .flatMapLatest { [weak self](_) -> Observable<[ReqQueryAllVehiclesGps.Data]> in
                return self?.queryVehicles(groupId: "") ?? .empty()
            }
            .map({ [weak self] (data) -> [BaseSectionVM]? in
                self?.dataArray = data
                return self?.viewModel(from: data)
            })
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        /// 搜索
        searchText.asObservable()
            .skip(2)
            .distinctUntilChanged()
            .flatMapLatest { [weak self] (text) ->Observable<[ReqQueryAllVehiclesGps.Data]> in
                MobClick.event("gps_pos_by_search")

                return self?.localFilter(searchText: text, data: self?.dataArray ?? []) ?? .empty()
            }
            .map { [weak self] (data) -> [BaseSectionVM]? in
                return self?.viewModel(from: data)
            }
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
            .map { [weak self] (_) -> Set<ReqQueryAllVehiclesGps.Data> in
                return self?.currentSelectItem ?? []
            }
            .bind(to: callback)
            .disposed(by: disposeBag)
        
        didClickConfirmBtn.asObservable()
            .bind(to: closeFilter)
            .disposed(by: disposeBag)
        
    }
    
    /// 本地搜索
    private func localFilter(searchText: String, data: [ReqQueryAllVehiclesGps.Data]) ->Observable<[ReqQueryAllVehiclesGps.Data]> {
        var filterData = [ReqQueryAllVehiclesGps.Data]()
        for sectionModel in data {
            if searchText.count == 0 ||  sectionModel.carLicense.lowercased().contains(searchText.lowercased()){
                filterData.append(sectionModel)
            }
        }
        return Observable.just(filterData)
        
    }
    
    
    /// 网络请求所有车辆的信息
    private func queryVehicles(groupId:String ) ->Observable<[ReqQueryAllVehiclesGps.Data]>{
        let reqParam = ReqQueryAllVehiclesGps(groupId: DataCenter.shared.userInfo.value?.groupId ?? "")
        let req = reqParam.toDataReuqest()
        
        req.isRequesting.asObservable()
            .map { (value) -> LoadingState in
                return LoadingState(isLoading: value, loadingText: nil)
            }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        let result = req.responseRx.asObservable()
        
        result.asObservable()   // 错误提示
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqQueryAllVehiclesGps.Data]? in
                return (rsp.model?.dataList ?? [])
            }
            .filter { $0 != nil }
            .map { $0! }
        req.send()
        return  success
        
    }
    
    /// 数据转为view model
    private func viewModel(from dataAry: [ReqQueryAllVehiclesGps.Data]) -> [BaseSectionVM] {
        
        let section = BaseSectionVM()
        let titleArr = ["运行车辆","报警车辆","车钥匙关","离线车辆"]
        var vehicleArr1 = [ReqQueryAllVehiclesGps.Data]()
        var vehicleArr2 = [ReqQueryAllVehiclesGps.Data]()
        var vehicleArr3 = [ReqQueryAllVehiclesGps.Data]()
        var vehicleArr4 = [ReqQueryAllVehiclesGps.Data]()
        var vehicleArr = [[ReqQueryAllVehiclesGps.Data]]()
        for vehicle in dataAry{
            if vehicle.status == .normal {
                vehicleArr1.append(vehicle)
            } else if vehicle.status == .alarming {
                vehicleArr2.append(vehicle)
            } else if vehicle.status == .shutdown {
                vehicleArr3.append(vehicle)
            } else if vehicle.status == .offline {
                vehicleArr4.append(vehicle)
            }
        }
        vehicleArr.append(vehicleArr1)
        vehicleArr.append(vehicleArr2)
        vehicleArr.append(vehicleArr3)
        vehicleArr.append(vehicleArr4)
        
        for (idx, aTitle) in titleArr.enumerated() {
            
            guard let vehiclesOfType = vehicleArr.yd[idx] else {
                continue
            }
            
            guard vehiclesOfType.count > 0 else {
                continue
            }
            
            /// 头部
            let cellHeadVM = VehicleGpsHeadCellVM()
            cellHeadVM.groupTitle.value = aTitle
            section.cellViewModels.append(cellHeadVM)
            /// 流式
            let cellVM = VehicleGpsFilterCellVM()
            cellVM.flowViewMode.value = .multiSelectItem
            section.cellViewModels.append(cellVM)
            cellVM.allItems.value = vehiclesOfType.map { $0.carLicense }
            
            /// 重置
            didClickResetBtn.asObservable()
                .map {
                    return Set<Int>()
                }
                .bind(to: cellVM.selection)
                .disposed(by: disposeBag)
            
            /// 选择/取消选择
            cellVM.selection.asObservable()
                .subscribe(onNext: { [weak self] (selectionIndexs) in
                    for (idx,aCar) in vehiclesOfType.enumerated() {
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
                    if value && vehiclesOfType.count > 0 {
                        return Set<Int>(0..<vehiclesOfType.count)
                    } else {
                        return []
                    }
                })
                .bind(to: cellVM.selection)
                .disposed(by: disposeBag)
            
            cellVM.selection.asObservable()
                .map { $0.count == vehiclesOfType.count && vehiclesOfType.count > 0}
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
