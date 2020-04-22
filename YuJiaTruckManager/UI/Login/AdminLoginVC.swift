//
//  AdminLoginVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/23.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 管理员登录页
class AdminLoginVC: BaseVC {
    
    // IBOutlet
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var subtitleLbl: UILabel!
    @IBOutlet private weak var usernameTxf: UITextField!
    @IBOutlet private weak var passwordTxf: UITextField!
    @IBOutlet private weak var loginBtn: UIButton!
    
    override func viewSetup() {
        super.viewSetup()
        navBarStyle = .translucent
        
    }
    
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        if let vm = viewModel as? AdminLoginVM{
            usernameTxf.rx.text.orEmpty
                .asObservable()
                .bind(to: vm.accountInput)
                .disposed(by: disposeBag)
            
            passwordTxf.rx.text.orEmpty
                .asObservable()
                .bind(to: vm.passwordInput)
                .disposed(by: disposeBag)
            
            vm.isEnabelClickNext.asDriver()
                .drive(loginBtn.rx.isEnabled)
                .disposed(by: disposeBag)
            
            loginBtn.rx.tap.asObservable()
                .bind(to: vm.clickNextBtn)
                .disposed(by: disposeBag)
            
            
        }
        
    }
    
}

