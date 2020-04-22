//
//  UserCenterUserInfoCell.swift
//  YuJia
//
//  Created by mh on 2018/7/26.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 用户中心-用户信息cell-viewmodel
class UserCenterUserInfoCellVM: BaseCellVM {
    
    // to view
    /// 头像
    let userHead = Variable<UIImage?>(nil)
    /// 姓名
    let userName = Variable<String?>(nil)
    /// 公司
    let userCompany = Variable<String?>(nil)
    /// 是否加入企业
    let isEnterpriseUser = Variable<Bool>(false)
    
    // from view
    /// 点击了激活
    let clickActive = PublishSubject<Void>()
    
    override init() {
        super.init()

    }
}

/// 用户中心-用户信息cell-view
class UserCenterUserInfoCell: BaseCell {
    
    @IBOutlet private weak var userHeadImv: UIImageView!
    
    @IBOutlet private weak var userContainerView: UIView!
    @IBOutlet private weak var nameLbl: UILabel!
    @IBOutlet private weak var companyLbl: UILabel!
    @IBOutlet private weak var enterpriseUserImv: UIImageView!
    
    @IBOutlet private weak var activeContainerView: UIView!
    @IBOutlet private weak var noEnterpriseLbl: UILabel!
    @IBOutlet private weak var activeBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        noEnterpriseLbl.text = Constants.Text.userNoConpany
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "UserCenterUserInfoCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UserCenterUserInfoCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "UserCenterUserInfoCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 86
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? UserCenterUserInfoCellVM {
            
            vm.userHead.asObservable()
                .map { return $0 ?? #imageLiteral(resourceName: "icon_car") }
                .asDriver(onErrorJustReturn: UIImage())
                .drive(userHeadImv.rx.image)
                .disposed(by: disposeBag)
            
            vm.userName.asObservable()
                .map { return $0 ?? "----" }
                .asDriver(onErrorJustReturn: "----")
                .drive(nameLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.userCompany.asObservable()
                .map { return $0 ?? "----" }
                .asDriver(onErrorJustReturn: "----")
                .drive(companyLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.isEnterpriseUser.asObservable()
                .map { return !$0 }
                .asDriver(onErrorJustReturn: false)
                .drive(userContainerView.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.isEnterpriseUser.asObservable()
                .asDriver(onErrorJustReturn: true)
                .drive(activeContainerView.rx.isHidden)
                .disposed(by: disposeBag)
            
            activeBtn.rx.tap.asObservable()
                .bind(to: vm.clickActive)
                .disposed(by: disposeBag)
            
        }
        
    }

    
}
