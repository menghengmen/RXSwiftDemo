//
//  SelectStoreVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2020/1/15.
//  Copyright © 2020 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YuDaoComponents

class SelectStoreVC: BaseTableVC {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
         case is SelectStoreCellVM:
             return SelectStoreCell .self
           
         default:
            return nil
            
        
        }
    }


}
