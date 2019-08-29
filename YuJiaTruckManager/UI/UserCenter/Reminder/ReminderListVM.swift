//
//  ReminderListVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 管车助手列表类型
enum ReminderListDataType: Int {
    /// 代办
    case todo = 0
    /// 过期
    case expired
}

/// 管车助手-列表
class ReminderListVM: BaseTableVM {
    
    /// 加载数据类型
    enum LoadingType {
        /// 主动刷新
        case callLoading
        /// 用户下拉刷新
        case userPullRefreshExpired
        /// 用户上拉更多
        case userPushLoadmoreExpired
    }
    
    // 当前页码
    var currentPage = 1
    // 分页大小
    let pageSize = "10"
    
    
    // to view
    /// 当前类型（双向绑定）
    let currentType = Variable<ReminderListDataType>(.todo)
    /// 搜索文字（双向绑定）
    let searchText = Variable<String?>(nil)
    
    ///  待办事项数据源
    let todoDataArray = Variable<[ReqQueryMenos.Data]>([])
    /// 过期的数据
    let expiredDataArray = Variable<[ReqMenos.Data]>([])
    
    
    // from view
    /// 点击已过期
    let didClickExpiredButton = PublishSubject<Void>()
    /// 点击添加
    let didClickAddButton = PublishSubject<Void>()
    
    /// 标记星星
    let didMarkStar = PublishSubject<Void>()
    /// 标记已过期
    let didMarkExpired = PublishSubject<IndexPath>()
    /// 点击删除
    let didClickDelete = PublishSubject<IndexPath>()
    
    /// 刷新数据
    private let updateData = PublishSubject<LoadingType>()
    
    // MARK: - 业务逻辑
    
