//
//  VehicleGpsSearchVC.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/29.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// gps-搜索界面
class VehicleGpsSearchVC: BaseTableVC {
    
    @IBOutlet var closeBarButtonItem: UIBarButtonItem!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var sureButton: UIButton!
    @IBOutlet var searchTextField: UITextField!
   
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
       
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
        
        if let vm = viewModel as? VehicleGpsSearchVM {
           
            closeBarButtonItem.rx.tap.asObservable()
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
