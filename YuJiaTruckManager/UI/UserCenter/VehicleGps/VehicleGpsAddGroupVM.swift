//
//  VehicleGpsAddGroupVM.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/3.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 增加分组
class VehicleGpsAddGroupVM: BaseVM {
    // to view
    /// 分组名输入
    let groupNameInput = Variable<String>("")
    /// 是否可以点击
    let isEnabelClickSureBtn = Variable<Bool>(false)
    
    // from view
    ///点击确定
    let clickSureBtn = PublishSubject<Void>()
    
    override init() {
        super.init()
        
        groupNameInput.asObservable()
            .map {  (value) -> Bool in
               return value.count > 0 && value.count < 21
            }
            .bind(to: isEnabelClickSureBtn)
            .disposed(by: disposeBag)
        /// 点击确定
         let addGroupSuccess = clickSureBtn.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<Void> in
                return self?.addGroupReq(groupName: self?.groupNameInput.value ?? "") ?? . empty()
            }
           .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
//        addGroupSuccess.asObservable()
//            .map { AlertMessage(message: "添加成功", alertType: .toast) }
//            .bind(to: showMessage)
//            .disposed(by: disposeBag)
           
        addGroupSuccess.asObservable()
            .map { (Router.UserCenter.popBack, nil) }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
    
    }
   
    /// 添加分组网络请求
    private func addGroupReq(groupName:String ) -> Observable<Void>{
        
        let reqParam = ReqAddGroup(groupId: DataCenter.shared.userInfo.value?.groupId ?? "", gpsGroupName: groupName, userId: DataCenter.shared.userInfo.value?.userId ?? "")
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

}
