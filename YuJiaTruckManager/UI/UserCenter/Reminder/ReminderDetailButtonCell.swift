//
//  ReminderDetailButtonCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/26.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift
import IQKeyboardManagerSwift

/// 管车助手-详情-功能按钮cell
class ReminderDetailButtonCellVM: BaseCellVM {
    
    // Public
    
    /// 备忘录id
    var menosId: String?
    /// 过期时间
    let expireTime = Variable<Date?>(nil)
    /// 提醒时间
    let remindTime = Variable<Date?>(nil)
    
    // 弹框透传给vc
    let showMessage = PublishSubject<AlertMessage>()
    
    
    // to view
    /// 图片
    let isStar = Variable<Bool>(false)
    
    // from view
    /// 点击星标（点击后的状态）
    let didClickStar = PublishSubject<Bool>()
    /// 点击图片
    let didClickImage = PublishSubject<Void>()
    /// 点击提醒
    let didClickRemind = PublishSubject<Void>()
    /// 选择完毕，（过期时间，提醒时间）
    let didPickRemindDate = PublishSubject<(Date, Date)>()
    /// 点击短信
    let didClickSms = PublishSubject<Void>()
    /// 点击电话
    let didClickTel = PublishSubject<Void>()
   
    /// 是否隐藏打电话按钮
    let isHiddenTel = Variable<Bool>(false)
    
 
    
