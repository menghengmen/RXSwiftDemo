//
//  VerifyCodeVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/23.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 验证码登录页
class VerifyCodeVC: BaseVC {
    
    // IBOutlet
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var subtitleLbl: UILabel!
    @IBOutlet private weak var verifyCodeTxf: UITextField!
    @IBOutlet private weak var codeSendBtn: CountDownButton!
    @IBOutlet private weak var loginBtn: UIButton!

    
    override func viewSetup() {
        super.viewSetup()
        
        codeSendBtn.readyText = "重新获取"

    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        if let vm = viewModel as? VerifyCodeVM{
            /// 标题
            vm.title.asDriver()
                .drive(titleLbl.rx.text)
                .disposed(by: disposeBag)
            
            ///副标题
            vm.subTitle.asDriver()
                .drive(subtitleLbl.rx.text)
                .disposed(by: disposeBag)
            //登录
            loginBtn.rx.tap.asObservable()
                .bind(to: vm.loginBtnClick)
                .disposed(by: disposeBag)
            
            ///输入的验证码
            verifyCodeTxf.rx.text.orEmpty
                .asObservable()
                .bind(to: vm.codeInput)
                .disposed(by: disposeBag)
            //发送验证码
            codeSendBtn.buttonTap = {[weak vm] in
                vm?.clickSendCodeBtn.onNext(())
            }
            
            vm.startCountDown.asDriver(onErrorJustReturn: (0))
                .drive(onNext: { [weak self] (countButtonbeginTime) in
                    self?.codeSendBtn.startCountDown(with: countButtonbeginTime)
                })
                .disposed(by: disposeBag)
            
            // 是否可以点击
            vm.isEnableClickNext.asDriver()
                .drive(loginBtn.rx.isEnabled)
                .disposed(by: disposeBag)
            
        }
    }
    
}
