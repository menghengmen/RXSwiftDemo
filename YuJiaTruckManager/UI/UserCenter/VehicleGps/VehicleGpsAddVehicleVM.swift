//
//  VehicleGpsAddVehicleVM.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/3.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 分组添加车辆
class VehicleGpsAddVehicleVM: BaseTableVM {
    
    /// 网络请求数据源
    var dataArrayFormServer = [ReqGetAllVehiclesGroup.Data]()
    /// 刷新数据
    private let updateDataFromServer = PublishSubject<Void>()
    /// 当前选择的车辆
    var currentSelectVehicleInfo = Set<ReqGetAllVehiclesGroup.Data>(Set())
    
    // 属性
    /// call back
    let callback = PublishSubject<Set<ReqGetAllVehiclesGroup.Data>>()
    
    
    // from view
    /// 关闭
    let closeFilter = PublishSubject<Void>()
    /// 点击重置按钮
    let didClickResetBtn = PublishSubject<Void>()
    /// 点击确认按钮
    let didClickConfirmBtn = PublishSubject<Void>()
    /// 搜索字符(双向绑定)
    let searchText = Variable<String>("")
  
    override init() {
        super.init()
       
        viewWillAppear.asObservable()
           .bind(to: updateDataFromServer)
           .disposed(by: disposeBag)
        
        searchText.asObservable()
            .filter ({ [weak self] (_) -> Bool in
                return self?.searchText.value == ""
             })
            .map{ (_) -> Void in }
            .bind(to: updateDataFromServer)
            .disposed(by: disposeBag)
        /// 网络请求
        updateDataFromServer.asObservable()
            .flatMapLatest { [weak self](_) -> Observable<[ReqGetAllVehiclesGroup.Data]> in
                return self?.queryCompanyVehicles() ?? . empty()
             }
            .map { [weak self] (data) -> [BaseSectionVM] in
                self?.dataArrayFormServer = data
                return self?.viewModel(from: data) ?? []
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        /// 本地搜索
        searchText.asObservable()
            .skip(2)
            .distinctUntilChanged()
            .flatMapLatest { [weak self](txt) -> Observable<[ReqGetAllVehiclesGroup.Data]> in
                return  self?.localFilter(searchText: txt) ?? .empty()
            }
            .map { [weak self] (data) -> [BaseSectionVM]? in
                return self?.viewModel(from: data)
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
       
    
        // 关闭
        closeFilter.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.closeFilterVC,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        /// 确定
        didClickConfirmBtn.asObservable()
            .map { [weak self] (_) -> Set<ReqGetAllVehiclesGroup.Data> in
                return self?.currentSelectVehicleInfo ?? Set()
            }
            .bind(to: callback)
            .disposed(by: disposeBag)

        didClickConfirmBtn.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.closeFilterVC,nil)
           }
           .bind(to: openRouter)
           .disposed(by: disposeBag)
        
    }
    
    /// 本地搜索
    private func localFilter(searchText: String) ->Observable<[ReqGetAllVehiclesGroup.Data]> {
        var filterData = [ReqGetAllVehiclesGroup.Data]()
        for sectionModel in dataArrayFormServer {
            if sectionModel.carLicense.contains(searchText){
                filterData.append(sectionModel)
            }
        }
        return Observable.just(filterData)
        
    }
    
    /// 数据转为view model
    private func viewModel(from dataAry: [ReqGetAllVehiclesGroup.Data]) -> [BaseSectionVM]? {
        let section = BaseSectionVM()
        
        /// 流式
        let cellVM = VehicleGpsFilterCellVM()
        /// 重置
        didClickResetBtn.asObservable()
            .map { return Set<Int>() }
            .bind(to: cellVM.selection)
            .disposed(by: disposeBag)
        
        /// 选择/取消选择
        cellVM.selection.asObservable()
            .subscribe(onNext: { [weak self] (selectionIndexs) in
                for (idx,aCar) in dataAry.enumerated() {
                    if selectionIndexs.contains(idx) {
                        self?.currentSelectVehicleInfo.insert(aCar)
                    } else {
                        self?.currentSelectVehicleInfo.remove(aCar)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        cellVM.cellIsOpen.value = true
        cellVM.allItems.value = dataAry.map { $0.carLicense }
        cellVM.flowViewMode.value = .multiSelectItem
        section.cellViewModels.append(cellVM)
        return [section]
        
    }
    
    /// 网络请求公司下面的车辆
    private func queryCompanyVehicles() ->Observable<[ReqGetAllVehiclesGroup.Data]>{
        let reqParam = ReqGetAllVehiclesGroup(groupId: DataCenter.shared.userInfo.value?.groupId ?? "")
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        result.asObservable()   // 错误提示
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqGetAllVehiclesGroup.Data]? in
                return (rsp.model?.dataList ?? [])
            }
            .filter { $0 != nil }
            .map { $0! }
        
        req.send()
        
        return  success
        
    }
}
