//
//  AlarmFilterSelectCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 告警过滤-选择型cell
class AlarmFilterSelectCellVM: BaseCellVM {
    
    // to view
    /// 标题
    let title = Variable<String?>(nil)
    /// 是否支持多选
    let isEnableMultiSelect = Variable<Bool>(false)
    /// 模式
    let flowViewMode = Variable<ButtonFlow.FlowViewType>(.singleSelectItem)
    /// 可选内容
    let allItems = Variable<[String]>([])
    /// 当前选择的
    let selection = Variable<Set<Int>>([])
    
    /// 是否展开
    fileprivate let isOpen = Variable<Bool>(false)
    
    // from view
    /// 点击了全部
    fileprivate let didClickOpenBtn = PublishSubject<Void>()
    /// 更新了选择内容
    fileprivate let didUpdateSelect = PublishSubject<Set<Int>>()
    
    override init() {
        super.init()
        
        didClickOpenBtn.asObservable()
            .map { [weak self] (_) -> Bool in
                return !(self?.isOpen.value ?? false)
         }
            .bind(to: isOpen)
            .disposed(by: disposeBag)
        
        didClickOpenBtn.asObservable()
            .map {}
            .bind(to: reload)
            .disposed(by: disposeBag)
        
        didUpdateSelect.asObservable()
            .bind(to: selection)
            .disposed(by: disposeBag)
        
    }
}


/// 告警过滤-选择型cell
class AlarmFilterSelectCell: BaseCell {
    
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var singleLbl: UILabel!
    @IBOutlet private weak var openBtn: UIButton!
    @IBOutlet private weak var itemContainerView: ButtonFlow!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemContainerView.customButton  = { (btn, _) in
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.setBackgroundImage(UIImage(named: "bg_selected_normal"), for: .normal)
            btn.setBackgroundImage(UIImage(named: "bg_selected_actived"), for: .selected)
        }
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "AlarmFilterSelectCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! AlarmFilterSelectCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "AlarmFilterSelectCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        
        if let vm = viewModel as? AlarmFilterSelectCellVM {
            
            var layout = ButtonFlow.LayoutInfo.filterLayout(type: vm.flowViewMode.value)
            layout.lineMaxWidth = tableSize.width - 56
            let itemSelectHeight = ButtonFlow.fullHeight(by: vm.allItems.value, layoutInfo: layout)
            
            if vm.isOpen.value {
                return 42 + itemSelectHeight + 10
            } else {
                return 42 + (itemSelectHeight > 80 ? 80 : itemSelectHeight) + 10
            }
            
        }
        
        return 42
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? AlarmFilterSelectCellVM {
            
            vm.title.asDriver()
                .drive(titleLbl.rx.text)
                .disposed(by: disposeBag)
            
//            vm.isEnableMultiSelect.asDriver()
//                .map { $0 }
//                .drive(singleLbl.rx.isHidden)
//                .disposed(by: disposeBag)
            
            vm.flowViewMode.asDriver()
                .map { (type) -> Bool in
                    return type != .singleSelectItem
                 }
                .drive(singleLbl.rx.isHidden)
                .disposed(by: disposeBag)
            
            
            vm.isOpen.asDriver()
                .drive(openBtn.rx.isSelected)
                .disposed(by: disposeBag)
            
            openBtn.rx.tap.asObservable()
                .bind(to: vm.didClickOpenBtn)
                .disposed(by: disposeBag)
            
            vm.allItems.asDriver()
                .drive(onNext: { [weak self, weak vm] (value) in
                    if let vmValue = vm {
                        self?.reloadItems(vm: vmValue)
                    }
                })
                .disposed(by: disposeBag)
            
            vm.selection.asDriver()
                .drive(onNext: { [weak self] (value) in
                    if value != self?.itemContainerView.selectedItems {
                        self?.itemContainerView.selectedItems = value
                    }
                })
                .disposed(by: disposeBag)
            
            itemContainerView.didUpdateSelectedItems = { [weak vm] (selection) in
                vm?.didUpdateSelect.onNext(selection)
              
            }
            
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var layout = itemContainerView.layoutInfo
        layout.lineMaxWidth = contentView.frame.width - 56
        
        let itemSelectHeight = ButtonFlow.fullHeight(by: itemContainerView.allItems, layoutInfo: layout)
        if itemSelectHeight > 80 {
            openBtn.isHidden = false
        } else {
            openBtn.isHidden = true
        }
    }
    
    /// 刷新元素
    private func reloadItems(vm: AlarmFilterSelectCellVM) {
        
        let layout = ButtonFlow.LayoutInfo.filterLayout(type: vm.flowViewMode.value)
        
        itemContainerView.layoutInfo = layout
        itemContainerView.type = vm.flowViewMode.value
        itemContainerView.allItems = vm.allItems.value
        itemContainerView.selectedItems = vm.selection.value
        
    }
    
}

/// 本cell使用的布局方案
extension ButtonFlow.LayoutInfo {
    
    /// 过滤器的布局方案
    static func filterLayout(type: ButtonFlow.FlowViewType) -> ButtonFlow.LayoutInfo {
        var layout = ButtonFlow.LayoutInfo.defaultLayout
        
        layout.font = .systemFont(ofSize: 14)
        layout.itemHeight = 32
        layout.itemSpace = 8
        layout.textMargin = 12
        layout.lineSpace = 16
       
        
        if type != .multiSelectItem {
            layout.itemMinWidth = 80

        }
        
        return layout
    }
}

