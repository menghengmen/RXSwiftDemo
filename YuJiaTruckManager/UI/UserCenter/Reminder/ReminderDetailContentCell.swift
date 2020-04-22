//
//  ReminderDetailContentCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/26.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 管车助手-详情-内容cell
class ReminderDetailContentCellVM: BaseCellVM {
    
    // to view
    /// 内容
    let content = Variable<String>("")
    /// 是否可以编辑
    let isEnableEditContent = Variable<Bool>(false)
    /// 正在编辑
    let isEditingContent =  Variable<Bool>(false)
    /// 打开键盘
    let openKeyboard = PublishSubject<Void>()
    
    override init() {
        super.init()
        
    }
    
    
}

/// 管车助手-列表cell
class ReminderDetailContentCell: BaseCell {
    
    // ui
    @IBOutlet private weak var contentTxv: UITextView!
    
    static let placeHolder = "请输入您需要说的话吧"
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "ReminderDetailContentCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ReminderDetailContentCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "ReminderDetailContentCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        if let vm = viewModel as? ReminderDetailContentCellVM {
            let cellHeight = vm.content.value.yd.size(withFont: Constants.Font.contentText, limitWidth: (tableSize.width - 114)).height
            
            let fulleHeight = cellHeight + 18
            
            return fulleHeight < 64 ? 64 : fulleHeight
        }
        
        return 64
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? ReminderDetailContentCellVM {
            
            vm.openKeyboard.asDriver(onErrorJustReturn: ())
                .drive(onNext: { [weak self] (_) in
                    self?.contentTxv.becomeFirstResponder()
                })
                .disposed(by: disposeBag)
           
            vm.isEditingContent.asDriver()
                .map({ [weak vm] (editing) -> UIColor in
                    if editing == false && vm?.content.value.count == 0 {
                        return Constants.Color.grayText
                    } else {
                        return Constants.Color.mainText
                    }
                })
                .drive(contentTxv.rx.textColor)
                .disposed(by: disposeBag)
            
            
            Observable<String?>.combineLatest(vm.content.asObservable(), vm.isEditingContent.asObservable()) { (value, editing) -> String in
                if editing == false &&  value.count == 0  {
                    return ReminderDetailContentCell.placeHolder
                } else {
                    return value
                }
                }
                .asDriver(onErrorJustReturn: nil)
                .drive(contentTxv.rx.text)
                .disposed(by: disposeBag)
            
            contentTxv.rx.text.orEmpty.asObservable()
                .map { $0 == ReminderDetailContentCell.placeHolder ? "" : $0 }
                .bind(to: vm.content)
                .disposed(by: disposeBag)
            
            vm.isEnableEditContent.asDriver()
                .drive(contentTxv.rx.isEditable)
                .disposed(by: disposeBag)
        
            contentTxv.rx.didBeginEditing.asObservable()
                .map { true }
                .bind(to: vm.isEditingContent)
                .disposed(by: disposeBag)
            
            contentTxv.rx.didEndEditing.asObservable()
                .map { false }
                .bind(to: vm.isEditingContent)
                .disposed(by: disposeBag)
            
        }
        
    }
    
    
}

