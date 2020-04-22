//
//  StoreInputCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/8/7.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// cell VM
class StoreInputCellVM: BaseCellVM {
    let titleVar       = Variable<String?>("")
    let commonInput = Variable<String?>("")
    
    
     init( title:String, subTitle:String ) {
        super.init()
        titleVar.value = title
        commonInput.value = subTitle
    }
}

class StoreInputCell: BaseCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBOutlet var commonInput: UITextField!
    @IBOutlet var titleLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "StoreInputCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! StoreInputCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "StoreInputCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 50
    }
    
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        if let vm = viewModel as? StoreInputCellVM {
            vm.titleVar.asDriver()
              .drive(titleLabel.rx.text)
              .disposed(by: disposeBag)
            
            vm.commonInput.asDriver()
              .drive(commonInput.rx.placeholder)
              .disposed(by: disposeBag)
       }
        
        
        
    }
    
}
