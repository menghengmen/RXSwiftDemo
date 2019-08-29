//
//  MyDriversListVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 我的司机-司机列表
class MyDriversListVM: BaseTableVM {
    
    /// 页面类型
    enum MyDriverListType {
        ///  打电话
        case callTel
        ///  发短信
        case sendMessage
        ///  默认
        case lookDriver
       
    }
    // to view
    
    // from view
    /// 原始数据源
    var dataArray = [ReqDriverList.Data]()
    /// 当前显示的数据源
    var currnetPresentArray = [(String,[ReqDriverList.Data])]()
    /// 搜索字符
    let searchText = Variable<String>("")
    
    /// 点击删除
    let didClickDelete = PublishSubject<IndexPath>()
    /// 点击打电话
    let didClickCallTel = PublishSubject<IndexPath>()
    /// 点击发短信
    let didClickMessage = PublishSubject<IndexPath>()
    /// 点击添加司机
    let didClickAddDriver = PublishSubject<Void>()
    
    // 私有事件
    /// 刷新数据
    private let updateDriverList = PublishSubject<Void>()
    /// 重新过滤
    private let updateFilter = PublishSubject<Void>()
    
    
     init(type :MyDriverListType) {
        super.init()
        
        isEnableEditCell.value = true
        viewWillAppear.asObservable()
           .bind(to: updateDriverList)
           .disposed(by: disposeBag)
        
        /// 打电话
        didClickCallTel.asObservable()
            .map({ [weak self] (index) -> String in
                return  self?.currnetPresentArray.yd.element(of: index.section)?.1.yd.element(of: index.row)?.tel ?? ""
            })
            .bind(to: MessageCenter.shared.needCallTelephone)
            .disposed(by: disposeBag)
        
        didSelectRow.asObservable()
            .filter{ _ in type == .callTel}
            .bind(to: didClickCallTel)
            .disposed(by: disposeBag)
        
        /// 发短信
        didClickMessage.asObservable()
            .map({ [weak self] (index) -> String in
                return  self?.currnetPresentArray.yd.element(of: index.section)?.1.yd.element(of: index.row)?.tel ?? ""
            })
            .bind(to: MessageCenter.shared.needSendMessage)
            .disposed(by: disposeBag)
        
        didSelectRow.asObservable()
            .filter{ _ in  type == .sendMessage}
            .bind(to: didClickMessage)
            .disposed(by: disposeBag)
        
        /// 编辑
        didSelecCell.asObservable()
            .filter{ _ in  type == .lookDriver }
            .map { (vm) -> RouterInfo in
                if let cellVM = vm as? MyDriversListCellVM{
                    return (Router.UserCenter.editDriver,["name": cellVM.name.value ?? "","tel": cellVM.tel.value ?? "","isCreateDriver":false ,"id" : cellVM.id.value ?? ""])
                } else {
                    return (nil,nil)
                }
                
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 添加
        didClickAddDriver.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.UserCenter.editDriver,["isCreateDriver":true])
         }
           .bind(to: openRouter)
           .disposed(by: disposeBag)
        
        /// 删除
        let deleteSuccess =   didClickDelete.asObservable()
            .flatMapLatest { [weak self] (clickIndex) -> Observable<Void> in
                return self?.deleteUserReq(addressBookId: self?.currnetPresentArray.yd.element(of: clickIndex.section)?.1.yd.element(of: clickIndex.row)?.id ?? "") ?? .empty()
                
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        deleteSuccess.asObservable()
            .bind(to: updateDriverList)
            .disposed(by: disposeBag)
        
        deleteSuccess.asObservable()
            .map { AlertMessage(message: "删除成功", alertType: .toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
       
        /// 刷新数据
        updateDriverList.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<[ReqDriverList.Data]> in
                return self?.getDriverList(userId:DataCenter.shared.userInfo.value?.userId ?? "" ) ?? .empty()
             }
            .map ({ [weak self](data) -> Void in
                self?.dataArray = data
            })
           .bind(to: updateFilter)
           .disposed(by: disposeBag)
        
        /// 搜索
        searchText.asObservable()
            .skip(1)
            .map { _ in }
            .bind(to: updateFilter)
            .disposed(by: disposeBag)
        
        updateFilter.asObservable()
            .map { [weak self] () -> [BaseSectionVM]? in
                let dataAfterSort = self?.sortData(self?.dataArray) ?? []
                self?.currnetPresentArray = dataAfterSort
                
                return self?.viewModel(from: dataAfterSort)
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        
        
    }

   /// 网络请求司机列表
    private func getDriverList(userId:String ) ->Observable<[ReqDriverList.Data]>{
        let reqParam = ReqDriverList(userId: userId)
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
        
        result.asObservable()   // 错误提示
            .filter { $0.isSuccess() == false }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
       
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqDriverList.Data]? in
                return (rsp.model?.dataList ?? [])
            }
            .filter { $0 != nil }
            .map { $0! }
        
        success.asObservable()
            .map { [weak self] (rsp) -> ErrViewInfo? in
                if self?.searchText.value == "" && rsp.count == 0 {
                    return ErrViewInfo.noDataFromDrivers
                } else {
                    return nil
                }
            }
            .bind(to: errView)
            .disposed(by: disposeBag)
        
        
        req.send()
        return  success
        
    }
   
