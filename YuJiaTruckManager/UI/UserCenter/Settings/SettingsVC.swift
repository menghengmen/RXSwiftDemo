//
//  SettingsVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/1/8.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 设置页
class SettingsVC: BaseTableVC {

    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
            
        case is BigTitleCellVM:
            return BigTitleCell.self
        case is SettingsSwitchCellVM:
            return SettingsSwitchCell.self
        
        default:
            return nil
        }
    }
}
