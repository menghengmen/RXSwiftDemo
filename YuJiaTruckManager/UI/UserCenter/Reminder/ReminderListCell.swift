//
//  ReminderListCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/22.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift
import DateToolsSwift

/// 管车助手-列表cell
class ReminderListCellVM: BaseCellVM {
    
    // Public
    // 弹框透传给vc
    let showMessage = PublishSubject<AlertMessage>()
    /// 备忘录id
    var menosId: String?
    /// 创建时间
    var createTime: Date?
    /// 过期时间
    var expireTime: Date?
    
    
    // to view
    /// 提醒时间()
    let remindTime = Variable<String?>(nil)
    /// 提醒时间（传入到下个界面）
    let remindDetailTime = Variable<Date?>(nil)
    /// 内容
    let content = Variable<String?>(nil)
    /// 图片
    let imageUrl = Variable<String?>(nil)
    /// 标星
    let isStar = Variable<Bool>(false)
    ///
    let hiddenStar = Variable<Bool>(false)
    
    // from view
    /// 点击星标按钮（点击后的状态）
    let didClickStarBtn = PublishSubject<Bool>()
    
    init(data :ReqQueryMenos.Data) {
        super.init()
        menosId = data.id
        createTime = data.createTime?.yd.dateByMs()
        expireTime = data.expireTime?.yd.dateByMs()
        content.value = data.content
        remindDetailTime.value = data.remindTime?.yd.dateByMs()
        /// 今天
        if data.remindTime?.yd.dateByMs()?.isToday ?? false {
            remindTime.value = todaySpecialHnadle(timeStamp: data.remindTime ?? 0)
        } else {
             remindTime.value = data.remindTime?.yd.dateByMs()?.yd.timeString()
        }
  
      
        imageUrl.value = data.picture1
        isStar.value = data.tag == 1 ? true : false
        
        didClickStarBtn.asObservable()
            .bind(to: isStar)
            .disposed(by: disposeBag)
        
        /// 标记过期
        let finishMark = didClickStarBtn.asObservable()
            .flatMapLatest {[weak self] (value) -> Observable<Void> in
                return self?.expireTodoMenosReq(tag: value ? 1 : 0) ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    
        finishMark
            .map { AlertMessage(message: "操作成功", alertType: AlertMessage.AlertType.toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
    }
    
    init(data :ReqMenos.Data) {
        super.init()
        
        menosId = data.id
        createTime = data.createTime?.yd.dateByMs()
        expireTime = data.expireTime?.yd.dateByMs()
        content.value = data.content
        imageUrl.value = data.picture1
        hiddenStar.value = true
        remindDetailTime.value = data.remindTime?.yd.dateByMs()

        /// 今天
        if data.remindTime?.yd.dateByMs()?.isToday ?? false {
            remindTime.value = todaySpecialHnadle(timeStamp: data.remindTime ?? 0)
        } else {
            remindTime.value = data.remindTime?.yd.dateByMs()?.yd.timeString()
        }
    }
    
    /// 今天的时间特殊处理
    private func todaySpecialHnadle(timeStamp: Int64) -> String{
        let remindStr = timeStamp.yd.dateByMs()?.yd.timeString()
        let index = remindStr?.index((remindStr?.startIndex)!, offsetBy: 10)
        let result = remindStr?.suffix(from: index!)
        return "今天".appending(result!)
    }
    
    
    /// 更改待办事项（标星）
    private func expireTodoMenosReq(tag: Int) -> Observable<Void> {
        
        let reqParam = ReqUpdateMenos()
        reqParam.userId = DataCenter.shared.userInfo.value?.userId ?? ""
        reqParam.id = menosId ?? ""
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

/// 管车助手-列表cell
class ReminderListCell: BaseCell {
    
    // ui
    @IBOutlet private weak var timeLbl: UILabel!
    @IBOutlet private weak var contentLbl: UILabel!
    @IBOutlet private weak var attachImageView: UIImageView!
    @IBOutlet private weak var starBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func willTransition(to state: UITableViewCell.StateMask) {
        super.willTransition(to: state)
        if state == .showingDeleteConfirmation {
            contentView.backgroundColor = Constants.Color.grayBg
        } else {
            contentView.backgroundColor = Constants.Color.white
        }
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "ReminderListCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ReminderListCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "ReminderListCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 74
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? ReminderListCellVM {
            
            vm.remindTime.asDriver()
                .replaceEmpty(" ")
                .drive(timeLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.content.asDriver()
                .map({ [weak vm] (value) -> String? in
                    if value == nil || value?.count == 0 {
                        if vm?.imageUrl.value?.count > 0 {
                            return "图片提醒"
                        } else {
                            return "提醒"
                        }
                    }
                    return value
                })
                .drive(contentLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.imageUrl.asDriver()
                .map { $0 == nil || $0?.count == 0 }
                .drive(attachImageView.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.hiddenStar.asDriver()
                .drive(starBtn.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.isStar.asDriver()
                .drive(starBtn.rx.isSelected)
                .disposed(by: disposeBag)
            
            starBtn.rx.tap.asObservable()
                .map({ [weak self] (_) -> Bool in
                    return !(self?.starBtn.isSelected ?? false)
                })
                .bind(to: vm.didClickStarBtn)
                .disposed(by: disposeBag)
            
        }
        
    }
    
    
}


