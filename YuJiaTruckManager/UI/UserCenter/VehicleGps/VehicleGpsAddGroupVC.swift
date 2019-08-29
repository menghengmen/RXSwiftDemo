//
//  VehicleGpsAddGroupVC.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/3.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 增加分组
class VehicleGpsAddGroupVC: BaseVC {
    @IBOutlet private weak var groupNameTxf: UITextField!
    @IBOutlet private weak var sureBtn: UIButton!
   
    override func viewBindViewModel() {
        super.viewBindViewModel()
        if let vm = viewModel as? VehicleGpsAddGroupVM{
           
            groupNameTxf.rx.text.orEmpty
                .asObservable()
                .bind(to: vm.groupNameInput)
                .disposed(by: disposeBag)
            
            vm.isEnabelClickSureBtn.asDriver()
                .drive(sureBtn.rx.isEnabled)
                .disposed(by: disposeBag)
            
            
            sureBtn.rx.tap.asObservable()
                .bind(to: vm.clickSureBtn)
                .disposed(by: disposeBag)
            
        }
    }
}
