//
//  LoginVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/22.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa


/// 登录页
class LoginVM: BaseVM {
    
    // to view
    /// 是否可以关闭
    let isShowCloseBtn = Variable<Bool>(false)
    ///手机号输入
    let phoneInput = Variable<String>("")
    /// 勾选隐私协议
    let isCheckPrivacy = Variable<Bool>(true)
    
    // from view
    /// 点击关闭
    let clickCloseBtn = PublishSubject<Void>()
    ///点击下一步
    let clickNextBtn = PublishSubject<Void>()
    ///点击管理员登录
    let clickAdminLoginBtn = PublishSubject<Void>()
    /// 点击勾选按钮
    let clickCheckBtn = PublishSubject<Void>()
    /// 点击隐私链接
    let clickPrivacyLink = PublishSubject<Void>()
    
    init(isShowClose: Bool) {
        super.init()
        
        /// 是否可以关闭
        isShowCloseBtn.value = isShowClose
        
        /// 点击关闭页面
        clickCloseBtn.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.Login.close, nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        /// 点击管理员登录
        clickAdminLoginBtn.asObservable()
            .map { (_) -> RouterInfo in
                return(Router.Login.adminLogin, nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 点击下一步
        let inputCheckResult = clickNextBtn.asObservable()
            .map { [weak self] (_) -> String? in
                self?.checkInput()
            }
            .share(replay: 1, scope: .whileConnected)
        
        // -- 输入合法
        inputCheckResult
            .filter { $0 == nil }
            .flatMapLatest { [weak self] (_) -> Observable<ReqCheckUserExists.Model> in
                return self?.requestUserExists(phoneNumber: self?.phoneInput.value ?? "") ?? .empty()
            }
            .map({[weak self] (register) -> RouterInfo in
                if  register.data ?? false {
                     return (Router.Login.verifyCode, ["tel":self!.phoneInput.value ,"registered":true])

                } else {
                    return (Router.Login.verifyCode, ["tel":self!.phoneInput.value,"registered":false ])

                }
            })
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        
        // -- 输入不合法
        inputCheckResult
            .filter { $0 != nil }
            .map { AlertMessage(message: $0, alertType: .toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        
        /// 用户协议
        clickCheckBtn.asObservable()
            .map { [weak self] (_) -> Bool in
                return !(self?.isCheckPrivacy.value ?? false)
            }
            .bind(to: isCheckPrivacy)
            .disposed(by: disposeBag)
        
        /// 点击用户协议跳转
        clickPrivacyLink.asObservable()
            .map { return RouterInfo(Router.Login.goPrivacyPolicy,nil) }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        
    }
    
    /// 检测手机号是否存在
    private func requestUserExists(phoneNumber :String) ->Observable<ReqCheckUserExists.Model>{
        
        let reqParam = ReqCheckUserExists(telephone: phoneNumber)
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
            .map { (rsp) -> ReqCheckUserExists.Model? in
                return rsp.model
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
    
    /// 输入检查，返回错误提示（可选）
    private func checkInput() -> String? {
        
        if phoneInput.value.count != 11 {
            return Constants.Text.phoneNotMatchMessage
        } else if isCheckPrivacy.value != true {
            return Constants.Text.privacyNotCheckMessage
        } else {
            return nil
        }
        
    }
    
}
