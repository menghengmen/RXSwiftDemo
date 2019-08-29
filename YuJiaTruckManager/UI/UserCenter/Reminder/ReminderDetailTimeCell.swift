//
//  ReminderDetailTimeCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/26.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 管车助手-详情-时间cell
class ReminderDetailTimeCellVM: BaseCellVM {
    
    // to view
    /// 时间日期
    let createDate = Variable<Date?>(nil)
    /// 提醒日期
    let remindDate = Variable<Date?>(nil)
    
    override init() {
        super.init()
    }
    
    
}

/// 管车助手-列表cell
class ReminderDetailTimeCell: BaseCell {
    
    // ui
    @IBOutlet private weak var createTimeLbl: UILabel!
    @IBOutlet private weak var remindTimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "ReminderDetailTimeCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ReminderDetailTimeCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "ReminderDetailTimeCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 50
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? ReminderDetailTimeCellVM {
            
            vm.createDate.asDriver()
                .map { $0?.yd.timeString() }
                .replaceEmpty("--")
                .map { "创建时间 " + $0 }
                .drive(createTimeLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.remindDate.asDriver()
                .map { $0?.yd.timeString() }
                .replaceEmpty("--")
                .map { "提醒时间 " + $0 }
                .drive(remindTimeLbl.rx.text)
                .disposed(by: disposeBag)
            
        }
        
    }
    
    
}

