//
//  VehicleGpsFilterCell.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/28.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 车辆选择-流式布局cellVM
class VehicleGpsFilterCellVM: BaseCellVM {
    /// to view
    
    /// 可选内容
    let allItems = Variable<[String]>([])
    /// 当前选择的
    let selection = Variable<Set<Int>>([])
    /// 不可选的
    let disableIndexs = Variable<Set<Int>>([])
    
    
    /// 是否展开
    let cellIsOpen = Variable<Bool>(false)
    /// 模式
    let flowViewMode = Variable<ButtonFlow.FlowViewType>(.singleSelectItem)
    
    /// frow view
    /// 更新了选择内容
    fileprivate let didUpdateSelect = PublishSubject<Set<Int>>()
    /// 计算出了cell的最终行数
    let didComputeCellFullLine = PublishSubject<Int>()
    /// 删除模式下，删除的回调
    let didDeleteItem = PublishSubject<Int>()
    
    
    override init() {
        super.init()
        
        cellIsOpen.asObservable()
            .distinctUntilChanged()
            .map{ _ in  }
            .bind(to: reload)
            .disposed(by: disposeBag)
        
        didUpdateSelect.asObservable()
            .bind(to: selection)
            .disposed(by: disposeBag)
        
    }
    
    
}

/// 车辆选择-流式布局cell
class VehicleGpsFilterCell: BaseCell {
    
    @IBOutlet var flowContentView: ButtonFlow!
    var viewModel: VehicleGpsFilterCellVM?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    /// 点击按钮
    @objc private func clickButton(_ delete: UIButton) {
        
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "VehicleGpsFilterCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! VehicleGpsFilterCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "VehicleGpsFilterCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        if let vm = viewModel as? VehicleGpsFilterCellVM {
            
            var layout = ButtonFlow.LayoutInfo.vehiclefilterLayout(type: vm.flowViewMode.value)
            layout.lineMaxWidth = tableSize.width - 56
            let itemSelectHeight = ButtonFlow.fullHeight(by: vm.allItems.value, layoutInfo: layout)
            
            if vm.cellIsOpen.value {
                return itemSelectHeight + 20
            } else {
                return (itemSelectHeight > 80 ? 80 : itemSelectHeight) + 20
            }
            
        }
        
        return 0
    }
    
    override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        if let vm = viewModel as? VehicleGpsFilterCellVM {
            
            self.viewModel = vm
            
            vm.allItems.asDriver()
                .drive(onNext: { [weak self, weak vm] (value) in
                    if let vmValue = vm {
                        self?.reloadItems(vm: vmValue)
                    }
                })
                .disposed(by: disposeBag)
            
            vm.selection.asDriver()
                .drive(onNext: { [weak self] (value) in
                    if value != self?.flowContentView.selectedItems {
                        self?.flowContentView.selectedItems = value
                    }
                })
                .disposed(by: disposeBag)
            
            flowContentView.didUpdateSelectedItems = { [weak vm] (selection) in
                vm?.didUpdateSelect.onNext(selection)
                
            }
            
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var layout = flowContentView.layoutInfo
        layout.lineMaxWidth = contentView.frame.width - 56
        
        let itemLine = ButtonFlow.fullLine(by: flowContentView.allItems, layoutInfo: layout)
//        mLog("【cell计算】items：\(flowContentView.allItems) | lines：\(itemLine)")
        viewModel?.didComputeCellFullLine.onNext(itemLine)
        
    }
    
    /// 刷新元素
    private func reloadItems(vm: VehicleGpsFilterCellVM) {
        
        flowContentView.customButton  = { [weak flowContentView, weak self] (btn, _) in
            btn.setTitleColor(Constants.Color.mainText, for: .normal)
            btn.titleLabel?.font = mFont(14)
            
//            let disableIdxs = self?.viewModel?.disableIndexs.value ?? []
            
            if flowContentView?.type == .deleteItem {
                btn.setBackgroundImage(UIImage(named: "bg_deletecar"), for: .normal)
                btn.titleEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
            } else {
                btn.setBackgroundImage(UIImage(named: "bg_selected_normal"), for: .normal)
                btn.setBackgroundImage(UIImage(named: "bg_selected_actived"), for: .selected)
                btn.titleEdgeInsets = UIEdgeInsets.zero
            }
            
            btn.setBackgroundImage(UIImage(named: "bg_disabled"), for: .disabled)
        }
        
        flowContentView.didDeleteItem = { [weak self] (idx) in
            self?.viewModel?.didDeleteItem.onNext(idx)
        }
        
        var layout = ButtonFlow.LayoutInfo.vehiclefilterLayout(type: vm.flowViewMode.value)
        layout.lineMaxWidth = contentView.frame.width - 56
        
        flowContentView.type = vm.flowViewMode.value
        flowContentView.layoutInfo = layout
        flowContentView.type = vm.flowViewMode.value
        flowContentView.allItems = vm.allItems.value
        flowContentView.selectedItems = vm.selection.value
        flowContentView.disabledItems = vm.disableIndexs.value
        
    }
}

/// 本cell使用的布局方案
extension ButtonFlow.LayoutInfo {
    
    /// 过滤器的布局方案
    static func vehiclefilterLayout(type: ButtonFlow.FlowViewType) -> ButtonFlow.LayoutInfo {
        var layout = ButtonFlow.LayoutInfo.defaultLayout
        
        layout.font = .systemFont(ofSize: 14)
        layout.itemHeight = type == .deleteItem ? 47 : 32
        layout.itemSpace = 8
        layout.textMargin = 12
        layout.lineSpace = 16
        
        layout.itemMinWidth = 95
        layout.itemMaxWidth = 95
        
        return layout
    }
}
