//
//  StoreDetailVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/7/29.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents

class StoreDetailVC: BaseTableVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.frame = self.view.frame
        self.tableView?.separatorStyle = .singleLine
        self.tableView?.tableFooterView = UIView()
        self.view.addSubview(self.tableView!)
    }
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
        case is StoreDetailCommonCellVM:
            return StoreDetailCommonCell.self
        case is StoreInputCellVM:
            return StoreInputCell.self
        case is StoreCommonImageCellVM:
            return StoreCommonImageCell.self
            
        default:
            return nil
        }
    }
   
}
