//
//  UserCenterLogoutCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 用户中心-登出cell
class UserCenterLogoutCellVM: BaseCellVM {
    
    // from view
    /// 点击登出
    let clickLogout = PublishSubject<Void>()
    
    override init() {
        super.init()
        
    }
}

/// 用户中心-登出cell
class UserCenterLogoutCell: BaseCell {
    
    @IBOutlet private weak var logoutBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "UserCenterLogoutCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UserCenterLogoutCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "UserCenterLogoutCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 100
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? UserCenterLogoutCellVM {
            
            logoutBtn.rx.tap.asObservable()
                .bind(to: vm.clickLogout)
                .disposed(by: disposeBag)
            
        }
        
    }
    
    
}

