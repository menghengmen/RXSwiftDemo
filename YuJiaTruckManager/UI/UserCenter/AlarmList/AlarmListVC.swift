//
//  AlarmListVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
import MJRefresh

/// 告警历史页面
class AlarmListVC: BaseTableVC {
    
    // ui
    @IBOutlet private weak var filterBarBtn: UIBarButtonItem!
    
    override func viewSetup() {
        super.viewSetup()
        navBarStyle = .normal
        showNavShadowsLineWhenScroll = true
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? AlarmListVM {
            filterBarBtn.rx.tap.asObservable()
                .bind(to: vm.clickFilterBtn)
                .disposed(by: disposeBag)
        }
        
    }
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
        case is BigTitleCellVM:
            return BigTitleCell.self
        case is AlarmListCellVM:
            return AlarmListCell.self
            
        default:
            return nil
        }
    }
    override func customRefreshHeaderClass() -> MJRefreshHeader.Type {
        return MJRefreshStateHeader.self
    }
    
    override func customRefreshFooterClass() -> MJRefreshFooter.Type {
        return BaseTableFooter.self
    }

    
    
    
}
