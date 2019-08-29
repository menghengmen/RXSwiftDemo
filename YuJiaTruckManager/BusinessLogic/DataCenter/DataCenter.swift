//
//  DataCenter.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 数据中心
class DataCenter: NSObject {
    
    // MARK: - Public
    
    /// 单例
    static let shared = DataCenter()
    
    /// 当前动态配置
    let dynamicConfig = Variable<Constants.DynamicConfig?>(nil)
    
    /// 用户登录信息
    let userInfo = Variable<ReqLogin.Data?>(nil)
    /// 用户详情
    let userDetail = Variable<ReqUserInfo.Data?>(nil)
    /// 当前的筛选器
    let currnetFilter = Variable<AlarmListFilter>(AlarmListFilter())
    /// 保存闹钟信息
    let saveAlarmInfo = PublishSubject<[RemindClockInfo]>()
    
    
    // MARK: - Private
    
    /// 监听回收
    private var disposeBag = DisposeBag()
    /// 登录处理
    private let loginProcess = PublishSubject<ReqLogin.Data>()
    /// 请求用户信息，传入手机号
    private let getUserInfo = PublishSubject<ReqLogin.Data>()
    
    
    
    // MARK: - 业务逻辑
    
    override init() {
        super.init()
        
        // 逻辑初始化
        messageCenterLogicInit()
        updateFuncLogicInit()
        saveAlarmInfoInit()
    }
    
    /// 消息中心逻辑
    private func messageCenterLogicInit(){
        
        // 跟页面加载完后，加载用户信息，没有用户信息就弹出登录页
        MessageCenter.shared.didLoadRootPage.asObservable()
            .map({ [weak self] (_) -> Bool in
                return self?.loadUserInfoFromLocal() ?? true
            })
            .bind(to: MessageCenter.shared.needLogin)
            .disposed(by: disposeBag)
        
        // 请求配置
        MessageCenter.shared.didLoadRootPage.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<Constants.DynamicConfig?> in
                return self?.requestDynamicConfig() ?? .empty()
            }
            .bind(to: dynamicConfig)
            .disposed(by: disposeBag)
        
        /// 登录成功
        MessageCenter.shared.didLogin.asObservable()
            .bind(to: userInfo)
            .disposed(by: disposeBag)
        
        MessageCenter.shared.didLogin.asObservable()
            .bind(to: loginProcess)
            .disposed(by: disposeBag)
        
        /// 登录成功以后请求个人信息
        loginProcess.asObservable()
            .bind(to: getUserInfo)
            .disposed(by: disposeBag)
        