    /// 删除司机
    private func deleteUserReq(addressBookId:String ) -> Observable<Void>{
        let reqParam = ReqDeleteDriver(addressBookId: addressBookId)
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
    
    /// 数据转为view model
    private func viewModel(from dataAry: [(String,[ReqDriverList.Data])]) -> [BaseSectionVM]? {
        
        var sectionAry = [BaseSectionVM]()
        
        for aData in dataAry {
            
            let sectionVM = MyDriversListSectionVM()
            sectionVM.indexTitle.value = aData.0
            
            for aCellData in aData.1 {
                let cellVM = MyDriversListCellVM(data: aCellData)
                sectionVM.cellViewModels.append(cellVM)
            }
            
            sectionAry.append(sectionVM)
        }
        
        return sectionAry
    }
    
    
    /// 整理数据
    private func sortData(_ data: [ReqDriverList.Data]?) -> [(String,[ReqDriverList.Data])] {
        
        var sectionDic = [String:[ReqDriverList.Data]]()
        
        for aData in data ?? [] {
            
            if searchText.value.count > 0 {
                if aData.name.contains(searchText.value) == false && aData.tel.contains(searchText.value) == false {
                    continue
                }
            }
            
            let firstLetter = getFirstLetterFromString(aString: aData.name)
            aData.firstLetter = firstLetter
            
            var ary = sectionDic[firstLetter] ?? []
            ary.append(aData)
            sectionDic[firstLetter] = ary
            
        }
        
        var resultAry = [(String,[ReqDriverList.Data])]()
        
        for key in sectionDic.keys {
            
            if let value = sectionDic[key] {
                resultAry.append((key, value))
            }
        }
        
        resultAry.sort { $0.0 < $1.0 }
        
        return resultAry
    }
    

    // MARK: - 获取联系人姓名首字母(传入汉字字符串, 返回大写拼音首字母)
    private  func getFirstLetterFromString(aString: String) -> (String) {
        if aString == "" {
            return "#"
        }
        
        // 注意,这里一定要转换成可变字符串
        let mutableString = NSMutableString.init(string: aString)
        // 将中文转换成带声调的拼音
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
        // 去掉声调(用此方法大大提高遍历的速度)
        let pinyinString = mutableString.folding(options: String.CompareOptions.diacriticInsensitive, locale: NSLocale.current)
        // 将拼音首字母装换成大写
        let strPinYin = polyphoneStringHandle(nameString: aString, pinyinString: pinyinString).uppercased()
        
        // 截取大写首字母
        let firstString = strPinYin.yd.substring(from: 0, to: 1) ?? ""
        // 判断姓名首位是否为大写字母
        let regexA = "^[A-Z]$"
        let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
        return predA.evaluate(with: firstString) ? firstString : "#"
    }
  
    /// 多音字处理
    func polyphoneStringHandle(nameString:String, pinyinString:String) -> String {
        if nameString.hasPrefix("长") {return "chang"}
        if nameString.hasPrefix("沈") {return "shen"}
        if nameString.hasPrefix("厦") {return "xia"}
        if nameString.hasPrefix("地") {return "di"}
        if nameString.hasPrefix("重") {return "chong"}
        
        return pinyinString;
    }
   
}
