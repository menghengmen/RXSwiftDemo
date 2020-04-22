//
//  UserEditVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa


/// 用户管理-用户编辑/新建页
class UserEditVC: BaseVC {
    
    // ui
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var subtitleLbl: UILabel!
    @IBOutlet private weak var nameInputTxf: UITextField!
    @IBOutlet private weak var phoneInputTxf: UITextField!
    @IBOutlet private weak var confirmBtn: UIButton!
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? UserEditVM {
            
            vm.isCreateUser.asDriver()
                .map { $0 ? "添加用户" : "编辑用户" }
                .drive(titleLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.isCreateUser.asDriver()
                .map { $0 ? "请输入姓名和手机进行编辑" : "请输入姓名和手机进行添加用户" }
                .drive(subtitleLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.name.asDriver()
                .drive(nameInputTxf.rx.text)
                .disposed(by: disposeBag)
            
            nameInputTxf.rx.text.asObservable()
                .bind(to: vm.name)
                .disposed(by: disposeBag)
            
            vm.phone.asDriver()
                .drive(phoneInputTxf.rx.text)
                .disposed(by: disposeBag)
            
            phoneInputTxf.rx.text.asObservable()
                .bind(to: vm.phone)
                .disposed(by: disposeBag)
            
            confirmBtn.rx.tap.asObservable()
                .bind(to: vm.clickConfirm)
                .disposed(by: disposeBag)
            
            vm.isEnableClick.asDriver()
                .drive(confirmBtn.rx.isEnabled)
                .disposed(by: disposeBag)
            
        }
    }
    
}