    override init() {
        super.init()
        
        // 页面设置：
        
        // 可以编辑
        isEnableEditCell.value = true
        
        // 过期事项开启上拉下拉
        currentType.asObservable()
            .map { $0 == .expired }
            .bind(to: isEnablePullRefresh)
            .disposed(by: disposeBag)
        currentType.asObservable()
            .map { $0 == .expired }
            .bind(to: isEnablePushLoadmore)
            .disposed(by: disposeBag)
        
        // 更新数据入口：
        
        /// 下拉刷新
        didPullRefresh.asObservable()
            .map { LoadingType.userPullRefreshExpired }
            .bind(to: updateData)
            .disposed(by: disposeBag)
        
        /// 上拉加载
        didPushLoadMore.asObservable()
            .map { LoadingType.userPushLoadmoreExpired }
            .bind(to: updateData)
            .disposed(by: disposeBag)
        
        /// 模糊搜索
        searchText.asObservable()
            .skip(2)
            .throttle(0.3, scheduler: MainScheduler.instance)
            .map { _ in LoadingType.callLoading }
            .bind(to: updateData)
            .disposed(by: disposeBag)
        
        /// 进入页面重新请求
        viewDidAppear.asObservable()
            .map { _ in LoadingType.callLoading }
            .bind(to: updateData)
            .disposed(by: disposeBag)
        
        /// 切换类型重新请求
        currentType.asObservable()
            .map { _ in LoadingType.callLoading }
            .bind(to: updateData)
            .disposed(by: disposeBag)
        
        /// 切换类型清空搜索条件
        currentType.asObservable()
            .map { (_) -> String? in
                return ""
            }
            .bind(to: searchText)
            .disposed(by: disposeBag)
        
        
        /// 代办列表转闹钟
        todoDataArray.asObservable()
            .skip(1)
            .map { (value) -> [RemindClockInfo] in
                
                var remindInfos = [RemindClockInfo]()
                
                for aValue in value {
                    
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
            .bind(to: DataCenter.shared.saveAlarmInfo)
            .disposed(by: disposeBag)
        
        // 请求完毕后的处理：
        
        let requestFinish = updateData.asObservable()
            .debounce(0.3, scheduler: MainScheduler.instance) // 添加防抖
            .flatMapLatest { [weak self] (type) -> Observable<(LoadingType, Bool)> in
                if self?.currentType.value == .todo {
                    return self?.requestTodoMenos(type) ?? .empty()
                } else {
                    return self?.requestOverdueList(type) ?? .empty()
                }
            }
            .share(replay: 1, scope: .whileConnected)
        
        requestFinish
            .filter { $0.0 == .callLoading }
            .map { _ in LoadingState.noLoading }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        requestFinish
            .filter { $0.0 == .userPullRefreshExpired }
            .map { _ in }
            .bind(to: callEndPullRefresh)
            .disposed(by: disposeBag)
        
        requestFinish
            .filter { $0.0 == .userPushLoadmoreExpired }
            .map { $0.1 }
            .bind(to: callEndPushLoadMore)
            .disposed(by: disposeBag)
        
        currentType.asObservable()
            .map { _ in }
            .bind(to: callScrollToTop)
            .disposed(by: disposeBag)
        
        // 数据转模型：
        Observable<[SectionViewModelProtocol]?>.combineLatest(currentType.asObservable(), todoDataArray.asObservable(), expiredDataArray.asObservable()) { [weak self] (type, todoData, expiredData) -> [SectionViewModelProtocol]? in
            
            if type == .todo {
                return self?.todoViewModel(from: todoData)
            } else {
                return self?.expiredViewModel(from: expiredData)
            }
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        // 用户操作：
        
        /// 删除
        let deleteSuccess =  didClickDelete.asObservable()
            .map({ [weak self] (idxp) -> ReminderListCellVM? in
                return self?.fetchCellViewModel(by: idxp) as? ReminderListCellVM
            })
            .flatMapLatest {[weak self] (cellVM) -> Observable<Void> in
                return self?.deleteMenosReq(memoId: cellVM?.menosId ?? "" ) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        deleteSuccess.asObservable()
            .map { AlertMessage(message: "删除成功", alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        deleteSuccess.asObservable()
            .map { _ in LoadingType.callLoading }
            .bind(to: updateData)
            .disposed(by: disposeBag)
        
        /// 标记过期
        let expireSuccess =  didMarkExpired.asObservable()
            .filter{ [weak self] _ in self?.currentType.value == .todo }
            .map({ [weak self] (idxp) -> ReminderListCellVM? in
                return self?.fetchCellViewModel(by: idxp) as? ReminderListCellVM
            })
            .flatMapLatest {[weak self] (cellVM) -> Observable<Void> in
                return self?.expireTodoMenosReq(todoId: cellVM?.menosId ?? "", status: 1, expireDate: cellVM?.expireTime) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        expireSuccess.asObservable()
            .map { AlertMessage(message: "标记过期成功", alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        expireSuccess.asObservable()
            .map { _ in LoadingType.callLoading }
            .bind(to: updateData)
            .disposed(by: disposeBag)
        
        // 跳转：
        
        /// 跳转新增备忘录
        didClickAddButton.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.menos,["type":ReminderDetailVM.RemindDetailType.addMenos])
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 编辑备忘录
        didSelecCell.asObservable()
            .filter{ [weak self] _ in self?.currentType.value == .todo}
            .map { (vm) -> RouterInfo in
                if let cellVM = vm as? ReminderListCellVM {
                    
                    return (Router.UserCenter.menos,["type":ReminderDetailVM.RemindDetailType.editMenos, "menosId":cellVM.menosId ?? "" , "isStar" :cellVM.isStar.value , "createTime":cellVM.createTime, "remindTime":cellVM.remindDetailTime.value ?? "", "expireTime": cellVM.expireTime, "content":cellVM.content.value ?? "", "picture":cellVM.imageUrl.value ?? ""])
                } else {
                    return (nil,nil)
                }
                
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 查看备忘录
        didSelecCell.asObservable()
            .filter{ [weak self] _ in self?.currentType.value == .expired}
            .map { (vm) -> RouterInfo in
                if let cellVM = vm as? ReminderListCellVM {
                    
                    return (Router.UserCenter.menos,["type":ReminderDetailVM.RemindDetailType.lookMenos,"menosId":cellVM.menosId ?? "" ,
                       "isStar" :cellVM.isStar.value,
                       "createTime":cellVM.createTime, "remindTime":cellVM.remindDetailTime.value ?? "", "content":cellVM.content.value ?? "", "picture":cellVM.imageUrl.value ?? ""])
                } else {
                    return (nil,nil)
                }
                
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - 请求
    
    /// 删除待办事项
    private func deleteMenosReq(memoId: String ) -> Observable<Void>{
        let reqParam = ReqDeleteMenos(memoId: memoId)
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
    
    /// 更改待办事项（手动标为过期）
    private func expireTodoMenosReq(todoId: String, status: Int, expireDate: Date?) -> Observable<Void>{
        
        let expireTimeStamp = (expireDate ?? Date()).yd.timeIntevaleSince1970ms
        
        let reqParam = ReqUpdateMenos()
        reqParam.userId = DataCenter.shared.userInfo.value?.userId ?? ""
        reqParam.id = todoId
        reqParam.status = status
        reqParam.expireTime = expireTimeStamp
        
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
    
    /// 过期事项（分页），返回结束事件，是否有数据
    private func requestOverdueList(_ type: LoadingType) -> Observable<(LoadingType, Bool)> {
        
        let pagNumber = type == .userPushLoadmoreExpired ? currentPage + 1 : 1
        
        let reqParam =  ReqMenos(userId: DataCenter.shared.userInfo.value?.userId ?? "", pageNo: "\(pagNumber)", pageSize: pageSize ,keyword : searchText.value ?? "")
        let req = reqParam.toDataReuqest()
        let finish = req.responseRx.asObservable()
        
        finish.asObservable()   // 错误提示
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        let success = finish
            .filter { $0.isSuccess() }
            .map { $0.model?.dataList ?? [] }
        
        success
            .map({ [weak self] (value) -> [ReqMenos.Data] in
                
                var currentData = self?.expiredDataArray.value ?? []
                
                if type != .userPushLoadmoreExpired { // 刷新
                    currentData.removeAll()
                }
                self?.currentPage = pagNumber
                currentData.append(contentsOf: value)
                
                return currentData
            })
            .bind(to: expiredDataArray)
            .disposed(by: disposeBag)
        
        
        success
            .filter{ [weak self] _ in  self?.searchText.value == ""}
            .map { [weak self] (rsp) -> ErrViewInfo? in
                if rsp.count == 0 && self?.expiredDataArray.value.count == 0{
                   return .noDataFromRemind
                } else {
                    return nil
                }
                
            }
            .bind(to: errView)
            .disposed(by: disposeBag)
        
        success
            .filter{ [weak self] _ in  self?.searchText.value != ""}
            .map { [weak self] (rsp) -> ErrViewInfo? in
                if rsp.count == 0 && self?.expiredDataArray.value.count == 0{
                    return .noDataFromSearch
                } else {
                    return nil
                }
                
            }
            .bind(to: errView)
            .disposed(by: disposeBag)
        
        
        
        success
            .filter { $0.count == 0 && type == .userPushLoadmoreExpired}
            .map { _ in AlertMessage(message: "没有更多数据", alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        req.send()
        
        return finish.map({ (rsp) -> (LoadingType, Bool) in
            return (type, rsp.model?.dataList.count > 0)
        })
    }
    
    /// 待办事项（包含模糊搜索），返回结束事件，是否有数据
    private func requestTodoMenos(_ type: LoadingType) ->Observable<(LoadingType, Bool)>{
        
        let reqParam = ReqQueryMenos(userId: DataCenter.shared.userInfo.value?.userId ?? "", keyword : searchText.value ?? "")
        let req = reqParam.toDataReuqest()
        
        let finish = req.responseRx.asObservable()
        
        finish.asObservable()   // 错误提示
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        let success = finish
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqQueryMenos.Data]? in
                return (rsp.model?.dataList ?? [])
            }
            .filter { $0 != nil }
            .map { $0! }
        
        success
            .bind(to: todoDataArray)
            .disposed(by: disposeBag)
        
        success
            .filter{ [weak self] _ in self?.searchText.value == "" }
            .map { (rsp) -> ErrViewInfo? in
                if rsp.count == 0{
                    return .noDataFromRemind
                } else {
                    return nil
                }
                
            }
            .bind(to: errView)
            .disposed(by: disposeBag)

        success
            .filter{ [weak self] _ in self?.searchText.value != "" }
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
        return finish.map({ (rsp) -> (LoadingType, Bool) in
            return (type, rsp.model?.dataList.count > 0)
        })
    }
    
    // MARK: - 数据转模型
    
    /// 待办事项数据转化为view model
    private func todoViewModel(from dataAry: [ReqQueryMenos.Data]) -> [BaseSectionVM]? {
        
        var section = [BaseSectionVM]()
        for aData in dataAry {
            let sectionVM = BaseSectionVM()
            let cellVM = ReminderListCellVM(data :aData)
            cellVM.showMessage.asObservable()
                .bind(to: showMessage)
                .disposed(by: disposeBag)
            sectionVM.cellViewModels.append(cellVM)
            section.append(sectionVM)
            
        }
        
        return section
        
    }
    
    /// 过期数据转化为view model
    private func expiredViewModel(from dataAry: [ReqMenos.Data]) -> [BaseSectionVM]? {
        guard dataAry.count > 0 else {
            return nil
        }
        let section = BaseSectionVM()
        for aData in dataAry {
            let cellVM = ReminderListCellVM(data :aData)
            cellVM.showMessage.asObservable()
                .bind(to: showMessage)
                .disposed(by: disposeBag)
            section.cellViewModels.append(cellVM)
        }
        return [section]
    }
    
}

