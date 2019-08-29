//
//  RankListCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/26.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 排行榜-列表cell
class RankListCellVM: BaseCellVM {
    
    /// 排名
    let order = Variable<Int?>(nil)
    /// 姓名
    let name = Variable<String?>(nil)
    /// 报警数量
    let alarmNumber = Variable<Int?>(nil)
    
}

/// 管车助手-列表cell
class RankListCell: BaseCell {
    
    // ui
    @IBOutlet private weak var orderLbl: UILabel!
    @IBOutlet private weak var nameLbl: UILabel!
    @IBOutlet private weak var alarmNumLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "RankListCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! RankListCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "RankListCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 83
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? RankListCellVM {
            
            vm.order.asDriver()
                .map { $0 != nil ? "\($0!)" : "-" }
                .drive(orderLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.order.asDriver()
                .map { (value) -> UIColor in
                    switch value {
                    case 1:
                        return mColor(0xF36700)
                    case 2:
                        return mColor(0x2665F4)
                    case 3:
                        return mColor(0x675FF2)
                    default:
                        return mColor(0xD2D2D2)
                    }
                }
                .drive(orderLbl.rx.textColor)
                .disposed(by: disposeBag)
            
            vm.name.asDriver()
                .drive(nameLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.alarmNumber.asDriver()
                .map { $0 != nil ? "\($0!)" : "-" }
                .drive(alarmNumLbl.rx.text)
                .disposed(by: disposeBag)
            
        }
        
    }
    
    
}


