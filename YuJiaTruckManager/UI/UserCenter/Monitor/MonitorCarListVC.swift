//
//  MonitorCarListVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 实时监控-车辆选择
class MonitorCarListVC: BaseTableVC {
    
    // ui
    @IBOutlet private var searchTxf: UITextField!
    @IBOutlet private var startSearchBtn: UIButton!
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? MonitorCarListVM {
            
            vm.searchText.asDriver()
                .drive(searchTxf.rx.text)
                .disposed(by: disposeBag)
            
            searchTxf.rx.text.orEmpty.asObservable()
                .bind(to: vm.searchText)
                .disposed(by: disposeBag)
            
            startSearchBtn.rx.tap.asObservable()
                .bind(to: vm.didClickSearch)
                .disposed(by: disposeBag)
        }
        
    }
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
            
        case is MonitorCarListCellVM:
            return MonitorCarListCell.self
            
        default:
            return nil
        }
    }
    
}
