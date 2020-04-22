//
//  ReminderDetailVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 管车助手-详情
class ReminderDetailVM: BaseTableVM {
    /// 页面类型
    enum RemindDetailType {
        /// 新建备忘录
        case addMenos
        /// 查看备忘录
        case lookMenos
        /// 编辑备忘录
        case editMenos
    }
    /// 图片数据
    let imageData = Variable<[ImageInfo]>([])
    /// 类型
    let type = Variable<RemindDetailType>(.addMenos)
   
    /// 时间选择
    let cellTimeVM = ReminderDetailTimeCellVM()
    /// 备忘录内容 vm
    let cellContentVM = ReminderDetailContentCellVM()
    /// 备忘录图片 vm
    let cellImageVM = ReminderDetailImageCellVM()
    /// 功能选择
    let cellDetailBtnVM = ReminderDetailButtonCellVM()
  
    
    // form view
    /// 点击添加
    let didClickAddMenos = PublishSubject<Void>()
    /// 点击删除
    let didClickDeleteMenos = PublishSubject<Void>()
    /// 点击分享
    let didClickShareMenos = PublishSubject<UIImage?>()
    
    /// 点击图片
    let didClickImage = PublishSubject<UIImage?>()
    /// 是否可以点击添加按钮
    let isEnableAddMenos = Variable<Bool>(true)
   
