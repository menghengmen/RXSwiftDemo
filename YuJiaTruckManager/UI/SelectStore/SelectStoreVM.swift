//
//  SelectStoreVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2020/1/15.
//  Copyright © 2020 mh Technology. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YuDaoComponents

class SelectStoreVM: BaseTableVM {

    override init() {
        super.init()
        
        let baseSection = BaseSectionVM()
         
         let cellVM = SelectStoreCellVM()
         baseSection.cellViewModels.append(cellVM)
        
         dataSource.value = [baseSection]
    }
    
}