    override init() {
        super.init()
        /// 点击图片
        didClickImage.asObservable()
            .bind(to: MessageCenter.shared.needShowImagePick)
            .disposed(by: disposeBag)
        
        didClickStar.asObservable()
            .bind(to: isStar)
            .disposed(by: disposeBag)
        
        didPickRemindDate.asObservable()
            .map { $0.0 }
            .bind(to: expireTime)
            .disposed(by: disposeBag)
        
        didPickRemindDate.asObservable()
            .map { $0.1 }
            .bind(to: remindTime)
            .disposed(by: disposeBag)
        
        /// 标记过期
        let finishMark = didClickStar.asObservable()
            .flatMapLatest {[weak self] (value) -> Observable<Void> in
                return self?.starTodoMenosReq(tag: value ? 1 : 0) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        finishMark
            .map { AlertMessage(message: "操作成功", alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
  
    }
    
    /// 更改待办事项（标星）
    private func starTodoMenosReq(tag: Int) -> Observable<Void> {
        
        guard let menosId = self.menosId  else {
            return .empty()
        }
        
        let reqParam = ReqUpdateMenos()
        reqParam.userId = DataCenter.shared.userInfo.value?.userId ?? ""
        reqParam.id = menosId
        reqParam.tag = tag
        
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
    
    
}

/// 管车助手-详情-功能按钮cell
class ReminderDetailButtonCell: BaseCell {
    
    
    // ui
    @IBOutlet private weak var starBtn: UIButton!
    @IBOutlet var starBtn1: UIButton!
    @IBOutlet private weak var starImv: UIImageView!
    @IBOutlet private weak var starImv1: UIImageView!
    @IBOutlet private weak var imageBtn: UIButton!
    @IBOutlet private weak var imageBtn1: UIButton!
    @IBOutlet private weak var remindBtn: UIButton!
  
    @IBOutlet var remindBtn1: UIButton!
    @IBOutlet private weak var smsBtn: UIButton!
    @IBOutlet private weak var telBtn: UIButton!

    @IBOutlet var normalView: UIView!
    @IBOutlet var addMenoView: UIView!
    weak var viewModel:ReminderDetailButtonCellVM?
    /// 缓存当前选中时间
    var currnetPickDateCache: Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    private func showDatePicker(remindDesc :String, aheadMinutes: Int) {
        
        let pickerView = RemindPickerView(
            frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width:  UIScreen.main.bounds.size.width, height: 0),
            reminTimeDesc: remindDesc, aheadMinutes: aheadMinutes, chooseDate: currnetPickDateCache == nil ? viewModel?.remindTime.value ?? Date(): currnetPickDateCache)

        let rootVC = UIApplication.shared.delegate as! AppDelegate
        rootVC.window?.addSubview(pickerView)
        pickerView.show()
        
        pickerView.remindAction = { [weak self, weak pickerView] in
            self?.currnetPickDateCache = pickerView?.chooseDate
            self?.remindTimePicker()
        }
        pickerView.selectDateBlock = { [weak self] (expireDate, remindDate) in
            self?.viewModel?.didPickRemindDate.onNext((expireDate, remindDate))
        }
    }
    
    private func remindTimePicker() {
        let sheet = UIAlertController(title: "提醒时间", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        sheet.addAction(UIAlertAction(title: "准时", style: .default, handler: {    [weak self](_) in
            self?.showDatePicker(remindDesc: "准时", aheadMinutes: 0)
            
        }))
        for  index in 1...3 {
            sheet.addAction(UIAlertAction(title: "\(index * 5)分钟前", style: .default, handler: { [weak self]  (_) in
                self?.showDatePicker(remindDesc: "\(index * 5)分钟前", aheadMinutes: index * 5)
                
            }))
            
        }
        sheet.addAction(UIAlertAction(title: "30分钟前", style: .default, handler: { [weak self]  (_) in
            self?.showDatePicker(remindDesc: "30分钟前", aheadMinutes: 30)
        }))
        sheet.addAction(UIAlertAction(title: "1小时前", style: .default, handler: { [weak self]  (_) in
            self?.showDatePicker(remindDesc: "60分钟前", aheadMinutes: 60)
        }))
        
        
        sheet.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(sheet, animated: true, completion: nil)
        
    }
    
    /// 格式化选择器（描述，提前分钟）
    private func remindPickInfo(expireTime: Date?, remindTime: Date?) -> (String, Int) {
        
        if let et = expireTime, let rt = remindTime {
            let minutes = et.minutes(from: rt)
            
            if minutes < 5 {
                return ("准时", 0)
            } else if minutes >= 5 && minutes < 10 {
                return ("5分钟前", 5)
            } else if minutes >= 10 && minutes < 15 {
                return ("10分钟前", 10)
            } else if minutes >= 15 && minutes < 30 {
                return ("15分钟前", 15)
            } else if minutes >= 30 && minutes < 60 {
                return ("30分钟前", 30)
            } else if minutes >= 60 {
                return ("1小时前", 60)
            }
        }
        
        return ("准时", 0)
    }
    
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "ReminderDetailButtonCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ReminderDetailButtonCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "ReminderDetailButtonCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 50
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? ReminderDetailButtonCellVM {
            self.viewModel = vm
            currnetPickDateCache = vm.expireTime.value
            
            vm.isStar.asDriver()
                .map { UIImage(named: $0 ? "icon_favoritednote" : "icon_addfavorite" ) }
                .drive(starImv.rx.image)
                .disposed(by: disposeBag)
            vm.isStar.asDriver()
                .map { UIImage(named: $0 ? "icon_favoritednote" : "icon_addfavorite" ) }
                .drive(starImv1.rx.image)
                .disposed(by: disposeBag)
            
            vm.isStar.asDriver()
                .drive(starBtn.rx.isSelected)
                .disposed(by: disposeBag)
           
            vm.isStar.asDriver()
                .drive(starBtn1.rx.isSelected)
                .disposed(by: disposeBag)
            
            
            starBtn.rx.tap.asObservable()
                .map({ [weak self] (_) -> Bool in
                    return !(self?.starBtn.isSelected ?? false)
                })
                .bind(to: vm.didClickStar)
                .disposed(by: disposeBag)

            starBtn1.rx.tap.asObservable()
                .map({ [weak self] (_) -> Bool in
                    return !(self?.starBtn.isSelected ?? false)
                })
                .bind(to: vm.didClickStar)
                .disposed(by: disposeBag)
           
            
            imageBtn.rx.tap.asObservable()
                .map { mLog("【点击】:imageBtn") }
                .bind(to: vm.didClickImage)
                .disposed(by: disposeBag)
           
            imageBtn1.rx.tap.asObservable()
                .map { mLog("【点击】:imageBtn1") }
                .bind(to: vm.didClickImage)
                .disposed(by: disposeBag)
            
            
            remindBtn.rx.tap.asObservable()
                .map { mLog("【点击】:remindBtn") }
                .bind(to: vm.didClickRemind)
                .disposed(by: disposeBag)
           
            remindBtn1.rx.tap.asObservable()
                .map { mLog("【点击】:remindBtn1") }
                .bind(to: vm.didClickRemind)
                .disposed(by: disposeBag)
          
            
            smsBtn.rx.tap.asObservable()
                .bind(to: vm.didClickSms)
                .disposed(by: disposeBag)
            
            telBtn.rx.tap.asObservable()
                .bind(to: vm.didClickTel)
                .disposed(by: disposeBag)
            
            vm.isHiddenTel.asObservable()
                .map { return !$0 }
                .asDriver(onErrorJustReturn: false)
                .drive(addMenoView.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.isHiddenTel.asDriver()
                .asDriver(onErrorJustReturn: true)
                .drive(normalView.rx.isHidden)
                .disposed(by: disposeBag)

            
        }
        
    }

    /// 收起键盘
    @IBAction private func clickBtnCloseKeyboard() {
        IQKeyboardManager.shared.resignFirstResponder()
    }
    
    /// 点击选择时间
    @IBAction func remindTimeClick(_ sender: UIButton) {
        
        IQKeyboardManager.shared.resignFirstResponder()
        
        guard let vm = viewModel else {
            return
        }
        
        let datePickerInfo = remindPickInfo(expireTime: vm.expireTime.value, remindTime: vm.remindTime.value)
        showDatePicker(remindDesc: datePickerInfo.0, aheadMinutes: datePickerInfo.1)
        
    }
    
}
