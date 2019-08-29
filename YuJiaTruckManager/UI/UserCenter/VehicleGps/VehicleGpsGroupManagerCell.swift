//
//  VehicleGpsGroupManagerCell.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/2.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 车辆分组管理-cellVM
class VehicleGpsGroupManagerCellVM: BaseCellVM {
    
    /// 缓存数据源
    var groupData: ReqGetGroups.Data?
    
    /// to view
    /// 组名
    let groupTitle = Variable<String?>("")
    /// 是否选
    let isCellSelected = Variable<Bool>(false)
    /// 是否是编辑模式
    let isEditMode = Variable<Bool>(false)
   
    /// from view
    /// 选
    let didClickSelect = PublishSubject<Bool>()
    
    override init() {
        super.init()
        
        didClickSelect.asObservable()
            .bind(to: isCellSelected)
            .disposed(by: disposeBag)
   
    }
    
    
}


/// 车辆分组管理-cell
class VehicleGpsGroupManagerCell: BaseCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var groupNameLeftMargin: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "VehicleGpsGroupManagerCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! VehicleGpsGroupManagerCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "VehicleGpsGroupManagerCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        
        return 60
    }
    
    override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? VehicleGpsGroupManagerCellVM {
           
            selectButton.rx.tap.asObservable()
                .map({ [weak self](_) -> Bool in
                    return !(self?.selectButton.isSelected ?? false)
                })
                .bind(to: vm.didClickSelect)
                .disposed(by: disposeBag)
            
            
            vm.groupTitle.asDriver()
                .drive(titleLabel.rx.text)
                .disposed(by: disposeBag)
            
            vm.isCellSelected.asDriver()
                .drive(selectButton.rx.isSelected)
                .disposed(by: disposeBag)
            
            vm.isEditMode.asObservable()
                .map { return !$0 }
                .asDriver(onErrorJustReturn: false)
                .drive(selectButton.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.isEditMode.asDriver()
                .drive(onNext: { [weak self] (isEdit) in
                    if isEdit == false{
                        self?.groupNameLeftMargin.constant = -34
                    } else {
                        self?.groupNameLeftMargin.constant = 10
                        
                    }
                })
                .disposed(by: disposeBag)
            
          
            
            
        }
        
    }
}
