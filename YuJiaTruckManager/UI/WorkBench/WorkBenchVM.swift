//
//  WorkBenchVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/7/7.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import YuDaoComponents
/// 工作台VM
class WorkBenchVM: BaseTableVM {
    
    // 私有事件
    /// 刷新数据
    private let updateWorkbenchList = PublishSubject<Void>()
    override init() {
        super.init()
        
        viewWillAppear.asObservable()
          .bind(to: updateWorkbenchList)
          .disposed(by: disposeBag)
        
        updateWorkbenchList.asObservable()
            .flatMapLatest { [weak self](_) -> Observable<[ReqWorkbenchList.Data]> in
                return self?.getworkBenchList() ?? .empty()
          }
            .map { [weak self](data) -> [BaseSectionVM]? in
                return self?.viewModel(from: data)
           }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
     
        
        didSelecCell.asObservable()
            .map { (_) -> RouterInfo in
             return (Router.Login.goStoreDetail,nil)
          }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
      
    }

    
    /// 数据转为view model
    private func viewModel(from dataAry: [ReqWorkbenchList.Data]) -> [BaseSectionVM]? {
        
        var sectionAry = [BaseSectionVM]()
        
        
        for aData in dataAry {
            let sectionVM = BaseSectionVM()
            
            let userCellVM = UserCenterUserInfoCellVM()
            userCellVM.isEnterpriseUser.value = false
            sectionVM.cellViewModels.append(userCellVM)
            
            let cellVM = WorkBenchStoreStateCellVM(data:aData)
            sectionVM.cellViewModels.append(cellVM)
            sectionAry.append(sectionVM)
          
        }
     

        return sectionAry
    }
    
    /// 网络请求司机列表
    private func getworkBenchList() ->Observable<[ReqWorkbenchList.Data]>{
        let reqParam = ReqWorkbenchList()
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        result.asObservable()   // 错误提示
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqWorkbenchList.Data]? in
                return (rsp.model?.dataList ?? [])
            }
            .filter { $0 != nil }
            .map { $0! }
        
        
        req.send(mockKey: "Demo")
        return  success
        
    }
}
