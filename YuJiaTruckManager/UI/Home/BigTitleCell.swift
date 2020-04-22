//
//  BigTitleCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/7.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit


import YuDaoComponents
import RxSwift
import RxCocoa
import SnapKit

/// 通用大标题cell
class BigTitleCellVM: BaseCellVM {
    
 
    /// 标题
    let title = Variable<String?>(nil)
    /// 右边标题
    let rightTitle = Variable<String?>(nil)
    /// 是是否显示右边按钮
    let showRightItem = Variable<Bool>(false)
    /// 点击右边标题
    let clickRightItem = PublishSubject<Void>()
    
    init(title: String?) {
        super.init()
        self.title.value = title
    }
    
}

/// 历史统计-第三方考核cell
class BigTitleCell: BaseCell {
    
    @IBOutlet private weak var titleLbl: UILabel!
    
    @IBOutlet var rightButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "BigTitleCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! BigTitleCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "BigTitleCell"
    }
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 52
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? BigTitleCellVM {
            vm.title.asDriver()
                .drive(titleLbl.rx.text)
                .disposed(by: disposeBag)
            
            rightButton.rx.tap.asObservable()
                .bind(to: vm.clickRightItem)
                .disposed(by: disposeBag)
            
            vm.rightTitle.asDriver()
                .drive(rightButton.rx.title())
                .disposed(by: disposeBag)
            
            vm.showRightItem.asDriver()
                .map { return !$0 }
                .drive(rightButton.rx.isHidden)
                .disposed(by: disposeBag)
            
        }
    }
    
    
}
