//
//  UserListVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 用户管理-列表页
class UserListVM: BaseTableVM {
    
    ///数据
    var dataArray = [ReqUserList.Data]()
    /// 当前删除的行
    private var currentDeleteIndexPath: IndexPath?
    
    // from view
    /// 搜索字符
    let searchText = Variable<String>("")
    /// 点击编辑（IndexPath）
    let clickEdit = PublishSubject<IndexPath>()
    /// 点击删除（IndexPath）
    let clickDelete = PublishSubject<IndexPath>()
    /// 点击添加用户
    let clickaddUser = PublishSubject<Void>()
    
    // 私有事件
    /// 刷新数据
    private let updateUsetList = PublishSubject<Void>()
    /// 过滤数据（搜索条件）
    private let filterData = PublishSubject<String>()
    
    override init() {
        super.init()
        isEnableEditCell.value = true
        
        /// 进入页面请求数据
        viewWillAppear.asObservable()
            .bind(to: updateUsetList)
            .disposed(by: disposeBag)
        
        /// 搜索筛选
        searchText.asObservable()
            .skip(2)
            .throttle(0.3, scheduler: MainScheduler.instance)
            .bind(to: filterData)
            .disposed(by: disposeBag)
        

       /// 编辑
        didSelecCell.asObservable()
            .map { (vm) -> RouterInfo in
                if let cellVM = vm as? UserListCellVM{
                return (Router.UserCenter.editUser,["name": cellVM.name.value ?? "","tel": cellVM.phone.value ?? "","isCreateUser":false])
                } else {
                    return (nil,nil)
                }
              
           }
        
           .bind(to: openRouter)
           .disposed(by: disposeBag)
        
        
        /// 添加用户
        clickaddUser.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.editUser,["isCreateUser":true])
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 删除用户
        didCommitDeleteRow.asObservable()
            .bind(to: clickDelete)
            .disposed(by: disposeBag)
        
        clickDelete.asObservable()
            .map { [weak self] (idxP) -> AlertMessage in
                self?.currentDeleteIndexPath = idxP
                return AlertMessage(message: "您确定删除此用户吗?", alertType: AlertMessage.AlertType.alert, title: nil, cancelButtonTitle: "取消", okButtonTitle: "确定")
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        /// 确认删除
        let deleteSuccess = didConfirmAlert.asObservable()
            .flatMapLatest { [weak self] (clickIndex) -> Observable<Void> in
                
                if clickIndex.1 == 1 {
                    if let cellVM = self?.fetchCellViewModel(by: self?.currentDeleteIndexPath ?? IndexPath()) as? UserListCellVM {
                        
                        return self?.deleteUserReq(phone: cellVM.phone.value ?? "") ?? .empty()
                    }
                }
                
                return .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        deleteSuccess.asObservable()
            .bind(to: updateUsetList)
            .disposed(by: disposeBag)
        
        /// 刷新数据
        updateUsetList.asObservable()
            .flatMapLatest { [weak self] (_)-> Observable<[ReqUserList.Data]> in
                return self?.getUserList(groupId: DataCenter.shared.userInfo.value?.groupId ?? "") ?? .empty()
            }
            .map({ [weak self] (data) -> String in
                self?.dataArray = data
                return self?.searchText.value ?? ""
            })
            .bind(to: filterData)
            .disposed(by: disposeBag)
        
        /// 过滤数据
        filterData.asObserver()
            .flatMapLatest({ [weak self] (txt) ->Observable <[ReqUserList.Data]> in
                return self?.localFilter(searchText: txt) ?? .empty()
            })
            .map({ [weak self] (data) -> [BaseSectionVM]? in
                return self?.viewModel(from: data)
            })
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
    }
    
    /// 数据转为view model
    private func viewModel(from dataAry: [ReqUserList.Data]) -> [BaseSectionVM]? {
        
        var sectionAry = [BaseSectionVM]()
        
        for aData in dataAry {
            let sectionVM = BaseSectionVM()
            
            let cellVM = UserListCellVM(data: aData)
            sectionVM.cellViewModels.append(cellVM)
            sectionAry.append(sectionVM)
        }
        
        return sectionAry
    }
    /// 本地筛选
    private func localFilter(searchText:String) ->Observable<[ReqUserList.Data]>{
        var filterData:[ReqUserList.Data] = []
        for sectionModel in dataArray{
            if searchText.isEmpty || sectionModel.tel.contains(searchText) || sectionModel.name.contains(searchText){
                filterData.append(sectionModel)
            }
        }
        return Observable.just(filterData)
        
    }
    
    /// 网络请求用户列表
    private func getUserList(groupId:String ) ->Observable<[ReqUserList.Data]>{
        let reqParam = ReqUserList(groupID: groupId)
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqUserList.Data]? in
                return (rsp.model?.dataList ?? [])
            }
            .filter { $0 != nil }
            .map { $0! }
        req.send()
        return  success
        
    }
    
    /// 删除用户网络请求，返回删除成功
    private func deleteUserReq(phone:String ) -> Observable<Void>{
        let reqParam = ReqDeleteUser(tel: phone)
        let req = reqParam.toDataReuqest()
        
        req.isRequesting.asObservable()
            .map { (value) -> LoadingState in
                  return LoadingState(isLoading: value, loadingText: "删除中")
                 }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        
        let result = req.responseRx.asObservable()
        
        let success = result
            .filter { $0.isSuccess() }
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
