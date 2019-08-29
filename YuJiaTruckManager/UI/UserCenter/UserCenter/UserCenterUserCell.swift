//
//  UserCenterUserCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/24.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 用户中心-用户信息cell-viewmodel
class UserCenterUserCellVM: BaseCellVM {
    
    // to view
    /// 姓名
    let name = Variable<String?>(nil)
    /// 公司
    let company = Variable<String?>(nil)
    /// 手机号
    let phone = Variable<String?>(nil)
    
    override init() {
        super.init()

    }
}

/// 用户中心-用户信息cell-view
class UserCenterUserCell: BaseCell {
    
    @IBOutlet private weak var userHeadImv: UIImageView!
    
    @IBOutlet private weak var nameLbl: UILabel!
    @IBOutlet private weak var companyLbl: UILabel!
    @IBOutlet private weak var phoneLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "UserCenterUserCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UserCenterUserCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "UserCenterUserCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 144
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? UserCenterUserCellVM {
            
            vm.name.asDriver()
                .replaceEmpty(" ")
                .drive(nameLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.company.asDriver()
                .replaceEmpty(" ")
                .drive(companyLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.phone.asDriver()
                .replaceEmpty(" ")
                .drive(phoneLbl.rx.text)
                .disposed(by: disposeBag)
        
        }
        
        
    }
    
    
}

