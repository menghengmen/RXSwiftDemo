//
//  AdminLoginVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/23.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa


/// 管理员登录页
class AdminLoginVM: BaseVM {
    
    // to view
    ///账号输入
    let accountInput = Variable<String>("")
    /// 密码输入
    let passwordInput = Variable<String>("")
    /// 是否可以点击下一步
    let isEnabelClickNext = Variable<Bool>(false)
    
    // from view

    ///点击下一步
    let clickNextBtn = PublishSubject<Void>()
  

    init(isShowClose: Bool) {
        super.init()
        
        // 是否可以点击
        let inputCheck = Observable<Bool>.combineLatest(accountInput.asObservable(), passwordInput.asObservable()) { (account, password) -> Bool in
            account.count > 0 && password.count > 0
            }
        
        inputCheck.asObservable()
            .bind(to: isEnabelClickNext)
            .disposed(by: disposeBag)
        
        
        /// 点击下一步管理员登录
       let adminLoginSuccess = clickNextBtn.asObservable()
            .flatMapLatest {[weak self] (_) -> Observable<ReqLogin.Data> in
            MobClick.event("admin_login")
            UserDefaultsManager.shared.account = self?.accountInput.value
            return self?.adminLogin(account: (self?.accountInput.value ?? ""), password:( self?.passwordInput.value ?? "")) ?? .empty()
          }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
       
        adminLoginSuccess.asObservable()
           .bind(to: MessageCenter.shared.didLogin)
           .disposed(by: disposeBag)
        
        adminLoginSuccess.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.Login.close,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
          
    }
    /// 管理员登录网络请求
    private func adminLogin(account :String ,password :String) ->Observable<ReqLogin.Data>{
        let reqParam = ReqLogin(tel: account, code: password, loginType: "1")
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        req.isRequesting.asObservable()
            .map { (value) -> LoadingState in
                return LoadingState(isLoading: value)
            }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> ReqLogin.Data? in
                return rsp.model?.data
            }
            .filter { $0 != nil }
            .map { $0! }
        
        result
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        req.send()
        
        return success
        
    }

}
