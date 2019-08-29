//
//  VehicleGpsGroupManagerVM.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/2.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 分组管理
class VehicleGpsGroupManagerVM: BaseTableVM {
    /// 页面类型
    enum VehicleGroupManagerType {
        ///  编辑
        case editGroup
        ///  默认
        case lookGroup
        
    }
    
    /// 当前选择的
    var currentSelectItem = Set<String>()
    ///  界面模式
    let managerType = Variable<VehicleGroupManagerType>(.lookGroup)
    
    // from view
    /// 点击取消按钮
    let didClickCancleBtn = PublishSubject<Void>()
    /// 点击确认按钮
    let didClickSureBtn = PublishSubject<Void>()
    /// 点击删除按钮
    let didClickDeleteBtn = PublishSubject<Void>()
    /// 点击新增组按钮
    let didClickAddGroupBtn = PublishSubject<Void>()
    
    override init() {
        super.init()
        
        /// 点击确定
        didClickSureBtn.asObservable()
            .filter({ [weak self] (_) -> Bool in
                (self?.currentSelectItem.count > 0) == false
            })
            .map { VehicleGroupManagerType.lookGroup }
            .bind(to: managerType)
            .disposed(by: disposeBag)
        
        let deleteSuccess = didClickSureBtn.asObservable()
            .filter({ [weak self] (_) -> Bool in
                self?.currentSelectItem.count > 0
            })
            .flatMapLatest { [weak self] (_) -> Observable<Void> in
                return self?.deleteGroupReq(gpsGroupIds: self?.currentSelectItem ?? []) ?? . empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        deleteSuccess.asObservable()
            .map { AlertMessage(message: "删除成功", alertType: .toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        /// 刷新数据
        Observable.merge(viewWillAppear.asObservable(), deleteSuccess.asObservable())
            .flatMapLatest { [weak self](_) -> Observable<[ReqGetGroups.Data]> in
                return self?.getGpsGroupList() ?? .empty()
            }
            .map({ [weak self] (data) -> [BaseSectionVM]? in
                return self?.viewModel(from: data)
            })
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        ///  取消
        didClickCancleBtn.asObservable()
            .map { (_) -> VehicleGroupManagerType in
                return .lookGroup
            }
            .bind(to: managerType)
            .disposed(by: disposeBag)
        
        /// 点击删除按钮
        didClickDeleteBtn.asObservable()
            .map { (_) -> VehicleGroupManagerType in
                return .editGroup
            }
            .bind(to: managerType)
            .disposed(by: disposeBag)
        
        /// 跳转
        didSelecCell.asObservable()
            .filter({ [weak self] (_) -> Bool in
                self?.managerType.value == .lookGroup
            })
            .map { (vm) -> RouterInfo in
                if let cellVM = vm as? VehicleGpsGroupManagerCellVM {
                    return (Router.UserCenter.groupEdit,["groups":cellVM.groupData])
                    
                } else {
                    return (nil,nil)
                }
                
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 新增分组
        didClickAddGroupBtn.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.addGroup,nil)
            }
            .bind(to: openRouter)
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
       
        req.send()
        
        return  success
        
    }
    
    /// 删除组
    private func deleteGroupReq(gpsGroupIds: Set<String>) -> Observable<Void>{
        
        let reqParam = ReqDeleteGroup(gpsGroupIdList: [String](gpsGroupIds))
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
    
    /// 数据转为view model
    private func viewModel(from dataAry: [ReqGetGroups.Data]) -> [BaseSectionVM]? {
        
        let section = BaseSectionVM()
        section.cellViewModels.append(BigTitleCellVM(title: "分组管理"))
        
        for group in dataAry {
            // for group in groupArray {
            let cellVM =  VehicleGpsGroupManagerCellVM()
            cellVM.groupData = group
            cellVM.groupTitle.value = group.gpsGropName +  "("+"\(group.vehicleDtoList.count)" + ")"
            
            managerType.asDriver()
                .map {  return $0 == .lookGroup ? false : true }
                .drive(cellVM.isEditMode)
                .disposed(by: disposeBag)
            
            /// 编辑模式下不跳转
            didSelecCell.asObservable()
                .filter({ [weak self] (vm) -> Bool in
                    (vm as? VehicleGpsGroupManagerCellVM)?.groupData?.gpsGroupId == group.gpsGroupId  && self?.managerType.value == .editGroup
                })
                .map { [weak cellVM] (_) -> Bool in
                    return !(cellVM?.isCellSelected.value ?? false)
                }
                .bind(to: cellVM.didClickSelect)
                .disposed(by: disposeBag)
            
            cellVM.didClickSelect.asObservable()
                .subscribe(onNext: { [weak self] (value) in
                    if value {
                        self?.currentSelectItem.insert(group.gpsGroupId)
                    } else {
                        self?.currentSelectItem.remove(group.gpsGroupId)
                    }
                })
                .disposed(by: disposeBag)
            
            section.cellViewModels.append(cellVM)
        
        }
        
        return [section]
        
    }
}
