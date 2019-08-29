//
//  AlarmFilterInputCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa
import VehicleKeyboard_swift

/// 告警过滤-输入型cell
class AlarmFilterInputCellVM: BaseCellVM {
    
    /// 标题
    let title = Variable<String?>(nil)
    /// 搜索的文字内容
    let searchText = Variable<String>("")
    /// 提示文字
    let placeHolder = Variable<String?>(nil)
    /// 是否开启车牌号键盘
    let isOpenCarKeyBoard = Variable<Bool>(false)
    
    override init() {
        super.init()
        
    }
}


/// 告警过滤-输入型cell
class AlarmFilterInputCell: BaseCell ,PWHandlerDelegate{
    let handler = PWHandler()

    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var inputTxf: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        
    }
    
    //MARK:车牌键盘代理方法-required
    func plateInputComplete(plate: String) {
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "AlarmFilterInputCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! AlarmFilterInputCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "AlarmFilterInputCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 95
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? AlarmFilterInputCellVM {
            if vm.isOpenCarKeyBoard.value {
                inputTxf.changeToPlatePWKeyBoardInpurView()
                handler.delegate = self
                
            }
            
            vm.title.asDriver()
                .drive(titleLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.placeHolder.asDriver()
                .drive(inputTxf.rx.placeholder)
                .disposed(by: disposeBag)
            
            vm.searchText.asDriver()
                .drive(inputTxf.rx.text)
                .disposed(by: disposeBag)
            
            inputTxf.rx.text.orEmpty.asObservable()
                .bind(to: vm.searchText)
                .disposed(by: disposeBag)
        }
        
    }
    
    
}
