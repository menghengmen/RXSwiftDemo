//
//  WorkBenchVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/7/7.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents

class WorkBenchVC: BaseTableVC {

    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type?
     
        {
        switch cellViewModel {
       case is WorkBenchStoreStateCellVM:
            return WorkBenchStoreStateCell.self
        case is UserCenterUserInfoCellVM:
            return UserCenterUserInfoCell.self
        
        default:
            return nil
        }
    }
    

}
