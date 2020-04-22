//
//  MyDriversEditVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 我的司机-编辑司机
class MyDriversEditVM: BaseVM {
    
    // to view
    /// 姓名
    let name = Variable<String?>(nil)
    /// 电话
    let tel = Variable<String?>(nil)
    /// 是否可以点击保存
    let isEnableSave = Variable<Bool>(false)
    /// 是不是新建司机
    let isCreateDriver = Variable<Bool>(false)
    
    // from view
    /// 点击保存
    let didClickSave = PublishSubject<Void>()
    
    init(isCreateDriver:Bool ,name:String ,phone:String , id :String) {
        super.init()
        
        self.isCreateDriver.value = isCreateDriver
        self.name.value = name
        self.tel.value = phone
        
        // 点击条件
        Observable<Bool>.combineLatest(self.name.asObservable(), self.tel.asObservable()) { (nameInput, telInput) -> Bool in
            return nameInput?.count > 0 && telInput?.replacingOccurrences(of: " ", with: "").count == 11 &&  self.numberOfChars(nameInput ?? "") < 21
        }
        .bind(to: isEnableSave)
        .disposed(by: disposeBag)
        
       
        self.name.asObservable()
            .filter({ [weak self] (txt) -> Bool in
                self?.numberOfChars(txt ?? "") > 20
            })
            .map {  _ in AlertMessage(message:"姓名不能超过10位", alertType: AlertMessage.AlertType.custom) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        

        
      ///点击确认添加司机
        let addSuccess = didClickSave.asObservable()
            .flatMapLatest { [weak self](_) -> Observable<ReqAddDriver.Model> in
                return self?.addDriverReq(name: (self?.name.value ?? ""), phone:( self?.tel.value ?? "")) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        addSuccess.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.popBack,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        /// 编辑
        let editSuccess = didClickSave.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<ReqEditDriver.Model> in
                return self?.editDriverReq(name: (self?.name.value ?? ""), phone:( self?.tel.value ?? ""), id: id) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        editSuccess.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.popBack,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
    }
    /// 计算字符数
    private func numberOfChars(_ str: String) -> Int {
        var number = 0
        guard str.characters.count > 0 else {return 0}
        for i in 0...str.characters.count - 1 {
            let c: unichar = (str as NSString).character(at: i)
            if (c >= 0x4E00) {
                number += 2
            }else {
                number += 1
            }
        }
        return number
    }
    
    /// 新增司机
    private func addDriverReq(name:String,phone :String) -> Observable<ReqAddDriver.Model>{
        
        let reqParam = ReqAddDriver(name: name, tel: phone ,userId :DataCenter.shared.userInfo.value?.userId ?? "")
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> ReqAddDriver.Model? in
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
    
    /// 编辑司机
    private func editDriverReq(name:String,phone :String,id :String) -> Observable<ReqEditDriver.Model>{
        
        let reqParam = ReqEditDriver(tel: phone, name: name ,id: id )
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> ReqEditDriver.Model? in
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
    
}

