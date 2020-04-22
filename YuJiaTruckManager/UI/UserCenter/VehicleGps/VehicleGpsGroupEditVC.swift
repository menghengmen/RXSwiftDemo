//
//  VehicleGpsGroupEditVC.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/2.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

///  编辑分组
class VehicleGpsGroupEditVC: BaseTableVC {

    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancleButton: UIButton!
   
    @IBOutlet var addVehicleItem: UIBarButtonItem!
    @IBOutlet var editItem: UIBarButtonItem!
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
        case is VehicleGpsGroupNameCellVM:
            return VehicleGpsGroupNameCell.self
        case is VehicleGpsFilterCellVM:
            return VehicleGpsFilterCell.self
            
        case is VehicleGpsGroupManagerCellVM:
            return VehicleGpsGroupManagerCell.self
        default:
            return nil
        }
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? VehicleGpsGroupEditVM {
            
            saveButton.rx.tap.asObservable()
                .bind(to: vm.didClickSaveBtn)
                .disposed(by: disposeBag)
            
            cancleButton.rx.tap.asObservable()
                .bind(to: vm.didClickCancleBtn)
                .disposed(by: disposeBag)

            editItem.rx.tap.asObservable()
                .bind(to: vm.didClickEditBtn)
                .disposed(by: disposeBag)
            addVehicleItem.rx.tap.asObservable()
                .bind(to: vm.didClickAddVehicleBtn)
                .disposed(by: disposeBag)
            
            vm.editVCType.asDriver()
                .map {  return $0 == .lookGroup ? true : false  }
                .drive(saveButton.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.editVCType.asDriver()
                .map {  return $0 == .lookGroup ? true : false  }
                .drive(cancleButton.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.editVCType.asDriver()
                .drive(onNext: { [weak self] (type) in
                    guard let sSelf = self else {
                        return
                    }
                    
                    if type == .lookGroup{
                        sSelf.navigationItem.rightBarButtonItems = [self?.addVehicleItem,self?.editItem] as? [UIBarButtonItem]
                    } else {
                        sSelf.navigationItem.rightBarButtonItems = [self?.addVehicleItem] as? [UIBarButtonItem]
                    }
                    
                })
                .disposed(by: disposeBag)
               
            
          
        }
        
    }

}
