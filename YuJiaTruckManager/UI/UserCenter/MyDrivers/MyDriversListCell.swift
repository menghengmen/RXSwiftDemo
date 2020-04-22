//
//  MyDriversListCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/22.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 我的司机-司机列表cell
class MyDriversListCellVM: BaseCellVM {
    
    /// id
    let id  = Variable<String?>(nil)
    /// 姓名
    let name = Variable<String?>(nil)
    /// 电话
    let tel = Variable<String?>(nil)
    /// 姓名前缀
    let namePrefix = Variable<String?>(nil)
    
 init(data:ReqDriverList.Data) {
       super.init()
        name.asObservable()
            .map { $0?.yd.substring(from: 0, to: 1) }
            .bind(to: namePrefix)
            .disposed(by: disposeBag)
        
        name.value = data.name
        tel.value = data.tel
        id.value = data.id
   
    }
    
    
}

/// 我的司机-司机列表cell
class MyDriversListCell: BaseCell {
    
    // ui
    @IBOutlet private weak var nameLbl: UILabel!
    @IBOutlet private weak var telLbl: UILabel!
    @IBOutlet private weak var namePrefixLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func willTransition(to state: UITableViewCell.StateMask) {
        super.willTransition(to: state)
        if state == .showingDeleteConfirmation {
            contentView.backgroundColor = Constants.Color.grayBg
        } else {
            contentView.backgroundColor = Constants.Color.white
        }
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "MyDriversListCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! MyDriversListCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "MyDriversListCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 74
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? MyDriversListCellVM {
            
            vm.name.asDriver()
                .drive(nameLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.tel.asDriver()
                .drive(telLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.namePrefix.asDriver()
                .drive(namePrefixLbl.rx.text)
                .disposed(by: disposeBag)
            
        }
        
    }
    
    
}
