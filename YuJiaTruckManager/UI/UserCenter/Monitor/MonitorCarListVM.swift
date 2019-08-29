//
//  MonitorCarListVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 实时监控-车辆选择
class MonitorCarListVM: BaseTableVM {
    
    // to view
    /// 搜索字符(双向绑定)
    let searchText = Variable<String>("")
    
    // from view
    /// 点击搜索按钮
    let didClickSearch = PublishSubject<Void>()
    
    /// 点击选择车辆
    let didSelectCar = PublishSubject<(String,String)>()
    
    // 私有事件
    /// 刷新数据
    private let updateCarList = PublishSubject<Void>()
    
    
    override init() {
        super.init()
        
        viewDidAppear.asObservable()
            .bind(to: updateCarList)
            .disposed(by: disposeBag)
        
        
        updateCarList.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<[ReqGetCanSendCommandVehicles.Data]> in
                return self?.sendCommandVehicle() ?? .empty()
            }
            .map { [weak self] (data) -> [BaseSectionVM]? in
                return   self?.ViewModel(from: data)
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        searchText.asObservable()
            .skip(3)
            .filter{ [weak self] _ in self?.searchText.value == "" }
            .flatMapLatest { [weak self] (_) -> Observable<[ReqGetCanSendCommandVehicles.Data]> in
                return self?.sendCommandVehicle() ?? .empty()
            }
            .map { [weak self] (data) -> [BaseSectionVM]? in
                return   self?.ViewModel(from: data)
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        
        
        searchText.asObservable()
            .skip(2)
            .filter{ [weak self] _ in self?.searchText.value != ""}
            .throttle(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] (TXT) -> Observable<[ReqSearchtCanSendCommandVehicles.Data]> in
                return self?.searchSendCommandVehicle(searchText: TXT) ?? .empty()
            }
            .map { [weak self] (data) -> [BaseSectionVM]? in
                return self?.searchViewModel(from: data)
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        
        /// 搜锁
        didClickSearch.asObservable()
            .map({ [weak self] (_) -> String in
                return self?.searchText.value ?? ""
            })
            .bind(to: searchText)
            .disposed(by: disposeBag)
        
        
        /// 选择车辆回调
        let selectCar = didSelecCell.asObservable()
            .filter ({ (vm) -> Bool in
                return  (vm as?MonitorCarListCellVM)?.onLineStar.value == "1"
            })
            .map { (cellVM) -> (String,String) in
                return ((cellVM as?MonitorCarListCellVM )?.vehicleId.value ?? "",
                        (cellVM as?MonitorCarListCellVM )?.carLicence.value ?? "")
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        selectCar.asObservable()
            .bind(to: didSelectCar)
            .disposed(by: disposeBag)
        
        selectCar.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.popBack,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 不在线的车
        didSelecCell.asObservable()
            .filter ({ (vm) -> Bool in
                return  (vm as?MonitorCarListCellVM)?.onLineStar.value != "1"
            })
            .map{ _ in AlertMessage(message:"当前车辆不在线，无法实时监控", alertType: AlertMessage.AlertType.toast)
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        
    }
    
    /// 监控车辆
    private func sendCommandVehicle( ) ->Observable<[ReqGetCanSendCommandVehicles.Data]>{
        
        let reqParam = ReqGetCanSendCommandVehicles(groupId: DataCenter.shared.userInfo.value?.groupId ?? "", pageSize : "50" )
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqGetCanSendCommandVehicles.Data]? in
                return (rsp.model?.dataList ?? [])
            }
            .filter { $0 != nil }
            .map { $0! }
        
        success.asObservable()
            .filter({ [weak self] (_) -> Bool in
                return self?.searchText.value == ""
            })
            .map { (rsp) -> ErrViewInfo? in
                return nil
            }
            .bind(to: errView)
            .disposed(by: disposeBag)

        req.send()
        return  success
    }
    /// search车辆
    private func searchSendCommandVehicle(searchText: String ) ->Observable<[ReqSearchtCanSendCommandVehicles.Data]>{
        
        let reqParam = ReqSearchtCanSendCommandVehicles(groupId: DataCenter.shared.userInfo.value?.groupId ?? "", carLicense : searchText )
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqSearchtCanSendCommandVehicles.Data]? in
                return (rsp.model?.dataList ?? [])
            }
            .filter { $0 != nil }
            .map { $0! }
        
        success.asObservable()
            .filter({ [weak self] (_) -> Bool in
                return self?.searchText.value != ""
            })
            .map { (rsp) -> ErrViewInfo? in
                if rsp.count == 0{
                    return .noDataFromSearch
                } else {
                    return nil
                }
            }
            .bind(to: errView)
            .disposed(by: disposeBag)
        
        req.send()
        return  success
    }
    
    
    /// 数据转化为view model
    private func ViewModel(from dataAry: [ReqGetCanSendCommandVehicles.Data]) -> [BaseSectionVM]? {
        
        var section = [BaseSectionVM]()
        for aData in dataAry {
            let sectionVM = BaseSectionVM()
            let cellVM = MonitorCarListCellVM(data :aData)
            sectionVM.cellViewModels.append(cellVM)
            section.append(sectionVM)
            
        }
        return section
        
    }
    
    private func searchViewModel(from dataAry: [ReqSearchtCanSendCommandVehicles.Data]) -> [BaseSectionVM]? {
        
        var section = [BaseSectionVM]()
        for aData in dataAry {
            let sectionVM = BaseSectionVM()
            let cellVM = MonitorCarListCellVM(data :aData)
            sectionVM.cellViewModels.append(cellVM)
            section.append(sectionVM)
            
        }
        return section
        
    }
    
}
