//
//  StoreDetailCommonCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/7/29.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// cell VM
class StoreDetailCommonCellVM: BaseCellVM {
    let title          =  Variable<String?>("")
    let subTitle       =  Variable<String?>("")
    let hiddenClickBtn =  Variable<Bool>(true)
    let imageName      =  Variable<String?>("")
    
    let didClickButton = PublishSubject<Void>()
    
    override init(){
        super.init()
        didClickButton.asObservable()
            .map { (_) -> String in
                return "13783452657"
            }
           .bind(to: MessageCenter.shared.needCallTelephone)
           .disposed(by: disposeBag)
        
    }
}

class StoreDetailCommonCell: BaseCell {

    @IBOutlet var clickButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var rightMargin: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "StoreDetailCommonCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! StoreDetailCommonCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "StoreDetailCommonCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 64
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        if  let vm = viewModel as? StoreDetailCommonCellVM {
            
            vm.title.asDriver()
              .drive(titleLabel.rx.text)
              .disposed(by: disposeBag)
           
            vm.subTitle.asDriver()
              .drive(subTitle.rx.text)
              .disposed(by: disposeBag)
            
            vm.hiddenClickBtn.asDriver()
              .drive(clickButton.rx.isHidden)
              .disposed(by: disposeBag)
            
            vm.imageName.asDriver()
                .map { (value) -> UIImage? in
                    return (UIImage(named: value ?? ""))
                }
                .drive(clickButton.rx.backgroundImage())
                .disposed(by: disposeBag)
            
            vm.hiddenClickBtn.asDriver()
                .drive(onNext: {[weak self](value) in
                    if value == true{
                       self?.rightMargin.constant = -40
                    } else {
                        self?.rightMargin.constant = 20
                    }
               })
                .disposed(by: disposeBag)
           
            clickButton.rx.tap.asObservable()
                .bind(to: vm.didClickButton)
                .disposed(by: disposeBag)

        
       }
    
    
     }


}
