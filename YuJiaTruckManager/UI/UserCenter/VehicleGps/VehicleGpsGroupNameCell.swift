//
//  VehicleGpsGroupNameCell.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/3.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 分组名cellVM
class VehicleGpsGroupNameCellVM: BaseCellVM {
    
    /// 标题
    let title = Variable<String>("")
    /// 是否可以编辑
    let isEnableEditGroupName = Variable<Bool>(false)
    override init() {
        super.init()
    }
    
}

/// 分组名
class VehicleGpsGroupNameCell: BaseCell {

    @IBOutlet var titleTxf: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "VehicleGpsGroupNameCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! VehicleGpsGroupNameCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "VehicleGpsGroupNameCell"
    }
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 52
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? VehicleGpsGroupNameCellVM {
            vm.title.asDriver()
                .drive(titleTxf.rx.text)
                .disposed(by: disposeBag)
            
            titleTxf.rx.text.orEmpty.asObservable()
                .bind(to: vm.title)
                .disposed(by: disposeBag)
            
            vm.isEnableEditGroupName.asDriver()
                .drive(titleTxf.rx.isUserInteractionEnabled)
                .disposed(by: disposeBag)
        }
    }
}
