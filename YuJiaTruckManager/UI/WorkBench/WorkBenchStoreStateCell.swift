//
//  WorkBenchStoreStateCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/7/7.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// CELL vm
class WorkBenchStoreStateCellVM: BaseCellVM {
    
    let storeName = Variable<String?>(nil)
    let createTime = Variable<String?>(nil)
    let userName = Variable<String?>(nil)
    let phone = Variable<String?>(nil)
    let address = Variable<String?>(nil)

    
    init(data:ReqWorkbenchList.Data) {
        super.init()
        storeName.value = data.storeName
        userName.value = data.userName
        phone.value = data.tel
        address.value = data.storeAddress
        createTime.value = data.createTime
        
    }
}


class WorkBenchStoreStateCell: BaseCell {

    @IBOutlet var storeNameLab: UILabel!
    @IBOutlet var createTimeLab: UILabel!
    @IBOutlet var userNameLab: UILabel!
    @IBOutlet var phoneLab: UILabel!
    @IBOutlet var addressLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "WorkBenchStoreStateCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! WorkBenchStoreStateCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "WorkBenchStoreStateCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 190
    }
    
    open override  func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? WorkBenchStoreStateCellVM {
            
          
            
            vm.storeName.asDriver()
                .drive(storeNameLab.rx.text)
                .disposed(by: disposeBag)
            
            vm.createTime.asDriver()
                .drive(createTimeLab.rx.text)
                .disposed(by: disposeBag)
           
            vm.userName.asDriver()
                .drive(userNameLab.rx.text)
                .disposed(by: disposeBag)
            vm.address.asDriver()
                .drive(addressLab.rx.text)
                .disposed(by: disposeBag)
            vm.phone.asDriver()
                .drive(phoneLab.rx.text)
                .disposed(by: disposeBag)
            

            
        }
    }
    
}
