//
//  AlarmFilterVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 告警过滤器页面
class AlarmFilterVC: BaseTableVC {
    
    @IBOutlet private weak var resetBtn: UIButton!
    @IBOutlet private weak var confirmBtn: UIButton!
    @IBOutlet private weak var closeBtn: UIBarButtonItem!
    
    override func viewSetup() {
        super.viewSetup()
        navBarStyle = .normal
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? AlarmFilterVM {
            
            resetBtn.rx.tap.asObservable()
                .bind(to: vm.didClickReset)
                .disposed(by: disposeBag)
            
            confirmBtn.rx.tap.asObservable()
                .bind(to: vm.didClickConfirm)
                .disposed(by: disposeBag)
            
            closeBtn.rx.tap.asObservable()
                .bind(to: vm.didClickClose)
                .disposed(by: disposeBag)
            
            vm.didClickSelectDate.asDriver(onErrorJustReturn: ())
                .drive(onNext: { [weak self] (_) in
                    self?.showDatePicker()
                })
                .disposed(by: disposeBag)
        }
        
        
    }
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
        case is BigTitleCellVM:
            return BigTitleCell.self
            
        case is AlarmFilterSelectCellVM:
            return AlarmFilterSelectCell.self
            
        case is AlarmFilterInputCellVM:
            return AlarmFilterInputCell.self
            
        case is AlarmFilterTimeCellVM:
            return AlarmFilterTimeCell.self
            
        default:
            return nil
        }
    }
    
    private func showDatePicker() {
    
        if let vm = viewModel as? AlarmFilterVM {
            
            let pickerView = HistoryPickerView.init(frame: CGRect(x: 0, y:view.frame.size.height , width:  view.frame.size.width, height: 0), startDate: vm.startTime.value, endDate: vm.endTime.value)
            
            
            let rootVC = UIApplication.shared.delegate as! AppDelegate
            rootVC.window?.addSubview(pickerView)
            pickerView.show()
            
            pickerView.selectDateBlock = {[weak vm] beginDate,endDate in
                vm?.didFinishSelectDate.onNext((beginDate, endDate))
            }
        }
        
    }
    
}