    init(type :RemindDetailType,
         menosId: String, isStar: Bool, createTime:Date?, remindTime:Date?, expireTime:Date?, content:String, picture:String) {
        super.init()
        
        self.type.value = type 
        
        let section = BaseSectionVM()
        cellContentVM.isEnableEditContent.value = true
        
        if type == .addMenos{ // 新增
            section.cellViewModels.append(BigTitleCellVM(title: "新增备忘录"))
            cellDetailBtnVM.isHiddenTel.value = true
            viewDidAppear.asObservable()
                .bind(to: cellContentVM.openKeyboard)
                .disposed(by: disposeBag)

        } else { // 查看
            section.cellViewModels.append(BigTitleCellVM(title: "查看备忘录"))
            section.cellViewModels.append(cellTimeVM)
        }

        cellTimeVM.createDate.value = createTime
     
       
        /// 备忘录内容
        cellContentVM.content.value = content
        section.cellViewModels.append(cellContentVM)
    
        /// 备忘录图片
        cellImageVM.imageUrl.value = picture
        cellImageVM.didClickImage.asObservable()
          .bind(to:didClickImage)
          .disposed(by: disposeBag)
        
        section.cellViewModels.append(cellImageVM)
    
        /// 功能选择
        if type != .lookMenos {
            section.cellViewModels.append(cellDetailBtnVM)
            
        } else {
            cellContentVM.isEnableEditContent.value = false
        }
        dataSource.value = [section]
    
        cellDetailBtnVM.menosId = menosId
        cellDetailBtnVM.isStar.value = isStar
        cellDetailBtnVM.expireTime.value = expireTime
        cellDetailBtnVM.remindTime.value = remindTime
        cellDetailBtnVM.remindTime.asObservable()
            .bind(to: cellTimeVM.remindDate)
            .disposed(by: disposeBag)
        cellDetailBtnVM.showMessage.asObservable()
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
       /// 点击电话
        cellDetailBtnVM.didClickTel.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.myDriver,["type" :MyDriversListVM.MyDriverListType.callTel])
              }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
         /// 发短信
        cellDetailBtnVM.didClickSms.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.myDriver,["type" :MyDriversListVM.MyDriverListType.sendMessage])
           }
            .bind(to: openRouter)
            .disposed(by: disposeBag)

        /// 图片数据
        cellImageVM.images.asObservable()
            .bind(to: imageData)
            .disposed(by: disposeBag)
        
        /// 先传图片
        didClickAddMenos.asObservable()
            .filter{ [weak self] in self?.cellImageVM.images.value.count > 0 }
            .subscribe(onNext: { [weak self] (_) in
                self?.cellImageVM.uploadMenosImage()
            })
            .disposed(by: disposeBag)
       /// 修改备忘录(修改图片)
       let updateMenosWithPictureSuccess = imageData.asObservable()
            .filter{ [weak self] _ in type == .editMenos &&  self?.imageData.value.yd.element(of: 0)?.imageUrl != nil }
            .flatMapLatest { [weak self] (imageData) -> Observable<Void> in
                return self?.updateTodoMenosReq(content: self?.cellContentVM.content.value ?? "", picture: imageData.yd.element(of: 0)?.imageUrl ?? "", todoId: menosId , remind: self?.cellDetailBtnVM.remindTime.value, expire: self?.cellDetailBtnVM.expireTime.value) ?? .empty()
              }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        /// 修改备忘录(不修改图片)
        let updateMenosSuccess =  didClickAddMenos.asObservable()
            .filter { [weak self] in type == .editMenos &&  self?.imageData.value.yd.element(of: 0)?.image == nil }
            .flatMapLatest { [weak self](_) -> Observable<Void> in
                return self?.updateTodoMenosReq(content: self?.cellContentVM.content.value ?? "", picture: picture, todoId: menosId , remind: self?.cellDetailBtnVM.remindTime.value, expire: self?.cellDetailBtnVM.expireTime.value) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
      
        
        
        /// 新增备忘录(不带图片)
        let addMenosSuccess = didClickAddMenos.asObservable()
            .filter{ [weak self] _ in type == .addMenos &&  self?.imageData.value.yd.element(of: 0)?.image == nil }
            .flatMapLatest { [weak self] (_) -> Observable<Void> in
                return self?.addMenosReq(content: self?.cellContentVM.content.value ?? "", picture: self?.imageData.value.yd.element(of: 0)?.imageUrl ?? "", remindTime: self?.cellTimeVM.remindDate.value, expireTime: self?.cellDetailBtnVM.expireTime.value, tag: self?.cellDetailBtnVM.isStar.value) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        /// 新增备忘录(带图片)
        let addMenosWithPictureSuccess = imageData.asObservable()
            .filter{ [weak self] _ in type == .addMenos &&  self?.imageData.value.yd.element(of: 0)?.imageUrl != nil }
            .flatMapLatest { [weak self] (imageData) -> Observable<Void> in
                return self?.addMenosReq(content: self?.cellContentVM.content.value ?? "", picture: self?.imageData.value.yd.element(of: 0)?.imageUrl ?? "", remindTime: self?.cellTimeVM.remindDate.value, expireTime: self?.cellDetailBtnVM.expireTime.value, tag: self?.cellDetailBtnVM.isStar.value) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
       
      
        /// 保存数据等待框
        didClickAddMenos.asObservable()
            .map{  _ in LoadingState(isLoading: true,loadingText: "保存中") }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        /// 按钮的状态
        didClickAddMenos.asObservable()
            .map { (_) -> Bool in
                return false
           }
           .bind(to:isEnableAddMenos)
           .disposed(by: disposeBag)
        
        

       didClickDeleteMenos.asObservable()
            .map { return AlertMessage.twoButtonAlert(with: "你确定删除此备忘录吗？") }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
       /// 删除备忘录
        let deleteMenosSuccess = didConfirmAlert.asObservable()
            .filter({ (type) -> Bool in
                type.1 == 1
            })
            .flatMapLatest { [weak self] (_) -> Observable<Void> in
                return self?.deleteMenosReq(memoId: menosId)  ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        deleteMenosSuccess.asObservable()
            .map { AlertMessage(message: "删除成功", alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
       
       /// 网络请求成功后的共同处理
       let commonSuccess = Observable.merge(deleteMenosSuccess.asObservable(),addMenosWithPictureSuccess.asObservable(),addMenosSuccess.asObservable(),updateMenosSuccess.asObservable(),updateMenosWithPictureSuccess.asObservable())
        
        
        commonSuccess.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.popBack,nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        /// 按钮的状态
        let common = Observable.merge(addMenosWithPictureSuccess.asObservable(),addMenosSuccess.asObservable(),updateMenosSuccess.asObservable(),updateMenosWithPictureSuccess.asObservable())
        
        common.asObservable()
            .map { (_) -> Bool in
                return true
            }
            .bind(to:isEnableAddMenos)
            .disposed(by: disposeBag)
        
        
        
       
    }
   
    /// 添加备忘录
    private func addMenosReq(content:String?, picture: String?,remindTime :Date? ,expireTime :Date?, tag: Bool?) -> Observable<Void>{
//        let reqParam = ReqAddMenos(userId: DataCenter.shared.userInfo.value?.userId ?? "",content: content ,picture: picture, tag: tag , expireTime: expireTime,remindTime: remindTime)
        
        let reqParam = ReqAddMenos()
        reqParam.userId = DataCenter.shared.userInfo.value?.userId ?? ""
        reqParam.content = content
        reqParam.picture1 = picture
        reqParam.tag = tag == true ? 1 : nil
        reqParam.expireTime = expireTime?.yd.timeIntevaleSince1970ms
        reqParam.remindTime = remindTime?.yd.timeIntevaleSince1970ms
        
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
        result
            .filter { $0.isSuccess() == false }
            .map { _ in LoadingState.noLoading }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
       
        result
            .filter { $0.isSuccess() == false }
            .map { (_) -> Bool in
                return true
            }
            .bind(to:isEnableAddMenos)
            .disposed(by: disposeBag)
        
        
        
        
        req.send()
        
        return success
    }
    
    /// 更新待办事项
    private func updateTodoMenosReq(content: String ,picture: String,todoId: String ,remind: Date?, expire: Date?) -> Observable<Void>{
//        let reqParam = ReqUpdateMenos(userId: DataCenter.shared.userInfo.value?.userId ?? "",picture :picture, content : content,id :todoId ,remind :remind ,expireTime :0 ,status :0,tag: 0)
        
        let reqParam = ReqUpdateMenos()
        reqParam.userId = DataCenter.shared.userInfo.value?.userId ?? ""
        reqParam.id = todoId
        reqParam.picture1 = picture
        reqParam.content = content
        reqParam.remindTime = remind?.yd.timeIntevaleSince1970ms
        reqParam.expireTime = expire?.yd.timeIntevaleSince1970ms
        
        
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
        
        result
            .filter { $0.isSuccess() == false }
            .map { (_) -> Bool in
                return true
            }
            .bind(to:isEnableAddMenos)
            .disposed(by: disposeBag)
        
        req.send()
        return success
    }
    /// 删除备忘录
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
        
        result
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        req.send()
        return success
    }
   
}

