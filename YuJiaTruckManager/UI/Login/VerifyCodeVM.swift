//
//  VerifyCodeVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/23.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 验证码登录页
class VerifyCodeVM: BaseVM {
    
    // to view
    ///验证码输入
    let codeInput = Variable<String>("")
    /// 标题
    let title  = Variable<String>("")
    /// 副标题
    let subTitle = Variable<String>("")
    /// 开始倒计时
    let startCountDown = PublishSubject<Int>()
    /// 是否可以点击
    let isEnableClickNext = Variable<Bool>(false)
    
    // from view
    ///点击发送验证码
    let clickSendCodeBtn = PublishSubject<Void>()
    ///立即登录
    let loginBtnClick = PublishSubject<Void>()
    
    init(tel:String, registered: Bool) {
        super.init()
        
        ///标题
        if registered == true {
            title.value = "欢迎回来"
        } else {
            title.value = "注册"
        }
        
        ///副标题
        subTitle.value = "请输入\(tel)收到的验证码"
        
        /// viewWillAppear
        
        /// 是否需要继续倒计时
        let continueCountDownSeconds = viewWillAppear.asObservable()
            .map { [weak self] () -> Int? in
                /// 获取当前时间戳与存入的比较
                let countButtonbeginTime = self?.getTimeDifferentWith() ?? 0
                /// 取出存入的时间戳手机号
                let timestampPhone =  UserDefaultsManager.shared.timestampPhone
                
                if (countButtonbeginTime < Constants.Config.countTime && timestampPhone == tel){
                    return  Constants.Config.countTime - countButtonbeginTime
                } else {
                    return nil
                }
            }
        // -- 不需要
        continueCountDownSeconds
            .filter { $0 == nil }
            .map { (_) -> Void in
            }
            .bind(to: clickSendCodeBtn)
            .disposed(by: disposeBag)
        // -- 需要
        continueCountDownSeconds
            .filter { $0 != nil }
            .skipNil()
            .bind(to: startCountDown)
            .disposed(by: disposeBag)
        
        
        /// 点击发送验证码
        let sendCodeSuccess = clickSendCodeBtn.asObservable()
            .flatMapLatest { [weak self](_) -> Observable<ReqSendCode.Model> in
                return (self?.sendCode(phone: tel )) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        sendCodeSuccess.asObservable()
            .map({ (data) -> Int in
                return Constants.Config.countTime
            })
            .bind(to: startCountDown)
            .disposed(by: disposeBag)
        ///存时间戳
        sendCodeSuccess.asObservable()
            .filter({ (data) -> Bool in
                data.isSuccess()
            })
            .subscribe(onNext: { [weak self] (data) in
                self?.saveCurrenttimeStamp(phone: tel)
            })
            .disposed(by: disposeBag)
        
        /// 注册
        let registerSuccess = loginBtnClick.asObservable()
            .filter {  registered == false }
            .flatMapLatest { [weak self](_) -> Observable<ReqRegister.Model> in
                return self?.registerReq(phone: tel, verifyCode: self?.codeInput.value ?? "") ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        let registerLoginSuccess  = registerSuccess.asObservable()
            .flatMapLatest { [weak self](_) -> Observable<ReqLogin.Data> in
                UserDefaultsManager.shared.account = tel
                return self?.loginReq (phone: tel ,code:self?.codeInput.value ?? "") ?? .empty()
                
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        
        
        /// 登录
        let logionSuccess = loginBtnClick.asObservable()
            .filter { registered == true}
            .flatMapLatest { [weak self](_) -> Observable<ReqLogin.Data> in
                MobClick.event("phone_login")

                UserDefaultsManager.shared.account = tel
                return self?.loginReq (phone: tel ,code:self?.codeInput.value ?? "") ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        /// 登录注册相关共同处理
        let commonFinfish = Observable.merge(registerLoginSuccess.asObservable(),logionSuccess.asObservable())
        
        /// 存个人信息（token,accountType等）
        commonFinfish.asObservable()
            .bind(to: MessageCenter.shared.didLogin)
            .disposed(by: disposeBag)
        
        commonFinfish.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.Login.close,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
      
        
        // 是否可以点击
        codeInput.asObservable()
            .map { $0.count > 0 }
            .bind(to: isEnableClickNext)
            .disposed(by: disposeBag)
    }
    /// 发送验证码网络请求
    private func sendCode(phone :String) -> Observable<ReqSendCode.Model>{
        
        let reqParam = ReqSendCode(tel: phone)
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
            .map { (rsp) -> ReqSendCode.Model in
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
    /// 注册请求
    private func registerReq(phone :String,verifyCode :String) -> Observable<ReqRegister.Model>{
        
        let reqParam = ReqRegister(tel: phone,verifyCode: verifyCode)
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> ReqRegister.Model? in
                return rsp.model!
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
    
    
    /// 登录请求
    private func loginReq(phone :String ,code :String) ->Observable<ReqLogin.Data>{
        let reqParam = ReqLogin(tel: phone,code: code,loginType: "2")
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
    
    
    /// 保存当前时间戳
    private func saveCurrenttimeStamp(phone :String){
        let now = NSDate()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        UserDefaultsManager.shared.timestampPhone = phone
        UserDefaultsManager.shared.timeStamp = timeStamp
        
    }
    
    ///获取当前时间与一个时间的差值
    func getTimeDifferentWith() -> Int {
        let sendCodeTimeStamp = UserDefaultsManager.shared.timeStamp ?? 0
        //传入时间的时间戳
        let now = NSDate()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeNow = Int(timeInterval) //计算当前时间的时间戳
        let time = (timeNow -  Int(sendCodeTimeStamp)) //计算时差
        return Int.init(time)
    }
}
