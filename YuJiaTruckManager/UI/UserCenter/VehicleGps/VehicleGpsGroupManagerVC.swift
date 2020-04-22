//
//  VehicleGpsGroupManagerVC.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/2.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

///  分组管理
class VehicleGpsGroupManagerVC: BaseTableVC {
   
    @IBOutlet var cancleBtn: UIButton!
    
    @IBOutlet var addGroupItem: UIBarButtonItem!
    @IBOutlet var deleteItem: UIBarButtonItem!
    @IBOutlet var sureButton: UIButton!
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
        case is BigTitleCellVM:
            return BigTitleCell.self
        case is VehicleGpsHeadCellVM:
            return VehicleGpsHeadCell.self
        case is VehicleGpsGroupManagerCellVM:
            return VehicleGpsGroupManagerCell.self
        default:
            return nil
        }
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? VehicleGpsGroupManagerVM {
           
            sureButton.rx.tap.asObservable()
                .bind(to: vm.didClickSureBtn)
                .disposed(by: disposeBag)
            
            cancleBtn.rx.tap.asObservable()
                .bind(to: vm.didClickCancleBtn)
                .disposed(by: disposeBag)
           
            deleteItem.rx.tap.asObservable()
                .bind(to: vm.didClickDeleteBtn)
                .disposed(by: disposeBag)
            
            addGroupItem.rx.tap.asObservable()
                .bind(to: vm.didClickAddGroupBtn)
                .disposed(by: disposeBag)
            
         
            vm.managerType.asDriver()
                .map {  return $0 == .lookGroup ? true : false  }
                .drive(sureButton.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.managerType.asDriver()
                .map {  return $0 == .lookGroup ? true : false  }
                .drive(cancleBtn.rx.isHidden)
                .disposed(by: disposeBag)
           
            vm.managerType.asDriver()
                .drive(onNext: { [weak self] (type) in
                    guard let sSelf = self else {
                        return
                    }
                    
                    if type == .lookGroup{
                        sSelf.navigationItem.rightBarButtonItems = [self?.addGroupItem,self?.deleteItem] as? [UIBarButtonItem]
                    } else {
                        sSelf.navigationItem.rightBarButtonItems = [self?.addGroupItem] as? [UIBarButtonItem]
                    }
                    
                })
                .disposed(by: disposeBag)
    }
        
    }
}
