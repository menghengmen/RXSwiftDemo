//
//  MyDriversListSection.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/28.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxCocoa
import RxSwift
import SnapKit

/// 我的司机-列表section
class MyDriversListSectionVM: BaseSectionVM {
    
    /// 索引
    let indexTitle = Variable<String>("")
    
}

/// 我的司机-列表section header
class MyDriversListSectionHeadView: BaseSectionHeadView {
    
    private var titleLbl = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(28)
            maker.centerY.equalToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func createInstance(with viewModel: SectionViewModelProtocol) -> UITableViewHeaderFooterView? {
        return MyDriversListSectionHeadView(reuseIdentifier: MyDriversListSectionHeadView.reuseID(with: viewModel))
    }
    
    override class func reuseID(with viewModel: SectionViewModelProtocol) -> String {
        return "MyDriversListSectionHeadView"
    }
    
    /// 计算高度
    override class func height(with viewModel: SectionViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 32
    }
    
    /// 通过view model更新view，子类重写时需要调用super方法
    override func updateView(with viewModel: SectionViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? MyDriversListSectionVM {
            
            vm.indexTitle.asDriver()
                .drive(titleLbl.rx.text)
                .disposed(by: disposeBag)
        }
    }
    
}
