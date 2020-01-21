//
//  SelectStoreCell.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2020/1/15.
//  Copyright © 2020 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YuDaoComponents

/// cell VM
 class SelectStoreCellVM: BaseCellVM {
    let titleVar       = Variable<String?>("")
    let commonInput    = Variable<String?>("")
    
    
    override init() {
        super.init()
        
    }
}




class SelectStoreCell: BaseCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    /// 返回一个新建实例
       open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
           return UINib(nibName: "SelectStoreCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SelectStoreCell
       }
       
       /// 返回重用ID
       open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
           return "SelectStoreCell"
       }
       
       /// 返回高度
       open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
           return 140
       }
    
}
