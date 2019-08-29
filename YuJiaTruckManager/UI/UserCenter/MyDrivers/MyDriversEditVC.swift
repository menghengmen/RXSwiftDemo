//
//  MyDriversEditVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
import ContactsUI

/// 我的司机-编辑司机
class MyDriversEditVC: BaseVC,CNContactPickerDelegate {
    
    // ui
    @IBOutlet private weak var nameInputTxf: UITextField!
    @IBOutlet private weak var telInputTxf: UITextField!
    @IBOutlet private weak var saveBtn: UIButton!
    
    override func viewSetup() {
        super.viewSetup()
      
    }
    
    @IBAction func openBook(_ sender: UIButton) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if let vm = viewModel as? MyDriversEditVM {
        vm.name.value = "\(contact.familyName)\(contact.givenName)"
        //获取联系人电话号码
        let phones = contact.phoneNumbers
        if phones.count > 1 {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01, execute:
                { [weak self] in
                  self?.morePhonePicker(phones: phones)
                })
            
        } else {
               vm.tel.value = phones.first?.value.stringValue
        }
      }
    }
    
    private func morePhonePicker(phones :[CNLabeledValue<CNPhoneNumber>]){
        let sheet = UIAlertController(title: "选择常用手机号码", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
       
        if let vm = viewModel as? MyDriversEditVM {
           for phone in phones {
            //获取号码
            let phoneValue = phone.value.stringValue
            sheet.addAction(UIAlertAction(title: phoneValue, style: .default, handler: { (_) in
                vm.tel.value = phoneValue
            }))
          }
        }
        sheet.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
        
        present(sheet, animated: true, completion: nil)
        
    }
    
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? MyDriversEditVM {
            
            vm.name.asDriver()
                .drive(nameInputTxf.rx.text)
                .disposed(by: disposeBag)
            
            nameInputTxf.rx.text.asObservable()
                .bind(to: vm.name)
                .disposed(by: disposeBag)
            
            vm.tel.asDriver()
                .drive(telInputTxf.rx.text)
                .disposed(by: disposeBag)
            
            telInputTxf.rx.text.asObservable()
                .bind(to: vm.tel)
                .disposed(by: disposeBag)
            
            vm.isEnableSave.asDriver()
                .drive(saveBtn.rx.isEnabled)
                .disposed(by: disposeBag)
            
            saveBtn.rx.tap.asObservable()
                .bind(to: vm.didClickSave)
                .disposed(by: disposeBag)
            
            
        }
    }
    
}