        /// 加载用户完毕
        userDetail.asObservable()
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: MessageCenter.shared.didGetUserInfo)
            .disposed(by: disposeBag)
        
        getUserInfo.asObservable()
            .flatMapLatest { [weak self](value) -> Observable<ReqUserInfo.Data> in
                return self?.userInfoReq(userName: UserDefaultsManager.shared.account ?? "", accountType:DataCenter.shared.userInfo.value?.accountType ?? "") ?? .empty()
            }
            .bind(to: userDetail)
            .disposed(by: disposeBag)
        
        /// 加载用户完毕后请求代办事件
        MessageCenter.shared.didGetUserInfo.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<[RemindClockInfo]> in
                return self?.requestAlarmInfo() ?? .empty()
            }
            .bind(to: saveAlarmInfo)
            .disposed(by: disposeBag)
        
        /// 根页面加载完后,请求新版本
        let checkNewVersionSuccess =  MessageCenter.shared.didLoadRootPage.asObservable()
            .flatMapLatest { [weak self](_) -> Observable<ReqGetNewVersion.Data> in
                return self?.requestNewVersion() ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        checkNewVersionSuccess.asObservable()
            .bind(to: MessageCenter.shared.needUpdateVersion)
            .disposed(by: disposeBag)
        
        
        /// 登出处理
        let logOutFinish = MessageCenter.shared.didLogout.asObservable()
            .map { (_) -> Void in
                UserDefaultsManager.shared.clearUp()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        logOutFinish.asObservable()
            .map{ return nil}
            .bind(to: userInfo)
            .disposed(by: disposeBag)
        
        logOutFinish.asObservable()
            .map { return nil}
            .bind(to: userDetail)
            .disposed(by: disposeBag)
        
        logOutFinish.asObservable()
            .map { return AlarmListFilter() }
            .bind(to: currnetFilter)
            .disposed(by: disposeBag)
        
        
        logOutFinish.asObservable()
            .map { return true }
            .bind(to: MessageCenter.shared.needLogin)
            .disposed(by: disposeBag)
        
    }
    
    private func updateFuncLogicInit(){
        ///存储用户信息
        userInfo.asObservable()
            .skipUntil(MessageCenter.shared.didLoadRootPage)
            .subscribe(onNext: { (data) in
                UserDefaultsManager.shared.userInfo = data?.toJSON()
            })
            .disposed(by: disposeBag)
        userDetail.asObservable()
            .skipUntil(MessageCenter.shared.didLoadRootPage)
            .subscribe(onNext: { (data) in
                UserDefaultsManager.shared.userDetail = data?.toJSON()
            })
            .disposed(by: disposeBag)
        
        /// 动态配置
        dynamicConfig.asObservable()
            .subscribe(onNext: { (data) in
                UserDefaultsManager.shared.dynamicConfig = data
            })
            .disposed(by: disposeBag)
        
    }
    
    private func saveAlarmInfoInit(){
        
        /// 存储闹铃信息
        saveAlarmInfo.asObservable()
            .subscribe(onNext: { (remindInfo) in
                UserDefaultsManager.shared.remindClocks = remindInfo
            })
            .disposed(by: disposeBag)

        
    }
    
    
    // MARK: - Private Method
    
    // 加载用户信息，返回是否需要登录
    private func loadUserInfoFromLocal() -> Bool {
        
        if let dic = UserDefaultsManager.shared.userInfo {
            if let userInfoFromUD = ReqLogin.Data.deserialize(from: dic) {
                userInfo.value = userInfoFromUD
            }
        }
        
        if let userDetailDic = UserDefaultsManager.shared.userDetail{
            if let userDertailFromUD = ReqUserInfo.Data.deserialize(from: userDetailDic) {
                userDetail.value = userDertailFromUD
            }
            
        }
        
        return userInfo.value == nil
    }
    /// 请求个人信息
    private func userInfoReq(userName :String ,accountType :String) ->Observable<ReqUserInfo.Data>{
        let reqParam = ReqUserInfo(userName: userName,accountType: accountType)
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> ReqUserInfo.Data? in
                return rsp.model?.data
            }
            .filter { $0 != nil }
            .map { $0! }
        req.send()
        return success
        
    }
    
    // 请求新版本，返回有新版本事件
    private func requestNewVersion() -> Observable<ReqGetNewVersion.Data>{
        let infoDictionary = Bundle.main.infoDictionary
        let appVersion = infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let reqParam = ReqGetNewVersion(currentVersion: appVersion)
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
            .map { (rsp) -> ReqGetNewVersion.Data?  in
                return rsp.model?.data
            }
            .filter {  $0 != nil }  // 空代表没有新版本
            .map { $0! }
        
        req.send()
        return  result
    }
    
    
    /// 请求代办列表
    private func requestAlarmInfo() -> Observable<[RemindClockInfo]> {
        
        let reqParam = ReqQueryMenos(userId: userInfo.value?.userId ?? "", keyword: "")
        let req = reqParam.toDataReuqest()
        
        let finish = req.responseRx.asObservable()
        
        let success = finish
            .filter { $0.isSuccess() }
            .map { (rsp) -> [RemindClockInfo] in
                
                var remindInfos = [RemindClockInfo]()
                
                for aValue in rsp.model?.dataList ?? [] {
                    
                    guard let time = aValue.remindTime else {
                        continue
                    }
                    
                    var reminModel = RemindClockInfo()
                    reminModel.id = aValue.id
                    reminModel.content = aValue.content
                    reminModel.fireDate = time.yd.dateByMs()
                    remindInfos.append(reminModel)
                    
                }
                
                return remindInfos
                
            }

        req.send()
        
        return success
        
    }
    
    /// 请求动态配置
    private func requestDynamicConfig() -> Observable<Constants.DynamicConfig?> {
        
        let reqParam = ReqGetDynamicConfig()
        reqParam.application = "YuJiaTM"
        let infoDictionary = Bundle.main.infoDictionary
        let appVersion: String = (infoDictionary? ["CFBundleShortVersionString"]as? String ) ?? ""
        reqParam.version = appVersion
        
        let req = reqParam.toDataReuqest()
        
        let success = req.responseRx.asObservable()
            .filter { $0.isSuccess() }
            .map { (rsp) -> Constants.DynamicConfig? in
                guard rsp.model?.dataList.count > 0 else {
                    return nil
                }
                return Constants.DynamicConfig(from: rsp.model?.dataList ?? [])
            }
        
        req.send()
        
        return success
    }
    
}
