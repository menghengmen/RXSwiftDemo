//
//  VehicleGpsGroupEditVM.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/2.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 编辑分组
class VehicleGpsGroupEditVM: BaseTableVM {
    
    /// 页面类型
    enum VehicleGroupEditType {
        ///  编辑
        case editGroup
        ///  默认
        case lookGroup
        
    }
    
    ///  界面模式
    let editVCType = Variable<VehicleGroupEditType>(.editGroup)
    
    /// 当前id
    private var groupId = ""
    /// 当前数据
    private let groupDatas = Variable<Set<ReqGetGroups.CarData>>([])
    
    // to view
    /// 分组名
    let groupName = Variable<String>("")
    
    // from view
    /// 点击取消按钮
    let didClickCancleBtn = PublishSubject<Void>()
    /// 点击保存信息按钮
    let didClickSaveBtn = PublishSubject<Void>()
    /// 点击编辑按钮
    let didClickEditBtn = PublishSubject<Void>()
    /// 点击添加车辆按钮
    let didClickAddVehicleBtn = PublishSubject<Void>()
    
    /// 保存选择器
    let didSaveSelector = PublishSubject<Set<ReqGetAllVehiclesGroup.Data>>()
    
    
    init(groupArray: ReqGetGroups.Data) {
        super.init()
        
        groupId = groupArray.gpsGroupId
        groupName.value = groupArray.gpsGropName
        groupDatas.value = Set<ReqGetGroups.CarData>(groupArray.vehicleDtoList)
        
        groupDatas.asObservable()
            .map { [weak self] (value) -> [BaseSectionVM] in
                self?.viewModel(from: value) ?? []
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        /// 点击删除按钮
        didClickEditBtn.asObservable()
            .map { (_) -> VehicleGroupEditType in
                return .editGroup
            }
            .bind(to: editVCType)
            .disposed(by: disposeBag)
        
        /// 点击取消按钮
        didClickCancleBtn.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.popBack,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 点击保存按钮
        let updateGroupSuccess =  didClickSaveBtn.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<Void> in
               
//                var gpsVehiclesIds = ""
//                for selectItem in self?.groupDatas.value ?? [] {
//                    gpsVehiclesIds.append((gpsVehiclesIds.isEmpty ? "" : ",") + selectItem.vehicleId)
//                }
                
                let gpsVehiclesIds = (self?.groupDatas.value ?? []).map { $0.vehicleId }
                return  self?.editGroupReq(vehicleIds: gpsVehiclesIds , groupName: self?.groupName.value ?? "")  ?? .empty()
           }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
         updateGroupSuccess.asObservable()
            .map { AlertMessage(message: "更新成功", alertType: .toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        updateGroupSuccess.asObservable()
            .delay(2, scheduler: MainScheduler.instance)
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.popBack,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 选择车辆
        didSaveSelector.asObservable()
            .map({ [weak self] (value) -> Set<ReqGetGroups.CarData> in
                
                var currentData = self?.groupDatas.value ?? []
                for aValue in value {
                    currentData.insert(ReqGetGroups.CarData(vehicleId: aValue.vehicleId, carLicense: aValue.carLicense, status: 1))
                }
                return currentData
            })
            .bind(to: groupDatas)
            .disposed(by: disposeBag)
        
        ///  添加车辆
        didClickAddVehicleBtn.asObservable()
            .map { [weak self] (_) -> RouterInfo in
                return (Router.UserCenter.groupAddVehicle,["callback": self?.didSaveSelector])
             }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
    }
    
    /// 编辑分组
    private func editGroupReq(vehicleIds:[String] ,groupName: String) -> Observable<Void>{
        
        let reqParam = ReqEditGroup(groupId: groupId, vehicleList: vehicleIds, groupName: groupName)
        let req = reqParam.toDataReuqest()
        let result = req.responseRx.asObservable()
        let success = result
            .filter { $0.isSuccess()}
            .map { (rsp) -> Void in
        }
        
        result
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)

        req.send()
        
        return success
    }
    
    /// 数据转为vm
    private func viewModel(from data: Set<ReqGetGroups.CarData>) -> [BaseSectionVM] {
        
        let section = BaseSectionVM()
        let titleVM = VehicleGpsGroupNameCellVM()
        titleVM.title.value = groupName.value
        
        editVCType.asObservable()
            .map { $0 == .editGroup }
            .bind(to: titleVM.isEnableEditGroupName)
            .disposed(by: disposeBag)
        titleVM.title.asObservable()
            .bind(to: groupName)
            .disposed(by: disposeBag)
        
        section.cellViewModels.append(titleVM)
        
        /// 流式
        let dataAry = [ReqGetGroups.CarData](data)
        
        let cellVM = VehicleGpsFilterCellVM()
        cellVM.cellIsOpen.value = true
        
        cellVM.allItems.value = dataAry.map { $0.carLicense }
        
        cellVM.didDeleteItem.asObservable()
            .map { (idx) -> Set<ReqGetGroups.CarData> in
                
                if idx < dataAry.count {
                    var newDataAry = dataAry
                    newDataAry.remove(at: idx)
                    return Set<ReqGetGroups.CarData>(newDataAry)
                }
                return []
            }
            .bind(to: groupDatas)
            .disposed(by: disposeBag)
        
        
    
        cellVM.flowViewMode.value = .deleteItem
        section.cellViewModels.append(cellVM)
        
        return [section]
    }
    

}
