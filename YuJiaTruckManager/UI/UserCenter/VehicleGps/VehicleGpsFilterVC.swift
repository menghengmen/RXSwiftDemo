//
//  VehicleGpsFilterVC.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/28.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// gps-过滤界面
class VehicleGpsFilterVC: BaseTableVC {

    @IBOutlet var closeBarButtonItem: UIBarButtonItem!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var sureButton: UIButton!
    override func viewSetup() {
        super.viewSetup()
    }

    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
        case is BigTitleCellVM:
            return BigTitleCell.self
        case is VehicleGpsHeadCellVM:
            return VehicleGpsHeadCell.self
        case is VehicleGpsFilterCellVM:
            return VehicleGpsFilterCell.self
        default:
            return nil
        }
    }
    
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? VehicleGpsFilterVM {
            closeBarButtonItem.rx.tap.asObservable()
                .bind(to: vm.closeFilter)
                .disposed(by: disposeBag)
            sureButton.rx.tap.asObservable()
                .bind(to: vm.didClickConfirmBtn)
                .disposed(by: disposeBag)
            
            resetButton.rx.tap.asObservable()
                .bind(to: vm.didClickResetBtn)
                .disposed(by: disposeBag)
            
        }
        
    }
}
