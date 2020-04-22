//
//  AlarmFilterTimeCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/28.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 告警过滤-日期cell
class AlarmFilterTimeCellVM: BaseCellVM {
    
    // to view
    /// 开始日期
    let startDate = Variable<Date?>(nil)
    /// 结束日期
    let endDate = Variable<Date?>(nil)
    
    // from view
    /// 点击选择日期
    let didClickSelectDate = PublishSubject<Void>()
    
    override init() {
        super.init()
        
    }
}


/// 告警过滤-日期cell
class AlarmFilterTimeCell: BaseCell {
    
    @IBOutlet private weak var timeLbl: UILabel!
    @IBOutlet private weak var selectDateBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    //MARK:车牌键盘代理方法-required
    func plateInputComplete(plate: String) {
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "AlarmFilterTimeCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! AlarmFilterTimeCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "AlarmFilterTimeCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 95
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? AlarmFilterTimeCellVM {
            
            let startDateStr = vm.startDate.asObservable()
                .map { $0?.format(with: "yyyy/MM/dd") }
                .replaceEmpty("--")
            
            let endDateStr = vm.endDate.asObservable()
                .map { $0?.format(with: "yyyy/MM/dd") }
                .replaceEmpty("--")
            
            Observable<String>.combineLatest(startDateStr, endDateStr) { $0 + "~" + $1 }
                .asDriver(onErrorJustReturn: "--")
                .drive(timeLbl.rx.text)
                .disposed(by: disposeBag)

            selectDateBtn.rx.tap.asObservable()
                .bind(to: vm.didClickSelectDate)
                .disposed(by: disposeBag)
            
        }
        
    }
    
    
}
