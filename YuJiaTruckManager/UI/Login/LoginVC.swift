//
//  LoginVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/22.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxCocoa
import RxSwift

/// 登录页
class LoginVC: BaseVC {
    
    // IBOutlet
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var subtitleLbl: UILabel!
    @IBOutlet private weak var phoneTxf: UITextField!
    @IBOutlet private weak var checkPrivacyBtn: UIButton!
    @IBOutlet private weak var privacyLinkBtn: UIButton!
    @IBOutlet private weak var nextBtn: UIButton!
    @IBOutlet private weak var adminBtn: UIButton!
    
    // 关闭按钮
    private var closeBtn = UIBarButtonItem(title: "关闭", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    
    override func viewSetup() {
        super.viewSetup()
        
        navBarStyle = .translucent
        
        phoneTxf.attributedPlaceholder = "手机号".yd.attrString(withAttributes: [NSAttributedString.Key.foregroundColor : Constants.Color.grayText])
        
        phoneTxf.delegate = self
        
    }

    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? LoginVM {
            
            vm.isShowCloseBtn.asDriver()
                .drive(onNext: { [weak self] (isShow) in
                    self?.navigationItem.leftBarButtonItem = isShow ? self?.closeBtn : nil
                })
                .disposed(by: disposeBag)

            phoneTxf.rx.text.orEmpty
                .asObservable()
                .bind(to: vm.phoneInput)
                .disposed(by: disposeBag)
            
            closeBtn.rx.tap.asObservable()
                .bind(to: vm.clickCloseBtn)
                .disposed(by: disposeBag)
            
            nextBtn.rx.tap.asObservable()
                .bind(to: vm.clickNextBtn)
                .disposed(by: disposeBag)
            
            adminBtn.rx.tap.asObservable()
                .bind(to: vm.clickAdminLoginBtn)
                .disposed(by: disposeBag)
            
            // 隐私
            vm.isCheckPrivacy.asDriver()
                .drive(checkPrivacyBtn.rx.isSelected)
                .disposed(by: disposeBag)
            
            checkPrivacyBtn.rx.tap.asObservable()
                .bind(to: vm.clickCheckBtn)
                .disposed(by: disposeBag)
            
            privacyLinkBtn.rx.tap.asObservable()
                .bind(to: vm.clickPrivacyLink)
                .disposed(by: disposeBag)
            
        }
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField === phoneTxf {
            if range.length == 1 && string.isEmpty {
                return true
            }
            else if (textField.text?.count ?? 0) >= 11 {
                return false
            }
        }
        
        return true
    }
}
