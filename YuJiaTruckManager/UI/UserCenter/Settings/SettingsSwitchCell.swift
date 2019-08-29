//
//  SettingsSwitchCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/1/8.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 用户中心-设置cell-开关型
class SettingsSwitchCellVM: BaseCellVM {
    
    // to view
    /// 标题
    let title = Variable<String?>(nil)
    /// 开关值
    let isOn = Variable<Bool>(false)
    
    // from view
    /// 变化开关值
    let didChangeValue = PublishSubject<Bool>()
    
    override init() {
        super.init()
        
    }
}

/// 用户中心-设置cell-开关型
class SettingsSwitchCell: BaseCell {
    
    // Ui
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var valueSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "SettingsSwitchCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SettingsSwitchCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "SettingsSwitchCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 62
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? SettingsSwitchCellVM {
            
            vm.title.asDriver()
                .drive(titleLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.isOn.asDriver()
                .drive(valueSwitch.rx.isOn)
                .disposed(by: disposeBag)
            
            valueSwitch.rx.isOn.asObservable()
                .distinctUntilChanged()
                .bind(to: vm.didChangeValue)
                .disposed(by: disposeBag)
            
            
        }
        
        
    }
    
    
}

