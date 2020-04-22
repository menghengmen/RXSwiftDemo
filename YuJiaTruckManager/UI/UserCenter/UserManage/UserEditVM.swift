//
//  UserEditVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa


/// 用户管理-用户编辑/新建页
class UserEditVM: BaseVM {
    
    // to view
    /// 是否为新建用户
    let isCreateUser = Variable<Bool>(false)
    /// 姓名
    let name  = Variable<String?>(nil)
    /// 手机号
    let phone  = Variable<String?>(nil)
    /// 是否可以点击
    let isEnableClick = Variable<Bool>(false)
    
    // from view
    /// 点击确认
    let clickConfirm = PublishSubject<Void>()
    
    init(isCreateUser:Bool ,name:String ,phone:String) {
        super.init()
        self.isCreateUser.value = isCreateUser
        self.name.value = name
        self.phone.value = phone
        
        
        // 是否可以点击
        
        Observable<Bool>.combineLatest(self.name.asObservable(), self.phone.asObservable()) { (nameTxt, phoneTxt) -> Bool in
            return nameTxt?.count > 0 && phoneTxt?.count > 0
            }
            .bind(to: isEnableClick)
            .disposed(by: disposeBag)
        
        /// 编辑用户
        let editSuccess = clickConfirm.asObservable()
            .filter { isCreateUser == false }
            .flatMapLatest { [weak self](_) -> Observable<ReqEditUser.Model> in
                return self?.editUserReq(name: self?.name.value ?? "", phone: self?.phone.value ?? "" ,oldPhone:phone ) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        editSuccess.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.popBack,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        
        ///点击确认（新增用户）
        let addSuccess = clickConfirm.asObservable()
            .filter { isCreateUser == true}
            .flatMapLatest { [weak self](_) -> Observable<ReqAddUser.Model> in
                return self?.addUserReq(name: (self?.name.value ?? ""), phone:( self?.phone.value ?? "")) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        addSuccess.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.popBack,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        
    }
    /// 更新用户信息网络请求
    private func editUserReq(name:String,phone :String, oldPhone: String) -> Observable<ReqEditUser.Model>{
        
        let reqParam = ReqEditUser(tel: phone, name: name, oldTel: oldPhone)
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> ReqEditUser.Model in
                return rsp.model!
        }
        
        result
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        req.send()
        return success
        
    }
    /// 新增用户信息
    private func addUserReq(name:String,phone :String) -> Observable<ReqAddUser.Model>{
        
        let reqParam = ReqAddUser(name: name, tel: phone ,groupId :DataCenter.shared.userInfo.value?.groupId ?? "")
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> ReqAddUser.Model in
                return rsp.model!
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





