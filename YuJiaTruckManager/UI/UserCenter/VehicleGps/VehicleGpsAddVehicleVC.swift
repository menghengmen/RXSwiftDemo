//
//  VehicleGpsAddVehicleVC.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/3.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 分组添加车辆
class VehicleGpsAddVehicleVC: BaseTableVC {
   
    @IBOutlet var closeItem: UIBarButtonItem!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var sureButton: UIButton!
    @IBOutlet var searchTextField: UITextField!

   
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
      
        case is VehicleGpsFilterCellVM:
            return VehicleGpsFilterCell.self
        default:
            return nil
        }
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? VehicleGpsAddVehicleVM {
            
            closeItem.rx.tap.asObservable()
                .bind(to: vm.closeFilter)
                .disposed(by: disposeBag)
            sureButton.rx.tap.asObservable()
                .bind(to: vm.didClickConfirmBtn)
                .disposed(by: disposeBag)
            
            resetButton.rx.tap.asObservable()
                .bind(to: vm.didClickResetBtn)
                .disposed(by: disposeBag)
            
            vm.searchText.asDriver()
                .drive(searchTextField.rx.text)
                .disposed(by: disposeBag)
            
            searchTextField.rx.text.orEmpty.asObservable()
                .bind(to: vm.searchText)
                .disposed(by: disposeBag)
            
        }
    }
  
}
