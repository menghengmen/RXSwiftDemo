//
//  VehicleGpsHeadCell.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/28.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 车辆选择-头部cellVM
class VehicleGpsHeadCellVM: BaseCellVM {
    
    /// to view
    /// 标题
    let groupTitle = Variable<String?>("")
    /// 是否全选
    let isAllSelected = Variable<Bool>(false)
    /// 是否可以展开
    let isEnableOpen  = Variable<Bool>(false)
    /// 是否展开
    let isOpen  = Variable<Bool>(false)
    
    
    /// from view
    /// 全选
    let didClickAllSelect = PublishSubject<Bool>()
    /// 展开，折叠
    let didClickOpenBtn = PublishSubject<Bool>()
   
    
    override init() {
        super.init()
        
        didClickOpenBtn.asObservable()
            .bind(to: isOpen)
            .disposed(by: disposeBag)
        
        
    }


}
/// 车辆选择-头部cell
class VehicleGpsHeadCell: BaseCell {

    @IBOutlet var allSelectBtn: UIButton!
    @IBOutlet var gruopName: UILabel!
    @IBOutlet var openButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "VehicleGpsHeadCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! VehicleGpsHeadCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "VehicleGpsHeadCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
      
        return 44
    }
    
    override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? VehicleGpsHeadCellVM {
            
            allSelectBtn.rx.tap.asObservable()
                .map({ [weak self](_) -> Bool in
                    return !(self?.allSelectBtn.isSelected ?? false)
                })
                .bind(to: vm.didClickAllSelect)
                .disposed(by: disposeBag)
            
            openButton.rx.tap.asObservable()
                .map({ [weak self](_) -> Bool in
                    return !(self?.openButton.isSelected ?? false)
                })
                .bind(to: vm.didClickOpenBtn)
                .disposed(by: disposeBag)
            
            vm.isOpen.asDriver()
                .drive(openButton.rx.isSelected)
                .disposed(by: disposeBag)
            
            vm.isAllSelected.asDriver()
                .drive(allSelectBtn.rx.isSelected)
                .disposed(by: disposeBag)
            
            vm.groupTitle.asDriver()
                .drive(gruopName.rx.text)
                .disposed(by: disposeBag)

            vm.isEnableOpen.asDriver()
                .map { !$0 }
                .drive(openButton.rx.isHidden)
                .disposed(by: disposeBag)
       
        }
    
    }
    
}
