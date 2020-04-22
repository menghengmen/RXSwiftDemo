//
//  UserListCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 告警详情-告警信息cell
class UserListCellVM: BaseCellVM {
    
    /// 姓名
    let name = Variable<String?>(nil)
    /// 电话号码
    let phone = Variable<String?>(nil)
    
   
     init(data:ReqUserList.Data) {
        super.init()
        name.value = data.name
        phone.value = data.tel
    }
}


/// 告警详情-告警信息cell
class UserListCell: BaseCell {
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet private weak var familyNameLbl: UILabel!
    @IBOutlet private weak var nameLbl: UILabel!
    @IBOutlet private weak var phoneLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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
        return UINib(nibName: "UserListCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UserListCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "UserListCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 74
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? UserListCellVM {
            
            vm.name.asDriver()
                .map { $0?.yd.substring(from: 0, to: 1) }
                .drive(familyNameLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.name.asDriver()
                .drive(nameLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.phone.asDriver()
                .drive(phoneLbl.rx.text)
                .disposed(by: disposeBag)
        }
        
        
    }
    
    
    
    
}
